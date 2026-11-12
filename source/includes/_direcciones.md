# Direcciones

<p class="lead">Una dirección es una ubicación física: el domicilio fiscal de un contacto, una aduana, una bodega, un puerto. Una integración las da de alta para facturar a sus clientes y para usarlas como aduana de un servicio o como origen, destino y paradas de cotizaciones y solicitudes comerciales.</p>

Hay dos familias de rutas sobre el mismo objeto:

Aspecto | Direcciones de la cuenta | Domicilio fiscal de un contacto
--------- | ---- | -----------
Rutas | `/api/v1/addresses` | `/api/v1/contacts/:contact_id/addresses`
Para qué | Ubicaciones operativas: aduanas, bodegas, puertos, aeropuertos | Datos del receptor para facturar al contacto
Cuántas | Las que necesites | Una por contacto
`address_type` | Obligatorio, cualquiera de la lista | `billing` siempre; otro valor responde **422**
Permisos | `addresses_read`, `addresses_create`, `addresses_edit`, `addresses_delete` | Los del contacto: `contacts_read` para leer, `contacts_edit` para crear, cambiar y eliminar
Acciones | Listar, buscar, obtener, crear, cambiar, archivar, restaurar, eliminar | Listar, obtener, crear, cambiar, eliminar
Dónde se usa | `customs_address_code` en servicios; rutas de cotizaciones y solicitudes comerciales | Facturas del contacto

Las dos usan el mismo objeto, las mismas validaciones y el mismo formato de respuesta, pero no se cruzan. <span class="new">nuevo</span> `/addresses` ve las mismas ubicaciones que el catálogo de ubicaciones de la plataforma: no lista los domicilios fiscales de los contactos, y leerlos, cambiarlos o eliminarlos por `/addresses/:id` responde **404**. La ruta del contacto solo ve el domicilio de ese contacto.

## El objeto dirección

El listado y la búsqueda devuelven los campos de `id` a `updated_at`. El detalle, el alta y el cambio agregan el resto.

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Identificador.
`alias` | string | Código de la dirección, único en la cuenta sin distinguir mayúsculas. Es el `customs_address_code` de los servicios y sirve en lugar del id en `/addresses/:id`.
`name` | string | Nombre de la ubicación (`Aduana Nuevo Laredo`).
`address_type` | string | Tipo de ubicación. Ver la tabla de abajo.
`status` | string | <span class="ro">solo lectura</span> `active` o `inactive`. Lo calcula la API: `inactive` si está archivada. Si lo mandas, se ignora.
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivada.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó, o `null`.
`city` | string | Ciudad o municipio.
`state` | string | Estado o provincia.
`country` | string | País en código ISO 3166-1 de dos letras (`MX`).
`postal_code` | string | Código postal.
`addressable` | object | <span class="ro">solo lectura</span> Registro al que está ligada: `type`, `id` y `name`. En `/addresses` es `null` (ubicación de la cuenta) o `Document`, cuando la plataforma creó la ubicación al capturar la ruta de una cotización. En el domicilio fiscal es el contacto (`Contact`). La API no liga direcciones a otros registros.
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span>
`description` | string | Descripción, hasta 255 caracteres.
`contact_information` | string | Persona y teléfono en la ubicación, hasta 255 caracteres.
`control_t_id_company_client` | string | RFC de la ubicación para la integración con ControlT, hasta 20 caracteres.
`control_t_description_company_client` | string | Razón social de la ubicación para ControlT, hasta 500 caracteres.
`line1`, `line2` | string | Líneas de dirección en texto libre. Usa `street` y los demás campos desglosados.
`street` | string | Calle.
`outdoor_number` | string | Número exterior.
`internal_number` | string | Número interior.
`neighborhood` | string | Colonia o barrio.
`aeat_city_code` | string | <span class="new">nuevo</span> Código de municipio de la AEAT (España), cinco dígitos, o `null`.
`full_address` | string | <span class="ro">solo lectura</span> Calle, números, colonia, ciudad, estado, código postal y país unidos con espacios.

