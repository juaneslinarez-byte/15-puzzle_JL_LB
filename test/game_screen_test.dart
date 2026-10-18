import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/data/app_storage.dart';
import 'package:puzzle15/logic/difficulty.dart';
import 'package:puzzle15/logic/game_session.dart';
import 'package:puzzle15/logic/puzzle.dart';
import 'package:puzzle15/screens/game_screen.dart';
import 'package:puzzle15/state/app_scope.dart';
import 'package:puzzle15/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpAlmostSolved(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final session = GameSession.withPuzzle(Difficulty.easy, Puzzle.fromTiles(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]));
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController(AppStorage(await SharedPreferences.getInstance()));
    await tester.pumpWidget(
      AppScope(
        settings: settings,
        child: MaterialApp(
          home: GameScreen(difficulty: Difficulty.easy, initialSession: session),
        ),
      ),
    );
  }

  testWidgets('al ordenar la última pieza se muestra la pantalla de victoria', (tester) async {
    await pumpAlmostSolved(tester);
    expect(find.text('¡Ganaste!'), findsNothing);

    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('Movimientos'), findsWidgets);
    expect(find.text('Fácil · 3x3'), findsWidgets);
  });

  testWidgets('Reiniciar cierra el resultado y empieza un tablero nuevo', (tester) async {
    await pumpAlmostSolved(tester);
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();

    expect(find.text('¡Ganaste!'), findsNothing);
    expect(find.text('Toca una pieza junto al hueco para empezar'), findsOneWidget);
  });

  testWidgets('la flecha izquierda mueve la pieza que está a la derecha del hueco', (tester) async {
    await pumpAlmostSolved(tester);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    expect(find.text('¡Ganaste!'), findsOneWidget);
  });

  testWidgets('una flecha sin pieza que mover no cuenta como movimiento', (tester) async {
    await pumpAlmostSolved(tester);
    await tester.pump();

    // El hueco está en la fila de abajo: no hay pieza debajo para subir.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    expect(find.text('Toca una pieza junto al hueco para empezar'), findsOneWidget);
  });
}
