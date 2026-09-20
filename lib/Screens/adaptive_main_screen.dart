import 'package:flutter/material.dart';
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/settings_model.dart' hide Theme;
import 'package:flutter_doing/Screens/classic_view.dart';
import 'package:flutter_doing/Screens/compact_view.dart';
import 'package:flutter_doing/Screens/edit_view.dart';
import 'package:flutter_doing/Screens/layout_screen.dart';
import 'package:flutter_doing/Services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handles the different layouts
class AdaptiveMainScreen extends ConsumerStatefulWidget {
  const AdaptiveMainScreen({super.key});

  @override
  ConsumerState<AdaptiveMainScreen> createState() => _AdaptiveMainScreenState();
}

class _AdaptiveMainScreenState extends ConsumerState<AdaptiveMainScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(settingsProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenStateAsync = ref.watch(screenStateProvider);

    ref.listen<Settings>(settingsProvider, (previous, next) async {
      if (previous == null) return;

      if (previous.showSorting != next.showSorting) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handleShowKPIChange(next),
        );
      }

      if (previous.layoutStyle != next.layoutStyle) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handleLayoutStyleChange(next),
        );
      }

      if (previous.openedBefore != next.openedBefore) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handleOnboardingFinished(next),
        );
      }
    });

    Color? scaffoldColor = Colors.transparent;

    if (screenStateAsync.value == ScreenState.edit) {
      scaffoldColor = null;
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Stack(
        children: [
          SizedBox.expand(
            child: screenStateAsync.when(
              skipError: true,
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                coloredLog(
                  "[ADAPTIVE MAIN SCREEN] Failed to load screen state: $err",
                  color: 'red',
                );
                // fall back to classic on error
                return ClassicView(key: ValueKey('classic'));
              },
              data: (screenState) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (screenState) {
                    ScreenState.compact => CompactView(
                      key: ValueKey(screenState.label),
                    ),
                    ScreenState.classic => ClassicView(
                      key: ValueKey(screenState.label),
                    ),
                    ScreenState.edit => EditView(
                      key: ValueKey(screenState.label),
                    ),
                    ScreenState.layout => LayoutScreen(
                      key: ValueKey(screenState.label),
                    ),

                    ScreenState.withSorting => null,
                    ScreenState.settings => null,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // everything related to authenticated windows / resizing / layout is handled here
  Future<void> _handleShowKPIChange(Settings settings) async {
    final appScreenState = ref.read(screenStateProvider).value;
    if (appScreenState == ScreenState.classic ||
        appScreenState == ScreenState.withSorting) {
      coloredLog("[MAIN] showKPI changed — resizing window", color: 'magenta');
      await ref
          .read(screenStateProvider.notifier)
          .changeState(appScreenState!, settings);
    }
  }

  Future<void> _handleOnboardingFinished(Settings settings) async {
    final appState = await SharedPreferencesService.instance
        .loadAppScreenState();

    await ref
        .read(screenStateProvider.notifier)
        .changeState(appState, settings);
  }

  Future<void> _handleLayoutStyleChange(Settings settings) async {
    final newState = ScreenState.values.firstWhere(
      (s) => s.label == settings.layoutStyle,
      orElse: () => ScreenState.classic,
    );
    coloredLog(
      "[ADAPTIVE MAIN SCREEN] layoutStyle changed — resizing",
      color: 'magenta',
    );
    await ref
        .read(screenStateProvider.notifier)
        .changeState(newState, settings);
  }
}
