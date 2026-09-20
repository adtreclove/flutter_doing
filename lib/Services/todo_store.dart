import 'dart:io';

import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Helpers/parse_helper.dart';
import 'package:flutter_doing/Models/todo_data_model.dart';
import 'package:flutter_doing/Models/todo_list_model.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:path_provider/path_provider.dart';

// Same pattern as SettingsFileStore: plain JSON file under the app's
// support directory, written atomically (temp file + rename) so a reader
// from another window/isolate never sees a half-written file.

class TodoStore {
  static File? _cachedFile;

  static Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true); // no-op if it already exists
    _cachedFile = File('${dir.path}/todos.json');

    coloredLog("[TODO STORE] File: $_cachedFile");
    return _cachedFile!;
  }

  static Future<void> save(TodoData data) async {
    final file = await _getFile();
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(data.toJsonString(), flush: true);
    await tempFile.rename(file.path);
  }

  /// Returns null on genuine absence OR on a read/parse failure — callers
  /// must NOT treat null as "start fresh," since a transient read failure
  /// isn't the same as a real first-run state.
  static Future<TodoData?> tryLoad() async {
    final file = await _getFile();
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      if (content.isEmpty) return null;
      return TodoData.fromJsonString(content);
    } catch (e) {
      coloredLog(
        "[TODO STORE] Failed reading/parsing todos file: $e",
        color: 'red',
      );
      return null;
    }
  }

  /// Loads the persisted to-do data, seeding a single default list the very
  /// first time the app runs (or if the file was genuinely empty).
  static Future<TodoData> load() async {
    final loaded = await tryLoad();
    if (loaded != null && loaded.lists.isNotEmpty) return loaded;

    final defaultList = TodoList(
      id: generateId(),
      name: getIt<LocalizationService>().localizations.default_list_name,
    );
    final seeded = TodoData(lists: [defaultList], activeListId: defaultList.id);
    await save(seeded);
    return seeded;
  }
}
