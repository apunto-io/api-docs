# Contactos

Clientes y proveedores de la cuenta. Los prospectos viven en [Prospectos](#prospectos).

## Objeto Contact

> Ejemplo de detalle (`GET /api/v1/contacts/:id`):

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "legal_name": "ACME LOGISTICS SA DE CV",
    "identification": "ALO010101AB1",
    "id_fiscal": null,
    "kind": ["client"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "nationality": "mexican",
    "email": "facturas@acme.mx",
    "phone": "+52 81 1111 2222",
    "emails": [{ "email": "facturas@acme.mx", "label": "work", "primary": true }],
    "phones": [{ "number": "+52 81 1111 2222", "label": "work", "primary": true }],
    "tags": ["aspel"],
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" },
    "description": null,
    "services": [],
    "credit_days": 30,
    "payment_method": { "code": "03", "name": "Transferencia electrónica de fondos" },
    "payment_type": { "code": "PPD", "name": "Pago en parcialidades o diferido" },
    "cfdi_use": { "code": "G03", "name": "Gastos en general" },
    "billing_address": {
      "id": 431, "alias": "ACME", "name": "Fiscal", "address_type": "billing",
      "street": "Av. Constitución", "outdoor_number": "100", "internal_number": null,
      "neighborhood": "Centro", "city": "Monterrey", "state": "NLE", "country": "MX",
      "postal_code": "64000", "full_address": "Av. Constitución 100, Centro, Monterrey, NLE, 64000, MX"
    },
    "created_at": "2026-11-11T10:00:00.000-06:00",
    "updated_at": "2026-11-11T10:00:00.000-06:00"
  }
}
```

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador
alias | string | Código único del contacto en la cuenta. Es el `contact_code` / `supplier_code` del resto del API
name | string | Nombre comercial
legal_name | string | Razón social (se guarda en mayúsculas)
identification | string | RFC (México)
id_fiscal | string | Identificador fiscal extranjero
kind | array | `client`, `supplier`, …
status | string | Estatus del catálogo (`active`, …). Archivar no lo cambia
archived / archived_at | boolean / datetime | Archivado
email / phone | string | Correo y teléfono principales
emails / phones | array | Todos los correos y teléfonos
tags | array | Etiquetas
contact_tax_regime | object | Régimen fiscal SAT (`code`, `name`)
payment_method / payment_type / cfdi_use | object | Catálogos SAT (`code`, `name`)
billing_address | object | Domicilio fiscal

El listado (`GET /api/v1/contacts`) devuelve un resumen sin correos, teléfonos, etiquetas ni domicilio.

## Listar contactos <span class="badge badge-success">GET</span>

```shell
curl "https://control.apunto.io/api/v1/contacts?kind=client&per_page=100" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

`GET /api/v1/contacts`

Parámetro | Descripción
--------- | -----------
kind | Filtra por tipo (`client`, `supplier`)
status | Filtra la columna `status`
archived | `true` lista solo archivados
updated_since / deleted_since | Sincronización incremental (ver [Información general](#sincronizacion-incremental-updated_since-deleted_since))
page / per_page | Paginación (máximo 100)

## Buscar contactos <span class="badge badge-success">GET</span>

```shell
curl "https://control.apunto.io/api/v1/contacts/search?q=ALO010101AB1" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

`GET /api/v1/contacts/search?q=`

Busca contactos vivos por alias, RFC (`identification`) o identificador fiscal exactos; si no hay coincidencia exacta, busca por nombre, alias, RFC o razón social. Responde `{ "contacts": [...], "pagination": {...} }`.

## Obtener un contacto <span class="badge badge-success">GET</span>

`GET /api/v1/contacts/:id`

`:id` acepta el id numérico o el alias.

## Crear un contacto <span class="badge badge-info">POST</span>

```shell
curl -X POST "https://control.apunto.io/api/v1/contacts" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "name": "Acme Logistics",
      "legal_name": "Acme Logistics SA de CV",
      "alias": "ACME",
      "identification": "ALO010101AB1",
      "kind": ["client"],
      "contact_tax_regime_code": "601",
      "cfdi_use_code": "G03",
      "payment_method_code": "03",
      "payment_type_code": "PPD",
      "credit_days": 30,
      "email": "facturas@acme.mx",
      "phone": "+52 81 1111 2222",
      "tag_list": ["aspel"],
      "billing_address_attributes": {
        "name": "Fiscal", "street": "Av. Constitución", "outdoor_number": "100",
        "neighborhood": "Centro", "city": "Monterrey", "state": "NLE",
        "country": "MX", "postal_code": "64000"
      }
    }
  }'
