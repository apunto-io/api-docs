# Cotizaciones

La cotización es el documento que ve el cliente. Puede nacer directo, o desde una [solicitud comercial](#crear-la-cotizacion-post) con `POST /quote_requests/:id/create_quote`. Cuando está abierta se puede convertir en [operación](#operaciones).

El alta deja la cotización en `drafted` y asigna como dueño al usuario del token. El contacto es obligatorio. Si no mandas moneda, usa la moneda por defecto de la cuenta. Si no mandas `exchange_rate`, queda `1.0`.

## Objeto Quote

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID interno |
| identification | string | Folio |
| status | string | Estatus del documento |
| kind | string | Tipo de documento |
| date | date | Fecha |
| due_at | date | Vigencia |
| subtotal | number | Subtotal |
| total | number | Total |
| exchange_rate | number | Tipo de cambio |
| contact | object | `{ id, alias, name }` |
| currency | object | `{ id, code, name }`. `code` es el ISO |
| owner | object | `{ id, name, email }` |
| seller | object | `{ id, name, email }` |
| operation_kind | string | Tipo de operación |
| operation_mode | string | Modo de operación |
| service_scope | string | Alcance |
| incoterm | string | Incoterm |
| client_ref | string | Referencia del cliente |
| created_at | datetime | Alta |
| updated_at | datetime | Último cambio |

El detalle agrega `description`, `tags`, `origin_address`, `destination_address`, `line_items_count` y `document_routes_count`.

El camino de aprobación que expone la API es:

`drafted` → `POST /quotes/:id/approve` → `approval_requested` → `POST /quotes/:id/open` → `opened`

Una cotización ya guardada también puede estar en `need_review`, `sent`, `viewed`, `partial`, `paid`, `voided`, `won`, `lose` o `invoiced`. Esos valores se leen; `approve` y `open` no saltan a ellos.

`operation_kind`, `operation_mode` y `service_scope` usan las mismas claves que en [solicitudes comerciales](#objeto-quoterequest).

## Listar cotizaciones <span class="badge badge-success">GET</span>

```
GET /api/v1/quotes
```

```shell
curl "https://control.apunto.io/api/v1/quotes?status=drafted" \
  -H "Authorization: Bearer TU_TOKEN"
```

| Parámetro | Descripción |
|-----------|-------------|
| status | Filtra por estatus |
| page | Página, default 1 |
| per_page | Default 25, máximo 100 |

La respuesta es `{ "quotes": [ ... ], "pagination": { "page", "per_page", "total" } }`.

## Obtener una cotización <span class="badge badge-success">GET</span>

```
GET /api/v1/quotes/:id
```

## Crear una cotización <span class="badge badge-info">POST</span>

```
POST /api/v1/quotes
```

```shell
curl -X POST "https://control.apunto.io/api/v1/quotes" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote": {
      "contact_code": "ACME",
      "currency_code": "MXN",
      "seller_email": "ana@apunto.com",
      "operation_kind": "importation",
      "operation_mode": "maritime",
      "incoterm": "FOB",
      "client_ref": "REF-001"
    }
  }'
```

```ruby
request.body = {
  quote: {
    contact_code: "ACME",
    currency_code: "MXN",
    seller_email: "ana@apunto.com",
    operation_kind: "importation",
    operation_mode: "maritime",
    incoterm: "FOB",
    client_ref: "REF-001"
  }
}.to_json
```

```python
requests.post(
    "https://control.apunto.io/api/v1/quotes",
    headers={"Authorization": "Bearer TU_TOKEN"},
    json={
        "quote": {
            "contact_code": "ACME",
            "currency_code": "MXN",
            "operation_kind": "importation",
            "operation_mode": "maritime",
            "incoterm": "FOB",
            "client_ref": "REF-001",
        }
    },
)
```

```javascript
await fetch("https://control.apunto.io/api/v1/quotes", {
  method: "POST",
  headers: {
    Authorization: "Bearer TU_TOKEN",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    quote: {
      contact_code: "ACME",
      currency_code: "MXN",
      operation_kind: "importation",
      operation_mode: "maritime",
      incoterm: "FOB",
      client_ref: "REF-001"
    }
  })
});
```

Un contacto que es solo prospecto no se puede convertir después en operación. Para ese paso el contacto tiene que ser cliente.

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| contact_id | Sí, o `contact_code` | ID del contacto |
| contact_code | Sí, o `contact_id` | Alias del contacto |
| currency_id | No | ID de la moneda |
| currency_code | No | ISO, por ejemplo `MXN` o `USD` |
| date | No | Fecha |
| due_at | No | Vigencia |
| description | No | Descripción |
| operation_kind | No | Tipo de operación. Hace falta antes de crear la operación |
| operation_mode | No | Modo. Hace falta antes de crear la operación |
| exchange_rate | No | Tipo de cambio. Default `1.0` |
| hide_exchange_rate | No | Oculta el tipo de cambio |
| hide_expense_account | No | Oculta la cuenta de gasto |
| origin_address_id | No | Dirección de origen |
| destination_address_id | No | Dirección de destino |
| incoterm | No | Incoterm |
| service_scope | No | Alcance |
| seller_id | No | ID del vendedor |
| seller_email | No | Correo del vendedor |
| client_ref | No | Referencia del cliente |
| status | No | El alta lo fuerza a `drafted` |
| tag_list | No | Etiquetas |
| document_routes_attributes | No | Rutas: `address_id`, `port_data_id`, `address_kind`, `address_type`, `location_name`, `position`, `description` |

Respuesta **201** con `{ "quote": { ... }, "message": "..." }`.

## Actualizar una cotización <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/quotes/:id
```

Mismo cuerpo `{ "quote": { ... } }`.

## Pedir aprobación <span class="badge badge-info">POST</span>

```
POST /api/v1/quotes/:id/approve
```

Solo desde `drafted`. Pasa a `approval_requested`. Si el estatus no es `drafted`, responde **422**.

## Abrir <span class="badge badge-info">POST</span>

```
POST /api/v1/quotes/:id/open
```

Solo desde `approval_requested`. Pasa a `opened`.

## Clonar <span class="badge badge-info">POST</span>

```
POST /api/v1/quotes/:id/clone
```

Copia la cotización a un borrador nuevo. Respuesta **201** con `{ "quote": { ... }, "message": "..." }`.

## Convertir en operación <span class="badge badge-info">POST</span>

```
POST /api/v1/quotes/:id/create_operation
```

Crea una operación nueva, o liga la cotización a una que ya existe. El contacto no puede ser solo prospecto. La cotización tiene que traer `operation_kind` y `operation_mode`.

Operación nueva (el default):

```json
{
  "operation_type": "new",
  "visibility_scope": "everyone"
}
```

`visibility_scope` acepta `everyone` (default) o `group`. Con `group` manda `work_group_id`.

Operación existente:

```json
{
  "operation_type": "existing",
  "existing_operation_id": 540
}
```

La operación tiene que ser de la misma cuenta, del mismo contacto y estar `confirmed` o `active`.

Para repartir partidas y carga puedes mandar, en el mismo cuerpo:

| Campo | Descripción |
|-------|-------------|
| line_items_to_services | Partidas que se van a servicios ya existentes |
| new_services | Servicios nuevos a crear |
| line_items_to_new_services | Partidas que se van a esos servicios nuevos |
| line_items_links | Liga partidas entre sí |
| shipment_items_to_service_groups | Carga hacia grupos de servicio |
| shipment_items_to_services | Carga hacia servicios existentes |
| shipment_items_to_new_services | Carga hacia servicios nuevos |

Si la operación es nueva, la respuesta es **201**. Si se liga a una existente, **200**. El cuerpo trae `operation` con `id`, `identification`, `kind`, `mode`, `status`, `client_ref` y `contact`, más `message`. Un rechazo (prospecto, sin tipo o modo, operación ajena) es **422** con `errors`.

## Eliminar una cotización <span class="badge badge-danger">DELETE</span>

```
DELETE /api/v1/quotes/:id
```

Respuesta con `{ "message": "..." }`.
