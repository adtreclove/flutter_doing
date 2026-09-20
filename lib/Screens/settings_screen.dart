import 'dart:io';

import 'package:flutter/material.dart' hide Theme, ThemeMode;
import 'package:flutter/material.dart' as material show Theme;
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/screen_state_model.dart';
import 'package:flutter_doing/Models/settings_model.dart';
import 'package:flutter_doing/Models/theme_data_model.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_mac.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_windows.dart';
import 'package:flutter_doing/Widgets/window_layout_preview.dart';
import 'package:flutter_doing/l10n/generated/intl_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

class DropdownItem {
  final String key; // stable, language-independent
  final String label; // localized display text
  const DropdownItem(this.key, this.label);
}

class SettingsPage extends ConsumerStatefulWidget {
  final Settings settings;
  const SettingsPage({super.key, required this.settings});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late ThemeData themeData;
  String version = '…'; // placeholder shown until PackageInfo resolves
  late final String platform = Platform.operatingSystem;

  @override
  void initState() {
    super.initState();
    // ref.read(settingsProvider.notifier).init();
    themeData = _resolveTheme(widget.settings.theme);
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyWindowConfig());
  }

  Future<void> _applyWindowConfig() async {
    await windowManager.ensureInitialized();
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    }
    await windowManager.setMinimumSize(const Size(0, 0));
    await windowManager.setMaximumSize(const Size(10000, 10000));

    await windowManager.setSize(
      ScreenState.settings.windowSize,
      animate: false,
    );
    await windowManager.setAsFrameless();
    await windowManager.setMinimumSize(ScreenState.settings.windowSize);
    await windowManager.setMaximumSize(ScreenState.settings.windowSize);
  }

  ThemeData _resolveTheme(Theme theme) {
    switch (theme) {
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

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      locale: getIt<LocalizationService>().currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = material.Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                Platform.isMacOS
                    ? SettingsTitleBarMac(
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_title,
                      )
                    : SettingsTitleBarWindows(
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_title,
                      ),
                // Header
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 24,
                        color: theme.iconTheme.color,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        getIt<LocalizationService>()
                            .localizations
                            .settings_title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    children: [
                      _buildSection(
                        theme: theme,
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_appearance_title,
                        icon: Icons.palette_outlined,
                        children: [
                          _buildLayoutSelector(theme),
                          _buildDropdown(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_theme_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_theme_subtitle,
                            value: widget.settings.theme.name,
                            items: [
                              DropdownItem(
                                'dark',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_theme_dark,
                              ),
                              DropdownItem(
                                'light',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_theme_light,
                              ),
                              DropdownItem(
                                'system',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_theme_system,
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;

                              final selectedTheme = Theme.values.firstWhere(
                                (theme) => theme.name == value,
                              );

                              coloredLog(
                                "[SETTINGS PAGE] Selected Theme = $selectedTheme",
                                color: 'magenta',
                              );
                              setState(() {
                                widget.settings.theme = selectedTheme;
                                themeData = _resolveTheme(selectedTheme);
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),
                          _buildSwitch(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_show_sorting_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_show_sorting_subtitle,

                            value: widget.settings.showSorting,
                            onChanged: (value) async {
                              setState(() {
                                widget.settings.showSorting = value;
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSection(
                        theme: theme,
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_startup,
                        icon: Icons.power_settings_new_outlined,
                        children: [
                          _buildSwitch(
                            theme: theme,
                            title: Platform.isWindows
                                ? getIt<LocalizationService>()
                                      .localizations
                                      .settings_startup_title_windows
                                : getIt<LocalizationService>()
                                      .localizations
                                      .settings_startup_title_mac,
                            subtitle: Platform.isWindows
                                ? getIt<LocalizationService>()
                                      .localizations
                                      .settings_startup_subtitle_windows
                                : getIt<LocalizationService>()
                                      .localizations
                                      .settings_startup_subtitle_mac,
                            value: widget.settings.startWithWindows,
                            onChanged: (value) async {
                              setState(() {
                                widget.settings.startWithWindows = value;
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),

                          _buildSwitch(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_alwaysOnTopTitle,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_alwaysOnTopSubtitle,
                            value: widget.settings.alwaysOnTop,
                            onChanged: (value) async {
                              setState(() {
                                widget.settings.alwaysOnTop = value;
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),

                          // LAUNCH MODE DROPDOWN
                          _buildDropdown(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_launch_mode_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_launch_mode_subutitle,
                            value: widget.settings.launchMode.name,
                            items: [
                              DropdownItem(
                                'normal',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_launch_mode_normal,
                              ),
                              DropdownItem(
                                'minimized',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_launch_mode_minimized,
                              ),
                              DropdownItem(
                                'backgrounded',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_launch_mode_background,
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;

                              setState(() {
                                final selectedMode = LaunchMode.values
                                    .firstWhere((mode) => mode.name == value);
                                widget.settings.launchMode = selectedMode;
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSection(
                        theme: theme,
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_notification,
                        icon: Icons.notifications_outlined,
                        children: [
                          _buildSwitch(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_notification_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_notification_subtitle,
                            value: widget.settings.allowNotifications,
                            onChanged: (value) async {
                              setState(() {
                                widget.settings.allowNotifications = value;
                              });

                              ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSection(
                        theme: theme,
                        title: getIt<LocalizationService>()
                            .localizations
                            .settings_about,
                        icon: Icons.info_outline,
                        children: [
                          _buildInfoRow(theme, 'Version', version),
                          _buildInfoRow(theme, 'Platform', platform),
                          _buildDropdown(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_language_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_language_subtitle,
                            value: widget.settings.language.name,
                            items: [
                              DropdownItem(
                                'de',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_language_german,
                              ),
                              DropdownItem(
                                'en',
                                getIt<LocalizationService>()
                                    .localizations
                                    .settings_language_english,
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;

                              await getIt<LocalizationService>().updateLocale(
                                Locale(value),
                              );

                              setState(() {
                                final selectedLang = Language.values.firstWhere(
                                  (lang) => lang.name == value,
                                );
                                widget.settings.language = selectedLang;
                              });

                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(widget.settings);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.iconTheme.color),
            const SizedBox(width: 9),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final enabled = onChanged != null;
    final titleColor = enabled
        ? theme.textTheme.bodyLarge?.color
        : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.4);
    final subtitleColor = enabled
        ? theme.textTheme.bodyMedium?.color
        : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: titleColor)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String value, // stable key, e.g. "light" / "dark" / "system"
    required List<DropdownItem> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Guard: if the stored key somehow doesn't match any known item
    // (corrupted data, renamed key, etc.), fall back to the first
    // item instead of letting DropdownButton assert/crash.
    final hasMatch = items.any((item) => item.key == value);
    final safeValue = hasMatch ? value : items.first.key;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 3),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: safeValue,
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surfaceContainerHighest,
            style: theme.textTheme.bodyLarge,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item.key,
                    child: Text(item.label),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getIt<LocalizationService>().localizations.settings_layout,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            getIt<LocalizationService>().localizations.settings_subtitle,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // WITH NAME
              Expanded(
                child: _buildLayoutOption(
                  theme: theme,
                  value: 'classic',
                  title: getIt<LocalizationService>()
                      .localizations
                      .settings_layout_classic,
                  image: 'assets/Logo-w-Telematics-print-logo-only.png',
                ),
              ),
              const SizedBox(width: 12),
              // ONLY TIMER
              Expanded(
                child: _buildLayoutOption(
                  theme: theme,
                  value: 'compact',
                  title: getIt<LocalizationService>()
                      .localizations
                      .settings_layout_compact,
                  image: 'assets/Logo-w-Telematics-print-logo-only.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutOption({
    required ThemeData theme,
    required String value,
    required String title,
    required String image,
  }) {
    final bool selected = widget.settings.layoutStyle == value;
    final accent = theme.colorScheme.primary;

    Future<void> selectLayout(String newValue) async {
      setState(() {
        widget.settings.layoutStyle = newValue;
      });

      await ref.read(settingsProvider.notifier).saveSettings(widget.settings);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => selectLayout(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.08)
              : accent.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.35)
                : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutPreview(style: value, theme: theme),
              ),
            ),

            const SizedBox(height: 8),

            // Radio + title
            Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: widget.settings.layoutStyle,
                  onChanged: (v) {
                    if (v != null) selectLayout(v);
                  },
                ),
                Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
