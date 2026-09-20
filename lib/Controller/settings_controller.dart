import 'dart:async';

import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_doing/Services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the Desktop Settings & syncs them with shared preferences
// The provider communicates with the UI instead of making the UI directly depending from shared preferences
class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  Timer? _pollTimer;
  static const _fastInterval = Duration(milliseconds: 500);
  static const _slowInterval = Duration(minutes: 5);

  Future<void> init() async {
    state = await SharedPreferencesService.instance.loadSettings();
  }

  /// Starts (or restarts) polling at [interval]. Call when the settings
  /// window opens, or anytime you want to react to changes quickly.
  void startPolling({Duration interval = _fastInterval}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => _refresh());
    coloredLog(
      "[SETTINGS PROV] Polling started (${interval.inMilliseconds}ms)",
      color: 'cyan',
    );
  }

  /// Slows polling down instead of stopping outright — still catches rare
  /// external changes, at a much lower cost.
  void slowPolling({Duration interval = _slowInterval}) {
    startPolling(interval: interval);
  }

  /// Stops polling entirely.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    coloredLog("[SETTINGS PROV] Polling stopped", color: 'cyan');
  }

  Future<void> _refresh() async {
    final onDisk = await SharedPreferencesService.instance.tryLoadSettings();
    if (onDisk == null) return;
    if (onDisk.toJsonString() != state.toJsonString()) {
      state = onDisk;
    }
  }

  Future<void> saveSettings(Settings settings) async {
    state = settings;
    await SharedPreferencesService.instance.saveSettings(settings);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((
  ref,
) {
  return SettingsNotifier();
});
