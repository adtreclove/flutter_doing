import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Widgets/Overlays/confetti_overlay.dart';
import 'package:flutter_doing/Widgets/sorting_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassicView extends ConsumerWidget {
  ClassicView({super.key});

  final double _mainPanelWidth = ScreenState.classic.windowSize.width; // 300
  final double _kpiPanelWidth =
      (ScreenState.withSorting.windowSize.width -
      ScreenState.classic.windowSize.width); // 400
  static const double _panelHeight = 175;

  final _confettiController = ConfettiController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleBarState = ref.watch(titleBarProvider);
    final settings = ref.watch(settingsProvider);

    double progress = 0.0;
    final showSorting = settings.showSorting;

    double borderRadius = 10;

    if (Platform.isMacOS) {
      borderRadius = 16;
    }

    const animationDuration = Duration(milliseconds: 200);
    const animationCurve = Curves.easeOut;
    final totalWidth = showSorting
        ? _mainPanelWidth + _kpiPanelWidth
        : _mainPanelWidth;

    return ConfettiOnComplete(
      progress: progress,
      child: Stack(
        children: [
          // ONE positioned card for the whole widget — main panel and KPI
          // panel live inside it as a Row, so hover animates them as a
          // single unit instead of two independently-moving cards.
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
              // mainAxisSize.min + no Expanded children means this Row's
              // width is exactly the sum of its children's widths, which we
              // now animate in lockstep with the outer AnimatedContainer
              // above, instead of jumping instantly — that mismatch was
              // the source of the overflow during the transition.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: _mainPanelWidth,
                    child: _mainPanelContent(theme: theme, progress: progress),
                  ),
                  // Animates its own width from 0 -> _kpiPanelWidth (and
                  // back) using the SAME duration/curve as the outer card,
                  // so the content never asks for more space than the
                  // container currently has during the transition.
                  AnimatedContainer(
                    duration: animationDuration,
                    curve: animationCurve,
                    width: showSorting ? _kpiPanelWidth : 0,
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
                    // Lays the KPI content out at its full intended width
                    // regardless of the animated clip width, so text/rows
                    // inside it don't reflow or wrap mid-animation — they
                    // just get progressively revealed/hidden by the clip.
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 0,
                      maxWidth: _kpiPanelWidth,
                      child: SizedBox(
                        width: _kpiPanelWidth,
                        child: _sortingContent(theme: theme),
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
    required ThemeData theme,
    required double progress,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "text",
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: Text(
                      "text",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 20),
                child: IconButton(
                  onPressed: () async {},
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: theme.dividerColor),
        Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "tet",
                style: TextStyle(
                  fontSize: 25,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: RawMaterialButton(
                  hoverColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  fillColor: theme.colorScheme.surface,
                  elevation: 3,
                  padding: const EdgeInsets.all(4),
                  shape: const CircleBorder(),
                  onPressed: () async {},
                  child: Icon(
                    Icons.play_arrow,
                    size: 25,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: Colors.grey,
            backgroundColor: theme.dividerColor,
          ),
        ),
      ],
    );
  }

  Widget _sortingContent({required ThemeData theme}) {
    // Expanded around each Row splits the available height evenly (matching
    // the Expanded around each card, which already splits width evenly) —
    // without this, both Rows just take their natural height and don't
    // fill/share the panel's actual height at all.
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: SortingCard(value: SortType.open)),
              Expanded(child: SortingCard(value: SortType.done)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [Expanded(child: SortingCard(value: SortType.deferred))],
          ),
        ),
      ],
    );
  }
}
