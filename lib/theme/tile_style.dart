/// Estilos visuales de las piezas.
enum TileStyle {
  classic('Clásico'),
  colorful('Colorido'),
  retro('Retro'),
  minimal('Minimalista');

  const TileStyle(this.label);

  final String label;

  static TileStyle fromName(String? name) =>
      TileStyle.values.firstWhere((s) => s.name == name, orElse: () => TileStyle.classic);
}
