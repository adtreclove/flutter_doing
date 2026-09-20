import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

final screenStateProvider =
    AsyncNotifierProvider<ScreenStateNotifier, ScreenState>(
      ScreenStateNotifier.new,
    );

class ScreenStateNotifier extends AsyncNotifier<ScreenState> {
  @override
  Future<ScreenState> build() async {
    final settings = ref.watch(settingsProvider);

    coloredLog("[APP SCREEN STATE PROV] Inside build", color: 'red');

    // Onboarding not finished — ALWAYS layout, regardless of what
    // layoutStyle happens to be set to. This must be checked first, since
    // build() reruns on every settingsProvider change (theme, language,
    // etc.), not just layoutStyle changes — without this check, any
    // unrelated settings change silently kicks the user out of onboarding.

    final ScreenState currentState;
    if (!settings.openedBefore) {
      currentState = ScreenState.layout;
    } else {
      currentState = ScreenState.values.firstWhere(
        (appState) => appState.label == settings.layoutStyle,
        orElse: () => ScreenState.classic,
      );
    }

    final size = _resolveWindowSize(currentState, settings);
    await windowManager.setMinimumSize(size);
    await windowManager.setMaximumSize(size);

    return currentState;
  }

  Future<void> changeState(ScreenState newState, Settings settings) async {
    state = AsyncValue.data(newState);

    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    }
    await windowManager.setMinimumSize(const Size(0, 0));
    await windowManager.setMaximumSize(const Size(10000, 10000));
    final settings = ref.read(settingsProvider);

    await _applyWindowConfiguration(newState, settings);

    final size = _resolveWindowSize(newState, settings);

    await windowManager.setMinimumSize(size);
    await windowManager.setMaximumSize(size);
  }

  Future<void> _applyWindowConfiguration(
    ScreenState newState,
    Settings settings,
  ) async {
    switch (newState) {
      case ScreenState.compact:
        await setCompactWindow();
        break;
      case ScreenState.classic:
      case ScreenState.withSorting:
        await setClassicWindow(settings);
        break;
      case ScreenState.edit:
        await setEditWindow();
        break;
      case ScreenState.settings:
        break;
      case ScreenState.layout:
        await setLayoutWindow();
        break;
    }
  }
}

/// Computes the actual target window size for a given screen state,
/// accounting for settings that affect size within a state (currently
/// just showKPI). Used both when locking bounds in build() and when
/// actually resizing in changeState(), so the two never disagree.
///

Size _resolveWindowSize(ScreenState state, Settings settings) {
  switch (state) {
    case ScreenState.compact:
      return ScreenState.compact.windowSize;
    case ScreenState.classic:
    case ScreenState.withSorting:
      return settings.showSorting
          ? ScreenState.withSorting.windowSize
          : ScreenState.classic.windowSize;
    case ScreenState.edit:
    case ScreenState.settings:
      return ScreenState.settings.windowSize;
    case ScreenState.layout:
      return ScreenState.layout.windowSize;
  }
}
// have to be outside of provider bc we need it in main

Future<void> setCompactWindow() async {
  coloredLog("[SCREEN STATE PROV] Setting compact window size", color: 'red');
  await windowManager.setBackgroundColor(Colors.transparent);
  //await windowManager.setAsFrameless();
  await windowManager.setSize(ScreenState.compact.windowSize, animate: true);
}

Future<void> setClassicWindow(Settings settings) async {
  coloredLog("[SCREEN STATE PROV] Setting normal window size", color: 'red');
  final size = settings.showSorting
      ? ScreenState.withSorting.windowSize
      : ScreenState.classic.windowSize;

  coloredLog(
    "[SCREEN STATE PROV] Showing KPI: ${settings.showSorting}. Window size = $size",
    color: 'red',
  );

  await windowManager.setBackgroundColor(Colors.transparent);
  // await windowManager.setAsFrameless();
  await windowManager.setSize(size, animate: false);
}

Future<void> setEditWindow() async {
  coloredLog("[SCREEN STATE PROV] Setting project window size", color: 'red');
  await windowManager.setSize(ScreenState.edit.windowSize, animate: false);
}

Future<void> setLayoutWindow() async {
  await windowManager.setBackgroundColor(Colors.white);
  // await windowManager.setAsFrameless();
  await windowManager.setSize(ScreenState.layout.windowSize, animate: false);
}
