// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShortcutModelAdapter extends TypeAdapter<ShortcutModel> {
  @override
  final int typeId = 2;

  @override
  ShortcutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShortcutModel(
      id: fields[0] as String,
      title: fields[1] as String,
      iconCodePoint: fields[2] as int,
      colorValue: fields[3] as int,
      order: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShortcutModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortcutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