> Objeto dirección

```json
{
  "address": {
    "id": 2045,
    "alias": "ADU-NLD",
    "name": "Aduana Nuevo Laredo",
    "address_type": "customs",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Nuevo Laredo",
    "state": "TAM",
    "country": "MX",
    "postal_code": "88000",
    "addressable": null,
    "created_at": "2026-11-04T08:20:00.000-06:00",
    "updated_at": "2026-11-04T08:20:00.000-06:00",
    "description": "Despacho de importaciones terrestres",
    "contact_information": "Ventanilla 4 · 867 712 0000",
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Puente Internacional",
    "outdoor_number": "2500",
    "internal_number": null,
    "neighborhood": "Centro",
    "aeat_city_code": null,
    "full_address": "Av. Puente Internacional 2500 Centro Nuevo Laredo TAM 88000 MX"
  }
}
```

### Tipos de dirección

Valor | Significado
--------- | -----------
`billing` | Facturación. Es el tipo del domicilio fiscal de un contacto.
`shipping` | Envío: bodega, planta o punto de entrega.
`port` | Puerto.
`customs` | Aduana.
`airport` | Aeropuerto.
`general` | Cualquier otra ubicación.

Manda uno de estos valores exactos. <span class="new">nuevo</span> Otro valor responde **422** `validation_failed` con la lista de permitidos.

### País, estado y código postal

Campo | Regla
--------- | -----------
`country` | <span class="req">obligatorio</span> Dos letras mayúsculas, ISO 3166-1 (`MX`, `US`, `ES`). En minúsculas responde **422**.
`postal_code` | <span class="req">obligatorio</span> Cinco dígitos si el país es `MX` o `ES`. En otros países, texto libre.
`state` | <span class="req">obligatorio</span> Texto libre; no se valida contra un catálogo. Usa siempre la misma forma (por ejemplo `NLE` o `Nuevo León`).
`city`, `street` | <span class="req">obligatorio</span> Texto libre.
`neighborhood` | Obligatorio si el país es `MX`.
`aeat_city_code` | Cinco dígitos. Obligatorio en direcciones de `ES` de cuentas de España con facturación Quantum.

### Alias de la dirección

- Si no lo mandas, se genera con las primeras cinco letras o dígitos del nombre, sin acentos y en mayúsculas (`Aduana Nuevo Laredo` → `ADUAN`). Si ya existe, se agrega un número: `ADUAN2`, `ADUAN3`, …
- <span class="new">nuevo</span> Es único entre las direcciones no eliminadas de la cuenta, sin distinguir mayúsculas: un alias repetido responde **422**. Se revisa al crear y cuando cambia el alias, así que un duplicado anterior a esta regla sigue aceptando cambios en sus otros campos.
- <span class="new">nuevo</span> `/addresses/:id` y `customs_address_code` buscan el alias sin distinguir mayúsculas (`adu-nld` encuentra `ADU-NLD`). Se guarda como lo mandas; mándalo sin espacios.

## Listar direcciones

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/addresses</code></div>

<p class="perm">Permiso: <code>addresses_read</code></p>

Devuelve las ubicaciones no archivadas de la cuenta, de la más reciente a la más antigua. <span class="new">nuevo</span> Son las mismas que lista el catálogo de ubicaciones de la plataforma: las que das de alta y las que la plataforma crea al capturar rutas de cotizaciones. No incluye los domicilios fiscales de los contactos ni el de tu propia cuenta. Para quedarte con un tipo, filtra por `address_type`. Sin `addresses_read` responde **403** (el listado y la búsqueda; el detalle responde **404**).

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`address_type` | string | <span class="opt">opcional</span> `billing`, `shipping`, `port`, `customs`, `airport` o `general`.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo las archivadas.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen `alias`.

