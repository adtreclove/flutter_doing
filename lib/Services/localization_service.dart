import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doing/Helpers/log_helper.dart';
import 'package:flutter_doing/l10n/generated/intl_localizations.dart';
import 'package:get_it/get_it.dart';

// To avoid the standard usage of AppLocalizations that needs a BuildContext,
// we now use our localization service instance
// With the getIt packge, we can access objects from anywhere without the need of a BuildContext

// to use a localized text, call: getIt<LocalizationService>().localizations.[NAME]
class LocalizationService {
  late AppLocalizations _localizations;
  late Locale _locale;

  // Initialize with a locale
  Future<void> init(Locale locale) async {
    _localizations = await AppLocalizations.delegate.load(locale);
    _locale = locale;
  }

  AppLocalizations get localizations => _localizations;
  Locale get currentLocale => _locale;

  // Update the locale dynamically
  Future<void> updateLocale(Locale locale) async {
    coloredLog(
      "[LOCALIZATIONS SERVICE] Updating locale to $locale",
      color: 'green',
    );

    _locale = locale;
    _localizations = await AppLocalizations.delegate.load(locale);
  }
}

final getIt = GetIt.instance;

Future<void> setupLocalizationService({String? preferredLanguage}) async {
  final localizationService = LocalizationService();

  String locale;
  if (preferredLanguage == 'en' || preferredLanguage == 'de') {
    locale = preferredLanguage!;
  } else {
    final String systemLocale = Platform.localeName;
    switch (systemLocale.split("_").first) {
      case "en":
        locale = "en";
        break;
      case "de":
        locale = "de";
        break;
      default:
        locale = "en";
    }
  }

  await localizationService.init(Locale(locale));
  getIt.registerSingleton<LocalizationService>(localizationService);
}
