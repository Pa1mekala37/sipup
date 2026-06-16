// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_container_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomContainerModelAdapter extends TypeAdapter<CustomContainerModel> {
  @override
  final int typeId = 3;

  @override
  CustomContainerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomContainerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      volumeMl: fields[2] as int,
      emoji: fields[3] as String,
      sortOrder: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomContainerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.volumeMl)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomContainerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
