import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:workmanager/workmanager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/hive_keys.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/custom_container_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/water_log_model.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await HiveFlutter.initFlutter();
      if (!Hive.isAdapterRegistered(HiveKeys.userProfileTypeId)) {
        Hive.registerAdapter(UserProfileModelAdapter());
        Hive.registerAdapter(WaterLogModelAdapter());
        Hive.registerAdapter(ReminderModelAdapter());
        Hive.registerAdapter(CustomContainerModelAdapter());
      }

      await Hive.openBox<UserProfileModel>(HiveKeys.userProfileBox);
      await Hive.openBox<WaterLogModel>(HiveKeys.waterLogsBox);
      await Hive.openBox<ReminderModel>(HiveKeys.remindersBox);
      await Hive.openBox<CustomContainerModel>(HiveKeys.customContainersBox);

      final ds = LocalDataSource();

      switch (taskName) {
        case AppConstants.rescheduleTaskName:
          await _rescheduleReminders(ds);
          break;
        case AppConstants.dailyResetTaskName:
          // No-op — logs naturally reset by date filtering
          break;
      }
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}

Future<void> _rescheduleReminders(LocalDataSource ds) async {
  // Initialize timezone
  tz.initializeTimeZones();
  try {
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }
  final profileModel = ds.getUserProfile();
  if (profileModel == null) return;

  final profile = UserProfile(
    wakeHour: profileModel.wakeHour,
    wakeMinute: profileModel.wakeMinute,
    sleepHour: profileModel.sleepHour,
    sleepMinute: profileModel.sleepMinute,
    dailyGoalMl: profileModel.dailyGoalMl,
    createdAt: profileModel.createdAt,
  );

  final reminderRepo = ReminderRepositoryImpl(ds);
  final reminders = reminderRepo.getAllReminders();
  if (reminders.isEmpty) {
    await reminderRepo.generateAndSaveReminders(profile);
  }

  final prefs = await SharedPreferences.getInstance();
  final soundEnabled =
      prefs.getBool(AppConstants.notificationSoundKey) ?? true;
  final vibrationEnabled =
      prefs.getBool(AppConstants.vibrationKey) ?? true;

  final notifService = NotificationService.instance;
  await notifService.initialize();
  await notifService.scheduleAllReminders(
    reminderRepo.getAllReminders(),
  );
}

class WorkManagerService {
  WorkManagerService._();
  static final WorkManagerService instance = WorkManagerService._();

  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> scheduleRescheduleTask() async {
    await Workmanager().registerPeriodicTask(
      AppConstants.rescheduleTaskName,
      AppConstants.rescheduleTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  Future<void> cancelAll() async => Workmanager().cancelAll();
}
