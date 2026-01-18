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
      print('Sign in error: $e');
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
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          photoUrl: '',
          lastSeen: DateTime.now(),
          isOnline: true,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
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
      print('Get user details error: $e');
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
}
