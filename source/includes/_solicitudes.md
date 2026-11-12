# Solicitudes comerciales

<p class="lead">Una solicitud comercial (<code>quote_request</code>) es el pedido de cotización de un cliente: ruta, carga y condiciones. Pasa por pricing, que consigue los costos con proveedores, y termina en una cotización ganada o perdida. Una integración las usa para registrar pedidos que llegan por portal, correo o CRM, cargar precios de proveedores y cerrar el resultado.</p>

Cada solicitud vive en una columna de un pipeline de cotización (`list_id`). Las columnas y sus ids salen de `GET /api/v1/quotation_pipelines`; los motivos de ganada y perdida, de `GET /api/v1/quote_won_reasons` y `GET /api/v1/quote_lost_reasons`. Los tres se documentan en [Catálogos](#catalogos). Puede ligarse a una [oportunidad](#oportunidades) y de ella sale la [cotización](#cotizaciones).

Una solicitud tiene dos datos de avance que no se mezclan:

- **`status`**: la etapa del pipeline. Cambia al mover la solicitud de columna (`list_id`) o con algunas acciones. No se escribe directo en un cambio.
- **`result`**: el resultado comercial. `null` o `pending` = abierta, `won` = ganada, `lost` = perdida. Solo cambia con [ganar](#marcar-una-solicitud-como-ganada), [perder](#marcar-una-solicitud-como-perdida), [reabrir](#reabrir-una-solicitud-comercial) o al archivar una abierta.

**Etapas (`status`):**

Estado | Leyenda | Qué significa
--------- | ---- | -----------
`start` | Inicio | Recién capturada. Estado por omisión.
`requested` | Solicitado | Se pidió precio a pricing. Al entrar, la plataforma abre una solicitud en la bandeja de pricing (un precio con `pricing_status` `solicitud_por_atender`) si no hay otra abierta. Solo en esta etapa puedes [agregar precios](#agregar-un-precio-a-una-solicitud).
`adjustments_requested` | Ajustes solicitados | Comercial pidió ajustes a pricing. La solicitud regresa a la columna de pricing.
`quoted` | Cotizado | Hay al menos un precio aceptado por comercial (`pricing_status` `completada`).
`vobo` | Visto bueno | Ya tiene una cotización generada.
`finished` | Finalizado | Cerrada. Para llegar avanzando necesita resultado `won` o `lost`.

**Mover de columna.** Cada columna puede tener un estado destino (`target_quote_request_status` en el catálogo). Al cambiar `list_id`:

- Hacia adelante, la solicitud toma el estado de la columna solo si el paso es válido: `requested` desde `start` o `adjustments_requested`; `quoted` desde `requested` o `adjustments_requested` con un precio `completada`; `vobo` desde `quoted` con una cotización ligada; `finished` desde `vobo` con resultado; `adjustments_requested` desde `quoted` o `vobo`. Si no es válido, cambia la columna pero el estado se queda igual.
- Hacia atrás, toma el estado de la columna sin revisar nada.
- La primera vez que entra a una columna se crean las tareas de plantilla de esa columna, y cada vez que entra se mandan sus correos automáticos.

El estado de los precios (`pricing_status`) cambia en la plataforma: pricing envía la propuesta a revisión y comercial la acepta. La API no lo cambia, así que el paso a `quoted` depende de ese trabajo en la plataforma.

## El objeto solicitud comercial

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la solicitud.
`identification` | string | <span class="ro">solo lectura</span> Folio que asigna la secuencia de la cuenta (por ejemplo `SOL-000157`), o `null` si no hay secuencia.
`status` | string | <span class="ro">solo lectura</span> Etapa del pipeline. Ver la tabla de etapas. Solo se escribe en el alta.
`result` | string | <span class="ro">solo lectura</span> `null` o `pending` (abierta), `won` o `lost`.
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivada.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`.
`origin` | string | Origen en texto.
`destination` | string | Destino en texto.
`transport_mode` | string | `ocean`, `air`, `truck`, `rail` o `multimodal`. Si `operation_mode` tiene valor, se deriva de él (`maritime` → `ocean`, `aerial` → `air`, `land` → `truck`); si no, por omisión `multimodal`.
`operation_kind` | string | `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company` o `import_trading_company`.
`operation_mode` | string | `maritime`, `aerial` o `land`.
`service_scope` | string | Alcance puerta/puerto, por ejemplo `door_to_door`, `port_cy_to_door`, `airport_to_airport`. Valores en [Crear una solicitud comercial](#crear-una-solicitud-comercial).
`incoterm` | string | Incoterm en texto libre (`FOB`, `EXW`, …).
`deal_amount` | decimal | Monto estimado del negocio, o `null`.
`closing_date` | date | Fecha estimada de cierre, o `null`.
`cargo_details` | string | Descripción de la carga.
`contact` | object | <span class="ro">solo lectura</span> `{ "id", "alias", "name" }` del cliente o prospecto, o `null`.
`owner` | object | <span class="ro">solo lectura</span> Quien la creó: `{ "id", "name", "email" }`.
`assignee` | object | <span class="ro">solo lectura</span> Responsable de pricing: `{ "id", "name", "email" }`, o `null`. Se escribe con `assignee_id` o `assignee_email`.
`seller` | object | <span class="ro">solo lectura</span> Vendedor: `{ "id", "name", "email" }`, o `null`. Se escribe con `seller_id` o `seller_email`.
`opportunity` | object | <span class="ro">solo lectura</span> `{ "id", "identification", "title" }`, o `null`.
`list` | object | <span class="ro">solo lectura</span> Columna actual: `{ "id", "name" }`. Se escribe con `list_id`.
`created_at` | datetime | <span class="ro">solo lectura</span> Alta.
`updated_at` | datetime | <span class="ro">solo lectura</span> Último cambio.
`movement_details` | string | Detalle del movimiento. Solo en el detalle.
`total_pricing_amount` | decimal | <span class="ro">solo lectura</span> Suma del `total_price` de los precios publicados. Solo en el detalle.
`minutes_to_result` | integer | <span class="ro">solo lectura</span> Minutos entre el alta y el resultado; `0` si está abierta. Solo en el detalle.
`tags` | array&lt;string&gt; | Etiquetas. Se escriben con `tag_list`. Solo en el detalle.
`shipment_items` | array&lt;object&gt; | Líneas de carga (tabla abajo). Se escriben con `shipment_items_attributes`. Solo en el detalle.
`quote_request_pricings_count` | integer | <span class="ro">solo lectura</span> Precios de la solicitud. Solo en el detalle.
`quotes_count` | integer | <span class="ro">solo lectura</span> Cotizaciones ligadas: las de sus precios y la que dejó [`create_quote`](#generar-la-cotizacion-de-una-solicitud). Solo en el detalle.
`activities_count`, `messages_count`, `to_dos_count` | integer | <span class="ro">solo lectura</span> Actividades, comentarios y tareas de la solicitud. Solo en el detalle.
`deal_currency` | object | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Moneda de `deal_amount`: `{ "id", "code" }`, o `null`. Se escribe con `deal_currency_id`. Solo en el detalle.
`volumetric_factor_code` | string | <span class="new">nuevo</span> Factor volumétrico. Solo en el detalle.
`origin_port`, `destination_port` | object | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Puerto del catálogo: `{ "id", "code", "name", "country" }`, o `null`. Se escriben con `origin_port_id` y `destination_port_id`. Solo en el detalle.
`document_routes` | array&lt;object&gt; | <span class="new">nuevo</span> Puntos de ruta en orden: `id`, `address_kind`, `address_type`, `location_name`, `address_id`, `port_data_id`, `position` y `description`. Se escriben con `document_routes_attributes`. Solo en el detalle.
`result_at` | datetime | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Fecha del resultado, o `null` si está abierta. Solo en el detalle.
`result_notes` | string | <span class="new">nuevo</span> Notas del resultado. Solo en el detalle.
`quote_won_reason`, `quote_lost_reason` | object | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Motivo de ganada o de pérdida: `{ "id", "name" }`, o `null`. Solo en el detalle.
`quote_ids` | array&lt;integer&gt; | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Ids de las cotizaciones ligadas, los mismos que acepta `winner_quote_ids`. Solo en el detalle.

El listado devuelve los campos hasta `updated_at`. El detalle, el alta, el cambio y las acciones agregan el resto.

**Líneas de carga (`shipment_items`):**

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la línea.
`cargo_type` | string | `container`, `loose_cargo` (carga suelta) o `vehicle`.
`package_type` | string | Carga suelta: `pallets` o `boxes_crates`.
`pallet_type` | string | `non_specified`, `48x40_inches`, `120x80cm_eur1` o `120x100cm_eur2`.
`container_type` | string | Contenedor: `twenty_ft`, `forty_ft`, `forty_ft_hc`, `forty_five_ft_hc`, `dry_van_20`, `dry_van_40`, `high_cube_40`, `reefer_20`, `reefer_40`, `open_top_20`, `open_top_40`, `flat_rack_20`, `flat_rack_40`, `open_side_20`, `open_side_40` o `iso_tank`.
`quantity` | integer | Cantidad, mayor que 0.
`length`, `width`, `height` | decimal | Medidas por pieza.
`weight` | decimal | Peso.
`unit_length` | string | `cm` (por omisión), `inches`, `meters`, `mm` o `ft`.
`unit_weight` | string | `kg` (por omisión), `lbs`, `tons`, `g` u `oz`.
`container_number` | string | Número de contenedor.
`unit_type_id` | integer | Tipo de unidad para `vehicle`.

> Objeto solicitud comercial

```json
{
  "id": 457,
  "identification": "SOL-000157",
  "status": "requested",
  "result": null,
  "archived": false,
  "archived_at": null,
  "origin": "Shanghai, China",
  "destination": "Manzanillo, Colima",
  "transport_mode": "ocean",
  "operation_kind": "importation",
  "operation_mode": "maritime",
  "service_scope": "port_cy_to_door",
  "incoterm": "FOB",
  "deal_amount": "18500.0",
  "closing_date": "2026-11-30",
  "cargo_details": "2x40HC autopartes",
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
  "assignee": null,
  "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
  "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
  "list": { "id": 611, "name": "Pricing" },
  "created_at": "2026-11-09T11:20:00.000-06:00",
  "updated_at": "2026-11-10T09:05:00.000-06:00",
  "movement_details": "Entrega en planta Silao, Gto.",
  "total_pricing_amount": "0.0",
  "minutes_to_result": 0,
  "tags": ["autopartes"],
  "shipment_items": [
    {
      "id": 2051,
      "cargo_type": "container",
      "package_type": null,
      "pallet_type": null,
      "container_type": "forty_ft_hc",
      "quantity": 2,
      "length": null,
      "width": null,
      "height": null,
      "weight": "18000.0",
      "unit_length": "cm",
      "unit_weight": "kg",
      "container_number": null,
      "unit_type_id": null
    }
  ],
  "quote_request_pricings_count": 1,
  "quotes_count": 0,
  "activities_count": 3,
  "messages_count": 0,
  "to_dos_count": 2,
  "deal_currency": { "id": 2, "code": "USD" },
  "volumetric_factor_code": "ground_6000",
  "origin_port": null,
  "destination_port": null,
  "document_routes": [],
  "result_at": null,
  "result_notes": null,
  "quote_won_reason": null,
  "quote_lost_reason": null,
  "quote_ids": []
}
```

## Listar solicitudes comerciales

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_requests</code></div>

<p class="perm">Permiso: <code>quote_requests_read</code></p>

Devuelve las solicitudes no archivadas que el usuario puede ver, de la más reciente a la más antigua (`created_at`). Con `updated_since` el orden cambia a `updated_at, id`. `total` cuenta la lista ya filtrada.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> Solo solicitudes en esa etapa (`start`, `requested`, `adjustments_requested`, `quoted`, `vobo`, `finished`).
`result` | string | <span class="opt">opcional</span> `pending`, `won` o `lost`. <span class="new">nuevo</span> `pending` trae todas las abiertas, con `result` `null` o `pending`.
`transport_mode` | string | <span class="opt">opcional</span> `ocean`, `air`, `truck`, `rail` o `multimodal`.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo las archivadas. Se combina con los demás filtros. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen el `identification`.

Un valor que no existe en `status`, `result` o `transport_mode` no da error: devuelve una lista vacía.

> Petición

```shell
curl "https://control.apunto.io/api/v1/quote_requests?status=requested&transport_mode=ocean&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quote_requests": [
    {
      "id": 457,
      "identification": "SOL-000157",
      "status": "requested",
      "result": null,
      "archived": false,
      "archived_at": null,
      "origin": "Shanghai, China",
      "destination": "Manzanillo, Colima",
      "transport_mode": "ocean",
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "service_scope": "port_cy_to_door",
      "incoterm": "FOB",
      "deal_amount": "18500.0",
      "closing_date": "2026-11-30",
      "cargo_details": "2x40HC autopartes",
      "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
      "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
      "assignee": null,
      "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
      "list": { "id": 611, "name": "Pricing" },
      "created_at": "2026-11-09T11:20:00.000-06:00",
      "updated_at": "2026-11-10T09:05:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Obtener una solicitud comercial

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_requests/:id</code></div>

<p class="perm">Permiso: <code>quote_requests_read</code></p>

Devuelve el detalle en `quote_request`, con la misma forma que [el objeto](#el-objeto-solicitud-comercial). También responde con solicitudes archivadas.

> Petición

```shell
curl https://control.apunto.io/api/v1/quote_requests/457 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "quote_request": {
    "id": 457,
    "identification": "SOL-000157",
    "status": "requested",
    "result": null,
    "archived": false,
    "archived_at": null,
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "transport_mode": "ocean",
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "deal_amount": "18500.0",
    "closing_date": "2026-11-30",
    "cargo_details": "2x40HC autopartes",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "assignee": null,
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
    "list": { "id": 611, "name": "Pricing" },
    "created_at": "2026-11-09T11:20:00.000-06:00",
    "updated_at": "2026-11-10T09:05:00.000-06:00",
    "movement_details": "Entrega en planta Silao, Gto.",
    "total_pricing_amount": "0.0",
    "minutes_to_result": 0,
    "tags": ["autopartes"],
    "shipment_items": [
      {
        "id": 2051,
        "cargo_type": "container",
        "package_type": null,
        "pallet_type": null,
        "container_type": "forty_ft_hc",
        "quantity": 2,
        "length": null,
        "width": null,
        "height": null,
        "weight": "18000.0",
        "unit_length": "cm",
        "unit_weight": "kg",
        "container_number": null,
        "unit_type_id": null
      }
    ],
    "quote_request_pricings_count": 1,
    "quotes_count": 0,
    "activities_count": 3,
    "messages_count": 0,
    "to_dos_count": 2,
    "deal_currency": { "id": 2, "code": "USD" },
    "volumetric_factor_code": "ground_6000",
    "origin_port": null,
    "destination_port": null,
    "document_routes": [],
    "result_at": null,
    "result_notes": null,
    "quote_won_reason": null,
    "quote_lost_reason": null,
    "quote_ids": []
  }
}
```

## Crear una solicitud comercial

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests</code></div>

<p class="perm">Permiso: <code>quote_requests_create</code></p>

Crea la solicitud en la columna que indicas. El usuario del token queda como `owner`. Si la columna tiene un estado destino, al crearse se aplica la misma regla que al mover de columna, partiendo del `status` del alta (ver **Mover de columna** en [Solicitudes comerciales](#solicitudes-comerciales)).

### Cuerpo de la petición

Todo va dentro de `quote_request`.

Campo | Tipo | Descripción
--------- | ---- | -----------
`list_id` | integer | <span class="req">obligatorio</span> Columna del pipeline, de `GET /api/v1/quotation_pipelines` (ver [Catálogos](#catalogos)). Tiene que ser de la cuenta.
`origin` | string | <span class="req">obligatorio</span> Origen. Si mandas rutas (`document_routes_attributes`), se toma de la primera ruta de origen.
`destination` | string | <span class="req">obligatorio</span> Destino. Con rutas, se toma de la primera ruta de destino.
`contact_code` | string | <span class="opt">opcional</span> Alias del cliente o prospecto.
`contact_id` | integer | <span class="opt">opcional</span> Alternativa a `contact_code`. Tiene que ser de la cuenta.
`opportunity_identification` | string | <span class="opt">opcional</span> Folio de la oportunidad (`OP-000045`).
`opportunity_id` | integer | <span class="opt">opcional</span> Alternativa a `opportunity_identification`. Tiene que ser de la cuenta.
`assignee_email` | string | <span class="opt">opcional</span> Correo del responsable de pricing, usuario de la cuenta.
`assignee_id` | integer | <span class="opt">opcional</span> Alternativa a `assignee_email`. Tiene que ser miembro de la cuenta.
`seller_email` | string | <span class="opt">opcional</span> Correo del vendedor, usuario de la cuenta.
`seller_id` | integer | <span class="opt">opcional</span> Alternativa a `seller_email`. Tiene que ser miembro de la cuenta.
`operation_kind` | string | <span class="opt">opcional</span> Tipo de operación. Valores en el objeto.
`operation_mode` | string | <span class="opt">opcional</span> `maritime`, `aerial` o `land`. Fija `transport_mode`.
`transport_mode` | string | <span class="opt">opcional</span> `ocean`, `air`, `truck`, `rail` o `multimodal`. Si la solicitud tiene `operation_mode`, se reemplaza por el que le corresponde.
`service_scope` | string | <span class="opt">opcional</span> `door_to_port_cy`, `door_to_port_cfs`, `port_cy_to_port_cy`, `port_cfs_to_port_cfs`, `port_cy_to_door`, `port_cfs_to_door`, `door_to_door`, `door_to_airport`, `airport_to_airport`, `airport_to_door`, `door_to_rail_ramp`, `rail_ramp_to_rail_ramp`, `rail_ramp_to_door`, `door_to_truck_terminal`, `truck_terminal_to_truck_terminal`, `truck_terminal_to_door`, `port_cy_to_airport`, `port_cfs_to_airport`, `airport_to_port_cy`, `airport_to_port_cfs`, `port_cy_to_rail_ramp`, `port_cfs_to_rail_ramp`, `rail_ramp_to_port_cy`, `rail_ramp_to_port_cfs`, `rail_ramp_to_airport` o `airport_to_rail_ramp`.
`incoterm` | string | <span class="opt">opcional</span> Texto libre.
`origin_port_id`, `destination_port_id` | integer | <span class="opt">opcional</span> Puertos del catálogo de puertos de la plataforma.
`cargo_details` | string | <span class="opt">opcional</span> Descripción de la carga.
`movement_details` | string | <span class="opt">opcional</span> Detalle del movimiento.
`status` | string | <span class="opt">opcional</span> Etapa inicial: `start` (por omisión) o `requested`, las mismas con las que la plataforma crea una solicitud. Con `requested` se abre la solicitud en la bandeja de pricing. <span class="new">nuevo</span> Otra etapa responde 422.
`volumetric_factor_code` | string | <span class="opt">opcional</span> Factor volumétrico para carga suelta: `ground_6000` (por omisión), `air_6000`, `air_5000` o `lcl_1000000`.
`deal_amount` | decimal | <span class="opt">opcional</span> Monto estimado, mayor o igual a 0.
`deal_currency_id` | integer | <span class="opt">opcional</span> Moneda de `deal_amount`. Obligatoria si mandas `deal_amount`. No acepta código.
`closing_date` | date | <span class="opt">opcional</span> Fecha estimada de cierre.
`result_notes` | string | <span class="opt">opcional</span> Notas del resultado. Las reemplazan ganar, perder y reabrir.
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta.
`shipment_items_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Líneas de carga con los campos de la tabla de líneas (sin `id`). También acepta `overweight` (boolean), que no se devuelve.
`document_routes_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Rutas con varios puntos: `address_kind` (`origin` o `destination`, obligatorio), `location_name`, `address_id` o `port_data_id` (al menos uno de los tres), `address_type` (`billing`, `shipping`, `port`, `customs`, `airport` o `general`), `position` y `description`.
`result` | string | No se acepta: responde 422 `read_only_fields`. Usa las acciones de resultado.

Reglas de las líneas de carga:

- `cargo_type` y `quantity` mayor que 0 son obligatorios. `container` necesita `container_type`; `loose_cargo`, `package_type`; `vehicle`, `unit_type_id`. Una línea a la que le falta alguno de esos datos **se descarta sin error**.
- Carga suelta necesita `weight` y `unit_weight`; en solicitudes aéreas también `length`, `width`, `height` y `unit_length`. Los contenedores `open_top`, `flat_rack` y `open_side` necesitan medidas y peso.
- Si mandas contenedores y carga suelta juntos, se quedan los contenedores y se descarta la carga suelta.

### Respuesta

**201** con el detalle en `quote_request` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `list_id`, `origin` o `destination`; `deal_amount` sin `deal_currency_id`; una línea de carga completa con datos inválidos.
`422` `validation_failed` | `contact_code` u `opportunity_identification` no existen en la cuenta, o un `*_id` es de otra cuenta.
`422` `validation_failed` | `assignee_email` o `seller_email` no son usuarios de la cuenta, o `assignee_id` / `seller_id` no son miembros.
`422` `validation_failed` | `status`, `transport_mode`, `operation_kind`, `operation_mode` o `service_scope` fuera de su lista; el mensaje trae los valores válidos.
`422` `validation_failed` | Una etiqueta de `tag_list` no existe en el catálogo.
`422` `read_only_fields` | <span class="new">nuevo</span> Mandaste `result`.
`422` `validation_failed` | <span class="new">nuevo</span> `status` es `quoted`, `vobo`, `finished` o `adjustments_requested`. Esas etapas se alcanzan moviendo la solicitud de columna o con sus acciones.
`422` `archived_read_only` | La oportunidad indicada está archivada.

Lo demás, en [Errores](#errores).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote_request": {
      "list_id": 610,
      "contact_code": "ACME",
      "opportunity_identification": "OP-000045",
      "seller_email": "laura@tuempresa.mx",
      "origin": "Shanghai, China",
      "destination": "Manzanillo, Colima",
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "service_scope": "port_cy_to_door",
      "incoterm": "FOB",
      "cargo_details": "2x40HC autopartes",
      "movement_details": "Entrega en planta Silao, Gto.",
      "deal_amount": 18500,
      "deal_currency_id": 2,
      "closing_date": "2026-11-30",
      "tag_list": ["autopartes"],
      "shipment_items_attributes": [
        { "cargo_type": "container", "container_type": "forty_ft_hc", "quantity": 2, "weight": 18000, "unit_weight": "kg" }
      ]
    }
  }'
```

```javascript
const { status, body } = await api("/quote_requests", {
  method: "POST",
  body: JSON.stringify({
    quote_request: {
      list_id: 610,
      contact_code: "ACME",
      opportunity_identification: "OP-000045",
      seller_email: "laura@tuempresa.mx",
      origin: "Shanghai, China",
      destination: "Manzanillo, Colima",
      operation_kind: "importation",
      operation_mode: "maritime",
      service_scope: "port_cy_to_door",
      incoterm: "FOB",
      cargo_details: "2x40HC autopartes",
      movement_details: "Entrega en planta Silao, Gto.",
      deal_amount: 18500,
      deal_currency_id: 2,
      closing_date: "2026-11-30",
      tag_list: ["autopartes"],
      shipment_items_attributes: [
        { cargo_type: "container", container_type: "forty_ft_hc", quantity: 2, weight: 18000, unit_weight: "kg" },
      ],
    },
  }),
});
```

```python
res = api.post(f"{BASE}/quote_requests", json={
    "quote_request": {
        "list_id": 610,
        "contact_code": "ACME",
        "opportunity_identification": "OP-000045",
        "seller_email": "laura@tuempresa.mx",
        "origin": "Shanghai, China",
        "destination": "Manzanillo, Colima",
        "operation_kind": "importation",
        "operation_mode": "maritime",
        "service_scope": "port_cy_to_door",
        "incoterm": "FOB",
        "cargo_details": "2x40HC autopartes",
        "movement_details": "Entrega en planta Silao, Gto.",
        "deal_amount": 18500,
        "deal_currency_id": 2,
        "closing_date": "2026-11-30",
        "tag_list": ["autopartes"],
        "shipment_items_attributes": [
            {"cargo_type": "container", "container_type": "forty_ft_hc", "quantity": 2, "weight": 18000, "unit_weight": "kg"},
        ],
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "quote_request": {
    "id": 457,
    "identification": "SOL-000157",
    "status": "start",
    "result": null,
    "archived": false,
    "archived_at": null,
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "transport_mode": "ocean",
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "deal_amount": "18500.0",
    "closing_date": "2026-11-30",
    "cargo_details": "2x40HC autopartes",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "assignee": null,
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
    "list": { "id": 610, "name": "Nueva" },
    "created_at": "2026-11-09T11:20:00.000-06:00",
    "updated_at": "2026-11-09T11:20:00.000-06:00",
    "movement_details": "Entrega en planta Silao, Gto.",
    "total_pricing_amount": "0.0",
    "minutes_to_result": 0,
    "tags": ["autopartes"],
    "shipment_items": [
      {
        "id": 2051,
        "cargo_type": "container",
        "package_type": null,
        "pallet_type": null,
        "container_type": "forty_ft_hc",
        "quantity": 2,
        "length": null,
        "width": null,
        "height": null,
        "weight": "18000.0",
        "unit_length": "cm",
        "unit_weight": "kg",
        "container_number": null,
        "unit_type_id": null
      }
    ],
    "quote_request_pricings_count": 0,
    "quotes_count": 0,
    "activities_count": 1,
    "messages_count": 0,
    "to_dos_count": 0,
    "deal_currency": { "id": 2, "code": "USD" },
    "volumetric_factor_code": "ground_6000",
    "origin_port": null,
    "destination_port": null,
    "document_routes": [],
    "result_at": null,
    "result_notes": null,
    "quote_won_reason": null,
    "quote_lost_reason": null,
    "quote_ids": []
  },
  "message": "Solicitud comercial creada exitosamente"
}
```

## Actualizar una solicitud comercial

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/quote_requests/:id</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Cambio parcial con los mismos campos del alta dentro de `quote_request`. Los campos que no mandas no cambian. `PUT` también funciona.

- Para mover la solicitud de etapa, cambia `list_id`. Ver las reglas en **Mover de columna**, en [Solicitudes comerciales](#solicitudes-comerciales).
- `status` y `result` no se aceptan: responden **422** `read_only_fields` con el campo en `fields`.
- En `shipment_items_attributes` y `document_routes_attributes`, una línea con `id` se edita y con `"_destroy": true` se quita. Sin `id`, se agrega.
- `tag_list` reemplaza todas las etiquetas.
- Una solicitud archivada es de solo lectura: **422** `archived_read_only` con `suggested_action` `restore`.

### Respuesta

**200** con el detalle en `quote_request` y `message`. Los errores son los del alta, más `read_only_fields` si mandas `status`.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/quote_requests/457 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "quote_request": { "list_id": 611 } }'
```

> Respuesta 200

```json
{
  "quote_request": {
    "id": 457,
    "identification": "SOL-000157",
    "status": "requested",
    "result": null,
    "archived": false,
    "archived_at": null,
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "transport_mode": "ocean",
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "deal_amount": "18500.0",
    "closing_date": "2026-11-30",
    "cargo_details": "2x40HC autopartes",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "assignee": null,
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
    "list": { "id": 611, "name": "Pricing" },
    "created_at": "2026-11-09T11:20:00.000-06:00",
    "updated_at": "2026-11-10T09:05:00.000-06:00",
    "movement_details": "Entrega en planta Silao, Gto.",
    "total_pricing_amount": "0.0",
    "minutes_to_result": 0,
    "tags": ["autopartes"],
    "shipment_items": [
      {
        "id": 2051,
        "cargo_type": "container",
        "package_type": null,
        "pallet_type": null,
        "container_type": "forty_ft_hc",
        "quantity": 2,
        "length": null,
        "width": null,
        "height": null,
        "weight": "18000.0",
        "unit_length": "cm",
        "unit_weight": "kg",
        "container_number": null,
        "unit_type_id": null
      }
    ],
    "quote_request_pricings_count": 1,
    "quotes_count": 0,
    "activities_count": 3,
    "messages_count": 0,
    "to_dos_count": 2,
    "deal_currency": { "id": 2, "code": "USD" },
    "volumetric_factor_code": "ground_6000",
    "origin_port": null,
    "destination_port": null,
    "document_routes": [],
    "result_at": null,
    "result_notes": null,
    "quote_won_reason": null,
    "quote_lost_reason": null,
    "quote_ids": []
  },
  "message": "Solicitud comercial actualizada exitosamente"
}
```

> Error 422

```json
{
  "error": "read_only_fields",
  "message": "El resultado y el status cambian con POST /quote_requests/:id/mark_as_won, /mark_as_lost o /reopen; la columna se mueve con list_id.",
  "errors": ["status no se escribe en esta petición"],
  "fields": ["status"],
  "request_id": "9a1c3e5f-7b2d-4c80-a6e4-0f3b8d2c1a97"
}
```

## El objeto precio de solicitud

Un precio (`quote_request_pricing`) es la propuesta de costos que arma pricing para una solicitud. Tiene **líneas** (conceptos: flete, despacho, maniobras) y cada línea tiene uno o más **proveedores**, cada uno con su propia moneda, cantidad, precio y tiempo de tránsito. La moneda vive en el proveedor de la línea, no en el precio: en un mismo precio puedes tener el flete en USD y el despacho en MXN.

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id del precio.
`service_name` | string | Nombre del precio. Si no lo mandas, toma el de la primera línea o «Cotización».
`service_description` | string | Descripción.
`unit_price` | decimal | Precio unitario a nivel precio, o `null`.
`total_price` | decimal | Total a nivel precio, o `null`. **No se calcula con las líneas.** Es el monto que suma `total_pricing_amount` de la solicitud.
`quantity` | integer | Cantidad. Mínimo 1; si mandas 0 o nada, queda 1.
`unit_type` | string | Unidad en texto libre.
`notes` | string | Notas.
`is_suggestion` | boolean | `true` si el precio salió de una sugerencia del tarifario.
`pricing_catalog_id` | integer | Tarifario de origen, o `null`.
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span> Alta y último cambio.
`draft` | boolean | <span class="ro">solo lectura</span> Siempre `false` en la API: los borradores no se listan.
`identification` | string | <span class="ro">solo lectura</span> Folio que asigna la secuencia de la cuenta (por ejemplo `PRI-000221`), o `null`.
`title` | string | <span class="ro">solo lectura</span> Título armado con transporte, ruta, cliente y folio de la solicitud.
`pricing_status` | string | <span class="ro">solo lectura</span> `solicitud_por_atender`, `en_proceso`, `enviada_a_revision`, `ajustes_solicitados` o `completada`. Cambia en la plataforma.
`line_items` | array&lt;object&gt; | <span class="new">nuevo</span> Líneas del precio.
`line_items[].id` | integer | <span class="ro">solo lectura</span> Id de la línea.
`line_items[].service_name` | string | Concepto de la línea.
`line_items[].description` | string | Descripción.
`line_items[].quantity` | integer | Cantidad de la línea.
`line_items[].item_id` | integer | Concepto del catálogo de la cuenta, o `null`. [`create_quote`](#generar-la-cotizacion-de-una-solicitud) lo necesita para volver la línea una partida.
`line_items[].suppliers` | array&lt;object&gt; | <span class="new">nuevo</span> Opciones de proveedor de la línea.
`suppliers[].id` | integer | <span class="ro">solo lectura</span> Id de la opción.
`suppliers[].supplier_id` | integer | Id del proveedor (un contacto de la cuenta).
`suppliers[].currency_id` | integer | Id de la moneda de esta opción.
`suppliers[].total_price` | decimal | <span class="ro">solo lectura</span> `quantity × unit_price`, redondeado a 2 decimales.
`suppliers[].transit_time` | string | Tiempo de tránsito en texto libre.
`suppliers[].quantity` | decimal | Cantidad. Por omisión 1.
`suppliers[].unit_price` | decimal | Precio unitario en la moneda de la opción.
`suppliers[].notes` | string | Notas.
`suppliers[].supplier_alias` | string | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Alias del proveedor.
`suppliers[].currency_code` | string | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Código ISO de la moneda (`USD`, `MXN`).

> Objeto precio

```json
{
  "id": 618,
  "service_name": "Importación 2x40HC Shanghai → Silao",
  "service_description": "Flete marítimo y despacho en Manzanillo",
  "unit_price": null,
  "total_price": "4200.0",
  "quantity": 1,
  "unit_type": null,
  "notes": null,
  "is_suggestion": false,
  "pricing_catalog_id": null,
  "created_at": "2026-11-10T12:30:00.000-06:00",
  "updated_at": "2026-11-10T12:30:00.000-06:00",
  "draft": false,
  "identification": "PRI-000221",
  "title": "MARÍTIMO · Shanghai, China → Manzanillo, Colima · Acme Logistics · SOL-000157",
  "pricing_status": "en_proceso",
  "line_items": [
    {
      "id": 1401,
      "service_name": "Flete marítimo",
      "description": "Shanghai → Manzanillo, 2x40HC",
      "quantity": 2,
      "item_id": 77,
      "suppliers": [
        {
          "id": 2207,
          "supplier_id": 815,
          "currency_id": 2,
          "total_price": "3700.0",
          "transit_time": "28 días",
          "quantity": "2.0",
          "unit_price": "1850.0",
          "notes": null,
          "supplier_alias": "NAVPAC",
          "currency_code": "USD"
        }
      ]
    },
    {
      "id": 1402,
      "service_name": "Despacho aduanal",
      "description": "Pedimento A1 en Manzanillo",
      "quantity": 1,
      "item_id": 77,
      "suppliers": [
        {
          "id": 2208,
          "supplier_id": 830,
          "currency_id": 1,
          "total_price": "9500.0",
          "transit_time": null,
          "quantity": "1.0",
          "unit_price": "9500.0",
          "notes": "Incluye previo",
          "supplier_alias": "AAPAC",
          "currency_code": "MXN"
        }
      ]
    }
  ]
}
```

## Listar los precios de una solicitud

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_requests/:quote_request_id/quote_request_pricings</code></div>

<p class="perm">Permiso: <code>quote_requests_read</code></p>

Devuelve todos los precios publicados de la solicitud (sin borradores), del más reciente al más antiguo, con sus líneas y proveedores. No tiene paginación ni filtros. Incluye el precio que abre la plataforma al pasar a `requested`, que nace sin líneas y en `solicitud_por_atender`. Funciona también con solicitudes archivadas.

> Petición

```shell
curl https://control.apunto.io/api/v1/quote_requests/457/quote_request_pricings \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "pricings": [
    {
      "id": 618,
      "service_name": "Importación 2x40HC Shanghai → Silao",
      "service_description": "Flete marítimo y despacho en Manzanillo",
      "unit_price": null,
      "total_price": "4200.0",
      "quantity": 1,
      "unit_type": null,
      "notes": null,
      "is_suggestion": false,
      "pricing_catalog_id": null,
      "created_at": "2026-11-10T12:30:00.000-06:00",
      "updated_at": "2026-11-10T12:30:00.000-06:00",
      "draft": false,
      "identification": "PRI-000221",
      "title": "MARÍTIMO · Shanghai, China → Manzanillo, Colima · Acme Logistics · SOL-000157",
      "pricing_status": "en_proceso",
      "line_items": [
        {
          "id": 1401,
          "service_name": "Flete marítimo",
          "description": "Shanghai → Manzanillo, 2x40HC",
          "quantity": 2,
          "item_id": 77,
          "suppliers": [
            {
              "id": 2207,
              "supplier_id": 815,
              "currency_id": 2,
              "total_price": "3700.0",
              "transit_time": "28 días",
              "quantity": "2.0",
              "unit_price": "1850.0",
              "notes": null,
              "supplier_alias": "NAVPAC",
              "currency_code": "USD"
            }
          ]
        }
      ]
    }
  ]
}
```

## Agregar un precio a una solicitud

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:quote_request_id/quote_request_pricings</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Agrega un precio con sus líneas y proveedores. Solo funciona cuando la solicitud está en `requested`. El usuario del token queda como responsable de pricing, así que el precio nace en `en_proceso`. No hay endpoint para editar ni borrar precios: eso se hace en la plataforma.

### Cuerpo de la petición

Todo va dentro de `quote_request_pricing`. Todos los campos del precio son opcionales.

Campo | Tipo | Descripción
--------- | ---- | -----------
`service_name` | string | <span class="opt">opcional</span> Nombre del precio.
`service_description` | string | <span class="opt">opcional</span> Descripción.
`unit_price` | decimal | <span class="opt">opcional</span> Precio unitario a nivel precio.
`total_price` | decimal | <span class="opt">opcional</span> Total a nivel precio. Lo suma `total_pricing_amount`; no se usa para las partidas de la cotización.
`quantity` | integer | <span class="opt">opcional</span> Cantidad. Por omisión 1.
`unit_type` | string | <span class="opt">opcional</span> Unidad.
`notes` | string | <span class="opt">opcional</span> Notas.
`is_suggestion` | boolean | <span class="opt">opcional</span> Marca que viene del tarifario.
`pricing_catalog_id` | integer | <span class="opt">opcional</span> Tarifario de origen. <span class="new">nuevo</span> Tiene que ser de la cuenta.
`quote_request_pricing_line_items_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Líneas (tabla abajo).

Cada línea:

Campo | Tipo | Descripción
--------- | ---- | -----------
`service_name` | string | <span class="req">obligatorio</span> Concepto. Una línea sin `service_name` ni `description` se descarta; con `description` pero sin `service_name`, responde 422.
`description` | string | <span class="opt">opcional</span> Descripción.
`item_id` | integer | <span class="opt">opcional</span> Concepto del catálogo de la cuenta (ver [Catálogos](#catalogos)). Mándalo si vas a generar la cotización con `create_quote`: una línea sin concepto no se vuelve partida.
`quantity` | integer | <span class="opt">opcional</span> Cantidad. Por omisión 1.
`quote_request_pricing_line_item_suppliers_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Opciones de proveedor (tabla abajo).

Cada proveedor de línea:

Campo | Tipo | Descripción
--------- | ---- | -----------
`supplier_code` | string | <span class="req">obligatorio</span> <span class="new">nuevo</span> Alias del proveedor en la cuenta. O `supplier_id`.
`supplier_id` | integer | Alternativa a `supplier_code`. Tiene que ser un contacto de la cuenta.
`currency_code` | string | <span class="req">obligatorio</span> <span class="new">nuevo</span> Código ISO de la moneda de esta opción (`USD`, `MXN`, `EUR`). O `currency_id`.
`currency_id` | integer | Alternativa a `currency_code`.
`unit_price` | decimal | <span class="req">obligatorio</span> Precio unitario, mayor o igual a 0. Si solo mandas `total_price`, se calcula como `total_price / quantity`.
`quantity` | decimal | <span class="opt">opcional</span> Mayor que 0. Por omisión 1.
`total_price` | decimal | <span class="opt">opcional</span> Se recalcula siempre como `quantity × unit_price`.
`transit_time` | string | <span class="opt">opcional</span> Tiempo de tránsito.
`notes` | string | <span class="opt">opcional</span> Notas.

Una opción de proveedor sin ningún dato se descarta. Si trae cualquier dato, proveedor, moneda y precio son obligatorios. No hay tipo de cambio en el precio: cada opción guarda su moneda.

### Respuesta

**201** con el precio en `pricing` (sin `message`), con la forma de [el objeto](#el-objeto-precio-de-solicitud). La solicitud recalcula `total_pricing_amount`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La solicitud no está en `requested` («Solo puedes agregar precios cuando la solicitud está en estatus solicitado.»).
`422` `validation_failed` | <span class="new">nuevo</span> `supplier_code` no existe en la cuenta o `supplier_id` es de otra cuenta («Contacto no encontrado con el código proporcionado»); `currency_code` no existe («Moneda no encontrada con el código proporcionado»); `item_id` no es de la cuenta («Concepto no encontrado: …»).
`422` `validation_failed` | Falta proveedor, moneda o precio en una opción, `quantity` no es mayor que 0, o una línea no tiene `service_name`.
`422` `validation_failed` | <span class="new">nuevo</span> `pricing_catalog_id` no es un tarifario de la cuenta.
`422` `archived_read_only` | La solicitud está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/quote_request_pricings \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote_request_pricing": {
      "service_name": "Importación 2x40HC Shanghai → Silao",
      "service_description": "Flete marítimo y despacho en Manzanillo",
      "total_price": 4200,
      "quote_request_pricing_line_items_attributes": [
        {
          "service_name": "Flete marítimo",
          "description": "Shanghai → Manzanillo, 2x40HC",
          "quantity": 2,
          "quote_request_pricing_line_item_suppliers_attributes": [
            { "supplier_code": "NAVPAC", "currency_code": "USD", "quantity": 2, "unit_price": 1850, "transit_time": "28 días" }
          ]
        },
        {
          "service_name": "Despacho aduanal",
          "description": "Pedimento A1 en Manzanillo",
          "quote_request_pricing_line_item_suppliers_attributes": [
            { "supplier_code": "AAPAC", "currency_code": "MXN", "unit_price": 9500, "notes": "Incluye previo" }
          ]
        }
      ]
    }
  }'
```

> Respuesta 201

```json
{
  "pricing": {
    "id": 618,
    "service_name": "Importación 2x40HC Shanghai → Silao",
    "service_description": "Flete marítimo y despacho en Manzanillo",
    "unit_price": null,
    "total_price": "4200.0",
    "quantity": 1,
    "unit_type": null,
    "notes": null,
    "is_suggestion": false,
    "pricing_catalog_id": null,
    "created_at": "2026-11-10T12:30:00.000-06:00",
    "updated_at": "2026-11-10T12:30:00.000-06:00",
    "draft": false,
    "identification": "PRI-000221",
    "title": "MARÍTIMO · Shanghai, China → Manzanillo, Colima · Acme Logistics · SOL-000157",
    "pricing_status": "en_proceso",
    "line_items": [
      {
        "id": 1401,
        "service_name": "Flete marítimo",
        "description": "Shanghai → Manzanillo, 2x40HC",
        "quantity": 2,
        "item_id": 77,
        "suppliers": [
          {
            "id": 2207,
            "supplier_id": 815,
            "currency_id": 2,
            "total_price": "3700.0",
            "transit_time": "28 días",
            "quantity": "2.0",
            "unit_price": "1850.0",
            "notes": null,
            "supplier_alias": "NAVPAC",
            "currency_code": "USD"
          }
        ]
      },
      {
        "id": 1402,
        "service_name": "Despacho aduanal",
        "description": "Pedimento A1 en Manzanillo",
        "quantity": 1,
        "item_id": 77,
        "suppliers": [
          {
            "id": 2208,
            "supplier_id": 830,
            "currency_id": 1,
            "total_price": "9500.0",
            "transit_time": null,
            "quantity": "1.0",
            "unit_price": "9500.0",
            "notes": "Incluye previo",
            "supplier_alias": "AAPAC",
            "currency_code": "MXN"
          }
        ]
      }
    ]
  }
}
```

> Error 422

```json
{
  "errors": ["Contacto no encontrado con el código proporcionado"],
  "error": "validation_failed",
  "message": "Contacto no encontrado con el código proporcionado",
  "request_id": "c2e8a4f1-5d97-4b3a-8e60-71f9d0b3a2c5"
}
```

## Sugerencias del tarifario para una solicitud

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/quote_requests/:quote_request_id/quote_request_pricings/suggestions</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Busca en los tarifarios de la cuenta hasta 12 tarifas que aplican al modo y la ruta de la solicitud: primero las vigentes y luego por confianza de la extracción. Sirve para armar un precio con `is_suggestion: true`. Solo lee: no crea precios.

Requiere que la cuenta tenga activo el módulo de tarifarios. Si no, responde **200** con `{ "suggestions": [], "meta": { "message": "Este feature no está habilitado para tu cuenta." } }`. <span class="new">nuevo</span> Si la búsqueda falla, responde **500** `internal_error` (ya no un 200 vacío).

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`supplier_id` | integer | <span class="opt">opcional</span> <span class="new">nuevo</span> Solo tarifas de ese proveedor: las que lo nombran y las que no nombran proveedor pero vienen de un archivo de tarifario asignado a él. Tiene que ser un contacto de la cuenta; si no, 422.
`advanced` | boolean | <span class="opt">opcional</span> Se acepta por compatibilidad, sin efecto.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`suggestions[].service_name` | string | Concepto de la tarifa.
`suggestions[].service_description` | string | Base de cobro y variante, o `null`.
`suggestions[].base_price` | decimal | Precio unitario de la tarifa, como número.
`suggestions[].total_price` | decimal | Igual a `base_price`.
`suggestions[].price_variants` | array&lt;object&gt; | `[{ "label", "amount" }]`.
`suggestions[].currency` | string | Código de moneda.
`suggestions[].supplier` | string | Nombre del proveedor de la tarifa.
`suggestions[].supplier_id` | integer | Proveedor en tus contactos, o `null`.
`suggestions[].transit_time` | string | Tiempo de tránsito.
`suggestions[].origin` | string | Origen según el tarifario.
`suggestions[].destination` | string | Destino según el tarifario.
`suggestions[].notes` | string | Notas.
`suggestions[].conditions` | string | Condiciones.
`suggestions[].confidence` | decimal | Confianza de la extracción, de 0 a 1.
`suggestions[].expired` | boolean | `true` si la vigencia ya pasó.
`suggestions[].ambiguous_route` | boolean | `true` si la ruta de la tarifa es ambigua.
`suggestions[].validity_status` | string | `declared`, `inferred` o `undetermined`.
`suggestions[].valid_until` | date | Vigencia, o `null`.
`suggestions[].rate_id` | integer | Id de la tarifa.
`suggestions[].source_id` | integer | Id del archivo de tarifario.
`suggestions[].source_document` | string | Nombre del archivo.
`suggestions[].source_ref` | string | Ubicación de la tarifa en el archivo.
`suggestions[].source_url` | string | Ruta relativa para descargar el archivo.
`meta` | object | `origin`, `destination` y `cargo_summary` de la solicitud; `message` si no hay tarifas («Los tarifarios no tienen tarifas que apliquen a esta ruta.»).

> Petición

```shell
curl https://control.apunto.io/api/v1/quote_requests/457/quote_request_pricings/suggestions \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "suggestions": [
    {
      "service_name": "Flete marítimo 40HC",
      "service_description": "Por contenedor",
      "base_price": 1850.0,
      "total_price": 1850.0,
      "price_variants": [{ "label": "Por contenedor", "amount": 1850.0 }],
      "currency": "USD",
      "supplier": "Naviera del Pacífico",
      "supplier_id": 815,
      "transit_time": "28",
      "origin": "Shanghai",
      "destination": "Manzanillo",
      "notes": null,
      "conditions": "Sujeto a disponibilidad de espacio",
      "confidence": 0.92,
      "expired": false,
      "ambiguous_route": false,
      "validity_status": "declared",
      "valid_until": "2026-12-31",
      "rate_id": 77310,
      "source_id": 412,
      "source_document": "tarifario-navpac-q4-2026.xlsx",
      "source_ref": "Hoja Asia, fila 18",
      "source_url": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NDEyfX0/tarifario-navpac-q4-2026.xlsx"
    }
  ],
  "meta": {
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "cargo_summary": "1xforty_ft_hc"
  }
}
```

## Generar la cotización de una solicitud

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/create_quote</code></div>

<p class="perm">Permiso: <code>quote_requests_create</code> (y poder editar la solicitud)</p>

Arma una [cotización](#cotizaciones) en borrador a partir de la solicitud, como lo hace la plataforma. No lleva cuerpo y no exige una etapa en particular. <span class="new">nuevo</span> Todo pasa en una sola transacción: si algo falla, no queda una cotización a medias ni la solicitud cambia de etapa.

Qué hace:

- Crea la cotización en `drafted` con el contacto, el vendedor, `operation_kind` y `operation_mode` de la solicitud, `cargo_details` como descripción y la moneda por omisión de la cuenta. El usuario del token queda como dueño. Si la solicitud lleva cuenta de gastos, también la copia.
- <span class="new">nuevo</span> Toma los precios publicados (no los borradores) y crea **una partida por cada línea de precio**, con su concepto (`item_id`), sus impuestos y la primera opción de proveedor, igual que la plataforma al armar una cotización desde un precio:
  - El costo del proveedor queda en la partida (proveedor, moneda, precio unitario y cantidad).
  - El precio de venta arranca en **0**, igual que en la plataforma, que lo deja en blanco para el vendedor. Fíjalo después con `PATCH /api/v1/quotes/:id` y `line_items_attributes` (ver [Actualizar una cotización](#actualizar-una-cotizacion)), usando los `id` de `line_items` del detalle.
  - El precio que abre la bandeja de pricing (sin líneas ni total) no agrega nada.
- Copia las líneas de carga a la cotización.
- Pasa la solicitud a `vobo` (y a la columna con ese estado destino, si existe) y guarda la cotización como ligada (`quote_ids`).

Cada llamada crea una cotización nueva, como en la plataforma. La solicitud queda ligada a la última: las anteriores salen de `quote_ids`.

### Respuesta

**201** con un resumen de la cotización en `quote` (`id`, `identification`, `status`, `archived`, `archived_at`, `contact_id`, `currency_id`, `created_at`, `updated_at`), la solicitud actualizada en `quote_request` y `message`. El detalle completo de la cotización está en [Obtener una cotización](#obtener-una-cotizacion).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La cotización no se pudo crear; por ejemplo, la solicitud no tiene contacto.
`422` `validation_failed` | <span class="new">nuevo</span> Una línea de precio no tiene concepto (`item_id`), o un precio con total no tiene líneas. El mensaje lista cuáles.
`422` `validation_failed` | <span class="new">nuevo</span> La cuenta no tiene configurada la numeración de cotizaciones.
`422` `archived_read_only` | La solicitud está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/create_quote \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 201

```json
{
  "quote": {
    "id": 905,
    "identification": "COT-000231",
    "status": "drafted",
    "archived": false,
    "archived_at": null,
    "contact_id": 812,
    "currency_id": 1,
    "created_at": "2026-11-10T16:00:00.000-06:00",
    "updated_at": "2026-11-10T16:00:00.000-06:00"
  },
  "quote_request": {
    "id": 457,
    "identification": "SOL-000157",
    "status": "vobo",
    "result": null,
    "archived": false,
    "archived_at": null,
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "transport_mode": "ocean",
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "deal_amount": "18500.0",
    "closing_date": "2026-11-30",
    "cargo_details": "2x40HC autopartes",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "assignee": null,
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
    "list": { "id": 613, "name": "VoBo" },
    "created_at": "2026-11-09T11:20:00.000-06:00",
    "updated_at": "2026-11-10T16:00:00.000-06:00",
    "movement_details": "Entrega en planta Silao, Gto.",
    "total_pricing_amount": "4200.0",
    "minutes_to_result": 0,
    "tags": ["autopartes"],
    "shipment_items": [
      {
        "id": 2051,
        "cargo_type": "container",
        "package_type": null,
        "pallet_type": null,
        "container_type": "forty_ft_hc",
        "quantity": 2,
        "length": null,
        "width": null,
        "height": null,
        "weight": "18000.0",
        "unit_length": "cm",
        "unit_weight": "kg",
        "container_number": null,
        "unit_type_id": null
      }
    ],
    "quote_request_pricings_count": 2,
    "quotes_count": 1,
    "activities_count": 6,
    "messages_count": 0,
    "to_dos_count": 2,
    "deal_currency": { "id": 2, "code": "USD" },
    "volumetric_factor_code": "ground_6000",
    "origin_port": null,
    "destination_port": null,
    "document_routes": [],
    "result_at": null,
    "result_notes": null,
    "quote_won_reason": null,
    "quote_lost_reason": null,
    "quote_ids": [905]
  },
  "message": "Cotización creada exitosamente desde la solicitud"
}
```

## Marcar una solicitud como ganada

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/mark_as_won</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Guarda el resultado `won`. Los parámetros van en la raíz del cuerpo, sin objeto `quote_request`. No cambia la etapa (`status`) ni la columna.

Además:

- Si la solicitud tiene una sola cotización ligada, esa cotización pasa a ganada. Si tiene varias, ganan las de `winner_quote_ids` y las demás pasan a perdidas (salvo canceladas, ya perdidas, ganadas o facturadas).
- Si está ligada a una oportunidad que no está ganada, la oportunidad pasa a `won`.
- Si la solicitud ya tenía resultado, se reemplaza.

### Cuerpo de la petición

Campo | Tipo | Descripción
--------- | ---- | -----------
`won_at` | date | <span class="opt">opcional</span> Fecha en que se ganó (`AAAA-MM-DD`). Por omisión, hoy. No puede ser anterior a la última actividad de la solicitud (alta, tareas o actividad). <span class="new">nuevo</span> Una fecha que no se puede leer responde 422.
`quote_won_reason_id` | integer | <span class="opt">opcional</span> Motivo vigente de la cuenta, de `GET /api/v1/quote_won_reasons` (ver [Catálogos](#catalogos)). <span class="new">nuevo</span> Un id que no existe, está archivado o es de otra cuenta responde 422.
`result_notes` | string | <span class="opt">opcional</span> Comentario.
`winner_quote_ids` | array&lt;integer&gt; | <span class="opt">opcional</span> Obligatorio cuando hay más de una cotización ligada: ids de las que aceptó el cliente, todos de `quote_ids`.

### Respuesta

**200** con el detalle en `quote_request` (`result` `won`, `minutes_to_result` calculado) y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | `won_at` es anterior a la última actividad («La fecha de ganado no puede ser anterior a la última actividad (…)»).
`422` `validation_failed` | Hay varias cotizaciones ligadas y falta `winner_quote_ids`, o trae ids que no son de la solicitud (ver `quote_ids` en el detalle).
`422` `validation_failed` | <span class="new">nuevo</span> `won_at` no es una fecha, o `quote_won_reason_id` no es un motivo vigente de la cuenta.
`422` `archived_read_only` | La solicitud está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/mark_as_won \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "won_at": "2026-11-11", "quote_won_reason_id": 8, "result_notes": "El cliente aceptó la tarifa de NAVPAC" }'
```

> Respuesta 200

```json
{
  "quote_request": {
    "id": 457,
    "identification": "SOL-000157",
    "status": "vobo",
    "result": "won",
    "archived": false,
    "archived_at": null,
    "origin": "Shanghai, China",
    "destination": "Manzanillo, Colima",
    "transport_mode": "ocean",
    "operation_kind": "importation",
    "operation_mode": "maritime",
    "service_scope": "port_cy_to_door",
    "incoterm": "FOB",
    "deal_amount": "18500.0",
    "closing_date": "2026-11-30",
    "cargo_details": "2x40HC autopartes",
    "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
    "owner": { "id": 12, "name": "Integración ERP", "email": "integracion@tuempresa.mx" },
    "assignee": null,
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "opportunity": { "id": 233, "identification": "OP-000045", "title": "Importación marítima mensual de autopartes" },
    "list": { "id": 613, "name": "VoBo" },
    "created_at": "2026-11-09T11:20:00.000-06:00",
    "updated_at": "2026-11-11T10:30:00.000-06:00",
    "movement_details": "Entrega en planta Silao, Gto.",
    "total_pricing_amount": "4200.0",
    "minutes_to_result": 1840,
    "tags": ["autopartes"],
    "shipment_items": [
      {
        "id": 2051,
        "cargo_type": "container",
        "package_type": null,
        "pallet_type": null,
        "container_type": "forty_ft_hc",
        "quantity": 2,
        "length": null,
        "width": null,
        "height": null,
        "weight": "18000.0",
        "unit_length": "cm",
        "unit_weight": "kg",
        "container_number": null,
        "unit_type_id": null
      }
    ],
    "quote_request_pricings_count": 2,
    "quotes_count": 1,
    "activities_count": 7,
    "messages_count": 0,
    "to_dos_count": 2,
    "deal_currency": { "id": 2, "code": "USD" },
    "volumetric_factor_code": "ground_6000",
    "origin_port": null,
    "destination_port": null,
    "document_routes": [],
    "result_at": "2026-11-10T18:00:00.000-06:00",
    "result_notes": "El cliente aceptó la tarifa de NAVPAC",
    "quote_won_reason": { "id": 8, "name": "Mejor precio" },
    "quote_lost_reason": null,
    "quote_ids": [905]
  },
  "message": "Solicitud marcada como ganada"
}
```

## Marcar una solicitud como perdida

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/mark_as_lost</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Guarda el resultado `lost`. Los parámetros van en la raíz del cuerpo. No cambia la etapa ni la columna, ni la oportunidad. Si la solicitud ya tenía resultado, se reemplaza.

Las cotizaciones ligadas que todavía pueden perderse (no canceladas, perdidas, ganadas ni facturadas) pasan a perdidas; las que ya generaron un folio operativo pasan a ganadas. Si hay cotizaciones que van a cambiar, tienes que confirmarlo con `confirm_quote_loss_consequences`.

### Cuerpo de la petición

Campo | Tipo | Descripción
--------- | ---- | -----------
`lost_at` | date | <span class="opt">opcional</span> Fecha en que se perdió (`AAAA-MM-DD`). Por omisión, hoy. <span class="new">nuevo</span> Una fecha que no se puede leer responde 422.
`quote_lost_reason_id` | integer | <span class="opt">opcional</span> Motivo vigente de la cuenta, de `GET /api/v1/quote_lost_reasons` (ver [Catálogos](#catalogos)). <span class="new">nuevo</span> Un id que no existe, está archivado o es de otra cuenta responde 422.
`result_notes` | string | <span class="opt">opcional</span> Comentario.
`confirm_quote_loss_consequences` | boolean | <span class="opt">opcional</span> `true` (o `"1"`) para aceptar el cambio de las cotizaciones ligadas. Obligatorio si hay alguna que va a cambiar.

### Respuesta

**200** con el detalle en `quote_request` (`result` `lost`) y `message` («Solicitud marcada como perdida»).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Hay cotizaciones ligadas que van a cambiar y no mandaste `confirm_quote_loss_consequences` («Debe confirmar las consecuencias sobre las cotizaciones vinculadas»).
`422` `validation_failed` | <span class="new">nuevo</span> `quote_lost_reason_id` no es un motivo vigente de la cuenta, o `lost_at` no es una fecha.
`422` `archived_read_only` | La solicitud está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/mark_as_lost \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "lost_at": "2026-11-11", "quote_lost_reason_id": 14, "result_notes": "Se fue con otra tarifa", "confirm_quote_loss_consequences": true }'
```

> Error 422

```json
{
  "errors": ["Debe confirmar las consecuencias sobre las cotizaciones vinculadas"],
  "message": "No se pudo marcar la solicitud como perdida",
  "error": "validation_failed",
  "request_id": "71d3b9e0-4a2c-4f85-b1e7-c08a6d5f3e29"
}
```

## Reabrir una solicitud comercial

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/reopen</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Quita el resultado: `result` vuelve a `null` y se borran la fecha, el motivo, las notas y `minutes_to_result`. No lleva cuerpo. No cambia la etapa, las cotizaciones ligadas ni la oportunidad. Si la solicitud no tenía resultado, también responde 200.

<span class="new">nuevo</span> Si alguna cotización de la solicitud ya generó un [folio operativo](#folios-operativos), la solicitud no se reabre: el resultado se queda y responde **422**.

### Respuesta

**200** con el detalle en `quote_request` y `message` («Solicitud reabierta exitosamente»).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | <span class="new">nuevo</span> Una cotización de la solicitud ya generó un folio operativo. El mensaje es «No se puede reabrir: una cotización de esta solicitud ya generó un folio operativo.».
`422` `archived_read_only` | La solicitud está archivada.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/reopen \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "errors": ["No se puede reabrir: una cotización de esta solicitud ya generó un folio operativo."],
  "message": "No se puede reabrir: una cotización de esta solicitud ya generó un folio operativo.",
  "error": "validation_failed",
  "request_id": "3e6f0a2d-9c48-4b17-8d53-a1f7e2c9b046"
}
```

## Archivar y restaurar una solicitud comercial

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/quote_requests/:id/restore</code></div>

<p class="perm">Permiso: <code>quote_requests_edit</code></p>

Archivar saca la solicitud de los listados sin borrarla; restaurar la regresa con la misma etapa y el mismo resultado. Responden la decisión del ciclo de vida. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

Archivar depende del resultado:

- **Ganada o perdida**: se archiva sin pedir nada (`allow`).
- **Abierta**: la primera llamada responde `confirm` con `code` `will_mark_lost`. Repite con `confirmed=true`, `lost_at` y `quote_lost_reason_id` (y si quieres `result_notes`): la solicitud queda perdida, las cotizaciones ligadas que todavía pueden perderse pasan a perdidas, y se archiva. Si confirmas sin fecha o sin motivo, responde `reject` con `code` `lost_reason_required` y no escribe nada.
- **Ya archivada**: `reject` con `code` `already_archived`.

Las cotizaciones ligadas no se archivan. Restaurar responde `allow`, o `reject` con `not_archived`.

### Parámetros

Van en la raíz del cuerpo, sin objeto `quote_request`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`confirmed` | boolean | <span class="opt">opcional</span> `true` para confirmar el archivado de una solicitud abierta.
`lost_at` | date | <span class="opt">opcional</span> Obligatorio al confirmar una solicitud abierta. <span class="new">nuevo</span> Una fecha que no se puede leer responde 422 `validation_failed`.
`quote_lost_reason_id` | integer | <span class="opt">opcional</span> Obligatorio al confirmar una solicitud abierta. Un id que no es un motivo vigente de la cuenta responde 422 `validation_failed`.
`result_notes` | string | <span class="opt">opcional</span> Comentario de la pérdida.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/458/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "confirm",
  "code": "will_mark_lost",
  "title": "¿Archivar esta solicitud?",
  "message": "La solicitud quedará perdida y saldrá de tu trabajo diario. Las cotizaciones que todavía pueden perderse también quedarán perdidas.",
  "suggested_action": null,
  "errors": ["La solicitud quedará perdida y saldrá de tu trabajo diario. Las cotizaciones que todavía pueden perderse también quedarán perdidas."],
  "error": "will_mark_lost",
  "request_id": "b84d2f17-6e0a-4c93-9f25-e3a1c7d0b568"
}
```

> Petición con confirmación

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/458/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "confirmed": true, "lost_at": "2026-11-11", "quote_lost_reason_id": 14, "result_notes": "El cliente pospuso el embarque" }'
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

## Eliminar una solicitud comercial

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/quote_requests/:id</code></div>

<p class="perm">Permiso: <code>quote_requests_delete</code></p>

Las solicitudes comerciales **no se eliminan**. Este endpoint siempre responde **422** con `outcome` `reject`, `code` `delete_not_allowed` y `suggested_action` `archive`, y no cambia nada. Usa [Archivar y restaurar una solicitud comercial](#archivar-y-restaurar-una-solicitud-comercial).

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/quote_requests/457 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "delete_not_allowed",
  "title": "No puedes eliminar esta solicitud",
  "message": "Esta solicitud no se elimina. Archívala: dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados, donde puedes restaurarla.",
  "suggested_action": "archive",
  "errors": ["Esta solicitud no se elimina. Archívala: dejará de aparecer en tus listas, en la búsqueda y en las opciones al capturar. La encuentras en Configuración › Archivados, donde puedes restaurarla."],
  "error": "delete_not_allowed",
  "request_id": "f05c8e3b-2d71-4a96-b4e8-6c9a1f2d7e03"
}
```
