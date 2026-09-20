import 'dart:io';

import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Services/window_service.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemTraySetup extends TrayListener {
  static Future<void> initialize() async {
    // windows = .ico, Mac = .png

    if (Platform.isWindows) {
      await trayManager.setIcon("assets/doing.ico");
    } else if (Platform.isMacOS) {
      await trayManager.setIcon("assets/doing-1024.png", isTemplate: true);
    }

    if (Platform.isWindows) {
      await trayManager.setToolTip("doing");
    }

    await _buildTrayMenu();
  }

  static Future<void> rebuildMenu() async {
    await _buildTrayMenu();
  }

  static Future<void> _buildTrayMenu() async {
    final List<MenuItem> items = [
      MenuItem(
        key: 'settings',
        label: getIt<LocalizationService>().localizations.tray_settings,
      ),

      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: Platform.isWindows
            ? getIt<LocalizationService>().localizations.tray_close_app_windows
            : getIt<LocalizationService>()
                  .localizations
                  .tray_close_app_mac, // Platform-specific terminology
      ),
    ];

    await trayManager.setContextMenu(Menu(items: items));
    trayManager.addListener(SystemTraySetup());
    coloredLog("[TRAY MANAGER] finished building tray menu", color: 'green');
  }

  @override
  void onTrayIconMouseDown() async {
    coloredLog("[TRAY MANAGER] Clicked with  mouse down", color: 'green');
    // Show window on tray icon click (Windows behavior)
    if (Platform.isWindows) {
      windowManager.show();
    }

    if (Platform.isMacOS) {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() async {
    coloredLog("[TRAY MANAGER] Clicked with right mouse down", color: 'green');
    // Show context menu on right-click (cross-platform)
    // need to focus the window to prevent the bug in tray manager! - important!
    await windowManager.focus();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'settings':
        await WindowService.instance.openSettingsWindow();
        break;

      case 'exit':
        await trayManager.destroy();
        await windowManager.destroy();
        break;
    }
  }
}
