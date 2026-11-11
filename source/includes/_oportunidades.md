# Oportunidades

<p class="lead">Una oportunidad (<code>opportunity</code>) es un negocio posible con un cliente o un prospecto: qué quiere mover, con qué frecuencia y en qué etapa va. Una integración las usa para llevar el embudo comercial desde un CRM y para ligar ahí las solicitudes comerciales que salen de cada negocio.</p>

Cada oportunidad pertenece a un contacto de la cuenta: un cliente de [Contactos](#contactos) o un [prospecto](#prospectos). De una oportunidad salen las [solicitudes comerciales](#solicitudes-comerciales) (`opportunity_id` u `opportunity_identification` en la solicitud).

**Estados (`status`).** La lista es fija:

Estado | Leyenda | Qué significa
--------- | ---- | -----------
`created` | Creada | Estado inicial.
`in_progress` | En proceso | Abierta, en seguimiento.
`in_negotiation` | En negociación | Abierta, negociando condiciones.
`won` | Ganada | Se cerró el negocio. Exige al menos una solicitud comercial ligada.
`lost` | Perdida | No se cerró.

- No hay un orden obligatorio: puedes pasar de cualquier estado a cualquier otro, también de regreso.
- Para pasar a `won` la oportunidad necesita al menos una solicitud comercial ligada. Si no, **422**.
- Cuando una solicitud comercial ligada se marca como ganada, la oportunidad pasa sola a `won`. Perder o reabrir la solicitud no cambia la oportunidad.
- Archivar una oportunidad `in_progress` o `in_negotiation` la deja en `lost`. Ver [Archivar y restaurar una oportunidad](#archivar-y-restaurar-una-oportunidad).

## El objeto oportunidad

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la oportunidad.
`identification` | string | <span class="ro">solo lectura</span> Folio que asigna la secuencia de la cuenta (por ejemplo `OP-000045`). Es `null` si la cuenta no tiene secuencia de oportunidades.
`title` | string | Título del negocio.
`status` | string | Estado. Ver la tabla de estados.
`status_label` | string | <span class="ro">solo lectura</span> Leyenda del estado.
`frequency` | string | Frecuencia esperada: `daily`, `weekly`, `monthly`, `semiannual` o `annual`. Puede ser `null`.
`frequency_label` | string | <span class="ro">solo lectura</span> Leyenda de la frecuencia (Diario, Semanal, Mensual, Semestral, Anual), o `null`.
`operations_volume` | integer | Operaciones esperadas en ese periodo. Entero mayor que 0, o `null`.
`detail` | string | Descripción libre.
`contact` | object | <span class="ro">solo lectura</span> `{ "id", "alias", "name" }` del cliente o prospecto, o `null`. Se escribe con `contact_id` o `contact_code`.
`owner` | object | <span class="ro">solo lectura</span> Responsable: `{ "id", "name", "email" }`. Se escribe con `owner_id` u `owner_email`.
`tags` | array&lt;string&gt; | Etiquetas. Se escriben con `tag_list`.
`created_at` | datetime | <span class="ro">solo lectura</span> Alta.
`updated_at` | datetime | <span class="ro">solo lectura</span> Último cambio.
`quote_requests_count` | integer | <span class="ro">solo lectura</span> Solicitudes comerciales ligadas. Solo en el detalle.
`opportunity_actions_count` | integer | <span class="ro">solo lectura</span> Acciones de seguimiento (llamadas, reuniones, visitas) registradas en la plataforma. Solo en el detalle.

El listado devuelve los campos hasta `updated_at`. El detalle, el alta, el cambio y el cambio de estado agregan los dos conteos.

<aside class="notice">El objeto no trae <code>archived</code> ni <code>archived_at</code>. Con <code>updated_since</code> el listado incluye oportunidades archivadas sin marcarlas; para saber cuáles son, consulta <code>GET /api/v1/opportunities?archived=true</code>.</aside>

> Objeto oportunidad

```json
{
  "id": 233,
  "identification": "OP-000045",
  "title": "Importación marítima mensual de autopartes",
  "status": "in_negotiation",
  "status_label": "En negociación",
  "frequency": "monthly",
  "frequency_label": "Mensual",
  "operations_volume": 4,
  "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
  "tags": ["autopartes"],
  "created_at": "2026-11-04T12:00:00.000-06:00",
  "updated_at": "2026-11-10T16:20:00.000-06:00",
  "quote_requests_count": 1,
  "opportunity_actions_count": 3
}
```

## Listar oportunidades

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/opportunities</code></div>

<p class="perm">Permiso: <code>opportunities_read</code></p>

Devuelve las oportunidades no archivadas que el usuario puede ver, de la más reciente a la más antigua (`created_at`). Con `updated_since` el orden cambia a `updated_at, id`.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> Solo oportunidades en ese estado.
`archived` | boolean | <span class="opt">opcional</span> <span class="new">nuevo</span> `true` lista solo las archivadas. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen el `identification`.

> Petición

```shell
curl "https://control.apunto.io/api/v1/opportunities?status=in_negotiation&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "opportunities": [
    {
      "id": 233,
      "identification": "OP-000045",
      "title": "Importación marítima mensual de autopartes",
      "status": "in_negotiation",
      "status_label": "En negociación",
      "frequency": "monthly",
      "frequency_label": "Mensual",
      "operations_volume": 4,
      "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
      "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
      "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "tags": ["autopartes"],
      "created_at": "2026-11-04T12:00:00.000-06:00",
      "updated_at": "2026-11-10T16:20:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Obtener una oportunidad

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/opportunities/:id</code></div>

<p class="perm">Permiso: <code>opportunities_read</code></p>

Devuelve el detalle en `opportunity`. También responde con oportunidades archivadas. El `:id` es el id numérico; para buscar por folio en una solicitud comercial usa `opportunity_identification`.

> Petición

```shell
curl https://control.apunto.io/api/v1/opportunities/233 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "opportunity": {
    "id": 233,
    "identification": "OP-000045",
    "title": "Importación marítima mensual de autopartes",
    "status": "in_negotiation",
    "status_label": "En negociación",
    "frequency": "monthly",
    "frequency_label": "Mensual",
    "operations_volume": 4,
    "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "tags": ["autopartes"],
    "created_at": "2026-11-04T12:00:00.000-06:00",
    "updated_at": "2026-11-10T16:20:00.000-06:00",
    "quote_requests_count": 1,
    "opportunity_actions_count": 3
  }
}
```

## Crear una oportunidad

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/opportunities</code></div>

<p class="perm">Permiso: <code>opportunities_create</code></p>

Crea una oportunidad en `created`, salvo que mandes otro estado. Si no indicas responsable, queda el usuario del token.

### Cuerpo de la petición

Todo va dentro de `opportunity`.

Campo | Tipo | Descripción
--------- | ---- | -----------
`title` | string | <span class="req">obligatorio</span> Título del negocio.
`contact_code` | string | <span class="opt">opcional</span> Alias del cliente o prospecto.
`contact_id` | integer | <span class="opt">opcional</span> Alternativa a `contact_code`. Tiene que ser un contacto de la cuenta.
`owner_email` | string | <span class="opt">opcional</span> Correo del responsable, usuario de la cuenta. Por omisión, el usuario del token.
`owner_id` | integer | <span class="opt">opcional</span> Alternativa a `owner_email`. Tiene que ser miembro de la cuenta.
`frequency` | string | <span class="opt">opcional</span> `daily`, `weekly`, `monthly`, `semiannual` o `annual`.
`operations_volume` | integer | <span class="opt">opcional</span> Entero mayor que 0.
`detail` | string | <span class="opt">opcional</span> Descripción libre.
`status` | string | <span class="opt">opcional</span> Estado inicial. Por omisión `created`. `won` no se acepta en el alta porque la oportunidad aún no tiene solicitudes.
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta (**Configuración → Etiquetas**).

### Respuesta

**201** con el detalle en `opportunity` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `title`, `operations_volume` no es un entero mayor que 0, o `status` o `frequency` no están en la lista.
`422` `validation_failed` | `contact_code` no existe en la cuenta, o `contact_id` es de otra cuenta.
`422` `validation_failed` | `owner_email` no es usuario de la cuenta, u `owner_id` no es miembro.
`422` `validation_failed` | Una etiqueta de `tag_list` no existe en el catálogo de la cuenta.
`422` `validation_failed` | `status` es `won` y la oportunidad no tiene solicitudes comerciales.

Lo demás, en [Errores](#errores).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/opportunities \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "opportunity": {
      "title": "Importación marítima mensual de autopartes",
      "contact_code": "ACME",
      "owner_email": "laura@tuempresa.mx",
      "frequency": "monthly",
      "operations_volume": 4,
      "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
      "tag_list": ["autopartes"]
    }
  }'
```

