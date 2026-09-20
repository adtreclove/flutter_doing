import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/title_bar_controller.dart';
import 'package:flutter_doing/Widgets/AppBars/app_bar_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// macOS-style title bar: traffic-light buttons (close/minimize/maximize) on
/// the LEFT, centered title, same hover-to-reveal + drag-to-move behavior as
/// CustomTitleBarOverlay. Use this on macOS builds; use CustomTitleBarOverlay
/// on Windows, matching each platform's native window chrome conventions.
class AnimatedTitleBarMac extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const AnimatedTitleBarMac({
    super.key,
    required this.child,
    this.title = 'DOING',
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimatedTitleBarMacState();
}

class _AnimatedTitleBarMacState extends ConsumerState<AnimatedTitleBarMac> {
  bool _isMenuOpen = false;
  bool _hoveringTrafficLights = false;

  void _showContextMenu(BuildContext context, TapUpDetails details) {
    ContextMenuController.removeAny();

    setState(() {
      _isMenuOpen = true;
    });

    contextMenuController.show(
      context: context,
      contextMenuBuilder: (BuildContext context) {
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

  Future<void> _toggleMaximize(dynamic notifier) async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
      notifier.setMaximized(false);
    } else {
      await windowManager.maximize();
      notifier.setMaximized(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleBarState = ref.watch(titleBarProvider);
    final notifier = ref.read(titleBarProvider.notifier);

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

            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: titleBarState.isHovered ? 0 : -50,
              left: 0,
              right: 0,
              height: 40,
              child: Material(
                // macOS title bars are typically a neutral, near-opaque
                // surface rather than an accent color — closer to the
                // system's own unified toolbar look than a branded bar.
                color: Colors.black,
                elevation: 4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => windowManager.startDragging(),
                  onDoubleTap: () => _toggleMaximize(notifier),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered title — macOS convention places the
                        // window title in the middle of the bar, not
                        // left-aligned next to the traffic lights.
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Traffic lights, pinned to the left.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => _hoveringTrafficLights = true),
                            onExit: (_) =>
                                setState(() => _hoveringTrafficLights = false),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TrafficLightButton(
                                  color: const Color(0xFFFF5F57),
                                  icon: Icons.close,
                                  showIcon: _hoveringTrafficLights,
                                  onPressed: () => windowManager.close(),
                                ),
                                const SizedBox(width: 8),
                                _TrafficLightButton(
                                  color: const Color(0xFFFFBD2E),
                                  icon: Icons.remove,
                                  showIcon: _hoveringTrafficLights,
                                  onPressed: () => windowManager.minimize(),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single macOS-style traffic-light dot. Shows its glyph only while the
/// whole cluster is hovered — matching real macOS behavior, where the
/// icons inside the dots are invisible until you mouse over any of them.
class _TrafficLightButton extends StatelessWidget {
  const _TrafficLightButton({
    required this.color,
    required this.icon,
    required this.showIcon,
    required this.onPressed,
    this.iconSize = 8,
  });

  final Color color;
  final IconData icon;
  final bool showIcon;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: showIcon ? 1 : 0,
          child: Icon(
            icon,
            size: iconSize,
            // The glyphs macOS draws inside traffic lights are a dark
            // tint of the dot's own color, not plain black/white.
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
