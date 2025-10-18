import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    return prefs.setBool(key, value);
  }

  static Future<bool> getBool(String key) async {
    var prefs = await _instance;
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }

  static Future<String> getString(String key) async {
    var prefs = await _instance;
    return prefs.getString(key) ?? '';
  }

  static Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    return prefs.setInt(key, value);
  }

  static Future<int> getInt(String key) async {
    var prefs = await _instance;
    return prefs.getInt(key) ?? 0;
  }

  static Future<bool> remove(String key) async {
    var prefs = await _instance;
    return prefs.remove(key);
  }

  static Future<bool> clear() async {
    var prefs = await _instance;
    return prefs.clear();
  }
}