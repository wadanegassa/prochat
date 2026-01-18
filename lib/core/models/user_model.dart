import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime lastSeen;
  final bool isOnline;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.lastSeen,
    required this.isOnline,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'isOnline': isOnline,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime lastSeen;
    var seen = map['lastSeen'];
    if (seen is Timestamp) {
      lastSeen = seen.toDate();
    } else if (seen is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(seen);
    } else {
      lastSeen = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      lastSeen: lastSeen,
      isOnline: map['isOnline'] ?? false,
      fcmToken: map['fcmToken'],
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
