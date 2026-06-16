import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/hive_keys.dart';
import 'core/services/notification_service.dart';
import 'core/services/workmanager_service.dart';
import 'core/theme/app_theme.dart';
import 'data/models/custom_container_model.dart';
import 'data/models/reminder_model.dart';
import 'data/models/user_profile_model.dart';
import 'data/models/water_log_model.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Hive
  await HiveFlutter.initFlutter();
  _registerHiveAdapters();
  await _openHiveBoxes();

  // Notifications
  await NotificationService.instance.initialize();

  // WorkManager
  await WorkManagerService.instance.initialize();
  await WorkManagerService.instance.scheduleRescheduleTask();

  runApp(const ProviderScope(child: SipUpApp()));
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(HiveKeys.userProfileTypeId)) {
    Hive.registerAdapter(UserProfileModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveKeys.waterLogTypeId)) {
    Hive.registerAdapter(WaterLogModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveKeys.reminderTypeId)) {
    Hive.registerAdapter(ReminderModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveKeys.customContainerTypeId)) {
    Hive.registerAdapter(CustomContainerModelAdapter());
  }
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox<UserProfileModel>(HiveKeys.userProfileBox);
  await Hive.openBox<WaterLogModel>(HiveKeys.waterLogsBox);
  await Hive.openBox<ReminderModel>(HiveKeys.remindersBox);
  await Hive.openBox<CustomContainerModel>(HiveKeys.customContainersBox);
}

class SipUpApp extends ConsumerWidget {
  const SipUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
