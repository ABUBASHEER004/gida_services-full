import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (IMPORTANT for Android 13+ and iOS)
    await _messaging.requestPermission();

    // Get token (you store this in Firestore later)
    String? token = await _messaging.getToken();
    debugPrint("FCM Token: $token");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("New Notification: ${message.notification?.title}");
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Notification clicked!");
    });
  }
}
