import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/notification_settings_model.dart';
import '../../data/models/fiscal_calendar_model.dart';

final notificationSettingsProvider =
    StateNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettingsModel
    >((ref) {
      return NotificationSettingsNotifier();
    });

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsModel> {
  final _box = Hive.box<NotificationSettingsModel>('notificationSettings');

  NotificationSettingsNotifier() : super(_getInitialState()) {
    _initTimezone();
  }

  static NotificationSettingsModel _getInitialState() {
    final box = Hive.box<NotificationSettingsModel>('notificationSettings');
    return box.get('settings') ?? const NotificationSettingsModel();
  }

  void _initTimezone() {
    tz.initializeTimeZones();
  }

  Future<void> updateSettings(NotificationSettingsModel settings) async {
    await _box.put('settings', settings);
    state = settings;
  }

  Future<bool> requestPermissions() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ requires explicit permission request too, but we handle the simple case here.
    return result ?? true;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleEventNotifications(
    List<FiscalCalendarModel> events,
  ) async {
    final settings = _ref.read(notificationSettingsProvider);

    await _notificationsPlugin.cancelAll();

    if (!settings.isPushEnabled) return;

    int notificationId = 0;
    final now = DateTime.now();

    for (final event in events) {
      if (!_shouldNotifyForEvent(event, settings)) continue;

      final reminderDate = event.date.subtract(
        Duration(days: settings.reminderDaysBefore),
      );

      // Only schedule if the reminder date is in the future
      if (reminderDate.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: 'Rappel Fiscal : ${event.title}',
          body: event.description,
          scheduledDate: reminderDate,
        );
      }

      // Also schedule on the day of the event
      if (event.date.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: 'Aujourd\'hui : ${event.title}',
          body: 'N\'oubliez pas : ${event.description}',
          scheduledDate: DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
            9,
            0,
          ), // 9 AM
        );
      }
    }
  }

  bool _shouldNotifyForEvent(
    FiscalCalendarModel event,
    NotificationSettingsModel settings,
  ) {
    switch (event.type) {
      case FiscalEventType.deadline:
        return settings.notifyDeadlines;
      case FiscalEventType.declaration:
        return settings.notifyDeclarations;
      case FiscalEventType.payment:
        return settings.notifyPayments;
      default:
        return true;
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fiscalia_reminders',
      'Rappels Fiscaux',
      channelDescription: 'Notifications pour les dates limites fiscales',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
