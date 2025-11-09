# Comentarios (Messages)

Los comentarios permiten agregar notas, comunicaciones y actualizaciones a operaciones, servicios y contactos. Están **anidados bajo sus recursos padre**.

## Objeto Message

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| content | text | Contenido del comentario |
| owner | object | Usuario que creó el comentario |
| edited | boolean | Indica si el comentario fue editado |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Comentarios <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:operation_id/messages
GET /api/v1/services/:service_id/messages
GET /api/v1/contacts/:contact_id/messages
```

> Ejemplo de llamada

```shell
# Comentarios de una operación
curl "https://control.apunto.io/api/v1/operations/123/messages" \
  -H "Authorization: Bearer TU_TOKEN"

# Comentarios de un servicio
curl "https://control.apunto.io/api/v1/services/789/messages" \
  -H "Authorization: Bearer TU_TOKEN"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://control.apunto.io/api/v1/operations/123/messages')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'

response = http.request(request)
puts response.body
```

```python
import requests

url = "https://control.apunto.io/api/v1/operations/123/messages"
headers = {"Authorization": "Bearer TU_TOKEN"}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/operations/123/messages', {
  headers: {'Authorization': 'Bearer TU_TOKEN'}
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON

```json
{
  "messages": [
    {
      "id": 456,
      "content": "Cliente confirmó recepción de mercancía",
      "owner": {
        "email": "usuario@apunto.com",
        "name": "Juan Pérez"
      },
      "edited": false,
      "created_at": "2024-01-16T14:30:00Z",
      "updated_at": "2024-01-16T14:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 25,
    "total": 12
  }
}
```

Retorna todos los comentarios de un recurso específico.

### Parámetros Query

| Parámetro | Descripción |
|-----------|-------------|
| page | Número de página (default: 1) |
| per_page | Registros por página (default: 25, max: 100) |

## Obtener un Comentario <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:operation_id/messages/:id
GET /api/v1/services/:service_id/messages/:id
GET /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl "https://control.apunto.io/api/v1/operations/123/messages/456" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": {
    "id": 456,
    "content": "Cliente confirmó recepción de mercancía",
    "owner": {
      "email": "usuario@apunto.com",
      "name": "Juan Pérez"
    },
    "edited": false,
    "created_at": "2024-01-16T14:30:00Z",
    "updated_at": "2024-01-16T14:30:00Z"
  }
}
```

Retorna un comentario específico.

## Crear Comentario <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:operation_id/messages
POST /api/v1/services/:service_id/messages
POST /api/v1/contacts/:contact_id/messages
```

> Ejemplo de llamada

```shell
curl -X POST "https://control.apunto.io/api/v1/operations/123/messages" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "content": "Cliente solicitó actualización de ETA"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://control.apunto.io/api/v1/operations/123/messages')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  message: {
    content: 'Cliente solicitó actualización de ETA'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://control.apunto.io/api/v1/operations/123/messages"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "message": {
        "content": "Cliente solicitó actualización de ETA"
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/operations/123/messages', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    message: {
      content: 'Cliente solicitó actualización de ETA'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta JSON (201 Created)

```json
{
  "message": {
    "id": 457,
    "content": "Cliente solicitó actualización de ETA",
    "owner": {
      "email": "usuario@apunto.com",
      "name": "Juan Pérez"
    },
    "edited": false,
    "created_at": "2024-01-16T15:00:00Z",
    "updated_at": "2024-01-16T15:00:00Z"
  }
}
```

Crea un nuevo comentario en el recurso especificado.

### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| content | text | Sí | Contenido del comentario |

## Actualizar Comentario <span class="badge badge-warning">PUT</span>

> Definición

```
PUT /api/v1/operations/:operation_id/messages/:id
PUT /api/v1/services/:service_id/messages/:id
PUT /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://control.apunto.io/api/v1/operations/123/messages/456" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "content": "Cliente confirmó recepción de mercancía [EDITADO]"
    }
  }'
```

> Respuesta JSON

```json
{
  "message": {
    "id": 456,
    "content": "Cliente confirmó recepción de mercancía [EDITADO]",
    "edited": true,
    "updated_at": "2024-01-16T15:30:00Z"
  }
}
```

Actualiza un comentario existente.

## Eliminar Comentario <span class="badge badge-danger">DELETE</span>

> Definición

```
DELETE /api/v1/operations/:operation_id/messages/:id
DELETE /api/v1/services/:service_id/messages/:id
DELETE /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://control.apunto.io/api/v1/operations/123/messages/456" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": "Comentario eliminado exitosamente"
}
```

Elimina un comentario.

<aside class="notice">
<strong>Importante</strong>: Los comentarios están siempre anidados bajo su recurso padre. Los campos <code>messageable_type</code> y <code>messageable_id</code> NO se incluyen en la respuesta porque son redundantes - la URL ya indica el recurso padre.
</aside>

### Ejemplo de Contexto por URL

Cuando llamas a `GET /api/v1/operations/123/messages`, ya sabes que:
- `messageable_type` = "Operation"
- `messageable_id` = 123

Por lo tanto, estos campos no se incluyen en la respuesta JSON.

