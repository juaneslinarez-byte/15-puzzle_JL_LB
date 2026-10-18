import 'package:flutter/material.dart';

import '../logic/puzzle.dart';
import '../theme/tile_style.dart';
import 'tile_view.dart';

/// Dibuja el tablero y anima el deslizamiento de las piezas.
///
/// Es un widget sin estado propio: recibe el tablero actual y avisa de los
/// toques con [onTileTap]. Las reglas viven en `GameSession`.
class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.style,
    required this.animate,
    this.onTileTap,
    this.enabled = true,
  });

  final Puzzle puzzle;
  final TileStyle style;
  final bool animate;
  final ValueChanged<int>? onTileTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth;
          final n = puzzle.size;
          final gap = side * (n >= 5 ? 0.015 : 0.02);
          final tile = (side - gap * (n + 1)) / n;
          final pieces = n * n - 1;

          return Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(gap * 3),
            ),
            child: Stack(
              children: [
                for (var index = 0; index < puzzle.tiles.length; index++)
                  if (puzzle.tiles[index] != 0)
                    AnimatedPositioned(
                      // La clave es el número de la pieza, así Flutter sabe
                      // que es la misma pieza que cambió de lugar y la anima.
                      key: ValueKey(puzzle.tiles[index]),
                      duration: animate ? const Duration(milliseconds: 140) : Duration.zero,
                      curve: Curves.easeOut,
                      left: gap + puzzle.colOf(index) * (tile + gap),
                      top: gap + puzzle.rowOf(index) * (tile + gap),
                      width: tile,
                      height: tile,
                      child: TileView(
                        value: puzzle.tiles[index],
                        pieces: pieces,
                        size: tile,
                        style: style,
                        isCorrect: puzzle.tiles[index] == index + 1,
                        canMove: enabled && puzzle.canMove(index),
                        onTap: enabled && onTileTap != null ? () => onTileTap!(index) : null,
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
