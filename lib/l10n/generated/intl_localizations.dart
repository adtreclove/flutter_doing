import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'intl_localizations_de.dart';
import 'intl_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/intl_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @settings_title.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings_title;

  /// No description provided for @settings_appearance_title.
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get settings_appearance_title;

  /// No description provided for @settings_layout.
  ///
  /// In de, this message translates to:
  /// **'Gestaltung'**
  String get settings_layout;

  /// No description provided for @settings_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie, wie die Anwendung dargestellt werden soll'**
  String get settings_subtitle;

  /// No description provided for @settings_layout_classic.
  ///
  /// In de, this message translates to:
  /// **'Klassisch'**
  String get settings_layout_classic;

  /// No description provided for @settings_layout_compact.
  ///
  /// In de, this message translates to:
  /// **'Kompakt'**
  String get settings_layout_compact;

  /// No description provided for @settings_theme_title.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get settings_theme_title;

  /// No description provided for @settings_theme_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie Ihr bevorzugtes Farbdesign'**
  String get settings_theme_subtitle;

  /// No description provided for @settings_theme_dark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_light.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_system.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_show_kpi_title.
  ///
  /// In de, this message translates to:
  /// **'KPIs anzeigen'**
  String get settings_show_kpi_title;

  /// No description provided for @settings_show_kpi_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie, ob Ihre KPIs in der klassischen Ansicht sichtbar sein sollen'**
  String get settings_show_kpi_subtitle;

  /// No description provided for @settings_startup.
  ///
  /// In de, this message translates to:
  /// **'Appstart'**
  String get settings_startup;

  /// No description provided for @settings_startup_title_windows.
  ///
  /// In de, this message translates to:
  /// **'Mit Windows starten'**
  String get settings_startup_title_windows;

  /// No description provided for @settings_startup_title_mac.
  ///
  /// In de, this message translates to:
  /// **'Mit Mac starten'**
  String get settings_startup_title_mac;

  /// No description provided for @settings_startup_subtitle_windows.
  ///
  /// In de, this message translates to:
  /// **'Die Anwendung startet automatisch, wenn Windows startet'**
  String get settings_startup_subtitle_windows;

  /// No description provided for @settings_startup_subtitle_mac.
  ///
  /// In de, this message translates to:
  /// **'Die Anwendung startet automatisch, wenn der Mac hochfährt'**
  String get settings_startup_subtitle_mac;

  /// No description provided for @settings_launch_mode_title.
  ///
  /// In de, this message translates to:
  /// **'Startmodus'**
  String get settings_launch_mode_title;

  /// No description provided for @settings_launch_mode_subutitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie aus, in welchem Zustand die App gestartet wird'**
  String get settings_launch_mode_subutitle;

  /// No description provided for @settings_launch_mode_normal.
  ///
  /// In de, this message translates to:
  /// **'Normal'**
  String get settings_launch_mode_normal;

  /// No description provided for @settings_launch_mode_minimized.
  ///
  /// In de, this message translates to:
  /// **'Minimiert'**
  String get settings_launch_mode_minimized;

  /// No description provided for @settings_launch_mode_background.
  ///
  /// In de, this message translates to:
  /// **'Hintergrund'**
  String get settings_launch_mode_background;

  /// No description provided for @settings_alwaysOnTopTitle.
  ///
  /// In de, this message translates to:
  /// **'Immer im Vordergrund'**
  String get settings_alwaysOnTopTitle;

  /// No description provided for @settings_alwaysOnTopSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die App wird immer im Vordergrund gehalten'**
  String get settings_alwaysOnTopSubtitle;

  /// No description provided for @settings_notification.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settings_notification;

  /// No description provided for @settings_notification_title.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen erlauben'**
  String get settings_notification_title;

  /// No description provided for @settings_notification_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Erlauben Sie der Anwendung Ihnen Desktop-Benachrichtigungen zu senden'**
  String get settings_notification_subtitle;

  /// No description provided for @settings_about.
  ///
  /// In de, this message translates to:
  /// **'Über diese Anwendung'**
  String get settings_about;

  /// No description provided for @settings_language_title.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settings_language_title;

  /// No description provided for @settings_language_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie Ihre bevorzugte Sprache'**
  String get settings_language_subtitle;

  /// No description provided for @settings_language_german.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get settings_language_german;

  /// No description provided for @settings_language_english.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get settings_language_english;

  /// No description provided for @tray_settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tray_settings;

  /// No description provided for @tray_close_app_windows.
  ///
  /// In de, this message translates to:
  /// **'App schließen'**
  String get tray_close_app_windows;

  /// No description provided for @tray_close_app_mac.
  ///
  /// In de, this message translates to:
  /// **'App beenden'**
  String get tray_close_app_mac;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
