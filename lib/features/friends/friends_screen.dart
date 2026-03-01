import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
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
            _buildSearchField(isDark),
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
                    padding: const EdgeInsets.only(bottom: 100),
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
      title: const Text('Contacts'),
      actions: const [
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Find someone new...',
          prefixIcon: Icon(Icons.search_rounded, 
            color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.3), 
            size: 22
          ),
        ),
      ),
    );
  }

  Widget _buildModernUserCard(BuildContext context, UserModel user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.peach.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: (user.photoUrl.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      user.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: AppTheme.rose,
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppTheme.rose,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 16, 
                    color: isDark ? const Color(0xFFE0E0E0) : AppTheme.brown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: user.isOnline ? AppTheme.sage : (isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.3)), 
                    fontSize: 12, 
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(receiverId: user.uid, receiverName: user.name, receiverPhotoUrl: user.photoUrl)));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.vibrantBlue, size: 20),
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
