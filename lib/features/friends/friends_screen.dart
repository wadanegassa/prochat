import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildSearchAndFilter(isDark),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _chatService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return _buildSkeletonLoaders();
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

                  final users = snapshot.data!
                      .where((u) => u.uid != currentUser.uid)
                      .where((u) => u.name.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .toList();

                  if (users.isEmpty) return _buildEmptyState();

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildModernUserCard(context, users[index], isDark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _buildCircleAction(Icons.menu_rounded, isDark),
      ),
      title: const Text('Friends'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildCircleAction(Icons.search_rounded, isDark),
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
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.rose, size: 22),
                fillColor: isDark ? AppTheme.brown.withValues(alpha: 0.3) : const Color(0xFFF5F5F7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.brown.withValues(alpha: 0.3) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.tune_rounded, color: isDark ? AppTheme.peach : AppTheme.brown, size: 22),
    );
  }

  Widget _buildModernUserCard(BuildContext context, UserModel user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.brown.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.peach.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppTheme.rose, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.brown)),
                const SizedBox(height: 2),
                Text(
                  user.isOnline ? 'Active now' : 'Seen recently',
                  style: TextStyle(color: user.isOnline ? AppTheme.sage : AppTheme.brown.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(receiverId: user.uid, receiverName: user.name, receiverPhotoUrl: user.photoUrl)));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.rose.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.rose, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoaders() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppTheme.softGrey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppTheme.brown.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('Your circle is waiting to grow!', style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.3), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
