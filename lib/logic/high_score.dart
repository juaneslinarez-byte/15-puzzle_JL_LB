/// Mejores marcas de una dificultad.
class HighScore {
  const HighScore({
    required this.bestTime,
    required this.bestTimeDate,
    required this.fewestMoves,
    required this.fewestMovesDate,
  });

  final Duration bestTime;
  final DateTime bestTimeDate;
  final int fewestMoves;
  final DateTime fewestMovesDate;

  Map<String, Object> toJson() => {
        'bestTimeMs': bestTime.inMilliseconds,
        'bestTimeDate': bestTimeDate.toIso8601String(),
        'fewestMoves': fewestMoves,
        'fewestMovesDate': fewestMovesDate.toIso8601String(),
      };

  static HighScore? fromJson(Map<String, dynamic> json) {
    try {
      return HighScore(
        bestTime: Duration(milliseconds: json['bestTimeMs'] as int),
        bestTimeDate: DateTime.parse(json['bestTimeDate'] as String),
        fewestMoves: json['fewestMoves'] as int,
        fewestMovesDate: DateTime.parse(json['fewestMovesDate'] as String),
      );
    } catch (_) {
      // Datos dañados o de otra versión: se ignoran en vez de romper la app.
      return null;
    }
  }
}

/// Resultado de registrar una victoria.
class RecordResult {
  const RecordResult(this.score, {required this.newBestTime, required this.newFewestMoves});

  final HighScore score;
  final bool newBestTime;
  final bool newFewestMoves;

  bool get isRecord => newBestTime || newFewestMoves;
}

/// Combina la marca anterior con una partida ganada.
///
/// El tiempo y los movimientos se comparan por separado: una partida puede
/// batir el récord de tiempo sin batir el de movimientos, y al revés.
RecordResult mergeScore(HighScore? previous, Duration time, int moves, DateTime date) {
  if (previous == null) {
    return RecordResult(
      HighScore(bestTime: time, bestTimeDate: date, fewestMoves: moves, fewestMovesDate: date),
      newBestTime: true,
      newFewestMoves: true,
    );
  }
  final betterTime = time < previous.bestTime;
  final fewerMoves = moves < previous.fewestMoves;
  return RecordResult(
    HighScore(
      bestTime: betterTime ? time : previous.bestTime,
      bestTimeDate: betterTime ? date : previous.bestTimeDate,
      fewestMoves: fewerMoves ? moves : previous.fewestMoves,
      fewestMovesDate: fewerMoves ? date : previous.fewestMovesDate,
    ),
    newBestTime: betterTime,
    newFewestMoves: fewerMoves,
  );
}
