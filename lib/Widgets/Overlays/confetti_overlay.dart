import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';

/// Controls a [ConfettiOverlay] — create one, pass it to the overlay, and
/// call [play] whenever you want a burst (e.g. on a button press).

class ConfettiController {
  _ConfettiOverlayState? _state;

  void _attach(_ConfettiOverlayState state) => _state = state;
  void _detach(_ConfettiOverlayState state) {
    if (_state == state) _state = null;
  }

  /// Triggers a confetti burst across the whole overlay area.
  void play() => _state?._play();

  void dispose() {
    _state = null;
  }
}

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.controller,
    this.particleCount = 80,
    this.colors = const [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFDD835),
      Color(0xFF8E24AA),
      Color(0xFFFB8C00),
    ],
    this.duration = const Duration(seconds: 3),
  });

  final ConfettiController controller;
  final int particleCount;
  final List<Color> colors;
  final Duration duration;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Particle {
  _Particle({
    required this.x,
    required this.color,
    required this.size,
    required this.shape,
    required this.fallSpeed,
    required this.swaySpeed,
    required this.swayAmount,
    required this.rotationSpeed,
    required this.startDelay,
  });

  final double x; // 0..1 horizontal start position, fraction of width
  final Color color;
  final double size;
  final int shape; // 0 = rect (confetti strip), 1 = circle
  final double fallSpeed; // relative speed multiplier
  final double swaySpeed;
  final double swayAmount;
  final double rotationSpeed;
  final double startDelay; // 0..1 fraction of total duration before it starts
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  void _play() {
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: _random.nextDouble(),
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: 6 + _random.nextDouble() * 6,
        shape: _random.nextInt(2),
        fallSpeed: 0.7 + _random.nextDouble() * 0.6,
        swaySpeed: 1 + _random.nextDouble() * 2,
        swayAmount: 10 + _random.nextDouble() * 20,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        startDelay:
            _random.nextDouble() *
            0.15, // slight stagger so it doesn't look robotic
      );
    });
    _controller
      ..reset()
      ..forward();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IgnorePointer so the confetti never blocks clicks on the real UI
    // underneath it — it's purely decorative and should be inert to input.
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty || progress <= 0) return;

    for (final p in particles) {
      // Normalize each particle's own progress against its stagger delay,
      // so particles with startDelay > 0 don't just sit frozen at the top
      // for that fraction of the animation — they start later but still
      // complete their fall by the time the overall animation ends.
      final localProgress = ((progress - p.startDelay) / (1 - p.startDelay))
          .clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      final dx =
          p.x * size.width +
          sin(localProgress * p.swaySpeed * pi * 2) * p.swayAmount;
      final dy = localProgress * (size.height + 40) * p.fallSpeed - 20;

      if (dy > size.height + 20) continue; // already fell off the bottom

      final opacity = localProgress > 0.85
          ? (1 - (localProgress - 0.85) / 0.15).clamp(0.0, 1.0)
          : 1.0;

      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(localProgress * p.rotationSpeed * pi);

      if (p.shape == 0) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

/// Wraps [child] and automatically plays a confetti burst the MOMENT
/// [progress] crosses from below 1.0 to 1.0-or-above — not just "whenever
/// progress happens to equal 1.0", which would re-fire on every rebuild
/// while progress stays at 100% (very common with rebuild-heavy provider
/// setups). Detection is edge-based via didUpdateWidget, comparing the
/// previous and new progress values on each update.
///
/// The overlay always fills whatever space [child] occupies (via a
/// Positioned.fill Stack), and runs for exactly 5 seconds before the
/// AnimationController completes and stops on its own — no extra timer
/// needed, since ConfettiOverlay already stops naturally once its
/// AnimationController finishes.
///
/// Usage:
/// ```dart
/// ConfettiOnComplete(
///   progress: progress, // your existing 0.0..1.0 value
///   child: YourExistingCardOrScreen(),
/// )
/// ```
class ConfettiOnComplete extends StatefulWidget {
  const ConfettiOnComplete({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  State<ConfettiOnComplete> createState() => _ConfettiOnCompleteState();
}

class _ConfettiOnCompleteState extends State<ConfettiOnComplete> {
  final _confettiController = ConfettiController();
  late double _previousProgress;

  @override
  void initState() {
    super.initState();
    // Seed with the CURRENT value, not 0 — so opening this screen while
    // progress already happens to be at 100% does NOT immediately fire a
    // burst; only a genuine crossing while the widget is alive should.
    _previousProgress = widget.progress;
  }

  @override
  void didUpdateWidget(covariant ConfettiOnComplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_previousProgress < 1.0 && widget.progress >= 1.0) {
      coloredLog("[CONFETTI] Throwing confetti", color: 'magenta');
      _confettiController.play();
    }
    _previousProgress = widget.progress;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: ConfettiOverlay(
            controller: _confettiController,
            duration: const Duration(seconds: 5), // runs, then stops, after 5s
          ),
        ),
      ],
    );
  }
}
