# Contactos

Los contactos representan clientes, proveedores, prospectos y otros participantes en las operaciones de freight forwarding.

## Objeto Contact

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "alias": "ABC",
  "identification": "ABC1234567890",
  "legal_name": "ABC Trading Company S.A. de C.V.",
  "kind": ["client", "supplier"],
  "services": ["maritime", "aerial"],
  "email": "contacto@abc.com",
  "phone": "+52 55 1234 5678",
  "status": "active",
  "billing_address": {
    "id": 101,
    "street": "Av. Reforma 123",
    "city": "Ciudad de México",
    "postal_code": "06600",
    "country": "MX"
  },
  "tags": ["prioritario"],
  "created_at": "2024-01-10T09:00:00Z"
}
```

### Atributos

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
name | string | Nombre del contacto
alias | string | Alias corto (sin espacios)
identification | string | RFC o identificación fiscal
legal_name | string | Razón social legal
kind | array | Tipos: `client`, `supplier`, `prospect`, `carrier`, `customs_agent`
services | array | Servicios: `maritime`, `aerial`, `land`, `customs`
email | string | Correo electrónico
phone | string | Teléfono
status | string | Estado: `active`, `inactive`
billing_address | object | Dirección de facturación
tags | array | Etiquetas del contacto

## Listar Contactos <span class="badge badge-success">GET</span>

```shell
curl "https://control.apunto.io/api/v1/contacts" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
uri = URI.parse("https://control.apunto.io/api/v1/contacts")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer TU_TOKEN_API'}
response = requests.get(
    'https://control.apunto.io/api/v1/contacts',
    headers=headers
)
```

```javascript
axios.get('https://control.apunto.io/api/v1/contacts', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data));
```

> Respuesta:

```json
{
  "contacts": [
    {
      "id": 456,
      "name": "ABC Trading Company",
      "alias": "ABC",
      "kind": ["client"],
      "status": "active"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 30
  }
}
```

Obtiene una lista de todos los contactos de la cuenta autenticada.

### Petición HTTP

`GET /api/v1/contacts`

### Parámetros Query

Parámetro | Tipo | Por Defecto | Descripción
--------- | ---- | ----------- | -----------
page | integer | 1 | Número de página
per_page | integer | 25 | Registros por página
kind | string | null | Filtrar por tipo: `client`, `supplier`, `prospect`
status | string | all | Filtrar por estado
search | string | null | Búsqueda por nombre, alias o identificación

## Obtener un Contacto Específico

```shell
curl "https://control.apunto.io/api/v1/contacts/456" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

> Respuesta:

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "alias": "ABC",
  "identification": "ABC1234567890",
  "kind": ["client", "supplier"],
  "services": ["maritime", "aerial"],
  "email": "contacto@abc.com",
  "phone": "+52 55 1234 5678",
  "billing_address": {
    "street": "Av. Reforma 123",
    "city": "Ciudad de México"
  }
}
```

Obtiene los detalles de un contacto específico.

### Petición HTTP

`GET /api/v1/contacts/:id`

## Crear un Contacto <span class="badge badge-info">POST</span>

```shell
curl -X POST "https://control.apunto.io/api/v1/contacts" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "name": "XYZ Logistics",
      "alias": "XYZ",
      "kind": ["client"],
      "email": "info@xyz.com",
      "phone": "+52 55 9876 5432",
      "billing_address_attributes": {
        "street": "Calle Principal 456",
        "city": "Monterrey",
        "state": "Nuevo León",
        "postal_code": "64000",
        "country": "MX",
        "address_type": "billing"
      }
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://control.apunto.io/api/v1/contacts')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN_API'
request['Content-Type'] = 'application/json'
request.body = {
  contact: {
    name: 'XYZ Logistics',
    alias: 'XYZ',
    kind: ['client'],
    email: 'info@xyz.com'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
payload = {
    'contact': {
        'name': 'XYZ Logistics',
        'alias': 'XYZ',
        'kind': ['client'],
        'email': 'info@xyz.com',
        'phone': '+52 55 9876 5432',
        'billing_address_attributes': {
            'street': 'Calle Principal 456',
            'city': 'Monterrey',
            'postal_code': '64000',
            'country': 'MX'
        }
    }
}

response = requests.post(
    'https://control.apunto.io/api/v1/contacts',
    headers=headers,
    json=payload
)
```

```javascript
fetch('https://control.apunto.io/api/v1/contacts', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    contact: {
      name: 'XYZ Logistics',
      alias: 'XYZ',
      kind: ['client'],
      email: 'info@xyz.com'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta:

```json
{
  "id": 457,
  "name": "XYZ Logistics",
  "alias": "XYZ",
  "kind": ["client"],
  "status": "active",
  "created_at": "2024-01-16T10:00:00Z"
}
```

Crea un nuevo contacto.

### Petición HTTP

`POST /api/v1/contacts`

### Parámetros del Body

Parámetro | Tipo | Requerido | Descripción
--------- | ---- | --------- | -----------
name | string | Sí | Nombre del contacto
alias | string | Sí | Alias corto (sin espacios)
kind | array | Sí | Tipos de contacto
identification | string | No | RFC o identificación fiscal
legal_name | string | No | Razón social
email | string | No | Correo electrónico
phone | string | No | Teléfono
services | array | No | Servicios que ofrece/requiere
billing_address_attributes | object | No | Dirección de facturación

## Actualizar un Contacto <span class="badge badge-warning">PATCH</span>

```shell
curl -X PATCH "https://control.apunto.io/api/v1/contacts/456" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "email": "nuevo@abc.com",
      "phone": "+52 55 1111 2222",
      "tags": ["vip", "prioritario"]
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://control.apunto.io/api/v1/contacts/456')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Patch.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN_API'
request['Content-Type'] = 'application/json'
request.body = {
  contact: {
    email: 'nuevo@abc.com',
    phone: '+52 55 1111 2222'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://control.apunto.io/api/v1/contacts/456"
headers = {
    "Authorization": "Bearer TU_TOKEN_API",
    "Content-Type": "application/json"
}
data = {
    "contact": {
        "email": "nuevo@abc.com",
        "phone": "+52 55 1111 2222"
    }
}

response = requests.patch(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://control.apunto.io/api/v1/contacts/456', {
  method: 'PATCH',
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    contact: {
      email: 'nuevo@abc.com',
      phone: '+52 55 1111 2222'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta:

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "email": "nuevo@abc.com",
  "phone": "+52 55 1111 2222",
  "updated_at": "2024-01-16T11:00:00Z"
}
```

Actualiza un contacto existente.

### Petición HTTP

`PATCH /api/v1/contacts/:id`

### Parámetros URL

Parámetro | Descripción
--------- | -----------
id | El ID del contacto a actualizar

## Búsqueda Rápida de Contactos <span class="badge badge-success">GET</span>

```shell
curl "https://control.apunto.io/api/v1/contacts/search?q=ABC" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

Busca contactos por nombre, alias o identificación.

### Petición HTTP

`GET /api/v1/contacts/search`

### Parámetros Query

Parámetro | Tipo | Descripción
--------- | ---- | -----------
q | string | Término de búsqueda
kind | string | Filtrar por tipo
limit | integer | Número máximo de resultados (por defecto: 10)
