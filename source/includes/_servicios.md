# Servicios

<p class="lead">Un servicio (<code>service</code>) es cada tramo o actividad de un folio operativo: el flete marítimo, el despacho aduanal, el transporte terrestre. Avanza por las columnas de un tablero de servicio y lleva sus propias líneas de centro de costos. Tu integración lo crea dentro de un folio, actualiza sus datos de embarque y lo cierra cuando termina.</p>

- **Folio.** Todo servicio pertenece a un [folio operativo](#folios-operativos) de la cuenta (`operation_id`). Al crear un servicio en un folio `confirmed`, el folio pasa a `active`.
- **Tablero y columna.** Cada servicio vive en una columna (`list_id`) de un tablero de servicio (`board_id`). Consulta los tableros y sus columnas con `GET /api/v1/boards` (ver [Catálogos](#catalogos)). Con `board_id` el servicio entra en la primera columna del tablero. La respuesta trae `board` y `list` para que sepas en qué etapa está.
- **Modo.** El tablero define el `mode` del servicio: `land` (terrestre), `aerial` (aéreo), `maritime` (marítimo) o `customs` (despacho aduanal). Si el tablero tiene tipo y clase de embarque, el servicio los toma cuando no los mandas.
- **Datos obligatorios según el tablero.** En tableros `land`, `aerial` y `maritime` el servicio necesita `shipment_type` y `shipment_kind`. En tableros `customs` necesita agente aduanal y aduana.
- **Agente.** El agente del servicio es un usuario de la cuenta: `service_agent_email` (recomendado) o `service_agent_id`.
- **Mes económico.** El servicio toma el del folio al crearse y cambia cuando cambia el del folio. No se escribe en el servicio.
- **Costos.** Las líneas de ingreso y gasto se manejan en [Centro de costos](#centro-de-costos). Al cancelar un servicio, sus líneas dejan de sumar en los totales del folio.
- **No se elimina.** Un servicio se cancela o se archiva; `DELETE` siempre responde un rechazo con la acción sugerida.

## Estados de un servicio

Estado | Significado
------ | -----------
`active` | Activo. Estado inicial
`finished` | Finalizado: la operación del tramo terminó
`closed` | Cerrado
`canceled` | Cancelado

Acción | Se permite cuando | Resultado
------ | ----------------- | ---------
`finish` | El servicio está `active` | `finished`. En servicios `land` crea la tarea obligatoria «Subir POD» (prueba de entrega)
`close` | El servicio está `finished`. En `land`, si tiene tarea de POD, debe estar aprobada | `closed`
`reopen` | El servicio está `finished` o `closed` | `active`
`cancel` | El servicio está `active` y no tiene facturas de cliente vigentes | `canceled`
`archive` | El servicio está `finished`, `closed` o `canceled` | `status` no cambia; `archived: true`
`restore` | El servicio está archivado | `status` no cambia; `archived: false`

Un servicio archivado, o cuyo folio está archivado, es de solo lectura: `PATCH`, `finish`, `close`, `reopen` y `cancel` responden **422** `archived_read_only`, y tampoco se escriben sus líneas de centro de costos, comentarios, tareas ni carpetas. Archivar y restaurar sí se permiten. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

## El objeto servicio

El listado devuelve los campos de la primera parte de la tabla. El detalle, el alta y el cambio agregan los campos marcados «solo detalle».

Campo | Tipo | Descripción
----- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Identificador del servicio
`identification` | string | <span class="ro">solo lectura</span> Folio del servicio, generado con la secuencia de servicios de la cuenta
`mode` | string | `land`, `aerial`, `maritime` o `customs`. Siempre es el del tablero del servicio
`status` | string | <span class="ro">solo lectura</span> `active`, `finished`, `closed` o `canceled`. Cambia con sus acciones
`archived` | boolean | <span class="ro">solo lectura</span> `true` si el servicio está archivado
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`
`shipment_type` | string | Tipo de embarque. Valores usados por modo: marítimo `fcl`, `lcl`, `roro`, `bbk`, `ogg`; terrestre `ltl`, `ftl`, `custody`, `regular`, `expedited`; aéreo `nfo`, `flash`, `std`, `chtr`, `eco`, `air`, `cou`, entre otros
`shipment_kind` | string | `national` (nacional) o `international` (internacional)
`operation` | object | Folio del servicio: `id`, `identification`, `kind`, `client_ref`. Se escribe con `operation_id`
`board` | object | <span class="new">nuevo</span> Tablero de servicio: `id` y `name`, o `null`. Se escribe con `board_id`
`list` | object | <span class="new">nuevo</span> Columna (etapa) del tablero en la que está el servicio: `id` y `name`, o `null`. Se escribe con `list_id`
`supplier` | object | Proveedor principal: `id`, `alias`, `name`, o `null`. Se escribe con `supplier_code` o `supplier_id`
`service_agent` | object | Agente del servicio: `id`, `email`, `name`, o `null`. Se escribe con `service_agent_email` o `service_agent_id`
`eta_date` | datetime | Llegada estimada
`etd_date` | datetime | Salida estimada
`pickup_date` | datetime | Recolección
`delivery_date` | datetime | Entrega
`comments_count` | integer | <span class="ro">solo lectura</span> Comentarios del servicio
`tasks_count` | integer | <span class="ro">solo lectura</span> Tareas del servicio
`folders_count` | integer | <span class="ro">solo lectura</span> Carpetas del servicio
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span> Alta y último cambio
`bl` | string | Solo detalle. Número de BL
`booking` | string | Solo detalle. Número de booking
`guide_number` | string | Solo detalle. Número de guía
`flight_number` | string | Solo detalle. Número de vuelo
`awb_number` | string | Solo detalle. Número de guía aérea (AWB)
`airline_name` | string | Solo detalle. Aerolínea
`shipping_line_name` | string | Solo detalle. Naviera
`customs_agent` | object | Solo detalle. Agente aduanal (un contacto): `id`, `alias`, `name`, o `null`. Se escribe con `customs_agent_code` o `customs_agent_id`
`customs_address` | object | Solo detalle. Aduana (una dirección de la cuenta): `id`, `alias`, `name`, `address_type` y `full_address`, o `null`. Se escribe con `customs_address_code` o `customs_address_id`. Ver [Direcciones](#direcciones)
`customs_reference` | string | Solo detalle. Referencia aduanal
`dispatch_appointment_at` | datetime | Solo detalle. Cita de despacho
`observations` | string | Solo detalle. Observaciones
`mbl`, `hbl` | string | Solo detalle. Master BL y House BL
`mawb`, `hawb` | string | Solo detalle. Master AWB y House AWB
`pedimento` | string | Solo detalle. Número de pedimento
`carta_porte` | string | Solo detalle. Carta porte
`manifiesto_carga` | string | Solo detalle. Manifiesto de carga
`tags` | array&lt;string&gt; | Solo detalle. Etiquetas. Se escriben con `tag_list`
`to_dos` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Hasta 100 tareas, de la más reciente a la más antigua, con la misma forma que en el [folio](#el-objeto-folio-operativo). Ver [Tareas](#tareas)
`folders` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Árbol de carpetas con sus archivos, con la misma forma que en el [folio](#el-objeto-folio-operativo). Al crear el servicio se crea una carpeta con su `identification`. Ver [Documentos y archivos](#documentos-y-archivos)
`cost_centers` | array&lt;object&gt; | <span class="ro">solo lectura</span> Solo detalle. Líneas de centro de costos, de la más reciente a la más antigua. Mismo formato que el [detalle de una línea](#el-objeto-linea-de-centro-de-costos), sin `service`

`board` y `list` dicen en qué tablero y etapa está el servicio; compáralos con `GET /api/v1/boards` (ver [Catálogos](#catalogos)).

> Objeto servicio

```json
{
  "id": 2210,
  "identification": "SRV-000731",
  "mode": "maritime",
  "status": "active",
  "archived": false,
  "archived_at": null,
  "shipment_type": "fcl",
  "shipment_kind": "international",
  "operation": {
    "id": 1042,
    "identification": "IMP-ACME-000184",
    "kind": "importation",
    "client_ref": "PO-7781"
  },
  "board": { "id": 31, "name": "Marítimo importación" },
  "list": { "id": 102, "name": "En tránsito" },
  "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
  "service_agent": { "id": 15, "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
  "eta_date": "2026-11-28T00:00:00.000-06:00",
  "etd_date": "2026-11-06T00:00:00.000-06:00",
  "pickup_date": null,
  "delivery_date": null,
  "comments_count": 1,
  "tasks_count": 0,
  "folders_count": 1,
  "created_at": "2026-11-03T10:20:41.000-06:00",
  "updated_at": "2026-11-10T17:42:05.000-06:00",
  "bl": "MAEU123456789",
  "booking": "BKG-55120",
  "guide_number": null,
  "flight_number": null,
  "awb_number": null,
  "airline_name": null,
  "shipping_line_name": "Naviera del Pacífico",
  "customs_agent": null,
  "customs_address": null,
  "customs_reference": null,
  "dispatch_appointment_at": null,
  "observations": "Entrega en CEDIS Guadalajara",
  "mbl": "MAEU123456789",
  "hbl": "NAVPAC-HBL-0091",
  "mawb": null,
  "hawb": null,
  "pedimento": null,
  "carta_porte": null,
  "manifiesto_carga": null,
  "tags": [],
  "to_dos": [],
  "folders": [
    {
      "id": 7731,
      "name": "SRV-000731",
      "parent_id": null,
      "files_count": 0,
      "attachments": [],
      "children": []
    }
  ],
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
```

## Listar servicios

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services</code></div>

<p class="perm">Permiso: <code>services_read</code></p>

Devuelve los servicios de la cuenta que el usuario puede ver, del más reciente al más antiguo (`created_at`). Con `updated_since` el orden es `updated_at`, `id`. Sin `archived`, la lista excluye los servicios archivados y los que están en un folio archivado. Cada elemento trae los campos del listado, sin los «solo detalle».

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="opt">opcional</span> Solo los servicios de ese folio
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo los servicios archivados, aunque su folio también lo esté
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion)
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Con `updated_since` (sin `archived`) también vienen los archivados y los de folios archivados. Las lápidas de `deleted_since` traen `identification`

No hay filtros por estado, modo ni proveedor.

> Petición

```shell
curl "https://control.apunto.io/api/v1/services?operation_id=1042" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "services": [
    {
      "id": 2210,
      "identification": "SRV-000731",
      "mode": "maritime",
      "status": "active",
      "archived": false,
      "archived_at": null,
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "operation": {
        "id": 1042,
        "identification": "IMP-ACME-000184",
        "kind": "importation",
        "client_ref": "PO-7781"
      },
      "board": { "id": 31, "name": "Marítimo importación" },
      "list": { "id": 102, "name": "En tránsito" },
      "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "service_agent": { "id": 15, "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
      "eta_date": "2026-11-28T00:00:00.000-06:00",
      "etd_date": "2026-11-06T00:00:00.000-06:00",
      "pickup_date": null,
      "delivery_date": null,
      "comments_count": 1,
      "tasks_count": 0,
      "folders_count": 1,
      "created_at": "2026-11-03T10:20:41.000-06:00",
      "updated_at": "2026-11-10T17:42:05.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Obtener un servicio

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:id</code></div>

<p class="perm">Permiso: <code>services_read</code></p>

Devuelve el servicio con todos sus campos, sus tareas, carpetas y líneas de centro de costos. Responde **404** si no existe, es de otra cuenta o el usuario no lo puede ver.

> Petición

```shell
curl https://control.apunto.io/api/v1/services/2210 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "service": {
    "id": 2210,
    "identification": "SRV-000731",
    "mode": "maritime",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "shipment_type": "fcl",
    "shipment_kind": "international",
    "operation": {
      "id": 1042,
      "identification": "IMP-ACME-000184",
      "kind": "importation",
      "client_ref": "PO-7781"
    },
    "board": { "id": 31, "name": "Marítimo importación" },
    "list": { "id": 102, "name": "En tránsito" },
    "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "service_agent": { "id": 15, "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
    "eta_date": "2026-11-28T00:00:00.000-06:00",
    "etd_date": "2026-11-06T00:00:00.000-06:00",
    "pickup_date": null,
    "delivery_date": null,
    "comments_count": 1,
    "tasks_count": 0,
    "folders_count": 1,
    "created_at": "2026-11-03T10:20:41.000-06:00",
    "updated_at": "2026-11-10T17:42:05.000-06:00",
    "bl": "MAEU123456789",
    "booking": "BKG-55120",
    "guide_number": null,
    "flight_number": null,
    "awb_number": null,
    "airline_name": null,
    "shipping_line_name": "Naviera del Pacífico",
    "customs_agent": null,
    "customs_address": null,
    "customs_reference": null,
    "dispatch_appointment_at": null,
    "observations": "Entrega en CEDIS Guadalajara",
    "mbl": "MAEU123456789",
    "hbl": "NAVPAC-HBL-0091",
    "mawb": null,
    "hawb": null,
    "pedimento": null,
    "carta_porte": null,
    "manifiesto_carga": null,
    "tags": [],
    "to_dos": [],
    "folders": [
      {
        "id": 7731,
        "name": "SRV-000731",
        "parent_id": null,
        "files_count": 0,
        "attachments": [],
        "children": []
      }
    ],
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
}
```

## Crear un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services</code></div>

<p class="perm">Permiso: <code>services_create</code></p>

Crea un servicio dentro de un folio y lo coloca en un tablero. El usuario del token queda como creador. Al entrar a su columna corren las automatizaciones del tablero (tareas y carpetas de esa etapa), igual que en la plataforma.

### Cuerpo de la petición

Todo va dentro de `service`. Para cada referencia manda el código o el id, no los dos.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="req">obligatorio</span> Folio del servicio. Debe ser de la cuenta y no estar archivado
`board_id` | integer | <span class="opt">opcional</span> <span class="new">nuevo</span> Tablero de servicio. El servicio entra en su primera columna
`list_id` | integer | <span class="opt">opcional</span> <span class="new">nuevo</span> Columna exacta de un tablero. Si mandas los dos, gana `list_id`
`mode` | string | <span class="opt">opcional</span> `land`, `aerial`, `maritime` o `customs`. Si mandas tablero o columna, debe coincidir con el modo del tablero
`shipment_type` | string | <span class="opt">opcional</span> Tipo de embarque. Obligatorio en tableros `land`, `aerial` y `maritime`, salvo que el tablero lo defina
`shipment_kind` | string | <span class="opt">opcional</span> `national` o `international`. Obligatorio en tableros `land`, `aerial` y `maritime`, salvo que el tablero lo defina
`supplier_code` | string | <span class="opt">opcional</span> Alias del proveedor principal. Alternativa: `supplier_id`
`service_agent_email` | string | <span class="opt">opcional</span> Correo del agente; debe ser usuario de la cuenta. Alternativa: `service_agent_id`
`customs_agent_code` | string | <span class="opt">opcional</span> Alias del agente aduanal. Alternativa: `customs_agent_id`. Obligatorio en tableros `customs`
`customs_address_code` | string | <span class="opt">opcional</span> Alias de la dirección de la aduana. Alternativa: `customs_address_id`. Obligatorio en tableros `customs`
`customs_reference` | string | <span class="opt">opcional</span> Referencia aduanal
`dispatch_appointment_at` | datetime | <span class="opt">opcional</span> Cita de despacho
`eta_date`, `etd_date`, `pickup_date`, `delivery_date` | datetime | <span class="opt">opcional</span> Fechas del embarque. Acepta fecha (`2026-11-28`) o fecha-hora con offset
`bl`, `booking`, `guide_number`, `flight_number`, `awb_number` | string | <span class="opt">opcional</span> Números del embarque
`airline_name`, `shipping_line_name` | string | <span class="opt">opcional</span> Aerolínea y naviera
`mbl`, `hbl`, `mawb`, `hawb` | string | <span class="opt">opcional</span> Documentos de transporte
`pedimento`, `carta_porte`, `manifiesto_carga` | string | <span class="opt">opcional</span> Documentos de aduana y transporte terrestre
`observations` | string | <span class="opt">opcional</span> Observaciones
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta

Si no mandas `board_id` ni `list_id`, la API usa el único tablero activo de la cuenta para el `mode` que mandaste (o el único tablero de la cuenta, si no mandas `mode`). Si hay más de uno, o ninguno, responde **422**: indica el tablero.

`status` no se acepta: el servicio nace `active` y mandarlo responde **422** `read_only_fields`.

### Respuesta

**201** con `{ "service": {...}, "message": "Servicio creado exitosamente" }`. El servicio viene completo, como en [Obtener un servicio](#obtener-un-servicio).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | No mandaste tablero ni columna y la cuenta no tiene exactamente un tablero para ese modo: «Indica board_id o list_id (consulta GET /api/v1/boards)»
`422` `validation_failed` | `board_id` o `list_id` no existen, son de un tablero archivado o de otra cuenta: «Lista no encontrada con la identificación proporcionada»
`422` `validation_failed` | `mode` no coincide con el del tablero: «El modo del servicio no coincide con el del tablero (maritime).»
`422` `validation_failed` | `supplier_code`, `customs_agent_code`, `customs_address_code` o `service_agent_email` no existen en la cuenta
`422` `validation_failed` | `mode` o `shipment_kind` fuera de su lista
`422` `validation_failed` | Falta el folio, es de otra cuenta, o faltan los datos obligatorios del tablero
`422` `validation_failed` | `service_agent_id` no es usuario de la cuenta, o una etiqueta no está en el catálogo
`422` `read_only_fields` | Mandaste `status`
`422` `archived_read_only` | El folio está archivado

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "operation_id": 1042,
      "board_id": 31,
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "supplier_code": "NAVPAC",
      "service_agent_email": "laura@tuempresa.mx",
      "booking": "BKG-55120",
      "shipping_line_name": "Naviera del Pacífico",
      "etd_date": "2026-11-06",
      "eta_date": "2026-11-28"
    }
  }'
```

```javascript
const { status, body } = await api("/services", {
  method: "POST",
  body: JSON.stringify({
    service: {
      operation_id: 1042,
      board_id: 31,
      shipment_type: "fcl",
      shipment_kind: "international",
      supplier_code: "NAVPAC",
      service_agent_email: "laura@tuempresa.mx",
      booking: "BKG-55120",
      shipping_line_name: "Naviera del Pacífico",
      etd_date: "2026-11-06",
      eta_date: "2026-11-28",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/services", json={
    "service": {
        "operation_id": 1042,
        "board_id": 31,
        "shipment_type": "fcl",
        "shipment_kind": "international",
        "supplier_code": "NAVPAC",
        "service_agent_email": "laura@tuempresa.mx",
        "booking": "BKG-55120",
        "shipping_line_name": "Naviera del Pacífico",
        "etd_date": "2026-11-06",
        "eta_date": "2026-11-28",
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "service": {
    "id": 2210,
    "identification": "SRV-000731",
    "mode": "maritime",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "shipment_type": "fcl",
    "shipment_kind": "international",
    "operation": {
      "id": 1042,
      "identification": "IMP-ACME-000184",
      "kind": "importation",
      "client_ref": "PO-7781"
    },
    "board": { "id": 31, "name": "Marítimo importación" },
    "list": { "id": 101, "name": "Booking" },
    "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "service_agent": { "id": 15, "email": "laura@tuempresa.mx", "name": "Laura Méndez" },
    "eta_date": "2026-11-28T00:00:00.000-06:00",
    "etd_date": "2026-11-06T00:00:00.000-06:00",
    "pickup_date": null,
    "delivery_date": null,
    "comments_count": 0,
    "tasks_count": 0,
    "folders_count": 1,
    "created_at": "2026-11-03T10:20:41.000-06:00",
    "updated_at": "2026-11-03T10:20:41.000-06:00",
    "bl": null,
    "booking": "BKG-55120",
    "guide_number": null,
    "flight_number": null,
    "awb_number": null,
    "airline_name": null,
    "shipping_line_name": "Naviera del Pacífico",
    "customs_agent": null,
    "customs_address": null,
    "customs_reference": null,
    "dispatch_appointment_at": null,
    "observations": null,
    "mbl": null,
    "hbl": null,
    "mawb": null,
    "hawb": null,
    "pedimento": null,
    "carta_porte": null,
    "manifiesto_carga": null,
    "tags": [],
    "to_dos": [],
    "folders": [
      {
        "id": 7731,
        "name": "SRV-000731",
        "parent_id": null,
        "files_count": 0,
        "attachments": [],
        "children": []
      }
    ],
    "cost_centers": []
  },
  "message": "Servicio creado exitosamente"
}
```

## Actualizar un servicio

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/services/:id</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Cambio parcial: manda dentro de `service` solo los campos que cambian; los omitidos no cambian. Acepta los mismos campos que el alta. `PUT` funciona igual.

- `status` responde **422** `read_only_fields`: usa [finalizar](#finalizar-un-servicio), [cerrar](#cerrar-un-servicio), [reabrir](#reabrir-un-servicio) o [cancelar](#cancelar-un-servicio).
- `list_id` mueve el servicio a esa columna; `board_id`, a la primera columna de ese tablero. Al avanzar de columna, si el servicio tiene tareas obligatorias pendientes responde **422**: «Es necesario terminar todas las tareas obligatorias antes de cambiar de etapa».
- `mode` sigue siempre al tablero: sin `board_id` ni `list_id`, mandar `mode` no cambia nada.
- `tag_list` reemplaza las etiquetas del servicio.
- En un servicio archivado o de un folio archivado responde **422** `archived_read_only`.

### Respuesta

**200** con `{ "service": {...}, "message": "Servicio actualizado exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | `board_id` o `list_id` no existen, son de un tablero archivado o de otra cuenta, o `mode` no coincide con el del tablero. `message`: «No se pudo actualizar el servicio»
`422` `validation_failed` | Avanzar de columna con tareas obligatorias pendientes
`422` `read_only_fields` | Mandaste `status`
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/services/2210 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "service": { "bl": "MAEU123456789", "list_id": 102, "eta_date": "2026-11-30" } }'
```

## Finalizar un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/finish</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Pasa un servicio `active` a `finished`. No lleva cuerpo. En servicios `land` crea la tarea obligatoria «Subir POD» si no existe.

### Respuesta

**200** con `{ "service": {...}, "message": "Servicio finalizado exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | El servicio no está `active`. `message`: «No se puede finalizar el servicio en su estado actual»
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/finish \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Cerrar un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/close</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Pasa un servicio `finished` a `closed`. No lleva cuerpo. En servicios `land` con tarea de POD, la tarea tiene que estar completada y no rechazada.

### Respuesta

**200** con `{ "service": {...}, "message": "Servicio cerrado exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Servicio `land` con POD sin aprobar. `message`: «No se puede cerrar el servicio terrestre sin POD aprobado»
`422` `validation_failed` | El servicio no está `finished`. `message`: «No se puede cerrar el servicio en su estado actual»
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/close \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Reabrir un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/reopen</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Regresa a `active` un servicio `finished` o `closed`. No lleva cuerpo. Un servicio `canceled` no se reabre.

### Respuesta

**200** con `{ "service": {...}, "message": "Servicio reabierto exitosamente" }`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | El servicio no está `finished` ni `closed`. `message`: «No se puede reabrir el servicio en su estado actual»
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/reopen \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Cancelar un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/cancel</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Pasa a `canceled` un servicio `active`. Sus líneas de centro de costos dejan de sumar en los totales del folio, que se recalculan al cancelar.

Responde la decisión del ciclo de vida, no el servicio: la primera petición responde **422** `confirm` sin cambiar nada; repítela con `confirmed=true` para cancelar. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

### Cuerpo de la petición

Los parámetros van en la raíz del cuerpo (o en la URL), no dentro de `service`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`service_cancellation_reason_id` | integer | <span class="opt">opcional</span> Motivo de cancelación del catálogo de la cuenta (`GET /api/v1/service_cancellation_reasons`, ver [Catálogos](#catalogos)). **Obligatorio** (este o el nombre) si la cuenta tiene motivos activos
`service_cancellation_reason_name` | string | <span class="opt">opcional</span> Alternativa al id: nombre exacto del motivo, sin distinguir mayúsculas
`cancellation_notes` | string | <span class="opt">opcional</span> Notas de la cancelación
`canceled_at` | datetime | <span class="opt">opcional</span> Fecha de cancelación. Por omisión, el momento de la petición
`archive` | boolean | <span class="opt">opcional</span> `true` también archiva el servicio al cancelarlo
`confirmed` | boolean | <span class="opt">opcional</span> `true` para ejecutar la cancelación

El motivo solo se toma de `service_cancellation_reason_id` o del nombre. Un parámetro `reason` suelto se ignora.

### Respuesta

- **422** `confirm` con `code` `will_cancel` (o `will_cancel_and_archive` si mandaste `archive=true`): no se hizo nada. Repite con `confirmed=true`.
- **200** `allow`: el servicio quedó cancelado (y archivado, si lo pediste).

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La cuenta tiene motivos activos y no mandaste id ni nombre, o el motivo no existe o está archivado. Se valida antes de la confirmación
`422` `has_customer_invoice` | El servicio tiene una factura de cliente que no está cancelada. Cancela esa factura primero. `suggested_action`: `null`
`422` `already_canceled` | El servicio ya está cancelado. `suggested_action`: `archive`
`422` `not_cancelable` | El servicio está `finished` o `closed`. `suggested_action`: `archive`
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/cancel \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_cancellation_reason_name": "Ya no se requiere el servicio",
    "cancellation_notes": "El cliente contrató el flete directo",
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

> Error 422 · factura vigente

```json
{
  "outcome": "reject",
  "code": "has_customer_invoice",
  "title": "No puedes cancelar",
  "message": "Este servicio tiene una factura que sigue vigente. Cancela esa factura y después podrás cancelar el servicio.",
  "suggested_action": null,
  "errors": ["Este servicio tiene una factura que sigue vigente. Cancela esa factura y después podrás cancelar el servicio."],
  "error": "has_customer_invoice",
  "request_id": "c47e1a90-2b3d-4f58-a6e1-9d0b8c2f4e17"
}
```

## Archivar y restaurar un servicio

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:id/restore</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Archivar saca el servicio de los listados normales sin cambiar su `status`. Solo se archiva un servicio `finished`, `closed` o `canceled`. Un servicio `active` se cancela y archiva en un paso con [cancelar](#cancelar-un-servicio) y `archive=true`.

Restaurar lo vuelve editable con el mismo `status`; reaparece en el listado normal si su folio no está archivado. Las dos se permiten aunque el folio esté archivado. Ninguna pide confirmación. Ambas responden la decisión del ciclo de vida: **200** `allow` o **422** `reject`.

Acción | `code` del rechazo | Cuándo | `suggested_action`
------ | ------------------ | ------ | ------------------
Archivar | `cancel_instead` | El servicio está `active` | `cancel`
Archivar | `already_archived` | Ya estaba archivado | `null`
Restaurar | `not_archived` | El servicio no está archivado | `null`

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/archive \
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

## Eliminar un servicio

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/services/:id</code></div>

<p class="perm">Permiso: <code>services_delete</code></p>

Un servicio **no se elimina**. Esta ruta siempre responde **422** `reject` con `code` `delete_not_allowed` y no cambia nada. `suggested_action` te dice qué hacer: `cancel` si el servicio está `active`, `archive` si está `finished`, `closed` o `canceled` (y no archivado).

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/services/2210 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "delete_not_allowed",
  "title": "No puedes eliminar",
  "message": "Un servicio no se elimina. Si sigue activo, cancélalo. Si ya está finalizado, cerrado o cancelado, archívalo.",
  "suggested_action": "cancel",
  "errors": ["Un servicio no se elimina. Si sigue activo, cancélalo. Si ya está finalizado, cerrado o cancelado, archívalo."],
  "error": "delete_not_allowed",
  "request_id": "5a0d3e72-9c1b-4a86-b2f4-61e8d07c3b95"
}
```
