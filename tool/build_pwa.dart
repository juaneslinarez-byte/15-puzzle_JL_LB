// Completa el service worker después de `flutter build web`.
//
// Uso: dart run tool/build_pwa.dart [carpeta_build]
// Recorre build/web, arma la lista de archivos a guardar en caché y la
// escribe dentro de build/web/sw.js junto con un número de versión.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final root = Directory(args.isNotEmpty ? args.first : 'build/web');
  final sw = File('${root.path}/sw.js');
  if (!sw.existsSync()) {
    stderr.writeln('No existe ${sw.path}. ¿Ejecutaste flutter build web?');
    exit(1);
  }

  const skip = {'sw.js', 'flutter_service_worker.js', '.last_build_id'};
  final files = <String>['./'];
  var totalBytes = 0;
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    final rel = entity.path
        .substring(root.path.length + 1)
        .replaceAll(Platform.pathSeparator, '/');
    if (skip.contains(rel) ||
        rel.endsWith('.map') ||
        rel.endsWith('.symbols') ||
        rel == 'assets/NOTICES' ||
        _unusedRenderer(rel)) {
      continue;
    }
    files.add(rel);
    totalBytes += entity.lengthSync();
  }
  files.sort();

  final version = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
  final content = sw
      .readAsStringSync()
      .replaceFirst('__VERSION__', version)
      .replaceFirst('__PRECACHE__', const JsonEncoder.withIndent('  ').convert(files));
  sw.writeAsStringSync(content);

  stdout.writeln('sw.js listo: ${files.length} archivos '
      '(${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB), versión $version');
}

/// Variantes del motor gráfico que la compilación JavaScript no usa
/// (son para compilaciones --wasm o experimentales). No se precargan para
/// no bajar ~15 MB de más; si alguna se llegara a pedir, el service worker
/// la guarda en caché en ese momento.
bool _unusedRenderer(String rel) =>
    rel.startsWith('canvaskit/skwasm') ||
    rel.startsWith('canvaskit/wimp') ||
    rel.startsWith('canvaskit/webparagraph/');
