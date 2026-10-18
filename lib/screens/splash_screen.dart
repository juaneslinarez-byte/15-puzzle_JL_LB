import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/maybe_animate.dart';
import 'menu_screen.dart';

/// Pantalla de carga: logo animado y paso automático al menú.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), _goToMenu);
  }

  /// Se llama al terminar el tiempo o al pulsar "Saltar"; `_left` evita
  /// navegar dos veces si pasan las dos cosas.
  void _goToMenu() {
    if (_left || !mounted) return;
    _left = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const MenuScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaybeAnimate(
                    builder: (child) => ZoomIn(duration: const Duration(milliseconds: 700), child: child),
                    child: const AppLogo(size: 120),
                  ),
                  const SizedBox(height: 28),
                  MaybeAnimate(
                    builder: (child) => FadeInUp(delay: const Duration(milliseconds: 350), child: child),
                    child: Text(
                      '15-Puzzle Flutter',
                      style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  MaybeAnimate(
                    builder: (child) => FadeIn(delay: const Duration(milliseconds: 700), child: child),
                    child: Text(
                      'Ordena. Desliza. Gana.',
                      style: text.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: TextButton.icon(
                onPressed: _goToMenu,
                icon: const Icon(Icons.skip_next),
                label: const Text('Saltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
