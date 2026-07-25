# Operaciones

Las operaciones representan procesos completos de freight forwarding (importación, exportación, transporte doméstico, etc.).

## Objeto Operation

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| identification | string | Identificador legible (ej: "IMP-001-2024") |
| kind | string | Tipo: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company`, `import_trading_company` |
| mode | string | Modo de transporte: `land`, `aerial`, `maritime` |
| status | string | Estado: `confirmed`, `active`, `finished`, `closed`, `canceled` |
| client_ref | string | Referencia del cliente |
| contact | object | Cliente de la operación |
| currency | object | Moneda de la operación |
| operational_agent | object | Agente operativo asignado |
| profit_amount | decimal | Monto de ganancia |
| profit_percentage | decimal | Porcentaje de ganancia |
| services_count | integer | Número de servicios asociados |
| comments_count | integer | Número de comentarios |
| tasks_count | integer | Número de tareas |
| folders_count | integer | Número de carpetas de documentos |
| goods_description | string | Descripción de la mercancía |
| incoterm | string | INCOTERM aplicable |
| service_scope | string | Alcance del servicio (enum; ej: `door_to_door`, `port_cy_to_port_cy`, `airport_to_airport`) |
| economic_month | date | Mes económico (primer día del mes; acepta fecha parseable) |
| regime | string | Régimen aduanero (texto libre) |
| income_amount | decimal | Ingresos |
| expense_amount | decimal | Gastos |
| quote_external_id | string | ID externo de cotización |
| nomenclature | string | Nomenclatura / fracción arancelaria |
| tags | array | Etiquetas (`tag_list` al crear/actualizar) |
| services | array | Servicios completos (solo en show); cada servicio incluye `cost_centers` |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Operaciones <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations
```

> Ejemplo de llamada

```shell
curl "https://control.apunto.io/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://control.apunto.io/api/v1/operations')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'

response = http.request(request)
puts response.body
```

