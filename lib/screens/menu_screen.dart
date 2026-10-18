import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../logic/difficulty.dart';
import '../state/app_scope.dart';
import '../widgets/app_logo.dart';
import '../widgets/maybe_animate.dart';
import '../widgets/menu_button.dart';
import 'game_screen.dart';
import 'instructions_screen.dart';
import 'settings_screen.dart';

/// Menú principal. La dificultad sale de Configuración (SettingsController),
/// así que se recuerda aunque se cierre la app.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// La primera vez se pregunta la dificultad; después se usa la guardada
  /// (se puede cambiar en Configuración).
  Future<void> _play() async {
    final settings = AppScope.of(context).settings;
    var difficulty = settings.difficulty;
    if (!settings.difficultyChosen) {
      final chosen = await showDifficultyPicker(context, difficulty);
      if (chosen == null || !mounted) return;
      settings.setDifficulty(chosen);
      difficulty = chosen;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameScreen(difficulty: difficulty)));
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what estará disponible pronto')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final settings = AppScope.of(context).settings;

    return Scaffold(
      body: TiledBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaybeAnimate(
                      builder: (child) => FadeInDown(child: child),
                      child: const Center(child: AppLogo(size: 84)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '15-Puzzle',
                      textAlign: TextAlign.center,
                      style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    ListenableBuilder(
                      listenable: settings,
                      builder: (context, _) => Text(
                        settings.difficultyChosen
                            ? 'Dificultad: ${settings.difficulty.label} · ${settings.difficulty.gridLabel}'
                            : 'Ordena las piezas antes de que se acabe el tiempo',
                        textAlign: TextAlign.center,
                        style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 32),
                    MaybeAnimate(
                      builder: (child) => FadeInUp(
                        delay: const Duration(milliseconds: 0),
                        duration: const Duration(milliseconds: 450),
                        child: child,
                      ),
                      child: MenuButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Jugar',
                        primary: true,
                        onPressed: _play,
                      ),
                    ),
                    const SizedBox(height: 14),
                    MaybeAnimate(
                      builder: (child) => FadeInUp(
                        delay: const Duration(milliseconds: 120),
                        duration: const Duration(milliseconds: 450),
                        child: child,
                      ),
                      child: MenuButton(
                        icon: Icons.emoji_events_outlined,
                        label: 'Marcadores',
                        onPressed: () => _comingSoon('Marcadores'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    MaybeAnimate(
                      builder: (child) => FadeInUp(
                        delay: const Duration(milliseconds: 240),
                        duration: const Duration(milliseconds: 450),
                        child: child,
                      ),
                      child: MenuButton(
                        icon: Icons.tune,
                        label: 'Configuración',
                        onPressed: () =>
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ),
                    const SizedBox(height: 14),
                    MaybeAnimate(
                      builder: (child) => FadeInUp(
                        delay: const Duration(milliseconds: 360),
                        duration: const Duration(milliseconds: 450),
                        child: child,
                      ),
                      child: MenuButton(
                        icon: Icons.help_outline,
                        label: 'Cómo jugar',
                        onPressed: () =>
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const InstructionsScreen())),
                      ),
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

/// Diálogo para elegir la dificultad antes de empezar.
Future<Difficulty?> showDifficultyPicker(BuildContext context, Difficulty current) {
  return showDialog<Difficulty>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Elige la dificultad'),
      children: [
        for (final d in Difficulty.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, d),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(d == current ? Icons.radio_button_checked : Icons.radio_button_off),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${d.label} · ${d.gridLabel}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${d.timeLimit.inMinutes} min'),
              ],
            ),
          ),
      ],
    ),
  );
}
