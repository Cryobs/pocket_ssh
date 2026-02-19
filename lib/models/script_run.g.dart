// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_run.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScriptRunAdapter extends TypeAdapter<ScriptRun> {
  @override
  final int typeId = 3;

  @override
  ScriptRun read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScriptRun(
      id: fields[1] as String,
      shortcutId: fields[0] as String,
      startTime: fields[2] as DateTime,
      output: fields[3] as String,
      finished: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScriptRun obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.shortcutId)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.output)
      ..writeByte(4)
      ..write(obj.finished);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScriptRunAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
