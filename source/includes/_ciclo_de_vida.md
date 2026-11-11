# Archivar, restaurar y eliminar

Los registros tienen tres estados de vida, igual que en la plataforma:

Estado | Qué significa | Cómo se ve en la API
------ | ------------- | --------------------
**Activo** | Se usa normalmente | Aparece en listados; se lee y se edita
**Archivado** | Ya no se usa, pero se conserva su historia | Sale de los listados normales; aparece con `archived=true` y en `updated_since`. Se lee, pero **no se edita** hasta restaurarlo
**Eliminado** | Se borró (borrado lógico) | No aparece en listados ni en el detalle (404). Solo aparece como lápida en `deleted_since`

<aside class="notice">Prefiere <strong>archivar</strong>. Eliminar solo está permitido cuando el registro no tiene historia que proteger (por ejemplo, un contacto sin folios ni facturas). Cuando no se puede eliminar, la API lo rechaza y te sugiere archivar.</aside>

## La decisión del ciclo de vida

`POST /:recurso/:id/archive`, `POST /:recurso/:id/restore` y `DELETE /:recurso/:id` no responden el registro: responden una **decisión** que dice qué pasó.

Campo | Descripción
----- | -----------
`outcome` | `allow` (se hizo), `confirm` (necesita confirmación, no se hizo nada) o `reject` (no se permite, no se hizo nada)
`code` | Motivo en formato máquina (`has_opportunities`, `will_mark_lost`, `archived_read_only`, …). Úsalo en tu lógica
`title`, `message` | Texto para mostrar a una persona
`suggested_action` | Lo que sí puedes hacer (`archive`, `restore`) o `null`

Outcome | HTTP | Qué hacer
------- | ---- | ---------
`allow` | 200 | Nada: el cambio quedó hecho
`confirm` | 422 | Repite la misma petición con `confirmed=true` si estás de acuerdo con lo que dice `message`
`reject` | 422 | No reintentes igual. Lee `code` y, si hay `suggested_action`, úsala

En 422 el cuerpo trae además `error` (igual a `code`), `errors` y `request_id`, como cualquier [error](#errores).

> Archivar · allow

```shell
curl -X POST https://control.apunto.io/api/v1/contacts/812/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "outcome": "allow",
  "code": null,
  "title": null,
  "message": null,
  "suggested_action": null
}
```

> Eliminar · reject

```shell
curl -X DELETE https://control.apunto.io/api/v1/contacts/812 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 422

```json
{
  "outcome": "reject",
  "code": "has_opportunities",
  "title": "No puedes eliminar este socio",
  "message": "Este socio tiene oportunidades, así que no puedes eliminarlo. Archívalo si ya no debe verse en tus listas.",
  "suggested_action": "archive",
  "errors": ["Este socio tiene oportunidades, así que no puedes eliminarlo. Archívalo si ya no debe verse en tus listas."],
  "error": "has_opportunities",
  "request_id": "0d5b3c55-6f0e-4a3e-9a47-3d1c8e9b2f40"
}
```

## Confirmar una acción

Algunas acciones tienen efectos además del cambio de estado. Por ejemplo, archivar una solicitud comercial abierta la marca como perdida. En esos casos la primera petición responde `confirm` sin cambiar nada; si estás de acuerdo, repítela con `confirmed=true` (en la URL o en el cuerpo) y los datos que pida la acción.

> Archivar · confirm

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/318/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 422

```json
{
  "outcome": "confirm",
  "code": "will_mark_lost",
  "title": "¿Archivar esta solicitud?",
  "message": "La solicitud quedará perdida y saldrá de tu trabajo diario. Las cotizaciones que todavía pueden perderse también quedarán perdidas.",
  "suggested_action": null,
  "errors": ["La solicitud quedará perdida y saldrá de tu trabajo diario. Las cotizaciones que todavía pueden perderse también quedarán perdidas."],
  "error": "will_mark_lost",
  "request_id": "a1f0e2c4-7d3b-4b8e-8f5a-6c2d9e0b1a77"
}
```

> Confirmar

```shell
curl -X POST "https://control.apunto.io/api/v1/quote_requests/318/archive?confirmed=true" \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "lost_at": "2026-11-11", "quote_lost_reason_id": 4, "result_notes": "El cliente pospuso el embarque" }'
```

Cada recurso documenta en su sección qué acciones piden confirmación y qué datos extra necesitan.

## Registros archivados son de solo lectura

Mientras un registro está archivado, cualquier cambio sobre él o sobre sus hijos (servicios de un folio archivado, líneas de centro de costos, comentarios, tareas, archivos) responde **422** con `code` `archived_read_only` y `suggested_action` `restore`. Restáuralo primero.

> Editar un archivado · 422

```json
{
  "outcome": "reject",
  "code": "archived_read_only",
  "title": "Está en Archivados",
  "message": "Está en Archivados. Restaúralo para modificarlo.",
  "suggested_action": "restore",
  "errors": ["Está en Archivados. Restaúralo para modificarlo."],
  "error": "archived_read_only",
  "request_id": "3b8e1f0a-9c2d-4e7f-b5a6-0d1c2e3f4a5b"
}
```

## Cómo verlos en listados

Parámetro | Resultado
--------- | ---------
Sin parámetro | Solo activos
`archived=true` | Solo archivados
`updated_since=…` | Activos y archivados que cambiaron (revisa `archived` en cada uno)
`deleted_since=…` | Lápidas de los eliminados

Ver [Sincronización incremental](#sincronizacion-incremental).

## Lo que no se puede por API

- **Recuperar un eliminado.** Un registro eliminado no se restaura por API. Si necesitas recuperarlo, contacta a soporte con su `id`.
- **Borrado definitivo.** La API nunca borra datos de forma física; eliminar siempre es lógico.
