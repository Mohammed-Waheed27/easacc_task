import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling local storage operations
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Set string value
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// Get boolean value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Set boolean value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// Get int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Set int value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// Remove value
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Clear all data
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
