# Folios operativos

<p class="lead">Un folio operativo (<code>operation</code>) es el expediente de un embarque: cliente, tipo de operación, modo de transporte, moneda y el resumen financiero de sus servicios. Tu integración lo abre, le agrega servicios y lee sus totales para conciliar o facturar.</p>

- Para abrir un folio necesitas cliente, moneda, tipo (`kind`) y modo (`mode`). Usa `contact_code` (alias del cliente) y `currency_code` en lugar de ids.
- `identification` lo genera la plataforma con la secuencia de folios de la cuenta. Mientras el folio está en `confirmed`, cambiar `kind`, `mode` o el cliente regenera `identification` con el mismo número. En otro estado el cambio se guarda pero `identification` no cambia.
- Los totales (`income_amount`, `expense_amount`, `profit_amount`, `profit_percentage`) los calcula la plataforma desde el [centro de costos](#centro-de-costos) de los servicios no cancelados, en la moneda del folio. Si los mandas, la respuesta es **422** `read_only_fields`.
- Los importes y la utilidad solo los ve quien tiene el permiso `operations_profit_read`, igual que en la plataforma. Sin él, esos campos vienen en `null` (la llave sigue en la respuesta), también en las líneas de centro de costos que trae el folio.
- `status` cambia solo con sus acciones (`close`, `reopen`, `cancel`). En el alta puedes elegir `confirmed` o `active`. En un cambio, mandarlo responde **422** `read_only_fields`.
- La moneda del folio se bloquea en cuanto tiene líneas de centro de costos en servicios no cancelados, o líneas ligadas a facturas o facturas de proveedor.
- Los servicios, comentarios, tareas y carpetas cuelgan del folio. Ver [Servicios](#servicios), [Comentarios](#comentarios), [Tareas](#tareas) y [Documentos y archivos](#documentos-y-archivos).

Valor de `kind` | Significado
--------------- | -----------
`importation` | Importación
`exportation` | Exportación
`domestic` | Doméstico
`crosstrade` | Crosstrade
`transportation` | Transporte
`consulting` | Consultoría
`export_trading_company` | Comercializadora de exportación
`import_trading_company` | Comercializadora de importación

Valor de `mode` | Significado
--------------- | -----------
`land` | Terrestre
`aerial` | Aéreo
`maritime` | Marítimo

## Estados de un folio operativo

Estado | Significado | Cómo llega a este estado
------ | ----------- | ------------------------
`confirmed` | Confirmado. Recién abierto, sin servicios | Estado inicial del alta (por omisión)
`active` | Activo. En operación | Al crear su primer servicio (si estaba `confirmed`), al darlo de alta con `"status": "active"` o con [reabrir](#reabrir-un-folio-operativo)
`finished` | Finalizado | Es un valor válido de `status`, pero ninguna acción de la API lleva un folio a este estado
`closed` | Cerrado | Con [cerrar](#cerrar-un-folio-operativo)
`canceled` | Cancelado | Con [cancelar](#cancelar-un-folio-operativo)

Acción | Se permite cuando | Resultado
------ | ----------------- | ---------
`close` | Ningún servicio del folio está `active` ni `finished` | `closed`
`reopen` | El folio está `finished` o `closed` | `active`
`cancel` | El folio está `confirmed` o `active` y todos sus servicios están `canceled` | `canceled`
`archive` | El folio está `finished`, `closed` o `canceled` | `status` no cambia; `archived: true`
`restore` | El folio está archivado | `status` no cambia; `archived: false`
`DELETE` | El folio está `confirmed`, sin servicios y sin cotizaciones | Se elimina (borrado lógico)

Un folio archivado es de solo lectura: `PATCH`, `close`, `reopen`, `cancel`, `generate_invoice` y `generate_bill` responden **422** `archived_read_only` hasta que lo restaures. Lo mismo pasa al escribir en sus servicios, líneas de centro de costos, comentarios, tareas y carpetas. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

## El objeto folio operativo

El listado devuelve los campos de la primera parte de la tabla. El detalle, el alta y el cambio agregan los campos marcados «solo detalle».

Campo | Tipo | Descripción
----- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Identificador del folio
`identification` | string | <span class="ro">solo lectura</span> Folio legible (`IMP-ACME-000184`), generado con la secuencia de la cuenta
`kind` | string | Tipo de operación. Ver los valores arriba
`mode` | string | Modo de transporte: `land`, `aerial` o `maritime`
`status` | string | <span class="ro">solo lectura</span> `confirmed`, `active`, `finished`, `closed` o `canceled`. Cambia con sus acciones
`archived` | boolean | <span class="ro">solo lectura</span> `true` si el folio está archivado
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`
`client_ref` | string | Referencia del cliente (orden de compra, pedido)
`contact` | object | Cliente del folio: `alias` y `name`. Se escribe con `contact_code` o `contact_id`
`currency` | object | Moneda del folio: `code` (ISO, p. ej. `USD`) y `name`. Se escribe con `currency_code` o `currency_id`
`operational_agent` | object | Agente operativo: `email` y `name`, o `null`. Se escribe con `operational_agent_email` o `operational_agent_id`
`profit_amount` | decimal | <span class="ro">solo lectura</span> Utilidad: ingresos menos gastos, en la moneda del folio. `null` sin `operations_profit_read`
`profit_percentage` | decimal | <span class="ro">solo lectura</span> Utilidad entre ingresos × 100. `null` hasta que el folio tiene su primer cálculo, o sin `operations_profit_read`
`economic_month` | date | Mes económico, siempre el primer día del mes (`2026-11-01`)
`services_count` | integer | <span class="ro">solo lectura</span> Servicios del folio, incluidos cancelados y archivados
`comments_count` | integer | <span class="ro">solo lectura</span> Comentarios del folio
`tasks_count` | integer | <span class="ro">solo lectura</span> Tareas del folio
`folders_count` | integer | <span class="ro">solo lectura</span> Carpetas del folio
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span> Alta y último cambio
`goods_description` | string | Solo detalle. Descripción de la mercancía
`incoterm` | string | Solo detalle. Incoterm, p. ej. `EXW`, `FCA`, `FOB`, `CIF`, `DAP`, `DDP`. Texto libre
`service_scope` | string | Solo detalle. Alcance del servicio (origen → destino). Valores abajo
`quote_external_id` | string | Solo detalle. Id de la cotización en tu sistema
`nomenclature` | string | Solo detalle. Nomenclatura (texto libre)
`regime` | string | Solo detalle. Régimen (texto libre)
`income_amount` | decimal | <span class="ro">solo lectura</span> Solo detalle. Ingresos: suma de las ventas de sus servicios no cancelados, convertidas a la moneda del folio. `null` sin `operations_profit_read`
`expense_amount` | decimal | <span class="ro">solo lectura</span> Solo detalle. Gastos: suma de las compras de sus servicios no cancelados, convertidas a la moneda del folio. `null` sin `operations_profit_read`
`tags` | array&lt;string&gt; | Solo detalle. Etiquetas. Se escriben con `tag_list`
`to_dos` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Hasta 100 tareas, de la más reciente a la más antigua: `id`, `title`, `completed`, `rejected`, `required`, `start_at`, `end_at`, `owner` (`email`, `name`), `completed_at`, `completed_by` (`email`, `name`), `created_at`, `updated_at`. Ver [Tareas](#tareas)
`folders` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Árbol de carpetas: `id`, `name`, `parent_id`, `files_count`, `attachments` (`id`, `blob_id`, `filename`, `byte_size`, `content_type`, `created_at`, `url`) y `children` con la misma forma. Ver [Documentos y archivos](#documentos-y-archivos)
`services` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Todos los servicios del folio, incluidos cancelados y archivados. Campos en la tabla siguiente

Cada elemento de `services` trae un resumen del servicio. El objeto completo está en [Servicios](#servicios).

Campo | Tipo | Descripción
----- | ---- | -----------
`services[].id` | integer | Id del servicio
`services[].identification` | string | Folio del servicio
`services[].mode` | string | `land`, `aerial`, `maritime` o `customs`
`services[].status` | string | `active`, `finished`, `closed` o `canceled`
`services[].shipment_type` | string | Tipo de embarque (`fcl`, `ltl`, …)
`services[].shipment_kind` | string | `national` o `international`
`services[].supplier` | object | Proveedor del servicio: `alias` y `name`, o `null`
`services[].eta_date`, `services[].etd_date` | datetime | Llegada y salida estimadas
`services[].bl`, `services[].booking` | string | BL y booking
`services[].economic_month` | date | Mes económico del servicio
`services[].cost_centers` | array&lt;object&gt; | Líneas de centro de costos del servicio, de la más reciente a la más antigua. Mismo formato que el [detalle de una línea](#el-objeto-linea-de-centro-de-costos), sin `service`

`service_scope` acepta: `door_to_port_cy`, `door_to_port_cfs`, `port_cy_to_port_cy`, `port_cfs_to_port_cfs`, `port_cy_to_door`, `port_cfs_to_door`, `door_to_door`, `door_to_airport`, `airport_to_airport`, `airport_to_door`, `door_to_rail_ramp`, `rail_ramp_to_rail_ramp`, `rail_ramp_to_door`, `door_to_truck_terminal`, `truck_terminal_to_truck_terminal`, `truck_terminal_to_door`, `port_cy_to_airport`, `port_cfs_to_airport`, `airport_to_port_cy`, `airport_to_port_cfs`, `port_cy_to_rail_ramp`, `port_cfs_to_rail_ramp`, `rail_ramp_to_port_cy`, `rail_ramp_to_port_cfs`, `rail_ramp_to_airport` y `airport_to_rail_ramp`.

> Objeto folio operativo

```json
{
  "id": 1042,
  "identification": "IMP-ACME-000184",
  "kind": "importation",
  "mode": "maritime",
  "status": "active",
  "archived": false,
  "archived_at": null,
  "client_ref": "PO-7781",
  "contact": { "alias": "ACME", "name": "Acme Logistics" },
  "currency": { "code": "USD", "name": "Dólar estadounidense" },
  "operational_agent": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
  "profit_amount": "1000.0",
  "profit_percentage": "25.0",
  "economic_month": "2026-11-01",
  "services_count": 1,
  "comments_count": 2,
  "tasks_count": 1,
  "folders_count": 1,
  "created_at": "2026-11-03T10:15:22.000-06:00",
  "updated_at": "2026-11-10T17:42:05.000-06:00",
  "goods_description": "2x40HC autopartes",
  "incoterm": "FOB",
  "service_scope": "port_cy_to_door",
  "quote_external_id": "COT-2026-0412",
  "nomenclature": null,
  "regime": null,
  "income_amount": "4000.0",
  "expense_amount": "3000.0",
  "tags": ["Cliente clave"],
  "to_dos": [
    {
      "id": 9310,
      "title": "Solicitar BL original",
      "completed": false,
      "rejected": false,
      "required": true,
      "start_at": "2026-11-04T09:00:00.000-06:00",
      "end_at": "2026-11-12T18:00:00.000-06:00",
      "owner": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
      "completed_at": null,
      "completed_by": null,
      "created_at": "2026-11-03T10:30:00.000-06:00",
      "updated_at": "2026-11-03T10:30:00.000-06:00"
    }
  ],
  "folders": [
    {
      "id": 7720,
      "name": "Documentos del cliente",
      "parent_id": null,
      "files_count": 1,
      "attachments": [
        {
          "id": 50411,
          "blob_id": 60872,
          "filename": "factura-comercial-7781.pdf",
          "byte_size": 184233,
          "content_type": "application/pdf",
          "created_at": "2026-11-05T12:01:44.000-06:00",
          "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjA4NzJ9fQ/factura-comercial-7781.pdf"
        }
      ],
      "children": []
    }
  ],
  "services": [
    {
      "id": 2210,
      "identification": "SRV-000731",
      "mode": "maritime",
      "status": "active",
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "supplier": { "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "eta_date": "2026-11-28T00:00:00.000-06:00",
      "etd_date": "2026-11-06T00:00:00.000-06:00",
      "bl": "MAEU123456789",
      "booking": "BKG-55120",
      "economic_month": "2026-11-01",
      "cost_centers": [
        {
          "id": 5501,
          "concept": "Flete marítimo Shanghai - Manzanillo",
          "quantity": "2.0",
          "income_amount": "4000.0",
          "expense_amount": "3000.0",
          "profit_amount": "1000.0",
          "profit_percentage": "25.0",
          "currency": { "code": "USD", "name": "Dólar estadounidense" },
          "exchange_rate": "1.0",
          "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
          "expense_exchange_rate": "1.0",
          "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
          "item": { "id": 44, "name": "Flete marítimo internacional" },
          "created_at": "2026-11-03T11:02:10.000-06:00",
          "updated_at": "2026-11-03T11:02:10.000-06:00",
          "notes": "Tarifa spot noviembre",
          "linked": {
            "quote_line_item_id": null,
            "invoice_line_item_id": null,
            "bill_line_item_id": null
          }
        }
      ]
    }
  ]
}
```

## Listar folios operativos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations</code></div>

<p class="perm">Permiso: <code>operations_read</code></p>

Devuelve los folios de la cuenta que el usuario puede ver, del más reciente al más antiguo (`created_at`). Con `updated_since` el orden es `updated_at`, `id`. Sin `operations_read` la lista sale vacía. Cada elemento trae los campos del listado, sin los «solo detalle».

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Uno o varios estados separados por coma (`active,confirmed`)
`kind` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Uno o varios tipos separados por coma
`mode` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Uno o varios modos separados por coma
`contact_code` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Alias del cliente. Si no existe, la lista sale vacía
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo archivados. Sin él, solo no archivados
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion)
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen `identification`

Un valor de `status`, `kind` o `mode` fuera de su lista responde **422** `validation_failed` con los valores permitidos en `errors`. `pagination.total` cuenta los folios después de filtrar.

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations?status=active,confirmed&contact_code=ACME&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "operations": [
    {
      "id": 1042,
      "identification": "IMP-ACME-000184",
      "kind": "importation",
      "mode": "maritime",
      "status": "active",
      "archived": false,
      "archived_at": null,
      "client_ref": "PO-7781",
      "contact": { "alias": "ACME", "name": "Acme Logistics" },
      "currency": { "code": "USD", "name": "Dólar estadounidense" },
      "operational_agent": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
      "profit_amount": "1000.0",
      "profit_percentage": "25.0",
      "economic_month": "2026-11-01",
      "services_count": 1,
      "comments_count": 2,
      "tasks_count": 1,
      "folders_count": 1,
      "created_at": "2026-11-03T10:15:22.000-06:00",
      "updated_at": "2026-11-10T17:42:05.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Buscar folios operativos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/search</code></div>

<p class="perm">Permiso: <code>operations_read</code></p>

Búsqueda rápida para un selector. Busca `q` (sin distinguir mayúsculas) dentro de `identification`, `client_ref`, `goods_description` y el número del folio. Devuelve hasta **20** folios, del último modificado al más antiguo, sin paginación. Incluye folios archivados. Sin `q` devuelve los 20 últimos modificados.

Cada resultado trae `id`, `identification`, `number` (número consecutivo del folio), `client_ref`, `kind`, `mode`, `status`, `goods_description`, `contact_name` (alias del cliente, o su nombre si no tiene alias), `updated_at` y hasta 10 `services` con `id`, `identification`, `mode` y `status`.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`q` | string | <span class="opt">opcional</span> Texto a buscar

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations/search?q=PO-7781" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "operations": [
    {
      "id": 1042,
      "identification": "IMP-ACME-000184",
      "number": 184,
      "client_ref": "PO-7781",
      "kind": "importation",
      "mode": "maritime",
      "status": "active",
      "goods_description": "2x40HC autopartes",
      "contact_name": "ACME",
      "updated_at": "2026-11-10T17:42:05.000-06:00",
      "services": [
        { "id": 2210, "identification": "SRV-000731", "mode": "maritime", "status": "active" }
      ]
    }
  ]
}
```

## Obtener un folio operativo

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:id</code></div>

<p class="perm">Permiso: <code>operations_read</code></p>

Devuelve el folio con todos sus campos, sus servicios y las líneas de centro de costos de cada servicio. Responde **404** si el folio no existe, es de otra cuenta o el usuario no lo puede ver.

> Petición

```shell
curl https://control.apunto.io/api/v1/operations/1042 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "operation": {
    "id": 1042,
    "identification": "IMP-ACME-000184",
    "kind": "importation",
    "mode": "maritime",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "client_ref": "PO-7781",
    "contact": { "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "code": "USD", "name": "Dólar estadounidense" },
    "operational_agent": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
    "profit_amount": "1000.0",
    "profit_percentage": "25.0",
    "economic_month": "2026-11-01",
    "services_count": 1,
    "comments_count": 2,
    "tasks_count": 1,
    "folders_count": 1,
    "created_at": "2026-11-03T10:15:22.000-06:00",
    "updated_at": "2026-11-10T17:42:05.000-06:00",
    "goods_description": "2x40HC autopartes",
    "incoterm": "FOB",
    "service_scope": "port_cy_to_door",
    "quote_external_id": "COT-2026-0412",
    "nomenclature": null,
    "regime": null,
    "income_amount": "4000.0",
    "expense_amount": "3000.0",
    "tags": ["Cliente clave"],
    "to_dos": [
      {
        "id": 9310,
        "title": "Solicitar BL original",
        "completed": false,
        "rejected": false,
        "required": true,
        "start_at": "2026-11-04T09:00:00.000-06:00",
        "end_at": "2026-11-12T18:00:00.000-06:00",
        "owner": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
        "completed_at": null,
        "completed_by": null,
        "created_at": "2026-11-03T10:30:00.000-06:00",
        "updated_at": "2026-11-03T10:30:00.000-06:00"
      }
    ],
    "folders": [
      {
        "id": 7720,
        "name": "Documentos del cliente",
        "parent_id": null,
        "files_count": 1,
        "attachments": [
          {
            "id": 50411,
            "blob_id": 60872,
            "filename": "factura-comercial-7781.pdf",
            "byte_size": 184233,
            "content_type": "application/pdf",
            "created_at": "2026-11-05T12:01:44.000-06:00",
            "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjA4NzJ9fQ/factura-comercial-7781.pdf"
          }
        ],
        "children": []
      }
    ],
    "services": [
      {
        "id": 2210,
        "identification": "SRV-000731",
        "mode": "maritime",
        "status": "active",
        "shipment_type": "fcl",
        "shipment_kind": "international",
        "supplier": { "alias": "NAVPAC", "name": "Naviera del Pacífico" },
        "eta_date": "2026-11-28T00:00:00.000-06:00",
        "etd_date": "2026-11-06T00:00:00.000-06:00",
        "bl": "MAEU123456789",
        "booking": "BKG-55120",
        "economic_month": "2026-11-01",
        "cost_centers": [
          {
            "id": 5501,
            "concept": "Flete marítimo Shanghai - Manzanillo",
            "quantity": "2.0",
            "income_amount": "4000.0",
            "expense_amount": "3000.0",
            "profit_amount": "1000.0",
            "profit_percentage": "25.0",
            "currency": { "code": "USD", "name": "Dólar estadounidense" },
            "exchange_rate": "1.0",
            "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
            "expense_exchange_rate": "1.0",
            "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
            "item": { "id": 44, "name": "Flete marítimo internacional" },
            "created_at": "2026-11-03T11:02:10.000-06:00",
            "updated_at": "2026-11-03T11:02:10.000-06:00",
            "notes": "Tarifa spot noviembre",
            "linked": {
              "quote_line_item_id": null,
              "invoice_line_item_id": null,
              "bill_line_item_id": null
            }
          }
        ]
      }
    ]
  }
}
```

## Crear un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations</code></div>

<p class="perm">Permiso: <code>operations_create</code></p>

Abre un folio. El usuario del token queda como creador. `identification` se genera al guardar.

### Cuerpo de la petición

Todo va dentro de `operation`. Para cada referencia manda el código o el id, no los dos.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`contact_code` | string | <span class="req">obligatorio</span> Alias del cliente. Alternativa: `contact_id` (debe ser de la cuenta). Ver [Contactos](#contactos)
`currency_code` | string | <span class="req">obligatorio</span> Moneda del folio en ISO 4217 (`MXN`, `USD`, `EUR`). Alternativa: `currency_id`
`kind` | string | <span class="req">obligatorio</span> Tipo de operación. Ver los valores al inicio
`mode` | string | <span class="req">obligatorio</span> `land`, `aerial` o `maritime`
`status` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Estado inicial: `confirmed` (por omisión) o `active`. Cualquier otro valor responde 422
`client_ref` | string | <span class="opt">opcional</span> Referencia del cliente
`goods_description` | string | <span class="opt">opcional</span> Descripción de la mercancía
`incoterm` | string | <span class="opt">opcional</span> Incoterm (`FOB`, `CIF`, …)
`service_scope` | string | <span class="opt">opcional</span> Alcance del servicio. Un valor fuera de la lista de arriba responde 422 con los permitidos
`economic_month` | date | <span class="opt">opcional</span> Cualquier fecha del mes (`2026-11-15`); se guarda el primer día. Por omisión, el mes en curso
`operational_agent_email` | string | <span class="opt">opcional</span> Correo del agente operativo; debe ser usuario de la cuenta. Alternativa: `operational_agent_id`
`quote_external_id` | string | <span class="opt">opcional</span> Id de la cotización en tu sistema
`nomenclature` | string | <span class="opt">opcional</span> Nomenclatura
`regime` | string | <span class="opt">opcional</span> Régimen
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta

`income_amount`, `expense_amount`, `profit_amount` y `profit_percentage` no se aceptan: responden **422** `read_only_fields`. Los demás campos de solo lectura (`identification`, `archived`, …) se ignoran.

### Respuesta

**201** con `{ "operation": {...}, "message": "Operación creada exitosamente" }`. El folio viene completo, como en [Obtener un folio operativo](#obtener-un-folio-operativo).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | `contact_code`, `currency_code` u `operational_agent_email` no existen en la cuenta
`422` `validation_failed` | `kind`, `mode`, `service_scope` o `status` fuera de su lista (los valores permitidos vienen en `errors`), o `economic_month` no es una fecha
`422` `validation_failed` | Falta cliente, moneda, `kind` o `mode`, o `contact_id` es de otra cuenta
`422` `validation_failed` | `operational_agent_id` no es usuario de la cuenta, o una etiqueta de `tag_list` no está en el catálogo
`422` `read_only_fields` | Mandaste un total calculado

Lo genérico está en [Errores](#errores).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "contact_code": "ACME",
      "currency_code": "USD",
      "kind": "importation",
      "mode": "maritime",
      "client_ref": "PO-7781",
      "goods_description": "2x40HC autopartes",
      "incoterm": "FOB",
      "service_scope": "port_cy_to_door",
      "operational_agent_email": "laura@tuempresa.mx",
      "quote_external_id": "COT-2026-0412"
    }
  }'
```

```javascript
const { status, body } = await api("/operations", {
  method: "POST",
  body: JSON.stringify({
    operation: {
      contact_code: "ACME",
      currency_code: "USD",
      kind: "importation",
      mode: "maritime",
      client_ref: "PO-7781",
      goods_description: "2x40HC autopartes",
      incoterm: "FOB",
      service_scope: "port_cy_to_door",
      operational_agent_email: "laura@tuempresa.mx",
      quote_external_id: "COT-2026-0412",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/operations", json={
    "operation": {
        "contact_code": "ACME",
        "currency_code": "USD",
        "kind": "importation",
        "mode": "maritime",
        "client_ref": "PO-7781",
        "goods_description": "2x40HC autopartes",
        "incoterm": "FOB",
        "service_scope": "port_cy_to_door",
        "operational_agent_email": "laura@tuempresa.mx",
        "quote_external_id": "COT-2026-0412",
    }
})
print(res.status_code, res.json())
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
    "archived": false,
    "archived_at": null,
    "client_ref": "PO-7781",
    "contact": { "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "code": "USD", "name": "Dólar estadounidense" },
    "operational_agent": { "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
    "profit_amount": "0.0",
    "profit_percentage": null,
    "economic_month": "2026-11-01",
    "services_count": 0,
    "comments_count": 0,
    "tasks_count": 0,
    "folders_count": 0,
    "created_at": "2026-11-03T10:15:22.000-06:00",
    "updated_at": "2026-11-03T10:15:22.000-06:00",
    "goods_description": "2x40HC autopartes",
    "incoterm": "FOB",
    "service_scope": "port_cy_to_door",
    "quote_external_id": "COT-2026-0412",
    "nomenclature": null,
    "regime": null,
    "income_amount": "0.0",
    "expense_amount": "0.0",
    "tags": [],
    "to_dos": [],
    "folders": [],
    "services": []
  },
  "message": "Operación creada exitosamente"
}
```

## Actualizar un folio operativo

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/operations/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code></p>

Cambio parcial: manda dentro de `operation` solo los campos que cambian; los omitidos no cambian. Acepta los mismos campos que el alta, salvo `status`. `PUT` funciona igual.

- `status` responde **422** `read_only_fields`: usa [cerrar](#cerrar-un-folio-operativo), [reabrir](#reabrir-un-folio-operativo) o [cancelar](#cancelar-un-folio-operativo).
- Los totales calculados responden **422** `read_only_fields`.
- La moneda (`currency_code` / `currency_id`) no cambia si el folio ya tiene líneas de centro de costos en servicios no cancelados, o líneas ligadas a facturas o facturas de proveedor: **422** `validation_failed`.
- Cambiar `economic_month` cambia también el mes económico de todos los servicios del folio.
- `tag_list` reemplaza las etiquetas del folio. Las que el folio ya tiene se aceptan aunque se hayan archivado en el catálogo.
- En un folio archivado responde **422** `archived_read_only`.

### Respuesta

**200** con `{ "operation": {...}, "message": "Operación actualizada exitosamente" }`.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/operations/1042 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "operation": { "client_ref": "PO-7781-B", "incoterm": "CIF" } }'
```

> Error 422

```json
{
  "error": "read_only_fields",
  "message": "El status del folio cambia con sus acciones: POST /operations/:id/close, /reopen o /cancel.",
  "errors": ["status no se escribe en esta petición"],
  "fields": ["status"],
  "request_id": "6c0f6a8e-2a7e-4c55-9d3e-1b0c2f8d9e11"
}
```

## Cerrar un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/close</code></div>

<p class="perm">Permiso: <code>operations_edit</code></p>

Pasa el folio a `closed` y registra quién lo cerró y cuándo. No lleva cuerpo.

Hoy la condición es una sola: que **ningún servicio** del folio esté `active` ni `finished`. Es decir, todos sus servicios están `closed` o `canceled`, o el folio no tiene servicios. No se revisa el estado del folio.

### Respuesta

**200** con `{ "operation": {...}, "message": "Operación cerrada exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Algún servicio está `active` o `finished`. `message`: «No se puede cerrar la operación mientras existan servicios activos o en proceso»
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/close \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "errors": ["No se puede cerrar la operación mientras existan servicios activos o en proceso"],
  "message": "No se puede cerrar la operación mientras existan servicios activos o en proceso",
  "error": "validation_failed",
  "request_id": "1b7c9a3e-5d2f-4e8a-9c61-0f3b2d7e8a14"
}
```

## Reabrir un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/reopen</code></div>

<p class="perm">Permiso: <code>operations_edit</code></p>

Regresa a `active` un folio `finished` o `closed`. No lleva cuerpo. Un folio `canceled` no se reabre.

### Respuesta

**200** con `{ "operation": {...}, "message": "Operación reabierta exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | El folio no está `finished` ni `closed`. `message`: «No se puede reabrir la operación en su estado actual»
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/reopen \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Cancelar un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/cancel</code></div>

<p class="perm">Permiso: <code>operations_edit</code></p>

Pasa a `canceled` un folio `confirmed` o `active` cuyos servicios estén **todos** cancelados (o que no tenga servicios). Primero [cancela los servicios](#cancelar-un-servicio).

Responde la decisión del ciclo de vida, no el folio: la primera petición responde **422** `confirm` sin cambiar nada; repítela con `confirmed=true` para cancelar. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

### Cuerpo de la petición

Los parámetros van en la raíz del cuerpo (o en la URL), no dentro de `operation`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_cancellation_reason_id` | integer | <span class="opt">opcional</span> Motivo de cancelación del catálogo de la cuenta (`GET /api/v1/operation_cancellation_reasons`, ver [Catálogos](#catalogos)). **Obligatorio** (este o el nombre) si la cuenta tiene motivos activos
`operation_cancellation_reason_name` | string | <span class="opt">opcional</span> Alternativa al id: nombre exacto del motivo, sin distinguir mayúsculas
`cancellation_notes` | string | <span class="opt">opcional</span> Notas de la cancelación
`canceled_at` | datetime | <span class="opt">opcional</span> Fecha de cancelación. Por omisión, el momento de la petición
`archive` | boolean | <span class="opt">opcional</span> `true` también archiva el folio al cancelarlo
`confirmed` | boolean | <span class="opt">opcional</span> `true` para ejecutar la cancelación

El motivo solo se toma de `operation_cancellation_reason_id` o del nombre. Un parámetro `reason` suelto se ignora.

### Respuesta

- **422** `confirm` con `code` `will_cancel` (o `will_cancel_and_archive` si mandaste `archive=true`): no se hizo nada. Repite con `confirmed=true`.
- **200** `allow`: el folio quedó cancelado (y archivado, si lo pediste).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La cuenta tiene motivos activos y no mandaste id ni nombre, o el motivo no existe o está archivado. Se valida antes de la confirmación
`422` `services_not_canceled` | Hay servicios sin cancelar. `suggested_action`: `null`
`422` `already_canceled` | El folio ya está cancelado. `suggested_action`: `archive`
`422` `not_cancelable` | El folio está `finished` o `closed`. `suggested_action`: `archive`
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/cancel \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation_cancellation_reason_name": "Cliente canceló",
    "cancellation_notes": "El cliente pospuso la compra",
    "confirmed": true
  }'
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

> Error 422 · sin confirmed

```json
{
  "outcome": "confirm",
  "code": "will_cancel",
  "title": "¿Cancelar este folio?",
  "message": "Quedará cancelado y seguirá en tus listas, en la búsqueda y en las opciones al capturar. No se puede deshacer.",
  "suggested_action": null,
  "errors": ["Quedará cancelado y seguirá en tus listas, en la búsqueda y en las opciones al capturar. No se puede deshacer."],
  "error": "will_cancel",
  "request_id": "3f2a9c41-7b6e-4d0a-8e15-2c9d4b7a6f03"
}
```

## Archivar y restaurar un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/restore</code></div>

<p class="perm">Permiso: <code>operations_edit</code></p>

Archivar saca el folio de los listados normales sin cambiar su `status`. Solo se archiva un folio `finished`, `closed` o `canceled`. Un folio `confirmed` o `active` se cancela y archiva en un paso con [cancelar](#cancelar-un-folio-operativo) y `archive=true`.

Restaurar lo devuelve a los listados con el mismo `status` y lo vuelve editable. Ninguna de las dos pide confirmación. Ambas responden la decisión del ciclo de vida: **200** `allow` o **422** `reject`.

Acción | `code` del rechazo | Cuándo | `suggested_action`
------ | ------------------ | ------ | ------------------
Archivar | `cancel_instead` | El folio está `confirmed` o `active` | `cancel`
Archivar | `already_archived` | Ya estaba archivado | `null`
Restaurar | `not_archived` | El folio no está archivado | `null`

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/archive \
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

## Eliminar un folio operativo

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/operations/:id</code></div>

<p class="perm">Permiso: <code>operations_delete</code></p>

Elimina (borrado lógico) un folio `confirmed` que no tiene servicios ni cotizaciones ligadas: un folio abierto por error. Después aparece como lápida en `deleted_since`. En cualquier otro caso responde **422** `reject` y te sugiere cancelar o archivar.

`code` | Cuándo | `suggested_action`
------ | ------ | ------------------
`not_confirmed` | El folio no está `confirmed` | `cancel` si está `active`; `archive` si está `finished`, `closed` o `canceled` y no archivado
`has_quotes` | El folio tiene cotizaciones ligadas | `cancel`
`has_services` | El folio tiene servicios | `cancel`

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/operations/1042 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "not_confirmed",
  "title": "No puedes eliminar",
  "message": "Solo puedes eliminar un folio confirmado, sin cotizaciones ni servicios. Si no es el caso, cancélalo o archívalo.",
  "suggested_action": "cancel",
  "errors": ["Solo puedes eliminar un folio confirmado, sin cotizaciones ni servicios. Si no es el caso, cancélalo o archívalo."],
  "error": "not_confirmed",
  "request_id": "8e41c2d7-0a9b-4f36-b5e2-7d1c3a9f6b20"
}
```

## Centro de costos de un folio operativo

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/cost_centers</code></div>

<p class="perm">Permiso: <code>operations_read</code></p>

Lista, paginadas, las líneas de centro de costos de todos los servicios del folio, con el servicio de cada una. Es solo lectura: las líneas se crean y cambian en su servicio. El detalle está en [Listar líneas de un folio operativo](#listar-lineas-de-un-folio-operativo).

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations/1042/cost_centers?per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Generar una factura desde un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/generate_invoice</code></div>

<p class="perm">Permiso: <code>invoices_create</code> y poder ver el folio (<code>operations_read</code>)</p>

Crea y guarda una [factura](#facturas) en borrador (`drafted`) a partir de líneas de venta del centro de costos del folio. Después la revisas, la completas y la timbras desde Facturas.

### Cuerpo de la petición

Los parámetros van en la raíz del cuerpo, no dentro de un objeto.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`cost_center_ids` | array&lt;integer&gt; | <span class="req">obligatorio</span> Ids de las líneas a facturar. Cada una tiene que ser de un servicio de **este** folio, tener concepto (`item_id`) y no tener factura vigente. Todas con la misma moneda de venta y de servicios no cancelados
`cfdi_use_code` | string | <span class="opt">opcional</span> Uso de CFDI del SAT (`G03`). **Obligatorio en cuentas de México**
`payment_method_code` | string | <span class="opt">opcional</span> Forma de pago del SAT (`01`, `03`, `99`). **Obligatorio en cuentas de México**
`payment_type_code` | string | <span class="opt">opcional</span> Método de pago: `PUE` o `PPD`

### Qué crea

- Cliente: el cliente del folio. Moneda: la moneda de venta de las líneas.
- Fecha y vencimiento: el momento de la petición.
- Descripción: el folio, la referencia del cliente y los datos de cada servicio (tipo de embarque, BL, booking, …).
- Una línea de factura por línea de centro de costos: `concept` como nombre, el concepto (`item`), la cantidad y como precio unitario `income_amount` entre `quantity`.
- Impuestos y retenciones de cada línea: los de la línea de cotización de la que vino la línea de centro de costos; si no viene de una cotización, los del concepto (`item`).
- Cada línea de la factura queda ligada a su línea de centro de costos. Desde ese momento la venta de esa línea queda bloqueada mientras la factura siga vigente. Ver [Líneas bloqueadas por una factura](#lineas-bloqueadas-por-una-factura).

### Qué revisa antes de crear

Antes de crear nada, la API revisa `cost_center_ids` en este orden y responde **422** `validation_failed` en la primera regla que no se cumple. No se crea la factura.

Regla | `message`
----- | ---------
Viene al menos un id | «Indica en cost_center_ids las líneas del centro de costos de este folio que quieres facturar.»
Cada id es una línea de un servicio de este folio | «Estas líneas no son del centro de costos de este folio: 5600, 5601» (los ids tal como los mandaste)
Ninguna línea tiene ya una factura vigente (no cancelada ni eliminada, incluidos borradores) | «Estas líneas ya tienen una factura vigente: 5501. Cancélala o desliga la línea antes de volver a facturarla.»
Cada línea tiene concepto (`item_id`): la línea de factura lo necesita | «Estas líneas no tienen concepto (item_id) y una factura lo necesita: 5502. Asígnalo con PATCH /services/:service_id/cost_centers/:id.»

### Respuesta

**201** con `{ "invoice": {...}, "message": "Borrador de factura generado exitosamente desde el centro de costos" }`. `invoice` trae `id`, `identification`, `status`, `date`, `due_at`, `description`, `contact_id`, `currency` (`code`), `subtotal`, `total` y `line_items_count`. Para el detalle completo usa `GET /api/v1/invoices/:id` (ver [Facturas](#facturas)).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falla una de las reglas de arriba: faltan ids, son de otro folio, ya tienen factura vigente o no tienen concepto
`422` `validation_failed` | Alguna línea es de un servicio cancelado, o las líneas tienen monedas de venta distintas
`422` `validation_failed` | `cfdi_use_code`, `payment_method_code` o `payment_type_code` no existen
`422` `validation_failed` | Cuenta de México sin uso de CFDI o forma de pago
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/generate_invoice \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cost_center_ids": [5501],
    "cfdi_use_code": "G03",
    "payment_method_code": "03",
    "payment_type_code": "PUE"
  }'
```

> Respuesta 201

```json
{
  "invoice": {
    "id": 3307,
    "identification": "F-1532",
    "status": "drafted",
    "date": "2026-11-11T10:15:00.000-06:00",
    "due_at": "2026-11-11T10:15:00.000-06:00",
    "description": "Folio operativo: IMP-ACME-000184 - Ref. cliente: PO-7781\nServicio: SRV-000731 - FCL - Full Container Load, Internacional, BL: MAEU123456789, Booking: BKG-55120",
    "contact_id": 812,
    "currency": { "code": "USD" },
    "subtotal": "4000.0",
    "total": "4640.0",
    "line_items_count": 1
  },
  "message": "Borrador de factura generado exitosamente desde el centro de costos"
}
```

> Error 422 · línea ya facturada

```json
{
  "error": "validation_failed",
  "message": "Estas líneas ya tienen una factura vigente: 5501. Cancélala o desliga la línea antes de volver a facturarla.",
  "errors": ["Estas líneas ya tienen una factura vigente: 5501. Cancélala o desliga la línea antes de volver a facturarla."],
  "request_id": "b81f0c2e-3a47-4d95-8e6b-2c7f9a1d0e53"
}
```

## Generar una factura de proveedor desde un folio operativo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:id/generate_bill</code></div>

<p class="perm">Permiso: <code>bills_create</code> y poder ver el folio (<code>operations_read</code>)</p>

Crea y guarda una [factura de proveedor](#facturas-de-proveedor) a partir de líneas de compra del centro de costos del folio. Queda en estado `opened` en cuanto se crea.

### Cuerpo de la petición

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`cost_center_ids` | array&lt;integer&gt; | <span class="req">obligatorio</span> Ids de las líneas. Todas deben ser de servicios `active`, `finished` o `closed` de **este** folio, tener concepto (`item_id`), no tener factura de proveedor vigente, y ser del mismo proveedor y con la misma moneda de compra

No acepta otros parámetros: ni XML ni PDF. Para adjuntar los documentos del proveedor usa [Facturas de proveedor](#facturas-de-proveedor).

### Qué crea

- Proveedor: el proveedor (`supplier`) de las líneas. Moneda: la moneda de compra de las líneas (`expense_currency`, o la de venta si la línea no tiene moneda de compra), con tipo de cambio 1.
- Fecha: el momento de la petición. Vencimiento: 30 días después.
- Una línea por línea de centro de costos: `concept` como nombre, el concepto (`item`), la cantidad y como precio unitario `expense_amount` entre `quantity`. Impuestos y retenciones como en la factura: de la línea de cotización o del concepto.
- Cada línea queda ligada a su línea de centro de costos y la compra de esa línea queda bloqueada.

Antes de crear nada aplica las mismas reglas que [Generar una factura](#generar-una-factura-desde-un-folio-operativo), con la factura de proveedor en lugar de la factura: una línea que ya tiene factura de proveedor vigente (no anulada ni eliminada) responde **422** con «Estas líneas ya tienen una factura de proveedor vigente: 5501. Anúlala o desliga la línea antes de volver a registrarla.»

### Respuesta

**201** con `{ "bill": {...}, "message": "Factura de proveedor generada exitosamente desde el centro de costos" }`. `bill` trae los mismos campos que `invoice` en [Generar una factura](#generar-una-factura-desde-un-folio-operativo); `status` es `opened`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Faltan ids, alguno no es una línea de este folio, alguna línea ya tiene factura de proveedor vigente o no tiene concepto
`422` `validation_failed` | Alguna línea es de un servicio cancelado
`422` `validation_failed` | Las líneas tienen proveedores o monedas de compra distintas
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/generate_bill \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "cost_center_ids": [5501] }'
```

> Respuesta 201

```json
{
  "bill": {
    "id": 3311,
    "identification": "P-0871",
    "status": "opened",
    "date": "2026-11-11T10:16:00.000-06:00",
    "due_at": "2026-12-11T10:16:00.000-06:00",
    "description": "Folio operativo: IMP-ACME-000184 - Ref. cliente: PO-7781\nServicio: SRV-000731 - FCL - Full Container Load, Internacional, BL: MAEU123456789, Booking: BKG-55120",
    "contact_id": 815,
    "currency": { "code": "USD" },
    "subtotal": "3000.0",
    "total": "3480.0",
    "line_items_count": 1
  },
  "message": "Factura de proveedor generada exitosamente desde el centro de costos"
}
```
