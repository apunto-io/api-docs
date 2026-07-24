# Motivos de cancelación

Catálogos configurados por cuenta (mismos valores que el modal web de cancelación). Úsalos para obtener el **id** o enviar el **name** al cancelar operaciones o servicios.

<aside class="notice">
<strong>Obligatoriedad</strong><br>
Si la cuenta tiene al menos un motivo <strong>activo</strong>, debes enviar <code>operation_cancellation_reason_id</code> <strong>o</strong> <code>operation_cancellation_reason_name</code> al cancelar una operación (igual con <code>service_*</code> en servicios).<br>
Si la cuenta <strong>no</strong> tiene motivos configurados, el motivo es opcional (como en la web cuando no hay catálogo).
</aside>

## Objeto CancellationReason

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID interno (usar en `*_cancellation_reason_id`) |
| name | string | Etiqueta visible (usar en `*_cancellation_reason_name`) |
| description | string | Descripción opcional |
| status | string | `active` (solo se listan activos) |

## Listar motivos — operaciones <span class="badge badge-success">GET</span>

```
GET /api/v1/operation_cancellation_reasons
```

> Ejemplo

```shell
curl "https://control.apunto.io/api/v1/operation_cancellation_reasons" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "operation_cancellation_reasons": [
    {
      "id": 3,
      "name": "Cliente canceló",
      "description": null,
      "status": "active"
    },
    {
      "id": 5,
      "name": "Ya no se requiere el servicio",
      "description": null,
      "status": "active"
    }
  ]
}
```

## Listar motivos — servicios <span class="badge badge-success">GET</span>

```
GET /api/v1/service_cancellation_reasons
```

> Respuesta JSON

```json
{
  "service_cancellation_reasons": [
    {
      "id": 2,
      "name": "Proveedor no disponible",
      "description": null,
      "status": "active"
    }
  ]
}
```

## Uso al cancelar

### Operación — POST /api/v1/operations/:id/cancel

| Parámetro | Requerido | Descripción |
|-----------|-----------|-------------|
| canceled_at | No | Fecha (default: hoy). En la web es obligatoria en el formulario. |
| operation_cancellation_reason_id | Condicional | ID del catálogo (ver GET arriba) |
| operation_cancellation_reason_name | Condicional | Nombre exacto del motivo (alternativa al id; no sensible a mayúsculas) |
| cancellation_notes | No | Notas adicionales |

Enviar **id o name**, no ambos obligatorios. Si envías un id/name inválido → **422**.

```json
{
  "operation_cancellation_reason_name": "Cliente canceló",
  "cancellation_notes": "El cliente desistió del embarque"
}
```

### Servicio — POST /api/v1/services/:id/cancel

| Parámetro | Requerido | Descripción |
|-----------|-----------|-------------|
| canceled_at | No | Fecha (default: hoy) |
| service_cancellation_reason_id | Condicional | ID del catálogo |
| service_cancellation_reason_name | Condicional | Nombre del motivo |
| cancellation_notes | No | Notas adicionales |

```json
{
  "service_cancellation_reason_id": 2,
  "cancellation_notes": "Proveedor declinó"
}
```

## Flujo recomendado para integraciones

1. `GET /api/v1/operation_cancellation_reasons` (o servicios) al iniciar sesión o cachear por cuenta.
2. Mostrar al usuario la lista de `name` (como el modal web).
3. Al cancelar, enviar `operation_cancellation_reason_name` con el texto elegido **o** el `id` obtenido del listado.

Los motivos se administran en la web en Configuración → Motivos de cancelación (operación / servicio); la API solo **lee** el catálogo activo.
