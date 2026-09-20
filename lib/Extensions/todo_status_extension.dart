import 'package:flutter/material.dart';
import 'package:flutter_doing/Services/localization_service.dart';

enum TodoStatus { open, done, deferred }

extension TodoStatusX on TodoStatus {
  String get label {
    switch (this) {
      case TodoStatus.open:
        return getIt<LocalizationService>().localizations.task_status_open;
      case TodoStatus.done:
        return getIt<LocalizationService>().localizations.task_status_done;
      case TodoStatus.deferred:
        return getIt<LocalizationService>().localizations.task_status_deferred;
    }
  }

  Color get color {
    switch (this) {
      case TodoStatus.open:
        return Colors.blueAccent;
      case TodoStatus.done:
        return Colors.green;
      case TodoStatus.deferred:
        return Colors.orange;
    }
  }

  static TodoStatus fromName(String? name) {
    return TodoStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TodoStatus.open,
    );
  }
}
