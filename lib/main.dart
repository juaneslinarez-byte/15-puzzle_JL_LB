import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';

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
      home: const MenuScreen(),
    );
  }
}
