import 'package:flutter/material.dart';

import 'logic/difficulty.dart';
import 'logic/game_session.dart';
import 'widgets/puzzle_board.dart';

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
      home: const _BoardPreview(),
    );
  }
}

/// Vista temporal para probar el tablero mientras se arma la pantalla de juego.
class _BoardPreview extends StatefulWidget {
  const _BoardPreview();

  @override
  State<_BoardPreview> createState() => _BoardPreviewState();
}

class _BoardPreviewState extends State<_BoardPreview> {
  final _session = GameSession(Difficulty.medium);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movimientos: ${_session.moves}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PuzzleBoard(
              puzzle: _session.puzzle,
              onTileTap: (i) => setState(() => _session.tapTile(i)),
            ),
          ),
        ),
      ),
    );
  }
}
