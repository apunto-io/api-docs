# Errores

La API de Apunto utiliza códigos de respuesta HTTP convencionales para indicar el éxito o fracaso de una petición.

## Códigos de Estado HTTP

Código | Significado | Descripción
------ | ----------- | -----------
200 | OK | La petición fue exitosa
201 | Created | El recurso fue creado exitosamente
204 | No Content | La petición fue exitosa sin contenido a retornar (típicamente para DELETE)
400 | Bad Request | La petición es inválida o no puede ser procesada
401 | Unauthorized | Autenticación fallida o token de API faltante/inválido
403 | Forbidden | No tienes permiso para acceder a este recurso
404 | Not Found | El recurso solicitado no existe
422 | Unprocessable Entity | Validación fallida - revisa la respuesta para más detalles
429 | Too Many Requests | Límite de tasa excedido
500 | Internal Server Error | Algo salió mal en nuestro servidor
503 | Service Unavailable | Problema temporal del servidor - intenta de nuevo más tarde

## Formato de Respuesta de Error

> Ejemplo de Respuesta de Error:

```json
{
  "error": "Validación fallida",
  "message": "La operación no pudo ser creada debido a errores de validación",
  "details": {
    "contact_id": ["no puede estar en blanco"],
    "kind": ["no está incluido en la lista"],
    "mode": ["no puede estar en blanco"]
  },
  "status": 422
}
```

Todas las respuestas de error siguen este formato:

Campo | Tipo | Descripción
----- | ---- | -----------
error | string | Tipo de error corto
message | string | Mensaje de error legible
details | object | Errores de validación detallados (para respuestas 422)
status | integer | Código de estado HTTP

## Errores Comunes

### Error de Autenticación

```json
{
  "error": "No autorizado",
  "message": "Token de API inválido o faltante",
  "status": 401
}
```

**Causa:** Falta el header `Authorization` o el token es inválido.

**Solución:** Asegúrate de enviar un token de API válido en el formato `Bearer TU_TOKEN_API`.

### Error de Validación

```json
{
  "error": "Validación fallida",
  "message": "El recurso no pudo ser guardado",
  "details": {
    "title": ["no puede estar en blanco"],
    "email": ["es inválido"]
  },
  "status": 422
}
```

**Causa:** Campos requeridos faltantes o datos que no cumplen requisitos de validación.

**Solución:** Revisa el objeto `details` para errores específicos de campos y corrige los datos.

### Recurso No Encontrado

```json
{
  "error": "No encontrado",
  "message": "La operación solicitada no fue encontrada",
  "status": 404
}
```

**Causa:** El ID del recurso no existe o no tienes acceso a él.

**Solución:** Verifica que el ID del recurso sea correcto y que tengas permiso para accederlo.

### Límite de Tasa Excedido

```json
{
  "error": "Límite de tasa excedido",
  "message": "Has excedido el límite de tasa. Por favor, intenta de nuevo más tarde.",
  "retry_after": 3600,
  "status": 429
}
```

**Causa:** Demasiadas peticiones en un período corto de tiempo.

**Solución:** Espera el tiempo especificado en `retry_after` (segundos) antes de hacer más peticiones. Implementa backoff exponencial en tu aplicación.

### Permiso Denegado

```json
{
  "error": "Prohibido",
  "message": "No tienes permiso para realizar esta acción",
  "status": 403
}
```

**Causa:** Tu cuenta o token de API no tiene los permisos requeridos.

**Solución:** Contacta al administrador de tu cuenta para solicitar los permisos necesarios.

### Error del Servidor

```json
{
  "error": "Error Interno del Servidor",
  "message": "Ocurrió un error inesperado. Por favor, intenta de nuevo más tarde.",
  "status": 500
}
```

**Causa:** Un error inesperado en el servidor.

**Solución:** Intenta la petición de nuevo. Si el problema persiste, contacta a soporte con los detalles de la petición.

## Mejores Prácticas para Manejo de Errores

