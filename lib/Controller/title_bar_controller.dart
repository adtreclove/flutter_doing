import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleBarState {
  final bool isHovered;
  final bool isMaximized;

  const TitleBarState({this.isHovered = false, this.isMaximized = false});

  TitleBarState copyWith({bool? isHovered, bool? isMaximized}) {
    return TitleBarState(
      isHovered: isHovered ?? this.isHovered,
      isMaximized: isMaximized ?? this.isMaximized,
    );
  }
}

class TitleBarNotifier extends StateNotifier<TitleBarState> {
  TitleBarNotifier() : super(const TitleBarState());

  Timer? _exitTimer;
  bool _resizeLocked = false;

  static const _exitDelay = Duration(milliseconds: 220);
  static const _resizeCooldown = Duration(milliseconds: 300);

  /// MouseRegion.onEnter
  void hoverEnter() {
    _exitTimer?.cancel();
    _exitTimer = null;

    if (_resizeLocked) return;
    if (!state.isHovered) {
      state = state.copyWith(isHovered: true);
    }
  }

  /// MouseRegion.onExit
  void hoverExit() {
    _exitTimer?.cancel();
    _exitTimer = Timer(_exitDelay, () {
      if (_resizeLocked) return;
      if (state.isHovered) {
        state = state.copyWith(isHovered: false);
      }
    });
  }

  void setMaximized(bool value) => state = state.copyWith(isMaximized: value);

  /// Call before window resize
  void beginResizeLock() {
    _resizeLocked = true;
  }

  /// call after window resize: unlocks after cooldown, for OS to puffer

  void endResizeLock() {
    Timer(_resizeCooldown, () => _resizeLocked = false);
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }
}

final titleBarProvider = StateNotifierProvider<TitleBarNotifier, TitleBarState>(
  (ref) => TitleBarNotifier(),
);
