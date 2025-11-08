# Direcciones

Las direcciones representan ubicaciones físicas para embarques, facturación, aduanas, puertos y aeropuertos.

## Objeto Address

```json
{
  "id": 101,
  "name": "Almacén Principal CDMX",
  "alias": "ALM-CDMX",
  "address_type": "shipping",
  "status": "active",
  "street": "Av. Insurgentes Sur 1234",
  "outdoor_number": "1234",
  "internal_number": "Int. 5",
  "neighborhood": "Col. Del Valle",
  "city": "Ciudad de México",
  "state": "Ciudad de México",
  "postal_code": "03100",
  "country": "MX",
  "description": "Almacén de recepción y distribución",
  "contact_information": "Juan Pérez - Tel: 55-1234-5678",
  "created_at": "2024-01-10T09:00:00Z"
}
```

### Atributos

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
name | string | Nombre descriptivo de la ubicación
alias | string | Alias corto para referencia rápida
address_type | string | Tipo: `billing`, `shipping`, `port`, `customs`, `airport`, `general`
status | string | Estado: `active`, `inactive`
street | string | Calle
outdoor_number | string | Número exterior
internal_number | string | Número interior
neighborhood | string | Colonia o barrio
city | string | Ciudad
state | string | Estado o provincia
postal_code | string | Código postal
country | string | Código de país (ISO 3166-1 alpha-2)
description | string | Descripción adicional
contact_information | string | Información de contacto en la ubicación

## Listar Direcciones <span class="badge badge-success">GET</span>

```shell
curl "https://tu-dominio.com/api/v1/addresses" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
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
```

```javascript
axios.get('https://tu-dominio.com/api/v1/addresses', {
  headers: { 'Authorization': 'Bearer TU_TOKEN_API' }
})
.then(response => console.log(response.data));
```

> Respuesta:

```json
{
  "addresses": [
    {
      "id": 101,
      "name": "Almacén Principal CDMX",
      "alias": "ALM-CDMX",
      "address_type": "shipping",
      "city": "Ciudad de México",
      "status": "active"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 2,
    "total_count": 20
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
address_type | string | all | Filtrar por tipo de dirección
status | string | all | Filtrar por estado
city | string | null | Filtrar por ciudad
country | string | null | Filtrar por país
search | string | null | Búsqueda por nombre o alias

## Obtener una Dirección Específica <span class="badge badge-success">GET</span>

```shell
curl "https://tu-dominio.com/api/v1/addresses/101" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

> Respuesta:

```json
{
  "id": 101,
  "name": "Almacén Principal CDMX",
  "alias": "ALM-CDMX",
  "address_type": "shipping",
  "street": "Av. Insurgentes Sur 1234",
  "outdoor_number": "1234",
  "neighborhood": "Col. Del Valle",
  "city": "Ciudad de México",
  "state": "Ciudad de México",
  "postal_code": "03100",
  "country": "MX",
  "full_address": "Av. Insurgentes Sur 1234, Col. Del Valle, 03100, Ciudad de México, MX"
}
```

Obtiene los detalles de una dirección específica.

### Petición HTTP

`GET /api/v1/addresses/:id`

## Crear una Dirección <span class="badge badge-info">POST</span>

```shell
curl -X POST "https://tu-dominio.com/api/v1/addresses" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "name": "Puerto de Veracruz",
      "alias": "VER-PORT",
      "address_type": "port",
      "street": "Av. Marina Mercante",
      "outdoor_number": "S/N",
      "neighborhood": "Puerto de Veracruz",
      "city": "Veracruz",
      "state": "Veracruz",
      "postal_code": "91700",
      "country": "MX",
      "description": "Terminal de contenedores"
    }
  }'
```

```python
payload = {
    'address': {
        'name': 'Puerto de Veracruz',
        'alias': 'VER-PORT',
        'address_type': 'port',
        'street': 'Av. Marina Mercante',
        'city': 'Veracruz',
        'state': 'Veracruz',
        'postal_code': '91700',
        'country': 'MX'
    }
}

response = requests.post(
    'https://tu-dominio.com/api/v1/addresses',
    headers=headers,
    json=payload
)
```

