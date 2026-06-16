import 'package:uuid/uuid.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/custom_container.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/water_log.dart';
import '../../domain/repositories/water_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/custom_container_model.dart';
import '../models/water_log_model.dart';

class WaterRepositoryImpl implements WaterRepository {
  final LocalDataSource _dataSource;
  final _uuid = const Uuid();

  WaterRepositoryImpl(this._dataSource);

  @override
  Future<WaterLog> addWaterLog({
    required int amountMl,
    required String containerName,
    required String containerEmoji,
  }) async {
    final log = WaterLogModel(
      id: _uuid.v4(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
      containerName: containerName,
      containerEmoji: containerEmoji,
    );
    await _dataSource.addLog(log);
    return _toEntity(log);
  }

  @override
  Future<void> deleteWaterLog(String id) => _dataSource.deleteLog(id);

  @override
  List<WaterLog> getTodayLogs() {
    return _dataSource.getLogsForDay(DateTime.now()).map(_toEntity).toList();
  }

  @override
  List<WaterLog> getLogsForDay(DateTime date) {
    return _dataSource.getLogsForDay(date).map(_toEntity).toList();
  }

  @override
  List<WaterLog> getLogsForRange(DateTime from, DateTime to) {
    return _dataSource.getLogsForRange(from, to).map(_toEntity).toList();
  }

  @override
  DailySummary getTodaySummary(int goalMl) {
    final logs = getTodayLogs();
    final total = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
    return DailySummary(
      date: AppDateUtils.getDayStart(DateTime.now()),
      consumedMl: total,
      goalMl: goalMl,
      logs: logs,
    );
  }

  @override
  List<DailySummary> getWeeklySummary(int goalMl) {
    final days = AppDateUtils.getLast7Days();
    return days.map((day) {
      final logs = getLogsForDay(day);
      final total = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
      return DailySummary(
        date: day,
        consumedMl: total,
        goalMl: goalMl,
        logs: logs,
      );
    }).toList();
  }

  @override
  List<DailySummary> getMonthlySummary(int goalMl) {
    final days = AppDateUtils.getLast30Days();
    return days.map((day) {
      final logs = getLogsForDay(day);
      final total = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
      return DailySummary(
        date: day,
        consumedMl: total,
        goalMl: goalMl,
        logs: logs,
      );
    }).toList();
  }

  @override
  int calculateStreak(int goalMl) {
    int streak = 0;
    var day = AppDateUtils.getDayStart(DateTime.now());

    // Don't count today in streak — only completed past days
    day = day.subtract(const Duration(days: 1));

    while (true) {
      final logs = getLogsForDay(day);
      final total = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
      if (total >= goalMl) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  int calculateLongestStreak(int goalMl) {
    final allLogs = _dataSource.getAllLogs();
    if (allLogs.isEmpty) return 0;

    allLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final oldest = AppDateUtils.getDayStart(allLogs.first.timestamp);
    final today = AppDateUtils.getDayStart(DateTime.now());

    int longest = 0;
    int current = 0;
    var day = oldest;

    while (!day.isAfter(today)) {
      final logs = getLogsForDay(day);
      final total = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
      if (total >= goalMl) {
        current++;
        longest = current > longest ? current : longest;
      } else {
        current = 0;
      }
      day = day.add(const Duration(days: 1));
    }
    return longest;
  }

  // ── Custom Containers ─────────────────────────────────────────────────────

  @override
  List<CustomContainer> getCustomContainers() {
    return _dataSource
        .getCustomContainers()
        .map(_containerToEntity)
        .toList();
  }

  @override
  Future<CustomContainer> addCustomContainer({
    required String name,
    required int volumeMl,
    required String emoji,
  }) async {
    final existing = _dataSource.getCustomContainers();
    final order =
        existing.isEmpty ? 0 : existing.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    final model = CustomContainerModel(
      id: _uuid.v4(),
      name: name,
      volumeMl: volumeMl,
      emoji: emoji,
      sortOrder: order,
    );
    await _dataSource.saveContainer(model);
    return _containerToEntity(model);
  }

  @override
  Future<void> updateCustomContainer(CustomContainer container) async {
    final model = CustomContainerModel(
      id: container.id,
      name: container.name,
      volumeMl: container.volumeMl,
      emoji: container.emoji,
      sortOrder: container.sortOrder,
    );
    await _dataSource.updateContainer(model);
  }

  @override
  Future<void> deleteCustomContainer(String id) =>
      _dataSource.deleteContainer(id);

  // ── Helpers ───────────────────────────────────────────────────────────────

  WaterLog _toEntity(WaterLogModel m) => WaterLog(
        id: m.id,
        amountMl: m.amountMl,
        timestamp: m.timestamp,
        containerName: m.containerName,
        containerEmoji: m.containerEmoji,
      );

  CustomContainer _containerToEntity(CustomContainerModel m) =>
      CustomContainer(
        id: m.id,
        name: m.name,
        volumeMl: m.volumeMl,
        emoji: m.emoji,
        sortOrder: m.sortOrder,
      );
}
