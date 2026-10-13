import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/retro_theme.dart';

class SettingsState {
  final RetroPaletteType paletteType;
  final bool isSoundEnabled;
  final bool isCrtScanlinesEnabled;
  final bool isLoading;

  const SettingsState({
    this.paletteType = RetroPaletteType.arcade,
    this.isSoundEnabled = true,
    this.isCrtScanlinesEnabled = true,
    this.isLoading = false,
  });

  RetroThemePalette get palette => RetroThemePalette.fromType(paletteType);

  SettingsState copyWith({
    RetroPaletteType? paletteType,
    bool? isSoundEnabled,
    bool? isCrtScanlinesEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      paletteType: paletteType ?? this.paletteType,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isCrtScanlinesEnabled:
          isCrtScanlinesEnabled ?? this.isCrtScanlinesEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _keyTheme = 'settings_theme_type';
  static const String _keySound = 'settings_sound_enabled';
  static const String _keyScanlines = 'settings_scanlines_enabled';

  SettingsCubit() : super(const SettingsState(isLoading: true)) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme) ?? 0;
    final sound = prefs.getBool(_keySound) ?? true;
    final scanlines = prefs.getBool(_keyScanlines) ?? true;

    final palette = RetroPaletteType.values[themeIndex.clamp(
      0,
      RetroPaletteType.values.length - 1,
    )];

    emit(
      SettingsState(
        paletteType: palette,
        isSoundEnabled: sound,
        isCrtScanlinesEnabled: scanlines,
        isLoading: false,
      ),
    );
  }

  Future<void> setPaletteType(RetroPaletteType type) async {
    emit(state.copyWith(paletteType: type));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, type.index);
  }

  Future<void> toggleSound() async {
    final next = !state.isSoundEnabled;
    emit(state.copyWith(isSoundEnabled: next));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, next);
  }

  Future<void> toggleCrtScanlines() async {
    final next = !state.isCrtScanlinesEnabled;
    emit(state.copyWith(isCrtScanlinesEnabled: next));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyScanlines, next);
  }
}
