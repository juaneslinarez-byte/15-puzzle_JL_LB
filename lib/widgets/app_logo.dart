import 'package:flutter/material.dart';

/// Logo del juego: un tablero 3x3 en miniatura con el hueco abajo a la derecha.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gap = size * 0.06;
    final tile = (size - gap * 4) / 3;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      padding: EdgeInsets.all(gap),
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < 9; i++)
            Container(
              width: tile,
              height: tile,
              decoration: BoxDecoration(
                color: i == 8
                    ? Colors.transparent
                    : scheme.onPrimary.withValues(alpha: i == 7 ? 0.55 : 0.92),
                borderRadius: BorderRadius.circular(tile * 0.22),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fondo decorativo: cuadrados tenues dispersos, como piezas sueltas.
class TiledBackground extends StatelessWidget {
  const TiledBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TilesPainter(Theme.of(context).colorScheme.primary),
      child: child,
    );
  }
}

class _TilesPainter extends CustomPainter {
  _TilesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.06);
    const cell = 72.0;
    for (var y = 0.0; y < size.height + cell; y += cell) {
      for (var x = 0.0; x < size.width + cell; x += cell) {
        // Patrón fijo (sin azar) para que no "salte" al redibujar.
        final skip = ((x / cell).floor() * 7 + (y / cell).floor() * 3) % 5 == 0;
        if (skip) continue;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 6, y + 6, cell - 12, cell - 12),
          const Radius.circular(12),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TilesPainter old) => old.color != color;
}
