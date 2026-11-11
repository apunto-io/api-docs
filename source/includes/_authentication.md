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
curl "https://control.apunto.io/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://control.apunto.io/api/v1/operations")
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
    'https://control.apunto.io/api/v1/operations',
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

axios.get('https://control.apunto.io/api/v1/operations', config)
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
curl -X POST "https://control.apunto.io/api/v1/auth" \
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

uri = URI.parse("https://control.apunto.io/api/v1/auth")
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

url = 'https://control.apunto.io/api/v1/auth'
payload = {
    'email': 'usuario@ejemplo.com',
    'password': 'tu_contraseña'
}

response = requests.post(url, json=payload)
token = response.json()['token']
```

```javascript
const axios = require('axios');

axios.post('https://control.apunto.io/api/v1/auth', {
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
  "token": "vQ7nT2kLp9XcR4sWm8Ya3bZd"
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

<aside class="notice">
El login devuelve siempre el token predeterminado del usuario (lo crea la primera vez). Es <strong>distinto</strong> del token que creaste en <strong>Configuración → Tokens de API</strong>; ambos sirven. Para integraciones de servidor usa el token de Configuración: lo puedes nombrar, revocar y no depende de la contraseña.
</aside>

Respuesta | Cuándo
--------- | ------
200 | Credenciales válidas
401 | Correo o contraseña incorrectos, o falta el código OTP válido
403 | Usuario bloqueado
422 | El usuario tiene 2FA y no mandaste `otp_attempt`
429 | Demasiados intentos (10 por minuto por IP, 5 cada 5 minutos por correo)

El alta de usuarios por API no existe: los usuarios entran por invitación desde la web.

## Esquema del header

`Authorization: Bearer TU_TOKEN_API` es el formato recomendado. El esquema `Authorization: token TU_TOKEN_API` también se acepta. Un token faltante, inválido o vencido responde **401** con cuerpo JSON:

```json
{
  "error": "unauthorized",
  "message": "Token de API inválido, vencido o faltante. Envía el header Authorization: Bearer <token>.",
  "request_id": "fdbe995b-7f61-41d8-b9aa-17b9d4ce3c8c"
}
```

## Usuario y cuenta del token

### `GET /api/v1/me`

Prueba de conexión. Devuelve el usuario del token y la cuenta con la que está operando.

```json
{
  "id": 12,
  "name": "Integración Aspel",
  "email": "integracion@empresa.mx",
  "time_zone": "America/Mexico_City",
  "preferred_language": "es",
  "avatar_url": null,
  "account": { "id": 3, "name": "Mi Empresa SA de CV" }
}
```

### `GET /api/v1/accounts`

Cuentas a las que pertenece el usuario. `current_account_id` es la cuenta que usa la API cuando no mandas `account_id`.

```json
{
  "accounts": [
    { "id": 3, "name": "Mi Empresa SA de CV", "personal": false, "owner_id": 1, "current": true,
      "created_at": "2026-01-10T16:00:00.000-06:00", "updated_at": "2026-11-01T09:12:00.000-06:00" }
  ],
  "current_account_id": 3
}
```

### Elegir la cuenta: `account_id`

Si el usuario del token pertenece a más de una cuenta, agrega `account_id` (query string o cuerpo) en cada petición para operar sobre una cuenta específica. Sin `account_id`, la API usa la cuenta de equipo más antigua del usuario. Un `account_id` de una cuenta a la que el usuario no pertenece se ignora.
