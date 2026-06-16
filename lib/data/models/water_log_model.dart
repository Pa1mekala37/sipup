import 'package:hive/hive.dart';
import '../../core/constants/hive_keys.dart';

part 'water_log_model.g.dart';

@HiveType(typeId: HiveKeys.waterLogTypeId)
class WaterLogModel extends HiveObject {
  @HiveField(HiveKeys.wlId)
  String id;

  @HiveField(HiveKeys.wlAmountMl)
  int amountMl;

  @HiveField(HiveKeys.wlTimestamp)
  DateTime timestamp;

  @HiveField(HiveKeys.wlContainerName)
  String containerName;

  @HiveField(HiveKeys.wlContainerEmoji)
  String containerEmoji;

  WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.containerName,
    required this.containerEmoji,
  });
}
