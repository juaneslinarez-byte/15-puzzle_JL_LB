import 'package:flutter/material.dart';

/// Una pieza numerada del tablero.
class TileView extends StatelessWidget {
  const TileView({
    super.key,
    required this.value,
    required this.size,
    this.isCorrect = false,
    this.canMove = false,
    this.onTap,
  });

  final int value;
  final double size;
  final bool isCorrect;
  final bool canMove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = scheme.primaryContainer;
    final foreground = scheme.onPrimaryContainer;
    // En piezas pequeñas (5x5) el radio se reduce para que no queden redondas.
    final radius = BorderRadius.circular((size * 0.18).clamp(2, 14).toDouble());

    return Semantics(
      button: canMove,
      label: 'Pieza $value${canMove ? ', se puede mover' : ''}',
      child: MouseRegion(
        cursor: canMove ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      height: 1,
                    ),
                  ),
                ),
                // Punto pequeño que indica que la pieza ya está en su lugar.
                if (isCorrect)
                  Positioned(
                    right: size * 0.1,
                    bottom: size * 0.1,
                    child: Container(
                      width: size * 0.08,
                      height: size * 0.08,
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
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
