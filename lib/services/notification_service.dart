import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/meal.dart';
import '../screens/meal_confirm_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final FlutterTts _tts = FlutterTts();
  static GlobalKey<NavigatorState>? _navigatorKey;

  // ─── Init ───────────────────────────────────────────────────────────────────

  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    _navigatorKey = navKey;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Request Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _initTts();
  }

  // ─── Notification tap handler ───────────────────────────────────────────────

  static void _onTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    if (payload.startsWith('confirm_')) {
      final parts = payload.split('|');
      final mealId = parts[0].replaceFirst('confirm_', '');
      final mealName = parts.length > 1 ? parts[1] : 'الوجبة';
      _navigatorKey?.currentState?.push(MaterialPageRoute(
        builder: (_) =>
            MealConfirmScreen(mealId: mealId, mealName: mealName),
      ));
    }
  }

  // ─── TTS ─────────────────────────────────────────────────────────────────────

  static Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  static Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ─── Channel details ──────────────────────────────────────────────────────────

  static const _androidDetails = AndroidNotificationDetails(
    'sihati_meals',
    'تنبيهات الوجبات',
    channelDescription: 'تنبيهات مواعيد وجبات تطبيق سحتي',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentSound: true,
    presentAlert: true,
    presentBadge: true,
  );

  static const _notifDetails =
      NotificationDetails(android: _androidDetails, iOS: _iosDetails);

  // ─── Schedule all three notifications for a meal ─────────────────────────────

  static Future<void> scheduleMealNotifications(Meal meal) async {
    final now = tz.TZDateTime.now(tz.local);
    var mealTime = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, meal.hour, meal.minute);
    if (mealTime.isBefore(now)) {
      mealTime = mealTime.add(const Duration(days: 1));
    }

    final base = meal.id.hashCode.abs() % 10000;
    final payload = 'confirm_${meal.id}|${meal.name}';

    // 1. 15 minutes before
    final minus15 = mealTime.subtract(const Duration(minutes: 15));
    if (minus15.isAfter(now)) {
      await _scheduleOne(
        id: base + 1,
        title: '⏰ تذكير بالوجبة القادمة',
        body: 'بقي ربع ساعة على موعد ${meal.name}',
        time: minus15,
      );
    }

    // 2. Exactly at meal time
    if (mealTime.isAfter(now)) {
      await _scheduleOne(
        id: base + 2,
        title: '🍽️ حان موعد ${meal.name}!',
        body: 'حان الآن موعدك الغذائي — لا تنسَ وجبتك.',
        time: mealTime,
        speakText: 'السلام عليكم، حان موعد ${meal.name}.',
      );
    }

    // 3. Confirmation — 30 minutes after
    final plus30 = mealTime.add(const Duration(minutes: 30));
    if (plus30.isAfter(now)) {
      await _scheduleOne(
        id: base + 3,
        title: '✅ هل تناولت ${meal.name}؟',
        body: 'اضغط هنا للتأكيد أو الإجابة بلا.',
        time: plus30,
        payload: payload,
      );
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime time,
    String? payload,
    String? speakText,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: time,
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: payload,
    );

    // If the app is open when the time arrives, also speak
    if (speakText != null) {
      final delay = time.difference(tz.TZDateTime.now(tz.local));
      if (!delay.isNegative) {
        Future.delayed(delay, () => speak(speakText));
      }
    }
  }

  // ─── Cancel ──────────────────────────────────────────────────────────────────

  static Future<void> cancelMealNotifications(String mealId) async {
    final base = mealId.hashCode.abs() % 10000;
    await _plugin.cancel(id: base + 1);
    await _plugin.cancel(id: base + 2);
    await _plugin.cancel(id: base + 3);
  }
}
