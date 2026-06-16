import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/custom_container.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/water_log.dart';
import 'user_provider.dart';

// ── Daily Summary ─────────────────────────────────────────────────────────────

final dailySummaryProvider =
    StateNotifierProvider<DailySummaryNotifier, DailySummary>(
  (ref) => DailySummaryNotifier(ref),
);

class DailySummaryNotifier extends StateNotifier<DailySummary> {
  final Ref _ref;

  DailySummaryNotifier(this._ref)
      : super(DailySummary(
          date: DateTime.now(),
          consumedMl: 0,
          goalMl: 2000,
          logs: [],
        )) {
    _refresh();
  }

  int get _goalMl =>
      _ref.read(userProfileProvider)?.dailyGoalMl ?? 2000;

  void _refresh() {
    final repo = _ref.read(waterRepositoryProvider);
    state = repo.getTodaySummary(_goalMl);
  }

  Future<void> addWater({
    required int amountMl,
    required String containerName,
    required String containerEmoji,
  }) async {
    final repo = _ref.read(waterRepositoryProvider);
    await repo.addWaterLog(
      amountMl: amountMl,
      containerName: containerName,
      containerEmoji: containerEmoji,
    );
    _refresh();

    // Notify if goal just reached
    if (state.goalReached) {
      await NotificationService.instance.showGoalAchievedNotification();
      await NotificationService.instance.cancelAllReminders();
    }
  }

  Future<void> deleteLog(String id) async {
    final repo = _ref.read(waterRepositoryProvider);
    await repo.deleteWaterLog(id);
    _refresh();
  }

  void refreshForNewDay() => _refresh();
}

// ── Weekly / Monthly Summaries ────────────────────────────────────────────────

final weeklySummaryProvider = Provider<List<DailySummary>>((ref) {
  final repo = ref.read(waterRepositoryProvider);
  final goal = ref.watch(userProfileProvider)?.dailyGoalMl ?? 2000;
  return repo.getWeeklySummary(goal);
});

final monthlySummaryProvider = Provider<List<DailySummary>>((ref) {
  final repo = ref.read(waterRepositoryProvider);
  final goal = ref.watch(userProfileProvider)?.dailyGoalMl ?? 2000;
  return repo.getMonthlySummary(goal);
});

// ── Streaks ───────────────────────────────────────────────────────────────────

final streakProvider = Provider<int>((ref) {
  final repo = ref.read(waterRepositoryProvider);
  final goal = ref.watch(userProfileProvider)?.dailyGoalMl ?? 2000;
  return repo.calculateStreak(goal);
});

final longestStreakProvider = Provider<int>((ref) {
  final repo = ref.read(waterRepositoryProvider);
  final goal = ref.watch(userProfileProvider)?.dailyGoalMl ?? 2000;
  return repo.calculateLongestStreak(goal);
});

// ── Custom Containers ─────────────────────────────────────────────────────────

final customContainersProvider =
    StateNotifierProvider<CustomContainersNotifier, List<CustomContainer>>(
  (ref) => CustomContainersNotifier(ref),
);

class CustomContainersNotifier extends StateNotifier<List<CustomContainer>> {
  final Ref _ref;

  CustomContainersNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _ref.read(waterRepositoryProvider).getCustomContainers();
  }

  Future<void> add({
    required String name,
    required int volumeMl,
    required String emoji,
  }) async {
    final container = await _ref.read(waterRepositoryProvider).addCustomContainer(
          name: name,
          volumeMl: volumeMl,
          emoji: emoji,
        );
    state = [...state, container];
  }

  Future<void> update(CustomContainer container) async {
    await _ref.read(waterRepositoryProvider).updateCustomContainer(container);
    _load();
  }

  Future<void> delete(String id) async {
    await _ref.read(waterRepositoryProvider).deleteCustomContainer(id);
    state = state.where((c) => c.id != id).toList();
  }
}