```python
import requests

url = "https://control.apunto.io/api/v1/operations"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/operations', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON

```json
{
  "operations": [
    {
      "id": 123,
      "identification": "IMP-001-2024",
      "kind": "importation",
      "mode": "maritime",
      "status": "active",
      "client_ref": "REF-001",
      "contact": {
        "alias": "ACME",
        "name": "ACME SA DE CV"
      },
      "currency": {
        "code": "MXN",
        "name": "Peso Mexicano"
      },
      "operational_agent": {
        "email": "agente@apunto.com",
        "name": "Juan Pérez"
      },
      "profit_amount": 5000.00,
      "profit_percentage": 15.5,
      "services_count": 3,
      "comments_count": 8,
      "tasks_count": 5,
      "folders_count": 2,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 25,
    "total": 150
  }
}
```

Retorna una lista paginada de operaciones de la cuenta.

### Parámetros Query

| Parámetro | Descripción |
|-----------|-------------|
| page | Número de página (default: 1) |
| per_page | Registros por página (default: 25, max: 100) |

## Buscar Operaciones <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/search
```

Búsqueda ligera (máximo **20** resultados) por `identification`, `client_ref`, `goods_description` o `number`. Usada por integraciones (p. ej. extensión de Chrome) para elegir destino al subir adjuntos.

### Parámetros Query

| Parámetro | Descripción |
|-----------|-------------|
| q | Texto de búsqueda (opcional; sin `q` devuelve las 20 operaciones más recientes por `updated_at`) |

> Respuesta JSON

```json
{
  "operations": [
    {
      "id": 123,
      "identification": "IMP-001-2024",
      "number": 1,
      "client_ref": "REF-001",
      "kind": "importation",
      "mode": "maritime",
      "status": "active",
      "goods_description": "Maquinaria",
      "contact_name": "ACME",
      "updated_at": "2024-01-15T10:30:00Z",
      "services": [
        { "id": 789, "identification": "SRV-001", "mode": "maritime", "status": "active" }
      ]
    }
  ]
}
```

## Obtener una Operación <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl "https://control.apunto.io/api/v1/operations/123" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "operation": {
    "id": 123,
    "identification": "IMP-001-2024",
    "kind": "importation",
    "mode": "maritime",
    "status": "active",
    "client_ref": "REF-001",
    "contact": {
      "alias": "ACME",
      "name": "ACME SA DE CV"
    },
    "currency": {
      "code": "MXN",
      "name": "Peso Mexicano"
    },
    "goods_description": "Maquinaria industrial",
    "incoterm": "FOB",
    "service_scope": "door_to_door",
    "quote_external_id": "QT-12345",
    "nomenclature": "8479.89.99",
    "profit_amount": 5000.00,
    "profit_percentage": 15.5,
    "services_count": 3,
    "comments_count": 8,
    "tasks_count": 5,
    "folders_count": 2,
    "tags": ["urgente", "cliente-vip"],
    "to_dos": [
      {
        "id": 55,
        "title": "Revisar documentación",
        "completed": false,
        "required": true,
        "start_at": null,
        "end_at": "2024-01-20T18:00:00Z"
      }
    ],
    "folders": [
      {
        "id": 10,
        "name": "BL",
        "parent_id": null,
        "files_count": 1,
        "attachments": [
          {
            "id": 501,
            "filename": "bl.pdf",
            "byte_size": 245000,
            "content_type": "application/pdf",
            "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/..."
          }
        ],
        "children": []
      }
    ],
    "services": [
      {
        "id": 789,
        "identification": "SRV-001-2024",
        "mode": "maritime",
        "status": "active",
        "shipment_type": "fcl",
        "shipment_kind": "international",
        "supplier": {
          "alias": "MAERSK",
          "name": "Maersk Line"
        },
        "eta_date": "2024-02-15",
        "etd_date": "2024-01-20",
        "bl": "BL123456",
        "booking": "BOOK789",
        "cost_centers": [
          {
            "id": 901,
            "concept": "Flete marítimo",
            "quantity": 1,
            "income_amount": 15000,
            "expense_amount": 9000,
            "profit_amount": 6000,
            "profit_percentage": 40.0,
            "currency": { "code": "MXN", "name": "Peso Mexicano" },
            "supplier": { "id": 111, "alias": "MAERSK", "name": "Maersk Line" },
            "linked": {
              "quote_line_item_id": null,
              "invoice_line_item_id": null,
              "bill_line_item_id": null
            }
          }
        ]
      }
    ],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

Retorna los detalles completos de una operación específica.

<aside class="notice">
<strong>Importante</strong>: El endpoint <code>show</code> incluye <strong>servicios</strong> (con <strong>centro de costos</strong> en <code>cost_centers</code> por servicio), <strong>tareas</strong> (<code>to_dos</code>) y <strong>carpetas con archivos</strong> (<code>folders</code>). En <code>index</code> solo verás contadores (<code>services_count</code>, <code>tasks_count</code>, <code>folders_count</code>).
</aside>

<aside class="notice">
Documentos: subida y gestión vía <a href="#documentos-carpetas-y-archivos">Documentos (carpetas y archivos)</a> y tareas vía <a href="#tareas-to-dos">Tareas</a>.
</aside>

## Crear Operación <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations
```

> Ejemplo de llamada

```shell
curl -X POST "https://control.apunto.io/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "contact_code": "ACME",
      "currency_code": "MXN",
      "operational_agent_email": "agente@apunto.com",
      "kind": "importation",
      "mode": "maritime",
      "client_ref": "REF-001",
      "goods_description": "Maquinaria industrial",
      "incoterm": "FOB"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://control.apunto.io/api/v1/operations')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  operation: {
    contact_code: 'ACME',
    currency_code: 'MXN',
    operational_agent_email: 'agente@apunto.com',
    kind: 'importation',
    mode: 'maritime'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://control.apunto.io/api/v1/operations"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "operation": {
        "contact_code": "ACME",
        "currency_code": "MXN",
        "operational_agent_email": "agente@apunto.com",
        "kind": "importation",
        "mode": "maritime"
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/operations', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    operation: {
      contact_code: 'ACME',
      currency_code: 'MXN',
      operational_agent_email: 'agente@apunto.com',
      kind: 'importation',
      mode: 'maritime'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON (201 Created)

```json
{
  "operation": {
    "id": 124,
    "identification": "IMP-002-2024",
    "kind": "importation",
    "mode": "maritime",
    "status": "confirmed",
    "client_ref": "REF-001",
    "goods_description": "Maquinaria industrial",
    "incoterm": "FOB",
    "created_at": "2024-01-16T09:15:00Z"
  },
  "message": "Operación creada exitosamente"
}
```

Crea una nueva operación.

### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| contact_code | string | Sí | Código (alias) del contacto |
| currency_code | string | No | Código de moneda (default: MXN) |
| operational_agent_email | string | No | Email del agente operativo |
| kind | string | Sí | Tipo de operación |
| mode | string | Sí | Modo de transporte |
| client_ref | string | No | Referencia del cliente |
| goods_description | string | No | Descripción de mercancía |
| incoterm | string | No | INCOTERM |
| service_scope | string | No | Alcance (`door_to_door`, `port_cy_to_port_cy`, etc.) |
| status | string | No | Estado inicial (default del modelo: `confirmed`) |
| profit_amount | decimal | No | Ganancia |
| profit_percentage | decimal | No | Margen % |
| income_amount | decimal | No | Ingresos |
| expense_amount | decimal | No | Gastos |
| regime | string | No | Régimen |
| quote_external_id | string | No | Referencia externa de cotización |
| nomenclature | string | No | Nomenclatura |
| economic_month | string | No | Mes económico (fecha parseable → primer día del mes) |
| tag_list | array | No | Etiquetas |

### Valores Permitidos

**kind**: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company`, `import_trading_company`

**mode**: `land`, `aerial`, `maritime`

**status**: `confirmed`, `active`, `finished`, `closed`, `canceled`

**service_scope**: valores dependen del modo de transporte (p. ej. `door_to_door`, `door_to_port_cy`, `port_cy_to_port_cy`, `airport_to_airport`, `door_to_door`). Ver enum completo en el modelo `Operation`.

## Actualizar Operación <span class="badge badge-warning">PUT</span>

> Definición

```
PUT /api/v1/operations/:id
PATCH /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://control.apunto.io/api/v1/operations/123" \
  -H "Authorization": Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "status": "active",
      "client_ref": "REF-001-UPDATED"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://control.apunto.io/api/v1/operations/123')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Put.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  operation: {
    status: 'active',
    client_ref: 'REF-001-UPDATED'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://control.apunto.io/api/v1/operations/123"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "operation": {
        "status": "active",
        "client_ref": "REF-001-UPDATED"
    }
}

