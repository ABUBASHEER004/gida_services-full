import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription<QuerySnapshot>? _chatSub;
  static StreamSubscription<QuerySnapshot>? _adminSub;
  static StreamSubscription<QuerySnapshot>? _requestSub;

  // =========================
  // INITIALIZE
  // =========================
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      showNotification(
        message.notification?.title ?? "New Message",
        message.notification?.body ?? "",
      );
    });
  }

  // =========================
  // SHOW LOCAL NOTIFICATION
  // =========================
  static Future<void> showNotification(
    String title,
    String body,
  ) async {
    const android = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for chats and updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: android,
      ),
    );
  }

  // =========================
  // USER / PROVIDER CHATS
  // =========================
  static void listenForChats(String receiverId) {
    _chatSub?.cancel();

    _chatSub = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: receiverId)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;

        final data =
            change.doc.data() as Map<String, dynamic>?;

        if (data == null) continue;

        showNotification(
          "New Message",
          data['message']?.toString() ??
              data['text']?.toString() ??
              "You received a new message",
        );
      }
    });
  }

  // =========================
  // ADMIN SUPPORT CHAT
  // =========================
  static void listenForAdminChats(String receiverId) {
    _adminSub?.cancel();

    _adminSub = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: receiverId)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;

        final data =
            change.doc.data() as Map<String, dynamic>?;

        if (data == null) continue;

        if (data['chatType'] != 'admin_support') {
          continue;
        }

        showNotification(
          "Admin Support",
          data['message']?.toString() ??
              data['text']?.toString() ??
              "New support message received",
        );
      }
    });
  }

  // =========================
  // REQUEST STATUS CHANGES
  // =========================
  static void listenForRequestUpdates(String providerId) {
    _requestSub?.cancel();

    _requestSub = FirebaseFirestore.instance
        .collection('requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.modified) {
          continue;
        }

        final data =
            change.doc.data() as Map<String, dynamic>?;

        if (data == null) continue;

        final status =
            data['status']?.toString() ?? 'updated';

        showNotification(
          "Request Update",
          "Request status changed to $status",
        );
      }
    });
  }

  // =========================
  // SAVE DEVICE TOKEN
  // =========================
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // =========================
  // CLEANUP
  // =========================
  static void dispose() {
    _chatSub?.cancel();
    _adminSub?.cancel();
    _requestSub?.cancel();

    _chatSub = null;
    _adminSub = null;
    _requestSub = null;
  }
}