class UserProfile {
  final int wakeHour;
  final int wakeMinute;
  final int sleepHour;
  final int sleepMinute;
  final int dailyGoalMl;
  final DateTime createdAt;
  final String name;

  const UserProfile({
    required this.wakeHour,
    required this.wakeMinute,
    required this.sleepHour,
    required this.sleepMinute,
    required this.dailyGoalMl,
    required this.createdAt,
    this.name = '',
  });

  UserProfile copyWith({
    int? wakeHour,
    int? wakeMinute,
    int? sleepHour,
    int? sleepMinute,
    int? dailyGoalMl,
    String? name,
  }) {
    return UserProfile(
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      createdAt: createdAt,
      name: name ?? this.name,
    );
  }

  String get wakeTimeFormatted {
    final h = wakeHour % 12 == 0 ? 12 : wakeHour % 12;
    final m = wakeMinute.toString().padLeft(2, '0');
    final period = wakeHour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String get sleepTimeFormatted {
    final h = sleepHour % 12 == 0 ? 12 : sleepHour % 12;
    final m = sleepMinute.toString().padLeft(2, '0');
    final period = sleepHour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
