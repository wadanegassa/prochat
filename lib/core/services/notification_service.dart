import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using them.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get token and save if user is already logged in
    String? token = await _fcm.getToken();
    if (token != null) {
      _saveTokenToFirestore(token);
    }

    // Listen to token refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
        // Note: Actual navigation logic depends on app state/routing
      },
    );

    // Create high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle interaction when app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation to chat
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Handle navigation to chat
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      } catch (e) {
        // Log error internally if needed
      }
    }
  }

  Future<void> updateToken() async {
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['chatId'], // Pass data for navigation
    );
  }
}
