# Direcciones

Las direcciones representan ubicaciones físicas en el sistema, incluyendo direcciones de facturación, envío, puertos, aeropuertos y aduanas. Pueden asociarse a contactos o existir de forma independiente.

## Objeto Address

```json
{
  "id": 100,
  "name": "Bodega Principal CDMX",
  "alias": "bodega_cdmx",
  "street": "Av. Insurgentes Sur 1234",
  "outdoor_number": "1234",
  "internal_number": "Int. 5",
  "neighborhood": "Del Valle",
  "city": "Ciudad de México",
  "state": "CDMX",
  "postal_code": "03100",
  "country": "MX",
  "address_type": "shipping",
  "status": "active",
  "description": "Bodega principal para recepción de mercancía",
  "contact_information": "Horario: Lun-Vie 8:00-18:00",
  "latitude": 19.3910,
  "longitude": -99.1700,
  "addressable_type": null,
  "addressable_id": null,
  "created_at": "2024-01-10T08:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Atributos

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
name | string | Nombre de la ubicación
alias | string | Alias o nombre corto
street | string | Nombre de la calle
outdoor_number | string | Número exterior
internal_number | string | Número interior (opcional)
neighborhood | string | Colonia o barrio
city | string | Ciudad
state | string | Estado o provincia
postal_code | string | Código postal
country | string | Código de país (ISO 3166-1 alpha-2, ej. MX, US)
address_type | string | Tipo de dirección: `billing`, `shipping`, `port`, `customs`, `airport`, `general`
status | string | Estado: `active`, `inactive`
description | string | Descripción adicional (máx. 255 caracteres)
contact_information | string | Información de contacto (máx. 255 caracteres)
latitude | decimal | Latitud (opcional)
longitude | decimal | Longitud (opcional)
addressable_type | string | Tipo de entidad asociada (opcional)
addressable_id | integer | ID de entidad asociada (opcional)
created_at | datetime | Fecha de creación
updated_at | datetime | Fecha de última actualización

## Listar Direcciones

```shell
curl "https://tu-dominio.com/api/v1/addresses" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://tu-dominio.com/api/v1/addresses")
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
    'https://tu-dominio.com/api/v1/addresses',
    headers=headers
)
addresses = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://tu-dominio.com/api/v1/addresses', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "addresses": [
    {
      "id": 100,
      "name": "Bodega Principal CDMX",
      "alias": "bodega_cdmx",
      "city": "Ciudad de México",
      "state": "CDMX",
      "country": "MX",
      "address_type": "shipping",
      "status": "active",
      "created_at": "2024-01-10T08:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 68,
    "per_page": 25
  }
}
```

Obtiene una lista de todas las direcciones de la cuenta autenticada.

### Petición HTTP

`GET /api/v1/addresses`

### Parámetros Query

Parámetro | Tipo | Por Defecto | Descripción
--------- | ---- | ----------- | -----------
page | integer | 1 | Número de página
per_page | integer | 25 | Registros por página
address_type | string | all | Filtrar por tipo: `billing`, `shipping`, `port`, `customs`, `airport`, `general`
status | string | active | Filtrar por estado: `active`, `inactive`
country | string | null | Filtrar por código de país (ej. MX, US)
city | string | null | Filtrar por ciudad
search | string | null | Buscar por nombre, alias o dirección
sort | string | created_at | Campo de ordenamiento
direction | string | desc | Dirección de ordenamiento

## Obtener una Dirección Específica

```shell
curl "https://tu-dominio.com/api/v1/addresses/100" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://tu-dominio.com/api/v1/addresses/100")
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
    'https://tu-dominio.com/api/v1/addresses/100',
    headers=headers
)
address = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://tu-dominio.com/api/v1/addresses/100', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "id": 100,
  "name": "Bodega Principal CDMX",
  "alias": "bodega_cdmx",
  "street": "Av. Insurgentes Sur 1234",
  "outdoor_number": "1234",
  "internal_number": "Int. 5",
  "neighborhood": "Del Valle",
  "city": "Ciudad de México",
  "state": "CDMX",
  "postal_code": "03100",
  "country": "MX",
  "address_type": "shipping",
  "status": "active",
  "full_address": "Av. Insurgentes Sur 1234 1234 Int. 5, Del Valle, Ciudad de México, CDMX 03100, MX"
}
```

Obtiene los detalles de una dirección específica.

### Petición HTTP

`GET /api/v1/addresses/:id`

### Parámetros URL

Parámetro | Descripción
--------- | -----------
id | El ID de la dirección a obtener

## Crear una Dirección

```shell
curl -X POST "https://tu-dominio.com/api/v1/addresses" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "name": "Nueva Bodega Guadalajara",
      "alias": "bodega_gdl",
      "street": "Av. Américas",
      "outdoor_number": "1500",
      "neighborhood": "Providencia",
      "city": "Guadalajara",
      "state": "Jalisco",
      "postal_code": "44630",
      "country": "MX",
      "address_type": "shipping",
      "description": "Bodega secundaria"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/addresses")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"
