# Operaciones

Las operaciones representan procesos completos de freight forwarding (importación, exportación, transporte doméstico, etc.).

## Objeto Operation

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| identification | string | Identificador legible (ej: "IMP-001-2024") |
| kind | string | Tipo: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting` |
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
| service_scope | string | Alcance del servicio (ej: `door_to_door`, `port_to_port`) |
| services | array | Servicios completos (solo en show) |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Operaciones

> Definición

```
GET /api/v1/operations
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://tu-dominio.com/api/v1/operations')
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

url = "https://tu-dominio.com/api/v1/operations"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/operations', {
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

## Obtener una Operación

> Definición

```
GET /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/operations/123" \
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
        "booking": "BOOK789"
      }
    ],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

Retorna los detalles completos de una operación específica.

<aside class="notice">
<strong>Importante</strong>: El endpoint <code>show</code> incluye los <strong>servicios completos anidados</strong>, mientras que el <code>index</code> solo incluye contadores (<code>services_count</code>, <code>comments_count</code>, etc.) para optimizar el rendimiento en listas grandes.
</aside>

## Crear Operación

> Definición

```
POST /api/v1/operations
```

> Ejemplo de llamada

```shell
curl -X POST "https://tu-dominio.com/api/v1/operations" \
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
| service_scope | string | No | Alcance del servicio |
| tag_list | array | No | Lista de etiquetas |

### Valores Permitidos

**kind**: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company`, `import_trading_company`

**mode**: `land`, `aerial`, `maritime`

**status**: `confirmed`, `active`, `finished`, `closed`, `canceled`

## Actualizar Operación

> Definición

```
PUT /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://tu-dominio.com/api/v1/operations/123" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "status": "active",
      "client_ref": "REF-001-UPDATED"
    }
  }'
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

## Eliminar Operación

> Definición

```
DELETE /api/v1/operations/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://tu-dominio.com/api/v1/operations/123" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Operación eliminada exitosamente"
}
```

Elimina una operación y todos sus servicios asociados.

## Comentarios de Operación

Los comentarios están anidados bajo las operaciones. Ver [Comentarios](#comentarios-messages) para más detalles.

```
GET    /api/v1/operations/:operation_id/messages
POST   /api/v1/operations/:operation_id/messages
PUT    /api/v1/operations/:operation_id/messages/:id
DELETE /api/v1/operations/:operation_id/messages/:id
```

## Tareas de Operación

Las tareas están anidadas bajo las operaciones. Ver [Tareas](#tareas-to-dos) para más detalles.

```
GET    /api/v1/operations/:operation_id/to_dos
POST   /api/v1/operations/:operation_id/to_dos
PUT    /api/v1/operations/:operation_id/to_dos/:id
POST   /api/v1/operations/:operation_id/to_dos/:id/complete
DELETE /api/v1/operations/:operation_id/to_dos/:id
```
