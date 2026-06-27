import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    return StorageService._(prefs, secure);
  }

  // SharedPreferences — non-sensitive
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);

  // FlutterSecureStorage — sensitive data
  Future<String?> getSecure(String key) => _secure.read(key: key);
  Future<void> setSecure(String key, String value) => _secure.write(key: key, value: value);
  Future<void> removeSecure(String key) => _secure.delete(key: key);
  Future<void> clearSecure() => _secure.deleteAll();

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secure.deleteAll();
  }
}
