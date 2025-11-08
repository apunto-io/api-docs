# Servicios

Los servicios representan los componentes logísticos individuales dentro de una operación (transporte marítimo, aéreo, terrestre, aduanas, etc.).

## Objeto Service

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| identification | string | Identificador legible (ej: "SRV-001-2024") |
| mode | string | Modo: `land`, `aerial`, `maritime`, `customs` |
| status | string | Estado: `active`, `finished`, `closed`, `canceled` |
| shipment_type | string | Tipo de envío (ej: `fcl`, `lcl`) |
| shipment_kind | string | Clase de envío (ej: `international`, `domestic`) |
| operation | object | Operación padre (anidada) |
| supplier | object | Proveedor del servicio (anidado) |
| service_agent | object | Agente de servicio (anidado) |
| eta_date | date | Fecha estimada de arribo |
| etd_date | date | Fecha estimada de salida |
| pickup_date | date | Fecha de recolección |
| delivery_date | date | Fecha de entrega |
| comments_count | integer | Número de comentarios |
| tasks_count | integer | Número de tareas |
| folders_count | integer | Número de carpetas de documentos |
| bl | string | Bill of Lading |
| booking | string | Número de reserva |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Servicios <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/services
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/services" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://tu-dominio.com/api/v1/services')
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

url = "https://tu-dominio.com/api/v1/services"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/services', {
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
  "services": [
    {
      "id": 789,
      "identification": "SRV-001-2024",
      "mode": "maritime",
      "status": "active",
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "operation": {
        "id": 123,
        "identification": "IMP-001-2024",
        "kind": "importation",
        "client_ref": "REF-001"
      },
      "supplier": {
        "id": 111,
        "alias": "MAERSK",
        "name": "Maersk Line"
      },
      "service_agent": {
        "id": 222,
        "email": "agente@apunto.com",
        "name": "María López"
      },
      "eta_date": "2024-02-15",
      "etd_date": "2024-01-20",
      "pickup_date": "2024-01-18",
      "delivery_date": "2024-02-17",
      "comments_count": 3,
      "tasks_count": 2,
      "folders_count": 1,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 25,
    "total": 85
  }
}
```

Retorna una lista paginada de servicios de la cuenta.

### Parámetros Query

| Parámetro | Descripción |
|-----------|-------------|
| page | Número de página (default: 1) |
| per_page | Registros por página (default: 25, max: 100) |

## Obtener un Servicio <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/services/:id
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/services/789" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "service": {
    "id": 789,
    "identification": "SRV-001-2024",
    "mode": "maritime",
    "status": "active",
    "shipment_type": "fcl",
    "shipment_kind": "international",
    "operation": {
      "id": 123,
      "identification": "IMP-001-2024",
      "kind": "importation",
      "client_ref": "REF-001"
    },
    "supplier": {
      "id": 111,
      "alias": "MAERSK",
      "name": "Maersk Line"
    },
    "service_agent": {
      "id": 222,
      "email": "agente@apunto.com",
      "name": "María López"
    },
    "bl": "BL123456",
    "booking": "BOOK789",
    "guide_number": null,
    "flight_number": null,
    "awb_number": null,
    "airline_name": null,
    "shipping_line_name": "Maersk",
    "customs_agent": {
      "id": 333,
      "alias": "ADUANAS-MX",
      "name": "Aduanas México SA"
    },
    "customs_address": {
      "id": 444,
      "alias": "ADUANA-VERACRUZ",
      "name": "Aduana Veracruz",
      "address_type": "customs",
      "full_address": "Puerto de Veracruz, Veracruz, México"
    },
    "customs_reference": "REF-ADU-001",
    "dispatch_appointment_at": "2024-02-16T09:00:00Z",
    "observations": "Requiere inspección especial",
    "eta_date": "2024-02-15",
    "etd_date": "2024-01-20",
    "pickup_date": "2024-01-18",
    "delivery_date": "2024-02-17",
    "mbl": "MBL123",
    "hbl": "HBL456",
    "mawb": null,
    "hawb": null,
    "pedimento": "24-01-1234-5678901",
    "carta_porte": null,
    "manifiesto_carga": "MAN-001",
    "comments_count": 3,
    "tasks_count": 2,
    "folders_count": 1,
    "tags": ["urgente", "refrigerado"],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

Retorna los detalles completos de un servicio específico.

<aside class="notice">
Nota: Los campos <code>operation</code>, <code>supplier</code>, <code>service_agent</code>, <code>customs_agent</code> y <code>customs_address</code> retornan objetos completos anidados con toda su información relevante, no solo IDs.
</aside>

## Crear Servicio <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/services
```

