// Service worker de 15-Puzzle.
//
// Al instalarse guarda en caché todos los archivos de la versión web, así el
// juego abre y se juega sin conexión. `tool/build_pwa.dart` reemplaza las dos
// marcas de abajo con la lista real de archivos y un número de versión cada
// vez que se compila; al cambiar la versión, se borra la caché vieja.
const VERSION = '__VERSION__';
const PRECACHE = __PRECACHE__;
const CACHE = `puzzle15-${VERSION}`;

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k.startsWith('puzzle15-') && k !== CACHE).map((k) => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  // Páginas: primero la red (para recibir actualizaciones) y, sin conexión, la caché.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put('./', copy));
          return response;
        })
        .catch(() => caches.match('./', { ignoreSearch: true }))
    );
    return;
  }

  // Resto de archivos: primero la caché; si no está, se descarga y se guarda
  // (incluye las fuentes que Flutter pide a fonts.gstatic.com).
  event.respondWith(
    caches.match(request, { ignoreSearch: true }).then((cached) => {
      if (cached) return cached;
      return fetch(request).then((response) => {
        if (response && (response.ok || response.type === 'opaque')) {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      });
    })
  );
});
