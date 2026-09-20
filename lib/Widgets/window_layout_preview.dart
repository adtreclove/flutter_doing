import 'package:flutter/material.dart';

class LayoutPreview extends StatelessWidget {
  const LayoutPreview({super.key, required this.style, required this.theme});

  final String style; // 'classic' or 'compact'
  final ThemeData theme;

  static const _barDark = Color(0xFF4A4A4A);
  static const _barLight = Color(0xFFBDBDBD);
  static const _avatarColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.splashColor,
        borderRadius: BorderRadius.circular(6),
      ),
      // Centers the fixed-size mini-card below within whatever space this
      // frame actually has — the card itself never stretches to fill it.
      alignment: Alignment.center,
      child: style == 'compact'
          ? _buildCompactPreview()
          : _buildClassicPreview(),
    );
  }

  Widget _buildClassicPreview() {
    // Fixed canvas — every child below is designed to fit inside exactly
    // this box, regardless of how big or small the outer frame is.
    return SizedBox(
      width: 130,
      height: 74,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _circle(_avatarColor, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  // Safe now — Expanded resolves against the fixed 130px
                  // parent width, not an unbounded/variable frame.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(_barDark, width: double.infinity, height: 4),
                      const SizedBox(height: 3),
                      _bar(_barLight, width: 26, height: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                _clockDigits(barWidth: 4, colonWidth: 1.5, height: 8),
                const Spacer(),
                _circle(const Color(0xFFE53935), size: 10),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: 0.6,
                minHeight: 4,
                color: const Color(0xFF43A047),
                backgroundColor: theme.dividerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPreview() {
    return SizedBox(
      width: 90,
      height: 22,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pencilDot(size: 12),
            _clockDigits(barWidth: 3, colonWidth: 1, height: 7),
            _circle(const Color(0xFF43A047), size: 12),
          ],
        ),
      ),
    );
  }

  Widget _clockDigits({
    required double barWidth,
    required double colonWidth,
    required double height,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        final isColon = i == 2 || i == 5;
        return Padding(
          padding: const EdgeInsets.only(right: 1.5),
          child: _bar(
            _barDark,
            width: isColon ? colonWidth : barWidth,
            height: height,
          ),
        );
      }),
    );
  }

  Widget _pencilDot({double size = 18}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _barLight.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.edit, size: size * 0.55, color: _barDark),
    );
  }

  Widget _circle(Color color, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _bar(Color color, {double width = 40, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
