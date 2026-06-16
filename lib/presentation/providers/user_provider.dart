import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/hive_keys.dart';
import '../../core/di/providers.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>(
  (ref) => UserProfileNotifier(ref),
);

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(null) {
    _load();
  }

  void _load() {
    final ds = _ref.read(localDataSourceProvider);
    final model = ds.getUserProfile();
    if (model != null) {
      state = _fromModel(model);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final ds = _ref.read(localDataSourceProvider);
    final model = UserProfileModel(
      wakeHour: profile.wakeHour,
      wakeMinute: profile.wakeMinute,
      sleepHour: profile.sleepHour,
      sleepMinute: profile.sleepMinute,
      dailyGoalMl: profile.dailyGoalMl,
      createdAt: profile.createdAt,
      name: profile.name,
    );
    await ds.saveUserProfile(model);
    state = profile;
  }

  Future<void> updateGoal(int goalMl) async {
    if (state == null) return;
    await saveProfile(state!.copyWith(dailyGoalMl: goalMl));
  }

  Future<void> updateWakeTime(int hour, int minute) async {
    if (state == null) return;
    await saveProfile(
        state!.copyWith(wakeHour: hour, wakeMinute: minute));
  }

  Future<void> updateSleepTime(int hour, int minute) async {
    if (state == null) return;
    await saveProfile(
        state!.copyWith(sleepHour: hour, sleepMinute: minute));
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
  }

  UserProfile _fromModel(UserProfileModel m) => UserProfile(
        wakeHour: m.wakeHour,
        wakeMinute: m.wakeMinute,
        sleepHour: m.sleepHour,
        sleepMinute: m.sleepMinute,
        dailyGoalMl: m.dailyGoalMl,
        createdAt: m.createdAt,
        name: m.name,
      );
}
