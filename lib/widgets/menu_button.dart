import 'package:flutter/material.dart';

/// Botón grande del menú con animación al presionar: se encoge un poco y
/// cambia de color mientras el dedo o el clic están sobre él.
class MenuButton extends StatefulWidget {
  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = widget.primary ? scheme.primary : scheme.secondaryContainer;
    final fg = widget.primary ? scheme.onPrimary : scheme.onSecondaryContainer;
    final pressedColor = Color.alphaBlend(fg.withValues(alpha: 0.14), base);

    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            height: widget.primary ? 64 : 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _pressed ? pressedColor : base,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: fg),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: fg,
                      fontSize: widget.primary ? 20 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: fg.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
