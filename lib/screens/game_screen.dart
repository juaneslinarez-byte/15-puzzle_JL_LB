import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/difficulty.dart';
import '../logic/format.dart';
import '../logic/game_session.dart';
import '../logic/puzzle.dart';
import '../state/app_scope.dart';
import '../widgets/puzzle_board.dart';

/// Pantalla del tablero.
///
/// Es un StatefulWidget porque cambia todo el tiempo: piezas, movimientos y
/// cronómetro. Usamos setState porque ese estado solo le importa a esta
/// pantalla; las reglas están en [GameSession] y aquí solo se dibujan.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty, this.initialSession});

  final Difficulty difficulty;

  /// Solo para pruebas: permite empezar desde un tablero conocido.
  @visibleForTesting
  final GameSession? initialSession;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameSession _session;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _newGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _focus.dispose();
    super.dispose();
  }

  /// Si la app pasa a segundo plano, se pausa sola para no perder tiempo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _session.status == GameStatus.playing) {
      _pause();
    }
  }

  void _newGame() {
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    final initial = widget.initialSession;
    _session = initial != null && initial.status == GameStatus.ready
        ? initial
        : GameSession(widget.difficulty);
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
    // Efecto de sonido y vibración opcionales (Configuración → Efectos de sonido).
    final sound = AppScope.of(context).settings.sound;
    if (sound) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.selectionClick();
    }
    setState(() {});
    if (_session.status == GameStatus.won) {
      _session.elapsed = _stopwatch.elapsed;
      if (sound) HapticFeedback.mediumImpact();
      _finish();
    }
  }

  void _finish() {
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() {});
  }

  void _pause() {
    _session.pause();
    _stopwatch.stop();
    setState(() {});
  }

  void _resume() {
    _session.resume();
    _stopwatch.start();
    setState(() {});
    _focus.requestFocus();
  }

  /// En computadora, las flechas mueven la pieza que está al lado del hueco
  /// en la dirección contraria: la flecha arriba sube la pieza de abajo.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => SlideDirection.up,
      LogicalKeyboardKey.arrowDown => SlideDirection.down,
      LogicalKeyboardKey.arrowLeft => SlideDirection.left,
      LogicalKeyboardKey.arrowRight => SlideDirection.right,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    final index = _session.puzzle.tileForDirection(direction);
    if (index != null) _onTileTap(index);
    return KeyEventResult.handled;
  }

  bool get _inProgress => _session.status == GameStatus.playing || _session.status == GameStatus.paused;

  /// Pide confirmación antes de perder una partida en curso. Mientras el
  /// diálogo está abierto el reloj queda en pausa.
  Future<bool> _confirm(String title, String message, String action) async {
    final wasPlaying = _session.status == GameStatus.playing;
    if (wasPlaying) _pause();
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir jugando')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
            ],
          ),
        ) ??
        false;
    if (!ok && wasPlaying && mounted) _resume();
    return ok;
  }

  Future<void> _restart() async {
    if (_inProgress &&
        !await _confirm('¿Reiniciar la partida?', 'Se perderá el progreso de este tablero.', 'Reiniciar')) {
      return;
    }
    setState(_newGame);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final status = _session.status;
    return PopScope(
      canPop: !_inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirm(
          '¿Salir de la partida?',
          'Volverás al menú y se perderá esta partida.',
          'Salir',
        );
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.difficulty.label} · ${widget.difficulty.gridLabel}'),
          actions: [
            if (status == GameStatus.playing)
              IconButton(tooltip: 'Pausar', onPressed: _pause, icon: const Icon(Icons.pause)),
            if (status == GameStatus.paused)
              IconButton(tooltip: 'Reanudar', onPressed: _resume, icon: const Icon(Icons.play_arrow)),
            IconButton(tooltip: 'Nuevo tablero', onPressed: _restart, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Focus(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // En pantallas anchas (escritorio, tablet horizontal) los datos
                // van a la izquierda del tablero; en el teléfono, arriba.
                final wide =
                    constraints.maxWidth > constraints.maxHeight * 1.15 && constraints.maxWidth > 700;
                final stats = _StatsPanel(session: _session, vertical: wide);
                final board = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // En pausa se oculta el tablero para que no se pueda planear sin reloj.
                        AnimatedOpacity(
                          opacity: status == GameStatus.paused ? 0 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: PuzzleBoard(
                            puzzle: _session.puzzle,
                            style: settings.tileStyle,
                            animate: settings.animations,
                            enabled: _session.acceptsMoves,
                            onTileTap: _onTileTap,
                          ),
                        ),
                        if (status == GameStatus.paused) _PausedOverlay(onResume: _resume),
                        if (_session.isOver)
                          _GameOverPanel(
                            session: _session,
                            onRestart: () {
                              setState(_newGame);
                              _focus.requestFocus();
                            },
                            // El menú todavía no existe: el botón solo aparece si hay a dónde volver.
                            onMenu: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
                          ),
                      ],
                    ),
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
                            Text(switch (status) {
                              GameStatus.ready => 'Toca una pieza junto al hueco para empezar',
                              GameStatus.won || GameStatus.lost => 'Partida terminada',
                              GameStatus.paused => 'En pausa',
                              _ =>
                                '${_session.puzzle.correctTiles} de ${widget.difficulty.pieces} piezas en su lugar',
                            }, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Pausa', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Reanudar'),
          ),
        ],
      ),
    );
  }
}

/// Resultado de la partida, superpuesto al tablero.
class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel({required this.session, required this.onRestart, this.onMenu});

  final GameSession session;
  final VoidCallback onRestart;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final won = session.status == GameStatus.won;
    final color = won ? scheme.primary : scheme.error;

    return ColoredBox(
      color: scheme.surface.withValues(alpha: 0.55),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              elevation: 8,
              color: scheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(won ? Icons.emoji_events : Icons.hourglass_empty, size: 48, color: color),
                    const SizedBox(height: 8),
                    Text(
                      won ? '¡Ganaste!' : 'Perdiste',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, color: color),
                    ),
                    if (!won) ...[const SizedBox(height: 4), const Text('Se acabó el tiempo')],
                    const SizedBox(height: 16),
                    _SummaryRow('Tiempo', formatDuration(session.elapsed)),
                    _SummaryRow('Movimientos', '${session.moves}'),
                    _SummaryRow(
                      'Dificultad',
                      '${session.difficulty.label} · ${session.difficulty.gridLabel}',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (onMenu != null) ...[
                          Expanded(
                            child: OutlinedButton(onPressed: onMenu, child: const Text('Menú')),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: FilledButton(onPressed: onRestart, child: const Text('Reiniciar')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
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
        // La cuenta regresiva redondea hacia arriba: con 1:59.6 restantes se ve 2:00.
        value: formatDuration(Duration(seconds: (session.remaining.inMilliseconds / 1000).ceil())),
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
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: color ?? scheme.onSurfaceVariant),
                ),
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
