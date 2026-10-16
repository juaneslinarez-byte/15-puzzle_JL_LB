import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/difficulty.dart';
import '../logic/format.dart';
import '../logic/game_session.dart';
import '../widgets/puzzle_board.dart';

/// Pantalla del tablero.
///
/// Es un StatefulWidget porque cambia todo el tiempo: piezas, movimientos y
/// cronómetro. Usamos setState porque ese estado solo le importa a esta
/// pantalla; las reglas están en [GameSession] y aquí solo se dibujan.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _session;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _newGame() {
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _session = GameSession(widget.difficulty);
    // El Stopwatch mide el tiempo real; el Timer solo refresca la pantalla.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _tick() {
    if (_session.status != GameStatus.playing) return;
    setState(() => _session.syncElapsed(_stopwatch.elapsed));
    if (_session.status == GameStatus.lost) _finish();
  }

  void _onTileTap(int index) {
    final wasReady = _session.status == GameStatus.ready;
    if (!_session.tapTile(index)) return;
    if (wasReady) _stopwatch.start();
    setState(() {});
    if (_session.status == GameStatus.won) {
      _session.elapsed = _stopwatch.elapsed;
      _finish();
    }
  }

  void _finish() {
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final status = _session.status;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.difficulty.label} · ${widget.difficulty.gridLabel}'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas (escritorio, tablet horizontal) los datos
            // van a la izquierda del tablero; en el teléfono, arriba.
            final wide = constraints.maxWidth > constraints.maxHeight * 1.15 && constraints.maxWidth > 700;
            final stats = _StatsPanel(session: _session, vertical: wide);
            final board = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
              child: PuzzleBoard(
                puzzle: _session.puzzle,
                enabled: _session.acceptsMoves,
                onTileTap: _onTileTap,
              ),
            );
            return Padding(
              padding: const EdgeInsets.all(16),
              child: wide
                  ? Row(
                      children: [
                        SizedBox(width: 240, child: stats),
                        const SizedBox(width: 24),
                        Expanded(child: Center(child: board)),
                      ],
                    )
                  : Column(
                      children: [
                        stats,
                        const SizedBox(height: 16),
                        Expanded(child: Center(child: board)),
                        const SizedBox(height: 8),
                        Text(
                          switch (status) {
                            GameStatus.ready => 'Toca una pieza junto al hueco para empezar',
                            GameStatus.won => '¡Ganaste!',
                            GameStatus.lost => 'Se acabó el tiempo',
                            _ => '${_session.puzzle.correctTiles} de ${widget.difficulty.pieces} piezas en su lugar',
                          },
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.session, required this.vertical});

  final GameSession session;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = session.remainingFraction < 0.2 && session.status == GameStatus.playing;
    final items = [
      _Stat(icon: Icons.swap_horiz, label: 'Movimientos', value: '${session.moves}'),
      _Stat(icon: Icons.timer_outlined, label: 'Tiempo', value: formatDuration(session.elapsed)),
      _Stat(
        icon: Icons.hourglass_bottom,
        label: 'Restante',
        value: formatDuration(session.remaining),
        color: low ? scheme.error : null,
      ),
    ];
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: session.remainingFraction,
        minHeight: 8,
        color: low ? scheme.error : scheme.primary,
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) ...[item, const SizedBox(height: 12)],
          bar,
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: items[i]),
            ],
          ],
        ),
        const SizedBox(height: 12),
        bar,
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value, this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: color ?? scheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
