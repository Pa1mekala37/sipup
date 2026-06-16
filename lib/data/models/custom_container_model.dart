import 'package:hive/hive.dart';
import '../../core/constants/hive_keys.dart';

part 'custom_container_model.g.dart';

@HiveType(typeId: HiveKeys.customContainerTypeId)
class CustomContainerModel extends HiveObject {
  @HiveField(HiveKeys.ccId)
  String id;

  @HiveField(HiveKeys.ccName)
  String name;

  @HiveField(HiveKeys.ccVolumeMl)
  int volumeMl;

  @HiveField(HiveKeys.ccEmoji)
  String emoji;

  @HiveField(HiveKeys.ccSortOrder)
  int sortOrder;

  CustomContainerModel({
    required this.id,
    required this.name,
    required this.volumeMl,
    required this.emoji,
    required this.sortOrder,
  });

  CustomContainerModel copyWith({
    String? name,
    int? volumeMl,
    String? emoji,
    int? sortOrder,
  }) {
    return CustomContainerModel(
      id: id,
      name: name ?? this.name,
      volumeMl: volumeMl ?? this.volumeMl,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
