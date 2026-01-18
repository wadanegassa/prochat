import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? groupPhotoUrl;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.lastMessage,
    required this.lastMessageTime,
    this.groupPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'groupPhotoUrl': groupPhotoUrl,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime lastTime;
    var time = map['lastMessageTime'];
    if (time is Timestamp) {
      lastTime = time.toDate();
    } else if (time is int) {
      lastTime = DateTime.fromMillisecondsSinceEpoch(time);
    } else {
      lastTime = DateTime.now();
    }

    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: lastTime,
      groupPhotoUrl: map['groupPhotoUrl'],
    );
  }

  factory GroupModel.fromDocument(DocumentSnapshot doc) {
    return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
