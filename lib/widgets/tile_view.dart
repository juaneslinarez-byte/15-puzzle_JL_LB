import 'package:flutter/material.dart';

import '../theme/tile_style.dart';

/// Colores y forma de una pieza según el estilo elegido.
class TileLook {
  const TileLook({
    required this.background,
    required this.foreground,
    required this.radius,
    this.border,
    this.fontFamily,
    this.fontWeight = FontWeight.w700,
    this.shadow = true,
  });

  final Color background;
  final Color foreground;
  final double radius;
  final BorderSide? border;
  final String? fontFamily;
  final FontWeight fontWeight;
  final bool shadow;

  static TileLook of(TileStyle style, ColorScheme scheme, int value, int pieces) {
    final dark = scheme.brightness == Brightness.dark;
    switch (style) {
      case TileStyle.classic:
        return TileLook(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
          radius: 14,
        );
      case TileStyle.colorful:
        // Cada número tiene su propio tono, repartidos por el círculo cromático.
        final hue = (value - 1) / pieces * 300;
        return TileLook(
          background: HSLColor.fromAHSL(1, hue, 0.62, dark ? 0.42 : 0.52).toColor(),
          foreground: Colors.white,
          radius: 14,
        );
      case TileStyle.retro:
        return const TileLook(
          background: Color(0xFFEAD7A8),
          foreground: Color(0xFF5B3A1E),
          radius: 4,
          border: BorderSide(color: Color(0xFF8A5A2B), width: 3),
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
        );
      case TileStyle.minimal:
        return TileLook(
          background: scheme.surface,
          foreground: scheme.onSurface,
          radius: 10,
          border: BorderSide(color: scheme.outlineVariant, width: 1.5),
          fontWeight: FontWeight.w300,
          shadow: false,
        );
    }
  }
}

/// Una pieza numerada del tablero.
class TileView extends StatelessWidget {
  const TileView({
    super.key,
    required this.value,
    required this.pieces,
    required this.size,
    required this.style,
    this.isCorrect = false,
    this.canMove = false,
    this.onTap,
  });

  final int value;
  final int pieces;
  final double size;
  final TileStyle style;
  final bool isCorrect;
  final bool canMove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final look = TileLook.of(style, scheme, value, pieces);
    // En piezas pequeñas (vistas previas, 5x5) el radio se reduce para que no queden redondas.
    final radius = BorderRadius.circular(look.radius.clamp(2, size * 0.18).toDouble());

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
              color: look.background,
              borderRadius: radius,
              border: look.border == null ? null : Border.fromBorderSide(look.border!),
              boxShadow: look.shadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: look.fontWeight,
                      fontFamily: look.fontFamily,
                      color: look.foreground,
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
                        color: look.foreground.withValues(alpha: 0.55),
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
