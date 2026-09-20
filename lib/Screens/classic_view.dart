import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Controller/todo_controller.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/todo_data_model.dart';
import 'package:flutter_doing/Models/todo_item_model.dart';
import 'package:flutter_doing/Extensions/todo_priority_extension.dart';
import 'package:flutter_doing/Extensions/todo_status_extension.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Widgets/Overlays/confetti_overlay.dart';
import 'package:flutter_doing/Widgets/sorting_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassicView extends ConsumerWidget {
  ClassicView({super.key});

  final double _mainPanelWidth = ScreenState.classic.windowSize.width; // 300
  final double _sortPanelWidth =
      (ScreenState.withSorting.windowSize.width -
      ScreenState.classic.windowSize.width); // 400
  static const double _panelHeight = 254;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleBarState = ref.watch(titleBarProvider);
    final settings = ref.watch(settingsProvider);
    final todoAsync = ref.watch(todoProvider);

    final data = todoAsync.value;
    final activeListId = data?.activeListId;
    final TodoItem? currentItem = data == null
        ? null
        : currentItemFor(data, activeListId);
    final List<TodoItem> upcoming = data == null
        ? <TodoItem>[]
        : upcomingItemsFor(data, activeListId);
    final hasAnyItems =
        data != null && data.items.any((i) => i.listId == activeListId);

    final activeListName = data == null
        ? ""
        : findList(data.lists, activeListId)?.name ?? "";

    final progress = hasAnyItems && currentItem == null ? 1.0 : 0.0;
    final showSorting = settings.showSorting;

    double borderRadius = 10;

    if (Platform.isMacOS) {
      borderRadius = 16;
    }

    const animationDuration = Duration(milliseconds: 200);
    const animationCurve = Curves.easeOut;
    final totalWidth = showSorting
        ? _mainPanelWidth + _sortPanelWidth
        : _mainPanelWidth;

    return ConfettiOnComplete(
      progress: progress,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: animationDuration,
            curve: animationCurve,
            top: titleBarState.isHovered ? 40 : 0,
            left: 0,
            width: totalWidth,
            height: _panelHeight,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(
                  titleBarState.isHovered ? 0 : borderRadius,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: _mainPanelWidth,
                    child: _mainPanelContent(
                      ref: ref,
                      theme: theme,
                      currentItem: currentItem,
                      upcoming: upcoming,
                      hasAnyItems: hasAnyItems,
                      activeListName: activeListName,
                    ),
                  ),
                  // Animates its own width from 0 -> _sortPanelWidth (and
                  // back) using the SAME duration/curve as the outer card,
                  // so the content never asks for more space than the
                  // container currently has during the transition.
                  AnimatedContainer(
                    duration: animationDuration,
                    curve: animationCurve,
                    width: showSorting ? _sortPanelWidth : 0,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: showSorting
                              ? theme.dividerColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 0,
                      maxWidth: _sortPanelWidth,
                      child: SizedBox(
                        width: _sortPanelWidth,
                        child: _sortingContent(
                          theme: theme,
                          data: data,
                          activeListId: activeListId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainPanelContent({
    required WidgetRef ref,
    required ThemeData theme,
    required TodoItem? currentItem,
    required List<TodoItem> upcoming,
    required bool hasAnyItems,
    required String activeListName,
  }) {
    final accentColor = currentItem?.priority.color ?? theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header: list name -------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Text(
            activeListName.isEmpty
                ? getIt<LocalizationService>()
                      .localizations
                      .classic_view_no_list
                : activeListName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ---- Current task, front and center -------------------------------
        // Tapping the task (dot + title) opens the edit screen — always
        // navigable, even with no current item, so there's still a way to
        // reach EditView and add a first task.
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openEdit(ref, currentItem?.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentItem?.title ??
                                  (hasAnyItems
                                      ? getIt<LocalizationService>()
                                            .localizations
                                            .tasks_all_done
                                      : getIt<LocalizationService>()
                                            .localizations
                                            .tasks_no_tasks),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _doneButton(
                theme: theme,
                onPressed: currentItem == null
                    ? null
                    : () => ref
                          .read(todoProvider.notifier)
                          .markDone(currentItem.id),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        Divider(height: 1, color: theme.dividerColor),

        // ---- Preview of what's next -----------------------------------------
        Expanded(
          child: _previewSection(theme: theme, upcoming: upcoming),
        ),
      ],
    );
  }

  Widget _doneButton({
    required ThemeData theme,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    return SizedBox(
      width: 32,
      height: 32,
      child: RawMaterialButton(
        onPressed: onPressed,
        fillColor: enabled ? Colors.green : theme.dividerColor,
        hoverColor: Colors.green.withValues(alpha: 0.85),
        elevation: 0,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      ),
    );
  }

  /// The "lower part" preview of upcoming tasks in the active list
  Widget _previewSection({
    required ThemeData theme,
    required List<TodoItem> upcoming,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getIt<LocalizationService>().localizations.classic_view_upcoming,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: upcoming.isEmpty
                ? Text(
                    getIt<LocalizationService>()
                        .localizations
                        .classic_view_no_upcoming_tasks,
                    style: theme.textTheme.bodyMedium,
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: upcoming.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final item = upcoming[index];
                      return Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: item.priority.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sortingContent({
    required ThemeData theme,
    required TodoData? data,
    required String? activeListId,
  }) {
    final openCount = data == null
        ? 0
        : countByStatus(data, activeListId, TodoStatus.open);
    final doneCount = data == null
        ? 0
        : countByStatus(data, activeListId, TodoStatus.done);
    final deferredCount = data == null
        ? 0
        : countByStatus(data, activeListId, TodoStatus.deferred);
    final total = openCount + doneCount + deferredCount;
    final completion = total == 0 ? 0.0 : doneCount / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 15,
                color: theme.iconTheme.color,
              ),
              const SizedBox(width: 6),
              Text(
                getIt<LocalizationService>()
                    .localizations
                    .classic_view_overview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "$total ${getIt<LocalizationService>().localizations.classic_view_total}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 6,
              backgroundColor: theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(completion * 100).round()}% ${getIt<LocalizationService>().localizations.classic_view_sorting_done}",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SortingCard(value: SortType.open, count: openCount),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SortingCard(value: SortType.done, count: doneCount),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SortingCard(
                  value: SortType.deferred,
                  count: deferredCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(WidgetRef ref, String? itemId) async {
    ref.read(editingItemIdProvider.notifier).state = itemId;
    final settings = ref.read(settingsProvider);
    await ref
        .read(screenStateProvider.notifier)
        .changeState(ScreenState.edit, settings);
  }
}
