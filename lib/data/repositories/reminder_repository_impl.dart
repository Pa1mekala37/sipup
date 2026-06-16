import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final LocalDataSource _dataSource;
  final _uuid = const Uuid();

  ReminderRepositoryImpl(this._dataSource);

  @override
  List<Reminder> getAllReminders() =>
      _dataSource.getAllReminders().map(_toEntity).toList();

  @override
  Future<List<Reminder>> generateAndSaveReminders(
      UserProfile profile) async {
    final reminders = _calculateReminderTimes(profile);
    final models = reminders
        .asMap()
        .entries
        .map((e) => ReminderModel(
              id: _uuid.v4(),
              hour: e.value[0],
              minute: e.value[1],
              isEnabled: true,
              notificationId:
                  AppConstants.baseNotificationId + e.key,
            ))
        .toList();
    await _dataSource.saveReminders(models);
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel(
      id: reminder.id,
      hour: reminder.hour,
      minute: reminder.minute,
      isEnabled: reminder.isEnabled,
      notificationId: reminder.notificationId,
    );
    await _dataSource.updateReminder(model);
  }

  @override
  Future<void> clearAllReminders() => _dataSource.clearReminders();

  @override
  Future<void> saveReminders(List<Reminder> reminders) async {
    final models = reminders
        .map((r) => ReminderModel(
              id: r.id,
              hour: r.hour,
              minute: r.minute,
              isEnabled: r.isEnabled,
              notificationId: r.notificationId,
            ))
        .toList();
    await _dataSource.saveReminders(models);
  }

  // ── Calculation ───────────────────────────────────────────────────────────

  List<List<int>> _calculateReminderTimes(UserProfile profile) {
    final wakeMinutes = profile.wakeHour * 60 + profile.wakeMinute;
    final sleepMinutes = profile.sleepHour * 60 + profile.sleepMinute;

    final awakenMinutes = sleepMinutes > wakeMinutes
        ? sleepMinutes - wakeMinutes
        : (24 * 60 - wakeMinutes) + sleepMinutes;

    final containerMl = 250; // default step size
    final count = (profile.dailyGoalMl / containerMl).ceil();
    final count_clamped = count.clamp(2, 24);

    if (count_clamped <= 1) return [[profile.wakeHour, profile.wakeMinute]];

    final intervalMinutes = awakenMinutes ~/ (count_clamped - 1);
    final clampedInterval =
        intervalMinutes.clamp(AppConstants.minReminderIntervalMinutes, 120);

    final times = <List<int>>[];
    for (int i = 0; i < count_clamped; i++) {
      int totalMin = wakeMinutes + clampedInterval * i;
      if (totalMin >= sleepMinutes) break;
      final h = (totalMin ~/ 60) % 24;
      final m = totalMin % 60;
      times.add([h, m]);
    }
    return times;
  }

  Reminder _toEntity(ReminderModel m) => Reminder(
        id: m.id,
        hour: m.hour,
        minute: m.minute,
        isEnabled: m.isEnabled,
        notificationId: m.notificationId,
      );
}
