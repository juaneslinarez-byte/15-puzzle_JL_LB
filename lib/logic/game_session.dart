import 'dart:math';

import 'difficulty.dart';
import 'puzzle.dart';

/// Estados posibles de una partida.
enum GameStatus {
  /// Tablero listo; el cronómetro arranca con el primer movimiento.
  ready,
  playing,
  paused,
  won,

  /// Se acabó el tiempo límite de la dificultad.
  lost,
}

/// Reglas de una partida, separadas de la interfaz.
///
/// La pantalla solo le avisa a la sesión de los toques y del paso del
/// tiempo; la sesión decide si el movimiento es válido y si se ganó o perdió.
class GameSession {
  GameSession(this.difficulty, {Random? random})
      : puzzle = Puzzle.shuffled(difficulty.size, random: random);

  /// Para pruebas: arranca desde un tablero concreto.
  GameSession.withPuzzle(this.difficulty, this.puzzle);

  final Difficulty difficulty;
  Puzzle puzzle;
  int moves = 0;
  Duration elapsed = Duration.zero;
  GameStatus status = GameStatus.ready;

  Duration get timeLimit => difficulty.timeLimit;

  Duration get remaining {
    final left = timeLimit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// Fracción de tiempo restante, de 1.0 (lleno) a 0.0 (agotado).
  double get remainingFraction =>
      remaining.inMilliseconds / timeLimit.inMilliseconds;

  bool get isOver => status == GameStatus.won || status == GameStatus.lost;

  bool get acceptsMoves =>
      status == GameStatus.ready || status == GameStatus.playing;

  /// Intenta mover la pieza en `index`. Devuelve `true` si se movió.
  bool tapTile(int index) {
    if (!acceptsMoves || !puzzle.canMove(index)) return false;
    puzzle = puzzle.move(index);
    moves++;
    if (status == GameStatus.ready) status = GameStatus.playing;
    if (puzzle.isSolved) status = GameStatus.won;
    return true;
  }

  bool slide(SlideDirection direction) {
    final index = puzzle.tileForDirection(direction);
    return index != null && tapTile(index);
  }

  /// Actualiza el tiempo transcurrido. Si se alcanza el límite, se pierde.
  void syncElapsed(Duration total) {
    if (status != GameStatus.playing) return;
    elapsed = total;
    if (elapsed >= timeLimit) {
      elapsed = timeLimit;
      status = GameStatus.lost;
    }
  }

  void pause() {
    if (status == GameStatus.playing) status = GameStatus.paused;
  }

  void resume() {
    if (status == GameStatus.paused) status = GameStatus.playing;
  }
}
