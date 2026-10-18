import 'package:flutter/material.dart';

import '../logic/difficulty.dart';
import '../logic/puzzle.dart';
import '../state/app_scope.dart';
import '../widgets/puzzle_board.dart';

/// Reglas del juego. Su contenido no cambia, por eso es un StatelessWidget.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo jugar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _Block(
                icon: Icons.flag_outlined,
                title: 'Objetivo',
                body:
                    'Ordena las piezas en orden numérico usando el espacio vacío '
                    'para deslizar las piezas que están a su lado.',
              ),
              const _Block(
                icon: Icons.touch_app_outlined,
                title: 'Cómo mover',
                body:
                    'Toca o haz clic en una pieza que esté junto al espacio vacío '
                    '(arriba, abajo, izquierda o derecha, nunca en diagonal) y se deslizará hacia él. '
                    'En computadora también puedes usar las flechas del teclado.',
              ),
              _Block(
                icon: Icons.emoji_events_outlined,
                title: 'Cómo se gana',
                body:
                    'Ganas cuando todas las piezas quedan ordenadas de izquierda a derecha '
                    'y de arriba hacia abajo, con el espacio vacío al final. Un punto pequeño '
                    'en la esquina de una pieza indica que ya está en su lugar.',
                extra: Center(
                  child: SizedBox(
                    width: 150,
                    child: PuzzleBoard(
                      puzzle: Puzzle.solved(3),
                      style: AppScope.of(context).settings.tileStyle,
                      animate: false,
                    ),
                  ),
                ),
              ),
              _Block(
                icon: Icons.hourglass_bottom,
                title: 'Cómo se pierde',
                body:
                    'Cada dificultad tiene un tiempo límite. El cronómetro arranca con tu '
                    'primer movimiento; si llega al límite antes de ordenar el tablero, pierdes.',
                extra: Column(
                  children: [
                    for (final d in Difficulty.values)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Text(d.gridLabel, style: text.titleMedium),
                        title: Text(d.label),
                        trailing: Text(
                          '${d.timeLimit.inMinutes} minutos',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
              const _Block(
                icon: Icons.leaderboard_outlined,
                title: 'Récords',
                body:
                    'Por cada dificultad se guardan tu mejor tiempo y tu menor número de '
                    'movimientos, con la fecha. Se cuentan por separado y los verás en Marcadores.',
              ),
              const _Block(
                icon: Icons.lightbulb_outline,
                title: 'Consejo',
                body:
                    'Resuelve primero la fila de arriba y la columna de la izquierda; '
                    'así el tablero se reduce a uno más pequeño. Puedes pausar cuando quieras.',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Volver al menú'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.icon, required this.title, required this.body, this.extra});

  final IconData icon;
  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: const TextStyle(height: 1.4)),
            if (extra != null) ...[const SizedBox(height: 12), extra!],
          ],
        ),
      ),
    );
  }
}
