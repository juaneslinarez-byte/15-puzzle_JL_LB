import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/data/app_storage.dart';
import 'package:puzzle15/logic/difficulty.dart';
import 'package:puzzle15/state/settings_controller.dart';
import 'package:puzzle15/theme/tile_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Crea un controlador nuevo leyendo lo que haya guardado, como al abrir la app.
Future<SettingsController> openApp() async =>
    SettingsController(AppStorage(await SharedPreferences.getInstance()));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la primera vez usa los valores por defecto y pide la dificultad', () async {
    final settings = await openApp();
    expect(settings.difficultyChosen, isFalse);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.sound, isTrue);
    expect(settings.animations, isTrue);
  });

  test('las preferencias se guardan y se recuperan al volver a abrir la app', () async {
    final settings = await openApp();
    settings
      ..setDifficulty(Difficulty.hard)
      ..setThemeMode(ThemeMode.dark)
      ..setTileStyle(TileStyle.retro)
      ..setAnimations(false)
      ..setSound(false);

    final reopened = await openApp();
    expect(reopened.difficulty, Difficulty.hard);
    expect(reopened.difficultyChosen, isTrue);
    expect(reopened.themeMode, ThemeMode.dark);
    expect(reopened.tileStyle, TileStyle.retro);
    expect(reopened.animations, isFalse);
    expect(reopened.sound, isFalse);
  });

  test('avisa a la interfaz cuando cambia una preferencia', () async {
    final settings = await openApp();
    var notified = 0;
    settings.addListener(() => notified++);
    settings.setTileStyle(TileStyle.colorful);
    settings.setThemeMode(ThemeMode.light);
    expect(notified, 2);
  });
}
