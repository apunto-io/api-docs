# Contactos

Los contactos representan clientes, proveedores, prospectos y otros contactos de negocio en el sistema. Cada contacto puede tener información de facturación, direcciones y detalles fiscales.

## Objeto Contact

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "alias": "ABC_Trading",
  "legal_name": "ABC Trading Company S.A. de C.V.",
  "identification": "ABC990101ABC",
  "kind": ["client", "supplier"],
  "services": ["import", "export"],
  "status": "active",
  "email": "contacto@abctrading.com",
  "phone": "+52 55 1234 5678",
  "website": "https://abctrading.com",
  "billing_address": {
    "id": 100,
    "street": "Av. Reforma 123",
    "neighborhood": "Juárez",
    "city": "Ciudad de México",
    "state": "CDMX",
    "postal_code": "06600",
    "country": "MX"
  },
  "contact_tax_regime_id": 1,
  "cfdi_use_id": 2,
  "payment_method_id": 3,
  "payment_type_id": 4,
  "tags": ["cliente-premium", "importador"],
  "created_at": "2024-01-10T08:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Atributos

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
name | string | Nombre del contacto
alias | string | Alias o nombre corto (sin espacios)
legal_name | string | Razón social legal
identification | string | RFC o identificación fiscal
kind | array | Tipos de contacto: `client`, `supplier`, `customs_agent`, `airline`, `shipping_line`, `prospect`
services | array | Servicios que ofrece: `import`, `export`, `customs`, `transport`, `consulting`
status | string | Estado: `active`, `inactive`
email | string | Correo electrónico principal
phone | string | Teléfono de contacto
website | string | Sitio web
contact_tax_regime_id | integer | ID del régimen fiscal
cfdi_use_id | integer | ID del uso de CFDI
payment_method_id | integer | ID del método de pago preferido
payment_type_id | integer | ID del tipo de pago preferido
billing_address | object | Dirección de facturación
tags | array | Etiquetas del contacto
created_at | datetime | Fecha de creación
updated_at | datetime | Fecha de última actualización

## Listar Contactos