El filtro `addressable_type` / `addressable_id` ya no existe: mandarlo responde **422** `invalid_parameter`. El domicilio fiscal de un contacto se lee en [Leer el domicilio fiscal de un contacto](#leer-el-domicilio-fiscal-de-un-contacto).

> Petición

```shell
curl "https://control.apunto.io/api/v1/addresses?address_type=customs&per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "addresses": [
    {
      "id": 2045,
      "alias": "ADU-NLD",
      "name": "Aduana Nuevo Laredo",
      "address_type": "customs",
      "status": "active",
      "archived": false,
      "archived_at": null,
      "city": "Nuevo Laredo",
      "state": "TAM",
      "country": "MX",
      "postal_code": "88000",
      "addressable": null,
      "created_at": "2026-11-04T08:20:00.000-06:00",
      "updated_at": "2026-11-04T08:20:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 100, "total": 1 }
}
```

## Buscar direcciones

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/addresses/search</code></div>

<p class="perm">Permiso: <code>addresses_read</code></p>

<span class="new">nuevo</span> Busca el texto dentro del nombre, alias, calle, colonia, ciudad o código postal (sin importar mayúsculas). Busca entre las mismas ubicaciones que el listado, solo las no archivadas, ordenadas por nombre, con los campos del listado.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`q` | string | <span class="req">obligatorio</span> Texto a buscar. Sin `q` la lista sale vacía.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).

> Petición

```shell
curl "https://control.apunto.io/api/v1/addresses/search?q=laredo" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "addresses": [
    {
      "id": 2045,
      "alias": "ADU-NLD",
      "name": "Aduana Nuevo Laredo",
      "address_type": "customs",
      "status": "active",
      "archived": false,
      "archived_at": null,
      "city": "Nuevo Laredo",
      "state": "TAM",
      "country": "MX",
      "postal_code": "88000",
      "addressable": null,
      "created_at": "2026-11-04T08:20:00.000-06:00",
      "updated_at": "2026-11-04T08:20:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Obtener una dirección

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/addresses/:id</code></div>

<p class="perm">Permiso: <code>addresses_read</code></p>

Devuelve el detalle, también si está archivada. `:id` acepta el id o el alias (`/addresses/ADU-NLD`). Si el alias es solo dígitos, se busca primero como id. Responde **404** `not_found` si no existe, es de otra cuenta, es el domicilio fiscal de un contacto o el usuario no tiene `addresses_read`.

> Petición

```shell
curl https://control.apunto.io/api/v1/addresses/ADU-NLD \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "address": {
    "id": 2045,
    "alias": "ADU-NLD",
    "name": "Aduana Nuevo Laredo",
    "address_type": "customs",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Nuevo Laredo",
    "state": "TAM",
    "country": "MX",
    "postal_code": "88000",
    "addressable": null,
    "created_at": "2026-11-04T08:20:00.000-06:00",
    "updated_at": "2026-11-04T08:20:00.000-06:00",
    "description": "Despacho de importaciones terrestres",
    "contact_information": "Ventanilla 4 · 867 712 0000",
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Puente Internacional",
    "outdoor_number": "2500",
    "internal_number": null,
    "neighborhood": "Centro",
    "aeat_city_code": null,
    "full_address": "Av. Puente Internacional 2500 Centro Nuevo Laredo TAM 88000 MX"
  }
}
```

## Crear una dirección

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/addresses</code></div>

<p class="perm">Permiso: <code>addresses_create</code></p>

Da de alta una ubicación de la cuenta.

### Cuerpo de la petición

Todo va dentro de `address`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`address_type` | string | <span class="req">obligatorio</span> Ver [Tipos de dirección](#tipos-de-direccion).
`street` | string | <span class="req">obligatorio</span> Calle.
`city` | string | <span class="req">obligatorio</span> Ciudad.
`state` | string | <span class="req">obligatorio</span> Estado o provincia.
`country` | string | <span class="req">obligatorio</span> Código de país de dos letras.
`postal_code` | string | <span class="req">obligatorio</span> Código postal.
`neighborhood` | string | <span class="req">obligatorio</span> si `country` es `MX`; <span class="opt">opcional</span> en otro caso.
`name` | string | <span class="opt">opcional</span> Nombre. Si no mandas `alias`, se genera a partir de él.
`alias` | string | <span class="opt">opcional</span> Código, sin espacios y único en la cuenta.
`outdoor_number`, `internal_number` | string | <span class="opt">opcional</span> Números exterior e interior.
`description` | string | <span class="opt">opcional</span> Hasta 255 caracteres.
`contact_information` | string | <span class="opt">opcional</span> Hasta 255 caracteres.
`control_t_id_company_client` | string | <span class="opt">opcional</span> Hasta 20 caracteres.
`control_t_description_company_client` | string | <span class="opt">opcional</span> Hasta 500 caracteres.
`line1`, `line2` | string | <span class="opt">opcional</span> Texto libre.
`aeat_city_code` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Código de municipio AEAT. Obligatorio en direcciones de `ES` con facturación Quantum.

<aside class="warning">No mandes <code>addressable_type</code> ni <code>addressable_id</code> (ni dentro de <code>address</code> ni al nivel raíz): responde <strong>422</strong>. Las direcciones de la cuenta no se ligan a otros registros. Para el domicilio fiscal de un contacto usa <a href="#crear-el-domicilio-fiscal-de-un-contacto">Crear el domicilio fiscal de un contacto</a>, que garantiza uno solo por contacto.</aside>

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/addresses \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "name": "Aduana Nuevo Laredo",
      "alias": "ADU-NLD",
      "address_type": "customs",
      "street": "Av. Puente Internacional",
      "outdoor_number": "2500",
      "neighborhood": "Centro",
      "city": "Nuevo Laredo",
      "state": "TAM",
      "country": "MX",
      "postal_code": "88000",
      "description": "Despacho de importaciones terrestres",
      "contact_information": "Ventanilla 4 · 867 712 0000"
    }
  }'
```

