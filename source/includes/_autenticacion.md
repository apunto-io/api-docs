# Autenticación

Cada petición lleva un **token de API** en el header `Authorization`. El token pertenece a un usuario de tu cuenta y la API actúa con sus permisos.

## Tokens de API

Crea los tokens en **Configuración → Tokens de API**. Puedes tener varios (uno por integración) y revocarlos cuando quieras; revocar uno no afecta a los demás.

Envía el token en cada petición:

`Authorization: Bearer <token>`

El esquema `Authorization: token <token>` también se acepta, pero usa `Bearer`.

> Petición autenticada

```shell
curl https://control.apunto.io/api/v1/operations \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Accept: application/json"
```

```javascript
await fetch("https://control.apunto.io/api/v1/operations", {
  headers: {
    Authorization: `Bearer ${process.env.APUNTO_TOKEN}`,
    Accept: "application/json",
  },
});
```

```python
requests.get(
    "https://control.apunto.io/api/v1/operations",
    headers={"Authorization": f"Bearer {os.environ['APUNTO_TOKEN']}"},
)
```

```ruby
req = Net::HTTP::Get.new(URI("https://control.apunto.io/api/v1/operations"))
req["Authorization"] = "Bearer #{ENV['APUNTO_TOKEN']}"
```

> Token inválido · 401

```json
{
  "error": "unauthorized",
  "message": "Token de API inválido, vencido o faltante. Envía el header Authorization: Bearer <token>.",
  "request_id": "fdbe995b-7f61-41d8-b9aa-17b9d4ce3c8c"
}
```

Situación | Respuesta
--------- | ---------
Sin header, token inexistente o vencido | **401** `unauthorized`
Usuario del token bloqueado | **403** `blocked`
Token válido sin permiso para la acción | **403** `forbidden` (ver [Permisos y alcance](#permisos-y-alcance))

<aside class="warning">Trata el token como una contraseña: guárdalo en un gestor de secretos, nunca en el repositorio ni en el navegador, y usa HTTPS siempre.</aside>

## Iniciar sesión con correo y contraseña

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/auth</code></div>

Devuelve un token a partir del correo y la contraseña del usuario. Sirve para apps que inician sesión a nombre de una persona. Para integraciones de servidor usa un token de Configuración: lo puedes nombrar y revocar, y no depende de la contraseña.

### Cuerpo de la petición

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`email` | string | <span class="req">obligatorio</span> Correo del usuario
`password` | string | <span class="req">obligatorio</span> Contraseña
`otp_attempt` | string | <span class="opt">opcional</span> Código de verificación, si el usuario tiene 2FA

### Respuesta

**200** con `{ "token": "..." }`. Siempre es el token predeterminado del usuario (se crea la primera vez) y es **distinto** de los tokens de Configuración; ambos funcionan.

### Errores

Código | Cuándo
------ | ------
`401` | Correo o contraseña incorrectos, o código OTP inválido
`403` | Usuario bloqueado
`422` | El usuario tiene 2FA y no mandaste `otp_attempt`
`429` | Demasiados intentos: 10 por minuto por IP o 5 cada 5 minutos por correo

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{ "email": "integracion@tuempresa.mx", "password": "••••••••" }'
```

> Respuesta 200

```json
{ "token": "vQ7nT2kLp9XcR4sWm8Ya3bZd" }
```

## Usuario del token

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/me</code></div>

Devuelve el usuario dueño del token y la cuenta con la que está operando. Úsalo para comprobar la conexión al arrancar tu integración.

> Respuesta 200

```json
{
  "id": 12,
  "name": "Integración ERP",
  "email": "integracion@tuempresa.mx",
  "time_zone": "America/Mexico_City",
  "preferred_language": "es",
  "avatar_url": null,
  "account": { "id": 3, "name": "Tu Empresa SA de CV" }
}
```

## Cuentas del usuario

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/accounts</code></div>

Lista las cuentas a las que pertenece el usuario. `current_account_id` es la cuenta que la API usa cuando no indicas otra.

> Respuesta 200

```json
{
  "accounts": [
    {
      "id": 3,
      "name": "Tu Empresa SA de CV",
      "personal": false,
      "owner_id": 1,
      "current": true,
      "created_at": "2026-01-10T16:00:00.000-06:00",
      "updated_at": "2026-11-01T09:12:00.000-06:00"
    }
  ],
  "current_account_id": 3
}
```

## Elegir la cuenta

Si el usuario pertenece a más de una cuenta, agrega `account_id` en cada petición (en la URL o en el cuerpo). Sin `account_id`, la API usa la cuenta de equipo más antigua del usuario. Un `account_id` de una cuenta a la que el usuario no pertenece se ignora.

> Operar en otra cuenta

```shell
curl "https://control.apunto.io/api/v1/operations?account_id=7" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

<aside class="notice">Para una integración, lo más simple es un usuario que pertenezca solo a la cuenta que vas a sincronizar. Así no dependes de <code>account_id</code>.</aside>

## Cerrar sesión

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/auth</code></div>

Cierra la sesión de una app que inició con `POST /api/v1/auth`. No revoca los tokens de Configuración: esos se revocan desde la plataforma.

<aside class="notice">No hay alta de usuarios por API. Los usuarios entran a la cuenta por invitación desde la plataforma.</aside>