```javascript
const { status, body } = await api("/opportunities", {
  method: "POST",
  body: JSON.stringify({
    opportunity: {
      title: "Importación marítima mensual de autopartes",
      contact_code: "ACME",
      owner_email: "laura@tuempresa.mx",
      frequency: "monthly",
      operations_volume: 4,
      detail: "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
      tag_list: ["autopartes"],
    },
  }),
});
```

```python
res = api.post(f"{BASE}/opportunities", json={
    "opportunity": {
        "title": "Importación marítima mensual de autopartes",
        "contact_code": "ACME",
        "owner_email": "laura@tuempresa.mx",
        "frequency": "monthly",
        "operations_volume": 4,
        "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
        "tag_list": ["autopartes"],
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "opportunity": {
    "id": 233,
    "identification": "OP-000045",
    "title": "Importación marítima mensual de autopartes",
    "status": "created",
    "status_label": "Creada",
    "frequency": "monthly",
    "frequency_label": "Mensual",
    "operations_volume": 4,
    "detail": "Cuatro embarques al mes de 2x40HC desde Shanghai a Manzanillo.",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "tags": ["autopartes"],
    "created_at": "2026-11-04T12:00:00.000-06:00",
    "updated_at": "2026-11-04T12:00:00.000-06:00",
    "quote_requests_count": 0,
    "opportunity_actions_count": 0
  },
  "message": "Oportunidad creada exitosamente"
}
```

