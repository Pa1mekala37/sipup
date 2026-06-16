import 'notification_service.dart';

class WorkManagerService {
  WorkManagerService._();
  static final WorkManagerService instance = WorkManagerService._();

  Future<void> initialize() async {
    // flutter_local_notifications.ScheduledNotificationBootReceiver handles
    // rescheduling after device reboot automatically. No separate background
    // task manager is needed.
  }

  Future<void> scheduleRescheduleTask() async {
    // No-op: zonedSchedule with DateTimeComponents.time creates self-repeating
    // daily alarms that survive without a periodic WorkManager task.
  }

  Future<void> cancelAll() async {
    await NotificationService.instance.cancelAllReminders();
  }
}