```javascript
const data = {
  address: {
    name: 'Puerto de Veracruz',
    alias: 'VER-PORT',
    address_type: 'port',
    street: 'Av. Marina Mercante',
    city: 'Veracruz',
    postal_code: '91700',
    country: 'MX'
  }
};

axios.post('https://tu-dominio.com/api/v1/addresses', data, {
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  }
});
```

> Respuesta:

```json
{
  "id": 102,
  "name": "Puerto de Veracruz",
  "alias": "VER-PORT",
  "address_type": "port",
  "city": "Veracruz",
  "status": "active",
  "created_at": "2024-01-16T10:30:00Z"
}
```

Crea una nueva dirección.

### Petición HTTP

`POST /api/v1/addresses`

### Parámetros del Body

Parámetro | Tipo | Requerido | Descripción
--------- | ---- | --------- | -----------
name | string | Sí | Nombre de la ubicación
address_type | string | Sí | Tipo de dirección
street | string | Sí | Calle
neighborhood | string | Sí | Colonia
city | string | Sí | Ciudad
state | string | Sí | Estado
postal_code | string | Sí | Código postal
country | string | Sí | Código de país (2 letras, ej: MX, US)
alias | string | No | Alias corto
outdoor_number | string | No | Número exterior
internal_number | string | No | Número interior
description | string | No | Descripción (máx. 255 caracteres)
contact_information | string | No | Contacto (máx. 255 caracteres)

## Actualizar una Dirección <span class="badge badge-warning">PATCH</span>

```shell
curl -X PATCH "https://tu-dominio.com/api/v1/addresses/101" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "contact_information": "Ana García - Tel: 55-9999-8888",
      "description": "Almacén actualizado con nuevo contacto",
      "status": "active"
    }
  }'
```

```ruby
require 'uri'
require 'net/http'
require 'json'

uri = URI('https://tu-dominio.com/api/v1/addresses/101')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Patch.new(uri)
request['Authorization'] = 'Bearer TU_TOKEN_API'
request['Content-Type'] = 'application/json'
request.body = {
  address: {
    contact_information: 'Ana García - Tel: 55-9999-8888',
    description: 'Almacén actualizado con nuevo contacto'
  }
}.to_json

response = http.request(request)
puts response.body
```

```python
import requests
import json

url = "https://tu-dominio.com/api/v1/addresses/101"
headers = {
    "Authorization": "Bearer TU_TOKEN_API",
    "Content-Type": "application/json"
}
data = {
    "address": {
        "contact_information": "Ana García - Tel: 55-9999-8888",
        "description": "Almacén actualizado con nuevo contacto"
    }
}

response = requests.patch(url, headers=headers, data=json.dumps(data))
print(response.json())
```

```javascript
fetch('https://tu-dominio.com/api/v1/addresses/101', {
  method: 'PATCH',
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    address: {
      contact_information: 'Ana García - Tel: 55-9999-8888',
      description: 'Almacén actualizado con nuevo contacto'
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

> Respuesta:

```json
{
  "id": 101,
  "name": "Almacén Principal CDMX",
  "contact_information": "Ana García - Tel: 55-9999-8888",
  "updated_at": "2024-01-16T11:30:00Z"
}
```

Actualiza una dirección existente.

### Petición HTTP

`PATCH /api/v1/addresses/:id`

### Parámetros URL

Parámetro | Descripción
--------- | -----------
id | El ID de la dirección a actualizar

## Tipos de Dirección

Tipo | Descripción | Uso Común
---- | ----------- | ---------
billing | Facturación | Dirección fiscal del contacto
shipping | Embarque | Origen/destino de mercancía
port | Puerto | Terminal marítima
customs | Aduana | Recinto aduanero
airport | Aeropuerto | Terminal aérea
general | General | Uso múltiple

## Búsqueda de Direcciones

```shell
curl "https://tu-dominio.com/api/v1/addresses/search?q=Puerto&type=port" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

Busca direcciones por nombre, alias o ciudad.

### Petición HTTP

`GET /api/v1/addresses/search`

### Parámetros Query

Parámetro | Tipo | Descripción
--------- | ---- | -----------
q | string | Término de búsqueda
type | string | Filtrar por tipo de dirección
country | string | Filtrar por país
limit | integer | Número máximo de resultados (por defecto: 10)

<aside class="notice">
El campo <code>country</code> debe usar el código ISO 3166-1 alpha-2 de 2 letras (ej: MX para México, US para Estados Unidos).
</aside>
