import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:pocket_ssh/models/private_key.dart';

class PrivateKeyRepo {
  static const String _boxName = 'private_keys_encrypted';
  static const String _encryptionKeyName = 'hive_encryption_key';
  static const _secureStorage = FlutterSecureStorage();

  late Box<PrivateKey> _box;

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
    _box = await Hive.openBox<PrivateKey>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  List<PrivateKey> getAll() => _box.values.toList();

  PrivateKey? getById(String id) {
    try {
      return _box.values.firstWhere((key) => key.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> save(PrivateKey key) async {
    await _box.put(key.id, key);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}