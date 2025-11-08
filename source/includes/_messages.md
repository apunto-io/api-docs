# Comentarios (Messages)

Los comentarios permiten agregar notas, comunicaciones y actualizaciones a operaciones, servicios y contactos. Están **anidados bajo sus recursos padre**.

## Objeto Message

### Atributos Principales

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| body | text | Contenido del comentario |
| messageable_type | string | Tipo de recurso padre (Operation, Service, Contact) |
| messageable_id | integer | ID del recurso padre |
| user | object | Usuario que creó el comentario |
| created_at | datetime | Fecha de creación |
| updated_at | datetime | Fecha de última actualización |

## Listar Comentarios

> Definición

```
GET /api/v1/operations/:operation_id/messages
GET /api/v1/services/:service_id/messages
GET /api/v1/contacts/:contact_id/messages
```

> Ejemplo de llamada

```shell
# Comentarios de una operación
curl "https://tu-dominio.com/api/v1/operations/123/messages" \
  -H "Authorization: Bearer TU_TOKEN"

# Comentarios de un servicio
curl "https://tu-dominio.com/api/v1/services/789/messages" \
  -H "Authorization: Bearer TU_TOKEN"
```

```ruby
require 'uri'
require 'net/http'

uri = URI('https://tu-dominio.com/api/v1/operations/123/messages')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'

response = http.request(request)
puts response.body
```

```python
import requests

url = "https://tu-dominio.com/api/v1/operations/123/messages"
headers = {"Authorization": "Bearer TU_TOKEN"}

response = requests.get(url, headers=headers)
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/operations/123/messages', {
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
      "body": "Cliente confirmó recepción de mercancía",
      "messageable_type": "Operation",
      "messageable_id": 123,
      "user": {
        "id": 10,
        "email": "usuario@apunto.com",
        "name": "Juan Pérez"
      },
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

## Obtener un Comentario

> Definición

```
GET /api/v1/operations/:operation_id/messages/:id
GET /api/v1/services/:service_id/messages/:id
GET /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl "https://tu-dominio.com/api/v1/operations/123/messages/456" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "message": {
    "id": 456,
    "body": "Cliente confirmó recepción de mercancía",
    "messageable_type": "Operation",
    "messageable_id": 123,
    "user": {
      "id": 10,
      "email": "usuario@apunto.com",
      "name": "Juan Pérez"
    },
    "created_at": "2024-01-16T14:30:00Z",
    "updated_at": "2024-01-16T14:30:00Z"
  }
}
```

Retorna un comentario específico.

## Crear Comentario

> Definición

```
POST /api/v1/operations/:operation_id/messages
POST /api/v1/services/:service_id/messages
POST /api/v1/contacts/:contact_id/messages
```

> Ejemplo de llamada

```shell
curl -X POST "https://tu-dominio.com/api/v1/operations/123/messages" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "body": "Cliente solicitó actualización de ETA"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://tu-dominio.com/api/v1/operations/123/messages')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN'
request['Content-Type'] = 'application/json'
request.body = {
  message: {
    body: 'Cliente solicitó actualización de ETA'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://tu-dominio.com/api/v1/operations/123/messages"
headers = {
    "Authorization": "Bearer TU_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "message": {
        "body": "Cliente solicitó actualización de ETA"
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/operations/123/messages', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    message: {
      body: 'Cliente solicitó actualización de ETA'
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
    "body": "Cliente solicitó actualización de ETA",
    "messageable_type": "Operation",
    "messageable_id": 123,
    "user": {
      "id": 10,
      "email": "usuario@apunto.com",
      "name": "Juan Pérez"
    },
    "created_at": "2024-01-16T15:00:00Z",
    "updated_at": "2024-01-16T15:00:00Z"
  }
}
```

Crea un nuevo comentario en el recurso especificado.

### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| body | text | Sí | Contenido del comentario |

## Actualizar Comentario

> Definición

```
PUT /api/v1/operations/:operation_id/messages/:id
PUT /api/v1/services/:service_id/messages/:id
PUT /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl -X PUT "https://tu-dominio.com/api/v1/operations/123/messages/456" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "body": "Cliente confirmó recepción de mercancía [EDITADO]"
    }
  }'
```

> Respuesta JSON

```json
{
  "message": {
    "id": 456,
    "body": "Cliente confirmó recepción de mercancía [EDITADO]",
    "updated_at": "2024-01-16T15:30:00Z"
  }
}
```

Actualiza un comentario existente.

## Eliminar Comentario

> Definición

```
DELETE /api/v1/operations/:operation_id/messages/:id
DELETE /api/v1/services/:service_id/messages/:id
DELETE /api/v1/contacts/:contact_id/messages/:id
```

> Ejemplo de llamada

```shell
curl -X DELETE "https://tu-dominio.com/api/v1/operations/123/messages/456" \
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
Los comentarios están siempre anidados bajo su recurso padre (Operation, Service o Contact). No existe un endpoint independiente para listar todos los comentarios.
</aside>

