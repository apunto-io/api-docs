# Tareas (To-Dos)

Las tareas permiten crear seguimiento y recordatorios asociados a operaciones, servicios y contactos. Están **anidados bajo sus recursos padre**.

## Objeto ToDo

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| title | string | Título de la tarea |
| description | text | Descripción detallada |
| start_at | datetime | Fecha de inicio |
| end_at | datetime | Fecha de fin |
| completed | boolean | Estado de completado |
| rejected | boolean | Si la tarea fue rechazada |
| required | boolean | Si la tarea es requerida |
| completed_at | datetime | Fecha de completado |
| owner | object | Usuario asignado a la tarea |
| completed_by | object | Usuario que completó la tarea |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Tareas <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:operation_id/to_dos
GET /api/v1/services/:service_id/to_dos
GET /api/v1/contacts/:contact_id/to_dos
```

> Ejemplo de llamada

```shell
# Tareas de una operación
curl "https://tu-dominio.com/api/v1/operations/123/to_dos" \
  -H "Authorization: Bearer TU_TOKEN"

# Tareas de un servicio
curl "https://tu-dominio.com/api/v1/services/789/to_dos" \
  -H "Authorization: Bearer TU_TOKEN"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://tu-dominio.com/api/v1/operations/123/to_dos')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'

response = http.request(request)
puts response.body
```

```python
import requests

url = "https://tu-dominio.com/api/v1/operations/123/to_dos"
headers = {"Authorization": "Bearer TU_TOKEN"}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/operations/123/to_dos', {
  headers: {'Authorization': 'Bearer TU_TOKEN'}
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON

```json
{
  "to_dos": [
    {
      "id": 321,
      "title": "Solicitar documentos al cliente",
      "start_at": "2024-01-15T10:00:00Z",
      "end_at": "2024-01-20T18:00:00Z",
      "completed": false,
      "rejected": false,
      "required": true,
      "completed_at": null,
      "owner": {
        "email": "operador@apunto.com",
        "name": "Carlos Ramírez"
      },
      "completed_by": null,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 25,
    "total": 8
  }
}
```

Retorna todas las tareas de un recurso específico.

### Parámetros Query

| Parámetro | Descripción |
|-----------|-------------|
| page | Número de página (default: 1) |
| per_page | Registros por página (default: 25, max: 100) |
| completed | Filtrar por estado: `true`, `false` |

## Obtener una Tarea <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:operation_id/to_dos/:id
GET /api/v1/services/:service_id/to_dos/:id
GET /api/v1/contacts/:contact_id/to_dos/:id
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/operations/123/to_dos/321" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "to_do": {
    "id": 321,
    "title": "Solicitar documentos al cliente",
    "start_at": "2024-01-15T10:00:00Z",
    "end_at": "2024-01-20T18:00:00Z",
    "completed": false,
    "rejected": false,
    "required": true,
    "completed_at": null,
    "owner": {
      "email": "operador@apunto.com",
      "name": "Carlos Ramírez"
    },
    "completed_by": null,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

Retorna una tarea específica.

