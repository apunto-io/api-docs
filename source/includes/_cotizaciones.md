# Cotizaciones

<p class="lead">Una cotización (<code>quote</code>) es la propuesta de precio que le mandas al cliente. Cuando el cliente la acepta, de ella sale el folio operativo. Una integración las usa para leer y sincronizar cotizaciones, mover su aprobación y convertir una cotización aceptada en un folio sin capturarlo a mano.</p>

Una cotización se crea de tres formas: con [Crear una cotización](#crear-una-cotizacion), desde una solicitud comercial con [Generar la cotización de una solicitud](#generar-la-cotizacion-de-una-solicitud) o con [Clonar una cotización](#clonar-una-cotizacion). Siempre nace en `drafted`.

<aside class="notice">Las partidas se escriben con <code>line_items_attributes</code> en <a href="#crear-una-cotizacion">Crear una cotización</a> y <a href="#actualizar-una-cotizacion">Actualizar una cotización</a>, con los mismos campos que el formulario de la plataforma. El detalle las devuelve en <code>line_items</code>, con el <code>id</code> que usas para cambiarlas o borrarlas y para los mapas de <a href="#crear-un-folio-desde-una-cotizacion">Crear un folio desde una cotización</a>.</aside>

**Estados (`status`).** El estado no se escribe en el alta ni en un cambio: cambia con las acciones.

Estado | Leyenda | Cómo llega
--------- | ---- | -----------
`drafted` | Borrador | Alta, generación desde solicitud o clon.
`need_review` | Necesita revisión | En la plataforma.
`approval_requested` | En aprobación | [Solicitar aprobación](#solicitar-aprobacion-de-una-cotizacion), desde `drafted`.
`opened` | Abierta | [Aprobar](#aprobar-una-cotizacion), desde `approval_requested`.
`sent` | Enviada | En la plataforma, al enviarla al cliente.
`viewed` | Vista | En la plataforma, cuando el cliente la abre.
`partial`, `paid` | Parcial, Pagada | Estados del flujo general de documentos.
`won` | Ganada | Al ganar la solicitud comercial ligada, o en la plataforma.
`lose` | Perdida | Al perder la solicitud ligada, al archivar una cotización abierta, o en la plataforma.
`invoiced` | Facturada | En la plataforma, desde `won`.
`voided` | Cancelada | En la plataforma.

## El objeto cotización

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la cotización.
`identification` | string | <span class="ro">solo lectura</span> Folio que asigna la secuencia de la cuenta (por ejemplo `COT-000231`).
`status` | string | <span class="ro">solo lectura</span> Estado. Ver la tabla de estados.
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivada.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`.
`kind` | string | <span class="ro">solo lectura</span> Campo general de documentos (`income` o `expense`). Las cotizaciones no lo usan y normalmente viene `null`.
`date` | datetime | Fecha de la cotización. Por omisión, el momento del alta.
`due_at` | datetime | Vigencia. Por omisión, el momento del alta.
`subtotal` | decimal | <span class="ro">solo lectura</span> Subtotal calculado con las partidas.
`total` | decimal | <span class="ro">solo lectura</span> Total calculado con las partidas.
`exchange_rate` | decimal | Tipo de cambio de la moneda de la cotización contra la moneda base de la cuenta.
`contact` | object | <span class="ro">solo lectura</span> `{ "id", "alias", "name" }` del cliente o prospecto. Se escribe con `contact_id` o `contact_code`.
`currency` | object | <span class="ro">solo lectura</span> `{ "id", "code", "name" }`. Se escribe con `currency_id` o `currency_code`.
`owner` | object | <span class="ro">solo lectura</span> Quien la creó: `{ "id", "name", "email" }`.
`seller` | object | <span class="ro">solo lectura</span> Vendedor: `{ "id", "name", "email" }`, o `null`. Se escribe con `seller_id` o `seller_email`.
`quote_request_id` | integer | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Id de la [solicitud comercial](#solicitudes-comerciales) de la que salió la cotización (por su precio o por [`create_quote`](#generar-la-cotizacion-de-una-solicitud)), o `null`.
`operation_ids` | array&lt;integer&gt; | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Ids de los [folios operativos](#folios-operativos) que salieron de la cotización o a los que se agregó. `[]` si no tiene.
`operation_kind` | string | Tipo del folio que saldrá: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company` o `import_trading_company`.
`operation_mode` | string | Modo del folio que saldrá: `maritime`, `aerial` o `land`.
`service_scope` | string | Alcance puerta/puerto. Mismos valores que en [Crear una solicitud comercial](#crear-una-solicitud-comercial).
`incoterm` | string | Incoterm en texto libre.
`client_ref` | string | Referencia del cliente (orden de compra).
`created_at` | datetime | <span class="ro">solo lectura</span> Alta.
`updated_at` | datetime | <span class="ro">solo lectura</span> Último cambio.
`description` | string | Descripción. Solo en el detalle.
`tags` | array&lt;string&gt; | Etiquetas. Se escriben con `tag_list`. Solo en el detalle.
`origin_address` | object | <span class="ro">solo lectura</span> `{ "id", "alias", "name", "address_type", "full_address" }`, o `null`. Se escribe con `origin_address_id`. Solo en el detalle.
`destination_address` | object | <span class="ro">solo lectura</span> Misma forma. Se escribe con `destination_address_id`. Solo en el detalle.
`line_items_count` | integer | <span class="ro">solo lectura</span> Número de partidas. Solo en el detalle.
`document_routes_count` | integer | <span class="ro">solo lectura</span> Número de puntos de ruta. Solo en el detalle.
`hide_exchange_rate` | boolean | <span class="new">nuevo</span> `true` si el PDF oculta el tipo de cambio. Solo en el detalle.
`hide_expense_account` | boolean | <span class="new">nuevo</span> `true` si el PDF oculta la cuenta de gastos. Solo en el detalle.
`line_items` | array&lt;object&gt; | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Partidas, en el orden de la cotización (tabla abajo). Solo en el detalle.

**Partidas (`line_items`):**

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Id de la partida. Es la llave de `line_items_to_services` y `line_items_to_new_services`.
`item_id` | integer | Concepto del catálogo de la cuenta.
`item_sku` | string | Código (`sku`) del concepto.
`name` | string | Nombre de la partida.
`description` | string | Descripción.
`quantity` | decimal | Cantidad.
`price` | decimal | Precio unitario de venta, en la moneda de la cotización.
`discount` | decimal | Descuento.
`subtotal` | decimal | `quantity × price`.
`taxes`, `retentions` | array&lt;object&gt; | Impuestos y retenciones: `{ "id", "account_contribution_id", "name", "percentage", "amount" }`.
`supplier` | object | Proveedor del costo: `{ "id", "alias", "name" }`, o `null`.
`supplier_currency_code` | string | Moneda del costo del proveedor, o `null`.
`supplier_unit_price`, `supplier_quantity` | decimal | Costo unitario y cantidad del proveedor.
`supplier_notes` | string | Notas del proveedor.

El listado devuelve los campos hasta `updated_at`. El detalle, el alta, el cambio y las acciones agregan el resto. La respuesta no dice de qué solicitud comercial salió la cotización ni qué folios generó; desde la solicitud, `quote_ids` lista sus cotizaciones.

> Objeto cotización

```json
{
  "id": 905,
  "identification": "COT-000231",
  "status": "opened",
  "archived": false,
  "archived_at": null,
  "kind": null,
  "date": "2026-11-10T16:00:00.000-06:00",
  "due_at": "2026-11-30T00:00:00.000-06:00",
  "subtotal": "4200.0",
  "total": "4200.0",
  "exchange_rate": "18.45",
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
  "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
  "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
  "quote_request_id": 457,
  "operation_ids": [1042],
  "operation_kind": "importation",
  "operation_mode": "maritime",
  "service_scope": "port_cy_to_door",
  "incoterm": "FOB",
  "client_ref": "PO-7781",
  "created_at": "2026-11-10T16:00:00.000-06:00",
  "updated_at": "2026-11-11T09:10:00.000-06:00",
  "description": "2x40HC autopartes Shanghai → Silao",
  "tags": ["autopartes"],
  "origin_address": null,
  "destination_address": null,
  "line_items_count": 2,
  "document_routes_count": 0,
  "hide_exchange_rate": false,
  "hide_expense_account": false,
  "line_items": [
    {
      "id": 5512,
      "item_id": 77,
      "item_sku": "AGEN-CARGA",
      "name": "Flete marítimo",
      "description": "Flete marítimo - Shanghai → Manzanillo, 2x40HC - Tiempo tránsito: 28 días",
      "quantity": "2.0",
      "price": "1950.0",
      "discount": "0.0",
      "subtotal": "3900.0",
      "taxes": [],
      "retentions": [],
      "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "supplier_currency_code": "USD",
      "supplier_unit_price": "1850.0",
      "supplier_quantity": "2.0",
      "supplier_notes": null
    },
    {
      "id": 5513,
      "item_id": 77,
      "item_sku": "AGEN-CARGA",
      "name": "Despacho aduanal",
      "description": "Despacho aduanal - Pedimento A1 en Manzanillo",
      "quantity": "1.0",
      "price": "300.0",
      "discount": "0.0",
      "subtotal": "300.0",
      "taxes": [],
      "retentions": [],
      "supplier": { "id": 830, "alias": "AAPAC", "name": "Agencia Aduanal del Pacífico" },
      "supplier_currency_code": "MXN",
      "supplier_unit_price": "9500.0",
      "supplier_quantity": "1.0",
      "supplier_notes": "Incluye previo"
    }
  ]
}
```

## Listar cotizaciones

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quotes</code></div>

<p class="perm">Permiso: <code>quotes_read</code></p>

Devuelve las cotizaciones no archivadas que el usuario puede ver, de la más reciente a la más antigua (`created_at`). Con `updated_since` el orden cambia a `updated_at, id`. `total` cuenta la lista ya filtrada.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> Solo cotizaciones en ese estado. Se combina con `archived`.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo las archivadas. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen el `identification`.

> Petición

```shell
curl "https://control.apunto.io/api/v1/quotes?status=opened&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quotes": [
    {
      "id": 905,
      "identification": "COT-000231",
      "status": "opened",
      "archived": false,
      "archived_at": null,
      "kind": null,
      "date": "2026-11-10T16:00:00.000-06:00",
      "due_at": "2026-11-30T00:00:00.000-06:00",
      "subtotal": "4200.0",
      "total": "4200.0",
      "exchange_rate": "18.45",
      "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
      "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
      "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
      "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "quote_request_id": 457,
      "operation_ids": [1042],
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "service_scope": "port_cy_to_door",
      "incoterm": "FOB",
      "client_ref": "PO-7781",
      "created_at": "2026-11-10T16:00:00.000-06:00",
      "updated_at": "2026-11-11T09:10:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Obtener una cotización

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quotes/:id</code></div>

<p class="perm">Permiso: <code>quotes_read</code></p>

Devuelve el detalle en `quote`, con la misma forma que [el objeto](#el-objeto-cotizacion). También responde con cotizaciones archivadas.

> Petición

```shell
curl https://control.apunto.io/api/v1/quotes/905 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quote": {
    "id": 905,
    "identification": "COT-000231",
    "status": "opened",
    "archived": false,
    "archived_at": null,
    "kind": null,
    "date": "2026-11-10T16:00:00.000-06:00",
    "due_at": "2026-11-30T00:00:00.000-06:00",
    "subtotal": "4200.0",
    "total": "4200.0",
    "exchange_rate": "18.45",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "quote_request_id": 457,
    "operation_ids": [1042],
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "client_ref": "PO-7781",
    "created_at": "2026-11-10T16:00:00.000-06:00",
    "updated_at": "2026-11-11T09:10:00.000-06:00",
    "description": "2x40HC autopartes Shanghai → Silao",
    "tags": ["autopartes"],
    "origin_address": null,
    "destination_address": null,
    "line_items_count": 2,
    "document_routes_count": 0,
    "hide_exchange_rate": false,
    "hide_expense_account": false,
    "line_items": [
      {
        "id": 5512,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Flete marítimo",
        "description": "Flete marítimo - Shanghai → Manzanillo, 2x40HC - Tiempo tránsito: 28 días",
        "quantity": "2.0",
        "price": "1950.0",
        "discount": "0.0",
        "subtotal": "3900.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "supplier_currency_code": "USD",
        "supplier_unit_price": "1850.0",
        "supplier_quantity": "2.0",
        "supplier_notes": null
      },
      {
        "id": 5513,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Despacho aduanal",
        "description": "Despacho aduanal - Pedimento A1 en Manzanillo",
        "quantity": "1.0",
        "price": "300.0",
        "discount": "0.0",
        "subtotal": "300.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 830, "alias": "AAPAC", "name": "Agencia Aduanal del Pacífico" },
        "supplier_currency_code": "MXN",
        "supplier_unit_price": "9500.0",
        "supplier_quantity": "1.0",
        "supplier_notes": "Incluye previo"
      }
    ]
  }
}
```

## Crear una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes</code></div>

<p class="perm">Permiso: <code>quotes_create</code></p>

Crea una cotización en `drafted`, con las partidas de `line_items_attributes` si las mandas. El usuario del token queda como dueño.

### Cuerpo de la petición

Todo va dentro de `quote`.

Campo | Tipo | Descripción
--------- | ---- | -----------
`contact_code` | string | <span class="req">obligatorio</span> Alias del cliente o prospecto. O `contact_id`. A un prospecto se le puede cotizar, pero no se puede crear un folio desde su cotización.
`contact_id` | integer | Alternativa a `contact_code`. Tiene que ser de la cuenta.
`currency_code` | string | <span class="req">obligatorio</span> Código ISO de la moneda (`MXN`, `USD`). O `currency_id`.
`currency_id` | integer | Alternativa a `currency_code`.
`exchange_rate` | decimal | <span class="opt">opcional</span> Tipo de cambio. Obligatorio si la moneda no es la moneda base de la cuenta (MXN por omisión).
`date` | date | <span class="opt">opcional</span> Fecha. Por omisión, ahora.
`due_at` | date | <span class="opt">opcional</span> Vigencia. Por omisión, ahora; mándala siempre.
`description` | string | <span class="opt">opcional</span> Descripción.
`operation_kind` | string | <span class="opt">opcional</span> Tipo de operación. Obligatorio para crear un folio después.
`operation_mode` | string | <span class="opt">opcional</span> `maritime`, `aerial` o `land`. Obligatorio para crear un folio después.
`service_scope` | string | <span class="opt">opcional</span> Alcance puerta/puerto.
`incoterm` | string | <span class="opt">opcional</span> Texto libre.
`client_ref` | string | <span class="opt">opcional</span> Referencia del cliente. Pasa al folio.
`seller_email` | string | <span class="opt">opcional</span> Correo del vendedor, usuario de la cuenta.
`seller_id` | integer | <span class="opt">opcional</span> Alternativa a `seller_email`. Tiene que ser miembro de la cuenta.
`origin_address_id`, `destination_address_id` | integer | <span class="opt">opcional</span> Direcciones de la cuenta (ver [Direcciones](#direcciones)).
`hide_exchange_rate` | boolean | <span class="opt">opcional</span> Oculta el tipo de cambio en el PDF.
`hide_expense_account` | boolean | <span class="opt">opcional</span> Oculta la cuenta de gastos en el PDF.
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta.
`document_routes_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Puntos de ruta, con los mismos campos que en [Crear una solicitud comercial](#crear-una-solicitud-comercial).
`line_items_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> <span class="new">nuevo</span> Partidas (tabla abajo).
`status` | string | No se acepta: responde 422 `read_only_fields`. Usa las acciones.
`subtotal`, `total`, `price`, `profit_amount`, `profit_percentage` | decimal | <span class="new">nuevo</span> No se aceptan: responden 422 `read_only_fields`. Se calculan con las partidas; el precio va en cada partida.

**Cada partida (`line_items_attributes`)** acepta lo mismo que el formulario de la plataforma:

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | Solo en un cambio: la partida a editar o borrar, de `line_items` del detalle. Sin `id`, la partida es nueva. Un `id` que no es de esta cotización responde 422.
`item_id` | integer | <span class="req">obligatorio</span> en una partida nueva. Concepto de la cuenta (ver [Catálogos](#catalogos)). O `item_sku`.
`item_sku` | string | Alternativa a `item_id`: código de un concepto no archivado, sin distinguir mayúsculas.
`description` | string | <span class="opt">opcional</span> Descripción. En una partida nueva sin descripción, toma el nombre del concepto.
`quantity` | decimal | <span class="opt">opcional</span> Cantidad.
`price` | decimal | <span class="opt">opcional</span> Precio unitario de venta, en la moneda de la cotización. En una partida nueva sin precio, toma el del concepto.
`discount` | decimal | <span class="opt">opcional</span> Descuento.
`position` | integer | <span class="opt">opcional</span> Orden de la partida.
`supplier_code` | string | <span class="opt">opcional</span> Alias del proveedor del costo. O `supplier_id`, que tiene que ser un contacto de la cuenta.
`supplier_currency_code` | string | <span class="opt">opcional</span> Moneda del costo (`USD`, `MXN`). O `supplier_currency_id`.
`supplier_unit_price` | decimal | <span class="opt">opcional</span> Costo unitario del proveedor.
`supplier_quantity` | decimal | <span class="opt">opcional</span> Cantidad del proveedor.
`supplier_exchange_rate` | decimal | <span class="opt">opcional</span> Tipo de cambio entre la moneda del costo y la de la cotización, para el margen.
`supplier_notes` | string | <span class="opt">opcional</span> Notas del proveedor.
`line_item_taxes_attributes`, `line_item_retentions_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Impuestos y retenciones: `{ "account_contribution_id" }` para agregar, `{ "id", "_destroy": true }` para quitar. Una partida nueva sin ellos toma los del concepto.
`_destroy` | boolean | <span class="opt">opcional</span> `true` con `id` borra la partida.

Al guardar, la cotización recalcula `subtotal`, `total` y el margen con sus partidas.

### Respuesta

**201** con el detalle en `quote` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta el contacto o la moneda, o falta `exchange_rate` con una moneda distinta a la base.
`422` `validation_failed` | `contact_code` o `currency_code` no existen, o `contact_id` es de otra cuenta.
`422` `validation_failed` | `seller_email` no es usuario de la cuenta, o `seller_id` no es miembro.
`422` `validation_failed` | `operation_kind`, `operation_mode` o `service_scope` fuera de su lista; el mensaje trae los valores válidos.
`422` `validation_failed` | Una etiqueta de `tag_list` no existe en el catálogo.
`422` `read_only_fields` | <span class="new">nuevo</span> Mandaste `status`, o un total de la cotización (`subtotal`, `total`, `price`, `profit_amount`, `profit_percentage`).
`422` `validation_failed` | <span class="new">nuevo</span> La cuenta no tiene configurada la numeración de cotizaciones («Pide a soporte que la configure»).
`422` `validation_failed` | <span class="new">nuevo</span> Una partida trae un `item_id` o `item_sku` que no es de la cuenta («Concepto no encontrado: …»), un `supplier_id` o `supplier_code` que no es un contacto de la cuenta, o un `supplier_currency_code` que no existe.
`422` `validation_failed` | <span class="new">nuevo</span> Una partida trae un `id` que no es de esta cotización («Estas partidas no son de esta cotización: …»).

Lo demás, en [Errores](#errores).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote": {
      "contact_code": "ACME",
      "currency_code": "USD",
      "exchange_rate": 18.45,
      "due_at": "2026-11-30",
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "service_scope": "port_cy_to_door",
      "incoterm": "FOB",
      "client_ref": "PO-7781",
      "seller_email": "laura@tuempresa.mx",
      "description": "2x40HC autopartes Shanghai → Silao",
      "tag_list": ["autopartes"],
      "line_items_attributes": [
        {
          "item_sku": "AGEN-CARGA",
          "description": "Flete marítimo Shanghai → Manzanillo, 2x40HC",
          "quantity": 2,
          "price": 1950,
          "supplier_code": "NAVPAC",
          "supplier_currency_code": "USD",
          "supplier_unit_price": 1850,
          "supplier_quantity": 2
        },
        {
          "item_id": 77,
          "description": "Despacho aduanal en Manzanillo",
          "quantity": 1,
          "price": 300,
          "supplier_code": "AAPAC",
          "supplier_currency_code": "MXN",
          "supplier_unit_price": 9500,
          "supplier_notes": "Incluye previo"
        }
      ]
    }
  }'
```

```javascript
const { status, body } = await api("/quotes", {
  method: "POST",
  body: JSON.stringify({
    quote: {
      contact_code: "ACME",
      currency_code: "USD",
      exchange_rate: 18.45,
      due_at: "2026-11-30",
      operation_kind: "importation",
      operation_mode: "maritime",
      service_scope: "port_cy_to_door",
      incoterm: "FOB",
      client_ref: "PO-7781",
      seller_email: "laura@tuempresa.mx",
      description: "2x40HC autopartes Shanghai → Silao",
      tag_list: ["autopartes"],
      line_items_attributes: [
        {
          item_sku: "AGEN-CARGA",
          description: "Flete marítimo Shanghai → Manzanillo, 2x40HC",
          quantity: 2,
          price: 1950,
          supplier_code: "NAVPAC",
          supplier_currency_code: "USD",
          supplier_unit_price: 1850,
          supplier_quantity: 2,
        },
        {
          item_id: 77,
          description: "Despacho aduanal en Manzanillo",
          quantity: 1,
          price: 300,
          supplier_code: "AAPAC",
          supplier_currency_code: "MXN",
          supplier_unit_price: 9500,
          supplier_notes: "Incluye previo",
        },
      ],
    },
  }),
});
```

```python
res = api.post(f"{BASE}/quotes", json={
    "quote": {
        "contact_code": "ACME",
        "currency_code": "USD",
        "exchange_rate": 18.45,
        "due_at": "2026-11-30",
        "operation_kind": "importation",
        "operation_mode": "maritime",
        "service_scope": "port_cy_to_door",
        "incoterm": "FOB",
        "client_ref": "PO-7781",
        "seller_email": "laura@tuempresa.mx",
        "description": "2x40HC autopartes Shanghai → Silao",
        "tag_list": ["autopartes"],
        "line_items_attributes": [
            {
                "item_sku": "AGEN-CARGA",
                "description": "Flete marítimo Shanghai → Manzanillo, 2x40HC",
                "quantity": 2,
                "price": 1950,
                "supplier_code": "NAVPAC",
                "supplier_currency_code": "USD",
                "supplier_unit_price": 1850,
                "supplier_quantity": 2,
            },
            {
                "item_id": 77,
                "description": "Despacho aduanal en Manzanillo",
                "quantity": 1,
                "price": 300,
                "supplier_code": "AAPAC",
                "supplier_currency_code": "MXN",
                "supplier_unit_price": 9500,
                "supplier_notes": "Incluye previo",
            },
        ],
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "quote": {
    "id": 906,
    "identification": "COT-000232",
    "status": "drafted",
    "archived": false,
    "archived_at": null,
    "kind": null,
    "date": "2026-11-11T09:30:00.000-06:00",
    "due_at": "2026-11-30T00:00:00.000-06:00",
    "subtotal": "4200.0",
    "total": "4200.0",
    "exchange_rate": "18.45",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "quote_request_id": null,
    "operation_ids": [],
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "client_ref": "PO-7781",
    "created_at": "2026-11-11T09:30:00.000-06:00",
    "updated_at": "2026-11-11T09:30:00.000-06:00",
    "description": "2x40HC autopartes Shanghai → Silao",
    "tags": ["autopartes"],
    "origin_address": null,
    "destination_address": null,
    "line_items_count": 2,
    "document_routes_count": 0,
    "hide_exchange_rate": false,
    "hide_expense_account": false,
    "line_items": [
      {
        "id": 5520,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Agenciamiento de carga",
        "description": "Flete marítimo Shanghai → Manzanillo, 2x40HC",
        "quantity": "2.0",
        "price": "1950.0",
        "discount": "0.0",
        "subtotal": "3900.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "supplier_currency_code": "USD",
        "supplier_unit_price": "1850.0",
        "supplier_quantity": "2.0",
        "supplier_notes": null
      },
      {
        "id": 5521,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Agenciamiento de carga",
        "description": "Despacho aduanal en Manzanillo",
        "quantity": "1.0",
        "price": "300.0",
        "discount": "0.0",
        "subtotal": "300.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 830, "alias": "AAPAC", "name": "Agencia Aduanal del Pacífico" },
        "supplier_currency_code": "MXN",
        "supplier_unit_price": "9500.0",
        "supplier_quantity": "1.0",
        "supplier_notes": "Incluye previo"
      }
    ]
  },
  "message": "Cotización creada exitosamente"
}
```

## Actualizar una cotización

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/quotes/:id</code></div>

<p class="perm">Permiso: <code>quotes_edit</code></p>

Cambio parcial con los mismos campos del alta dentro de `quote`. Los campos que no mandas no cambian. `PUT` también funciona.

- `status` no se acepta: responde **422** `read_only_fields`. El estado cambia con las acciones.
- <span class="new">nuevo</span> Solo se edita una cotización en `drafted`, `need_review`, `approval_requested`, `opened` o `won`, los estados en los que la plataforma ofrece Editar. En los demás (`sent`, `viewed`, `lose`, `invoiced`, `voided`…) responde **422** `validation_failed` con el status en el mensaje.
- `tag_list` reemplaza todas las etiquetas.
- <span class="new">nuevo</span> `line_items_attributes` edita las partidas con los campos de [Crear una cotización](#crear-una-cotizacion): con `id` cambia esa partida (solo los campos que mandas), con `id` y `"_destroy": true` la borra, y sin `id` agrega una. Las partidas que no mandas no cambian. Es la forma de fijar el precio de venta de las partidas que dejó [Generar la cotización de una solicitud](#generar-la-cotizacion-de-una-solicitud) en 0.
- Una cotización archivada es de solo lectura: **422** `archived_read_only` con `suggested_action` `restore`.

### Respuesta

**200** con el detalle en `quote` y `message` («Cotización actualizada exitosamente»), con `subtotal` y `total` recalculados. Los errores son los del alta, más el 422 de una cotización que ya no se edita («Esta cotización ya no se puede editar (status sent)…»).

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/quotes/906 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "quote": { "exchange_rate": 18.62, "due_at": "2026-12-05" } }'
```

> Petición con partidas

```shell
curl -X PATCH https://control.apunto.io/api/v1/quotes/906 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote": {
      "line_items_attributes": [
        { "id": 5520, "price": 2050 },
        { "id": 5521, "_destroy": true }
      ]
    }
  }'
```

> Respuesta 200

```json
{
  "quote": {
    "id": 906,
    "identification": "COT-000232",
    "status": "drafted",
    "archived": false,
    "archived_at": null,
    "kind": null,
    "date": "2026-11-11T09:30:00.000-06:00",
    "due_at": "2026-12-05T00:00:00.000-06:00",
    "subtotal": "4100.0",
    "total": "4100.0",
    "exchange_rate": "18.62",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "quote_request_id": 457,
    "operation_ids": [1042],
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "client_ref": "PO-7781",
    "created_at": "2026-11-11T09:30:00.000-06:00",
    "updated_at": "2026-11-11T09:50:00.000-06:00",
    "description": "2x40HC autopartes Shanghai → Silao",
    "tags": ["autopartes"],
    "origin_address": null,
    "destination_address": null,
    "line_items_count": 1,
    "document_routes_count": 0,
    "hide_exchange_rate": false,
    "hide_expense_account": false,
    "line_items": [
      {
        "id": 5520,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Agenciamiento de carga",
        "description": "Flete marítimo Shanghai → Manzanillo, 2x40HC",
        "quantity": "2.0",
        "price": "2050.0",
        "discount": "0.0",
        "subtotal": "4100.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "supplier_currency_code": "USD",
        "supplier_unit_price": "1850.0",
        "supplier_quantity": "2.0",
        "supplier_notes": null
      }
    ]
  },
  "message": "Cotización actualizada exitosamente"
}
```

> Error 422

```json
{
  "error": "read_only_fields",
  "message": "El status de la cotización cambia con sus acciones: POST /quotes/:id/approve u /open.",
  "errors": ["status no se escribe en esta petición"],
  "fields": ["status"],
  "request_id": "8d2f6a13-0b7e-4c59-a3e1-5f9c4b2d8e70"
}
```

## Solicitar aprobación de una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/approve</code></div>

<p class="perm">Permiso: <code>quotes_edit</code></p>

Pese a su nombre, `approve` **solicita** la aprobación: pasa la cotización de `drafted` a `approval_requested`. Para aprobarla usa [Aprobar una cotización](#aprobar-una-cotizacion). No lleva cuerpo.

### Respuesta

**200** con el detalle en `quote` (`status` `approval_requested`) y `message` («Solicitud de aprobación enviada exitosamente»).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La cotización no está en `drafted` («Solo se puede solicitar aprobación cuando la cotización está en borrador»).
`422` `archived_read_only` | La cotización está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/906/approve \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quote": {
    "id": 906,
    "identification": "COT-000232",
    "status": "approval_requested",
    "archived": false,
    "archived_at": null,
    "kind": null,
    "date": "2026-11-11T09:30:00.000-06:00",
    "due_at": "2026-12-05T00:00:00.000-06:00",
    "subtotal": "4200.0",
    "total": "4200.0",
    "exchange_rate": "18.62",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "quote_request_id": 457,
    "operation_ids": [1042],
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "client_ref": "PO-7781",
    "created_at": "2026-11-11T09:30:00.000-06:00",
    "updated_at": "2026-11-11T09:40:00.000-06:00",
    "description": "2x40HC autopartes Shanghai → Silao",
    "tags": ["autopartes"],
    "origin_address": null,
    "destination_address": null,
    "line_items_count": 2,
    "document_routes_count": 0,
    "hide_exchange_rate": false,
    "hide_expense_account": false,
    "line_items": [
      {
        "id": 5520,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Agenciamiento de carga",
        "description": "Flete marítimo Shanghai → Manzanillo, 2x40HC",
        "quantity": "2.0",
        "price": "1950.0",
        "discount": "0.0",
        "subtotal": "3900.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "supplier_currency_code": "USD",
        "supplier_unit_price": "1850.0",
        "supplier_quantity": "2.0",
        "supplier_notes": null
      },
      {
        "id": 5521,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Agenciamiento de carga",
        "description": "Despacho aduanal en Manzanillo",
        "quantity": "1.0",
        "price": "300.0",
        "discount": "0.0",
        "subtotal": "300.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 830, "alias": "AAPAC", "name": "Agencia Aduanal del Pacífico" },
        "supplier_currency_code": "MXN",
        "supplier_unit_price": "9500.0",
        "supplier_quantity": "1.0",
        "supplier_notes": "Incluye previo"
      }
    ]
  },
  "message": "Solicitud de aprobación enviada exitosamente"
}
```

## Aprobar una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/open</code></div>

<p class="perm">Permiso: <code>quotes_edit</code></p>

Aprueba la cotización: pasa de `approval_requested` a `opened`. No lleva cuerpo.

### Respuesta

**200** con el detalle en `quote` (`status` `opened`) y `message` («Cotización aprobada exitosamente»).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La cotización no está en `approval_requested` («Solo se puede aprobar cuando la cotización está pendiente de aprobación»).
`422` `archived_read_only` | La cotización está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/906/open \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "errors": ["Solo se puede aprobar cuando la cotización está pendiente de aprobación"],
  "message": "No se pudo abrir la cotización",
  "error": "validation_failed",
  "request_id": "2a7e9c41-d6b3-4f08-8e15-b0c3a9f6d742"
}
```

## Clonar una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/clone</code></div>

<p class="perm">Permiso: <code>quotes_create</code></p>

Crea una cotización nueva en `drafted` con un folio nuevo, copiando los datos de la original, sus etiquetas, sus partidas (con impuestos y retenciones) y su ruta. El usuario del token queda como dueño. La copia no queda ligada a la solicitud comercial de la original. No lleva cuerpo.

<span class="new">nuevo</span> La copia nace como un borrador vivo: no hereda el archivado, el resultado (`won_at`, `lose_at`), las fechas de estado, el timbrado ni los pagos de la original. Puedes clonar una cotización archivada.

### Respuesta

**201** con el detalle de la cotización nueva en `quote` y `message` («Cotización clonada exitosamente»). Si no se puede guardar, o la cuenta no tiene numeración de cotizaciones, **422** con `errors`.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/905/clone \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 201

```json
{
  "quote": {
    "id": 907,
    "identification": "COT-000233",
    "status": "drafted",
    "archived": false,
    "archived_at": null,
    "kind": null,
    "date": "2026-11-10T16:00:00.000-06:00",
    "due_at": "2026-11-30T00:00:00.000-06:00",
    "subtotal": "4200.0",
    "total": "4200.0",
    "exchange_rate": "18.45",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "quote_request_id": null,
    "operation_ids": [],
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "client_ref": "PO-7781",
    "created_at": "2026-11-11T11:00:00.000-06:00",
    "updated_at": "2026-11-11T11:00:00.000-06:00",
    "description": "2x40HC autopartes Shanghai → Silao",
    "tags": ["autopartes"],
    "origin_address": null,
    "destination_address": null,
    "line_items_count": 2,
    "document_routes_count": 0,
    "hide_exchange_rate": false,
    "hide_expense_account": false,
    "line_items": [
      {
        "id": 5530,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Flete marítimo",
        "description": "Flete marítimo - Shanghai → Manzanillo, 2x40HC - Tiempo tránsito: 28 días",
        "quantity": "2.0",
        "price": "1950.0",
        "discount": "0.0",
        "subtotal": "3900.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "supplier_currency_code": "USD",
        "supplier_unit_price": "1850.0",
        "supplier_quantity": "2.0",
        "supplier_notes": null
      },
      {
        "id": 5531,
        "item_id": 77,
        "item_sku": "AGEN-CARGA",
        "name": "Despacho aduanal",
        "description": "Despacho aduanal - Pedimento A1 en Manzanillo",
        "quantity": "1.0",
        "price": "300.0",
        "discount": "0.0",
        "subtotal": "300.0",
        "taxes": [],
        "retentions": [],
        "supplier": { "id": 830, "alias": "AAPAC", "name": "Agencia Aduanal del Pacífico" },
        "supplier_currency_code": "MXN",
        "supplier_unit_price": "9500.0",
        "supplier_quantity": "1.0",
        "supplier_notes": "Incluye previo"
      }
    ]
  },
  "message": "Cotización clonada exitosamente"
}
```

## Crear un folio desde una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/create_operation</code></div>

<p class="perm">Permiso: <code>operations_create</code> (y poder ver la cotización)</p>

Convierte la cotización en un [folio operativo](#folios-operativos), o la agrega a un folio que ya existe. Los parámetros van en la raíz del cuerpo, sin objeto `quote`. No cambia el estado de la cotización.

### Folio nuevo

Con `operation_type` `new`, el modo por omisión. Requisitos: el contacto no puede ser prospecto, y la cotización necesita `operation_kind` y `operation_mode`.

El folio nuevo copia de la cotización:

Del folio | Sale de
--------- | -------
`contact` | `contact` de la cotización
`currency` | `currency`
`kind` | `operation_kind`
`mode` | `operation_mode`
`seller` | `seller`
`client_ref`, `incoterm`, `service_scope` | Los mismos campos
Dueño y agente operativo | El usuario del token
Visibilidad | `visibility_scope` del cuerpo, o la de la cotización, o `everyone`

El folio nace en `confirmed` y recibe su `identification` según la secuencia de la cuenta. También copia las líneas de carga y liga la cotización al folio. **No crea servicios ni líneas de centro de costos**: las partidas de la cotización no pasan al folio. Agrega los servicios con [Servicios](#servicios).

Cada llamada crea un folio nuevo; la API no revisa si la cotización ya generó uno. Responde **201**.

### Folio existente

Con `operation_type` `existing`. Liga la cotización a `existing_operation_id` y reparte sus partidas en los servicios del folio como líneas de [centro de costos](#centro-de-costos). El folio tiene que ser del mismo cliente y estar en `confirmed` o `active`, y el contacto no puede ser prospecto. Si el folio no tiene vendedor, toma el de la cotización. Si el folio no tiene líneas de carga, copia las de la cotización. Responde **200**.

Cada partida necesita un servicio destino en `line_items_to_services` o en `line_items_to_new_services`. Las llaves de esos mapas son los `id` de `line_items` del [detalle de la cotización](#obtener-una-cotizacion). Si la cotización no tiene partidas basta con que el folio tenga al menos un servicio.

<span class="new">nuevo</span> La liga, el vendedor y las partidas son un solo cambio: si a una partida le falta destino o algo falla, responde **422** y el folio queda como estaba (sin la cotización ligada ni el vendedor). El `board_id` de `new_services` tiene que ser un tablero de la cuenta.

### Cuerpo de la petición

Campo | Tipo | Descripción
--------- | ---- | -----------
`operation_type` | string | <span class="opt">opcional</span> `new` (por omisión) o `existing`.
`visibility_scope` | string | <span class="opt">opcional</span> Solo `new`. `everyone`, `group` u `owner`.
`work_group_id` | integer | <span class="opt">opcional</span> Solo `new`, con `visibility_scope` `group`. Por omisión, el de la cotización.
`existing_operation_id` | integer | <span class="opt">opcional</span> Obligatorio con `existing`. Id del folio.
`line_items_to_services` | object | <span class="opt">opcional</span> Solo `existing`. `{ "<id de partida>": "<id de servicio del folio>" }`.
`new_services` | object | <span class="opt">opcional</span> Solo `existing`. Servicios a crear en el folio: `{ "0": { "board_id", "shipment_kind", "shipment_type" } }`. La llave es un índice de grupo. Ver [Servicios](#servicios) para `board_id`.
`line_items_to_new_services` | object | <span class="opt">opcional</span> Solo `existing`. `{ "<id de partida>": "<índice de grupo de new_services>" }`.

### Respuesta

**201** (folio nuevo) o **200** (folio existente) con un resumen del folio en `operation` y `message`. El detalle completo está en [Folios operativos](#folios-operativos).

Campo | Tipo | Descripción
--------- | ---- | -----------
`operation.id` | integer | Id del folio.
`operation.identification` | string | Folio, por ejemplo `IMP-ACME-000184`.
`operation.kind`, `operation.mode` | string | Tipo y modo.
`operation.status` | string | Estado del folio.
`operation.client_ref` | string | Referencia del cliente.
`operation.contact` | object | `{ "id", "alias", "name" }`.
`operation.currency` | object | `{ "id", "code", "name" }`.
`operation.created_at`, `operation.updated_at` | datetime | Alta y último cambio.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | El contacto de la cotización es prospecto («No se puede convertir una cotización con contacto prospecto»). Conviértelo antes en la plataforma (ver [Convertir un prospecto en cliente](#convertir-un-prospecto-en-cliente)).
`422` `validation_failed` | Faltan `operation_kind` u `operation_mode` en la cotización («Faltan campos requeridos: operation_kind, operation_mode»).
`422` `validation_failed` | Con `existing`: falta `existing_operation_id`, el folio no existe en la cuenta, es de otro cliente, o no está en `confirmed` ni `active`.
`422` `validation_failed` | Con `existing`: el folio no tiene servicios y no mandaste `new_services`.
`422` `validation_failed` | <span class="new">nuevo</span> Con `existing`: una partida no tiene servicio destino («No se especificó un servicio válido para la línea …»), o el `board_id` no es un tablero de la cuenta («No se encontró el flujo (board) para el nuevo servicio»).
`422` `archived_read_only` | La cotización está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/905/create_operation \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "operation_type": "new" }'
```

> Respuesta 201

```json
{
  "operation": {
    "id": 1042,
    "identification": "IMP-ACME-000184",
    "kind": "importation",
    "mode": "maritime",
    "status": "confirmed",
    "client_ref": "PO-7781",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "id": 2, "code": "USD", "name": "Dólar estadounidense" },
    "created_at": "2026-11-11T12:00:00.000-06:00",
    "updated_at": "2026-11-11T12:00:00.000-06:00"
  },
  "message": "Operación creada exitosamente desde la cotización"
}
```

> Error 422

```json
{
  "errors": ["Faltan campos requeridos: operation_kind, operation_mode"],
  "message": "No se pudo crear la operación desde la cotización",
  "error": "validation_failed",
  "request_id": "6c1d8b2e-f305-4a7c-9e48-d2b7a0c5f9e1"
}
```

## Archivar y restaurar una cotización

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quotes/:id/restore</code></div>

<p class="perm">Permiso: <code>quotes_edit</code></p>

Archivar saca la cotización de los listados sin borrarla; restaurar la regresa con el mismo estado. Ni el folio operativo ni su liga con la cotización cambian. Responden la decisión del ciclo de vida. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

Archivar depende del estado:

- `drafted`, `need_review`, `approval_requested`, `opened`, `sent`, `viewed`, `partial` o `paid`: responde `confirm` con `code` `will_mark_lost`. Repite con `confirmed=true` y la cotización pasa a `lose` y se archiva.
- `won`, `lose`, `invoiced` o `voided`: se archiva sin cambiar el estado (`allow`).
- Ya archivada: `reject` con `code` `already_archived`.

Restaurar responde `allow`, o `reject` con `not_archived`.

### Parámetros

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`confirmed` | boolean | <span class="opt">opcional</span> `true` para confirmar el archivado de una cotización abierta. Va en la raíz del cuerpo o en la URL.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/906/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "confirm",
  "code": "will_mark_lost",
  "title": "¿Archivar esta cotización?",
  "message": "Esta cotización quedará perdida y dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados; al restaurarla, sigue perdida.",
  "suggested_action": null,
  "errors": ["Esta cotización quedará perdida y dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados; al restaurarla, sigue perdida."],
  "error": "will_mark_lost",
  "request_id": "d9f3a7c0-1e64-4b82-b5d9-07e2c8a4f163"
}
```

> Petición con confirmación

```shell
curl -X POST https://control.apunto.io/api/v1/quotes/906/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "confirmed": true }'
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

## Eliminar una cotización

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/quotes/:id</code></div>

<p class="perm">Permiso: <code>quotes_delete</code></p>

Las cotizaciones **no se eliminan**. Este endpoint siempre responde **422** con `outcome` `reject`, `code` `delete_not_allowed` y `suggested_action` `archive`, y no cambia nada. Usa [Archivar y restaurar una cotización](#archivar-y-restaurar-una-cotizacion).

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/quotes/906 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "delete_not_allowed",
  "title": "No puedes eliminar esta cotización",
  "message": "Esta cotización no se elimina. Archívala: dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados, donde puedes restaurarla.",
  "suggested_action": "archive",
  "errors": ["Esta cotización no se elimina. Archívala: dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados, donde puedes restaurarla."],
  "error": "delete_not_allowed",
  "request_id": "1b5e0d9a-7c32-4f6e-a8d4-93c6b2e1f057"
}
```
