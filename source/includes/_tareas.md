# Tareas

<p class="lead">Las tareas (<code>to_dos</code>) son pendientes con fecha dentro de un folio operativo o de un servicio: «Solicitar carta de instrucciones», «Confirmar booking». Una integración las usa para abrir seguimientos desde su sistema y marcarlos como hechos cuando ocurren.</p>

- Viven dentro de su folio (`/operations/:operation_id/to_dos`) o servicio (`/services/:service_id/to_dos`). Una tarea solo se encuentra a través de su padre: con otro folio o servicio en la URL responde **404**.
- Leer necesita permiso para ver el folio o servicio (`operations_read` / `services_read`); crear, editar, completar o borrar necesita permiso para editarlo (`operations_edit` / `services_edit`). Ver [Permisos y alcance](#permisos-y-alcance).
- `completed` solo cambia con [Completar una tarea](#completar-una-tarea), que registra quién y cuándo. Si mandas `completed` en un alta o cambio, se ignora. La API no reabre una tarea completada.
- **La API no asigna tareas.** No acepta `assignee_id`, correos de responsables ni equipos: la tarea queda a nombre del usuario del token (`owner`). Asigna responsables desde la plataforma; los asignados no vienen en la respuesta.
- Una tarea obligatoria (`required: true`) sin completar impide avanzar el servicio a una etapa posterior de su tablero.
- En un folio o servicio archivado, o en un servicio cuyo folio está archivado, las tareas se leen pero no se crean, editan, completan ni borran: responde **422** `archived_read_only`. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
- Crear, editar o completar una tarea actualiza `updated_at` del folio o servicio. El detalle de un [folio](#folios-operativos) o [servicio](#servicios) incluye sus 100 tareas más recientes en `to_dos`.

## El objeto tarea

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la tarea.
`title` | string | Título.
`completed` | boolean | <span class="ro">solo lectura</span> `true` cuando se completó. Cambia solo con `POST .../complete`.
`rejected` | boolean | Marca de rechazo. Una tarea completada y no rechazada cuenta como aprobada. `false` por omisión.
`required` | boolean | Obligatoria. `false` por omisión.
`start_at` | datetime | Inicio. `null` si no tiene.
`end_at` | datetime | Fecha límite (vencimiento). `null` si no tiene.
`owner` | object | <span class="ro">solo lectura</span> Quien creó la tarea. Por API, el usuario del token.
`owner.email` | string | <span class="ro">solo lectura</span> Correo.
`owner.name` | string | <span class="ro">solo lectura</span> Nombre.
`completed_at` | datetime | <span class="ro">solo lectura</span> Cuándo se completó.
`completed_by` | object | <span class="ro">solo lectura</span> Quién la completó: `email` y `name`. `null` si está pendiente.
`created_at` | datetime | <span class="ro">solo lectura</span> Fecha de creación.
`updated_at` | datetime | <span class="ro">solo lectura</span> Última modificación.
`description` | string | Descripción en HTML (texto enriquecido), envuelta en `<div class="trix-content">…</div>`. `null` si no tiene. **Solo en el detalle**, no en el listado.
`deleted_at` | datetime | <span class="ro">solo lectura</span> Siempre `null` en una tarea viva. **Solo en el detalle.**

> Objeto tarea

```json
{
  "id": 3307,
  "title": "Solicitar carta de instrucciones al cliente",
  "completed": true,
  "rejected": false,
  "required": true,
  "start_at": "2026-11-11T09:00:00.000-06:00",
  "end_at": "2026-11-13T18:00:00.000-06:00",
  "owner": {
    "email": "integracion@tuempresa.mx",
    "name": "Integración ERP"
  },
  "completed_at": "2026-11-12T16:40:12.380-06:00",
  "completed_by": {
    "email": "laura@tuempresa.mx",
    "name": "Laura Méndez"
  },
  "created_at": "2026-11-11T08:55:31.207-06:00",
  "updated_at": "2026-11-12T16:40:12.391-06:00",
  "description": "<div class=\"trix-content\">\n  Pedir la carta firmada antes del arribo del buque.\n</div>\n",
  "deleted_at": null
}
```

## Listar tareas

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/to_dos</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/to_dos</code></div>

<p class="perm">Permiso: <code>operations_read</code> (folio) o <code>services_read</code> (servicio)</p>

Devuelve las tareas vivas del folio o servicio, de la más reciente a la más antigua. Cada elemento trae todos los campos menos `description` y `deleted_at`. Con `updated_since` el orden cambia a `updated_at` ascendente.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`completed` | string | <span class="opt">opcional</span> `true` lista solo las completadas; cualquier otro valor (`false`) lista solo las pendientes. Sin él, todas.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de tareas traen `id`, `deleted`, `deleted_at` y `updated_at`.

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations/1042/to_dos?completed=false" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "to_dos": [
    {
      "id": 3311,
      "title": "Confirmar booking con la naviera",
      "completed": false,
      "rejected": false,
      "required": false,
      "start_at": null,
      "end_at": "2026-11-14T12:00:00.000-06:00",
      "owner": {
        "email": "integracion@tuempresa.mx",
        "name": "Integración ERP"
      },
      "completed_at": null,
      "completed_by": null,
      "created_at": "2026-11-12T10:05:44.018-06:00",
      "updated_at": "2026-11-12T10:05:44.018-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El folio o servicio no existe o no lo puedes ver.
`422` `invalid_parameter` | `updated_since` o `deleted_since` no es una fecha válida.

## Obtener una tarea

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/to_dos/:id</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/to_dos/:id</code></div>

<p class="perm">Permiso: <code>operations_read</code> (folio) o <code>services_read</code> (servicio)</p>

Devuelve la tarea completa, con `description` y `deleted_at`, dentro de `to_do`.

> Petición

```shell
curl https://control.apunto.io/api/v1/operations/1042/to_dos/3307 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "to_do": {
    "id": 3307,
    "title": "Solicitar carta de instrucciones al cliente",
    "completed": false,
    "rejected": false,
    "required": true,
    "start_at": "2026-11-11T09:00:00.000-06:00",
    "end_at": "2026-11-13T18:00:00.000-06:00",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "completed_at": null,
    "completed_by": null,
    "created_at": "2026-11-11T08:55:31.207-06:00",
    "updated_at": "2026-11-11T08:55:31.207-06:00",
    "description": "<div class=\"trix-content\">\n  Pedir la carta firmada antes del arribo del buque.\n</div>\n",
    "deleted_at": null
  }
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El folio o servicio no existe o no lo puedes ver, o la tarea no es de ese folio o servicio o ya se borró («Tarea no encontrada»).

## Crear una tarea

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:operation_id/to_dos</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:service_id/to_dos</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Crea una tarea pendiente en el folio o servicio. Queda a nombre del usuario del token.

### Cuerpo de la petición

Va dentro del objeto `to_do`. Cualquier otro campo (`completed`, `owner_id`, `assignee_id`, …) se ignora.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`title` | string | <span class="req">obligatorio</span> Título.
`description` | string | <span class="opt">opcional</span> Texto plano o HTML.
`start_at` | datetime | <span class="opt">opcional</span> Inicio. Ver [Convenciones](#convenciones).
`end_at` | datetime | <span class="opt">opcional</span> Fecha límite.
`required` | boolean | <span class="opt">opcional</span> Obligatoria. `false` por omisión.
`rejected` | boolean | <span class="opt">opcional</span> Marca de rechazo. `false` por omisión.

<aside class="warning">Una fecha que no se puede interpretar en <code>start_at</code> o <code>end_at</code> se guarda vacía, sin error. Revisa esos campos en la respuesta.</aside>

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/to_dos \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "to_do": {
      "title": "Solicitar carta de instrucciones al cliente",
      "description": "Pedir la carta firmada antes del arribo del buque.",
      "start_at": "2026-11-11T09:00:00-06:00",
      "end_at": "2026-11-13T18:00:00-06:00",
      "required": true
    }
  }'
```

```javascript
const { status, body } = await api("/operations/1042/to_dos", {
  method: "POST",
  body: JSON.stringify({
    to_do: {
      title: "Solicitar carta de instrucciones al cliente",
      description: "Pedir la carta firmada antes del arribo del buque.",
      start_at: "2026-11-11T09:00:00-06:00",
      end_at: "2026-11-13T18:00:00-06:00",
      required: true,
    },
  }),
});
```

```python
res = api.post(f"{BASE}/operations/1042/to_dos", json={
    "to_do": {
        "title": "Solicitar carta de instrucciones al cliente",
        "description": "Pedir la carta firmada antes del arribo del buque.",
        "start_at": "2026-11-11T09:00:00-06:00",
        "end_at": "2026-11-13T18:00:00-06:00",
        "required": True,
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "to_do": {
    "id": 3307,
    "title": "Solicitar carta de instrucciones al cliente",
    "completed": false,
    "rejected": false,
    "required": true,
    "start_at": "2026-11-11T09:00:00.000-06:00",
    "end_at": "2026-11-13T18:00:00.000-06:00",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "completed_at": null,
    "completed_by": null,
    "created_at": "2026-11-11T08:55:31.207-06:00",
    "updated_at": "2026-11-11T08:55:31.207-06:00",
    "description": "<div class=\"trix-content\">\n  Pedir la carta firmada antes del arribo del buque.\n</div>\n",
    "deleted_at": null
  },
  "message": "Tarea creada exitosamente"
}
```

### Respuesta

**201** con la tarea completa en `to_do` y un texto en `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `title` («Title no puede estar en blanco»).
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.
`404` `not_found` | El folio o servicio no existe o no lo puedes ver.

> Error 422

```json
{
  "errors": ["Title no puede estar en blanco"],
  "message": "No se pudo crear la tarea",
  "error": "validation_failed",
  "request_id": "2d6f8a0c-4e1b-4c3d-a5f7-9b1d3e5f7a9c"
}
```

## Actualizar una tarea

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/operations/:operation_id/to_dos/:id</code></div>
<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/services/:service_id/to_dos/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Cambia solo los campos que mandas; lo demás queda igual. `PUT` funciona igual. Acepta los mismos campos que el alta (`title`, `description`, `start_at`, `end_at`, `required`, `rejected`). Para vaciar una fecha mándala en `null`. `completed` se ignora: usa [Completar una tarea](#completar-una-tarea).

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/operations/1042/to_dos/3307 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "to_do": { "end_at": "2026-11-14T12:00:00-06:00" } }'
```

> Respuesta 200

```json
{
  "to_do": {
    "id": 3307,
    "title": "Solicitar carta de instrucciones al cliente",
    "completed": false,
    "rejected": false,
    "required": true,
    "start_at": "2026-11-11T09:00:00.000-06:00",
    "end_at": "2026-11-14T12:00:00.000-06:00",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "completed_at": null,
    "completed_by": null,
    "created_at": "2026-11-11T08:55:31.207-06:00",
    "updated_at": "2026-11-12T08:10:02.551-06:00",
    "description": "<div class=\"trix-content\">\n  Pedir la carta firmada antes del arribo del buque.\n</div>\n",
    "deleted_at": null
  },
  "message": "Tarea actualizada exitosamente"
}
```

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | `title` vacío.
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.
`404` `not_found` | La tarea no existe, ya se borró o no es de ese folio o servicio.

## Completar una tarea

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:operation_id/to_dos/:id/complete</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:service_id/to_dos/:id/complete</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Marca la tarea como completada: `completed` pasa a `true`, `completed_at` toma la hora actual y `completed_by` es el usuario del token. No lleva cuerpo. Si la tarea ya estaba completada, vuelve a registrar quién y cuándo.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/to_dos/3307/complete \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "to_do": {
    "id": 3307,
    "title": "Solicitar carta de instrucciones al cliente",
    "completed": true,
    "rejected": false,
    "required": true,
    "start_at": "2026-11-11T09:00:00.000-06:00",
    "end_at": "2026-11-14T12:00:00.000-06:00",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "completed_at": "2026-11-12T16:40:12.380-06:00",
    "completed_by": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "created_at": "2026-11-11T08:55:31.207-06:00",
    "updated_at": "2026-11-12T16:40:12.391-06:00",
    "description": "<div class=\"trix-content\">\n  Pedir la carta firmada antes del arribo del buque.\n</div>\n",
    "deleted_at": null
  },
  "message": "Tarea completada exitosamente"
}
```

### Errores

Código | Cuándo
------ | ------
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.
`404` `not_found` | La tarea no existe, ya se borró o no es de ese folio o servicio.

## Eliminar una tarea

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/operations/:operation_id/to_dos/:id</code></div>
<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/services/:service_id/to_dos/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Borra la tarea (borrado lógico) y registra quién la borró. Deja de aparecer en el listado y sale como lápida en `deleted_since`. Cualquier usuario con permiso de edición puede borrar cualquier tarea del folio o servicio, no solo las suyas.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/operations/1042/to_dos/3307 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "message": "Tarea eliminada exitosamente" }
```

### Errores

Código | Cuándo
------ | ------
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.
`404` `not_found` | La tarea no existe, ya se borró o no es de ese folio o servicio.
