# Catálogos

<p class="lead">Los catálogos son las listas que la cuenta configura en la plataforma: tableros de servicio, conceptos, impuestos, pipelines y motivos. La API solo los lee. Tu integración los consulta para obtener los ids y códigos que piden otros recursos.</p>

Catálogo | Endpoint | Permiso | Se usa en
--------- | ---- | ----------- | -----------
Tableros de servicio | `GET /api/v1/boards` | `services_read` | `board_id` y `list_id` de [Servicios](#servicios)
Conceptos | `GET /api/v1/items`, `GET /api/v1/items/:id` | `items_read` | `item_id` o `item_sku` en líneas de [Facturas](#facturas) y [Facturas de proveedor](#facturas-de-proveedor); solo `item_id` en [Centro de costos](#centro-de-costos)
Impuestos y retenciones | `GET /api/v1/taxes` | `items_read` | `account_contribution_id` en líneas de facturas y facturas de proveedor
Pipelines de cotización | `GET /api/v1/quotation_pipelines` | `quote_requests_read` | `list_id` de [Solicitudes comerciales](#solicitudes-comerciales)
Motivos de ganada y pérdida | `GET /api/v1/quote_won_reasons`, `GET /api/v1/quote_lost_reasons` | Ninguno | Ganar, perder o archivar una solicitud comercial
Motivos de cancelación | `GET /api/v1/operation_cancellation_reasons`, `GET /api/v1/service_cancellation_reasons` | Ninguno | Cancelar un [folio](#folios-operativos) o un [servicio](#servicios)

- Solo devuelven registros no archivados. La excepción son los conceptos con `archived=true` o `updated_since`.
- Conceptos es el único catálogo paginado y con [sincronización incremental](#sincronizacion-incremental). Los demás devuelven todo en una sola respuesta.
- Los catálogos cambian poco. Guárdalos en caché y vuelve a pedirlos cuando una referencia falle.

## Tableros de servicio

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/boards</code></div>

<p class="perm">Permiso: <code>services_read</code></p>

<span class="new">nuevo</span> Un tablero de servicio es el flujo de trabajo de los servicios de un modo de transporte. Sus columnas (`lists`) son las etapas, y cada servicio vive en una columna. Devuelve los tableros no archivados de la cuenta, ordenados por nombre, con sus columnas en orden. No incluye los pipelines de cotización.

### Dónde empieza un servicio

Al [crear un servicio](#crear-un-servicio) indicas su columna con uno de estos campos:

- `list_id`: el id de una columna. El servicio empieza en esa columna.
- `board_id`: el id de un tablero. El servicio empieza en la primera columna. Si mandas los dos, gana `list_id`.
- Sin ninguno de los dos: si la cuenta tiene un solo tablero para el `mode` que mandas (o un solo tablero en total, si no mandas `mode`), se usa ese. Si hay varios o ninguno, **422**.

El servicio toma el `mode` del tablero, y `shipment_type` y `shipment_kind` si no los mandas. Mandar un `mode` distinto al del tablero responde **422**. En `PATCH /services/:id`, `list_id` o `board_id` mueven el servicio de columna.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`mode` | string | <span class="opt">opcional</span> Solo los tableros de ese modo: `land`, `aerial`, `maritime` o `customs`.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Id del tablero. Es el `board_id`.
`name` | string | Nombre.
`mode` | string | Modo: `land` (terrestre), `aerial` (aéreo), `maritime` (marítimo) o `customs` (aduanas).
`shipment_type` | string | Tipo de embarque por omisión, o `null`. Depende del modo: `ltl`, `ftl`, … en terrestre; `fcl`, `lcl`, … en marítimo.
`shipment_kind` | string | `national`, `international` o `null`.
`status` | string | Estado del tablero (`active`).
`lists` | array&lt;object&gt; | Columnas en orden.
`lists[].id` | integer | Id de la columna. Es el `list_id`.
`lists[].name` | string | Nombre de la etapa.
`lists[].position` | integer | Orden de la columna, de menor a mayor. No es consecutivo: úsalo solo para ordenar.

> Petición

```shell
curl "https://control.apunto.io/api/v1/boards?mode=maritime" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "boards": [
    {
      "id": 41,
      "name": "Importación marítima",
      "mode": "maritime",
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "status": "active",
      "lists": [
        { "id": 301, "name": "Booking", "position": 0 },
        { "id": 302, "name": "En tránsito", "position": 4194303 },
        { "id": 303, "name": "Arribo", "position": 6291455 },
        { "id": 304, "name": "Entregado", "position": 7340031 }
      ]
    }
  ]
}
```

## Catálogo de conceptos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/items</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/items/:id</code></div>

<p class="perm">Permiso: <code>items_read</code></p>

<span class="new">nuevo</span> Los conceptos (`items`) son los productos y servicios que la cuenta cobra o paga: flete, maniobras, agenciamiento. Cada uno trae sus claves del SAT y los impuestos que una línea toma por omisión. El listado está ordenado por nombre y es paginado. Sin `items_read`, el listado sale vacío y el detalle responde **404**.

`GET /items/:id` acepta solo el id numérico. Devuelve el concepto aunque esté archivado; si no existe o es de otra cuenta, **404**.

### Cómo se usa un concepto

- En [Facturas](#facturas) y [Facturas de proveedor](#facturas-de-proveedor), cada línea de `line_items_attributes` acepta `item_id` o `item_sku`. `item_sku` busca el código completo sin distinguir mayúsculas (`agen-carga` encuentra `AGEN-CARGA`), entre los conceptos **no archivados**; `item_id` acepta cualquiera de la cuenta. Un concepto que no existe responde **422** («Concepto no encontrado: …»).
- Una línea nueva sin `line_item_taxes_attributes` ni `line_item_retentions_attributes` toma los impuestos y retenciones del concepto. Una línea nueva sin `description` o sin `price` toma el nombre o el precio del concepto.
- En [Centro de costos](#centro-de-costos) la línea acepta `item_id`.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`q` | string | <span class="opt">opcional</span> Busca por palabras en nombre, descripción y `sku`, sin importar acentos. Si no encuentra nada, busca en el nombre de la clave de producto del SAT.
`sku` | string | <span class="opt">opcional</span> Código completo, sin distinguir mayúsculas.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo los archivados.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen `sku`.

<aside class="success">Para mantener tu catálogo al día usa el <code>sku</code> como llave: <code>updated_since</code> te da los conceptos nuevos o cambiados (también los archivados), y <code>deleted_since</code> los eliminados con su <code>sku</code>.</aside>

### Respuesta

El listado devuelve `items` y `pagination`; el detalle, `item`. Todos los campos son de solo lectura: el catálogo se administra en la plataforma.

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Id del concepto. Es el `item_id`.
`name` | string | Nombre. Es la descripción por omisión de una línea.
`sku` | string | Código del concepto, único en la cuenta sin distinguir mayúsculas. Es el `item_sku`.
`description` | string | Descripción larga, o `null`.
`price` | decimal | Precio por omisión, sin moneda. Sale como string decimal.
`archived` | boolean | `true` si está archivado.
`product_key` | object | Clave de producto o servicio del SAT (`code`, `name`), o `null`.
`unit_key` | object | Clave de unidad del SAT (`code`, `name`), o `null`.
`taxes` | array&lt;object&gt; | Impuestos por omisión: `id`, `name` y `percentage` (número). Los `id` son los del [catálogo de impuestos](#catalogo-de-impuestos).
`retentions` | array&lt;object&gt; | Retenciones por omisión, con la misma forma.
`created_at`, `updated_at` | datetime |

> Petición

```shell
curl "https://control.apunto.io/api/v1/items?sku=AGEN-CARGA" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "items": [
    {
      "id": 77,
      "name": "Agenciamiento de carga",
      "sku": "AGEN-CARGA",
      "description": "Coordinación de embarque puerta a puerta",
      "price": "3500.0",
      "archived": false,
      "product_key": { "code": "78141501", "name": "Servicios de expedidores de fletes" },
      "unit_key": { "code": "E48", "name": "Unidad de servicio" },
      "taxes": [{ "id": 1, "name": "IVA", "percentage": 16.0 }],
      "retentions": [],
      "created_at": "2026-11-02T09:00:00.000-06:00",
      "updated_at": "2026-11-09T12:30:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

> Petición · detalle

```shell
curl https://control.apunto.io/api/v1/items/77 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200 · detalle

```json
{
  "item": {
    "id": 77,
    "name": "Agenciamiento de carga",
    "sku": "AGEN-CARGA",
    "description": "Coordinación de embarque puerta a puerta",
    "price": "3500.0",
    "archived": false,
    "product_key": { "code": "78141501", "name": "Servicios de expedidores de fletes" },
    "unit_key": { "code": "E48", "name": "Unidad de servicio" },
    "taxes": [{ "id": 1, "name": "IVA", "percentage": 16.0 }],
    "retentions": [],
    "created_at": "2026-11-02T09:00:00.000-06:00",
    "updated_at": "2026-11-09T12:30:00.000-06:00"
  }
}
```

## Catálogo de impuestos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/taxes</code></div>

<p class="perm">Permiso: <code>items_read</code></p>

<span class="new">nuevo</span> Impuestos y retenciones que puede llevar una línea de factura o de factura de proveedor. Es un catálogo general del país de operación de la cuenta: los ids son los mismos para todas las cuentas de ese país. Cada lista está ordenada por nombre. Sin `items_read` responde **403**.

Úsalos en las líneas de [Facturas](#facturas) y [Facturas de proveedor](#facturas-de-proveedor):

- `line_item_taxes_attributes: [{ "account_contribution_id": <id de taxes> }]`
- `line_item_retentions_attributes: [{ "account_contribution_id": <id de retentions> }]`

Los `taxes` y `retentions` de un concepto usan estos mismos ids.

No recibe parámetros.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`country` | string | País de operación de la cuenta (`MX` por omisión).
`taxes` | array&lt;object&gt; | Impuestos trasladados.
`retentions` | array&lt;object&gt; | Retenciones.
`*.id` | integer | Es el `account_contribution_id`.
`*.name` | string | Nombre.
`*.display_name` | string | Nombre con el porcentaje, como lo muestra la plataforma.
`*.percentage` | number | Tasa en porcentaje (`16.0` = 16 %). Sale como número, no como string.
`*.category` | string | `federal` o `local`.
`*.sat_code` | string | Clave del impuesto en el SAT (`002` = IVA, `001` = ISR), u `OBJ_01` / `OBJ_03` en las entradas de objeto de impuesto, que tienen tasa 0.

> Petición

```shell
curl https://control.apunto.io/api/v1/taxes \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "country": "MX",
  "taxes": [
    { "id": 1, "name": "IVA", "display_name": "IVA (16.00%)", "percentage": 16.0, "category": "federal", "sat_code": "002" },
    { "id": 31, "name": "No objeto de impuesto (01)", "display_name": "No objeto de impuesto (01)", "percentage": 0.0, "category": "federal", "sat_code": "OBJ_01" }
  ],
  "retentions": [
    { "id": 6, "name": "Retención IVA", "display_name": "Retención IVA (4.00%)", "percentage": 4.0, "category": "federal", "sat_code": "002" }
  ]
}
```

## Pipelines de cotización

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quotation_pipelines</code></div>

<p class="perm">Permiso: <code>quote_requests_read</code></p>

Un pipeline de cotización es el flujo comercial de las [solicitudes comerciales](#solicitudes-comerciales). Sus columnas (`lists`) son las etapas, y cada solicitud vive en una. Devuelve los pipelines no archivados de la cuenta, ordenados por nombre, con sus columnas en orden. Sin `quote_requests_read` la lista sale vacía.

### Columnas de una solicitud comercial

- `list_id` es **obligatorio** al [crear una solicitud comercial](#crear-una-solicitud-comercial): es la columna donde empieza.
- En `PATCH /quote_requests/:id`, `list_id` mueve la solicitud a otra columna.
- Si la columna tiene `target_quote_request_status`, al entrar la solicitud toma ese estado. Hacia adelante, solo si el cambio de estado es válido; hacia atrás, siempre.
- Al revés, cuando una acción cambia el estado de la solicitud, la solicitud pasa a la columna que tiene ese estado.
- Entrar a una columna envía los correos automáticos que tenga configurados, y la primera vez crea sus tareas.

No recibe parámetros.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Id del pipeline.
`name` | string | Nombre.
`status` | string | Estado del pipeline (`active`).
`default_pipeline` | boolean | `true` en el pipeline predeterminado de la cuenta.
`lists` | array&lt;object&gt; | Columnas en orden.
`lists[].id` | integer | Id de la columna. Es el `list_id`.
`lists[].name` | string | Nombre de la etapa.
`lists[].position` | integer | Orden de la columna, de menor a mayor. No es consecutivo.
`lists[].target_quote_request_status` | string | Estado de la solicitud asociado a la columna, o `null`: `start`, `requested`, `quoted`, `vobo`, `finished` o `adjustments_requested`.

> Petición

```shell
curl https://control.apunto.io/api/v1/quotation_pipelines \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quotation_pipelines": [
    {
      "id": 57,
      "name": "Pipeline comercial",
      "status": "active",
      "default_pipeline": true,
      "lists": [
        { "id": 610, "name": "Nueva", "position": 0, "target_quote_request_status": "start" },
        { "id": 611, "name": "Pricing", "position": 4194303, "target_quote_request_status": "requested" },
        { "id": 612, "name": "Cotizada", "position": 6291455, "target_quote_request_status": "quoted" },
        { "id": 613, "name": "VoBo", "position": 7340031, "target_quote_request_status": "vobo" },
        { "id": 614, "name": "Cerrada", "position": 7864319, "target_quote_request_status": "finished" }
      ]
    }
  ]
}
```

## Motivos de ganada y pérdida

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_won_reasons</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_lost_reasons</code></div>

<p class="perm">Permiso: cualquier usuario de la cuenta</p>

Motivos por los que una solicitud comercial se gana o se pierde. No piden permiso de módulo: basta un token válido de la cuenta. Devuelven los motivos no archivados, activos e inactivos, ordenados por nombre.

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Id del motivo.
`name` | string | Nombre.
`description` | string | Descripción, o `null`.
`status` | string | `active` o `inactive`. Informativo: la plataforma ofrece y acepta los dos; lo que saca un motivo de uso es archivarlo.

Se mandan al nivel raíz de la petición (no dentro de un objeto) en estas acciones de [Solicitudes comerciales](#solicitudes-comerciales):

Acción | Campo
--------- | -----------
[`POST /quote_requests/:id/mark_as_won`](#marcar-una-solicitud-como-ganada) | `quote_won_reason_id`
[`POST /quote_requests/:id/mark_as_lost`](#marcar-una-solicitud-como-perdida) | `quote_lost_reason_id`
[`POST /quote_requests/:id/archive`](#archivar-y-restaurar-una-solicitud-comercial) (solicitud abierta) | `quote_lost_reason_id`, obligatorio junto con `lost_at`

<span class="new">nuevo</span> El id tiene que ser un motivo **no archivado de tu cuenta**. Un id de otra cuenta, archivado o que no existe responde **422** `validation_failed` y la solicitud no cambia, en las tres acciones.

> Error 422 · motivo

```json
{
  "error": "validation_failed",
  "message": "No se pudo marcar la solicitud como ganada",
  "errors": ["quote_won_reason_id 999 no es un motivo de ganada vigente de esta cuenta. Consulta GET /api/v1/quote_won_reasons."],
  "request_id": "b2d8e4a6-1c37-4f90-a5e2-6d0f9c1b7e43"
}
```

> Petición

```shell
curl https://control.apunto.io/api/v1/quote_won_reasons \
  -H "Authorization: Bearer $APUNTO_TOKEN"

curl https://control.apunto.io/api/v1/quote_lost_reasons \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200 · ganada

```json
{
  "quote_won_reasons": [
    { "id": 8, "name": "Mejor precio", "description": null, "status": "active" }
  ]
}
```

> Respuesta 200 · pérdida

```json
{
  "quote_lost_reasons": [
    { "id": 14, "name": "Tarifa fuera de presupuesto", "description": "El cliente eligió otra opción por precio", "status": "active" }
  ]
}
```

## Motivos de cancelación de folio y servicio

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operation_cancellation_reasons</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/service_cancellation_reasons</code></div>

<p class="perm">Permiso: cualquier usuario de la cuenta</p>

Motivos para cancelar un folio operativo o un servicio. Cada uno es un catálogo aparte. No piden permiso de módulo. Devuelven los motivos no archivados, activos e inactivos, ordenados por nombre, con los mismos campos que los motivos de ganada y pérdida (`id`, `name`, `description`, `status`).

Se mandan al nivel raíz de la petición de cancelación:

Acción | Campos
--------- | -----------
[`POST /operations/:id/cancel`](#cancelar-un-folio-operativo) | `operation_cancellation_reason_id` o `operation_cancellation_reason_name`
[`POST /services/:id/cancel`](#cancelar-un-servicio) | `service_cancellation_reason_id` o `service_cancellation_reason_name`

- Manda el id o el nombre. El nombre se compara completo, sin distinguir mayúsculas. Si mandas los dos, gana el id.
- Si la cuenta tiene al menos un motivo no archivado (activo o inactivo), el motivo es **obligatorio**: sin él, **422** «Debe indicar un motivo de cancelación…».
- Un id o nombre que no está en el catálogo, o que está archivado, responde **422** «Motivo de cancelación no encontrado».
- Si la cuenta no tiene motivos, se puede cancelar sin motivo.
- Las notas van en `cancellation_notes`. Lo demás de la cancelación está en [Folios operativos](#folios-operativos) y [Servicios](#servicios).

> Petición

```shell
curl https://control.apunto.io/api/v1/operation_cancellation_reasons \
  -H "Authorization: Bearer $APUNTO_TOKEN"

curl https://control.apunto.io/api/v1/service_cancellation_reasons \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200 · folio

```json
{
  "operation_cancellation_reasons": [
    { "id": 3, "name": "Cliente canceló", "description": null, "status": "active" }
  ]
}
```

> Respuesta 200 · servicio

```json
{
  "service_cancellation_reasons": [
    { "id": 2, "name": "Proveedor no disponible", "description": null, "status": "active" }
  ]
}
```

> Uso al cancelar

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/cancel \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "operation_cancellation_reason_name": "Cliente canceló", "cancellation_notes": "El cliente desistió del embarque" }'
```