request.content_type = "application/json"
request.body = JSON.dump({
  "address" => {
    "name" => "Nueva Bodega Guadalajara",
    "street" => "Av. Américas",
    "outdoor_number" => "1500",
    "neighborhood" => "Providencia",
    "city" => "Guadalajara",
    "state" => "Jalisco",
    "postal_code" => "44630",
    "country" => "MX",
    "address_type" => "shipping"
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
    'address': {
        'name': 'Nueva Bodega Guadalajara',
        'street': 'Av. Américas',
        'outdoor_number': '1500',
        'neighborhood': 'Providencia',
        'city': 'Guadalajara',
        'state': 'Jalisco',
        'postal_code': '44630',
        'country': 'MX',
        'address_type': 'shipping'
    }
}

response = requests.post(
    'https://tu-dominio.com/api/v1/addresses',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  address: {
    name: 'Nueva Bodega Guadalajara',
    street: 'Av. Américas',
    outdoor_number: '1500',
    neighborhood: 'Providencia',
    city: 'Guadalajara',
    state: 'Jalisco',
    postal_code: '44630',
    country: 'MX',
    address_type: 'shipping'
  }
};

axios.post('https://tu-dominio.com/api/v1/addresses', data, {
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
  "id": 101,
  "name": "Nueva Bodega Guadalajara",
  "alias": "bodega_gdl",
  "city": "Guadalajara",
  "state": "Jalisco",
  "country": "MX",
  "address_type": "shipping",
  "status": "active",
  "created_at": "2024-01-16T10:00:00Z"
}
```

Crea una nueva dirección.

### Petición HTTP

`POST /api/v1/addresses`

### Parámetros del Body

Parámetro | Tipo | Requerido | Descripción
--------- | ---- | --------- | -----------
name | string | Sí | Nombre de la ubicación
street | string | Sí | Nombre de la calle
outdoor_number | string | No | Número exterior
internal_number | string | No | Número interior
neighborhood | string | Sí | Colonia o barrio
city | string | Sí | Ciudad
state | string | Sí | Estado o provincia
postal_code | string | Sí | Código postal
country | string | Sí | Código de país (formato ISO, ej. MX)
address_type | string | Sí | Tipo de dirección
alias | string | No | Alias o nombre corto
description | string | No | Descripción (máx. 255 caracteres)
contact_information | string | No | Información de contacto (máx. 255 caracteres)
latitude | decimal | No | Latitud
longitude | decimal | No | Longitud

<aside class="notice">
El campo <code>country</code> debe ser un código ISO 3166-1 alpha-2 de 2 letras (ej. MX para México, US para Estados Unidos).
</aside>

## Actualizar una Dirección

```shell
curl -X PATCH "https://tu-dominio.com/api/v1/addresses/100" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "status": "inactive",
      "description": "Bodega cerrada temporalmente",
      "contact_information": "Cerrado hasta nuevo aviso"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/addresses/100")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"
request.content_type = "application/json"
request.body = JSON.dump({
  "address" => {
    "status" => "inactive",
    "description" => "Bodega cerrada temporalmente"
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
    'address': {
        'status': 'inactive',
        'description': 'Bodega cerrada temporalmente'
    }
}

response = requests.patch(
    'https://tu-dominio.com/api/v1/addresses/100',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  address: {
    status: 'inactive',
    description: 'Bodega cerrada temporalmente'
  }
};

axios.patch('https://tu-dominio.com/api/v1/addresses/100', data, {
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
  "id": 100,
  "name": "Bodega Principal CDMX",
  "status": "inactive",
  "description": "Bodega cerrada temporalmente",
  "updated_at": "2024-01-16T11:00:00Z"
}
```

Actualiza una dirección existente.

### Petición HTTP

`PATCH /api/v1/addresses/:id`

### Parámetros URL

Parámetro | Descripción
--------- | -----------
id | El ID de la dirección a actualizar

### Parámetros del Body

Todos los campos de dirección son opcionales. Solo incluye los campos que deseas actualizar.

## Tipos de Dirección

Las direcciones pueden ser de los siguientes tipos:

Tipo | Descripción | Uso Común
---- | ----------- | ---------
billing | Facturación | Direcciones fiscales para facturación
shipping | Envío | Origen/destino de mercancía
port | Puerto | Puertos marítimos
customs | Aduana | Ubicaciones aduanales
airport | Aeropuerto | Terminales aéreas
general | General | Otros usos

<aside class="notice">
Puedes tener múltiples direcciones del mismo tipo. El sistema no limita el número de direcciones por tipo.
</aside>

