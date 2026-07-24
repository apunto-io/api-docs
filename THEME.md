# Tema visual — documentación API (Slate)

## Modo claro y oscuro

- Tokens en `source/stylesheets/_theme.scss` (`data-theme="light"|"dark"` en `<html>`).
- Toggle en la barra lateral; preferencia en `localStorage` (`apunto-docs-theme`).
- Sin elección guardada, se usa `prefers-color-scheme`.

## UI de referencia

- Estilos en `source/stylesheets/_docs-ui.scss`: sidebar, tablas de parámetros, encabezados de endpoint, avisos.
- Sidebar: 260px, etiqueta **API Reference · v1**, búsqueda con borde redondeado.

## Archivos tocados

| Archivo | Rol |
|---------|-----|
| `source/layouts/layout.erb` | Script anti-FOUC, header sidebar, botón tema |
| `source/javascripts/app/_theme.js` | Toggle y sync con sistema |
| `source/stylesheets/_theme.scss` | Variables CSS |
| `source/stylesheets/_docs-ui.scss` | Componentes |

## Vista local

```bash
cd apunto-api-docs && ./start-docs.sh
# http://localhost:4567
```