## Crear Tarea <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:operation_id/to_dos
POST /api/v1/services/:service_id/to_dos
POST /api/v1/contacts/:contact_id/to_dos
```

> Ejemplo de llamada

```shell
curl -X POST "https://tu-dominio.com/api/v1/operations/123/to_dos" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "to_do": {
      "title": "Revisar documentación aduanal",
      "description": "Verificar que todos los documentos estén completos",
      "start_at": "2024-01-20T09:00:00Z",
      "end_at": "2024-01-25T18:00:00Z",
      "required": true
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://tu-dominio.com/api/v1/operations/123/to_dos')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  to_do: {
    title: 'Revisar documentación aduanal',
    description: 'Verificar que todos los documentos estén completos',
    start_at: '2024-01-20T09:00:00Z',
    end_at: '2024-01-25T18:00:00Z',
    required: true
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://tu-dominio.com/api/v1/operations/123/to_dos"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "to_do": {
        "title": "Revisar documentación aduanal",
        "description": "Verificar que todos los documentos estén completos",
        "start_at": "2024-01-20T09:00:00Z",
        "end_at": "2024-01-25T18:00:00Z",
        "required": true
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/operations/123/to_dos', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    to_do: {
      title: 'Revisar documentación aduanal',
      description: 'Verificar que todos los documentos estén completos',
      start_at: '2024-01-20T09:00:00Z',
      end_at: '2024-01-25T18:00:00Z',
      required: true
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON (201 Created)

```json
{
  "to_do": {
    "id": 322,
    "title": "Revisar documentación aduanal",
    "start_at": "2024-01-20T09:00:00Z",
    "end_at": "2024-01-25T18:00:00Z",
    "completed": false,
    "rejected": false,
    "required": true,
    "completed_at": null,
    "owner": {
      "email": "operador@apunto.com",
      "name": "Carlos Ramírez"
    },
    "completed_by": null,
    "created_at": "2024-01-16T11:00:00Z"
  }
}
```

Crea una nueva tarea en el recurso especificado.

### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| title | string | Sí | Título de la tarea |
| description | text | No | Descripción detallada |
| start_at | datetime | No | Fecha de inicio |
| end_at | datetime | No | Fecha de fin |
| required | boolean | No | Si la tarea es requerida |

## Actualizar Tarea <span class="badge badge-warning">PUT</span>

> Definición

```
PUT /api/v1/operations/:operation_id/to_dos/:id
PUT /api/v1/services/:service_id/to_dos/:id
PUT /api/v1/contacts/:contact_id/to_dos/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://tu-dominio.com/api/v1/operations/123/to_dos/321" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "to_do": {
      "title": "Solicitar documentos al cliente [URGENTE]",
      "end_at": "2024-01-18T18:00:00Z",
      "required": true
    }
  }'
```

> Respuesta JSON

```json
{
  "to_do": {
    "id": 321,
    "title": "Solicitar documentos al cliente [URGENTE]",
    "end_at": "2024-01-18T18:00:00Z",
    "required": true,
    "updated_at": "2024-01-16T11:30:00Z"
  }
}
```

Actualiza una tarea existente.

## Marcar como Completada <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:operation_id/to_dos/:id/complete
POST /api/v1/services/:service_id/to_dos/:id/complete
POST /api/v1/contacts/:contact_id/to_dos/:id/complete
```

> Ejemplo de llamada

```shell
curl -X POST "https://tu-dominio.com/api/v1/operations/123/to_dos/321/complete" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "to_do": {
    "id": 321,
    "title": "Solicitar documentos al cliente",
    "completed": true,
    "completed_at": "2024-01-16T12:00:00Z"
  },
  "message": "Tarea marcada como completada"
}
```

Marca una tarea como completada.

<aside class="notice">
Para marcar una tarea como NO completada, usa el endpoint de actualización con <code>completed: false</code>.
</aside>

## Eliminar Tarea <span class="badge badge-danger">DELETE</span>

> Definición

```
DELETE /api/v1/operations/:operation_id/to_dos/:id
DELETE /api/v1/services/:service_id/to_dos/:id
DELETE /api/v1/contacts/:contact_id/to_dos/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://tu-dominio.com/api/v1/operations/123/to_dos/321" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Tarea eliminada exitosamente"
}
```

Elimina una tarea.

<aside class="notice">
<strong>Importante</strong>: Las tareas están siempre anidadas bajo su recurso padre. Los campos <code>todoable_type</code> y <code>todoable_id</code> NO se incluyen en la respuesta porque son redundantes - la URL ya indica el recurso padre.
</aside>

### Ejemplo de Contexto por URL

Cuando llamas a `GET /api/v1/operations/123/to_dos`, ya sabes que:
- `todoable_type` = "Operation"
- `todoable_id` = 123

Por lo tanto, estos campos no se incluyen en la respuesta JSON.

