# 15-Puzzle Flutter

Rompecabezas deslizante (*sliding puzzle*) para web y móvil hecho en Flutter. Se instala como aplicación (PWA) y funciona sin conexión.

El jugador ordena las piezas deslizándolas hacia el espacio vacío antes de que se acabe el tiempo. Hay tres dificultades, varios estilos visuales y un registro de récords por dificultad que se guarda en el dispositivo.

**Versión web:** https://juaneslinarez-byte.github.io/15-puzzle_JL_LB/ (se publica automáticamente cada vez que se integran cambios en `main`).

> Micro-proyecto de la asignatura **Sistemas de Información** (Sección 1, trimestre 2026-2027-1), Facultad de Ingeniería, UNIMET. Profesor: Franklin J. Sandoval S.

## Funcionalidades

| Pantalla | Qué ofrece | Estado |
| --- | --- | --- |
| Juego | Tablero 3x3, 4x4 o 5x5 siempre resoluble, contador de movimientos, cronómetro y tiempo restante, pausa, reinicio y controles con las flechas del teclado. | Disponible |
| Fin de partida | Victoria o derrota con tiempo, movimientos y dificultad; reiniciar o volver al menú. | Disponible |
| Inicio | Pantalla de carga animada con opción de saltarla. | Disponible |
| Menú principal | Botones animados; Jugar pide la dificultad antes de empezar. | Disponible |
| Marcadores | Mejor tiempo y menor número de movimientos por dificultad, con fecha. | En desarrollo |
| Configuración | Dificultad, tema claro / oscuro / automático, estilo de piezas, animaciones y sonido. | En desarrollo |
| Cómo jugar | Reglas, cómo mover, cómo se gana y cómo se pierde (tiempos por dificultad). | Disponible |

### Dificultades

| Nivel | Cuadrícula | Piezas | Tiempo límite |
| --- | --- | --- | --- |
| Fácil | 3x3 | 8 | 2 minutos |
| Medio | 4x4 | 15 | 5 minutos |
| Difícil | 5x5 | 24 | 10 minutos |

El cronómetro arranca con el primer movimiento. Si llega al límite antes de ordenar el tablero, la partida se pierde.

### Tableros siempre resolubles

La mitad de las formas de desordenar un 15-puzzle no tiene solución. Para evitarlo, el tablero se baraja al azar y se comprueba con la **paridad de inversiones**:

- En cuadrículas de ancho impar (3x3, 5x5) el tablero es resoluble si el número de inversiones es par.
- En cuadrículas de ancho par (4x4) también cuenta la fila del espacio vacío, contada desde abajo.

Si el barajado sale sin solución, se intercambian dos piezas, lo que cambia la paridad y lo vuelve resoluble. Las pruebas comparan esta regla con una búsqueda completa de los 181 440 tableros 3x3 alcanzables.

## Tecnologías

- **Flutter** (Dart), solo con `material.dart`.
- **shared_preferences** para guardar preferencias y récords en el dispositivo.
- **animate_do** para las animaciones de entrada.
- **GitHub Actions** y **GitHub Pages** para el despliegue de la versión web.

## Estructura del proyecto

```
lib/
├── logic/      Reglas del juego sin interfaz: tablero, partida, dificultad y récords
├── screens/    Pantallas de la app
└── widgets/    Componentes reutilizables (tablero, piezas, botones del menú y logo)
test/           Pruebas de la lógica y de la pantalla de juego
tool/           Scripts de la PWA (service worker y verificación)
web/            index.html, manifiesto, íconos y service worker
.github/        Workflow de GitHub Actions (pruebas y despliegue)
```

La lógica (`lib/logic`) no depende de Flutter: las pantallas solo le avisan los toques y el paso del tiempo y dibujan el resultado.

## Cómo ejecutar el proyecto

Requisitos: Flutter SDK (canal estable) y Google Chrome.

```bash
git clone https://github.com/juaneslinarez-byte/15-puzzle_JL_LB.git
cd 15-puzzle_JL_LB
flutter pub get
flutter run -d chrome
```

Pruebas:

```bash
flutter test
```

## Despliegue

El workflow `.github/workflows/deploy.yml` se ejecuta en cada pull request y en cada integración en `main`:

1. Análisis estático y pruebas.
2. Compilación de la versión web.
3. Generación del service worker (`tool/build_pwa.dart`), que guarda la app en caché para usarla sin conexión.
4. Verificación de que sigue siendo una PWA instalable (`tool/check_pwa.dart`).
5. Publicación en GitHub Pages (solo desde `main`).

## Equipo

- Juan Linarez
- Luis Bravo

## Cómo colaborar

Revisa [CONTRIBUTING.md](CONTRIBUTING.md) para conocer el flujo de ramas, el formato de los commits y cómo abrir un pull request.
