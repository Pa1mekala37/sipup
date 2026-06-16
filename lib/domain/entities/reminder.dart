class Reminder {
  final String id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final int notificationId;

  const Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    required this.notificationId,
  });

  Reminder copyWith({bool? isEnabled, int? hour, int? minute}) => Reminder(
        id: id,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        isEnabled: isEnabled ?? this.isEnabled,
        notificationId: notificationId,
      );

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  int get totalMinutes => hour * 60 + minute;
}