```shell
curl "https://tu-dominio.com/api/v1/contacts" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://tu-dominio.com/api/v1/contacts")
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
    'https://tu-dominio.com/api/v1/contacts',
    headers=headers
)
contacts = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://tu-dominio.com/api/v1/contacts', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "contacts": [
    {
      "id": 456,
      "name": "ABC Trading Company",
      "alias": "ABC_Trading",
      "kind": ["client"],
      "status": "active",
      "created_at": "2024-01-10T08:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 120,
    "per_page": 25
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
kind | string | all | Filtrar por tipo: `client`, `supplier`, `customs_agent`, `prospect`
status | string | active | Filtrar por estado: `active`, `inactive`
search | string | null | Buscar por nombre, alias o identificación
sort | string | created_at | Campo de ordenamiento
direction | string | desc | Dirección de ordenamiento

## Obtener un Contacto Específico

```shell
curl "https://tu-dominio.com/api/v1/contacts/456" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://tu-dominio.com/api/v1/contacts/456")
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
    'https://tu-dominio.com/api/v1/contacts/456',
    headers=headers
)
contact = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://tu-dominio.com/api/v1/contacts/456', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "alias": "ABC_Trading",
  "legal_name": "ABC Trading Company S.A. de C.V.",
  "identification": "ABC990101ABC",
  "kind": ["client", "supplier"],
  "services": ["import", "export"],
  "status": "active",
  "email": "contacto@abctrading.com",
  "phone": "+52 55 1234 5678",
  "billing_address": {
    "street": "Av. Reforma 123",
    "city": "Ciudad de México",
    "country": "MX"
  },
  "operations_count": 45,
  "tags": ["cliente-premium"]
}
```

Obtiene los detalles de un contacto específico.

### Petición HTTP

`GET /api/v1/contacts/:id`

### Parámetros URL

Parámetro | Descripción
--------- | -----------
id | El ID del contacto a obtener

## Crear un Contacto

```shell
curl -X POST "https://tu-dominio.com/api/v1/contacts" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "name": "Nueva Empresa SA",
      "alias": "NuevaEmpresa",
      "legal_name": "Nueva Empresa S.A. de C.V.",
      "identification": "NEA010101ABC",
      "kind": ["client"],
      "services": ["import"],
      "email": "contacto@nuevaempresa.com",
      "phone": "+52 55 9876 5432",
      "tags": ["nuevo-cliente"]
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/contacts")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"
request.content_type = "application/json"
request.body = JSON.dump({
  "contact" => {
    "name" => "Nueva Empresa SA",
    "alias" => "NuevaEmpresa",
    "kind" => ["client"],
    "email" => "contacto@nuevaempresa.com"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
}

payload = {
    'contact': {
        'name': 'Nueva Empresa SA',
        'alias': 'NuevaEmpresa',
        'kind': ['client'],
        'email': 'contacto@nuevaempresa.com',
        'phone': '+52 55 9876 5432'
    }
}

response = requests.post(
    'https://tu-dominio.com/api/v1/contacts',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  contact: {
    name: 'Nueva Empresa SA',
    alias: 'NuevaEmpresa',
    kind: ['client'],
    email: 'contacto@nuevaempresa.com',
    phone: '+52 55 9876 5432'
  }
};

axios.post('https://tu-dominio.com/api/v1/contacts', data, {
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "id": 457,
  "name": "Nueva Empresa SA",
  "alias": "NuevaEmpresa",
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
alias | string | Sí | Alias único (sin espacios)
kind | array | Sí | Tipos de contacto
legal_name | string | No | Razón social legal
identification | string | No | RFC o identificación fiscal (12-13 caracteres)
services | array | No | Servicios que ofrece
email | string | No | Correo electrónico
phone | string | No | Teléfono
website | string | No | Sitio web
contact_tax_regime_id | integer | No | ID del régimen fiscal
cfdi_use_id | integer | No | ID del uso de CFDI
payment_method_id | integer | No | ID del método de pago
payment_type_id | integer | No | ID del tipo de pago
tags | array | No | Etiquetas del contacto

<aside class="notice">
El campo <code>alias</code> no debe contener espacios y debe ser único en tu cuenta.
</aside>

## Actualizar un Contacto

```shell
curl -X PATCH "https://tu-dominio.com/api/v1/contacts/456" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "status": "inactive",
      "email": "nuevo@ejemplo.com",
      "tags": ["cliente-inactivo"]
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/contacts/456")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"
request.content_type = "application/json"
request.body = JSON.dump({
  "contact" => {
    "status" => "inactive",
    "email" => "nuevo@ejemplo.com"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
}

payload = {
    'contact': {
        'status': 'inactive',
        'email': 'nuevo@ejemplo.com'
    }
}

response = requests.patch(
    'https://tu-dominio.com/api/v1/contacts/456',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  contact: {
    status: 'inactive',
    email: 'nuevo@ejemplo.com'
  }
};

axios.patch('https://tu-dominio.com/api/v1/contacts/456', data, {
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "id": 456,
  "name": "ABC Trading Company",
  "status": "inactive",
  "email": "nuevo@ejemplo.com",
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

### Parámetros del Body

Todos los campos de contacto son opcionales. Solo incluye los campos que deseas actualizar.

## Crear Contacto Rápido

```shell
curl -X POST "https://tu-dominio.com/api/v1/contacts/quick_create" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Contacto Rápido",
    "kind": "client"
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/contacts/quick_create")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"
request.content_type = "application/json"
request.body = JSON.dump({
  "name" => "Contacto Rápido",
  "kind" => "client"
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
}

payload = {
    'name': 'Contacto Rápido',
    'kind': 'client'
}

response = requests.post(
    'https://tu-dominio.com/api/v1/contacts/quick_create',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  name: 'Contacto Rápido',
  kind: 'client'
};

axios.post('https://tu-dominio.com/api/v1/contacts/quick_create', data, {
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "id": 458,
  "name": "Contacto Rápido",
  "alias": "ContactoRapido",
  "kind": ["client"],
  "status": "active",
  "created_at": "2024-01-16T11:30:00Z"
}
```

Crea un contacto rápidamente con información mínima. El sistema genera automáticamente un alias basado en el nombre.

### Petición HTTP

`POST /api/v1/contacts/quick_create`

### Parámetros del Body

Parámetro | Tipo | Requerido | Descripción
--------- | ---- | --------- | -----------
name | string | Sí | Nombre del contacto
kind | string | Sí | Tipo de contacto (solo uno)

<aside class="notice">
Este endpoint es útil para crear contactos rápidamente desde formularios o integraciones que solo tienen información básica.
</aside>

