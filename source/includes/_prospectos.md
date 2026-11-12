# Prospectos

<p class="lead">Un prospecto (<code>lead</code>) es una empresa con la que todavía no trabajas: la registras, le das seguimiento por etapas y, cuando cierra, la conviertes en cliente. Una integración los usa para cargar prospectos desde un CRM, un formulario web o una feria, y para leer en qué etapa va cada uno.</p>

Un prospecto es un contacto con `kind` `["prospect"]` que vive en `/api/v1/leads`, no en `/api/v1/contacts`. Puedes ligarle [oportunidades](#oportunidades), [solicitudes comerciales](#solicitudes-comerciales) y [cotizaciones](#cotizaciones) con su `id` o con su `alias` (`contact_code`).

`POST /api/v1/contacts/quick_create` también crea un prospecto: responde su `id` y su `url`, y el registro se lee en `GET /api/v1/leads/:id`. Ese endpoint se documenta en [Contactos](#contactos).

**Estados del prospecto (`lead_status`).** Cada cuenta tiene su catálogo de estados en **Configuración → Estados de Leads**. Puede renombrarlos, agregar estados propios y archivar los que no use; la clave (`key`) no cambia después de crearse. El catálogo inicial es este:

Clave | Leyenda | Tipo de etapa
--------- | ---- | -----------
`new_lead` | Nuevo | Abierto. Estado con el que nace un prospecto si no mandas otro
`qualified` | Calificado | Abierto
`contacted` | Contactado | Abierto
`negotiation` | Negociación | Abierto
`closed` | Cerrado | Cerrado
`discarded` | Descartado | Cerrado
`bad_timing` | Mal timing | Cerrado
`revalue` | Revalorar | Otro

- Los estados no siguen un orden: puedes pasar de cualquier estado a cualquier otro del catálogo, hacia adelante o hacia atrás.
- Solo se aceptan claves de estados **no archivados**. Si el prospecto ya está en un estado que después se archivó, puede quedarse ahí, pero no puedes mover otro prospecto a ese estado.
- No hay endpoint para leer el catálogo. Si mandas una clave que no existe en `POST /api/v1/leads` o en `PATCH /api/v1/leads/:id/transition`, el 422 trae la lista de claves válidas de la cuenta.
- Pasar a `closed` no convierte al prospecto en cliente. Ver [Convertir un prospecto en cliente](#convertir-un-prospecto-en-cliente).

El origen (`lead_source`) usa el mismo esquema, con su catálogo en **Configuración → Fuentes de Leads**. Claves iniciales: `referral`, `website`, `linkedin`, `event`, `cold_call`, `trade_show`, `inbound` y `other`.

## El objeto prospecto

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id del prospecto. Se conserva cuando se convierte en cliente.
`alias` | string | Código del prospecto, único entre los contactos vivos de la cuenta. Se guarda en mayúsculas y no admite espacios. Es el `contact_code` que usan los demás recursos.
`name` | string | Nombre comercial.
`legal_name` | string | Razón social. Se guarda en mayúsculas.
`identification` | string | RFC u otra identificación fiscal. En cuentas de México, si lo mandas, se valida el formato de RFC.
`id_fiscal` | string | Identificación fiscal extranjera (Tax ID).
`kind` | array&lt;string&gt; | Tipo de contacto. Un prospecto siempre tiene `["prospect"]`; otro valor responde 422.
`status` | string | <span class="ro">solo lectura</span> `active` o `inactive`. Nace `active`. <span class="new">nuevo</span> Si lo mandas en el alta o en un cambio, responde 422 `read_only_fields`.
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivado.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`.
`lead_status` | string | Clave del estado. Ver la tabla de estados arriba. Se manda en el alta; después cambia solo con [Cambiar el estado de un prospecto](#cambiar-el-estado-de-un-prospecto).
`lead_status_label` | string | <span class="ro">solo lectura</span> Leyenda del estado según el catálogo de la cuenta.
`prospect_type` | string | `direct` (cliente directo) o `origin_agent` (agente en origen). Puede ser `null`.
`lead_source` | string | Clave del origen. Puede ser `null`.
`seller` | object | <span class="ro">solo lectura</span> Vendedor asignado: `{ "id", "name", "email" }`, o `null`. Se escribe con `seller_id` o `seller_email`.
`created_at` | datetime | <span class="ro">solo lectura</span> Alta.
`updated_at` | datetime | <span class="ro">solo lectura</span> Último cambio.
`description` | string | Notas. Solo en el detalle.
`services` | array&lt;string&gt; | Servicios que le interesan. La plataforma usa `maritime`, `aerial`, `land`, `customs`, `insurance`, `custody` y `shipping`; la API no valida los valores. Solo en el detalle.
`credit_days` | integer | Días de crédito. Solo en el detalle.
`billing_address` | object | <span class="ro">solo lectura</span> Domicilio fiscal: `{ "id", "alias", "name", "address_type", "full_address" }`, o `null`. Solo en el detalle. Se captura en la plataforma.
`trade_identification` | string | <span class="new">nuevo</span> Identificación comercial, o `null`. Solo en el detalle.
`nationality` | string | <span class="new">nuevo</span> `national` o `foreign`. Solo en el detalle.

El listado devuelve los campos hasta `updated_at`. El detalle, el alta, el cambio y el cambio de estado agregan `description`, `services`, `credit_days`, `billing_address`, `trade_identification` y `nationality`.

> Objeto prospecto

```json
{
  "id": 1310,
  "alias": "GTBAJIO",
  "name": "Grupo Textil del Bajío",
  "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
  "identification": "GTB050505KJ2",
  "id_fiscal": null,
  "kind": ["prospect"],
  "status": "active",
  "archived": false,
  "archived_at": null,
  "lead_status": "qualified",
  "lead_status_label": "Calificado",
  "prospect_type": "direct",
  "lead_source": "trade_show",
  "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
  "created_at": "2026-11-03T10:15:00.000-06:00",
  "updated_at": "2026-11-10T17:42:00.000-06:00",
  "description": "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo.",
  "services": ["maritime", "customs"],
  "credit_days": null,
  "billing_address": null,
  "trade_identification": null,
  "nationality": "national"
}
```

## Listar prospectos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/leads</code></div>

<p class="perm">Permiso: <code>leads_read</code></p>

Devuelve los prospectos no archivados que el usuario puede ver, del más reciente al más antiguo (`created_at`). Con `updated_since` el orden cambia a `updated_at, id`.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`lead_status` | string | <span class="opt">opcional</span> Solo prospectos en ese estado (clave exacta).
`prospect_type` | string | <span class="opt">opcional</span> `direct` o `origin_agent`.
`lead_source` | string | <span class="opt">opcional</span> Clave de origen exacta.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo los archivados. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen el `alias`.

Un prospecto que se convierte en cliente deja de aparecer aquí y no deja lápida. Ver [Convertir un prospecto en cliente](#convertir-un-prospecto-en-cliente).

> Petición

```shell
curl "https://control.apunto.io/api/v1/leads?lead_status=qualified&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "leads": [
    {
      "id": 1310,
      "alias": "GTBAJIO",
      "name": "Grupo Textil del Bajío",
      "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
      "identification": "GTB050505KJ2",
      "id_fiscal": null,
      "kind": ["prospect"],
      "status": "active",
      "archived": false,
      "archived_at": null,
      "lead_status": "qualified",
      "lead_status_label": "Calificado",
      "prospect_type": "direct",
      "lead_source": "trade_show",
      "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "created_at": "2026-11-03T10:15:00.000-06:00",
      "updated_at": "2026-11-10T17:42:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Obtener un prospecto

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/leads/:id</code></div>

<p class="perm">Permiso: <code>leads_read</code></p>

Devuelve el detalle en `lead`. También responde con prospectos archivados. Un id que no es de un prospecto (por ejemplo, un cliente) responde **404**.

> Petición

```shell
curl https://control.apunto.io/api/v1/leads/1310 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "lead": {
    "id": 1310,
    "alias": "GTBAJIO",
    "name": "Grupo Textil del Bajío",
    "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
    "identification": "GTB050505KJ2",
    "id_fiscal": null,
    "kind": ["prospect"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "lead_status": "qualified",
    "lead_status_label": "Calificado",
    "prospect_type": "direct",
    "lead_source": "trade_show",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-10T17:42:00.000-06:00",
    "description": "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo.",
    "services": ["maritime", "customs"],
    "credit_days": null,
    "billing_address": null,
    "trade_identification": null,
    "nationality": "national"
  }
}
```

## Crear un prospecto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/leads</code></div>

<p class="perm">Permiso: <code>leads_create</code></p>

Crea un prospecto con `kind` `["prospect"]`, estado `new_lead` (si no mandas otro) y `status` `active`. El usuario del token queda como dueño del registro.

### Cuerpo de la petición

Todo va dentro de `lead`.

Campo | Tipo | Descripción
--------- | ---- | -----------
`name` | string | <span class="req">obligatorio</span> Nombre comercial.
`alias` | string | <span class="req">obligatorio</span> Código único en la cuenta, sin espacios. La API no lo genera en este endpoint (`quick_create` sí).
`legal_name` | string | <span class="opt">opcional</span> Razón social.
`identification` | string | <span class="opt">opcional</span> RFC. En cuentas de México se valida el formato. Los prospectos pueden repetir el RFC de otro contacto; la regla de RFC único aplica al convertirlo en cliente.
`id_fiscal` | string | <span class="opt">opcional</span> Tax ID extranjero.
`trade_identification` | string | <span class="opt">opcional</span> Identificación comercial.
`nationality` | string | <span class="opt">opcional</span> `national` (por omisión) o `foreign`.
`description` | string | <span class="opt">opcional</span> Notas.
`credit_days` | integer | <span class="opt">opcional</span> Días de crédito.
`lead_status` | string | <span class="opt">opcional</span> Clave de un estado no archivado. Por omisión `new_lead`.
`lead_source` | string | <span class="opt">opcional</span> Clave de un origen no archivado.
`prospect_type` | string | <span class="opt">opcional</span> `direct` o `origin_agent`.
`seller_email` | string | <span class="opt">opcional</span> Correo del vendedor. Tiene que ser usuario de la cuenta.
`seller_id` | integer | <span class="opt">opcional</span> Alternativa a `seller_email`. Tiene que ser miembro de la cuenta.
`services` | array&lt;string&gt; | <span class="opt">opcional</span> Servicios de interés.
`kind` | array&lt;string&gt; | <span class="opt">opcional</span> Solo `["prospect"]`, que es el valor por omisión. <span class="new">nuevo</span> Otro valor (`client`, `supplier`) responde 422: la conversión se hace en la plataforma.

El régimen fiscal y el domicilio fiscal no se reciben aquí: se capturan en la plataforma. <span class="new">nuevo</span> `status` no se acepta: responde 422 `read_only_fields`.

### Respuesta

**201** con el detalle en `lead` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `name` o `alias`, el `alias` ya existe o tiene espacios, o el RFC no tiene formato válido.
`422` `validation_failed` | `lead_status` o `lead_source` no es una clave viva del catálogo; el mensaje lista las claves válidas. `prospect_type` fuera de `direct` y `origin_agent`.
`422` `validation_failed` | `seller_email` no es un usuario de la cuenta, o `seller_id` no es miembro de la cuenta.
`422` `validation_failed` | <span class="new">nuevo</span> `kind` trae algo distinto de `prospect`. El mensaje dice que la conversión se hace con «Convertir a cliente» en la plataforma.
`422` `read_only_fields` | <span class="new">nuevo</span> Mandaste `status`.

Lo demás, en [Errores](#errores).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/leads \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lead": {
      "name": "Grupo Textil del Bajío",
      "alias": "GTBAJIO",
      "legal_name": "Grupo Textil del Bajío SA de CV",
      "identification": "GTB050505KJ2",
      "lead_source": "trade_show",
      "prospect_type": "direct",
      "seller_email": "laura@tuempresa.mx",
      "services": ["maritime", "customs"],
      "description": "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo."
    }
  }'
```

```javascript
const { status, body } = await api("/leads", {
  method: "POST",
  body: JSON.stringify({
    lead: {
      name: "Grupo Textil del Bajío",
      alias: "GTBAJIO",
      legal_name: "Grupo Textil del Bajío SA de CV",
      identification: "GTB050505KJ2",
      lead_source: "trade_show",
      prospect_type: "direct",
      seller_email: "laura@tuempresa.mx",
      services: ["maritime", "customs"],
      description: "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo.",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/leads", json={
    "lead": {
        "name": "Grupo Textil del Bajío",
        "alias": "GTBAJIO",
        "legal_name": "Grupo Textil del Bajío SA de CV",
        "identification": "GTB050505KJ2",
        "lead_source": "trade_show",
        "prospect_type": "direct",
        "seller_email": "laura@tuempresa.mx",
        "services": ["maritime", "customs"],
        "description": "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo.",
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "lead": {
    "id": 1310,
    "alias": "GTBAJIO",
    "name": "Grupo Textil del Bajío",
    "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
    "identification": "GTB050505KJ2",
    "id_fiscal": null,
    "kind": ["prospect"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "lead_status": "new_lead",
    "lead_status_label": "Nuevo",
    "prospect_type": "direct",
    "lead_source": "trade_show",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-03T10:15:00.000-06:00",
    "description": "Importa telas de Asia. Pidió tarifa de 40HC a Manzanillo.",
    "services": ["maritime", "customs"],
    "credit_days": null,
    "billing_address": null,
    "trade_identification": null,
    "nationality": "national"
  },
  "message": "Lead creado exitosamente"
}
```

## Actualizar un prospecto

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/leads/:id</code></div>

<p class="perm">Permiso: <code>leads_edit</code></p>

Cambio parcial con los campos del alta dentro de `lead`. Los campos que no mandas no cambian. `PUT` también funciona.

- <span class="new">nuevo</span> `lead_status` y `status` no se aceptan: responden **422** `read_only_fields` con el campo en `fields`. El estado se cambia con [Cambiar el estado de un prospecto](#cambiar-el-estado-de-un-prospecto).
- <span class="new">nuevo</span> `kind` solo acepta `["prospect"]`; otro valor responde **422**.
- Un `lead_source` que ya no está vivo en el catálogo se acepta si es el que el prospecto ya tiene.
- Un prospecto archivado es de solo lectura: responde **422** con `code` `archived_read_only` y `suggested_action` `restore`.

### Respuesta

**200** con el detalle en `lead` y `message`. Los errores son los del alta, más `read_only_fields` si mandas `lead_status`.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/leads/1310 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "lead": { "credit_days": 30, "description": "Embarca 4 contenedores al mes." } }'
```

> Respuesta 200

```json
{
  "lead": {
    "id": 1310,
    "alias": "GTBAJIO",
    "name": "Grupo Textil del Bajío",
    "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
    "identification": "GTB050505KJ2",
    "id_fiscal": null,
    "kind": ["prospect"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "lead_status": "qualified",
    "lead_status_label": "Calificado",
    "prospect_type": "direct",
    "lead_source": "trade_show",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-11T09:30:00.000-06:00",
    "description": "Embarca 4 contenedores al mes.",
    "services": ["maritime", "customs"],
    "credit_days": 30,
    "billing_address": null,
    "trade_identification": null,
    "nationality": "national"
  },
  "message": "Lead actualizado exitosamente"
}
```

> Error 422

```json
{
  "error": "read_only_fields",
  "message": "lead_status cambia con PATCH /api/v1/leads/:id/transition. status (active o inactive) no se escribe por la API.",
  "errors": ["lead_status no se escribe en esta petición"],
  "fields": ["lead_status"],
  "request_id": "2f9b7c1e-84d3-4a6b-b0e5-c7d1a3f9e264"
}
```

## Cambiar el estado de un prospecto

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/leads/:id/transition</code></div>

<p class="perm">Permiso: <code>leads_edit</code></p>

Mueve el prospecto a otra etapa. Manda `lead_status` en la raíz del cuerpo o dentro de `lead` (`{ "lead": { "lead_status": "qualified" } }`). Solo cambia el estado; no toca otros campos.

### Cuerpo de la petición

Campo | Tipo | Descripción
--------- | ---- | -----------
`lead_status` | string | <span class="req">obligatorio</span> Clave de un estado no archivado del catálogo, o el estado actual del prospecto.

### Respuesta

**200** con el detalle en `lead` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `lead_status` o no es una clave viva del catálogo. <span class="new">nuevo</span> El mensaje lista las claves válidas de la cuenta.
`422` `archived_read_only` | El prospecto está archivado.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/leads/1310/transition \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "lead_status": "negotiation" }'
```

> Respuesta 200

```json
{
  "lead": {
    "id": 1310,
    "alias": "GTBAJIO",
    "name": "Grupo Textil del Bajío",
    "legal_name": "GRUPO TEXTIL DEL BAJÍO SA DE CV",
    "identification": "GTB050505KJ2",
    "id_fiscal": null,
    "kind": ["prospect"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "lead_status": "negotiation",
    "lead_status_label": "Negociación",
    "prospect_type": "direct",
    "lead_source": "trade_show",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-11T09:45:00.000-06:00",
    "description": "Embarca 4 contenedores al mes.",
    "services": ["maritime", "customs"],
    "credit_days": 30,
    "billing_address": null,
    "trade_identification": null,
    "nationality": "national"
  },
  "message": "Estado del lead actualizado exitosamente"
}
```

> Error 422

```json
{
  "error": "validation_failed",
  "message": "lead_status no es un estado vigente de la cuenta. Valores permitidos: new_lead, qualified, contacted, negotiation, closed, discarded, bad_timing, revalue",
  "errors": ["lead_status no es un estado vigente de la cuenta. Valores permitidos: new_lead, qualified, contacted, negotiation, closed, discarded, bad_timing, revalue"],
  "request_id": "5b0f7c2e-3a41-4d9b-9a52-1e8c0d6f4b17"
}
```

## Convertir un prospecto en cliente

La API v1 **no** convierte prospectos en clientes. La conversión se hace en la plataforma, con **Convertir a cliente** en el prospecto. Si la cuenta exige autorizar altas de clientes y el usuario no es aprobador, la plataforma crea una solicitud de autorización y la conversión ocurre cuando un aprobador la acepta.

Para convertirlo, en una cuenta de México el prospecto necesita razón social, RFC, régimen fiscal y domicilio fiscal, y el RFC no puede ser de otro cliente o proveedor de la cuenta. El régimen fiscal y el domicilio fiscal se capturan en la plataforma: este endpoint no los recibe.

Al convertirse:

- El registro conserva su `id` y su `alias`. `kind` cambia de `prospect` a `client`.
- Sale de `/api/v1/leads`: `GET /api/v1/leads/:id` responde **404** y el listado ya no lo trae, sin lápida en `deleted_since`.
- Aparece en `GET /api/v1/contacts` como cliente. Para detectarlo, sincroniza también [Contactos](#contactos) con `updated_since` y busca el mismo `id`.
- Sus oportunidades, solicitudes comerciales y cotizaciones siguen ligadas, porque apuntan al mismo `id`.

<aside class="notice"><code>kind</code> no sirve para convertir: <code>POST</code> y <code>PATCH /api/v1/leads</code> solo aceptan <code>["prospect"]</code> y responden 422 con cualquier otro valor.</aside>

## Archivar y restaurar un prospecto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/leads/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/leads/:id/restore</code></div>

<p class="perm">Permiso: <code>leads_edit</code></p>

Archivar saca al prospecto de los listados sin borrarlo; restaurar lo regresa. Ninguno de los dos cambia `status` ni `lead_status`. Archivar no pide confirmación. No llevan cuerpo.

Las dos acciones responden la decisión del ciclo de vida. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

Acción | `outcome` | `code` | Cuándo
------ | --------- | ------ | ------
Archivar | `allow` (200) | `null` | El prospecto queda archivado.
Archivar | `reject` (422) | `already_archived` | Ya estaba archivado.
Restaurar | `allow` (200) | `null` | El prospecto vuelve a los listados.
Restaurar | `reject` (422) | `not_archived` | No estaba archivado.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/leads/1310/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "already_archived",
  "title": "Este lead ya está archivado",
  "message": "Este lead ya está archivado. Lo encuentras en Configuración › Archivados, donde puedes restaurarlo.",
  "suggested_action": null,
  "errors": ["Este lead ya está archivado. Lo encuentras en Configuración › Archivados, donde puedes restaurarlo."],
  "error": "already_archived",
  "request_id": "a3d9e1f0-6c2b-4f7e-8d15-2b7c9e0a4f61"
}
```

## Eliminar un prospecto

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/leads/:id</code></div>

<p class="perm">Permiso: <code>leads_delete</code></p>

Elimina el prospecto (borrado lógico) solo si no tiene historia. Después aparece como lápida en `deleted_since`, con su `alias`. Responde la decisión del ciclo de vida.

`outcome` | `code` | Cuándo
--------- | ------ | ------
`allow` (200) | `null` | Se eliminó.
`reject` (422) | `has_history` | Tiene folios operativos, solicitudes comerciales, cotizaciones, facturas, pagos u otros registros. El mensaje lista cuántos de cada uno. `suggested_action` es `archive` si no está archivado.
`reject` (422) | `has_opportunities` | Tiene oportunidades (archivadas también cuentan). `suggested_action` es `archive` si no está archivado.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/leads/1310 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "has_opportunities",
  "title": "No puedes eliminar este lead",
  "message": "Este lead tiene oportunidades, así que no puedes eliminarlo. Archívalo si ya no debe verse en tus listas.",
  "suggested_action": "archive",
  "errors": ["Este lead tiene oportunidades, así que no puedes eliminarlo. Archívalo si ya no debe verse en tus listas."],
  "error": "has_opportunities",
  "request_id": "0c6e2b9d-71f4-4a83-b5e0-93d2f1a8c7e4"
}
```
