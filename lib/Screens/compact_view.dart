import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Controller/todo_controller.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/todo_item_model.dart';
import 'package:flutter_doing/Extensions/todo_priority_extension.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Widgets/Overlays/confetti_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompactView extends ConsumerStatefulWidget {
  const CompactView({super.key});

  @override
  ConsumerState<CompactView> createState() => _CompactViewState();
}

class _CompactViewState extends ConsumerState<CompactView> {
  static const double _cardHeight = 58;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleBarState = ref.watch(titleBarProvider);
    final todoAsync = ref.watch(todoProvider);

    final data = todoAsync.value;
    final activeListId = data?.activeListId;
    final TodoItem? currentItem = data == null
        ? null
        : currentItemFor(data, activeListId);
    final hasAnyItems =
        data != null && data.items.any((i) => i.listId == activeListId);

    // Confetti fires the moment there is no more open item left (only if the list had items)
    final progress = hasAnyItems && currentItem == null ? 1.0 : 0.0;

    final accentColor = currentItem?.priority.color ?? theme.dividerColor;

    return ConfettiOnComplete(
      progress: progress,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: titleBarState.isHovered ? 40 : 0,
            left: 0,
            right: 0,
            height: _cardHeight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(
                  titleBarState.isHovered ? 0 : 16,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 4,
                    color: accentColor,
                  ),
                  // Tapping anywhere in the title area opens the edit screen

                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openEdit(currentItem?.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentItem != null)
                                Text(
                                  currentItem.priority.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: accentColor,
                                  ),
                                ),
                              Text(
                                currentItem?.title ??
                                    (hasAnyItems
                                        ? getIt<LocalizationService>()
                                              .localizations
                                              .tasks_all_done
                                        : getIt<LocalizationService>()
                                              .localizations
                                              .tasks_no_tasks),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionButton(
                          theme: theme,
                          icon: Icons.check,
                          filledColor: Colors.green,
                          onPressed: currentItem == null
                              ? null
                              : () => ref
                                    .read(todoProvider.notifier)
                                    .markDone(currentItem.id),
                        ),
                      ],
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

  Widget _actionButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? filledColor,
  }) {
    final bool filled = filledColor != null;
    final bool enabled = onPressed != null;
    final Color background = filled
        ? (enabled ? filledColor : theme.dividerColor)
        : Colors.transparent;
    final Color iconColor = filled
        ? Colors.white
        : (theme.iconTheme.color ?? Colors.grey);

    return SizedBox(
      width: 28,
      height: 28,
      child: RawMaterialButton(
        onPressed: onPressed,
        fillColor: background,
        hoverColor: filled
            ? filledColor.withValues(alpha: 0.85)
            : theme.colorScheme.primary.withValues(alpha: 0.12),
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Future<void> _openEdit(String? itemId) async {
    ref.read(editingItemIdProvider.notifier).state = itemId;
    final settings = ref.read(settingsProvider);
    await ref
        .read(screenStateProvider.notifier)
        .changeState(ScreenState.edit, settings);
  }
}
