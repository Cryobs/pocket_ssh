import 'package:hive/hive.dart';

part 'server.g.dart';

@HiveType(typeId: 1)
class ServerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String host;

  @HiveField(3)
  final int port;

  @HiveField(4)
  final String username;

  @HiveField(5)
  final int authType; // 0 = password, 1 = ssh key

  @HiveField(6)
  final String? passwordKey;

  @HiveField(7)
  final String? sshKeyId;

  ServerModel({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.authType,
    this.passwordKey,
    this.sshKeyId,
  });
}