import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/data/score_storage.dart';
import 'package:puzzle15/logic/difficulty.dart';
import 'package:puzzle15/logic/high_score.dart';
import 'package:puzzle15/screens/scores_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Abre Marcadores encima de una pantalla de "menú" para poder volver.
  Future<void> openScores(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScoresScreen())),
                child: const Text('Menú de prueba'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Menú de prueba'));
    await tester.pumpAndSettle();
  }

  testWidgets('sin récords muestra un mensaje amigable', (tester) async {
    await openScores(tester);
    expect(find.textContaining('Aún no hay récords'), findsOneWidget);
    expect(find.byTooltip('Borrar marcadores'), findsNothing);
  });

  testWidgets('el botón Volver al menú regresa a la pantalla anterior', (tester) async {
    await openScores(tester);
    await tester.tap(find.text('Volver al menú'));
    await tester.pumpAndSettle();
    expect(find.text('Menú de prueba'), findsOneWidget);
  });

  testWidgets('borrar pide confirmación antes de eliminar los récords', (tester) async {
    final date = DateTime(2026, 10, 18);
    await ScoreStorage().write(
      Difficulty.medium,
      HighScore(
        bestTime: const Duration(minutes: 2),
        bestTimeDate: date,
        fewestMoves: 80,
        fewestMovesDate: date,
      ),
    );
    await openScores(tester);
    expect(find.text('Menos movimientos: 80'), findsOneWidget);

    await tester.tap(find.byTooltip('Borrar marcadores'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Menos movimientos: 80'), findsOneWidget);

    await tester.tap(find.byTooltip('Borrar marcadores'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aún no hay récords'), findsOneWidget);
    expect(await ScoreStorage().read(Difficulty.medium), isNull);
  });
}
