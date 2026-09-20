import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Controller/todo_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/todo_data_model.dart';
import 'package:flutter_doing/Models/todo_item_model.dart';
import 'package:flutter_doing/Extensions/todo_priority_extension.dart';
import 'package:flutter_doing/Extensions/todo_status_extension.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Services/shared_preferences_service.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_mac.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_windows.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// save status for saving the notes
enum SaveStatus { idle, saving, saved, error }

class EditView extends ConsumerStatefulWidget {
  const EditView({super.key});

  @override
  ConsumerState<EditView> createState() => _EditViewState();
}

class _EditViewState extends ConsumerState<EditView> {
  String? _selectedItemId;
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _newTaskController = TextEditingController();

  Timer? _notesDebounce;
  SaveStatus _saveStatus = SaveStatus.idle;
  bool _preselected = false;

  @override
  void initState() {
    super.initState();

    // Preselect whatever item Compact/Classic view's edit button asked us
    // to open — done once, after the first frame, so the provider has had
    // a chance to load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _preselected) return;
      _preselected = true;
      final requestedId = ref.read(editingItemIdProvider);
      if (requestedId != null) {
        _selectItem(requestedId);
      }
    });
  }

  void _selectItem(String? itemId) {
    final data = ref.read(todoProvider).value;
    final item = data == null ? null : findItem(data.items, itemId);
    setState(() {
      _selectedItemId = item?.id;
      _titleController.text = item?.title ?? '';
      _notesController.text = item?.notes ?? '';
      _saveStatus = SaveStatus.idle;
    });
  }

  void _onNoteChanged(String value) {
    final itemId = _selectedItemId;
    if (itemId == null) return;

    _notesDebounce?.cancel();
    setState(() => _saveStatus = SaveStatus.idle);
    _notesDebounce = Timer(const Duration(milliseconds: 600), () {
      _saveNote(itemId, value);
    });
  }

  Future<void> _saveNote(String itemId, String value) async {
    setState(() => _saveStatus = SaveStatus.saving);
    try {
      await ref.read(todoProvider.notifier).updateNotes(itemId, value);
      if (!mounted) return;
      setState(() => _saveStatus = SaveStatus.saved);

      Timer(const Duration(seconds: 2), () {
        if (mounted && _saveStatus == SaveStatus.saved) {
          setState(() => _saveStatus = SaveStatus.idle);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveStatus = SaveStatus.error);
    }
    coloredLog("[EDIT VIEW] Saving note", color: 'green');
  }

  // suffix icon for saving the note
  Widget _buildSuffixIcon() {
    switch (_saveStatus) {
      case SaveStatus.saving:
        return const SizedBox(
          key: ValueKey('saving'),
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ),
        );
      case SaveStatus.saved:
        return const Icon(
          Icons.save,
          key: ValueKey('saved'),
          color: Colors.green,
        );
      case SaveStatus.error:
        return const Icon(
          Icons.error_outline,
          key: ValueKey('error'),
          color: Colors.red,
        );
      case SaveStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoAsync = ref.watch(todoProvider);
    final data = todoAsync.value;

    // to prevent render overflows, use Layout Builder here
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight <= 200) {
          return SizedBox.shrink();
        } else {
          return Column(
            children: [
              Platform.isMacOS
                  ? SettingsTitleBarMac(title: "Doing")
                  : SettingsTitleBarWindows(
                      title: getIt<LocalizationService>()
                          .localizations
                          .edit_screen_title,
                    ),
              Expanded(
                child: data == null
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Container(
                              color: theme.scaffoldBackgroundColor,
                            );
                          } else if (constraints.maxHeight < 150) {
                            return Container(
                              color: theme.scaffoldBackgroundColor,
                            );
                          } else {
                            return _editContent(theme, data);
                          }
                        },
                      ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _editContent(ThemeData theme, TodoData data) {
    final activeListId = data.activeListId;
    final items = data.items.where((i) => i.listId == activeListId).toList()
      ..sort((a, b) {
        // Open first, then deferred, then done last.
        final rankDiff = _statusRank(a.status).compareTo(_statusRank(b.status));
        if (rankDiff != 0) return rankDiff;
        final byPriority = b.priority.index.compareTo(a.priority.index);
        if (byPriority != 0) return byPriority;
        return a.createdAt.compareTo(b.createdAt);
      });

    final selectedItem = findItem(data.items, _selectedItemId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(theme, data),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 270,
                  child: _panelCard(
                    theme: theme,
                    padding: const EdgeInsets.all(14),
                    child: _taskListPanel(theme, activeListId, items),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _panelCard(
                    theme: theme,
                    padding: const EdgeInsets.all(22),
                    child: selectedItem == null
                        ? _emptyDetail(theme)
                        : _detailEditor(theme, selectedItem),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelCard({
    required ThemeData theme,
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }

  Widget _header(ThemeData theme, TodoData data) {
    final activeListId = data.activeListId;
    final hasActiveList = data.lists.any((l) => l.id == activeListId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                getIt<LocalizationService>().localizations.edit_screen_list,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: DropdownButton<String>(
                  value: hasActiveList ? activeListId : null,
                  hint: Text(
                    getIt<LocalizationService>()
                        .localizations
                        .edit_screen_no_list,
                  ),
                  underline: const SizedBox(),
                  isDense: true,
                  dropdownColor: theme.colorScheme.surfaceContainerHighest,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  items: data.lists
                      .map(
                        (list) => DropdownMenuItem(
                          value: list.id,
                          child: Text(list.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    _selectItem(null);
                    ref.read(todoProvider.notifier).setActiveList(value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: _promptNewList,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            getIt<LocalizationService>().localizations.edit_screen_new_list,
          ),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: getIt<LocalizationService>().localizations.edit_screen_close,
          onPressed: () async {
            final appState = await SharedPreferencesService.instance
                .loadAppScreenState();
            final settings = ref.read(settingsProvider);

            await ref
                .read(screenStateProvider.notifier)
                .changeState(appState, settings);
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _taskListPanel(
    ThemeData theme,
    String? activeListId,
    List<TodoItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTaskController,
                enabled: activeListId != null,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: getIt<LocalizationService>()
                      .localizations
                      .edit_screen_new_task,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addTask(activeListId),
              ),
            ),
            IconButton(
              onPressed: activeListId == null
                  ? null
                  : () => _addTask(activeListId),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    getIt<LocalizationService>()
                        .localizations
                        .edit_screen_no_task_in_list,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.id == _selectedItemId;
                    return Material(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _selectItem(item.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.isDone,
                                onChanged: (value) => ref
                                    .read(todoProvider.notifier)
                                    .markDone(item.id, isDone: value ?? false),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: item.priority.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    decoration: item.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontStyle: item.isDeferred
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: (item.isDone || item.isDeferred)
                                        ? theme.textTheme.bodyMedium?.color
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              IconButton(
                                iconSize: 18,
                                tooltip: item.status == TodoStatus.deferred
                                    ? getIt<LocalizationService>()
                                          .localizations
                                          .edit_screen_activate_again
                                    : getIt<LocalizationService>()
                                          .localizations
                                          .edit_screen_defer,
                                onPressed: () => ref
                                    .read(todoProvider.notifier)
                                    .setStatus(
                                      item.id,
                                      item.status == TodoStatus.deferred
                                          ? TodoStatus.open
                                          : TodoStatus.deferred,
                                    ),
                                icon: Icon(
                                  item.status == TodoStatus.deferred
                                      ? Icons.play_circle_outline
                                      : Icons.pause_circle_outline,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                              IconButton(
                                iconSize: 18,
                                tooltip: getIt<LocalizationService>()
                                    .localizations
                                    .edit_screen_delete,
                                onPressed: () => _deleteItem(item.id),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _emptyDetail(ThemeData theme) {
    return Center(
      child: Text(
        getIt<LocalizationService>().localizations.edit_screen_empty_detail,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  // Scrollable rather than relying on Expanded to fit everything
  Widget _detailEditor(ThemeData theme, TodoItem item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          TextField(
            controller: _titleController,
            style: theme.textTheme.titleLarge,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: getIt<LocalizationService>()
                  .localizations
                  .edit_screen_task_title,
            ),
            onSubmitted: (value) =>
                ref.read(todoProvider.notifier).updateTitle(item.id, value),
            onTapOutside: (_) => ref
                .read(todoProvider.notifier)
                .updateTitle(item.id, _titleController.text),
          ),
          const SizedBox(height: 16),
          Text(
            getIt<LocalizationService>().localizations.edit_screen_status_title,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          // Wrap (not Row)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TodoStatus.values.map((status) {
              final selected = item.status == status;
              return ChoiceChip(
                label: Text(status.label),
                selected: selected,
                selectedColor: status.color.withValues(alpha: 0.25),
                onSelected: (_) =>
                    ref.read(todoProvider.notifier).setStatus(item.id, status),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            getIt<LocalizationService>()
                .localizations
                .edit_screen_status_priority,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TodoPriority.values.map((priority) {
              final selected = item.priority == priority;
              return ChoiceChip(
                label: Text(priority.label),
                selected: selected,
                selectedColor: priority.color.withValues(alpha: 0.25),
                onSelected: (_) => ref
                    .read(todoProvider.notifier)
                    .updatePriority(item.id, priority),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            getIt<LocalizationService>().localizations.edit_screen_status_notes,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: _onNoteChanged,
            controller: _notesController,
            minLines: 5,
            maxLines: 12,
            textAlignVertical: TextAlignVertical.top,
            autocorrect: true,
            keyboardType: TextInputType.multiline,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              alignLabelWithHint: true,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildSuffixIcon(),
                ),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              hintText: getIt<LocalizationService>()
                  .localizations
                  .edit_screen_notes_hint,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(String? listId) async {
    if (listId == null) return;
    final title = _newTaskController.text.trim();
    if (title.isEmpty) return;

    final item = await ref
        .read(todoProvider.notifier)
        .addItem(listId: listId, title: title);
    _newTaskController.clear();
    _selectItem(item.id);
  }

  Future<void> _deleteItem(String itemId) async {
    if (_selectedItemId == itemId) {
      _selectItem(null);
    }
    await ref.read(todoProvider.notifier).deleteItem(itemId);
  }

  Future<void> _promptNewList() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          getIt<LocalizationService>().localizations.edit_screen_new_list,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: getIt<LocalizationService>()
                .localizations
                .edit_screen_new_list_name,
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              getIt<LocalizationService>().localizations.edit_screen_cancel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(
              getIt<LocalizationService>().localizations.edit_screen_create,
            ),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      final list = await ref.read(todoProvider.notifier).addList(name);
      await ref.read(todoProvider.notifier).setActiveList(list.id);
    }
  }

  @override
  void dispose() {
    _notesDebounce?.cancel();
    _titleController.dispose();
    _notesController.dispose();
    _newTaskController.dispose();
    super.dispose();
  }
}

int _statusRank(TodoStatus status) {
  switch (status) {
    case TodoStatus.open:
      return 0;
    case TodoStatus.deferred:
      return 1;
    case TodoStatus.done:
      return 2;
  }
}
