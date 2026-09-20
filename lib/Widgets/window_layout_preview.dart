import 'package:flutter/material.dart';

class LayoutPreview extends StatelessWidget {
  const LayoutPreview({super.key, required this.style, required this.theme});

  final String style; // 'classic' or 'compact'
  final ThemeData theme;

  static const _doneGreen = Color(0xFF43A047);
  static const _accentBlue = Colors.blueAccent;

  Color get _barLight => theme.dividerColor;
  Color get _barDark => theme.textTheme.bodyLarge?.color ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.splashColor,
        borderRadius: BorderRadius.circular(6),
      ),

      alignment: Alignment.center,
      child: style == 'compact'
          ? _buildCompactPreview()
          : _buildClassicPreview(),
    );
  }

  Widget _buildCompactPreview() {
    return SizedBox(
      width: 132,
      height: 26,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: _accentBlue),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bar(_accentBlue, width: 16, height: 3),
                    const SizedBox(height: 3),
                    _bar(_barDark, width: double.infinity, height: 4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Center(child: _circle(_doneGreen, size: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicPreview() {
    return SizedBox(
      width: 132,
      height: 92,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
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
            _bar(_barLight, width: 38, height: 4),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: _circle(_accentBlue, size: 6),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _bar(_barDark, width: double.infinity, height: 6),
                ),
                const SizedBox(width: 5),
                _circle(_doneGreen, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 6),
            _bar(_barLight, width: 34, height: 3),
            const SizedBox(height: 5),
            _previewRow(),
            const SizedBox(height: 4),
            _previewRow(),
          ],
        ),
      ),
    );
  }

  Widget _previewRow() {
    return Row(
      children: [
        _circle(_barLight, size: 4),
        const SizedBox(width: 4),
        Expanded(child: _bar(_barLight, width: double.infinity, height: 3)),
      ],
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