response = requests.put(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/operations/123', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    operation: {
      status: 'active',
      client_ref: 'REF-001-UPDATED'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON

```json
{
  "operation": {
    "id": 123,
    "identification": "IMP-001-2024",
    "status": "active",
    "client_ref": "REF-001-UPDATED",
    "updated_at": "2024-01-16T10:45:00Z"
  },
  "message": "Operación actualizada exitosamente"
}
```

Actualiza una operación existente.

## Eliminar Operación <span class="badge badge-danger">DELETE</span>

> Definición

```
DELETE /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://control.apunto.io/api/v1/operations/123" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Operación eliminada exitosamente"
}
```

Elimina la operación y marca sus servicios asociados como eliminados (`deleted_at`). Requiere permisos de cuenta.

## Cerrar operación <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:id/close
```

Cierra la operación cuando **ningún servicio** está en estado `active` o `finished` (todos deben estar `closed` o `canceled`). Equivalente a la acción web de cierre.

> Respuesta JSON

```json
{
  "operation": { "id": 123, "status": "closed" },
  "message": "Operación cerrada exitosamente"
}
```

Si aún hay servicios activos o en proceso, responde **422** con `errors` y `message`.

## Reabrir operación <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:id/reopen
```

Reabre una operación en estado `finished` o `closed` y la regresa a `active` (evento AASM `reopen`).

## Cancelar operación <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:id/cancel
```

Cancela la operación solo si **todos** sus servicios ya están en estado `canceled`.

Consulta los motivos disponibles con `GET /api/v1/operation_cancellation_reasons` (ver [Motivos de cancelación](#motivos-de-cancelacion)).

### Parámetros (body JSON, raíz)

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| canceled_at | date | No | Fecha de cancelación (default: hoy; en la web el formulario la marca como obligatoria) |
| operation_cancellation_reason_id | integer | Condicional | ID del motivo — **obligatorio si la cuenta tiene motivos activos** |
| operation_cancellation_reason_name | string | Condicional | Alternativa al id: nombre del motivo (ej. `Cliente canceló`) |
| cancellation_notes | string | No | Notas adicionales |

Si la cuenta tiene motivos configurados, debes enviar **id o name**. Si no hay catálogo, el motivo es opcional.

> Respuesta JSON

```json
{
  "operation": { "id": 123, "status": "canceled" },
  "message": "Operación cancelada exitosamente"
}
```

## Centro de costos agregado <span class="badge badge-success">GET</span>

```
GET /api/v1/operations/:operation_id/cost_centers
```

Listado paginado de todas las líneas de ingreso/gasto de los servicios de la operación. CRUD completo bajo `/services/:service_id/cost_centers` (ver [Centro de costos](#centro-de-costos-costcenter)).

## Generar factura o factura de proveedor <span class="badge badge-info">POST</span>

```
POST /api/v1/operations/:id/generate_invoice
POST /api/v1/operations/:id/generate_bill
```

Body: `{ "cost_center_ids": [1, 2], ... }`. Para `generate_invoice`, incluye códigos CFDI en cuentas MX. Detalle en [Facturas y facturas de proveedor](#facturas-y-facturas-de-proveedor).

## Carpetas de documentos

Listar árbol con archivos:

```
GET /api/v1/operations/:operation_id/folders
POST /api/v1/operations/:operation_id/folders
```

Subir / actualizar / eliminar archivos: ver sección **Documentos** en la documentación.

## Comentarios de Operación

Los comentarios están anidados bajo las operaciones. Ver [Comentarios](#comentarios-messages) para más detalles.

```
GET    /api/v1/operations/:operation_id/messages
POST   /api/v1/operations/:operation_id/messages
PUT    /api/v1/operations/:operation_id/messages/:id
DELETE /api/v1/operations/:operation_id/messages/:id
```

## Tareas de Operación

Las tareas están anidadas bajo las operaciones. Ver [Tareas](#tareas-to-dos) para CRUD completo.

```
GET    /api/v1/operations/:operation_id/to_dos
POST   /api/v1/operations/:operation_id/to_dos
PATCH  /api/v1/operations/:operation_id/to_dos/:id
POST   /api/v1/operations/:operation_id/to_dos/:id/complete
DELETE /api/v1/operations/:operation_id/to_dos/:id
```