## Actualizar una oportunidad

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/opportunities/:id</code></div>

<p class="perm">Permiso: <code>opportunities_edit</code></p>

Cambio parcial con los mismos campos del alta dentro de `opportunity`. Los campos que no mandas no cambian. `PUT` también funciona.

- `status` también se puede cambiar aquí, con las mismas reglas que en [Cambiar el estado de una oportunidad](#cambiar-el-estado-de-una-oportunidad).
- `tag_list` reemplaza todas las etiquetas. Las que la oportunidad ya tiene se aceptan aunque se hayan archivado en el catálogo.
- Una oportunidad archivada es de solo lectura: responde **422** con `code` `archived_read_only` y `suggested_action` `restore`.

### Respuesta

**200** con el detalle en `opportunity` y `message` («Oportunidad actualizada exitosamente»). Los errores son los del alta.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/opportunities/233 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "opportunity": { "operations_volume": 6, "detail": "Subió a seis embarques al mes." } }'
```

> Respuesta 200

```json
{
  "opportunity": {
    "id": 233,
    "identification": "OP-000045",
    "title": "Importación marítima mensual de autopartes",
    "status": "in_negotiation",
    "status_label": "En negociación",
    "frequency": "monthly",
    "frequency_label": "Mensual",
    "operations_volume": 6,
    "detail": "Subió a seis embarques al mes.",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "tags": ["autopartes"],
    "created_at": "2026-11-04T12:00:00.000-06:00",
    "updated_at": "2026-11-11T10:05:00.000-06:00",
    "quote_requests_count": 1,
    "opportunity_actions_count": 3
  },
  "message": "Oportunidad actualizada exitosamente"
}
```

## Cambiar el estado de una oportunidad

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/opportunities/:id/transition</code></div>

<p class="perm">Permiso: <code>opportunities_edit</code></p>

Mueve la oportunidad a otro estado. Manda `status` en la raíz del cuerpo o dentro de `opportunity` (`{ "opportunity": { "status": "won" } }`).

### Cuerpo de la petición

Campo | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="req">obligatorio</span> `created`, `in_progress`, `in_negotiation`, `won` o `lost`.

### Respuesta

**200** con el detalle en `opportunity` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `status` o no está en la lista («Estado de oportunidad inválido»).
`422` `validation_failed` | `status` es `won` y la oportunidad no tiene ninguna solicitud comercial ligada.
`422` `archived_read_only` | La oportunidad está archivada.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/opportunities/233/transition \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "status": "won" }'
```

