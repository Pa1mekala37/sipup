import 'package:hive/hive.dart';
import '../../core/constants/hive_keys.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: HiveKeys.userProfileTypeId)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  int wakeHour;

  @HiveField(1)
  int wakeMinute;

  @HiveField(2)
  int sleepHour;

  @HiveField(3)
  int sleepMinute;

  @HiveField(4)
  int dailyGoalMl;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String name;

  UserProfileModel({
    required this.wakeHour,
    required this.wakeMinute,
    required this.sleepHour,
    required this.sleepMinute,
    required this.dailyGoalMl,
    required this.createdAt,
    this.name = '',
  });

  UserProfileModel copyWith({
    int? wakeHour,
    int? wakeMinute,
    int? sleepHour,
    int? sleepMinute,
    int? dailyGoalMl,
    String? name,
  }) {
    return UserProfileModel(
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      createdAt: createdAt,
      name: name ?? this.name,
    );
  }
}
