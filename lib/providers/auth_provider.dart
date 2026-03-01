import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _onAuthStateChanged(user);
    });
  }

  /// Subscribes to live Firestore changes so bio/photoUrl edits update the UI immediately.
  void _subscribeToUserDoc(String uid) {
    _userDocSubscription?.cancel();
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userModel = UserModel.fromDocument(snapshot);
        notifyListeners();
      }
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (user == null) {
      _userDocSubscription?.cancel();
      _userDocSubscription = null;
      _userModel = null;
      _isLoading = false;
      notifyListeners();
    } else {
      // Retry a few times if the user document isn't found immediately (race condition during registration)
      int retries = 3;
      while (retries > 0) {
        try {
          _userModel = await _authService.getUserDetails(user.uid);
          if (_userModel != null) {
            NotificationService().initialize();
            // Start live listener so profile edits (bio, photoUrl, name) reflect instantly
            _subscribeToUserDoc(user.uid);
            break;
          }
        } catch (e) {
          if (retries == 1) {
             _errorMessage = "Connection error: ${e.toString()}";
          }
        }
        
        if (_userModel == null && retries > 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
        retries--;
      }
      
      if (_userModel == null && _errorMessage == null) {
        _errorMessage = "User profile not found. Please try signing out and in again.";
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _userModel = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Could not retrieve user profile.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().contains('user-not-found') 
          ? "No user found with this email." 
          : e.toString().contains('wrong-password')
              ? "Incorrect password."
              : "Login error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.registerWithEmailAndPassword(email, password, name);
      if (user != null) {
        _userModel = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to create user profile.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().contains('email-already-in-use')
          ? "This email is already registered."
          : "Registration error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userDocSubscription?.cancel();
      _userDocSubscription = null;
      await _authService.signOut();
      _userModel = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDisplayName(String newName) async {
    await _authService.updateDisplayName(newName);
    if (_userModel != null) {
      _userModel = UserModel(
        uid: _userModel!.uid,
        name: newName,
        email: _userModel!.email,
        photoUrl: _userModel!.photoUrl,
        bio: _userModel!.bio,
        lastSeen: _userModel!.lastSeen,
        isOnline: _userModel!.isOnline,
        fcmToken: _userModel!.fcmToken,
      );
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    await _authService.updateUserStatus(isOnline);
  }

  Future<void> repairMissingProfile(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = _authService.currentUser;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          photoUrl: '',
          bio: 'Nature Traveler',
          lastSeen: DateTime.now(),
          isOnline: true,
        );
        await _authService.createProfile(newUser);
        _userModel = newUser;
        NotificationService().initialize();
      }
    } catch (e) {
      _errorMessage = "Repair failed: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
