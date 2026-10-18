/// Niveles de dificultad del juego.
///
/// Cada nivel define el tamaño de la cuadrícula y el tiempo límite.
/// Si el cronómetro llega al límite antes de ordenar el tablero, se pierde.
enum Difficulty {
  easy('Fácil', 3, Duration(minutes: 2)),
  medium('Medio', 4, Duration(minutes: 5)),
  hard('Difícil', 5, Duration(minutes: 10));

  const Difficulty(this.label, this.size, this.timeLimit);

  /// Nombre que ve el usuario.
  final String label;

  /// Número de filas y columnas de la cuadrícula.
  final int size;

  /// Tiempo máximo para resolver el tablero.
  final Duration timeLimit;

  /// Cantidad de piezas numeradas (sin contar el espacio vacío).
  int get pieces => size * size - 1;

  /// Texto corto para mostrar el tamaño, por ejemplo "4x4".
  String get gridLabel => '${size}x$size';

  static Difficulty fromName(String? name) => Difficulty.values.firstWhere(
        (d) => d.name == name,
        orElse: () => Difficulty.medium,
      );
}