> Ejemplo de llamada

```shell
curl -X POST "https://tu-dominio.com/api/v1/services" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "operation_id": 123,
      "supplier_code": "MAERSK",
      "service_agent_email": "agente@apunto.com",
      "mode": "maritime",
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "bl": "BL123456",
      "booking": "BOOK789"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://tu-dominio.com/api/v1/services')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  service: {
    operation_id: 123,
    supplier_code: 'MAERSK',
    service_agent_email: 'agente@apunto.com',
    mode: 'maritime'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://tu-dominio.com/api/v1/services"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "service": {
        "operation_id": 123,
        "supplier_code": "MAERSK",
        "service_agent_email": "agente@apunto.com",
        "mode": "maritime"
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/services', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    service: {
      operation_id: 123,
      supplier_code: 'MAERSK',
      service_agent_email: 'agente@apunto.com',
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
  "service": {
    "id": 790,
    "identification": "SRV-002-2024",
    "mode": "maritime",
    "status": "active",
    "operation": {
      "id": 123,
      "identification": "IMP-001-2024",
      "kind": "importation",
      "client_ref": "REF-001"
    },
    "supplier": {
      "id": 111,
      "alias": "MAERSK",
      "name": "Maersk Line"
    },
    "bl": "BL123456",
    "booking": "BOOK789",
    "created_at": "2024-01-16T09:15:00Z"
  },
  "message": "Servicio creado exitosamente"
}
```

Crea un nuevo servicio dentro de una operación.

### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| operation_id | integer | Sí | ID de la operación padre |
| supplier_code | string | No | Código (alias) del proveedor |
| service_agent_email | string | No | Email del agente de servicio |
| mode | string | Sí | Modo de transporte |
| shipment_type | string | No | Tipo de envío |
| shipment_kind | string | No | Clase de envío |
| bl | string | No | Bill of Lading |
| booking | string | No | Número de reserva |
| eta_date | date | No | Fecha estimada de arribo |
| etd_date | date | No | Fecha estimada de salida |

### Valores Permitidos

**mode**: `land`, `aerial`, `maritime`, `customs`

**status**: `active`, `finished`, `closed`, `canceled`

**shipment_type**: `fcl`, `lcl`, `air`, `truck`

**shipment_kind**: `international`, `domestic`

## Actualizar Servicio <span class="badge badge-warning">PUT</span>

> Definición

```
PUT /api/v1/services/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://tu-dominio.com/api/v1/services/789" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "status": "finished",
      "eta_date": "2024-02-14"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://tu-dominio.com/api/v1/services/789')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Put.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  service: {
    status: 'finished',
    eta_date: '2024-02-14'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://tu-dominio.com/api/v1/services/789"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "service": {
        "status": "finished",
        "eta_date": "2024-02-14"
    }
}

response = requests.put(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/services/789', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    service: {
      status: 'finished',
      eta_date: '2024-02-14'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON

```json
{
  "service": {
    "id": 789,
    "identification": "SRV-001-2024",
    "status": "finished",
    "eta_date": "2024-02-14",
    "updated_at": "2024-01-16T10:45:00Z"
  },
  "message": "Servicio actualizado exitosamente"
}
```

Actualiza un servicio existente.

## Eliminar Servicio <span class="badge badge-danger">DELETE</span>

> Definición

```
DELETE /api/v1/services/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://tu-dominio.com/api/v1/services/789" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Servicio eliminado exitosamente"
}
```

Elimina un servicio.

## Comentarios de Servicio

Los comentarios están anidados bajo los servicios. Ver [Comentarios](#comentarios-messages) para más detalles.

```
GET    /api/v1/services/:service_id/messages
POST   /api/v1/services/:service_id/messages
PUT    /api/v1/services/:service_id/messages/:id
DELETE /api/v1/services/:service_id/messages/:id
```

## Tareas de Servicio

Las tareas están anidadas bajo los servicios. Ver [Tareas](#tareas-to-dos) para más detalles.

```
GET    /api/v1/services/:service_id/to_dos
POST   /api/v1/services/:service_id/to_dos
PUT    /api/v1/services/:service_id/to_dos/:id
POST   /api/v1/services/:service_id/to_dos/:id/complete
DELETE /api/v1/services/:service_id/to_dos/:id
```
