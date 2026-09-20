import 'dart:io';

import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_doing/Controller/settings_controller.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/Models/settings_model.dart' show Theme, Language;
import 'package:flutter_doing/Models/theme_data_model.dart';
import 'package:flutter_doing/Screens/settings_screen.dart';
import 'package:flutter_doing/Services/localization_service.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_mac.dart';
import 'package:flutter_doing/Widgets/AppBars/settings_title_bar_windows.dart';
import 'package:flutter_doing/Widgets/window_layout_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Theme, ThemeMode;

class LayoutScreen extends ConsumerStatefulWidget {
  const LayoutScreen({super.key});

  @override
  ConsumerState<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends ConsumerState<LayoutScreen> {
  late ThemeData themeData;

  // Local working copy of the layout choice — deliberately NOT written to
  // settingsProvider on every tap. Unlike theme/language (which take effect
  // immediately, since the user is previewing them live on the actual
  // window)
  String? _selectedLayoutStyle;

  @override
  Widget build(BuildContext context) {
    coloredLog("[LAYOUT SCREEN] building layout screen.. ", color: 'white');
    final settings = ref.watch(settingsProvider);
    final theme = _resolveTheme(settings.theme);

    // Seed the local selection from the persisted value exactly once. After
    // that, this field is the source of truth for what's shown selected
    _selectedLayoutStyle ??= settings.layoutStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight <= 700) {
          return SizedBox.shrink();
        } else {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                Platform.isMacOS
                    ? SettingsTitleBarMac(
                        title:
                            "DOING - ${getIt<LocalizationService>().localizations.layout_screen_title}",
                      )
                    : SettingsTitleBarWindows(
                        title:
                            "DOING - ${getIt<LocalizationService>().localizations.layout_screen_title}",
                      ),
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
                      Text(
                        getIt<LocalizationService>()
                            .localizations
                            .layout_screen_preferences,
                        style: theme.textTheme.titleLarge,
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton(
                          child: Row(
                            children: [
                              Text(
                                getIt<LocalizationService>()
                                    .localizations
                                    .layout_screen_finish_btn,
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                          onPressed: () async {
                            final updatedSettings = settings.copyWith(
                              openedBefore: true,
                              layoutStyle: _selectedLayoutStyle,
                            );

                            await ref
                                .read(settingsProvider.notifier)
                                .saveSettings(updatedSettings);
                          },
                        ),
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
                            .layout_screen_section_layout_title,
                        icon: Icons.info,

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
                            value: settings.theme.name,
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
                              // Theme changes immediately — it's a live
                              // preview on the actual window, unlike layout.
                              final updatedSettings = settings.copyWith(
                                theme: selectedTheme,
                              );
                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(updatedSettings);
                            },
                          ),
                          _buildDropdown(
                            theme: theme,
                            title: getIt<LocalizationService>()
                                .localizations
                                .settings_language_title,
                            subtitle: getIt<LocalizationService>()
                                .localizations
                                .settings_language_subtitle,
                            value: settings.language.name,
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

                              final selectedLang = Language.values.firstWhere(
                                (lang) => lang.name == value,
                              );
                              // Language changes immediately too, same
                              // reason as theme.
                              final updated = settings.copyWith(
                                language: selectedLang,
                              );
                              await ref
                                  .read(settingsProvider.notifier)
                                  .saveSettings(updated);
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
        }
      },
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
  }) {
    final bool selected = _selectedLayoutStyle == value;
    final accent = theme.colorScheme.primary;

    void selectLayout(String newValue) {
      setState(() => _selectedLayoutStyle = newValue);
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
                  groupValue: _selectedLayoutStyle,
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

  Widget _buildDropdown({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownItem> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Guard: if the stored key somehow doesn't match any known item
    // (corrupted data, renamed key, etc.), fall back to the first
    // item instead of letting DropdownButton crash.
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
}