```javascript
const { status, body } = await api("/addresses", {
  method: "POST",
  body: JSON.stringify({
    address: {
      name: "Aduana Nuevo Laredo",
      alias: "ADU-NLD",
      address_type: "customs",
      street: "Av. Puente Internacional",
      outdoor_number: "2500",
      neighborhood: "Centro",
      city: "Nuevo Laredo",
      state: "TAM",
      country: "MX",
      postal_code: "88000",
      description: "Despacho de importaciones terrestres",
      contact_information: "Ventanilla 4 · 867 712 0000",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/addresses", json={
    "address": {
        "name": "Aduana Nuevo Laredo",
        "alias": "ADU-NLD",
        "address_type": "customs",
        "street": "Av. Puente Internacional",
        "outdoor_number": "2500",
        "neighborhood": "Centro",
        "city": "Nuevo Laredo",
        "state": "TAM",
        "country": "MX",
        "postal_code": "88000",
        "description": "Despacho de importaciones terrestres",
        "contact_information": "Ventanilla 4 · 867 712 0000",
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "address": {
    "id": 2045,
    "alias": "ADU-NLD",
    "name": "Aduana Nuevo Laredo",
    "address_type": "customs",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Nuevo Laredo",
    "state": "TAM",
    "country": "MX",
    "postal_code": "88000",
    "addressable": null,
    "created_at": "2026-11-11T09:41:03.000-06:00",
    "updated_at": "2026-11-11T09:41:03.000-06:00",
    "description": "Despacho de importaciones terrestres",
    "contact_information": "Ventanilla 4 · 867 712 0000",
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Puente Internacional",
    "outdoor_number": "2500",
    "internal_number": null,
    "neighborhood": "Centro",
    "aeat_city_code": null,
    "full_address": "Av. Puente Internacional 2500 Centro Nuevo Laredo TAM 88000 MX"
  },
  "message": "Dirección creada exitosamente"
}
```

