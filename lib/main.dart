import 'package:flutter/material.dart';

import 'logic/difficulty.dart';
import 'screens/game_screen.dart';

void main() => runApp(const PuzzleApp());

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '15-Puzzle Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F5C)),
        useMaterial3: true,
      ),
      // Mientras no exista el menú, la app abre directo en una partida.
      home: const GameScreen(difficulty: Difficulty.medium),
    );
  }
}
