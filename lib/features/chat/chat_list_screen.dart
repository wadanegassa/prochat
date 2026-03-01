import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/chat_room.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  late AuthProvider _authProvider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Note: Global status update is handled by AuthProvider/AuthService
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    final currentUser = _authProvider.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildSearchAndFilter(isDark),
          Expanded(
            child: _buildChatList(currentUser, isDark),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _buildCircleAction(Icons.notes_rounded, isDark),
      ),
      title: const Text('Chats'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildCircleAction(Icons.notifications_none_rounded, isDark),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.brown.withValues(alpha: 0.3) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.brown.withValues(alpha: 0.05), width: 1),
      ),
      child: Icon(icon, color: isDark ? AppTheme.peach : AppTheme.brown, size: 20),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for item',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.rose, size: 22),
                fillColor: isDark ? AppTheme.brown.withValues(alpha: 0.3) : softGreyVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(isDark),
        ],
      ),
    );
  }

  // Helper color for the search bar background (very light light grey)
  static final Color softGreyVariant = const Color(0xFFF5F5F7);

  Widget _buildFilterButton(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.brown.withValues(alpha: 0.3) : softGreyVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.tune_rounded, color: isDark ? AppTheme.peach : AppTheme.brown, size: 22),
    );
  }

  Widget _buildChatList(UserModel currentUser, bool isDark) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _chatService.getChatRooms(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildSkeletonLoaders();
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

        final rooms = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: rooms.length,
          itemBuilder: (context, index) => _buildModernChatTile(rooms[index], currentUser.uid, isDark),
        );
      },
    );
  }

  Widget _buildModernChatTile(ChatRoom room, String currentUserId, bool isDark) {
    final otherUserId = room.users.firstWhere((id) => id != currentUserId);

    return StreamBuilder<UserModel?>(
      stream: _chatService.getUserStream(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'Loading...';
        
        if (_searchController.text.isNotEmpty && !name.toLowerCase().contains(_searchController.text.toLowerCase())) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.brown.withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: otherUserId,
                    receiverName: name,
                    receiverPhotoUrl: user?.photoUrl ?? '',
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(12),
            leading: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.peach.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.rose, fontSize: 20),
                    ),
                  ),
                ),
                if (user?.isOnline ?? false)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.sage,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppTheme.deepBrown : Colors.white, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.brown),
                ),
                Text(
                  _formatTimestamp(room.lastMessageTime),
                  style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.brown.withValues(alpha: 0.4),
                        fontSize: 14,
                        fontWeight: room.unreadCount > 0 ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (room.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.rose,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        room.unreadCount.toString().padLeft(2, '0'),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    )
                  else if (room.lastMessageSenderId == currentUserId)
                    Icon(Icons.done_all_rounded, size: 16, color: AppTheme.brown.withValues(alpha: 0.2)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (now.day == date.day) return '${date.hour}:${date.minute.toString().padLeft(2, '0')} PM';
    return '${date.day}/${date.month}';
  }

  Widget _buildSkeletonLoaders() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.softGrey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.brown.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.3), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
