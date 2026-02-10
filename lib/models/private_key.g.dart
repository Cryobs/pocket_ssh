// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_key.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrivateKeyAdapter extends TypeAdapter<PrivateKey> {
  @override
  final int typeId = 0;

  @override
  PrivateKey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivateKey(
      id: fields[0] as String,
      name: fields[1] as String,
      key: fields[2] as String,
      passphrase: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrivateKey obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.key)
      ..writeByte(3)
      ..write(obj.passphrase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateKeyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