### Respuesta

**201** con el detalle en `address` y `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta un campo obligatorio; `address_type` fuera de la lista (el mensaje trae los permitidos); `country` no es de dos letras mayúsculas; código postal que no es de cinco dígitos en `MX` o `ES`; alias que ya usa otra dirección de la cuenta; texto más largo que su límite; mandaste `addressable_type` o `addressable_id`.
`403` `forbidden` | El usuario no tiene `addresses_create`.

> Error 422 · address_type

```json
{
  "error": "validation_failed",
  "message": "address_type Valor inválido. Valores permitidos: billing, shipping, port, customs, airport, general",
  "errors": ["address_type Valor inválido. Valores permitidos: billing, shipping, port, customs, airport, general"],
  "request_id": "4e9b2c71-8a05-4d3f-b6e2-91c7f0a3d528"
}
```

### Dónde se usa una dirección

Recurso | Campo
--------- | -----------
[Servicios](#servicios) | `customs_address_code` (alias, sin distinguir mayúsculas) o `customs_address_id`: aduana del servicio.
[Cotizaciones](#cotizaciones) | `origin_address_id`, `destination_address_id` y `document_routes_attributes[].address_id`.
[Solicitudes comerciales](#solicitudes-comerciales) | `document_routes_attributes[].address_id`.

En servicios, la API solo recibe la aduana. Las rutas de origen y destino del servicio no se escriben por API.

## Actualizar una dirección

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/addresses/:id</code></div>

<p class="perm">Permiso: <code>addresses_edit</code></p>

Cambia solo los campos que mandas; `PUT` funciona igual. `:id` acepta el id o el alias. Acepta los mismos campos que el alta, con las mismas validaciones. `status` se ignora. Responde **200** con el detalle en `address` y `message`.

- `address_type` fuera de la lista y un alias que ya usa otra dirección responden **422**, igual que en el alta. `addressable_type` y `addressable_id` también.
- Una dirección archivada no se puede cambiar: responde **422** con `code: archived_read_only` y `suggested_action: restore`.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/addresses/ADU-NLD \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "address": { "contact_information": "Ventanilla 6 · 867 712 0001" } }'
```

> Respuesta 200

```json
{
  "address": {
    "id": 2045,
    "alias": "ADU-NLD",
    "name": "Aduana Nuevo Laredo",
    "address_type": "customs",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Nuevo Laredo",
    "state": "TAM",
    "country": "MX",
    "postal_code": "88000",
    "addressable": null,
    "created_at": "2026-11-04T08:20:00.000-06:00",
    "updated_at": "2026-11-11T12:02:51.000-06:00",
    "description": "Despacho de importaciones terrestres",
    "contact_information": "Ventanilla 6 · 867 712 0001",
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Puente Internacional",
    "outdoor_number": "2500",
    "internal_number": null,
    "neighborhood": "Centro",
    "aeat_city_code": null,
    "full_address": "Av. Puente Internacional 2500 Centro Nuevo Laredo TAM 88000 MX"
  },
  "message": "Dirección actualizada exitosamente"
}
```

## Archivar y restaurar una dirección

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/addresses/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/addresses/:id/restore</code></div>

<p class="perm">Permiso: <code>addresses_edit</code></p>

Archivar saca la dirección del listado y de la búsqueda, la deja de solo lectura y cambia su `status` a `inactive`; sigue disponible en `GET /addresses/:id`. Restaurar la regresa. No piden confirmación.

