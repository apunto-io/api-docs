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
| shipment_kind | string | Clase: `national`, `international` |
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
curl "https://control.apunto.io/api/v1/services" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://control.apunto.io/api/v1/services')
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

url = "https://control.apunto.io/api/v1/services"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/services', {
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
| operation_id | Filtrar servicios de una operación |

## Obtener un Servicio <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/services/:id
```

> Ejemplo de llamada

```shell
curl "https://control.apunto.io/api/v1/services/789" \
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

Retorna los detalles completos de un servicio específico. Incluye arrays `to_dos` y `folders` (igual que operaciones). En `index` solo hay contadores.

<aside class="notice">
Documentos y tareas: ver <a href="#documentos-carpetas-y-archivos">Documentos</a> y <a href="#tareas-to-dos">Tareas</a>.
</aside>

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
curl -X POST "https://control.apunto.io/api/v1/services" \
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

uri = URI('https://control.apunto.io/api/v1/services')
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

url = "https://control.apunto.io/api/v1/services"
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
fetch('https://control.apunto.io/api/v1/services', {
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
| pickup_date | date | No | Recolección |
| delivery_date | date | No | Entrega |
| customs_agent_code | string | No | Alias del agente aduanal |
| customs_address_code | string | No | Alias de dirección aduanal (cuenta) |
| customs_reference | string | No | Referencia aduanal |
| dispatch_appointment_at | datetime | No | Cita de despacho |
| observations | string | No | Observaciones |
| guide_number | string | No | Guía |
| flight_number | string | No | Vuelo |
| awb_number | string | No | AWB |
| airline_name | string | No | Aerolínea |
| shipping_line_name | string | No | Naviera |
| mbl, hbl, mawb, hawb | string | No | Documentos de transporte |
| pedimento, carta_porte, manifiesto_carga | string | No | Campos aduana/terrestre |
| status | string | No | Estado |
| tag_list | array | No | Etiquetas |

### Valores Permitidos

**mode**: `land`, `aerial`, `maritime`, `customs`

**status**: `active`, `finished`, `closed`, `canceled`

**shipment_kind**: `national`, `international`

**shipment_type**: cadena según modo (marítimo: `fcl`, `lcl`, …; terrestre: `ltl`, `ftl`, …; aéreo: `std`, `eco`, …). No es un enum cerrado de cuatro valores; debe coincidir con los tipos configurados en la aplicación.

## Actualizar Servicio <span class="badge badge-warning">PUT</span>

> Definición

```
PUT /api/v1/services/:id
PATCH /api/v1/services/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://control.apunto.io/api/v1/services/789" \
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

uri = URI('https://control.apunto.io/api/v1/services/789')
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

url = "https://control.apunto.io/api/v1/services/789"
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
fetch('https://control.apunto.io/api/v1/services/789', {
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
curl -X DELETE "https://control.apunto.io/api/v1/services/789" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Servicio eliminado exitosamente"
}
```

Marca el servicio como eliminado (`deleted_at`); no borra físicamente el registro.

## Finalizar servicio <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/services/:id/finish
```

Pasa el servicio de `active` a `finished` (misma acción que **Finalizar** en la web). Es el paso previo habitual antes de **cerrar**.

## Cerrar servicio <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/services/:id/close
```

Cierra un servicio en estado `finished` (`finished` → `closed`). En servicios **terrestres** (`mode: land`) puede requerir tarea POD aprobada; si no, responde **422** con mensaje de POD.

## Reabrir servicio <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/services/:id/reopen
```

Reabre un servicio en `finished` o `closed` y lo regresa a `active`.

## Cancelar servicio <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/services/:id/cancel
```

Cancela un servicio (`active` o `finished` → `canceled`). Recalcula utilidad de la operación padre. Falla con **422** si hay facturas vinculadas que bloquean la cancelación.

### Parámetros (body JSON, raíz)

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| canceled_at | date | No | Fecha de cancelación (default: hoy) |
| service_cancellation_reason_id | integer | No | ID del motivo configurado en la cuenta |
| cancellation_notes | string | No | Notas adicionales |

> Respuesta JSON

```json
{
  "service": { "id": 789, "status": "canceled" },
  "message": "Servicio cancelado exitosamente"
}
```

## Carpetas de documentos

```
GET /api/v1/services/:service_id/folders
```

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
