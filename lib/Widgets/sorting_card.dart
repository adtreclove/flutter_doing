import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortType { done, open, deferred }

class SortingCard extends ConsumerStatefulWidget {
  const SortingCard({super.key, required this.value});
  final SortType value;

  @override
  ConsumerState<SortingCard> createState() => _SortingCardState();
}

class _SortingCardState extends ConsumerState<SortingCard>
    with SingleTickerProviderStateMixin {
  // How far the mouse is from the card's center, normalized to -1..1 on
  // each axis. (0, 0) means centered / not hovered.
  Offset _tilt = Offset.zero;
  bool _hovering = false;

  // Tune these to taste:
  static const double _maxTiltAngle = 0.12; // radians (~7°) at the edges
  static const double _hoverScale = 1.03;
  static const double _restScale = 1.0;

  late String title;
  String value = "";
  late Color accentColor;

  @override
  void initState() {
    super.initState();
    title = _resolveTitle();

    accentColor = _resolveColor();
  }

  void _updateTilt(PointerEvent event, Size size) {
    // Position relative to the card's center, normalized to -1..1.
    final dx = (event.localPosition.dx / size.width) * 2 - 1;
    final dy = (event.localPosition.dy / size.height) * 2 - 1;
    setState(() {
      _tilt = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  void _resetTilt() {
    setState(() {
      _hovering = false;
      _tilt = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);

    title = _resolveTitle();
    value = _resolveValue();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onHover: (event) => _updateTilt(event, size),
          onExit: (_) => _resetTilt(),
          // AnimatedContainer/TweenAnimationBuilder both animate toward
          // whatever _tilt currently is — while actively hovering, that
          // means every mouse-move snaps the target and it eases toward
          // it (a smooth "follow"); on exit, _tilt resets to zero and the
          // same easing animates it back to flat, giving the settle/swing
          // -back feel rather than an abrupt jump.
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: _tilt, end: _tilt),
            duration: Duration(milliseconds: _hovering ? 120 : 350),
            curve: _hovering ? Curves.easeOut : Curves.elasticOut,
            builder: (context, animatedTilt, child) {
              final rotateY = -animatedTilt.dx * _maxTiltAngle;
              final rotateX = animatedTilt.dy * _maxTiltAngle;
              final scale = _hovering ? _hoverScale : _restScale;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(rotateX)
                  ..rotateY(rotateY)
                  ..scale(scale),
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(
                left: 4,
                right: 4,
                top: 3,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                  color: _hovering
                      ? accentColor.withValues(alpha: 0.6)
                      : theme.highlightColor,
                  width: _hovering ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: _hovering ? 18.0 : 10.0,
                    offset: Offset(0, _hovering ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(title, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 4),
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _resolveTitle() {
    switch (widget.value) {
      case SortType.done:
        return "erledigt";
      case SortType.open:
        return "offen";
      case SortType.deferred:
        return "zurückgestellt";
    }
  }

  String _resolveValue() {
    switch (widget.value) {
      case SortType.done:
        return "10";
      case SortType.open:
        return "1";
      case SortType.deferred:
        return "2";
    }
  }

  Color _resolveColor() {
    switch (widget.value) {
      case SortType.open:
        return Colors.green;
      case SortType.done:
        return Colors.blue;
      case SortType.deferred:
        return Colors.orange;
    }
  }
}
