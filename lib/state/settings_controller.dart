import 'package:flutter/material.dart';

import '../data/app_storage.dart';
import '../logic/difficulty.dart';
import '../theme/tile_style.dart';

/// Preferencias del usuario. Notifica a la interfaz cuando cambian para que
/// el tema y el estilo se apliquen al instante, y las guarda en el dispositivo.
class SettingsController extends ChangeNotifier {
  SettingsController(this._storage)
    : _difficulty = Difficulty.fromName(_storage.difficulty),
      _difficultyChosen = _storage.difficultyChosen,
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == _storage.theme,
        orElse: () => ThemeMode.system,
      ),
      _tileStyle = TileStyle.fromName(_storage.tileStyle),
      _sound = _storage.sound,
      _animations = _storage.animations;

  final AppStorage _storage;

  Difficulty _difficulty;
  bool _difficultyChosen;
  ThemeMode _themeMode;
  TileStyle _tileStyle;
  bool _sound;
  bool _animations;

  Difficulty get difficulty => _difficulty;

  /// Si el usuario ya eligió una dificultad alguna vez. Si no, al pulsar
  /// "Jugar" se le pregunta antes de empezar.
  bool get difficultyChosen => _difficultyChosen;
  ThemeMode get themeMode => _themeMode;
  TileStyle get tileStyle => _tileStyle;
  bool get sound => _sound;
  bool get animations => _animations;

  void setDifficulty(Difficulty value) {
    _difficulty = value;
    _difficultyChosen = true;
    notifyListeners();
    _storage.setDifficulty(value.name);
  }

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
    _storage.setTheme(value.name);
  }

  void setTileStyle(TileStyle value) {
    _tileStyle = value;
    notifyListeners();
    _storage.setTileStyle(value.name);
  }

  void setSound(bool value) {
    _sound = value;
    notifyListeners();
    _storage.setSound(value);
  }

  void setAnimations(bool value) {
    _animations = value;
    notifyListeners();
    _storage.setAnimations(value);
  }
}
