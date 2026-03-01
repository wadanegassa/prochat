import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/chat_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ChatService _chatService = ChatService();
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.rose)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, user, isDark),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsCard(user, isDark),
                const SizedBox(height: 16),
                _buildBioCard(context, user, isDark),
                const SizedBox(height: 16),
                _buildSettingsSection(context, themeProvider, user, isDark),
                const SizedBox(height: 24),
                _buildLogoutButton(context, isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, UserModel user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : AppTheme.rose,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          onPressed: () => _showEditProfileSheet(context, user, isDark),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderBackground(context, user, isDark),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context, UserModel user, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E253D), Color(0xFF0B0F1A)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.rose, AppTheme.peach],
              ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildAvatar(context, user),
            const SizedBox(height: 14),
            // Name
            Text(
              user.name.isNotEmpty ? user.name : 'Unknown User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            // Email
            Text(
              user.email,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(user),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserModel user) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () => _showAvatarOptions(context, user),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: user.photoUrl.isNotEmpty
                  ? Image.network(
                      user.photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _avatarFallback(user),
                      errorBuilder: (_, __, ___) => _avatarFallback(user),
                    )
                  : _avatarFallback(user),
            ),
          ),
        ),
        // Camera badge
        GestureDetector(
          onTap: () => _showAvatarOptions(context, user),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.rose,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
          ),
        ),
        // Online dot
        if (user.isOnline)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF4DDE80),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback(UserModel user) {
    return Container(
      color: AppTheme.rose.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: user.isOnline ? const Color(0xFF4DDE80) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            user.isOnline ? 'Online' : 'Offline',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Real-data Stats Card ─────────────────────────────────────────────────────

  Widget _buildStatsCard(UserModel user, bool isDark) {
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final subColor = isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Contacts count from Firestore
          StreamBuilder<List<UserModel>>(
            stream: _chatService.getUsers(),
            builder: (ctx, snap) {
              final count = snap.hasData
                  ? (snap.data!.where((u) => u.uid != user.uid).length)
                  : 0;
              return _buildStatItem(
                count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count',
                'Contacts',
                textColor,
                subColor,
              );
            },
          ),
          _buildVerticalDivider(isDark),
          // Chat rooms count from Firestore
          StreamBuilder<List<dynamic>>(
            stream: _chatService.getChatRooms(user.uid),
            builder: (ctx, snap) {
              final count = snap.hasData ? snap.data!.length : 0;
              return _buildStatItem(
                count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count',
                'Chats',
                textColor,
                subColor,
              );
            },
          ),
          _buildVerticalDivider(isDark),
          // Groups count from Firestore
          StreamBuilder<List<dynamic>>(
            stream: _chatService.getGroups(user.uid),
            builder: (ctx, snap) {
              final count = snap.hasData ? snap.data!.length : 0;
              return _buildStatItem('$count', 'Groups', textColor, subColor);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color textColor, Color subColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subColor)),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 36,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark ? Colors.white.withValues(alpha: 0.08) : AppTheme.brown.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ─── Bio Card ─────────────────────────────────────────────────────────────────

  Widget _buildBioCard(BuildContext context, UserModel user, bool isDark) {
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final subColor = isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.rose.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.rose, size: 17),
              ),
              const SizedBox(width: 12),
              Text('About Me', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showEditBioDialog(context, user, isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.rose),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.bio.isNotEmpty ? user.bio : 'No bio yet. Tap Edit to add one.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subColor, height: 1.6),
          ),
          const Divider(height: 24, thickness: 0.5),
          // Tappable UID (copies to clipboard)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: user.uid));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('User ID copied to clipboard'),
                  backgroundColor: AppTheme.rose,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.copy_rounded, size: 13, color: subColor),
                const SizedBox(width: 8),
                Text(
                  'UID: ${user.uid.length > 18 ? '${user.uid.substring(0, 18)}…' : user.uid}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Settings ─────────────────────────────────────────────────────────────────

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider, UserModel user, bool isDark) {
    return Column(
      children: [
        _buildSettingsGroup('NOTIFICATIONS', [
          _buildSettingsTile(
            'Push Notifications',
            Icons.notifications_active_outlined,
            isDark,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _updateNotificationPref(user.uid, v);
              },
              activeThumbColor: AppTheme.rose,
            ),
          ),
        ], isDark),
        const SizedBox(height: 14),
        _buildSettingsGroup('PREFERENCES', [
          _buildSettingsTile(
            'Dark Mode',
            Icons.dark_mode_outlined,
            isDark,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.toggleTheme(),
              activeThumbColor: AppTheme.rose,
            ),
          ),
          _buildSettingsTile(
            'Language',
            Icons.language_rounded,
            isDark,
            subtitle: _selectedLanguage,
            onTap: () => _showLanguagePicker(context, isDark),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4),
            ),
          ),
        ], isDark),
        const SizedBox(height: 14),
        _buildSettingsGroup('ACCOUNT', [
          _buildSettingsTile(
            'Edit Name',
            Icons.person_outline_rounded,
            isDark,
            onTap: () => _showEditNameDialog(context, user, isDark),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4),
            ),
          ),
          _buildSettingsTile(
            'Privacy',
            Icons.shield_outlined,
            isDark,
            onTap: () => _showComingSoon(context, 'Privacy settings'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4),
            ),
          ),
          _buildSettingsTile(
            'Blocked Users',
            Icons.block_rounded,
            isDark,
            onTap: () => _showComingSoon(context, 'Blocked users'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4),
            ),
          ),
        ], isDark),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> tiles, bool isDark) {
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final labelColor = isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: labelColor, letterSpacing: 1.2)),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    bool isDark, {
    Widget? trailing,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final subColor = isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppTheme.rose.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.rose, size: 17),
        ),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subColor))
            : null,
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return TextButton.icon(
      onPressed: () => _confirmSignOut(context),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.rose,
        backgroundColor: AppTheme.rose.withValues(alpha: isDark ? 0.15 : 0.1),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
    );
  }

  // ─── Dialogs & Sheets ─────────────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, UserModel user, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(user: user, isDark: isDark),
    );
  }

  void _showEditNameDialog(BuildContext context, UserModel user, bool isDark) {
    final controller = TextEditingController(text: user.name);
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Edit Name', style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.rose),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              await Provider.of<AuthProvider>(context, listen: false)
                  .updateDisplayName(newName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Name updated!'),
                    backgroundColor: AppTheme.rose,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, UserModel user, bool isDark) {
    final controller = TextEditingController(text: user.bio);
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Edit Bio', style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          maxLength: 150,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newBio = controller.text.trim();
              Navigator.pop(ctx);
              await _updateBioInFirestore(user.uid, newBio);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Bio updated!'),
                    backgroundColor: AppTheme.rose,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.rose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.link_rounded, color: AppTheme.rose, size: 20),
              ),
              title: Text('Set from URL', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
              subtitle: Text('Paste an image URL', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4), fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showSetPhotoUrlDialog(context, user, isDark);
              },
            ),
            if (user.photoUrl.isNotEmpty)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                ),
                title: Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _updatePhotoUrl(user.uid, '');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSetPhotoUrlDialog(BuildContext context, UserModel user, bool isDark) {
    final controller = TextEditingController(text: user.photoUrl);
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Photo URL', style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            prefixIcon: Icon(Icons.link_rounded, color: AppTheme.rose),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();
              Navigator.pop(ctx);
              await _updatePhotoUrl(user.uid, url);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Photo updated!'),
                    backgroundColor: AppTheme.rose,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, bool isDark) {
    final languages = ['English', 'Amharic (አማርኛ)', 'Afaan Oromo', 'Tigrinya (ትግርኛ)', 'Arabic (عربي)', 'French (Français)'];
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 12),
            ...languages.map((lang) => ListTile(
              title: Text(lang, style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
              trailing: _selectedLanguage == lang
                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.rose)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        backgroundColor: AppTheme.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ─── Firestore Updates ────────────────────────────────────────────────────────

  Future<void> _updateBioInFirestore(String uid, String bio) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'bio': bio});
  }

  Future<void> _updatePhotoUrl(String uid, String url) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'photoUrl': url});
  }

  Future<void> _updateNotificationPref(String uid, bool enabled) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'notificationsEnabled': enabled});
  }
}

// ─── Edit Profile Bottom Sheet ────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserModel user;
  final bool isDark;

  const _EditProfileSheet({required this.user, required this.isDark});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 20),
            Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5), letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Your name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.rose),
              ),
            ),
            const SizedBox(height: 16),
            Text('Bio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5), letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              maxLength: 150,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(hintText: 'Something about you...'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'bio': bio, 'name': name});
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated!'),
            backgroundColor: AppTheme.rose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
