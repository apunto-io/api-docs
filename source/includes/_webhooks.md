# Webhooks

Los webhooks te permiten recibir notificaciones en tiempo real cuando ocurren ciertos eventos en tu cuenta.

## Eventos Disponibles

Evento | Descripción
------ | -----------
operation.created | Se crea una nueva operación
operation.updated | Se actualiza una operación
operation.status_changed | Cambia el estado de una operación
service.created | Se crea un nuevo servicio
service.updated | Se actualiza un servicio
service.status_changed | Cambia el estado de un servicio
task.created | Se crea una nueva tarea
task.completed | Se marca una tarea como completada
comment.created | Se agrega un nuevo comentario
contact.created | Se crea un nuevo contacto
contact.updated | Se actualiza un contacto
address.created | Se crea una nueva dirección
address.updated | Se actualiza una dirección

## Payload del Webhook

```json
{
  "event": "operation.status_changed",
  "timestamp": "2024-01-16T10:00:00Z",
  "data": {
    "id": 123,
    "identification": "IMP-MEX-001-2024",
    "old_status": "confirmed",
    "new_status": "active"
  },
  "account_id": 456
}
```

Todos los payloads de webhook incluyen:

Campo | Descripción
----- | -----------
event | El tipo de evento que disparó el webhook
timestamp | Cuándo ocurrió el evento (ISO 8601)
data | Datos específicos del evento
account_id | Tu ID de cuenta

## Firmas de Webhook

Todas las peticiones de webhook incluyen un header `X-Signature` que puedes usar para verificar que la petición proviene de Apunto.

La firma es un hash HMAC SHA256 del body de la petición usando tu secreto de webhook.

### Verificar la Firma

```ruby
require 'openssl'

def verificar_firma_webhook(payload, signature, secret)
  expected_signature = OpenSSL::HMAC.hexdigest(
    OpenSSL::Digest.new('sha256'),
    secret,
    payload
  )
  
  Rack::Utils.secure_compare(signature, expected_signature)
end
```

```python
import hmac
import hashlib

def verificar_firma_webhook(payload, signature, secret):
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(signature, expected_signature)
```

```javascript
const crypto = require('crypto');

function verificarFirmaWebhook(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
    
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}
```

## Configurar Webhooks

1. Navega a **Configuración** → **Webhooks** en tu cuenta
2. Haz clic en **Nuevo Webhook**
3. Ingresa la URL donde deseas recibir las notificaciones
4. Selecciona los eventos que deseas recibir
5. Guarda tu secreto de webhook de forma segura

## Reintentos

Si tu endpoint no responde con un código 2xx, Apunto intentará enviar el webhook de nuevo:

- Primer reintento: después de 1 minuto
- Segundo reintento: después de 5 minutos
- Tercer reintento: después de 30 minutos
- Cuarto reintento: después de 2 horas
- Quinto reintento: después de 6 horas

Después de 5 intentos fallidos, el webhook se desactivará automáticamente.

## Mejores Prácticas

1. **Responde rápidamente**: Procesa el webhook de forma asíncrona y responde con 200 OK inmediatamente
2. **Verifica la firma**: Siempre verifica el header `X-Signature` para confirmar que la petición viene de Apunto
3. **Maneja duplicados**: Usa el `event.id` o `timestamp` para detectar y manejar webhooks duplicados
4. **Usa HTTPS**: Solo acepta webhooks en URLs HTTPS
5. **Registra eventos**: Guarda los webhooks recibidos para debugging