Respuesta | Cuándo
--------- | ------
**200** `outcome: allow` | Se archivó o se restauró.
**422** `code: already_archived` | Archivar una dirección que ya está archivada.
**422** `code: not_archived` | Restaurar una dirección que no está archivada.

Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/addresses/2045/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```

## Eliminar una dirección

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/addresses/:id</code></div>

<p class="perm">Permiso: <code>addresses_delete</code></p>

Elimina una dirección que nada usa. Desaparece de todas las lecturas y aparece en `deleted_since` con su `alias`.

Respuesta | Cuándo
--------- | ------
**200** `outcome: allow` | Se eliminó.
**422** `code: in_use` | La usan rutas de servicios, cotizaciones o solicitudes; el origen o destino de una cotización; la aduana de un servicio o de una solicitud; o una ubicación de carta porte, aunque esos registros estén eliminados. `suggested_action: archive`.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/addresses/2045 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "in_use",
  "title": "No puedes eliminar «Aduana Nuevo Laredo»",
  "message": "Hay 14 elementos que usan «Aduana Nuevo Laredo». Puedes archivarlo.",
  "suggested_action": "archive",
  "errors": ["Hay 14 elementos que usan «Aduana Nuevo Laredo». Puedes archivarlo."],
  "error": "in_use",
  "request_id": "a1c94e27-0b6f-4d3a-8e15-7c2f9d4b6e80"
}
```

## Domicilio fiscal de un contacto

<span class="new">nuevo</span> Las rutas `/api/v1/contacts/:contact_id/addresses` manejan **solo** el domicilio fiscal del contacto: uno por contacto, con `address_type: billing`. Es la dirección que se usa como domicilio del receptor al facturarle.

