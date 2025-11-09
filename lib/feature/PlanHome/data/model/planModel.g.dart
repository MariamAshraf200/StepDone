// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanModelAdapter extends TypeAdapter<PlanModel> {
  @override
  final int typeId = 3;

  @override
  PlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      startDate: fields[3] as String,
      endDate: fields[4] as String,
      category: fields[5] as String,
      priority: fields[6] as String,
      updatedTime: fields[7] as String?,
      status: fields[8] as String,
      images: (fields[9] as List?)?.cast<String>(),
      completed: fields[10] as bool,
      tasks: (fields[11] as List).cast<TaskPlan>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlanModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.updatedTime)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.images)
      ..writeByte(10)
      ..write(obj.completed)
      ..writeByte(11)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
