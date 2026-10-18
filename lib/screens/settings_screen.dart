import 'package:flutter/material.dart';

import '../logic/difficulty.dart';
import '../logic/puzzle.dart';
import '../state/app_scope.dart';
import '../theme/tile_style.dart';
import '../widgets/puzzle_board.dart';

/// Ajustes del juego. Cada cambio se guarda al momento.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _SectionTitle('Dificultad'),
                SegmentedButton<Difficulty>(
                  segments: [
                    for (final d in Difficulty.values)
                      ButtonSegment(
                        value: d,
                        label: Text('${d.label}\n${d.gridLabel}', textAlign: TextAlign.center),
                      ),
                  ],
                  selected: {settings.difficulty},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => settings.setDifficulty(s.first),
                ),
                const SizedBox(height: 8),
                Text(
                  '${settings.difficulty.pieces} piezas · tiempo límite de '
                  '${settings.difficulty.timeLimit.inMinutes} minutos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const _SectionTitle('Tema'),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Oscuro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('Automático'),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => settings.setThemeMode(s.first),
                ),
                const _SectionTitle('Estilo de las piezas'),
                LayoutBuilder(
                  builder: (context, c) {
                    final columns = c.maxWidth > 440 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                      children: [
                        for (final style in TileStyle.values)
                          _StyleOption(
                            style: style,
                            selected: settings.tileStyle == style,
                            onTap: () => settings.setTileStyle(style),
                          ),
                      ],
                    );
                  },
                ),
                const _SectionTitle('Otros'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: settings.animations,
                        onChanged: settings.setAnimations,
                        title: const Text('Animaciones'),
                        subtitle: const Text('Entradas de pantalla y deslizamiento de piezas'),
                        secondary: const Icon(Icons.animation),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        value: settings.sound,
                        onChanged: settings.setSound,
                        title: const Text('Efectos de sonido y vibración'),
                        subtitle: const Text('Clic al mover piezas (en dispositivos que lo admiten)'),
                        secondary: const Icon(Icons.volume_up_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
  );
}

/// Vista previa de un estilo con un tablero 3x3 de muestra.
class _StyleOption extends StatelessWidget {
  const _StyleOption({required this.style, required this.selected, required this.onTap});

  static final _sample = Puzzle.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]);

  final TileStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: 'Estilo ${style.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: IgnorePointer(
                  child: PuzzleBoard(puzzle: _sample, style: style, animate: false),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) Icon(Icons.check_circle, size: 18, color: scheme.primary),
                  if (selected) const SizedBox(width: 4),
                  Text(style.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
