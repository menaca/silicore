import 'package:flutter/material.dart';
import 'lang_en.dart';
import 'lang_tr.dart';

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': tr,
    'en': en,
  };

  final Locale locale;

  AppLocalizations(this.locale);

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static  LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
   AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
