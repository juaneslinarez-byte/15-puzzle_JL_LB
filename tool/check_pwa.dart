// Verifica que la versión web siga siendo una PWA instalable y con modo sin
// conexión. Se ejecuta en GitHub Actions; si algo falta, el workflow falla.
//
// Uso: dart run tool/check_pwa.dart [carpeta_build]
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final root = args.isNotEmpty ? args.first : 'build/web';
  final errors = <String>[];

  void check(bool ok, String message) {
    stdout.writeln('${ok ? '✔' : '✘'} $message');
    if (!ok) errors.add(message);
  }

  // 1. Manifiesto con los campos que exigen los navegadores para instalar.
  final manifestFile = File('$root/manifest.json');
  check(manifestFile.existsSync(), 'existe manifest.json');
  if (manifestFile.existsSync()) {
    final m = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    for (final field in ['name', 'short_name', 'start_url', 'display', 'icons']) {
      check(m[field] != null, 'el manifiesto tiene "$field"');
    }
    check(['standalone', 'fullscreen', 'minimal-ui'].contains(m['display']),
        'display permite abrirla como app');
    final icons = (m['icons'] as List? ?? []).cast<Map<String, dynamic>>();
    for (final size in ['192x192', '512x512']) {
      final icon = icons.where((i) => i['sizes'] == size).toList();
      check(icon.isNotEmpty && File('$root/${icon.first['src']}').existsSync(),
          'icono de $size declarado y presente');
    }
  }

  // 2. index.html enlaza el manifiesto y registra el service worker.
  final index = File('$root/index.html');
  final html = index.existsSync() ? index.readAsStringSync() : '';
  check(html.contains('rel="manifest"'), 'index.html enlaza el manifiesto');
  check(html.contains("serviceWorker.register('sw.js')"), 'index.html registra sw.js');

  // 3. Service worker completo (lista de caché ya generada) para funcionar sin red.
  final sw = File('$root/sw.js');
  final swText = sw.existsSync() ? sw.readAsStringSync() : '';
  check(sw.existsSync(), 'existe sw.js');
  check(!swText.contains('__PRECACHE__') && !swText.contains('__VERSION__'),
      'sw.js tiene la lista de archivos (se corrió tool/build_pwa.dart)');
  for (final core in ['index.html', 'main.dart.js', 'flutter_bootstrap.js', 'manifest.json']) {
    check(swText.contains('"$core"'), 'sw.js guarda en caché $core');
  }
  check(swText.contains("addEventListener('fetch'"), 'sw.js responde peticiones sin conexión');
  check(Directory('$root/canvaskit').existsSync(),
      'CanvasKit va incluido en la app (no depende de un CDN externo)');

  if (errors.isNotEmpty) {
    stderr.writeln('\nLa app NO cumple como PWA: ${errors.length} problema(s).');
    exit(1);
  }
  stdout.writeln('\nLa app cumple como PWA instalable y sin conexión.');
}
