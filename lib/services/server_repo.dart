import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:pocket_ssh/models/server.dart';

class ServerRepo {
  static const String _boxName = 'servers_encrypted';
  static const String _encryptionKeyName = 'servers_hive_encryption_key';
  static const _secureStorage = FlutterSecureStorage();

  late Box<ServerModel> _box;

  Future<List<int>> _getEncryptionKey() async {
    String? encodedKey = await _secureStorage.read(key: _encryptionKeyName);

    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64UrlEncode(key),
      );
      return key;
    }

    return base64Url.decode(encodedKey);
  }

  Future<void> init() async {
    final encryptionKey = await _getEncryptionKey();
    _box = await Hive.openBox<ServerModel>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  List<ServerModel> getAll() => _box.values.toList();

  ServerModel? getById(String id) {
    try {
      return _box.values.firstWhere((server) => server.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> save(ServerModel server) async {
    await _box.put(server.id, server);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}