> Respuesta 200

```json
{
  "opportunity": {
    "id": 233,
    "identification": "OP-000045",
    "title": "Importación marítima mensual de autopartes",
    "status": "won",
    "status_label": "Ganada",
    "frequency": "monthly",
    "frequency_label": "Mensual",
    "operations_volume": 6,
    "detail": "Subió a seis embarques al mes.",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "tags": ["autopartes"],
    "created_at": "2026-11-04T12:00:00.000-06:00",
    "updated_at": "2026-11-11T10:20:00.000-06:00",
    "quote_requests_count": 1,
    "opportunity_actions_count": 3
  },
  "message": "Estado de la oportunidad actualizado exitosamente"
}
```

## Archivar y restaurar una oportunidad

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/opportunities/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/opportunities/:id/restore</code></div>

<p class="perm">Permiso: <code>opportunities_edit</code></p>

Archivar saca la oportunidad de los listados sin borrarla; restaurar la regresa con el mismo estado. Responden la decisión del ciclo de vida. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

Archivar depende del estado:

- `created`, `won` o `lost`: se archiva sin cambiar el estado (`allow`).
- `in_progress` o `in_negotiation`: responde `confirm` con `code` `will_mark_lost`. Repite con `confirmed=true` y la oportunidad pasa a `lost` y se archiva.
- Ya archivada: `reject` con `code` `already_archived`.

Restaurar responde `allow`, o `reject` con `not_archived` si no estaba archivada.

### Parámetros

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`confirmed` | boolean | <span class="opt">opcional</span> `true` para confirmar el archivado de una oportunidad abierta. Va en la raíz del cuerpo o en la URL.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/opportunities/241/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "confirm",
  "code": "will_mark_lost",
  "title": "¿Archivar esta oportunidad?",
  "message": "Esta oportunidad quedará perdida y dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados; al restaurarla, sigue perdida.",
  "suggested_action": null,
  "errors": ["Esta oportunidad quedará perdida y dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados; al restaurarla, sigue perdida."],
  "error": "will_mark_lost",
  "request_id": "e7b2c4a9-0d3f-4e61-a8c5-6f19b2d7e340"
}
```

> Petición con confirmación

```shell
curl -X POST https://control.apunto.io/api/v1/opportunities/241/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "confirmed": true }'
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

## Eliminar una oportunidad

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/opportunities/:id</code></div>

<p class="perm">Permiso: <code>opportunities_delete</code></p>

Elimina la oportunidad (borrado lógico) solo si sigue en `created` y no tiene solicitudes comerciales. Después aparece como lápida en `deleted_since`, con su `identification`. Responde la decisión del ciclo de vida.

`outcome` | `code` | Cuándo
--------- | ------ | ------
`allow` (200) | `null` | Se eliminó.
`reject` (422) | `not_created` | Ya no está en `created`. `suggested_action` es `archive`.
`reject` (422) | `has_quote_requests` | Tiene solicitudes comerciales (archivadas también cuentan). `suggested_action` es `archive`.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/opportunities/233 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "not_created",
  "title": "No puedes eliminar esta oportunidad",
  "message": "Solo puedes eliminar una oportunidad que sigue creada. Si ya avanzó, archívala.",
  "suggested_action": "archive",
  "errors": ["Solo puedes eliminar una oportunidad que sigue creada. Si ya avanzó, archívala."],
  "error": "not_created",
  "request_id": "4f8a1d6c-29e3-4b70-9c1e-d5a07b3f82e9"
}
```