1. **Siempre revisa códigos de estado** - No confíes solo en el cuerpo de la respuesta
2. **Implementa lógica de reintentos** - Para errores 5xx y límites de tasa (429)
3. **Usa backoff exponencial** - Al reintentar peticiones fallidas
4. **Registra detalles de errores** - Guarda respuestas de error para debugging
5. **Valida antes de enviar** - Reduce errores 422 validando datos del lado del cliente primero
6. **Maneja expiración de tokens** - Prepárate para refrescar o solicitar nuevos tokens
7. **Proporciona feedback al usuario** - Muestra mensajes de error significativos a los usuarios finales

## Ejemplo de Manejo de Errores

```ruby
require 'net/http'
require 'json'

def hacer_peticion_api(url, metodo = :get, body = nil)
  uri = URI(url)
  request = case metodo
            when :get then Net::HTTP::Get.new(uri)
            when :post then Net::HTTP::Post.new(uri)
            when :patch then Net::HTTP::Patch.new(uri)
            when :delete then Net::HTTP::Delete.new(uri)
            end
  
  request['Authorization'] = "Bearer #{ENV['API_TOKEN']}"
  request['Content-Type'] = 'application/json'
  request.body = body.to_json if body
  
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  
  case response.code.to_i
  when 200..299
    JSON.parse(response.body)
  when 401
    raise 'Autenticación fallida. Revisa tu token de API.'
  when 404
    raise 'Recurso no encontrado.'
  when 422
    errors = JSON.parse(response.body)
    raise "Validación fallida: #{errors['details']}"
  when 429
    retry_after = response['Retry-After'].to_i
    sleep(retry_after)
    hacer_peticion_api(url, metodo, body) # Reintentar
  when 500..599
    raise 'Error del servidor. Por favor, intenta de nuevo más tarde.'
  else
    raise "Error inesperado: #{response.code}"
  end
rescue JSON::ParserError
  raise 'Respuesta JSON inválida del servidor'
end
```

```python
import requests
import time
from typing import Dict, Any

def hacer_peticion_api(url: str, metodo: str = 'GET', body: Dict = None) -> Dict[Any, Any]:
    headers = {
        'Authorization': f'Bearer {os.environ["API_TOKEN"]}',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.request(metodo, url, json=body, headers=headers)
        
        if 200 <= response.status_code < 300:
            return response.json()
        elif response.status_code == 401:
            raise Exception('Autenticación fallida. Revisa tu token de API.')
        elif response.status_code == 404:
            raise Exception('Recurso no encontrado.')
        elif response.status_code == 422:
            errors = response.json()
            raise Exception(f'Validación fallida: {errors.get("details")}')
        elif response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            time.sleep(retry_after)
            return hacer_peticion_api(url, metodo, body)  # Reintentar
        elif response.status_code >= 500:
            raise Exception('Error del servidor. Por favor, intenta de nuevo más tarde.')
        else:
            raise Exception(f'Error inesperado: {response.status_code}')
            
    except requests.exceptions.RequestException as e:
        raise Exception(f'Petición fallida: {str(e)}')
```

```javascript
const axios = require('axios');

async function hacerPeticionApi(url, metodo = 'GET', body = null) {
  const config = {
    method: metodo,
    url: url,
    headers: {
      'Authorization': `Bearer ${process.env.API_TOKEN}`,
      'Content-Type': 'application/json'
    },
    data: body
  };
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      const data = error.response.data;
      
      switch (status) {
        case 401:
          throw new Error('Autenticación fallida. Revisa tu token de API.');
        case 404:
          throw new Error('Recurso no encontrado.');
        case 422:
          throw new Error(`Validación fallida: ${JSON.stringify(data.details)}`);
        case 429:
          const retryAfter = parseInt(error.response.headers['retry-after']) || 60;
          await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
          return hacerPeticionApi(url, metodo, body); // Reintentar
        case 500:
        case 502:
        case 503:
          throw new Error('Error del servidor. Por favor, intenta de nuevo más tarde.');
        default:
          throw new Error(`Error inesperado: ${status}`);
      }
    } else if (error.request) {
      throw new Error('Sin respuesta del servidor');
    } else {
      throw new Error(`Petición fallida: ${error.message}`);
    }
  }
}
```
