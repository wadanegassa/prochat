import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isEdited;
  final String senderName;
  final List<String> deletedBy;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.isEdited = false,
    this.senderName = '',
    this.deletedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'isEdited': isEdited,
      'senderName': senderName,
      'deletedBy': deletedBy,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.text,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      senderName: map['senderName'] ?? '',
      deletedBy: List<String>.from(map['deletedBy'] ?? []),
    );
  }

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data, doc.id);
  }
}
