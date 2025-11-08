# Errores

La API usa códigos de estado HTTP convencionales para indicar éxito o fallo.

## Códigos de Estado HTTP

Código | Significado | Descripción
------ | ----------- | -----------
200 | OK | Petición exitosa
201 | Created | Recurso creado exitosamente
204 | No Content | Petición exitosa sin contenido (típicamente DELETE)
400 | Bad Request | Petición inválida
401 | Unauthorized | Autenticación fallida o token inválido
403 | Forbidden | No tienes permiso para este recurso
404 | Not Found | Recurso no encontrado
422 | Unprocessable Entity | Error de validación
429 | Too Many Requests | Límite de tasa excedido
500 | Internal Server Error | Error en el servidor
503 | Service Unavailable | Problema temporal del servidor

## Formato de Respuesta de Error

> Ejemplo de error:

```json
{
  "error": "Validation failed",
  "message": "No se pudo guardar el recurso",
  "details": {
    "contact_id": ["no puede estar en blanco"],
    "kind": ["no está incluido en la lista"],
    "mode": ["no puede estar en blanco"]
  },
  "status": 422
}
```

Todos los errores siguen este formato:

Campo | Tipo | Descripción
----- | ---- | -----------
error | string | Tipo de error corto
message | string | Mensaje de error legible
details | object | Detalles de validación (para errores 422)
status | integer | Código de estado HTTP

## Errores Comunes

### Error de Autenticación

```json
{
  "error": "Unauthorized",
  "message": "Token de API inválido o faltante",
  "status": 401
}
```

**Causa:** Header `Authorization` faltante o inválido.

**Solución:** Asegúrate de enviar un token válido en formato `Bearer TU_TOKEN_API`.

### Error de Validación

```json
{
  "error": "Validation failed",
  "message": "No se pudo guardar el recurso",
  "details": {
    "name": ["no puede estar en blanco"],
    "email": ["no es válido"]
  },
  "status": 422
}
```

**Causa:** Campos requeridos faltantes o datos que no cumplen validaciones.

**Solución:** Revisa el objeto `details` para errores específicos.

### Recurso No Encontrado

```json
{
  "error": "Not Found",
  "message": "No se encontró la operación solicitada",
  "status": 404
}
```

**Causa:** El ID del recurso no existe o no tienes acceso.

**Solución:** Verifica el ID y tus permisos.

### Límite de Tasa Excedido

```json
{
  "error": "Rate limit exceeded",
  "message": "Has excedido el límite. Intenta más tarde.",
  "retry_after": 3600,
  "status": 429
}
```

**Causa:** Demasiadas peticiones en poco tiempo.

**Solución:** Espera el tiempo en `retry_after` (segundos). Implementa backoff exponencial.

### Permiso Denegado

```json
{
  "error": "Forbidden",
  "message": "No tienes permiso para esta acción",
  "status": 403
}
```

**Causa:** Tu cuenta o token no tiene los permisos necesarios.

**Solución:** Contacta al administrador para solicitar permisos.

### Error del Servidor

```json
{
  "error": "Internal Server Error",
  "message": "Ocurrió un error inesperado. Intenta más tarde.",
  "status": 500
}
```

**Causa:** Error inesperado en el servidor.

**Solución:** Reintenta la petición. Si persiste, contacta soporte.

## Mejores Prácticas

1. **Verifica códigos de estado** - No te bases solo en el body
2. **Implementa reintentos** - Para errores 5xx y rate limits (429)
3. **Usa backoff exponencial** - Al reintentar peticiones fallidas
4. **Registra errores** - Guarda respuestas de error para debugging
5. **Valida antes de enviar** - Reduce errores 422 validando en cliente
6. **Maneja expiración de tokens** - Prepárate para refrescar tokens
7. **Mensajes al usuario** - Muestra errores significativos a usuarios finales

## Ejemplo de Manejo de Errores

```ruby
def make_api_request(url, method = :get, body = nil)
  # ... código de petición ...
  
  case response.code.to_i
  when 200..299
    JSON.parse(response.body)
  when 401
    raise 'Error de autenticación. Verifica tu token.'
  when 404
    raise 'Recurso no encontrado.'
  when 422
    errors = JSON.parse(response.body)
    raise "Errores de validación: #{errors['details']}"
  when 429
    retry_after = response['Retry-After'].to_i
    sleep(retry_after)
    make_api_request(url, method, body) # Reintentar
  when 500..599
    raise 'Error del servidor. Intenta más tarde.'
  end
end
```

```python
def make_api_request(url, method='GET', body=None):
    try:
        response = requests.request(method, url, json=body, headers=headers)
        
        if 200 <= response.status_code < 300:
            return response.json()
        elif response.status_code == 401:
            raise Exception('Error de autenticación')
        elif response.status_code == 404:
            raise Exception('Recurso no encontrado')
        elif response.status_code == 422:
            errors = response.json()
            raise Exception(f'Validación: {errors.get("details")}')
        elif response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            time.sleep(retry_after)
            return make_api_request(url, method, body)
        elif response.status_code >= 500:
            raise Exception('Error del servidor')
    except requests.exceptions.RequestException as e:
        raise Exception(f'Petición fallida: {str(e)}')
```

```javascript
async function makeApiRequest(url, method = 'GET', body = null) {
  try {
    const response = await axios({ method, url, data: body, headers });
    return response.data;
  } catch (error) {
    const status = error.response?.status;
    const data = error.response?.data;
    
    switch (status) {
      case 401:
        throw new Error('Error de autenticación');
      case 404:
        throw new Error('Recurso no encontrado');
      case 422:
        throw new Error(`Validación: ${JSON.stringify(data.details)}`);
      case 429:
        const retryAfter = parseInt(error.response.headers['retry-after']) || 60;
        await new Promise(r => setTimeout(r, retryAfter * 1000));
        return makeApiRequest(url, method, body);
      case 500:
      case 502:
      case 503:
        throw new Error('Error del servidor');
      default:
        throw new Error(`Error: ${status}`);
    }
  }
}
```
