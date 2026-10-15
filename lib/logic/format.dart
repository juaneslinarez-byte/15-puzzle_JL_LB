/// Formatea una duración como m:ss (o h:mm:ss si pasa de una hora).
String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$minutes:$seconds';
  return '${d.inMinutes}:$seconds';
}

/// Formatea una fecha como dd/mm/aaaa.
String formatDate(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
