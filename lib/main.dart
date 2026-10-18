import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_storage.dart';
import 'screens/splash_screen.dart';
import 'state/app_scope.dart';
import 'state/settings_controller.dart';

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
      child: MaterialApp(
        title: '15-Puzzle Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F5C)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
