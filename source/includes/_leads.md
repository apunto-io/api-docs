# Prospectos

Un prospecto es un contacto con `kind` que incluye `prospect`. El alta lo crea así. El ciclo comercial sigue de aquí a una [oportunidad](#oportunidades).

<aside class="notice">
Los catálogos de <code>lead_status</code> y <code>lead_source</code> pueden estar recortados por cuenta. Si envías un valor fuera de ese catálogo, la API responde <strong>422</strong>.
</aside>

## Objeto Lead

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID interno |
| alias | string | Alias del contacto |
| name | string | Nombre |
| legal_name | string | Razón social |
| identification | string | Identificación |
| id_fiscal | string | RFC u otra identificación fiscal |
| kind | array | En el alta queda `prospect` |
| status | string | `active` o `inactive` |
| lead_status | string | Estatus comercial |
| lead_status_label | string | Etiqueta del estatus |
| prospect_type | string | `direct` o `origin_agent` |
| lead_source | string | Origen del prospecto |
| seller | object | `{ id, name, email }` o `null` |
| created_at | datetime | Alta |
| updated_at | datetime | Último cambio |

El detalle (`GET /leads/:id`) agrega `description`, `services`, `credit_days` y `billing_address`.

**lead_status:** `new_lead`, `qualified`, `contacted`, `negotiation`, `closed`, `discarded`, `bad_timing`, `revalue`

**lead_source:** `referral`, `website`, `linkedin`, `event`, `cold_call`, `trade_show`, `inbound`, `other`

## Listar prospectos <span class="badge badge-success">GET</span>

```
GET /api/v1/leads
```

```shell
curl "https://control.apunto.io/api/v1/leads?lead_status=new_lead" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta

```json
{
  "leads": [
    {
      "id": 120,
      "alias": "ACME",
      "name": "Acme Logistics",
      "kind": ["prospect"],
      "status": "active",
      "lead_status": "new_lead",
      "lead_status_label": "Nuevo",
      "prospect_type": "direct",
      "lead_source": "inbound",
      "seller": { "id": 8, "name": "Ana Pérez", "email": "ana@apunto.com" }
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

| Parámetro | Descripción |
|-----------|-------------|
| lead_status | Filtra por estatus comercial |
| prospect_type | `direct` o `origin_agent` |
| lead_source | Origen |
| page | Página, default 1 |
| per_page | Default 25, máximo 100 |

## Obtener un prospecto <span class="badge badge-success">GET</span>

```
GET /api/v1/leads/:id
```

La respuesta envuelve el objeto en `lead`.

## Crear un prospecto <span class="badge badge-info">POST</span>

```
POST /api/v1/leads
```

```shell
curl -X POST "https://control.apunto.io/api/v1/leads" \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lead": {
      "name": "Acme Logistics",
      "alias": "ACME",
      "lead_status": "new_lead",
      "lead_source": "inbound",
      "prospect_type": "direct",
      "seller_email": "ana@apunto.com"
    }
  }'
```

```ruby
uri = URI("https://control.apunto.io/api/v1/leads")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer TU_TOKEN"
request["Content-Type"] = "application/json"
request.body = {
  lead: {
    name: "Acme Logistics",
    alias: "ACME",
    lead_status: "new_lead",
    lead_source: "inbound",
    prospect_type: "direct",
    seller_email: "ana@apunto.com"
  }
}.to_json
```

```python
import requests

requests.post(
    "https://control.apunto.io/api/v1/leads",
    headers={"Authorization": "Bearer TU_TOKEN"},
    json={
        "lead": {
            "name": "Acme Logistics",
            "alias": "ACME",
            "lead_status": "new_lead",
            "lead_source": "inbound",
            "prospect_type": "direct",
            "seller_email": "ana@apunto.com",
        }
    },
)
```

```javascript
await fetch("https://control.apunto.io/api/v1/leads", {
  method: "POST",
  headers: {
    Authorization: "Bearer TU_TOKEN",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    lead: {
      name: "Acme Logistics",
      alias: "ACME",
      lead_status: "new_lead",
      lead_source: "inbound",
      prospect_type: "direct",
      seller_email: "ana@apunto.com"
    }
  })
});
```

`name` es obligatorio. `seller_email` es el correo de un usuario de la cuenta; también puedes mandar `seller_id`.

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| name | Sí | Nombre |
| alias | No | Alias |
| legal_name | No | Razón social |
| identification | No | Identificación |
| id_fiscal | No | Identificación fiscal |
| trade_identification | No | Identificación comercial |
| description | No | Notas |
| status | No | `active` o `inactive` |
| nationality | No | Nacionalidad |
| credit_days | No | Días de crédito |
| lead_status | No | Estatus comercial |
| prospect_type | No | `direct` o `origin_agent` |
| lead_source | No | Origen |
| seller_id | No | ID del vendedor |
| seller_email | No | Correo del vendedor en la cuenta |
| kind | No | Arreglo; el alta usa `prospect` |
| services | No | `maritime`, `aerial`, `land`, `customs` |

Respuesta **201** con `{ "lead": { ... }, "message": "..." }`. El detalle incluye `description`, `services`, `credit_days` y `billing_address`.

## Actualizar un prospecto <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/leads/:id
```

Mismo cuerpo `{ "lead": { ... } }` que en el alta. Los campos que no envías se quedan como están.

## Cambiar estatus <span class="badge badge-warning">PATCH</span>

```
PATCH /api/v1/leads/:id/transition
```

```json
{ "lead_status": "qualified" }
```

También se acepta anidado en `lead`. El valor tiene que estar en el catálogo de la cuenta, o ser el estatus actual.

## Eliminar un prospecto <span class="badge badge-danger">DELETE</span>

```
DELETE /api/v1/leads/:id
```

Si el contacto no se puede borrar, la respuesta trae `errors`, `blocking_counts` y `can_archive`.
