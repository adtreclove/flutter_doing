import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Widgets/AppBars/app_bar_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class AnimatedTitleBar extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const AnimatedTitleBar({
    super.key,
    required this.child,
    this.title = 'DOING',
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimatedTitleBarState();
}

class _AnimatedTitleBarState extends ConsumerState<AnimatedTitleBar> {
  bool _isMenuOpen = false;

  void _showContextMenu(BuildContext context, TapUpDetails details) {
    ContextMenuController.removeAny();

    setState(() {
      _isMenuOpen = true;
    });

    contextMenuController.show(
      context: context,
      contextMenuBuilder: (BuildContext context) {
        // Correct argument name is contextMenuBuilder
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: details.globalPosition,
          ),
          buttonItems: buildContextMenuItems(),
        );
      },
    );
  }

  void _handleMenuClose() {
    if (contextMenuController.isShown) {
      contextMenuController.remove();
    }
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  void dispose() {
    if (contextMenuController.isShown) {
      contextMenuController.remove();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleBarState = ref.watch(titleBarProvider);
    final notifier = ref.read(titleBarProvider.notifier);
    final screenStateAsync = ref.watch(screenStateProvider);

    return GestureDetector(
      onSecondaryTapUp: (details) => _showContextMenu(context, details),
      onTapDown: (details) => _handleMenuClose(),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        onHover: (_) {
          if (!_isMenuOpen) notifier.hoverEnter();
        },
        onExit: (_) {
          if (!_isMenuOpen) notifier.hoverExit();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,

            screenStateAsync.when(
              skipError: true,
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              data: (state) {
                if (state == ScreenState.classic ||
                    state == ScreenState.compact) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    top: titleBarState.isHovered ? 0 : -50,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Material(
                      color: Colors.black,
                      elevation: 4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (_) => windowManager.startDragging(),
                        onDoubleTap: () async {
                          if (await windowManager.isMaximized()) {
                            await windowManager.unmaximize();
                            notifier.setMaximized(false);
                          } else {
                            await windowManager.maximize();
                            notifier.setMaximized(true);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              WindowButton(
                                icon: Icons.remove,
                                onPressed: () => windowManager.minimize(),
                              ),

                              WindowButton(
                                icon: Icons.close,
                                isClose: true,
                                onPressed: () => windowManager.close(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
              error: (Object error, StackTrace stackTrace) {
                return SizedBox();
              },
              loading: () {
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
