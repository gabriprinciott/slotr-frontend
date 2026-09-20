import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsStorageService {
  final FlutterSecureStorage _storage;

  static const String _themeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  SettingsStorageService(this._storage);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _storage.write(key: _themeKey, value: themeMode.name);
  }

  Future<ThemeMode?> getThemeMode() async {
    final value = await _storage.read(key: _themeKey);
    if (value != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
    return null;
  }

  Future<void> saveLocale(Locale locale) async {
    await _storage.write(key: _localeKey, value: locale.languageCode);
  }

  Future<Locale?> getLocale() async {
    final value = await _storage.read(key: _localeKey);
    if (value != null && value.isNotEmpty) {
      return Locale(value);
    }
    return null;
  }
}
