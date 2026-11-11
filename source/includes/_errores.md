# Errores

La API usa los códigos HTTP estándar y **un solo formato de error** para todos los endpoints. Un 2xx es éxito; un 4xx es un problema con la petición que debes corregir; un 5xx es un problema nuestro.

## Formato

Campo | Tipo | Descripción
----- | ---- | -----------
`error` | string | Código en formato máquina (`validation_failed`, `not_found`, …). Úsalo en tu lógica
`message` | string | Explicación para una persona, en el idioma de la cuenta
`errors` | array<string> | Lista de problemas. Siempre viene en **422**; en otros códigos puede faltar
`request_id` | string | Identificador de la petición. También viene en el header `X-Request-Id`
`fields` | array<string> | Solo en `read_only_fields`: los campos que no se escriben
`outcome`, `code`, `title`, `suggested_action` | | Solo en rechazos del [ciclo de vida](#archivar-restaurar-y-eliminar)

> Error 422

```json
{
  "error": "validation_failed",
  "message": "No se pudo crear la operación",
  "errors": [
    "Contact code Contacto no encontrado con el código proporcionado"
  ],
  "request_id": "5f7b2d1e-8a4c-4f0e-9b3d-2c6a1e8f7d90"
}
```

<aside class="success">Cuando reportes un problema a soporte, comparte el <code>request_id</code>. Con él encontramos la petición exacta en nuestros registros.</aside>

## Códigos

HTTP | `error` | Cuándo
---- | ------- | ------
400 | `invalid_json` | El cuerpo no es JSON válido
400 | `bad_request` | La petición está mal formada
401 | `unauthorized` | Falta el token, no existe o venció
401 | `invalid_credentials` | `POST /auth`: correo o contraseña incorrectos
401 | `invalid_otp` | `POST /auth`: código de verificación incorrecto
401 | `inactive_user` | `POST /auth`: el usuario no está activo (por ejemplo, no confirmó su correo)
403 | `forbidden` | El usuario no tiene el permiso que pide la acción (ver [Permisos y alcance](#permisos-y-alcance))
403 | `blocked` | El usuario está bloqueado en la plataforma
404 | `not_found` | El registro no existe, es de otra cuenta, está eliminado o el usuario no lo puede ver
422 | `validation_failed` | Algún campo no pasó la validación. Revisa `errors`
422 | `parameter_missing` | Falta el objeto raíz (`contact`, `operation`, …) que pide el endpoint
422 | `read_only_fields` | Mandaste campos que no se escriben (estado, totales). Revisa `fields`
422 | `invalid_parameter` | Un parámetro de consulta no es válido (por ejemplo, `updated_since` con una fecha mal escrita)
422 | `not_destroyed` | El registro no se pudo eliminar
422 | `otp_attempt_required` | `POST /auth`: el usuario tiene verificación en dos pasos; manda `otp_attempt`
422 | código del ciclo de vida | `archived_read_only`, `has_opportunities`, `will_mark_lost`, … (ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar))
429 | `rate_limited` | Superaste el [límite de uso](#limites-de-uso). Espera `retry_after` segundos
500 | `internal_error` | Error inesperado de nuestro lado. Ya se reportó; comparte el `request_id` si persiste

<aside class="notice">Los registros de otra cuenta y los que el usuario no tiene permiso de ver responden igual que uno inexistente: <strong>404</strong>. Así la API no revela qué existe fuera de tu alcance. Si mandas uno de ellos como referencia (<code>contact_id</code>, <code>owner_id</code>, …) en un alta o cambio, la respuesta es <strong>422</strong>.</aside>

## Qué hacer con cada error

Tipo | Reintentar | Qué hacer
---- | ---------- | ---------
400, 422 | No | Corrige la petición. Guarda `errors` en tu log para saber qué falló
401 | No | Revisa o reemplaza el token
403 | No | Pide al administrador de la cuenta el permiso que falta
404 | No | Verifica el `id`, la cuenta (`account_id`) y la visibilidad del usuario
429 | Sí | Espera los segundos de `Retry-After` y repite
500, 502, 503, 504 | Sí, con espera | Reintenta con espera exponencial (1 s, 2 s, 4 s…) hasta 5 veces

<aside class="warning">Reintentar un <code>POST</code> de alta después de un timeout puede crear un duplicado si la primera petición sí llegó. Antes de repetirla, busca el registro por su código (por ejemplo, <code>client_ref</code> del folio o <code>alias</code> del contacto).</aside>

> Reintentos

```javascript
async function apiWithRetry(path, options = {}, attempt = 0) {
  const res = await api(path, options);
  const retryable = res.status === 429 || res.status >= 500;
  if (!retryable || attempt >= 5) return res;

  const wait = res.status === 429
    ? (res.body.retry_after ?? 60) * 1000
    : 2 ** attempt * 1000;
  await new Promise((r) => setTimeout(r, wait));
  return apiWithRetry(path, options, attempt + 1);
}
```

```python
import time

def api_with_retry(method, path, attempt=0, **kwargs):
    res = api.request(method, f"{BASE}{path}", **kwargs)
    retryable = res.status_code == 429 or res.status_code >= 500
    if not retryable or attempt >= 5:
        return res
    wait = int(res.headers.get("Retry-After", 60)) if res.status_code == 429 else 2 ** attempt
    time.sleep(wait)
    return api_with_retry(method, path, attempt + 1, **kwargs)
```
