import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' && locale.languageCode != 'fr') return;
    state = locale;
  }

  void toggleLocale() {
    state = state.languageCode == 'en' ? const Locale('fr') : const Locale('en');
  }
}