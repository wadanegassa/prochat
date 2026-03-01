import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        UserModel? userDetails = await getUserDetails(user.uid);
        if (userDetails != null) {
           await updateUserStatus(true);
           return userDetails;
        }
      }
      return null;
    } catch (e) {
      // Log error internally if needed
      rethrow;
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Essential: Give a tiny bit of time for the auth token to propagate to Firestore client
        await Future.delayed(const Duration(milliseconds: 500));
        
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          photoUrl: '',
          bio: 'Hey there! I am using ProChat.',
          lastSeen: DateTime.now(),
          isOnline: true,
        );
        
        try {
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        } catch (e) {
          // If Firestore write fails (e.g. permission denied), cleanup the auth user 
          // to allow the user to try again with the same email.
          // Firestore write failed during registration, cleaning up auth user...
          await user.delete();
          rethrow;
        }
        return newUser;
      }
      return null;
    } catch (e) {
      // Log error internally if needed
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Log error internally if needed
    }
    await _auth.signOut();
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      // Log error internally if needed
      return null;
    }
  }
  
  Future<void> updateUserStatus(bool isOnline) async {
    if (currentUser != null) {
       await _firestore.collection('users').doc(currentUser!.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateDisplayName(String newName) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'name': newName,
      });
    }
  }

  Future<void> createProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}
