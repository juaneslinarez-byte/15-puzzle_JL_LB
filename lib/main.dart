import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_storage.dart';
import 'screens/splash_screen.dart';
import 'state/app_scope.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se cargan las preferencias guardadas antes de dibujar la primera pantalla.
  final storage = AppStorage(await SharedPreferences.getInstance());
  runApp(PuzzleApp(settings: SettingsController(storage)));
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      // Se reconstruye cuando cambia el tema, así el cambio es inmediato.
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: '15-Puzzle Flutter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
