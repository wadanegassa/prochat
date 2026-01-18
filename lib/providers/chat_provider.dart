import 'package:flutter/material.dart';
import '../core/models/message_model.dart';
import '../core/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage(
      String senderId, String senderName, String receiverId, String text, MessageType type) async {
    await _chatService.sendMessage(senderId, senderName, receiverId, text, type);
  }

  Stream<List<MessageModel>> getMessages(String userId, String otherUserId) {
    return _chatService.getMessages(userId, otherUserId);
  }

  Future<void> updateMessage(String chatRoomId, String messageId, String newText) async {
    await _chatService.updateMessage(chatRoomId, messageId, newText);
  }

  Future<void> deleteMessage(String chatRoomId, String messageId, bool deleteForBoth, String currentUserId) async {
    await _chatService.deleteMessage(chatRoomId, messageId, deleteForBoth, currentUserId);
  }

  // --- Group Messaging ---
  
  Stream<List<MessageModel>> getGroupMessages(String groupId, String userId) {
    return _chatService.getGroupMessages(groupId, userId);
  }

  Future<void> sendGroupMessage(String groupId, String senderId, String senderName, String text) async {
    await _chatService.sendGroupMessage(groupId, senderId, senderName, text);
  }

  Future<void> updateGroupMessage(String groupId, String messageId, String newText) async {
    await _chatService.updateGroupMessage(groupId, messageId, newText);
  }

  Future<void> deleteGroupMessage(String groupId, String messageId, bool deleteForBoth, String currentUserId) async {
    await _chatService.deleteGroupMessage(groupId, messageId, deleteForBoth, currentUserId);
  }
}
