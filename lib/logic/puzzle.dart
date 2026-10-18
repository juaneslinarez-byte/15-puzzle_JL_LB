import 'dart:math';

/// Dirección en la que se desplaza una pieza hacia el espacio vacío.
enum SlideDirection { up, down, left, right }

/// Estado inmutable del tablero.
///
/// Las piezas se guardan en una lista de tamaño `size * size`, recorrida
/// de izquierda a derecha y de arriba hacia abajo. El valor `0` es el
/// espacio vacío.
class Puzzle {
  Puzzle._(this.size, List<int> tiles) : tiles = List.unmodifiable(tiles);

  /// Tablero ordenado: 1, 2, 3, ..., n, y el vacío al final.
  factory Puzzle.solved(int size) {
    if (size < 2) {
      throw ArgumentError.value(size, 'size', 'debe ser al menos 2');
    }
    return Puzzle._(size, [for (var i = 1; i < size * size; i++) i, 0]);
  }

  /// Crea un tablero a partir de una lista concreta (útil para pruebas).
  factory Puzzle.fromTiles(int size, List<int> tiles) {
    final expected = {for (var i = 0; i < size * size; i++) i};
    if (tiles.length != size * size || !expected.containsAll(tiles)) {
      throw ArgumentError('Las piezas deben ser una permutación de 0..${size * size - 1}');
    }
    return Puzzle._(size, tiles);
  }

  /// Tablero desordenado al azar que siempre se puede resolver.
  ///
  /// Se baraja la lista con Fisher-Yates. Si la permutación resultante no
  /// es resoluble, se intercambian dos piezas numeradas: eso cambia la
  /// paridad de las inversiones en exactamente 1 y la vuelve resoluble.
  /// Así se garantiza un tablero válido sin repetir el barajado a ciegas.
  factory Puzzle.shuffled(int size, {Random? random}) {
    final rng = random ?? Random();
    final values = Puzzle.solved(size).tiles.toList();
    do {
      values.shuffle(rng);
      if (!isSolvable(size, values)) {
        final a = values.indexWhere((v) => v != 0);
        final b = values.indexWhere((v) => v != 0, a + 1);
        final tmp = values[a];
        values[a] = values[b];
        values[b] = tmp;
      }
    } while (_isOrdered(values));
    return Puzzle._(size, values);
  }

  final int size;
  final List<int> tiles;

  /// Cuenta los pares de piezas numeradas que están en orden invertido.
  static int countInversions(List<int> tiles) {
    final numbers = tiles.where((v) => v != 0).toList();
    var inversions = 0;
    for (var i = 0; i < numbers.length; i++) {
      for (var j = i + 1; j < numbers.length; j++) {
        if (numbers[i] > numbers[j]) inversions++;
      }
    }
    return inversions;
  }

  /// Regla de paridad de inversiones.
  ///
  /// - Cuadrícula de ancho impar (3x3, 5x5): resoluble si las inversiones son pares.
  /// - Cuadrícula de ancho par (4x4): se cuenta la fila del vacío desde abajo
  ///   (empezando en 1). Si esa fila es par, las inversiones deben ser impares;
  ///   si es impar, deben ser pares.
  static bool isSolvable(int size, List<int> tiles) {
    final inversions = countInversions(tiles);
    if (size.isOdd) return inversions.isEven;
    final emptyRowFromBottom = size - tiles.indexOf(0) ~/ size;
    return emptyRowFromBottom.isEven ? inversions.isOdd : inversions.isEven;
  }

  static bool _isOrdered(List<int> tiles) {
    for (var i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }

  int get emptyIndex => tiles.indexOf(0);

  int rowOf(int index) => index ~/ size;
  int colOf(int index) => index % size;

  /// Índice donde debería estar la pieza `value` en el tablero resuelto.
  int targetIndexOf(int value) => value == 0 ? size * size - 1 : value - 1;

  bool get isSolved => _isOrdered(tiles);

  /// Piezas numeradas que ya están en su posición final.
  int get correctTiles {
    var count = 0;
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != 0 && tiles[i] == i + 1) count++;
    }
    return count;
  }

  /// Una pieza se puede mover si está justo al lado (no en diagonal) del vacío.
  bool canMove(int index) {
    if (index < 0 || index >= tiles.length || tiles[index] == 0) return false;
    final empty = emptyIndex;
    final distance = (rowOf(index) - rowOf(empty)).abs() +
        (colOf(index) - colOf(empty)).abs();
    return distance == 1;
  }

  /// Devuelve un tablero nuevo con la pieza movida al espacio vacío.
  Puzzle move(int index) {
    if (!canMove(index)) {
      throw StateError('La pieza en la posición $index no está junto al vacío');
    }
    final next = tiles.toList();
    final empty = emptyIndex;
    next[empty] = next[index];
    next[index] = 0;
    return Puzzle._(size, next);
  }

  /// Índice de la pieza que se movería en esa dirección (para el teclado),
  /// o `null` si no hay ninguna. Por ejemplo, "arriba" sube la pieza que
  /// está debajo del vacío.
  int? tileForDirection(SlideDirection direction) {
    final empty = emptyIndex;
    final row = rowOf(empty);
    final col = colOf(empty);
    switch (direction) {
      case SlideDirection.up:
        return row + 1 < size ? empty + size : null;
      case SlideDirection.down:
        return row - 1 >= 0 ? empty - size : null;
      case SlideDirection.left:
        return col + 1 < size ? empty + 1 : null;
      case SlideDirection.right:
        return col - 1 >= 0 ? empty - 1 : null;
    }
  }
}
