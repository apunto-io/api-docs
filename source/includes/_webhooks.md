# Webhooks

Los webhooks permiten recibir notificaciones en tiempo real.

## Eventos Disponibles

Evento | Descripción
------ | -----------
operation.created | Nueva operación creada
operation.status_changed | Cambio de estado
service.created | Nuevo servicio creado
service.status_changed | Cambio de estado
task.created | Nueva tarea
task.completed | Tarea completada
comment.created | Nuevo comentario

## Payload

```json
{
  "event": "operation.status_changed",
  "timestamp": "2024-01-16T10:00:00Z",
  "data": {
    "id": 123,
    "old_status": "confirmed",
    "new_status": "active"
  },
  "account_id": 456
}
```

## Verificación de Firma

Todas las peticiones incluyen header `X-Signature` con hash HMAC SHA256.

```ruby
def verify_webhook_signature(payload, signature, secret)
  expected = OpenSSL::HMAC.hexdigest(
    OpenSSL::Digest.new('sha256'),
    secret,
    payload
  )
  Rack::Utils.secure_compare(signature, expected)
end
```
