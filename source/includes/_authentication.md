# Autenticación

## Descripción General

La API de Apunto utiliza autenticación mediante Bearer token. Para acceder a la API, necesitas:

1. Crear un token de API en la configuración de tu cuenta
2. Incluir el token en el header `Authorization` de cada petición

## Crear un Token de API

Los tokens de API se pueden crear a través de la interfaz web:

1. Navega a **Configuración** → **Tokens de API**
2. Haz clic en **Nuevo Token de API**
3. Dale un nombre descriptivo a tu token
4. Copia el token generado (solo se mostrará una vez)

## Usar el Token de API

> Para autenticarte, incluye el token en el header Authorization:

```shell
curl "https://tu-dominio.com/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://tu-dominio.com/api/v1/operations")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer TU_TOKEN_API"

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

response = requests.get(
    'https://tu-dominio.com/api/v1/operations',
    headers=headers
)
```

```javascript
const axios = require('axios');

const config = {
  headers: {
    'Authorization': 'Bearer TU_TOKEN_API',
    'Content-Type': 'application/json'
  }
};

axios.get('https://tu-dominio.com/api/v1/operations', config)
  .then(response => console.log(response.data))
  .catch(error => console.error(error));
```

Incluye tu token de API en el header `Authorization` de todas las peticiones:

`Authorization: Bearer TU_TOKEN_API`

<aside class="notice">
Reemplaza <code>TU_TOKEN_API</code> con tu token de API real.
</aside>

<aside class="warning">
¡Mantén tus tokens de API seguros! Proporcionan acceso completo a tu cuenta.
</aside>

## Login (Autenticación Alternativa)

Si necesitas autenticarte programáticamente y obtener un token:

```shell
curl -X POST "https://tu-dominio.com/api/v1/auth" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "tu_contraseña"
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://tu-dominio.com/api/v1/auth")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request.body = JSON.dump({
  "email" => "usuario@ejemplo.com",
  "password" => "tu_contraseña"
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests
import json

url = 'https://tu-dominio.com/api/v1/auth'
payload = {
    'email': 'usuario@ejemplo.com',
    'password': 'tu_contraseña'
}

response = requests.post(url, json=payload)
token = response.json()['token']
```

```javascript
const axios = require('axios');

axios.post('https://tu-dominio.com/api/v1/auth', {
  email: 'usuario@ejemplo.com',
  password: 'tu_contraseña'
})
.then(response => {
  const token = response.data.token;
  console.log('Token:', token);
})
.catch(error => console.error(error));
```

> Respuesta:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Petición HTTP

`POST /api/v1/auth`

### Parámetros del Body

Parámetro | Tipo | Requerido | Descripción
--------- | ---- | --------- | -----------
email | string | Sí | Correo electrónico del usuario
password | string | Sí | Contraseña del usuario
otp_attempt | string | No | Código OTP (si 2FA está activado)

### Respuesta

Retorna un objeto que contiene el token de API.
