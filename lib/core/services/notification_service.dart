import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'hydroflow_reminders';
  static const _channelName = 'Hydration Reminders';
  static const _channelDescription = 'Scheduled water intake reminders';

  static const _actionDrank = 'action_drank';
  static const _actionSnooze = 'action_snooze';
  static const _actionSkip = 'action_skip';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    // Use the monochrome notification icon (white drop silhouette)
    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    await _createChannel();
    _initialized = true;
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isEnabled) return;
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(_buildNotificationBody()),
      actions: const [
        AndroidNotificationAction(
          _actionDrank,
          '💧 I Drank!',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _actionSnooze,
          '⏰ Snooze 15m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _actionSkip,
          'Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.zonedSchedule(
      reminder.notificationId,
      '💧 Time to hydrate!',
      _buildNotificationBody(),
      scheduledTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAllReminders(List<Reminder> reminders) async {
    await cancelAllReminders();
    for (final r in reminders.where((r) => r.isEnabled)) {
      await scheduleReminder(r);
    }
  }

  Future<void> cancelReminder(int notificationId) async =>
      _plugin.cancel(notificationId);

  Future<void> cancelAllReminders() async => _plugin.cancelAll();

  Future<void> showGoalAchievedNotification() async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      9999,
      '🎉 Daily goal achieved!',
      'Amazing! You\'ve reached your hydration goal for today. Keep it up!',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showSnoozeNotification(int notificationId) async {
    await initialize();
    final snoozeTime =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 15));

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          _actionDrank,
          '💧 I Drank!',
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.zonedSchedule(
      notificationId + 10000,
      '💧 Reminder: Time to hydrate!',
      'You snoozed your reminder. Time to drink some water!',
      snoozeTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  String _buildNotificationBody() {
    final messages = [
      'Stay hydrated, stay healthy! 🌊',
      'Your body needs water. Take a sip now! 💧',
      'Hydration time! A small sip goes a long way. 🫗',
      'Don\'t forget your water. Your body will thank you! 💪',
      'Time for a water break! Keep up the great work! ⭐',
    ];
    final idx = DateTime.now().minute % messages.length;
    return messages[idx];
  }
}

void _onNotificationResponse(NotificationResponse response) {
  // Handled by the app when open
}

@pragma('vm:entry-point')
void _onBackgroundResponse(NotificationResponse response) {
  // Background handler — minimal work only
}
