import 'dart:convert';

import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/storage_keys.dart';
import 'package:flutter_doing/Models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// The secure storage is used for auth token and sensitive data (like user information)
// is is backed by keychain/keystore for encryption

//  macOS:  must enable the "Keychain Sharing" capability, otherwise
//   writes silently appear to succeed but nothing is actually persisted.
//   Add the following to BOTH macos/Runner/DebugProfile.entitlements and
//   macos/Runner/Release.entitlements:
//
//   <key>keychain-access-groups</key>
//   <array>
//     <string>$(AppIdentifierPrefix)your.bundle.id</string>
//   </array>
//
//   (If your app uses App Groups, use the App Group name instead of the
//   bundle id.)

class SecureStorageService {
  SecureStorageService._internal();

  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> readKey(
    String key, {
    int maxAttempts = 10,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    String? storageContent;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (storageContent != null && storageContent.isNotEmpty) {
        break;
      }
      try {
        storageContent = await _secureStorage.read(key: key);
      } catch (e) {
        coloredLog(
          '[SECURE STORAGE] Failed reading key "$key" (attempt ${attempt + 1}/$maxAttempts): $e',
          color: 'red',
        );
      }

      if (storageContent == null || storageContent.isEmpty) {
        await Future.delayed(retryDelay);
      }
    }

    return storageContent;
  }

  /// Writes [value] under [key]. Passing `null` deletes the key.
  Future<bool> writeKey(String key, String? value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      coloredLog(
        '[SECURE STORAGE] Failed writing key "$key": $e',
        color: 'red',
      );
      return false;
    }
  }

  /// Deletes [key] from secure storage.
  Future<bool> deleteKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      coloredLog(
        '[SECURE STORAGE] Failed deleting key "$key": $e',
        color: 'red',
      );
      return false;
    }
  }

  /// Deletes all keys from secure storage.
  Future<bool> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      coloredLog('[SECURE STORAGE] Failed clearing storage: $e', color: 'red');
      return false;
    }
  }

  /// Returns true if [key] exists in storage.
  Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      coloredLog(
        '[SECURE STORAGE] Failed checking key "$key": $e',
        color: 'red',
      );
      return false;
    }
  }

  /// Stores any JSON-encodable object under [key].
  Future<bool> writeJson(String key, Object? value) {
    return writeKey(key, jsonEncode(value));
  }

  /// Retrieves and decodes a JSON object previously stored with [writeJson].
  /// Returns null if the key doesn't exist or decoding fails.
  Future<T?> readJson<T>(String key) async {
    final raw = await readKey(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (e) {
      coloredLog(
        '[SECURE STORAGE] Failed decoding JSON for key "$key": $e',
        color: 'red',
      );
      return null;
    }
  }

  // ---- APP SPECIFIC FUNCTIONS
  Future<User> getUser() async {
    final jsonString = await readKey(userKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return User.fromJson(jsonMap);
      } catch (e) {
        coloredLog(
          '[SECURE STORAGE] Failed parsing stored user: $e',
          color: 'red',
        );
      }
    }
    return User();
  }

  Future<void> saveUser(User user) async {
    try {
      await writeKey(userKey, jsonEncode(user.toJson()));
    } catch (e) {
      coloredLog('[SECURE STORAGE] Failed saving user: $e', color: 'red');
    }
  }
}
