import '../entities/reminder.dart';
import '../entities/user_profile.dart';

abstract interface class ReminderRepository {
  List<Reminder> getAllReminders();

  Future<List<Reminder>> generateAndSaveReminders(UserProfile profile);

  Future<void> updateReminder(Reminder reminder);

  Future<void> clearAllReminders();

  Future<void> saveReminders(List<Reminder> reminders);
}
