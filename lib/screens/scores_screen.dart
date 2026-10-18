import 'package:flutter/material.dart';
import '../data/score_storage.dart';
import '../logic/difficulty.dart';
import '../logic/format.dart';
import '../logic/high_score.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  final ScoreStorage _storage = ScoreStorage();
  Map<Difficulty, HighScore?> _scores = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final map = <Difficulty, HighScore?>{};
    for (final d in Difficulty.values) {
      map[d] = await _storage.read(d);
    }
    if (mounted) {
      setState(() {
        _scores = map;
        _loading = false;
      });
    }
  }

  Future<void> _clearScores() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar marcadores'),
        content: const Text('¿Estás seguro de que deseas borrar todos los récords?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.clearAll();
      await _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyScore = _scores.values.any((s) => s != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcadores'),
        actions: [
          if (hasAnyScore)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar marcadores',
              onPressed: _clearScores,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !hasAnyScore
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aún no hay récords guardados.\n¡Juega una partida para registrar tu tiempo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: Difficulty.values.map((d) {
                    final score = _scores[d];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dificultad: ${d.label}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Divider(),
                            if (score == null)
                              const Text('Sin partidas ganadas aún.',
                                  style: TextStyle(fontStyle: FontStyle.italic))
                            else ...[
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Mejor tiempo: ${formatDuration(score.bestTime)}'),
                                  const Spacer(),
                                  Text(formatDate(score.bestTimeDate),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.touch_app_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Menos movimientos: ${score.fewestMoves}'),
                                  const Spacer(),
                                  Text(formatDate(score.fewestMovesDate),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}