// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'intl_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_appearance_title => 'Erscheinungsbild';

  @override
  String get settings_layout => 'Gestaltung';

  @override
  String get settings_subtitle =>
      'Wählen Sie, wie die Anwendung dargestellt werden soll';

  @override
  String get settings_layout_classic => 'Klassisch';

  @override
  String get settings_layout_compact => 'Kompakt';

  @override
  String get settings_theme_title => 'Design';

  @override
  String get settings_theme_subtitle => 'Wählen Sie Ihr bevorzugtes Farbdesign';

  @override
  String get settings_theme_dark => 'Dunkel';

  @override
  String get settings_theme_light => 'Hell';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_show_kpi_title => 'KPIs anzeigen';

  @override
  String get settings_show_kpi_subtitle =>
      'Wählen Sie, ob Ihre KPIs in der klassischen Ansicht sichtbar sein sollen';

  @override
  String get settings_startup => 'Appstart';

  @override
  String get settings_startup_title_windows => 'Mit Windows starten';

  @override
  String get settings_startup_title_mac => 'Mit Mac starten';

  @override
  String get settings_startup_subtitle_windows =>
      'Die Anwendung startet automatisch, wenn Windows startet';

  @override
  String get settings_startup_subtitle_mac =>
      'Die Anwendung startet automatisch, wenn der Mac hochfährt';

  @override
  String get settings_launch_mode_title => 'Startmodus';

  @override
  String get settings_launch_mode_subutitle =>
      'Wählen Sie aus, in welchem Zustand die App gestartet wird';

  @override
  String get settings_launch_mode_normal => 'Normal';

  @override
  String get settings_launch_mode_minimized => 'Minimiert';

  @override
  String get settings_launch_mode_background => 'Hintergrund';

  @override
  String get settings_alwaysOnTopTitle => 'Immer im Vordergrund';

  @override
  String get settings_alwaysOnTopSubtitle =>
      'Die App wird immer im Vordergrund gehalten';

  @override
  String get settings_notification => 'Benachrichtigungen';

  @override
  String get settings_notification_title => 'Benachrichtigungen erlauben';

  @override
  String get settings_notification_subtitle =>
      'Erlauben Sie der Anwendung Ihnen Desktop-Benachrichtigungen zu senden';

  @override
  String get settings_about => 'Über diese Anwendung';

  @override
  String get settings_language_title => 'Sprache';

  @override
  String get settings_language_subtitle => 'Wählen Sie Ihre bevorzugte Sprache';

  @override
  String get settings_language_german => 'Deutsch';

  @override
  String get settings_language_english => 'Englisch';

  @override
  String get tray_settings => 'Einstellungen';

  @override
  String get tray_close_app_windows => 'App schließen';

  @override
  String get tray_close_app_mac => 'App beenden';
}
