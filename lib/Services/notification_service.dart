import 'dart:io';

import 'package:flutter_desktop_notifications/flutter_desktop_notifications.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Services/shared_preferences_service.dart';

/// Wraps DesktopNotifier and gates every notification behind the user's
/// `allowNotifications` setting, re-checked fresh on every call — so a
/// setting change (from this window or another) takes effect immediately,
/// without needing to re-init this service.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();
  static const _aumid = 'com.doing.app';
  static const _displayName = 'Doing';

  final DesktopNotifier _notifier = DesktopNotifier(
    appName: 'doing',
    appId: _aumid,
  );

  bool _permissionGranted = false;
  String? _lastNotificationId;

  /// Call once at app start (e.g. in main() after SharedPreferencesService
  /// is initialized). Registers the activation/dismissal callback.
  /// Does NOT request permission yet — that only happens lazily the first
  /// time a notification is actually shown while the setting is enabled,
  /// to avoid prompting the user (macOS) for a permission they may never
  /// need if they keep notifications turned off.
  Future<void> init() async {
    coloredLog(
      "[NOTIFICATION SERVICE] Initializing notification service",
      color: 'magenta',
    );

    if (Platform.isWindows) {
      await WindowsNotification.registerAumid(
        aumid: _aumid,
        displayName: _displayName,
      );
      coloredLog(
        "[NOTIFICATION SERVICE] AUMID registered: $_aumid",
        color: 'magenta',
      );
    }

    await _notifier.setCallback((details) {
      switch (details.event) {
        case NotificationEvent.activated:
          coloredLog(
            "[NOTIFICATION SERVICE] Notification activated: ${details.arguments}",
            color: 'magenta',
          );
          break;
        case NotificationEvent.dismissedByUser:
        case NotificationEvent.dismissedByApp:
        case NotificationEvent.dismissedByTimeout:
          coloredLog(
            "[NOTIFICATION SERVICE] Notification dismissed: ${details.event}",
            color: 'magenta',
          );
          break;
      }
    });
  }

  Future<bool> _notificationsAllowed() async {
    final settings = await SharedPreferencesService.instance.loadSettings();
    return settings.allowNotifications;
  }

  Future<bool> _ensurePermission() async {
    if (_permissionGranted) return true;

    _permissionGranted = await _notifier.requestPermission();
    coloredLog(
      "[NOTIFICATION SERVICE] Permission granted: $_permissionGranted",
      color: 'magenta',
    );
    return _permissionGranted;
  }

  Future<bool> showNotification(
    String title,
    String body, {
    List<NotificationAction> actions = const [],
    List<NotificationInput> inputs = const [],
  }) async {
    if (!await _notificationsAllowed()) {
      coloredLog(
        "[NOTIFICATION SERVICE] Skipped — notifications disabled in settings",
        color: 'yellow',
      );
      return false;
    }

    if (!await _ensurePermission()) {
      coloredLog(
        "[NOTIFICATION SERVICE] Skipped — OS permission not granted",
        color: 'yellow',
      );
      return false;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _notifier.show(
        NotificationMessage.fromPluginTemplate(
          id,
          title,
          body,
          actions: actions,
          inputs: inputs,
        ),
      );
      _lastNotificationId = id;
      return true;
    } catch (e) {
      coloredLog(
        "[NOTIFICATION SERVICE] Failed to show notification: $e",
        color: 'red',
      );
      return false;
    }
  }

  Future<bool> showSimpleNotification(String title, String body) {
    coloredLog(
      "[NOTIFICATION SERVICE] Showing simple notification",
      color: 'green',
    );
    return showNotification(
      title,
      body,
      actions: const [
        NotificationAction(content: 'Open', arguments: 'action:open'),
      ],
    );
  }

  Future<void> removeLatestNotification() async {
    final id = _lastNotificationId;
    if (id == null) return;
    await _notifier.cancel(id);
    _lastNotificationId = null;
  }

  Future<void> removeAllNotifications() async {
    await _notifier.cancelAll();
    _lastNotificationId = null;
  }
}
