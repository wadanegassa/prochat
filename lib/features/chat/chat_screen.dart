import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhotoUrl;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  String? _editingMessageId;
  String? _editingText;

  void _startEditing(MessageModel message) {
    setState(() {
      _editingMessageId = message.id;
      _editingText = message.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _editingText = null;
    });
  }

  void _onMessageLongPress(MessageModel message, bool isMe) {
    if (!isMe) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppTheme.rose),
              title: const Text('EDIT MESSAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: AppTheme.brown)),
              onTap: () {
                Navigator.pop(context);
                _startEditing(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('DELETE MESSAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(message);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('DELETE MESSAGE?', style: TextStyle(color: AppTheme.rose, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: const Text('THIS ACTION CANNOT BE UNDONE.', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              final roomId = ChatService.getChatRoomId(authProvider.userModel!.uid, widget.receiverId);
              chatProvider.deleteMessage(roomId, message.id, true, authProvider.userModel!.uid);
              Navigator.pop(context);
            },
            child: const Text('DELETE FOR BOTH', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userModel;
    if (currentUser != null) {
      final roomId = ChatService.getChatRoomId(currentUser.uid, widget.receiverId);
      _chatService.markMessagesAsRead(roomId, currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).userModel;
    final chatProvider = Provider.of<ChatProvider>(context);

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.getMessages(currentUser.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUser.uid,
                      onLongPress: () => _onMessageLongPress(message, message.senderId == currentUser.uid),
                    );
                  },
                  reverse: true,
                );
              },
            ),
          ),
          ChatInput(
            senderId: currentUser.uid,
            receiverId: widget.receiverId,
            editingMessageId: _editingMessageId,
            editingText: _editingText,
            onCancelEditing: _cancelEditing,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: StreamBuilder<UserModel?>(
        stream: _chatService.getUserStream(widget.receiverId),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final isOnline = user?.isOnline ?? false;
          
          return Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.sage.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.receiverName[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.sage, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.sage,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOnline ? AppTheme.sage : AppTheme.brown.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(icon: const Icon(Icons.call_rounded, size: 22), onPressed: () {}),
        IconButton(icon: const Icon(Icons.videocam_rounded, size: 22), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert_rounded, size: 22), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }
}
