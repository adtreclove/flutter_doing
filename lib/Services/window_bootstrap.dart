import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_doing/Screens/settings_screen.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WindowBootstrap {
  static Future<void> initialize(
    WindowController controller,
    Settings settings,
  ) async {
    if (controller.arguments.trim().isEmpty) {
      coloredLog('[WINDOW BOOTSTRAP] Running main app', color: 'green');
      runApp(MyHomePage());
      return;
    }

    final Map<String, dynamic> data;

    try {
      data = jsonDecode(controller.arguments) as Map<String, dynamic>;
    } catch (e) {
      coloredLog(
        '[WINDOW BOOTSTRAP] Invalid window arguments: '
        '${controller.arguments}',
        color: 'red',
      );

      runApp(MyHomePage());
      return;
    }

    final type = data['type'];

    switch (type) {
      case 'settings':
        await setupLocalizationService(
          preferredLanguage: settings.language.name,
        );
        runApp(ProviderScope(child: SettingsPage(settings: settings)));
        break;
    }
  }
}
