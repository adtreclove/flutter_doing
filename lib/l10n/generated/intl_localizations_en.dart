// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'intl_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance_title => 'Appearance';

  @override
  String get settings_layout => 'Layout';

  @override
  String get settings_subtitle =>
      'Choose, how the main application is displayed';

  @override
  String get settings_layout_classic => 'Classic';

  @override
  String get settings_layout_compact => 'Compact';

  @override
  String get settings_theme_title => 'Theme';

  @override
  String get settings_theme_subtitle => 'Choose how the application looks';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_show_kpi_title => 'Show KPIs';

  @override
  String get settings_show_kpi_subtitle =>
      'Select if you want your KPIs to be displayed in classic layout';

  @override
  String get settings_startup => 'Startup';

  @override
  String get settings_startup_title_windows => 'Start with windows';

  @override
  String get settings_startup_title_mac => 'Start with mac';

  @override
  String get settings_startup_subtitle_windows =>
      'Automatically start the application with Windows';

  @override
  String get settings_startup_subtitle_mac =>
      'Automatically start the application with Mac';

  @override
  String get settings_launch_mode_title => 'Launch Mode';

  @override
  String get settings_launch_mode_subutitle =>
      'Select the state in which the app starts';

  @override
  String get settings_launch_mode_normal => 'normal';

  @override
  String get settings_launch_mode_minimized => 'minimized';

  @override
  String get settings_launch_mode_background => 'backgrounded';

  @override
  String get settings_alwaysOnTopTitle => 'Always on top';

  @override
  String get settings_alwaysOnTopSubtitle =>
      'The app is always kept in the foreground';

  @override
  String get settings_notification => 'Notifications';

  @override
  String get settings_notification_title => 'Allow notifications';

  @override
  String get settings_notification_subtitle =>
      'Allow the application to send you desktop notifications';

  @override
  String get settings_about => 'About';

  @override
  String get settings_language_title => 'Language';

  @override
  String get settings_language_subtitle => 'Choose your language';

  @override
  String get settings_language_german => 'German';

  @override
  String get settings_language_english => 'English';

  @override
  String get tray_settings => 'Settings';

  @override
  String get tray_close_app_windows => 'Close app';

  @override
  String get tray_close_app_mac => 'Stop app';
}
