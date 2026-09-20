import 'package:flutter_doing/Helpers/parse_helper.dart';
import 'package:flutter_doing/Models/todo_data_model.dart';
import 'package:flutter_doing/Models/todo_item_model.dart';
import 'package:flutter_doing/Models/todo_list_model.dart';
import 'package:flutter_doing/Extensions/todo_priority_extension.dart';
import 'package:flutter_doing/Extensions/todo_status_extension.dart';
import 'package:flutter_doing/Services/todo_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoProvider = AsyncNotifierProvider<TodoNotifier, TodoData>(
  TodoNotifier.new,
);

/// The item currently opened for editing: set by Compact/Classic view's
/// edit button right before navigating to EditView, so EditView knows which
/// item (and therefore which list) to preselect. May be null (no current
/// item yet, or the list is empty)
final editingItemIdProvider = StateProvider<String?>((ref) => null);

class TodoNotifier extends AsyncNotifier<TodoData> {
  @override
  Future<TodoData> build() async {
    return TodoStore.load();
  }

  Future<void> _persist(TodoData data) async {
    state = AsyncValue.data(data);
    await TodoStore.save(data);
  }

  TodoData get _current => state.value ?? TodoData();

  Future<TodoList> addList(String name) async {
    final current = _current;
    final list = TodoList(id: generateId(), name: name.trim());
    await _persist(
      TodoData(
        lists: [...current.lists, list],
        items: current.items,
        activeListId: current.activeListId ?? list.id,
      ),
    );
    return list;
  }

  Future<void> renameList(String listId, String name) async {
    final current = _current;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    for (final list in current.lists) {
      if (list.id == listId) list.name = trimmed;
    }
    await _persist(current);
  }

  Future<void> deleteList(String listId) async {
    final current = _current;
    final remainingLists = current.lists.where((l) => l.id != listId).toList();
    final remainingItems = current.items
        .where((i) => i.listId != listId)
        .toList();

    String? newActive = current.activeListId;
    if (newActive == listId) {
      newActive = remainingLists.isNotEmpty ? remainingLists.first.id : null;
    }

    await _persist(
      TodoData(
        lists: remainingLists,
        items: remainingItems,
        activeListId: newActive,
      ),
    );
  }

  Future<void> setActiveList(String listId) async {
    final current = _current;
    await _persist(
      TodoData(
        lists: current.lists,
        items: current.items,
        activeListId: listId,
      ),
    );
  }

  Future<TodoItem> addItem({
    required String listId,
    required String title,
    TodoPriority priority = TodoPriority.medium,
  }) async {
    final current = _current;
    final item = TodoItem(
      id: generateId(),
      listId: listId,
      title: title.trim(),
      priority: priority,
    );
    await _persist(
      TodoData(
        lists: current.lists,
        items: [...current.items, item],
        activeListId: current.activeListId,
      ),
    );
    return item;
  }

  Future<void> updateTitle(String itemId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _mutateItem(itemId, (item) => item.title = trimmed);
  }

  Future<void> updateNotes(String itemId, String notes) async {
    await _mutateItem(itemId, (item) => item.notes = notes);
  }

  Future<void> updatePriority(String itemId, TodoPriority priority) async {
    await _mutateItem(itemId, (item) => item.priority = priority);
  }

  /// Sets the item's status explicitly (open / done / deferred).
  Future<void> setStatus(String itemId, TodoStatus status) async {
    await _mutateItem(itemId, (item) {
      item.status = status;
      item.completedAt = status == TodoStatus.done ? DateTime.now() : null;
    });
  }

  Future<void> markDone(String itemId, {bool isDone = true}) async {
    await setStatus(itemId, isDone ? TodoStatus.done : TodoStatus.open);
  }

  Future<void> deleteItem(String itemId) async {
    final current = _current;
    final remaining = current.items.where((i) => i.id != itemId).toList();
    await _persist(
      TodoData(
        lists: current.lists,
        items: remaining,
        activeListId: current.activeListId,
      ),
    );
  }

  Future<void> _mutateItem(
    String itemId,
    void Function(TodoItem item) mutate,
  ) async {
    final current = _current;
    for (final item in current.items) {
      if (item.id == itemId) {
        mutate(item);
        break;
      }
    }
    await _persist(current);
  }
}

TodoItem? findItem(List<TodoItem> items, String? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

TodoList? findList(List<TodoList> lists, String? id) {
  if (id == null) return null;
  for (final list in lists) {
    if (list.id == id) return list;
  }
  return null;
}

List<TodoItem> openItemsSorted(TodoData data, String? listId) {
  if (listId == null) return [];
  final open = data.items
      .where((i) => i.listId == listId && i.status == TodoStatus.open)
      .toList();
  open.sort((a, b) {
    final byPriority = b.priority.index.compareTo(a.priority.index);
    if (byPriority != 0) return byPriority;
    return a.createdAt.compareTo(b.createdAt);
  });
  return open;
}

TodoItem? currentItemFor(TodoData data, String? listId) {
  final open = openItemsSorted(data, listId);
  return open.isEmpty ? null : open.first;
}

List<TodoItem> upcomingItemsFor(
  TodoData data,
  String? listId, {
  int limit = 4,
}) {
  final open = openItemsSorted(data, listId);
  if (open.length <= 1) return [];
  return open.skip(1).take(limit).toList();
}

int countByStatus(TodoData data, String? listId, TodoStatus status) {
  if (listId == null) return 0;
  return data.items
      .where((i) => i.listId == listId && i.status == status)
      .length;
}
