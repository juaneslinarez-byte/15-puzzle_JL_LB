import 'package:shared_preferences/shared_preferences.dart';

/// Acceso a las preferencias guardadas en el dispositivo (shared_preferences).
///
/// Todo vive en el dispositivo; no hay servidor. Si un valor no existe o es
/// desconocido, quien lo lee usa un valor por defecto.
class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kDifficulty = 'settings.difficulty';
  static const _kDifficultyChosen = 'settings.difficultyChosen';
  static const _kTheme = 'settings.theme';
  static const _kTileStyle = 'settings.tileStyle';
  static const _kSound = 'settings.sound';
  static const _kAnimations = 'settings.animations';

  String? get difficulty => _prefs.getString(_kDifficulty);
  bool get difficultyChosen => _prefs.getBool(_kDifficultyChosen) ?? false;
  String? get theme => _prefs.getString(_kTheme);
  String? get tileStyle => _prefs.getString(_kTileStyle);
  bool get sound => _prefs.getBool(_kSound) ?? true;
  bool get animations => _prefs.getBool(_kAnimations) ?? true;

  Future<void> setDifficulty(String value) async {
    await _prefs.setString(_kDifficulty, value);
    await _prefs.setBool(_kDifficultyChosen, true);
  }

  Future<void> setTheme(String value) => _prefs.setString(_kTheme, value);
  Future<void> setTileStyle(String value) => _prefs.setString(_kTileStyle, value);
  Future<void> setSound(bool value) => _prefs.setBool(_kSound, value);
  Future<void> setAnimations(bool value) => _prefs.setBool(_kAnimations, value);
}
