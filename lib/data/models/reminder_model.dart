import 'package:hive/hive.dart';
import '../../core/constants/hive_keys.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: HiveKeys.reminderTypeId)
class ReminderModel extends HiveObject {
  @HiveField(HiveKeys.remId)
  String id;

  @HiveField(HiveKeys.remHour)
  int hour;

  @HiveField(HiveKeys.remMinute)
  int minute;

  @HiveField(HiveKeys.remIsEnabled)
  bool isEnabled;

  @HiveField(HiveKeys.remNotificationId)
  int notificationId;

  ReminderModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    required this.notificationId,
  });

  ReminderModel copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
  }) {
    return ReminderModel(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationId: notificationId,
    );
  }

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
