import 'package:flutter/material.dart';
import 'package:flutter_doing/Services/localization_service.dart';

/// How prioritized a TodoItem is. Ordered low -> high; the enum index is used
/// directly for sorting (higher index = higher priority = shown first).
enum TodoPriority { low, medium, high }

extension TodoPriorityX on TodoPriority {
  String get label {
    switch (this) {
      case TodoPriority.low:
        return getIt<LocalizationService>().localizations.task_priority_low;
      case TodoPriority.medium:
        return getIt<LocalizationService>().localizations.task_priority_medium;
      case TodoPriority.high:
        return getIt<LocalizationService>().localizations.task_priority_high;
    }
  }

  Color get color {
    switch (this) {
      case TodoPriority.low:
        return Colors.blueGrey;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.redAccent;
    }
  }

  static TodoPriority fromName(String? name) {
    return TodoPriority.values.firstWhere(
      (priority) => priority.name == name,
      orElse: () => TodoPriority.medium,
    );
  }
}
