class AppConstants {
  AppConstants._();

  static const String appName = 'SipUp';

  // Goal limits (ml)
  static const int minGoal = 500;
  static const int maxGoal = 6000;
  static const int defaultGoal = 2000;

  // Reminder
  static const int snoozeDurationMinutes = 15;
  static const int minReminderIntervalMinutes = 30;

  // Streak thresholds for badges
  static const List<int> streakMilestones = [1, 7, 14, 30, 60, 100, 365];

  // Predefined containers
  static const List<Map<String, dynamic>> predefinedContainers = [
    {'name': 'Small Sip', 'volumeMl': 150, 'emoji': '🥤'},
    {'name': 'Water Glass', 'volumeMl': 250, 'emoji': '🥛'},
    {'name': 'Coffee Cup', 'volumeMl': 200, 'emoji': '☕'},
    {'name': 'Small Bottle', 'volumeMl': 500, 'emoji': '🍶'},
    {'name': 'Sports Bottle', 'volumeMl': 750, 'emoji': '🏃'},
    {'name': 'Large Bottle', 'volumeMl': 1000, 'emoji': '🫗'},
    {'name': 'Steel Bottle', 'volumeMl': 1500, 'emoji': '⚗️'},
  ];

  // Notification IDs
  static const int baseNotificationId = 1000;
  static const int goalAchievedNotificationId = 9999;

  // WorkManager task names
  static const String rescheduleTaskName = 'reschedule_reminders';
  static const String dailyResetTaskName = 'daily_reset';

  // Shared Preferences keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  static const String wakeTimeKey = 'wake_time';
  static const String sleepTimeKey = 'sleep_time';
  static const String dailyGoalKey = 'daily_goal_ml';
  static const String reminderIntervalKey = 'reminder_interval_minutes';
  static const String notificationSoundKey = 'notification_sound';
  static const String vibrationKey = 'vibration_enabled';

  // Animation durations
  static const int progressAnimationMs = 800;
  static const int cardAnimationMs = 300;
  static const int pageTransitionMs = 250;
}
