import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class StorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String> read(String key) {
    return _storage.read(key: key);
  }

  static Future<Map<String, String>> readAll() {
    return _storage.readAll();
  }

  static Future<void> write(String key, String value) {
    _storage.write(key: key, value: value);
  }

  static Future<void> delete(String key) {
    _storage.delete(key: key);
  }

  static Future<void> deleteAll() {
    _storage.deleteAll();
  }
}
