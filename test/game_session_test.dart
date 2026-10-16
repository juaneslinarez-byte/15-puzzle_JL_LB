import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/logic/difficulty.dart';
import 'package:puzzle15/logic/game_session.dart';
import 'package:puzzle15/logic/high_score.dart';
import 'package:puzzle15/logic/puzzle.dart';

void main() {
  GameSession almostSolved() => GameSession.withPuzzle(
        Difficulty.easy,
        Puzzle.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]),
      );

  test('el cronómetro arranca con el primer movimiento', () {
    final s = GameSession(Difficulty.easy);
    expect(s.status, GameStatus.ready);
    s.syncElapsed(const Duration(seconds: 5));
    expect(s.elapsed, Duration.zero);
  });

  test('ordenar el tablero gana la partida y cuenta el movimiento', () {
    final s = almostSolved();
    expect(s.tapTile(8), isTrue);
    expect(s.status, GameStatus.won);
    expect(s.moves, 1);
    expect(s.tapTile(7), isFalse, reason: 'no se juega después de ganar');
  });

  test('un toque inválido no cuenta como movimiento', () {
    final s = almostSolved();
    expect(s.tapTile(0), isFalse);
    expect(s.moves, 0);
  });

  test('se pierde al llegar al tiempo límite', () {
    final s = GameSession.withPuzzle(
        Difficulty.easy, Puzzle.fromTiles(3, [1, 2, 3, 4, 5, 6, 0, 7, 8]));
    s.tapTile(7);
    s.syncElapsed(const Duration(minutes: 1));
    expect(s.status, GameStatus.playing);
    s.syncElapsed(const Duration(minutes: 2, seconds: 1));
    expect(s.status, GameStatus.lost);
    expect(s.remaining, Duration.zero);
    expect(s.tapTile(8), isFalse);
  });

  test('en pausa no corre el tiempo ni se mueven piezas', () {
    final s = GameSession.withPuzzle(
        Difficulty.easy, Puzzle.fromTiles(3, [1, 2, 3, 4, 5, 6, 0, 7, 8]));
    s.tapTile(7);
    s.pause();
    s.syncElapsed(const Duration(minutes: 5));
    expect(s.status, GameStatus.paused);
    expect(s.tapTile(8), isFalse);
    s.resume();
    expect(s.tapTile(8), isTrue);
    expect(s.status, GameStatus.won);
  });

  group('récords', () {
    final d1 = DateTime(2026, 10, 15);
    final d2 = DateTime(2026, 10, 16);

    test('la primera victoria es récord en todo', () {
      final r = mergeScore(null, const Duration(seconds: 90), 40, d1);
      expect(r.newBestTime && r.newFewestMoves, isTrue);
    });

    test('tiempo y movimientos se comparan por separado', () {
      final first = mergeScore(null, const Duration(seconds: 90), 40, d1).score;
      final r = mergeScore(first, const Duration(seconds: 60), 55, d2);
      expect(r.newBestTime, isTrue);
      expect(r.newFewestMoves, isFalse);
      expect(r.score.bestTime, const Duration(seconds: 60));
      expect(r.score.bestTimeDate, d2);
      expect(r.score.fewestMoves, 40);
      expect(r.score.fewestMovesDate, d1);
    });

    test('se guarda y se lee en JSON', () {
      final s = mergeScore(null, const Duration(seconds: 75), 33, d1).score;
      final back = HighScore.fromJson(s.toJson())!;
      expect(back.bestTime, s.bestTime);
      expect(back.fewestMoves, 33);
      expect(HighScore.fromJson({'basura': 1}), isNull);
    });
  });
}
