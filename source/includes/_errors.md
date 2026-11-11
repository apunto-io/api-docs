# Errores

La API usa códigos de estado HTTP convencionales y **siempre** responde JSON, también en los errores.

## Códigos de estado HTTP

Código | Significado | Cuándo
------ | ----------- | ------
200 | OK | Lectura, cambio, archivo, restauración o borrado exitoso (el `DELETE` responde 200 con cuerpo)
201 | Created | Alta exitosa
400 | Bad Request | Falta el recurso padre en una ruta anidada o la petición no se puede interpretar
401 | Unauthorized | Token faltante, inválido o vencido
403 | Forbidden | El usuario del token no tiene el permiso para esa acción, o está bloqueado
404 | Not Found | El registro no existe, es de otra cuenta o el usuario no puede verlo
422 | Unprocessable Entity | Validación, código inexistente, campo de solo lectura o una regla de negocio que impide la acción
429 | Too Many Requests | Límite de peticiones excedido
500 | Internal Server Error | Error inesperado; el cuerpo trae `request_id` para soporte

## Formato del error

> Ejemplo de error de validación:

```json
{
  "error": "validation_failed",
  "message": "Moneda no puede estar en blanco y Contacto no puede estar en blanco",
  "errors": [
    "Moneda no puede estar en blanco",
    "Contacto no puede estar en blanco"
  ],
  "request_id": "0f055872-5929-4ab8-ab2c-128a6029f73b"
}
```

Campo | Tipo | Descripción
----- | ---- | -----------
error | string | Código corto del tipo de error (`unauthorized`, `forbidden`, `not_found`, `validation_failed`, `read_only_fields`, `invalid_parameter`, `rate_limited`, `internal_error`)
message | string | Mensaje legible
errors | array de string | Mensajes de validación, cuando aplica
request_id | string | Identificador de la petición; compártelo con soporte

Algunas respuestas 422 de altas y cambios traen solo `errors` y `message` (sin `error`). Lee siempre `errors` cuando exista.

## Errores comunes

### Token faltante, inválido o vencido (401)

```json
{
  "error": "unauthorized",
  "message": "Token de API inválido, vencido o faltante. Envía el header Authorization: Bearer <token>.",
  "request_id": "fdbe995b-7f61-41d8-b9aa-17b9d4ce3c8c"
}
```

### Sin permiso (403)

```json
{
  "error": "forbidden",
  "message": "No tienes permiso para esta acción.",
  "request_id": "97300d19-d813-463b-8313-c5d0101274b9"
}
```

El token actúa con los permisos del usuario dueño: rol, permisos por módulo y visibilidad de registros (todos, de su equipo o solo propios). Si el usuario no puede hacerlo en la web, la API responde 403. Si el usuario no puede ver un registro, la API responde 404.

### Campo de solo lectura (422)

```json
{
  "error": "read_only_fields",
  "message": "El status del folio cambia con sus acciones: POST /operations/:id/close, /reopen o /cancel.",
  "errors": ["status no se escribe en esta petición"],
  "fields": ["status"],
  "request_id": "1ca64730-86f5-4ed8-8a37-3b0ff028a4b7"
}
```

El estado de folios, servicios, cotizaciones y solicitudes cambia con sus acciones, no con `PATCH`. Los totales del folio (`profit_amount`, `income_amount`, `expense_amount`, `profit_percentage`) se calculan desde los centros de costos.

### Registro de otra cuenta (422)

Un id que pertenece a otra cuenta (contacto, folio, lista, oportunidad, concepto o usuario) se rechaza con el mensaje «no pertenece a esta cuenta».

### Confirmación pendiente (422)

Archivar, cancelar o borrar algunos registros pide confirmar las consecuencias. La primera respuesta trae el aviso:

```json
{
  "outcome": "confirm",
  "code": "needs_confirmation",
  "message": "Esta cotización quedará perdida…",
  "errors": ["Esta cotización quedará perdida…"]
}
```

Repite la misma petición con `"confirmed": true` para ejecutarla.

### Límite de peticiones (429)

```json
{
  "error": "rate_limited",
  "message": "Demasiadas peticiones al API. Espera 60 segundos e intenta de nuevo.",
  "retry_after": 60
}
```

Límite | Valor
------ | -----
Peticiones con token | 300 por minuto por token
`POST /api/v1/auth` por IP | 10 por minuto
`POST /api/v1/auth` por correo | 5 cada 5 minutos

Respeta el header `Retry-After` (segundos) y usa backoff exponencial.

### Error interno (500)

```json
{
  "error": "internal_error",
  "message": "Error interno del servidor. Comparte el request_id con soporte.",
  "request_id": "73fa43ec-33a5-4cd9-9802-23a754e198bc"
}
```

## Buenas prácticas

- Registra el status HTTP, el cuerpo y el `request_id` de cada error.
- No reintentes un 4xx sin corregir la petición. Reintenta 429 y 5xx con backoff.
- Pagina los listados; no pidas más de 100 registros por página.
