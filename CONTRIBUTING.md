# Guía de colaboración

Estas reglas mantienen el historial ordenado y permiten ver el aporte de cada integrante.

## Ramas (gitflow)

| Rama | Uso |
| --- | --- |
| `main` | Versión publicada. Cada integración despliega la web en GitHub Pages. |
| `develop` | Integración del trabajo en curso. |
| `feature/<nombre>` | Una funcionalidad, por ejemplo `feature/tablero` o `feature/marcadores`. |
| `fix/<nombre>` | Corrección de un error. |
| `docs/<nombre>` | Cambios de documentación. |

Flujo: se crea la rama desde `develop`, se trabaja en ella y se abre un pull request hacia `develop`. Para publicar, `develop` se integra en `main`.

## Commits

Mensajes cortos, en español y en imperativo, con un prefijo que indique el tipo de cambio:

| Prefijo | Cuándo usarlo | Ejemplo |
| --- | --- | --- |
| `feat:` | Nueva funcionalidad | `feat: agregar cronómetro a la partida` |
| `fix:` | Corrección de un error | `fix: detener el tiempo al pausar` |
| `docs:` | Documentación | `docs: explicar la regla de paridad` |
| `style:` | Formato o estilos, sin cambiar lógica | `style: ajustar colores del tema oscuro` |
| `refactor:` | Reorganizar código sin cambiar su comportamiento | `refactor: separar la lógica del tablero` |
| `test:` | Pruebas | `test: probar la detección de victoria` |
| `ci:` | GitHub Actions y despliegue | `ci: publicar la web en GitHub Pages` |
| `chore:` | Configuración y mantenimiento | `chore: agregar shared_preferences` |

Cada commit debe dejar la app compilando. No se suben commits vacíos ni cambios que se deshacen en el siguiente commit.

## Pull requests

1. Describe qué cambia y qué requisito del enunciado cubre.
2. Pide la revisión del otro integrante.
3. Integra solo cuando la revisión esté aprobada y el workflow pase (análisis, pruebas y verificación de la PWA).

## Antes de subir cambios

```bash
git pull
flutter analyze
flutter test
```
