import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.userModel;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    if (!_isEditing) {
      _nameController.text = user.name;
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(color: Theme.of(context).scaffoldBackgroundColor),
        title: const Text('PROFILE'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppTheme.pureGold),
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty) {
                  await authProvider.updateDisplayName(_nameController.text.trim());
                  setState(() {
                    _isEditing = false;
                  });
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppTheme.pureGold),
              onPressed: () => setState(() => _isEditing = true),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.pureGold.withOpacity(0.2), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: AppTheme.pureGold.withOpacity(0.05),
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(Icons.person_outline_rounded, size: 60, color: AppTheme.pureGold)
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.pureGold.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    if (_isEditing)
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        decoration: const InputDecoration(
                          labelText: 'DISPLAY NAME',
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      )
                    else
                      Text(
                        user.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppTheme.pureGold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      user.email.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DARK MODE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                          activeThumbColor: AppTheme.pureGold,
                          activeTrackColor: AppTheme.pureGold.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              TextButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthWrapper()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('SIGN OUT'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent.withOpacity(0.8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
