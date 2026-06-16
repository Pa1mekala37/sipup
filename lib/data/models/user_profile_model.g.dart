// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      wakeHour: fields[0] as int,
      wakeMinute: fields[1] as int,
      sleepHour: fields[2] as int,
      sleepMinute: fields[3] as int,
      dailyGoalMl: fields[4] as int,
      createdAt: fields[5] as DateTime,
      name: fields[6] == null ? '' : fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.wakeHour)
      ..writeByte(1)
      ..write(obj.wakeMinute)
      ..writeByte(2)
      ..write(obj.sleepHour)
      ..writeByte(3)
      ..write(obj.sleepMinute)
      ..writeByte(4)
      ..write(obj.dailyGoalMl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