- <span class="new">nuevo</span> Pide los permisos del contacto: `contacts_read` para leer y `contacts_edit` para crear, cambiar o eliminar. Los permisos `addresses_*` no aplican aquí.
- `:contact_id` acepta el id o el alias del contacto. Funciona también con [prospectos](#prospectos): además de `contacts_read`, pide `leads_read` para leer y `leads_edit` para crear, cambiar o eliminar.
- `:id` acepta el id o el alias de la dirección (sin distinguir mayúsculas), y tiene que ser la del contacto; otra responde **404**.
- `address_type` siempre es `billing`. <span class="new">nuevo</span> Mandar otro tipo responde **422**.
- No mandes `addressable_type` ni `addressable_id`: responde **422**.
- Si el contacto está archivado, crear, cambiar o eliminar su domicilio responde **422** con `code: archived_read_only`.
- El objeto, los campos y las validaciones son los de [El objeto dirección](#el-objeto-direccion).
- También puedes escribirlo dentro del contacto con `billing_address_attributes` (ver [Crear un contacto](#crear-un-contacto)), y leerlo en `billing_address` del detalle del contacto.

## Leer el domicilio fiscal de un contacto

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/contacts/:contact_id/addresses</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/contacts/:contact_id/addresses/:id</code></div>

<p class="perm">Permiso: <code>contacts_read</code></p>

El listado devuelve `addresses` con cero o un elemento y `pagination`. El detalle devuelve `address` con todos los campos. Si el contacto no existe o no lo puedes ver, **404**.

> Petición

```shell
curl https://control.apunto.io/api/v1/contacts/ACME/addresses \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "addresses": [
    {
      "id": 431,
      "alias": "ACME-FISCAL",
      "name": "Fiscal Acme",
      "address_type": "billing",
      "status": "active",
      "archived": false,
      "archived_at": null,
      "city": "Monterrey",
      "state": "NLE",
      "country": "MX",
      "postal_code": "64000",
      "addressable": { "type": "Contact", "id": 812, "name": "Acme Logistics" },
      "created_at": "2026-11-03T10:15:00.000-06:00",
      "updated_at": "2026-11-03T10:15:00.000-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Crear el domicilio fiscal de un contacto

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/contacts/:contact_id/addresses</code></div>

<p class="perm">Permiso: <code>contacts_edit</code></p>

Crea el domicilio fiscal si el contacto aún no tiene. El cuerpo va dentro de `address` con los campos de [Crear una dirección](#crear-una-direccion), salvo `addressable_type` y `addressable_id`. `address_type` queda en `billing`: no lo mandes, y si mandas otro valor responde **422**. Responde **201** con `address` y `message`.

Si el contacto ya tiene domicilio fiscal, responde **422** con su id en `address_id`: cámbialo con `PATCH`.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/contacts/ACME/addresses \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
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
  }'
```

> Respuesta 201

```json
{
  "address": {
    "id": 431,
    "alias": "ACME-FISCAL",
    "name": "Fiscal Acme",
    "address_type": "billing",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Monterrey",
    "state": "NLE",
    "country": "MX",
    "postal_code": "64000",
    "addressable": { "type": "Contact", "id": 812, "name": "Acme Logistics" },
    "created_at": "2026-11-11T10:02:44.000-06:00",
    "updated_at": "2026-11-11T10:02:44.000-06:00",
    "description": null,
    "contact_information": null,
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Constitución",
    "outdoor_number": "100",
    "internal_number": null,
    "neighborhood": "Centro",
    "aeat_city_code": null,
    "full_address": "Av. Constitución 100 Centro Monterrey NLE 64000 MX"
  },
  "message": "Dirección creada exitosamente"
}
```

> Error 422 · ya tiene domicilio

```json
{
  "error": "validation_failed",
  "message": "No se pudo crear la dirección",
  "errors": ["El contacto ya tiene domicilio fiscal. Actualízalo con PATCH /api/v1/contacts/:contact_id/addresses/:id."],
  "address_id": 431,
  "request_id": "c37e0b51-2f84-4a9d-b0e6-58d1f2a7c904"
}
```

## Actualizar el domicilio fiscal de un contacto

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/contacts/:contact_id/addresses/:id</code></div>

<p class="perm">Permiso: <code>contacts_edit</code></p>

Cambia solo los campos que mandas; `PUT` funciona igual. Responde **200** con `address` y `message`. Un `address_type` distinto de `billing` responde **422**. Si el contacto o la dirección están archivados, **422** `archived_read_only`.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/contacts/ACME/addresses/431 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "address": { "postal_code": "64010", "neighborhood": "Obispado" } }'
```

> Respuesta 200

```json
{
  "address": {
    "id": 431,
    "alias": "ACME-FISCAL",
    "name": "Fiscal Acme",
    "address_type": "billing",
    "status": "active",
    "archived": false,
    "archived_at": null,
    "city": "Monterrey",
    "state": "NLE",
    "country": "MX",
    "postal_code": "64010",
    "addressable": { "type": "Contact", "id": 812, "name": "Acme Logistics" },
    "created_at": "2026-11-11T10:02:44.000-06:00",
    "updated_at": "2026-11-11T12:18:30.000-06:00",
    "description": null,
    "contact_information": null,
    "control_t_id_company_client": null,
    "control_t_description_company_client": null,
    "line1": null,
    "line2": null,
    "street": "Av. Constitución",
    "outdoor_number": "100",
    "internal_number": null,
    "neighborhood": "Obispado",
    "aeat_city_code": null,
    "full_address": "Av. Constitución 100 Obispado Monterrey NLE 64010 MX"
  },
  "message": "Dirección actualizada exitosamente"
}
```

## Eliminar el domicilio fiscal de un contacto

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/contacts/:contact_id/addresses/:id</code></div>

<p class="perm">Permiso: <code>contacts_edit</code></p>

Elimina el domicilio fiscal. Después puedes crear otro con `POST`. Responde la decisión del ciclo de vida, con las mismas reglas que [Eliminar una dirección](#eliminar-una-direccion). Si el contacto está archivado, **422** `archived_read_only`.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/contacts/ACME/addresses/431 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "outcome": "allow", "code": null, "title": null, "message": null, "suggested_action": null }
```