```

`POST /api/v1/contacts` — responde **201** con el detalle.

Parámetro | Requerido | Descripción
--------- | --------- | -----------
name | Sí | Nombre comercial
kind | Sí | Arreglo de tipos (`client`, `supplier`)
alias | No | Sin espacios. Único en la cuenta. Si no lo mandas se genera con las primeras letras del nombre (`ACMEL`, `ACMEL2`, …)
legal_name, identification, id_fiscal, trade_identification, description, nationality, credit_days | No | Datos generales y fiscales
contact_tax_regime_code | No | Régimen fiscal SAT (`601`, `612`, …)
cfdi_use_code, payment_method_code, payment_type_code | No | Catálogos SAT
email, phone | No | Correo y teléfono principales. En `PATCH`, un valor vacío los quita
tag_list | No | Etiquetas que **ya existen** en el catálogo de la cuenta (Configuración → Etiquetas)
billing_address_attributes | No | Domicilio fiscal: `name`, `alias`, `street`, `outdoor_number`, `internal_number`, `neighborhood`, `city`, `state`, `country` (2 letras), `postal_code`

Un código que no existe (régimen, uso CFDI, forma o método de pago), una etiqueta fuera del catálogo o un alias repetido responden **422**; el contacto no se guarda.

Para facturar a un cliente mexicano, el contacto necesita razón social, RFC, régimen fiscal y domicilio fiscal.

## Actualizar un contacto <span class="badge badge-warning">PATCH</span>

`PATCH /api/v1/contacts/:id` con los mismos campos del alta. `billing_address_attributes` actualiza el domicilio fiscal existente; no crea un segundo domicilio.

## Domicilio fiscal: `/contacts/:id/addresses`

El contacto tiene **un** domicilio fiscal. Estas rutas lo leen y escriben:

Ruta | Qué hace
---- | --------
`GET /api/v1/contacts/:id/addresses` | Lista el domicilio fiscal (0 o 1 elemento)
`POST /api/v1/contacts/:id/addresses` | Crea el domicilio fiscal. Si ya existe responde 422 con su `address_id`
`GET` / `PATCH` / `DELETE /api/v1/contacts/:id/addresses/:address_id` | Lee, cambia o elimina ese domicilio

Leer necesita permiso para ver el contacto; escribir, permiso para editarlo.

## Alta rápida (prospecto) <span class="badge badge-info">POST</span>

`POST /api/v1/contacts/quick_create` con `{ "contact": { "name": "...", "description": "..." } }` crea un **prospecto**, no un cliente. Responde `type: "Lead"` y la `url` donde se consulta (`/api/v1/leads/:id`).

## Archivar, restaurar y eliminar

Ruta | Qué hace
---- | --------
`POST /api/v1/contacts/:id/archive` | Lo saca de los listados vivos. Manda `"confirmed": true` si la respuesta pide confirmar
`POST /api/v1/contacts/:id/restore` | Lo regresa
`DELETE /api/v1/contacts/:id` | Borrado lógico. Si tiene historial (folios, solicitudes, cotizaciones) responde 422 `code: has_history` y sugiere archivar

Un contacto archivado es de solo lectura: `PATCH` responde 422 hasta que lo restauras.
