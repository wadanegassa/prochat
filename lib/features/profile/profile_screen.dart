import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildProfileSection(user, isDark),
            const SizedBox(height: 32),
            _buildStatCard(isDark),
            const SizedBox(height: 32),
            _buildSettingsSection(themeProvider, isDark),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
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
      title: const Text('Profile'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildCircleAction(Icons.settings_outlined, isDark),
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

  Widget _buildProfileSection(UserModel user, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.peach.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(44),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppTheme.rose),
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.rose,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppTheme.deepBrown : Colors.white, width: 3),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.brown)),
        const SizedBox(height: 4),
        Text(user.email, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.brown.withValues(alpha: 0.4))),
      ],
    );
  }

  Widget _buildStatCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.brown.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('156', 'Friends'),
          _buildVerticalDivider(isDark),
          _buildStatItem('1.4k', 'Messages'),
          _buildVerticalDivider(isDark),
          _buildStatItem('32', 'Collections'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.brown)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.brown.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: AppTheme.brown.withValues(alpha: 0.05),
    );
  }

  Widget _buildSettingsSection(ThemeProvider themeProvider, bool isDark) {
    return Column(
      children: [
        _buildSettingsGroup('NOTIFICATION', [
          _buildSettingsTile('Push Notifications', Icons.notifications_none_rounded, isDark, trailing: Switch(value: true, onChanged: (v) {}, activeThumbColor: AppTheme.rose)),
        ], isDark),
        const SizedBox(height: 24),
        _buildSettingsGroup('PREFERENCE', [
          _buildSettingsTile('Dark Mode', Icons.dark_mode_outlined, isDark, trailing: Switch(value: themeProvider.isDarkMode, onChanged: (v) => themeProvider.toggleTheme(), activeThumbColor: AppTheme.rose)),
          _buildSettingsTile('Language', Icons.language_rounded, isDark, trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.brown.withValues(alpha: 0.3))),
        ], isDark),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> tiles, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.brown.withValues(alpha: 0.4), letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.brown.withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, bool isDark, {Widget? trailing}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.peach.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.rose, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.brown)),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.rose,
        backgroundColor: AppTheme.rose.withValues(alpha: 0.1),
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
    );
  }
}
