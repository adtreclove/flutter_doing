import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Widgets/Overlays/confetti_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompactView extends ConsumerStatefulWidget {
  const CompactView({super.key});

  @override
  ConsumerState<CompactView> createState() => _CompactViewState();
}

// Top Bar (animated), Invisible spacing 40 top, timer
class _CompactViewState extends ConsumerState<CompactView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleBarState = ref.watch(titleBarProvider);

    double progress = 0;

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
            height: 70,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: Platform.isMacOS
                    ? titleBarState.isHovered
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            )
                          : BorderRadius.circular(999)
                    : BorderRadius.circular(titleBarState.isHovered ? 0 : 999),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: RawMaterialButton(
                      hoverColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      fillColor: theme.colorScheme.surface,
                      elevation: 3,
                      padding: EdgeInsets.all(10),
                      shape: CircleBorder(),
                      onPressed: () async {},
                      child: Icon(
                        Icons.edit,
                        size: 25,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Reserved, non-overlapping space for text + badge — no Positioned
                  // overflow trick, so there's no hit-test ambiguity with anything
                  // else in the Row. The badge only ever occupies its own real slot.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "text",
                        style:
                            theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 25,
                            ) ??
                            TextStyle(
                              fontSize: 25,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: RawMaterialButton(
                      hoverColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      fillColor: theme.colorScheme.surface,
                      elevation: 3,
                      padding: EdgeInsets.all(6),
                      shape: CircleBorder(),
                      onPressed: () async {},
                      child: Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: theme.iconTheme.color,
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
}
