# Oportunidades

Una oportunidad es un negocio sobre un contacto. Para marcarla `won` tiene que tener al menos una [solicitud comercial](#solicitudes-comerciales) ligada.

## Objeto Opportunity

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID interno |
| identification | string | Folio, por ejemplo `OP-00012` |
| title | string | Título |
| status | string | Estatus |
| status_label | string | Etiqueta |
| frequency | string | Frecuencia esperada |
| frequency_label | string | Etiqueta de la frecuencia |
| operations_volume | integer | Volumen de operaciones |
| detail | string | Detalle |
| contact | object | `{ id, alias, name }` o `null` |
| owner | object | `{ id, name, email }` o `null` |
| tags | array | Etiquetas |
| created_at | datetime | Alta |
| updated_at | datetime | Último cambio |

El detalle agrega `quote_requests_count` y `opportunity_actions_count`.

**status:** `created`, `in_progress`, `in_negotiation`, `won`, `lost`

**frequency:** `daily`, `weekly`, `monthly`, `semiannual`, `annual`

## Listar oportunidades <span class="badge badge-success">GET</span>

```
GET /api/v1/opportunities
```

```shell
curl "https://control.apunto.io/api/v1/opportunities?status=in_progress" \
  -H "Authorization: Bearer TU_TOKEN"
```

| Parámetro | Descripción |
|-----------|-------------|
| status | Filtra por estatus |
| page | Página, default 1 |
| per_page | Default 25, máximo 100 |

La respuesta es `{ "opportunities": [ ... ], "pagination": { "page", "per_page", "total" } }`.

## Obtener una oportunidad <span class="badge badge-success">GET</span>

```
GET /api/v1/opportunities/:id
```

También puedes buscar por folio en otros recursos con `opportunity_identification` (el campo `identification`).

## Crear una oportunidad <span class="badge badge-info">POST</span>

```
POST /api/v1/opportunities
```

```shell
curl -X POST "https://control.apunto.io/api/v1/opportunities" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "opportunity": {
      "title": "Importación FCL Manzanillo",
      "contact_code": "ACME",
      "owner_email": "ana@apunto.com",
      "frequency": "monthly",
      "operations_volume": 4
    }
  }'
```

```ruby
request.body = {
  opportunity: {
    title: "Importación FCL Manzanillo",
    contact_code: "ACME",
    owner_email: "ana@apunto.com",
    frequency: "monthly",
    operations_volume: 4
  }
}.to_json
```

```python
requests.post(
    "https://control.apunto.io/api/v1/opportunities",
    headers={"Authorization": "Bearer TU_TOKEN"},
    json={
        "opportunity": {
            "title": "Importación FCL Manzanillo",
            "contact_code": "ACME",
            "frequency": "monthly",
            "operations_volume": 4,
        }
    },
)
```

```javascript
await fetch("https://control.apunto.io/api/v1/opportunities", {
  method: "POST",
  headers: {
    Authorization: "Bearer TU_TOKEN",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    opportunity: {
      title: "Importación FCL Manzanillo",
      contact_code: "ACME",
      frequency: "monthly",
      operations_volume: 4
    }
  })
});
```

`title` va en el cuerpo. El contacto es obligatorio: `contact_id` o `contact_code` (el alias del contacto, en mayúsculas). Si no mandas dueño, queda el usuario del token.

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| title | Sí | Título |
| contact_id | Sí, o `contact_code` | ID del contacto |
| contact_code | Sí, o `contact_id` | Alias del contacto |
| owner_id | No | ID del dueño |
| owner_email | No | Correo de un usuario de la cuenta |
| frequency | No | Frecuencia |
| operations_volume | No | Volumen |
| detail | No | Detalle |
| status | No | Estatus inicial |
| tag_list | No | Arreglo de etiquetas |

Respuesta **201** con `{ "opportunity": { ... }, "message": "..." }`.

## Actualizar una oportunidad <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/opportunities/:id
```

Mismo cuerpo `{ "opportunity": { ... } }`.

## Cambiar estatus <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/opportunities/:id/transition
```

```json
{ "status": "in_progress" }
```

También se acepta `{ "opportunity": { "status": "in_progress" } }`. Pasar a `won` sin una solicitud comercial ligada responde **422**.

## Eliminar una oportunidad <span class="badge badge-danger">DELETE</span>

```
DELETE /api/v1/opportunities/:id
```

Respuesta con `{ "message": "..." }`.
