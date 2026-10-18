import 'package:flutter/widgets.dart';

import '../state/app_scope.dart';

/// Aplica una animación de entrada solo si el usuario tiene las
/// animaciones activadas en Configuración.
class MaybeAnimate extends StatelessWidget {
  const MaybeAnimate({super.key, required this.builder, required this.child});

  final Widget Function(Widget child) builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = AppScope.of(context).settings.animations;
    return enabled ? builder(child) : child;
  }
}
