# Comentarios

<p class="lead">Los comentarios (<code>messages</code>) son la conversación interna de un folio operativo o de un servicio: lo que el equipo anota sobre el embarque. Una integración los usa para dejar constancia de eventos de su sistema («Pedimento pagado») o para leer lo que escribió el equipo.</p>

- Viven dentro de su folio (`/operations/:operation_id/messages`) o servicio (`/services/:service_id/messages`). Un comentario solo se encuentra a través de su padre: con otro folio o servicio en la URL responde **404**.
- Leer necesita permiso para ver el folio o servicio (`operations_read` / `services_read`); crear, editar o borrar necesita permiso para editarlo (`operations_edit` / `services_edit`). Ver [Permisos y alcance](#permisos-y-alcance).
- **Solo el autor** edita o borra su comentario. Un administrador o el dueño de la cuenta también puede. El autor de lo que crea tu integración es el usuario del token.
- En un folio o servicio archivado, o en un servicio cuyo folio está archivado, los comentarios se leen pero no se crean, editan ni borran: responde **422** `archived_read_only`. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
- Crear o editar un comentario actualiza `updated_at` del folio o servicio.

## El objeto comentario

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id del comentario.
`content` | string | Texto del comentario en HTML (texto enriquecido). Al leerlo viene envuelto en `<div class="trix-content">…</div>`. Ver [Formato de los comentarios](#formato-de-los-comentarios).
`owner` | object | <span class="ro">solo lectura</span> Autor. `null` si no tiene.
`owner.email` | string | <span class="ro">solo lectura</span> Correo del autor.
`owner.name` | string | <span class="ro">solo lectura</span> Nombre del autor.
`edited` | boolean | <span class="ro">solo lectura</span> `true` si se editó después de crearlo (más de 5 segundos entre `created_at` y `updated_at`).
`created_at` | datetime | <span class="ro">solo lectura</span> Fecha de creación.
`updated_at` | datetime | <span class="ro">solo lectura</span> Última modificación.

> Objeto comentario

```json
{
  "id": 6120,
  "content": "<div class=\"trix-content\">\n  Pedimento 26 47 3912 6001234 pagado. Listo para modular.\n</div>\n",
  "owner": {
    "email": "integracion@tuempresa.mx",
    "name": "Integración ERP"
  },
  "edited": false,
  "created_at": "2026-11-12T09:20:05.114-06:00",
  "updated_at": "2026-11-12T09:20:05.114-06:00"
}
```

## Formato de los comentarios

- `content` acepta texto plano o HTML como el que produce el editor de la plataforma (`<div>`, `<br>`, `<strong>`, `<em>`, `<a href>`, listas). La plataforma lo muestra como HTML: para separar párrafos usa `<br>` o un `<div>` por párrafo.
- Al leer, `content` siempre viene envuelto en `<div class="trix-content">…</div>`. Si guardas el texto en tu sistema, quita esa envoltura o conviértelo a texto plano.
- **Menciones.** La API no crea menciones. En la plataforma una mención es un elemento especial del editor que la API no expone; un `@Laura` escrito en el texto se guarda como texto y no notifica a nadie.
- **Adjuntos.** Los comentarios de la API no llevan archivos. Sube el archivo a una carpeta del folio con [Subir un archivo](#subir-un-archivo) y, si quieres, menciona su nombre en el comentario.

## Listar comentarios

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/messages</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/messages</code></div>

<p class="perm">Permiso: <code>operations_read</code> (folio) o <code>services_read</code> (servicio)</p>

Devuelve los comentarios del folio o servicio, del más reciente al más antiguo. Con `updated_since` el orden cambia a `updated_at` ascendente.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de comentarios traen `id`, `deleted`, `deleted_at` y `updated_at`.

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations/1042/messages?per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "messages": [
    {
      "id": 6121,
      "content": "<div class=\"trix-content\">\n  El cliente confirma entrega en almacén de Querétaro.\n</div>\n",
      "owner": {
        "email": "laura@tuempresa.mx",
        "name": "Laura Méndez"
      },
      "edited": false,
      "created_at": "2026-11-12T11:02:47.930-06:00",
      "updated_at": "2026-11-12T11:02:47.930-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El folio o servicio no existe o no lo puedes ver.
`422` `invalid_parameter` | `updated_since` o `deleted_since` no es una fecha válida.

## Obtener un comentario

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/messages/:id</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/messages/:id</code></div>

<p class="perm">Permiso: <code>operations_read</code> (folio) o <code>services_read</code> (servicio)</p>

Devuelve un comentario dentro de `message`.

> Petición

```shell
curl https://control.apunto.io/api/v1/operations/1042/messages/6120 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "message": {
    "id": 6120,
    "content": "<div class=\"trix-content\">\n  Pedimento 26 47 3912 6001234 pagado. Listo para modular.\n</div>\n",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "edited": false,
    "created_at": "2026-11-12T09:20:05.114-06:00",
    "updated_at": "2026-11-12T09:20:05.114-06:00"
  }
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El folio o servicio no existe o no lo puedes ver, o el comentario no es de ese folio o servicio («Comentario no encontrado»).

## Crear un comentario

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:operation_id/messages</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:service_id/messages</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Agrega un comentario al folio o servicio. El autor es el usuario del token.

### Cuerpo de la petición

Va dentro del objeto `message`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`content` | string | <span class="req">obligatorio</span> Texto plano o HTML. Ver [Formato de los comentarios](#formato-de-los-comentarios).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/messages \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "message": { "content": "Pedimento 26 47 3912 6001234 pagado. Listo para modular." } }'
```

```javascript
const { status, body } = await api("/operations/1042/messages", {
  method: "POST",
  body: JSON.stringify({
    message: { content: "Pedimento 26 47 3912 6001234 pagado. Listo para modular." },
  }),
});
```

```python
res = api.post(f"{BASE}/operations/1042/messages", json={
    "message": {"content": "Pedimento 26 47 3912 6001234 pagado. Listo para modular."}
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "message": {
    "id": 6120,
    "content": "<div class=\"trix-content\">\n  Pedimento 26 47 3912 6001234 pagado. Listo para modular.\n</div>\n",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "edited": false,
    "created_at": "2026-11-12T09:20:05.114-06:00",
    "updated_at": "2026-11-12T09:20:05.114-06:00"
  },
  "message_text": "Comentario creado exitosamente"
}
```

### Respuesta

**201** con el comentario en `message` y el texto de éxito en `message_text`. Ojo: en este recurso `message` es el comentario, no un texto.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `content` o va vacío («Content no puede estar en blanco»). El cuerpo trae también `message_text`.
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.
`404` `not_found` | El folio o servicio no existe o no lo puedes ver.

> Error 422

```json
{
  "errors": ["Content no puede estar en blanco"],
  "message_text": "No se pudo crear el comentario",
  "error": "validation_failed",
  "message": "Content no puede estar en blanco",
  "request_id": "8a2f4c6e-1b3d-4f5a-9c7e-0d2b4f6a8c1e"
}
```

## Actualizar un comentario

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/operations/:operation_id/messages/:id</code></div>
<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/services/:service_id/messages/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio), y ser el autor, administrador o dueño de la cuenta</p>

Reemplaza el texto del comentario. `PUT` funciona igual. Solo lo puede hacer su autor, un administrador o el dueño de la cuenta. Después de editarlo, `edited` vale `true`.

### Cuerpo de la petición

Va dentro del objeto `message`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`content` | string | <span class="opt">opcional</span> Texto nuevo. Si lo mandas vacío responde 422.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/operations/1042/messages/6120 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "message": { "content": "Pedimento 26 47 3912 6001234 pagado. <strong>Modulado en verde.</strong>" } }'
```

> Respuesta 200

```json
{
  "message": {
    "id": 6120,
    "content": "<div class=\"trix-content\">\n  Pedimento 26 47 3912 6001234 pagado. <strong>Modulado en verde.</strong>\n</div>\n",
    "owner": {
      "email": "integracion@tuempresa.mx",
      "name": "Integración ERP"
    },
    "edited": true,
    "created_at": "2026-11-12T09:20:05.114-06:00",
    "updated_at": "2026-11-12T13:48:31.602-06:00"
  },
  "message_text": "Comentario actualizado exitosamente"
}
```

### Errores

Código | Cuándo
------ | ------
`403` `forbidden` | El comentario es de otra persona y el usuario del token no es administrador ni dueño de la cuenta, o no puede editar el folio o servicio.
`422` `validation_failed` | `content` vacío.
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`404` `not_found` | El comentario no existe o no es de ese folio o servicio.

> Error 403

```json
{
  "error": "forbidden",
  "message": "Solo quien escribió el comentario o un administrador de la cuenta puede editarlo o borrarlo.",
  "request_id": "f3c1a9e7-6d2b-4a8c-b0e5-7c9d1f2a3b4c"
}
```

## Eliminar un comentario

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/operations/:operation_id/messages/:id</code></div>
<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/services/:service_id/messages/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio), y ser el autor, administrador o dueño de la cuenta</p>

Borra el comentario (borrado lógico): deja de aparecer en el listado y sale como lápida en `deleted_since`. Aplica la misma regla de autor que al editar.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/operations/1042/messages/6120 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "message": "Comentario eliminado exitosamente" }
```

### Errores

Código | Cuándo
------ | ------
`403` `forbidden` | El comentario es de otra persona y el usuario del token no es administrador ni dueño de la cuenta, o no puede editar el folio o servicio.
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`404` `not_found` | El comentario no existe o no es de ese folio o servicio.
