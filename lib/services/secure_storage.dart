import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveValue(String key, String value) async {
    await _storage.write(
        key: key,
        value: value
    );
  }


  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
}


Future<String> getValueFromStorage(String key) async {
  final value = await SecureStorageService.getValue(key);

  if (value == null) {
    throw Exception("Value not found in secure storage");
  }

  return value;
}