import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/user_profile.dart';

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>(
  (ref) => RemindersNotifier(ref),
);

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final Ref _ref;

  RemindersNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _ref.read(reminderRepositoryProvider).getAllReminders();
  }

  Future<void> generateForProfile(UserProfile profile) async {
    final reminders = await _ref
        .read(reminderRepositoryProvider)
        .generateAndSaveReminders(profile);
    state = reminders;
    await NotificationService.instance.scheduleAllReminders(reminders);
  }

  Future<void> toggleReminder(String id) async {
    final repo = _ref.read(reminderRepositoryProvider);
    final reminder = state.firstWhere((r) => r.id == id);
    final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
    await repo.updateReminder(updated);
    state = state.map((r) => r.id == id ? updated : r).toList();

    if (updated.isEnabled) {
      await NotificationService.instance.scheduleReminder(updated);
    } else {
      await NotificationService.instance.cancelReminder(updated.notificationId);
    }
  }

  Future<void> rescheduleAll() async {
    final reminders = _ref.read(reminderRepositoryProvider).getAllReminders();
    state = reminders;
    await NotificationService.instance.scheduleAllReminders(reminders);
  }

  Future<void> clearAll() async {
    await _ref.read(reminderRepositoryProvider).clearAllReminders();
    await NotificationService.instance.cancelAllReminders();
    state = [];
  }
}
