import 'water_log.dart';

class DailySummary {
  final DateTime date;
  final int consumedMl;
  final int goalMl;
  final List<WaterLog> logs;

  const DailySummary({
    required this.date,
    required this.consumedMl,
    required this.goalMl,
    required this.logs,
  });

  double get progressPercent =>
      goalMl > 0 ? (consumedMl / goalMl).clamp(0.0, 1.0) : 0.0;

  int get remainingMl => (goalMl - consumedMl).clamp(0, goalMl);

  bool get goalReached => consumedMl >= goalMl;
}
