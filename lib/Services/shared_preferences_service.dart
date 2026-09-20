import 'dart:convert';

import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_doing/Services/settings_file_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The shared Preferences is used for app settings and non-sensitive data

/// Usage:
/// ```dart
/// await SharedPreferencesService.instance.init();
/// await SharedPreferencesService.instance.setString('username', 'alice');
/// final username = SharedPreferencesService.instance.getString('username');
/// ```
class SharedPreferencesService {
  SharedPreferencesService._internal();

  static final SharedPreferencesService instance =
      SharedPreferencesService._internal();

  SharedPreferences? _prefs;

  /// Must be called once (e.g. in main() before runApp) before using
  /// any other method.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _instanceOrThrow {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferencesService.init() must be called before use. '
        'Call `await SharedPreferencesService.instance.init();` in main().',
      );
    }
    return prefs;
  }

  Future<void> saveSettings(Settings settings) async {
    await SettingsFileStore.save(settings);
  }

  Future<Settings?> tryLoadSettings() => SettingsFileStore.tryLoad();

  Future<Settings> loadSettings() async {
    return SettingsFileStore.load();
  }

  Future<ScreenState> loadAppScreenState() async {
    final settings = await loadSettings();
    final layout = settings.layoutStyle;

    return ScreenState.values.firstWhere(
      (appState) => appState.label == layout,
      orElse: () => ScreenState.classic,
    );
  }

  String? getString(String key, {String? defaultValue}) {
    return _instanceOrThrow.getString(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) {
    return _instanceOrThrow.setString(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return _instanceOrThrow.getInt(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) {
    return _instanceOrThrow.setInt(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return _instanceOrThrow.getDouble(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) {
    return _instanceOrThrow.setDouble(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return _instanceOrThrow.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) {
    return _instanceOrThrow.setBool(key, value);
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _instanceOrThrow.getStringList(key) ?? defaultValue;
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _instanceOrThrow.setStringList(key, value);
  }

  /// Stores any JSON-encodable object (Map, List, etc.) under [key].
  Future<bool> setJson(String key, Object? value) {
    return _instanceOrThrow.setString(key, jsonEncode(value));
  }

  /// Retrieves and decodes a JSON object previously stored with [setJson].
  /// Returns null if the key doesn't exist or decoding fails.
  T? getJson<T>(String key) {
    final raw = _instanceOrThrow.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  /// Returns true if [key] exists in storage.
  bool containsKey(String key) => _instanceOrThrow.containsKey(key);

  /// Removes a single value.
  Future<bool> remove(String key) => _instanceOrThrow.remove(key);

  /// Clears all values in shared preferences.
  Future<bool> clear() => _instanceOrThrow.clear();

  /// Returns all keys currently stored.
  Set<String> getKeys() => _instanceOrThrow.getKeys();
}
