import '../entities/custom_container.dart';
import '../entities/daily_summary.dart';
import '../entities/water_log.dart';

abstract interface class WaterRepository {
  Future<WaterLog> addWaterLog({
    required int amountMl,
    required String containerName,
    required String containerEmoji,
  });

  Future<void> deleteWaterLog(String id);

  List<WaterLog> getTodayLogs();

  List<WaterLog> getLogsForDay(DateTime date);

  List<WaterLog> getLogsForRange(DateTime from, DateTime to);

  DailySummary getTodaySummary(int goalMl);

  List<DailySummary> getWeeklySummary(int goalMl);

  List<DailySummary> getMonthlySummary(int goalMl);

  int calculateStreak(int goalMl);

  int calculateLongestStreak(int goalMl);

  List<CustomContainer> getCustomContainers();

  Future<CustomContainer> addCustomContainer({
    required String name,
    required int volumeMl,
    required String emoji,
  });

  Future<void> updateCustomContainer(CustomContainer container);

  Future<void> deleteCustomContainer(String id);
}
