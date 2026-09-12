import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String currencySymbol;
  final ThemeMode themeMode;
  final bool isFirstRun;

  SettingsState({
    required this.currencySymbol,
    required this.themeMode,
    required this.isFirstRun,
  });

  SettingsState copyWith({
    String? currencySymbol,
    ThemeMode? themeMode,
    bool? isFirstRun,
  }) {
    return SettingsState(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
      isFirstRun: isFirstRun ?? this.isFirstRun,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          currencySymbol: "\$",
          themeMode: ThemeMode.system,
          isFirstRun: true,
        )) {
    _loadSettings();
  }

  static const _currencyKey = 'currency_symbol';
  static const _themeModeKey = 'theme_mode';
  static const _firstRunKey = 'is_first_run';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString(_currencyKey) ?? "\$";
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;

    state = SettingsState(
      currencySymbol: currency,
      themeMode: ThemeMode.values[themeIndex],
      isFirstRun: isFirstRun,
    );
  }

  Future<void> setCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
    state = state.copyWith(currencySymbol: symbol);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setFirstRun(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, value);
    state = state.copyWith(isFirstRun: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
