import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/window_type_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WindowService {
  WindowService._();
  static final WindowService instance = WindowService._();

  final Map<String, WindowController> _controllers = {};
  String? _settingsWindowId;
  bool _openingSettings = false;
  ProviderContainer? _container;
  StreamSubscription<void>? _windowsSubscription;

  /// Call once from main() right after creating the ProviderContainer.
  void attachContainer(ProviderContainer container) {
    _container = container;
  }

  /// Opens the settings window, or focuses the existing one if it's already
  /// open — call this from the tray menu / anywhere settings can be
  /// triggered from, instead of calling createWindow directly, to prevent
  /// duplicate settings windows from rapid/double clicks.
  Future<void> openSettingsWindow() async {
    if (_openingSettings) return;
    _openingSettings = true;
    try {
      if (_settingsWindowId != null) {
        final stillOpen = await _isWindowStillOpen(_settingsWindowId!);
        if (stillOpen) {
          coloredLog(
            "[WINDOW SERVICE] Settings window already open — focusing it",
            color: 'cyan',
          );
          final controller = _controllers[_settingsWindowId!];
          await controller?.show();

          return;
        }
        _settingsWindowId = null;
      }

      final controller = await createWindow(
        type: AppWindowType.settings,
        arguments: {
          'type': 'settings',
        }, // must match what WindowBootstrap expects
      );
      await showWindow(controller.windowId);
    } finally {
      _openingSettings = false;
    }
  }

  Future<bool> _isWindowStillOpen(String windowId) async {
    final openControllers = await WindowController.getAll();
    return openControllers.any((c) => c.windowId == windowId);
  }

  Future<WindowController> createWindow({
    required AppWindowType type,
    Map<String, dynamic> arguments = const {},
  }) async {
    final payload = {'type': type.name, 'arguments': arguments};
    final controller = await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: false,
        arguments: jsonEncode(payload),
      ),
    );
    _controllers[controller.windowId] = controller;

    if (type == AppWindowType.settings) {
      _settingsWindowId = controller.windowId;
      _container?.read(settingsProvider.notifier).startPolling();
      _watchWindowsList();
      coloredLog(
        "[WINDOW SERVICE] Settings window opened (${controller.windowId}), fast polling started",
        color: 'cyan',
      );
    }

    return controller;
  }

  void _watchWindowsList() {
    if (_windowsSubscription != null) return; // avoid stacking subscriptions
    _windowsSubscription = onWindowsChanged.listen(
      (_) => _handleWindowsChanged(),
    );
  }

  Future<void> _handleWindowsChanged() async {
    if (_settingsWindowId == null) return;

    final openControllers = await WindowController.getAll();
    final stillOpen = openControllers.any(
      (c) => c.windowId == _settingsWindowId,
    );

    if (!stillOpen) {
      coloredLog(
        "[WINDOW SERVICE] Settings window closed, slowing polling",
        color: 'cyan',
      );
      _controllers.remove(_settingsWindowId);
      _settingsWindowId = null;

      await _windowsSubscription?.cancel();
      _windowsSubscription = null;

      // one last refresh to catch the final save, then back off
      _container?.read(settingsProvider.notifier).slowPolling();
    }
  }

  Future<void> showWindow(String windowId) async {
    final controller = _controllers[windowId];
    if (controller == null) return;
    await controller.show();
  }

  Future<void> hideWindow(String windowId) async {
    final controller = _controllers[windowId];
    if (controller == null) return;
    await controller.hide();
  }
}
