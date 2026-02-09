import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> savePassword(String key, String password) async {
    await _storage.write(
        key: key,
        value: password
    );
  }


  static Future<String?> getPassword(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deletePassword(String key) async {
    await _storage.delete(key: key);
  }
}


Future<String> getPasswordFromStorage(String key) async {
  final password = await SecureStorageService.getPassword(key);

  if (password == null) {
    throw Exception("Password not found in secure storage");
  }

  return password;
}