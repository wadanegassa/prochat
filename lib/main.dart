import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/main_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ProChat',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.rose, strokeWidth: 3),
                  SizedBox(height: 24),
                  Text(
                    'Gathering leaves...',
                    style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          if (authProvider.userModel != null) {
            return const MainScreen();
          } else {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.sage.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.nature_rounded, color: AppTheme.sage, size: 40),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'NATURAL SYNC',
                        style: TextStyle(
                          color: AppTheme.brown,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re aligning your profile with the universe.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.rose.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(32),
                            ),
                            border: Border.all(color: AppTheme.rose.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.waves_rounded, color: AppTheme.rose, size: 32),
                              const SizedBox(height: 16),
                              Text(
                                authProvider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppTheme.rose, fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () => authProvider.repairMissingProfile("Nature Traveler"),
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                          label: const Text('REPAIR CONNECTION'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brown,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => authProvider.signOut(),
                          child: Text(
                            'BACK TO ENTRANCE',
                            style: TextStyle(
                              color: AppTheme.brown.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
