import 'dart:io';

import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:path_provider/path_provider.dart';

// desktop_multi_window gives each window its own Flutter engine,
// and shared_preferences's native implementations cache the underlying storage
// in memory per-engine with no public way to force a re-read from Dart.
// Anything we need synced live across windows (settings and main window currently)
// should go through our own file I/O (or another IPC mechanism) rather than shared_preferences,
// which is fine for per-window local state but not built for cross-engine visibility.

class SettingsFileStore {
  static File? _cachedFile;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true); // no-op if it already exists
    _cachedFile = File('${dir.path}/desktop_settings.json');

    coloredLog("[FILE STORE] File: $_cachedFile");
    return _cachedFile!;
  }

  static Future<void> save(Settings settings) async {
    final file = await _getFile();
    // Write to a temp file, then rename. rename is atomic, so a
    // concurrent reader from another window/isolate can never observe a
    // partially-written file. This is what was causing corrupted reads
    // during cross-window polling, which silently reset openedBefore
    // (and every other field) to defaults on a torn read.
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(settings.toJsonString(), flush: true);
    await tempFile.rename(file.path);
  }

  /// Returns null on genuine absence OR on a read/parse failure — callers
  /// must NOT treat null as "apply defaults," since a transient read
  /// failure isn't the same as a real first-run state.
  static Future<Settings?> tryLoad() async {
    final file = await _getFile();
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      if (content.isEmpty) return null;
      return Settings.fromJsonString(content);
    } catch (e) {
      coloredLog(
        "[PREFS] Failed reading/parsing settings file: $e",
        color: 'red',
      );
      return null;
    }
  }

  static Future<Settings> load() async {
    return await tryLoad() ?? Settings();
  }
}
