import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> users;
  final String lastMessage;
  final int lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.users,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      users: List<String>.from(data['users'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] ?? 0,
      unreadCount: data['unreadCount'] ?? 0, // Note: This might need a separate stream count if not stored directly
    );
  }
}
