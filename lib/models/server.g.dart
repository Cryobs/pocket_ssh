// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerModelAdapter extends TypeAdapter<ServerModel> {
  @override
  final int typeId = 1;

  @override
  ServerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      host: fields[2] as String,
      port: fields[3] as int,
      username: fields[4] as String,
      authType: fields[5] as int,
      passwordKey: fields[6] as String?,
      sshKeyId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ServerModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.authType)
      ..writeByte(6)
      ..write(obj.passwordKey)
      ..writeByte(7)
      ..write(obj.sshKeyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
