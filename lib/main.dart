import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_doing/Controller/screen_state_controller.dart';
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_doing/Models/theme_data_model.dart';
import 'package:flutter_doing/Screens/adaptive_main_screen.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Services/notification_service.dart';
import 'package:flutter_doing/Services/shared_preferences_service.dart';
import 'package:flutter_doing/Services/system_tray_service.dart';
import 'package:flutter_doing/Services/window_bootstrap.dart';
import 'package:flutter_doing/Services/window_service.dart';
import 'package:flutter_doing/Widgets/AppBars/animated_title_bar.dart';
import 'package:flutter_doing/Widgets/AppBars/animated_title_bar_mac.dart';
import 'package:flutter_doing/l10n/generated/intl_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

late final ProviderContainer container;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load settings
  await SharedPreferencesService.instance.init();
  final settings = await SharedPreferencesService.instance.loadSettings();

  final packageInfo = await PackageInfo.fromPlatform();
  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  final controller = await WindowController.fromCurrentEngine();
  final isSubWindow = controller.arguments.isNotEmpty;

  await NotificationService.instance.init();

  if (isSubWindow) {
    await WindowBootstrap.initialize(controller, settings);
    return;
  }

  // ---------------------------------------------------------------------
  // MAIN WINDOW ONLY, from here on
  // ---------------------------------------------------------------------
  await windowManager.ensureInitialized();

  container = ProviderContainer();
  WindowService.instance.attachContainer(container);

  await _syncLaunchAtStartup(settings.startWithWindows);
  await windowManager.setAlwaysOnTop(settings.alwaysOnTop);

  runApp(UncontrolledProviderScope(container: container, child: MyHomePage()));

  await container.read(settingsProvider.notifier).init();
}

Future<void> _syncLaunchAtStartup(bool shouldStartWithWindows) async {
  try {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final launchAgentsDir = Directory('$home/Library/LaunchAgents');
        if (!await launchAgentsDir.exists()) {
          await launchAgentsDir.create(recursive: true);
        }
      }
    }

    final isEnabled = await LaunchAtStartup.instance.isEnabled();
    if (shouldStartWithWindows && !isEnabled) {
      await LaunchAtStartup.instance.enable();
    } else if (!shouldStartWithWindows && isEnabled) {
      await LaunchAtStartup.instance.disable();
    }
  } catch (e) {
    // Launch-at-startup is a nice-to-have, not core functionality — a
    // failure here (missing directory, permissions, sandbox quirks)
    // should never be allowed to crash the whole app at startup.
    coloredLog("[MAIN] Failed to sync launch-at-startup: $e", color: 'red');
  }
}

Future<void> applyWindowSettings(
  Settings settings,
  ScreenState windowState,
) async {
  coloredLog("[MAIN] Authenticated window state = $windowState", color: 'red');

  // Hide first — the resize/frameless switch below should happen off-screen,
  // not while the previous (login) window is still visibly showing.
  await windowManager.hide();
  await windowManager.setMinimumSize(const Size(0, 0));
  await windowManager.setMaximumSize(const Size(10000, 10000));
  await windowManager.setAsFrameless();

  switch (windowState) {
    case ScreenState.compact:
      await setCompactWindow();
    case ScreenState.classic:
    case ScreenState.withSorting:
      await setClassicWindow(settings);
    case ScreenState.edit:
      await setEditWindow();
    case ScreenState.settings:
      break;
    case ScreenState.layout:
      await setLayoutWindow();
      break;
  }

  switch (settings.launchMode) {
    case LaunchMode.normal:
      await windowManager.show();
      await windowManager.focus();
      coloredLog("[MAIN] Launching visible", color: 'magenta');
    case LaunchMode.minimized:
      // Minimizing an already-hidden window reveals it directly in the
      // minimized/taskbar state — no visible "normal" frame in between.
      await windowManager.minimize();
      coloredLog(
        "[MAIN] Launching minimized (taskbar icon present)",
        color: 'magenta',
      );
    case LaunchMode.backgrounded:
      // Already hidden above — nothing further to do. No taskbar icon.
      coloredLog(
        "[MAIN] Launching backgrounded (no taskbar icon)",
        color: 'magenta',
      );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with WidgetsBindingObserver {
  bool _ready = false;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _bootstrap();

    // Window configuration is deferred until after the first frame has
    // painted — doing this any earlier corrupts the render surface on
    // Windows. This is the ONLY place cold-start window setup happens.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _applyInitialWindowState(),
    );
  }

  Future<void> _bootstrap() async {
    await _initLocalizations(); // must finish first — tray menu needs real strings
    await _initTray();
  }

  Future<void> _initLocalizations() async {
    final settings = await SharedPreferencesService.instance.loadSettings();
    await setupLocalizationService(preferredLanguage: settings.language.name);
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _initTray() async {
    await SystemTraySetup.initialize();
  }

  Future<void> _applyInitialWindowState() async {
    coloredLog(
      "[MAIN] Applying initial window state (post-first-frame)",
      color: 'magenta',
    );

    final settings = await SharedPreferencesService.instance.loadSettings();
    if (settings.openedBefore) {
      final windowState = await SharedPreferencesService.instance
          .loadAppScreenState();
      await applyWindowSettings(settings, windowState);
    } else {
      await applyWindowSettings(settings, ScreenState.layout);
    }
  }

  ThemeData _resolveThemeData(Settings settings) {
    switch (settings.theme) {
      case Theme.dark:
        return AppTheme.dark;
      case Theme.light:
        return AppTheme.light;
      case Theme.system:
        final isDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        return isDark ? AppTheme.dark : AppTheme.light;
    }
  }

  /// Reacts to settings changes that need side effects beyond just
  /// updating what's shown on screen (language, startup, always-on-top).
  void _handleSettingsChange(Settings? previous, Settings next) {
    if (!_ready || previous == null) return;

    coloredLog("[MAIN] Handling settings change.", color: 'yellow');

    if (previous.language != next.language) {
      _applyLanguageChange(next.language.name);
    }
    if (previous.startWithWindows != next.startWithWindows) {
      _syncLaunchAtStartup(next.startWithWindows);
    }
    if (previous.alwaysOnTop != next.alwaysOnTop) {
      windowManager.setAlwaysOnTop(next.alwaysOnTop);
    }
  }

  Future<void> _applyLanguageChange(String languageCode) async {
    coloredLog("[MAIN] Language changed -> $languageCode", color: 'magenta');
    await getIt<LocalizationService>().updateLocale(Locale(languageCode));
    await SystemTraySetup.rebuildMenu();

    if (mounted) setState(() {}); // rebuild subtree with new locale
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final themeData = _resolveThemeData(settings);

    ref.listen<Settings>(
      settingsProvider,
      (previous, next) => _handleSettingsChange(previous, next),
    );

    return MaterialApp(
      theme: themeData,
      themeMode: settings.theme == Theme.system
          ? ThemeMode.system
          : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: "Doing",
      locale: _ready ? getIt<LocalizationService>().currentLocale : _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: !_ready
            ? const SizedBox.shrink()
            : Platform.isWindows
            ? AnimatedTitleBar(title: " ", child: AdaptiveMainScreen())
            : AnimatedTitleBarMac(title: " ", child: AdaptiveMainScreen()),
      ),
    );
  }
}
