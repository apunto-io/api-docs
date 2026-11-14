# Contactos

<p class="lead">Los contactos son los clientes y proveedores de tu cuenta. Una integración los sincroniza con su ERP y usa el <code>alias</code> de cada uno como código en folios, servicios, centro de costos, facturas y cotizaciones.</p>

- Un contacto es cliente, proveedor o ambos (`kind`).
- Los prospectos no viven aquí. Se leen y escriben en [Prospectos](#prospectos): `GET /contacts` no los lista y `GET /contacts/:id` responde 404 para un prospecto.
- `status` (`active` / `inactive`) y archivado son cosas distintas. Archivar no cambia `status`, y un contacto archivado es de solo lectura hasta que lo restauras.
- El domicilio fiscal es uno por contacto. Lo mandas dentro del contacto (`billing_address_attributes`) o lo manejas en [Domicilio fiscal de un contacto](#domicilio-fiscal-de-un-contacto).

## El objeto contacto

El listado y la búsqueda devuelven los campos de `id` a `updated_at`. El detalle, el alta y el cambio agregan el resto.

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Identificador.
`alias` | string | Código del contacto en la cuenta. Es el `contact_code`, `supplier_code` o `customs_agent_code` de los demás recursos. Se guarda en mayúsculas.
`name` | string | Nombre comercial.
`legal_name` | string | Razón social. Se guarda en mayúsculas.
`identification` | string | RFC. Se guarda en mayúsculas y sin espacios.
`id_fiscal` | string | Identificador fiscal de un contacto extranjero (Tax ID, VAT, …).
`trade_identification` | string | <span class="new">nuevo</span> Identificador de comercio exterior (EORI en cuentas de la Unión Europea).
`kind` | array&lt;string&gt; | Tipos del contacto: `client`, `supplier` o ambos.
`status` | string | <span class="ro">solo lectura</span> `active` o `inactive`. La API no lo cambia: si lo mandas, se ignora. No indica si está archivado.
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivado.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`.
`nationality` | string | `national` (por omisión) o `foreign`.
`seller` | object | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Vendedor asignado al contacto cuando es un usuario de la cuenta: `id`, `name` y `email`, o `null`. Se asigna en la plataforma.
`external_seller` | object | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Vendedor externo (registrado en el catálogo de vendedores externos de la cuenta; no es usuario): `id`, `name` y `email`, o `null`. Un contacto tiene `seller` o `external_seller`, nunca los dos.
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span>
`email` | string | <span class="new">nuevo</span> Correo principal, o `null`.
`phone` | string | <span class="new">nuevo</span> Teléfono principal, o `null`.
`emails` | array&lt;object&gt; | <span class="new">nuevo</span> <span class="ro">solo lectura</span> Todos los correos, el principal primero: `email`, `label` (`work`, `personal`, `other`) y `primary`.
`phones` | array&lt;object&gt; | <span class="new">nuevo</span> <span class="ro">solo lectura</span> Todos los teléfonos, el principal primero: `number`, `label` (`work`, `mobile`, `personal`, `home`, `other`) y `primary`.
`tags` | array&lt;string&gt; | <span class="new">nuevo</span> Etiquetas. Se escriben con `tag_list`.
`contact_tax_regime` | object | <span class="new">nuevo</span> Régimen fiscal del SAT (`code`, `name`), o `null`. Se escribe con `contact_tax_regime_code`.
`description` | string | Notas libres.
`services` | array&lt;string&gt; | Servicios que da o contrata. La plataforma usa `insurance`, `custody`, `customs`, `land`, `aerial` y `maritime`.
`credit_days` | integer | Días de crédito.
`payment_method` | object | Forma de pago del SAT (`code`, `name`), o `null`. Se escribe con `payment_method_code`.
`payment_type` | object | Método de pago del SAT (`code`, `name`): `PUE` o `PPD`, o `null`. Se escribe con `payment_type_code`.
`cfdi_use` | object | Uso del CFDI (`code`, `name`), o `null`. Se escribe con `cfdi_use_code`.
`billing_address` | object | Domicilio fiscal, o `null`: `id`, `alias`, `name`, `address_type`, `street`, `outdoor_number`, `internal_number`, `neighborhood`, `city`, `state`, `country`, `postal_code`, `aeat_city_code` y `full_address`. <span class="new">nuevo</span> de `street` a `aeat_city_code`.

> Objeto contacto

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "legal_name": "ACME LOGISTICS SA DE CV",
    "identification": "ALO010101AB1",
    "id_fiscal": null,
    "trade_identification": null,
    "kind": ["client"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "nationality": "national",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "external_seller": null,
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-10T16:42:08.000-06:00",
    "email": "facturas@acme.mx",
    "phone": "+52 81 1111 2222",
    "emails": [
      { "email": "facturas@acme.mx", "label": "work", "primary": true },
      { "email": "logistica@acme.mx", "label": "other", "primary": false }
    ],
    "phones": [
      { "number": "+52 81 1111 2222", "label": "work", "primary": true }
    ],
    "tags": ["Exportador"],
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" },
    "description": null,
    "services": ["maritime", "customs"],
    "credit_days": 30,
    "payment_method": { "code": "03", "name": "Transferencia electrónica de fondos" },
    "payment_type": { "code": "PPD", "name": "Pago en parcialidades o diferido" },
    "cfdi_use": { "code": "G03", "name": "Gastos en general" },
    "billing_address": {
      "id": 431,
      "alias": "ACME-FISCAL",
      "name": "Fiscal Acme",
      "address_type": "billing",
      "street": "Av. Constitución",
      "outdoor_number": "100",
      "internal_number": null,
      "neighborhood": "Centro",
      "city": "Monterrey",
      "state": "NLE",
      "country": "MX",
      "postal_code": "64000",
      "aeat_city_code": null,
      "full_address": "Av. Constitución 100 Centro Monterrey NLE 64000 MX"
    }
  }
}
```

### Tipos de contacto

`kind` es un arreglo y es obligatorio al crear.

Valor | Significado
--------- | -----------
`client` | Cliente. Se usa como `contact_code` en folios, oportunidades, solicitudes comerciales, cotizaciones y facturas.
`supplier` | Proveedor. Se usa como `supplier_code` en servicios, centro de costos y precios de solicitudes, y como `contact_code` en facturas de proveedor.

Para un contacto que es las dos cosas manda `["client", "supplier"]`. Un solo valor como texto (`"client"`) se toma como `["client"]`. <span class="new">nuevo</span> Cualquier otro valor, incluido `prospect`, responde **422** con los permitidos: los prospectos se crean con [Alta rápida de un prospecto](#alta-rapida-de-un-prospecto) o en [Prospectos](#prospectos).

### Alias

- Es el código con el que los demás recursos apuntan al contacto (`contact_code`, `supplier_code`, `customs_agent_code`). También sirve en lugar del id en `/contacts/:id`.
- Se guarda en mayúsculas y no puede tener espacios.
- Es único entre los contactos no eliminados de la cuenta, incluidos los archivados y los prospectos. Un alias repetido responde **422**.
- Si no lo mandas, se genera con las primeras cinco letras o dígitos del nombre, sin acentos (`Transportes Ñandú` → `TRANS`). Si ya existe, se agrega un número: `TRANS2`, `TRANS3`, …
- Si un alias es solo dígitos, `/contacts/:id` lo busca primero como id.

<aside class="success">Usa como alias la clave del cliente o proveedor en tu ERP. Así no necesitas guardar ids de Apunto. Si cambias un alias, las peticiones que usen el anterior dejan de encontrar al contacto.</aside>

### Datos fiscales

- `identification` es el RFC. En cuentas que operan en México debe tener formato de RFC (12 o 13 caracteres); si no, **422**.
- El RFC no se puede repetir entre clientes y proveedores de la cuenta. Las excepciones son los RFC genéricos `XAXX010101000` (público en general) y `XEXX010101000` (extranjero).
- Para un contacto extranjero manda `nationality: "foreign"` y su identificador real en `id_fiscal`. En `identification` va el RFC genérico `XEXX010101000`, como lo guarda la plataforma. En ese caso lo que no se repite es `id_fiscal`.
- `trade_identification` es el identificador de comercio exterior. En cuentas de la Unión Europea debe tener formato EORI (dos letras de país y hasta 15 caracteres).

Los catálogos del SAT se mandan por clave y se devuelven como objeto `{ "code", "name" }`:

Mandas | Se devuelve en | Catálogo del SAT | Ejemplo
--------- | ---- | ----------- | -------
`contact_tax_regime_code` | `contact_tax_regime` | Régimen fiscal | `601`
`cfdi_use_code` | `cfdi_use` | Uso del CFDI | `G03`
`payment_method_code` | `payment_method` | Forma de pago | `03` (transferencia), `01` (efectivo)
`payment_type_code` | `payment_type` | Método de pago | `PUE`, `PPD`

- Las claves se buscan en el catálogo del país de operación de la cuenta. Las formas y los métodos de pago tienen catálogo de México y de España; los demás países usan el de México. El uso del CFDI solo existe para México.
- Una clave que no existe en ese catálogo responde **422** y el contacto no se guarda. <span class="new">nuevo</span> Si mandas varias claves malas, `errors` las lista todas.
- <span class="new">nuevo</span> También se aceptan los ids internos (`contact_tax_regime_id`, `cfdi_use_id`, `payment_method_id`, `payment_type_id`). Cada id debe existir en el catálogo del país de la cuenta; si no, **422**. Prefiere las claves.

<aside class="notice">Para timbrar una factura a un cliente con RFC, el contacto necesita RFC, régimen fiscal, razón social y un domicilio fiscal con calle, ciudad, estado, código postal y país (y colonia si el país es <code>MX</code>).</aside>

### Correos y teléfonos

- `email` y `phone` escriben el correo y el teléfono **principales**. Si el contacto no tiene, se crean con etiqueta `work`; si ya tiene, se reemplazan.
- Mandar `""` o `null` borra el principal. Si no mandas la llave, no cambia.
- Los demás correos y teléfonos (los que se capturan en la plataforma) se leen en `emails` y `phones`. La API no agrega ni quita esos.
- Un correo con formato inválido responde **422** y no se guarda nada del contacto.

### Etiquetas del contacto

`tag_list` recibe nombres del catálogo de etiquetas de contactos de la cuenta (**Configuración → Etiquetas**). No distingue mayúsculas. Reemplaza la lista completa; `[]` quita todas. Un nombre que no existe responde **422**. Ver [Convenciones](#convenciones).

## Listar contactos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/contacts</code></div>

<p class="perm">Permiso: <code>contacts_read</code></p>

Devuelve los clientes y proveedores no archivados, del más reciente al más antiguo. Sin `contacts_read` la lista sale vacía.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`kind` | string | <span class="opt">opcional</span> `client` o `supplier`. Con varios (`kind[]=client&kind[]=supplier`) devuelve los que tienen todos.
`status` | string | <span class="opt">opcional</span> `active` o `inactive`. Filtra la columna `status`, no el archivado.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo los archivados.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen `alias`.

> Petición

```shell
curl "https://control.apunto.io/api/v1/contacts?kind=client&per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "contacts": [
    {
      "id": 812,
      "alias": "ACME",
      "name": "Acme Logistics",
      "legal_name": "ACME LOGISTICS SA DE CV",
      "identification": "ALO010101AB1",
      "id_fiscal": null,
      "trade_identification": null,
      "kind": ["client"],
      "status": "active",
      "archived": false,
      "archived_at": null,
      "nationality": "national",
      "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "external_seller": null,
      "created_at": "2026-11-03T10:15:00.000-06:00",
      "updated_at": "2026-11-10T16:42:08.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 100, "total": 1 }
}
```

## Buscar contactos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/contacts/search</code></div>

<p class="perm">Permiso: <code>contacts_read</code></p>

<span class="new">nuevo</span> Busca un cliente o proveedor por texto. Pensado para autocompletar o para encontrar un contacto antes de darlo de alta.

1. Primero busca coincidencia **exacta** (sin importar mayúsculas) en `alias`, RFC (`identification`) o `id_fiscal`. Si hay, devuelve solo esas, ordenadas por nombre.
2. Si no hay, busca por palabras o inicios de palabra en nombre, alias, RFC y razón social, sin importar acentos.

Solo devuelve contactos no archivados. Cada resultado tiene los campos del listado.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`q` | string | <span class="req">obligatorio</span> Texto a buscar. Sin `q` la lista sale vacía.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).

> Petición

```shell
curl "https://control.apunto.io/api/v1/contacts/search?q=ALO010101AB1" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "contacts": [
    {
      "id": 812,
      "alias": "ACME",
      "name": "Acme Logistics",
      "legal_name": "ACME LOGISTICS SA DE CV",
      "identification": "ALO010101AB1",
      "id_fiscal": null,
      "trade_identification": null,
      "kind": ["client"],
      "status": "active",
      "archived": false,
      "archived_at": null,
      "nationality": "national",
      "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
      "external_seller": null,
      "created_at": "2026-11-03T10:15:00.000-06:00",
      "updated_at": "2026-11-10T16:42:08.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Obtener un contacto

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/contacts/:id</code></div>

<p class="perm">Permiso: <code>contacts_read</code></p>

Devuelve el detalle completo, también si está archivado. `:id` acepta el id o el alias (`/contacts/ACME`).

Responde **404** `not_found` si el contacto no existe, es de otra cuenta, el usuario no lo puede ver o es un prospecto.

> Petición

```shell
curl https://control.apunto.io/api/v1/contacts/ACME \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "legal_name": "ACME LOGISTICS SA DE CV",
    "identification": "ALO010101AB1",
    "id_fiscal": null,
    "trade_identification": null,
    "kind": ["client"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "nationality": "national",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "external_seller": null,
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-10T16:42:08.000-06:00",
    "email": "facturas@acme.mx",
    "phone": "+52 81 1111 2222",
    "emails": [{ "email": "facturas@acme.mx", "label": "work", "primary": true }],
    "phones": [{ "number": "+52 81 1111 2222", "label": "work", "primary": true }],
    "tags": ["Exportador"],
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" },
    "description": null,
    "services": ["maritime", "customs"],
    "credit_days": 30,
    "payment_method": { "code": "03", "name": "Transferencia electrónica de fondos" },
    "payment_type": { "code": "PPD", "name": "Pago en parcialidades o diferido" },
    "cfdi_use": { "code": "G03", "name": "Gastos en general" },
    "billing_address": null
  }
}
```

## Crear un contacto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/contacts</code></div>

<p class="perm">Permiso: <code>contacts_create</code></p>

Da de alta un cliente o proveedor. El usuario del token queda como dueño.

### Cuerpo de la petición

Todo va dentro de `contact`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`name` | string | <span class="req">obligatorio</span> Nombre comercial.
`kind` | array&lt;string&gt; | <span class="req">obligatorio</span> `["client"]`, `["supplier"]` o los dos. Otro valor responde **422**.
`alias` | string | <span class="opt">opcional</span> Código único, sin espacios. Si lo omites, se genera a partir del nombre.
`legal_name` | string | <span class="opt">opcional</span> Razón social.
`identification` | string | <span class="opt">opcional</span> RFC.
`id_fiscal` | string | <span class="opt">opcional</span> Identificador fiscal extranjero.
`nationality` | string | <span class="opt">opcional</span> `national` o `foreign`. Otro valor responde **422** con los permitidos.
`trade_identification` | string | <span class="opt">opcional</span> Identificador de comercio exterior. En cuentas de la Unión Europea, formato EORI.
`contact_tax_regime_code` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Clave de régimen fiscal del SAT (`601`).
`cfdi_use_code` | string | <span class="opt">opcional</span> Clave de uso del CFDI (`G03`).
`payment_method_code` | string | <span class="opt">opcional</span> Clave de forma de pago (`03`).
`payment_type_code` | string | <span class="opt">opcional</span> Método de pago (`PUE`, `PPD`).
`credit_days` | integer | <span class="opt">opcional</span> Días de crédito.
`description` | string | <span class="opt">opcional</span> Notas.
`services` | array&lt;string&gt; | <span class="opt">opcional</span> Servicios del contacto.
`email` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Correo principal.
`phone` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Teléfono principal.
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> <span class="new">nuevo</span> Etiquetas del catálogo de la cuenta.
`billing_address_attributes` | object | <span class="opt">opcional</span> <span class="new">nuevo</span> Domicilio fiscal: `name`, `alias`, `street`, `outdoor_number`, `internal_number`, `neighborhood`, `city`, `state`, `country`, `postal_code`, `aeat_city_code`. Se guarda con `address_type: billing`. Lleva las mismas validaciones que una [dirección](#direcciones): calle, ciudad, estado, código postal y país obligatorios, y colonia si el país es `MX`.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/contacts \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
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
      "tag_list": ["Exportador"],
      "billing_address_attributes": {
        "name": "Fiscal Acme",
        "alias": "ACME-FISCAL",
        "street": "Av. Constitución",
        "outdoor_number": "100",
        "neighborhood": "Centro",
        "city": "Monterrey",
        "state": "NLE",
        "country": "MX",
        "postal_code": "64000"
      }
    }
  }'
```

```javascript
const { status, body } = await api("/contacts", {
  method: "POST",
  body: JSON.stringify({
    contact: {
      name: "Acme Logistics",
      legal_name: "Acme Logistics SA de CV",
      alias: "ACME",
      identification: "ALO010101AB1",
      kind: ["client"],
      contact_tax_regime_code: "601",
      cfdi_use_code: "G03",
      payment_method_code: "03",
      payment_type_code: "PPD",
      credit_days: 30,
      email: "facturas@acme.mx",
      phone: "+52 81 1111 2222",
      tag_list: ["Exportador"],
      billing_address_attributes: {
        name: "Fiscal Acme",
        alias: "ACME-FISCAL",
        street: "Av. Constitución",
        outdoor_number: "100",
        neighborhood: "Centro",
        city: "Monterrey",
        state: "NLE",
        country: "MX",
        postal_code: "64000",
      },
    },
  }),
});
```

```python
res = api.post(f"{BASE}/contacts", json={
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
        "tag_list": ["Exportador"],
        "billing_address_attributes": {
            "name": "Fiscal Acme",
            "alias": "ACME-FISCAL",
            "street": "Av. Constitución",
            "outdoor_number": "100",
            "neighborhood": "Centro",
            "city": "Monterrey",
            "state": "NLE",
            "country": "MX",
            "postal_code": "64000",
        },
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "legal_name": "ACME LOGISTICS SA DE CV",
    "identification": "ALO010101AB1",
    "id_fiscal": null,
    "trade_identification": null,
    "kind": ["client"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "nationality": "national",
    "seller": null,
    "external_seller": null,
    "created_at": "2026-11-11T09:30:12.000-06:00",
    "updated_at": "2026-11-11T09:30:12.000-06:00",
    "email": "facturas@acme.mx",
    "phone": "+52 81 1111 2222",
    "emails": [{ "email": "facturas@acme.mx", "label": "work", "primary": true }],
    "phones": [{ "number": "+52 81 1111 2222", "label": "work", "primary": true }],
    "tags": ["Exportador"],
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" },
    "description": null,
    "services": [],
    "credit_days": 30,
    "payment_method": { "code": "03", "name": "Transferencia electrónica de fondos" },
    "payment_type": { "code": "PPD", "name": "Pago en parcialidades o diferido" },
    "cfdi_use": { "code": "G03", "name": "Gastos en general" },
    "billing_address": {
      "id": 431,
      "alias": "ACME-FISCAL",
      "name": "Fiscal Acme",
      "address_type": "billing",
      "street": "Av. Constitución",
      "outdoor_number": "100",
      "internal_number": null,
      "neighborhood": "Centro",
      "city": "Monterrey",
      "state": "NLE",
      "country": "MX",
      "postal_code": "64000",
      "aeat_city_code": null,
      "full_address": "Av. Constitución 100 Centro Monterrey NLE 64000 MX"
    }
  },
  "message": "Contacto creado exitosamente"
}
```

### Respuesta

**201** con el detalle en `contact` y `message`. El contacto, sus correos, teléfonos y domicilio fiscal se guardan juntos: si algo falla, no se guarda nada.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `name` o `kind`; `kind` con un valor distinto de `client` o `supplier`; alias repetido o con espacios; RFC con formato inválido o ya usado por otro contacto; clave del SAT o id de catálogo que no existe en el país de la cuenta; `nationality` fuera de la lista; correo con formato inválido; domicilio fiscal incompleto; etiqueta que no está en el catálogo. `errors` lista todos los problemas de la petición.
`403` `forbidden` | El usuario no tiene `contacts_create`.

> Error 422 · kind

```json
{
  "error": "validation_failed",
  "message": "No se pudo crear el contacto",
  "errors": [
    "kind solo acepta client, supplier (mandaste: prospect). Los prospectos se crean con POST /api/v1/contacts/quick_create o POST /api/v1/leads.",
    "Payment method code Método de pago no encontrado con el código proporcionado"
  ],
  "request_id": "7a1e4c90-2d3b-4f58-9e61-0c8b5d2f7a14"
}
```

> Error 422 · etiqueta

```json
{
  "error": "validation_failed",
  "message": "Etiquetas que no existen en el catálogo de la cuenta: VIP. Créalas en Configuración > Etiquetas.",
  "errors": ["Etiquetas que no existen en el catálogo de la cuenta: VIP. Créalas en Configuración > Etiquetas."],
  "request_id": "0d3b7f2e-6a41-4b8e-9c57-1f2a9e8c4d10"
}
```

Lo demás está en [Errores](#errores).

## Actualizar un contacto

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/contacts/:id</code></div>

<p class="perm">Permiso: <code>contacts_edit</code></p>

Cambia solo los campos que mandas; `PUT` funciona igual. `:id` acepta el id o el alias. Acepta los mismos campos que el alta.

- `kind`, `services` y `tag_list` reemplazan el arreglo completo.
- `email` y `phone` reemplazan el principal; `""` o `null` lo borran.
- `billing_address_attributes` cambia el domicilio fiscal que ya existe (lo que omites no cambia) o lo crea si no hay. Nunca crea un segundo domicilio.
- `status` se ignora.
- Responde **200** con el detalle en `contact` y `message`.

Un contacto archivado no se puede cambiar: responde **422** con `code: archived_read_only` y `suggested_action: restore`. Restáuralo primero. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/contacts/ACME \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "contact": { "credit_days": 45, "phone": "+52 81 3333 4444" } }'
```

> Respuesta 200

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "legal_name": "ACME LOGISTICS SA DE CV",
    "identification": "ALO010101AB1",
    "id_fiscal": null,
    "trade_identification": null,
    "kind": ["client"],
    "status": "active",
    "archived": false,
    "archived_at": null,
    "nationality": "national",
    "seller": { "id": 15, "name": "Laura Méndez", "email": "laura@tuempresa.mx" },
    "external_seller": null,
    "created_at": "2026-11-03T10:15:00.000-06:00",
    "updated_at": "2026-11-11T11:05:40.000-06:00",
    "email": "facturas@acme.mx",
    "phone": "+52 81 3333 4444",
    "emails": [{ "email": "facturas@acme.mx", "label": "work", "primary": true }],
    "phones": [{ "number": "+52 81 3333 4444", "label": "work", "primary": true }],
    "tags": ["Exportador"],
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" },
    "description": null,
    "services": ["maritime", "customs"],
    "credit_days": 45,
    "payment_method": { "code": "03", "name": "Transferencia electrónica de fondos" },
    "payment_type": { "code": "PPD", "name": "Pago en parcialidades o diferido" },
    "cfdi_use": { "code": "G03", "name": "Gastos en general" },
    "billing_address": null
  },
  "message": "Contacto actualizado exitosamente"
}
```

## Archivar y restaurar un contacto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/contacts/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/contacts/:id/restore</code></div>

<p class="perm">Permiso: <code>contacts_edit</code></p>

Archivar saca al contacto del listado y de la búsqueda, y lo deja de solo lectura; sigue disponible en `GET /contacts/:id` y en `updated_since`. Restaurar lo regresa. Ninguna de las dos cambia `status` ni pide confirmación.

Respuesta | Cuándo
--------- | ------
**200** `outcome: allow` | Se archivó o se restauró.
**422** `code: already_archived` | Archivar un contacto que ya está archivado.
**422** `code: not_archived` | Restaurar un contacto que no está archivado.

Sin `contacts_edit` responde **403** `forbidden`. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/contacts/812/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

## Eliminar un contacto

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/contacts/:id</code></div>

<p class="perm">Permiso: <code>contacts_delete</code></p>

Elimina un contacto sin historial. Desaparece de todas las lecturas y aparece en `deleted_since` con su `alias`. Si ya se usó, archívalo.

Respuesta | Cuándo
--------- | ------
**200** `outcome: allow` | Se eliminó.
**422** `code: has_history` | Tiene folios, solicitudes comerciales, cotizaciones, facturas, facturas de proveedor, notas de crédito, pagos o anticipos, o aparece como proveedor o naviera en servicios, centro de costos, líneas de documentos, precios de solicitudes o reportes de incidencia. `message` dice qué tiene. `suggested_action: archive` si no está archivado.
**422** `code: has_opportunities` | Tiene oportunidades. `suggested_action: archive` si no está archivado.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/contacts/812 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "has_history",
  "title": "No puedes eliminar este socio",
  "message": "No se puede eliminar porque tiene 3 folios operativos y 12 facturas.",
  "suggested_action": "archive",
  "errors": ["No se puede eliminar porque tiene 3 folios operativos y 12 facturas."],
  "error": "has_history",
  "request_id": "5f8c1e0a-93d2-4c71-b6a4-2e7d0b9f1c33"
}
```

## Alta rápida de un prospecto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/contacts/quick_create</code></div>

<p class="perm">Permiso: <code>leads_create</code></p>

Crea un **prospecto** con solo el nombre, no un cliente. Úsalo cuando aún no tienes datos fiscales. El prospecto se lee y se cambia en [Prospectos](#prospectos) (`/api/v1/leads/:id`), no en `/contacts`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`name` | string | <span class="req">obligatorio</span> Nombre.
`description` | string | <span class="opt">opcional</span> Notas.

El alias se genera a partir del nombre, igual que en el alta de un contacto. Los demás campos se ignoran.

### Respuesta

**201** con `id`, `type` (siempre `Lead`), `name`, `alias`, `kind` (`["prospect"]`), `url` (dónde leerlo) y `message`. Sin `name` responde **422**.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/contacts/quick_create \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "contact": { "name": "Grupo Textil del Bajío", "description": "Contacto de la feria de Monterrey" } }'
```

> Respuesta 201

```json
{
  "id": 9051,
  "type": "Lead",
  "name": "Grupo Textil del Bajío",
  "alias": "GRUPO",
  "kind": ["prospect"],
  "url": "https://control.apunto.io/api/v1/leads/9051",
  "message": "Prospecto creado. Consúltalo en /api/v1/leads/:id."
}
```
