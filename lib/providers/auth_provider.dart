import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true; // Initialize to true for initial check
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _onAuthStateChanged(user);
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true; // Set loading true at the start of state change
    notifyListeners();

    if (user == null) {
      _userModel = null;
    } else {
      _userModel = await _authService.getUserDetails(user.uid);
      // Initialize notifications when user is logged in
      NotificationService().initialize();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userModel = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _userModel = await _authService.registerWithEmailAndPassword(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
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
}
