class HiveKeys {
  HiveKeys._();

  // Box names
  static const String userProfileBox = 'user_profile';
  static const String waterLogsBox = 'water_logs';
  static const String remindersBox = 'reminders';
  static const String customContainersBox = 'custom_containers';

  // Type IDs for Hive adapters
  static const int userProfileTypeId = 0;
  static const int waterLogTypeId = 1;
  static const int reminderTypeId = 2;
  static const int customContainerTypeId = 3;

  // UserProfile field indices
  static const int upWakeTime = 0;
  static const int upSleepTime = 1;
  static const int upDailyGoalMl = 2;
  static const int upCreatedAt = 3;
  static const int upName = 4;

  // WaterLog field indices
  static const int wlId = 0;
  static const int wlAmountMl = 1;
  static const int wlTimestamp = 2;
  static const int wlContainerName = 3;
  static const int wlContainerEmoji = 4;

  // Reminder field indices
  static const int remId = 0;
  static const int remHour = 1;
  static const int remMinute = 2;
  static const int remIsEnabled = 3;
  static const int remDays = 4;
  static const int remNotificationId = 5;

  // CustomContainer field indices
  static const int ccId = 0;
  static const int ccName = 1;
  static const int ccVolumeMl = 2;
  static const int ccEmoji = 3;
  static const int ccSortOrder = 4;
}
