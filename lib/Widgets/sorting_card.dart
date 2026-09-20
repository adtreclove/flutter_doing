import 'package:flutter/material.dart';
import 'package:flutter_doing/Services/localization_service.dart';

enum SortType { done, open, deferred }

class SortingCard extends StatelessWidget {
  const SortingCard({super.key, required this.value, required this.count});

  final SortType value;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _resolveColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _resolveTitle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveTitle() {
    switch (value) {
      case SortType.done:
        return getIt<LocalizationService>().localizations.task_status_done;
      case SortType.open:
        return getIt<LocalizationService>().localizations.task_status_open;
      case SortType.deferred:
        return getIt<LocalizationService>().localizations.task_status_deferred;
    }
  }

  Color _resolveColor() {
    switch (value) {
      case SortType.open:
        return Colors.blueAccent;
      case SortType.done:
        return Colors.green;
      case SortType.deferred:
        return Colors.orange;
    }
  }
}
