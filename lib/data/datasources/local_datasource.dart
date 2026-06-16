import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_keys.dart';
import '../models/custom_container_model.dart';
import '../models/reminder_model.dart';
import '../models/user_profile_model.dart';
import '../models/water_log_model.dart';

class LocalDataSource {
  Box<UserProfileModel> get _profileBox =>
      Hive.box<UserProfileModel>(HiveKeys.userProfileBox);

  Box<WaterLogModel> get _logsBox =>
      Hive.box<WaterLogModel>(HiveKeys.waterLogsBox);

  Box<ReminderModel> get _remindersBox =>
      Hive.box<ReminderModel>(HiveKeys.remindersBox);

  Box<CustomContainerModel> get _containersBox =>
      Hive.box<CustomContainerModel>(HiveKeys.customContainersBox);

  // ── User Profile ──────────────────────────────────────────────────────────

  UserProfileModel? getUserProfile() =>
      _profileBox.isEmpty ? null : _profileBox.getAt(0);

  Future<void> saveUserProfile(UserProfileModel profile) async {
    if (_profileBox.isEmpty) {
      await _profileBox.add(profile);
    } else {
      await _profileBox.putAt(0, profile);
    }
  }

  // ── Water Logs ────────────────────────────────────────────────────────────

  List<WaterLogModel> getAllLogs() => _logsBox.values.toList();

  List<WaterLogModel> getLogsForDay(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _logsBox.values
        .where((l) =>
            l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<WaterLogModel> getLogsForRange(DateTime from, DateTime to) {
    return _logsBox.values
        .where((l) =>
            l.timestamp.isAfter(from) && l.timestamp.isBefore(to))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> addLog(WaterLogModel log) async =>
      _logsBox.put(log.id, log);

  Future<void> deleteLog(String id) async => _logsBox.delete(id);

  Future<void> deleteLogsForDay(DateTime date) async {
    final logs = getLogsForDay(date);
    for (final log in logs) {
      await _logsBox.delete(log.id);
    }
  }

  // ── Reminders ─────────────────────────────────────────────────────────────

  List<ReminderModel> getAllReminders() {
    return _remindersBox.values.toList()
      ..sort((a, b) {
        final aMinutes = a.hour * 60 + a.minute;
        final bMinutes = b.hour * 60 + b.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    await _remindersBox.clear();
    for (final r in reminders) {
      await _remindersBox.put(r.id, r);
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async =>
      _remindersBox.put(reminder.id, reminder);

  Future<void> clearReminders() async => _remindersBox.clear();

  // ── Custom Containers ─────────────────────────────────────────────────────

  List<CustomContainerModel> getCustomContainers() {
    return _containersBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> saveContainer(CustomContainerModel container) async =>
      _containersBox.put(container.id, container);

  Future<void> updateContainer(CustomContainerModel container) async =>
      _containersBox.put(container.id, container);

  Future<void> deleteContainer(String id) async =>
      _containersBox.delete(id);

  // ── Maintenance ───────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _logsBox.clear();
    await _remindersBox.clear();
    await _containersBox.clear();
    await _profileBox.clear();
  }

  Future<void> deleteOldLogs(int keepDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    final old = _logsBox.values
        .where((l) => l.timestamp.isBefore(cutoff))
        .map((l) => l.id)
        .toList();
    await _logsBox.deleteAll(old);
  }
}
