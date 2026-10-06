# Solicitudes comerciales

La solicitud comercial es el pedido de cotización: ruta, carga y precios. Vive en una columna del flujo (`list_id`). De aquí sale la [cotización](#cotizaciones).

Antes de crear una solicitud, lee el flujo y, cuando vayas a cerrarla, los motivos de ganado o perdido.

## Columnas del flujo <span class="badge badge-success">GET</span>

```
GET /api/v1/quotation_pipelines
```

```shell
curl "https://control.apunto.io/api/v1/quotation_pipelines" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta

```json
{
  "quotation_pipelines": [
    {
      "id": 4,
      "name": "Comercial",
      "status": "active",
      "default_pipeline": true,
      "lists": [
        {
          "id": 10,
          "name": "Solicitado",
          "position": 1,
          "target_quote_request_status": "requested"
        }
      ]
    }
  ]
}
```

El `id` de cada elemento de `lists` es el `list_id` que pide el alta. `default_pipeline` marca el flujo por defecto de la cuenta. Solo ves flujos de tu cuenta.

## Motivos de ganado <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_won_reasons
```

```json
{
  "quote_won_reasons": [
    { "id": 3, "name": "Mejor precio", "description": null, "status": "active" }
  ]
}
```

Solo motivos activos. El `id` se manda como `quote_won_reason_id` al marcar ganada.

## Motivos de perdido <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_lost_reasons
```

```json
{
  "quote_lost_reasons": [
    { "id": 7, "name": "Precio", "description": null, "status": "active" }
  ]
}
```

El `id` se manda como `quote_lost_reason_id` al marcar perdida.

## Objeto QuoteRequest

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID interno |
| identification | string | Folio |
| status | string | Estatus del tablero |
| result | string | `pending`, `won` o `lost` |
| origin | string | Origen |
| destination | string | Destino |
| transport_mode | string | Modo de transporte |
| operation_kind | string | Tipo de operación |
| operation_mode | string | Modo de operación |
| service_scope | string | Alcance del servicio |
| incoterm | string | Incoterm |
| deal_amount | number | Monto del trato |
| closing_date | date | Cierre esperado |
| cargo_details | string | Detalle de la carga |
| contact | object | `{ id, alias, name }` |
| owner | object | `{ id, name, email }` |
| assignee | object | Pricing asignado |
| seller | object | Vendedor |
| opportunity | object | `{ id, identification, title }` |
| list | object | `{ id, name }` de la columna |
| created_at | datetime | Alta |
| updated_at | datetime | Último cambio |

El detalle agrega `movement_details`, `total_pricing_amount`, `minutes_to_result`, `tags`, `shipment_items` y los conteos de precios, cotizaciones, actividades, mensajes y tareas.

**status:** `start`, `requested`, `quoted`, `vobo`, `finished`, `adjustments_requested`

**result:** `pending`, `won`, `lost`

**transport_mode:** `ocean`, `air`, `truck`, `rail`, `multimodal`

**operation_mode:** `land`, `aerial`, `maritime`. Se mapea a transporte así: `maritime` → `ocean`, `aerial` → `air`, `land` → `truck`.

**operation_kind:** `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company`, `import_trading_company`

**service_scope:** `door_to_door`, `door_to_port_cy`, `door_to_port_cfs`, `port_cy_to_port_cy`, `port_cfs_to_port_cfs`, `port_cy_to_door`, `port_cfs_to_door`, `door_to_airport`, `airport_to_airport`, `airport_to_door`, `door_to_rail_ramp`, `rail_ramp_to_rail_ramp`, `rail_ramp_to_door`, `door_to_truck_terminal`, `truck_terminal_to_truck_terminal`, `truck_terminal_to_door`, `port_cy_to_airport`, `port_cfs_to_airport`, `airport_to_port_cy`, `airport_to_port_cfs`, `port_cy_to_rail_ramp`, `port_cfs_to_rail_ramp`, `rail_ramp_to_port_cy`, `rail_ramp_to_port_cfs`, `rail_ramp_to_airport`, `airport_to_rail_ramp`

## Listar solicitudes <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_requests
```

```shell
curl "https://control.apunto.io/api/v1/quote_requests?status=requested&transport_mode=ocean" \
  -H "Authorization: Bearer TU_TOKEN"
```

| Parámetro | Descripción |
|-----------|-------------|
| status | Estatus |
| result | `pending`, `won` o `lost` |
| transport_mode | `ocean`, `air`, `truck`, `rail`, `multimodal` |
| page | Página, default 1 |
| per_page | Default 25, máximo 100 |

## Obtener una solicitud <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_requests/:id
```

## Crear una solicitud <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests
```

Obligatorios: `list_id`, `origin` y `destination`. El contacto es opcional. Si mandas `contact_code` y no existe, responde **422**.

```shell
curl -X POST "https://control.apunto.io/api/v1/quote_requests" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote_request": {
      "list_id": 10,
      "contact_code": "ACME",
      "opportunity_identification": "OP-00012",
      "assignee_email": "pricing@apunto.com",
      "seller_email": "ana@apunto.com",
      "origin": "Manzanillo",
      "destination": "Monterrey",
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "transport_mode": "ocean",
      "service_scope": "port_cy_to_door",
      "incoterm": "FOB"
    }
  }'
```

```ruby
request.body = {
  quote_request: {
    list_id: 10,
    contact_code: "ACME",
    origin: "Manzanillo",
    destination: "Monterrey",
    operation_kind: "importation",
    operation_mode: "maritime",
    transport_mode: "ocean"
  }
}.to_json
```

```python
requests.post(
    "https://control.apunto.io/api/v1/quote_requests",
    headers={"Authorization": "Bearer TU_TOKEN"},
    json={
        "quote_request": {
            "list_id": 10,
            "contact_code": "ACME",
            "origin": "Manzanillo",
            "destination": "Monterrey",
            "transport_mode": "ocean",
        }
    },
)
```

```javascript
await fetch("https://control.apunto.io/api/v1/quote_requests", {
  method: "POST",
  headers: {
    Authorization: "Bearer TU_TOKEN",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    quote_request: {
      list_id: 10,
      contact_code: "ACME",
      origin: "Manzanillo",
      destination: "Monterrey",
      transport_mode: "ocean"
    }
  })
});
```

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| list_id | Sí | Columna del flujo |
| origin | Sí | Origen |
| destination | Sí | Destino |
| contact_id | No | ID del contacto |
| contact_code | No | Alias del contacto |
| opportunity_id | No | ID de la oportunidad |
| opportunity_identification | No | Folio de la oportunidad |
| assignee_id | No | ID de quien cotiza |
| assignee_email | No | Correo de quien cotiza |
| seller_id | No | ID del vendedor |
| seller_email | No | Correo del vendedor |
| origin_port_id | No | Puerto de origen |
| destination_port_id | No | Puerto de destino |
| incoterm | No | Incoterm |
| service_scope | No | Alcance |
| transport_mode | No | Modo de transporte |
| operation_kind | No | Tipo de operación |
| operation_mode | No | Modo de operación |
| cargo_details | No | Carga |
| movement_details | No | Movimiento |
| status | No | Estatus |
| volumetric_factor_code | No | Factor volumétrico |
| deal_amount | No | Monto. Si viene, `deal_currency_id` es obligatorio |
| deal_currency_id | Condicional | Moneda del monto |
| closing_date | No | Fecha de cierre |
| result | No | `pending`, `won` o `lost` |
| result_notes | No | Notas del resultado |
| tag_list | No | Etiquetas |
| shipment_items_attributes | No | Líneas de carga |
| document_routes_attributes | No | Rutas del documento |

Cada línea de `shipment_items_attributes` acepta `cargo_type`, `package_type`, `pallet_type`, `container_type`, `quantity`, `length`, `width`, `height`, `weight`, `unit_length`, `unit_weight`, `overweight`, `container_number`, `unit_type_id`. En una actualización, `id` y `_destroy` editan o quitan la línea.

Respuesta **201** con `{ "quote_request": { ... }, "message": "..." }`.

## Actualizar una solicitud <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/quote_requests/:id
```

Mismo cuerpo `{ "quote_request": { ... } }`.

## Crear la cotización <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests/:id/create_quote
```

Arma un borrador de cotización con el contacto, el vendedor, la carga, el tipo y el modo de operación, y la moneda por defecto de la cuenta. Copia cada precio a una partida, copia las líneas de carga, guarda `quote_id` y pasa la solicitud a `vobo`.

No lleva cuerpo. Respuesta **201** con la cotización creada. Si no se puede armar, **422** con `errors`.

## Precios de la solicitud

### Listar <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_requests/:quote_request_id/quote_request_pricings
```

Devuelve los precios publicados (`draft: false`), con la moneda incluida: `{ "pricings": [ ... ] }`.

### Crear <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests/:quote_request_id/quote_request_pricings
```

Solo cuando la solicitud está en `requested`. Si no, **422**.

```json
{
  "quote_request_pricing": {
    "service_name": "Flete marítimo",
    "service_description": "FCL 40",
    "quantity": 1,
    "unit_price": "1850.00",
    "total_price": "1850.00",
    "currency_id": 2,
    "exchange_rate": "17.20"
  }
}
```

`currency_id` es el ID de la moneda. Campos adicionales: `unit_type`, `notes`, `is_suggestion`, `pricing_catalog_id`, `supplier_id` y `quote_request_pricing_line_items_attributes`.

Respuesta **201** con `{ "pricing": { ... } }`.

### Sugerencias del tarifario <span class="badge badge-success">GET</span>

```
GET /api/v1/quote_requests/:quote_request_id/quote_request_pricings/suggestions
```

Requiere el flag `pricing_catalogs`. Sin el flag responde `{ "suggestions": [], "meta": { "message": "..." } }`.

| Parámetro | Descripción |
|-----------|-------------|
| supplier_id | Limita las sugerencias a un proveedor |
| advanced | `true` para la búsqueda avanzada |

## Marcar ganada <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests/:id/mark_as_won
```

```json
{
  "won_at": "2026-10-05",
  "result_notes": "El cliente confirmó el flete",
  "quote_won_reason_id": 3,
  "winner_quote_ids": [88]
}
```

`won_at` por defecto es hoy y no puede ser anterior a la última actividad. `quote_won_reason_id` sale de [motivos de ganado](#motivos-de-ganado-get). Si hay más de una cotización ligada, `winner_quote_ids` tiene que ser un subconjunto no vacío de esas cotizaciones.

## Marcar perdida <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests/:id/mark_as_lost
```

```json
{
  "lost_at": "2026-10-05",
  "quote_lost_reason_id": 7,
  "result_notes": "Se fue con otra tarifa",
  "confirm_quote_loss_consequences": true
}
```

`quote_lost_reason_id` sale de [motivos de perdido](#motivos-de-perdido-get). Si al perder la solicitud también se pierden cotizaciones ligadas, `confirm_quote_loss_consequences` tiene que ser `true` o `"1"`. Si no, **422**.

## Reabrir <span class="badge badge-info">POST</span>

```
POST /api/v1/quote_requests/:id/reopen
```

Quita el resultado de ganada o perdida. No lleva cuerpo.

## Eliminar una solicitud <span class="badge badge-danger">DELETE</span>

```
DELETE /api/v1/quote_requests/:id
```

Respuesta con `{ "message": "..." }`.
