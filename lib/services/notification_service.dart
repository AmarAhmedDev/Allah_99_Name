import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: null, // iOS initialization removed as this is an Android-focused app
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Create Notification Channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminders', // id
      'Daily Reminders', // name
      description: 'Notifications for daily Asma-ul-Husna reading', // description
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Schedules daily notifications at random proper times (e.g., between 9 AM and 8 PM)
  /// for the next 7 days to encourage memorization.
  Future<void> scheduleRandomDailyReminders() async {
    // Clear old scheduled notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    final random = Random();
    final now = tz.TZDateTime.now(tz.local);

    final notificationMessages = [
      "Time to read and memorize a new name of Allah! 🌟",
      "Have you checked the 99 Names today? Open to continue your journey! ✨",
      "Keep up the great work! Learn one more beautiful name today. 📖",
      "Mashallah! Your progress is waiting. Open the app to learn more. 🕌",
      "A moment with the Names of Allah is a moment well spent. Let's learn! 🕋",
    ];

    // Schedule for the next 7 days
    for (int i = 0; i < 7; i++) {
      // Pick random hour between 9 (9 AM) and 19 (7 PM)
      final int randomHour = 9 + random.nextInt(11);
      final int randomMinute = random.nextInt(60);

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + i,
        randomHour,
        randomMinute,
      );

      // If scheduled time for today has already passed, skip today.
      if (i == 0 && scheduledDate.isBefore(now)) {
        continue;
      }

      final message = notificationMessages[random.nextInt(notificationMessages.length)];

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: i,
        title: 'Asma\'ul Husna Reminder',
        body: message,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Notifications for daily Asma-ul-Husna reading',
            icon: '@mipmap/launcher_icon',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFD4AF37), // Gold color
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
