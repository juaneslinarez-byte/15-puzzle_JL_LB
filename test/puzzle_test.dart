import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/logic/puzzle.dart';

/// Todos los estados 3x3 alcanzables desde el tablero resuelto (181 440).
/// Se calcula una sola vez por búsqueda en anchura y sirve para comprobar
/// que la regla de paridad coincide con la realidad.
final Set<String> reachable3x3 = () {
  final start = Puzzle.solved(3);
  final seen = <String>{start.tiles.join(',')};
  var frontier = [start];
  while (frontier.isNotEmpty) {
    final next = <Puzzle>[];
    for (final p in frontier) {
      for (var i = 0; i < 9; i++) {
        if (!p.canMove(i)) continue;
        final moved = p.move(i);
        if (seen.add(moved.tiles.join(','))) next.add(moved);
      }
    }
    frontier = next;
  }
  return seen;
}();

void main() {
  group('Puzzle.solved', () {
    test('pone 1..n en orden y el vacío al final', () {
      expect(Puzzle.solved(3).tiles, [1, 2, 3, 4, 5, 6, 7, 8, 0]);
      expect(Puzzle.solved(4).isSolved, isTrue);
    });
  });

  group('paridad de inversiones', () {
    test('el tablero resuelto es resoluble en 3x3, 4x4 y 5x5', () {
      for (final size in [3, 4, 5]) {
        expect(Puzzle.isSolvable(size, Puzzle.solved(size).tiles), isTrue);
      }
    });

    test('el clásico 14-15 intercambiado de Sam Loyd no tiene solución', () {
      final tiles = Puzzle.solved(4).tiles.toList();
      tiles[13] = 15;
      tiles[14] = 14;
      expect(Puzzle.isSolvable(4, tiles), isFalse);
    });

    test('exactamente la mitad de las permutaciones 3x3 es resoluble', () {
      expect(reachable3x3.length, 181440);
    });

    test('la regla coincide con una búsqueda real en 2000 tableros 3x3', () {
      final rng = Random(7);
      for (var i = 0; i < 2000; i++) {
        final tiles = Puzzle.solved(3).tiles.toList()..shuffle(rng);
        expect(Puzzle.isSolvable(3, tiles), reachable3x3.contains(tiles.join(',')),
            reason: 'tablero $tiles');
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('Puzzle.shuffled', () {
    test('siempre produce tableros resolubles y desordenados', () {
      final rng = Random(42);
      for (final size in [3, 4, 5]) {
        for (var i = 0; i < 500; i++) {
          final p = Puzzle.shuffled(size, random: rng);
          expect(Puzzle.isSolvable(size, p.tiles), isTrue);
          expect(p.isSolved, isFalse);
          expect(p.tiles.toSet().length, size * size);
        }
      }
    });
  });

  group('movimientos', () {
    final p = Puzzle.fromTiles(3, [1, 2, 3, 4, 0, 5, 7, 8, 6]);

    test('solo se mueven las piezas junto al vacío, nunca en diagonal', () {
      expect(p.canMove(1), isTrue); // arriba
      expect(p.canMove(3), isTrue); // izquierda
      expect(p.canMove(5), isTrue); // derecha
      expect(p.canMove(7), isTrue); // abajo
      expect(p.canMove(0), isFalse); // diagonal
      expect(p.canMove(4), isFalse); // el vacío
    });

    test('no hay salto entre el final de una fila y el inicio de la otra', () {
      final q = Puzzle.fromTiles(3, [1, 2, 0, 3, 4, 5, 6, 7, 8]);
      expect(q.canMove(3), isFalse);
    });

    test('mover intercambia la pieza con el vacío', () {
      expect(p.move(5).tiles, [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(p.move(5).move(8).isSolved, isTrue);
    });

    test('mover una pieza no adyacente lanza error', () {
      expect(() => p.move(0), throwsStateError);
    });

    test('las flechas mueven la pieza correcta', () {
      expect(p.tileForDirection(SlideDirection.up), 7);
      expect(p.tileForDirection(SlideDirection.down), 1);
      expect(p.tileForDirection(SlideDirection.left), 5);
      expect(p.tileForDirection(SlideDirection.right), 3);
      final corner = Puzzle.solved(3);
      expect(corner.tileForDirection(SlideDirection.up), isNull);
      expect(corner.tileForDirection(SlideDirection.left), isNull);
    });
  });
}
