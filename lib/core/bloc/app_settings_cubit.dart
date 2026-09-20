import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slotr_app/core/storage/settings_storage_service.dart';

class AppSettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale? locale;

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final SettingsStorageService _storageService;

  AppSettingsCubit(this._storageService) : super(const AppSettingsState());

  Future<void> loadSettings() async {
    try {
      final themeMode = await _storageService.getThemeMode();
      final locale = await _storageService.getLocale();

      emit(state.copyWith(
        themeMode: themeMode,
        locale: locale,
      ));
    } catch (e) {

      emit(state.copyWith(
        themeMode: ThemeMode.system,
      ));
    }
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newThemeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    
    try {
      await _storageService.saveThemeMode(newThemeMode);
    } catch (e) {

    }
    emit(state.copyWith(themeMode: newThemeMode));
  }

  Future<void> setLocale(Locale locale) async {
    try {
      await _storageService.saveLocale(locale);
    } catch (e) {

    }
    emit(state.copyWith(locale: locale));
  }
}
