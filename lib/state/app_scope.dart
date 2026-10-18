import 'package:flutter/widgets.dart';

import 'settings_controller.dart';

/// Pone las preferencias al alcance de todas las pantallas sin tener que
/// pasarlas de mano en mano por los constructores.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.settings, required super.child});

  final SettingsController settings;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No hay AppScope por encima de este widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => settings != oldWidget.settings;
}
