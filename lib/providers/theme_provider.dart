import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_lightTheme);

  static final _lightTheme = ThemeData.light().copyWith(
    cardTheme: CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    cardTheme: CardTheme(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
  );

  void toggleTheme() {
    state = state.brightness == Brightness.dark ? _lightTheme : _darkTheme;
  }
}