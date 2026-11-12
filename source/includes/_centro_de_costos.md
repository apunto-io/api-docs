# Centro de costos

<p class="lead">Las líneas del centro de costos (<code>cost_centers</code>) registran, por servicio, lo que le vendes al cliente (ingreso) y lo que te cobra el proveedor (gasto). De ellas sale la utilidad del servicio y del folio operativo, y desde ellas se generan facturas y facturas de proveedor.</p>

Las líneas se crean, cambian y borran en su servicio (`/services/:service_id/cost_centers`). El folio tiene una vista de solo lectura con las líneas de todos sus servicios. Leer necesita ver el servicio (o el folio, en la vista agregada); escribir necesita editar el servicio. Ver [Permisos y alcance](#permisos-y-alcance).

Los importes, monedas, tipos de cambio y la utilidad siguen la misma regla que la plataforma: solo los ve y los escribe quien tiene el permiso `operations_profit_read`. Sin él, esos campos vienen en `null` (la llave sigue en la respuesta) y mandarlos en un alta o cambio responde **403** `forbidden`. Ver [Permiso de importes y utilidad](#permiso-de-importes-y-utilidad).

## Cómo se calcula el centro de costos

Cada línea tiene dos lados y una cantidad común (`quantity`):

Lado | Importe | Moneda | Tipo de cambio
---- | ------- | ------ | --------------
Venta (ingreso) | `income_amount` | `currency` | `exchange_rate`
Compra (gasto) | `expense_amount` | `expense_currency` | `expense_exchange_rate`

- **Importes totales.** `income_amount` y `expense_amount` son el total de la línea, no el precio unitario. Si prefieres mandar precio unitario, usa `income_unit_price` o `expense_unit_price`: la API guarda `precio × quantity` como importe.
- **Tipo de cambio.** Lleva cada importe a la moneda del folio: el folio suma `income_amount × exchange_rate` y `expense_amount × expense_exchange_rate`. Si la moneda de la línea es la del folio, el tipo de cambio es `1`. Si es otra, manda cuántas unidades de la moneda del folio vale una unidad de la moneda de la línea: en un folio en USD, una línea en MXN lleva algo como `0.0541`. Debe ser mayor que 0 y como máximo 10,000.
- **Valores por omisión al crear.** Igual que en la plataforma, un lado sin moneda toma la moneda del folio, y un lado en la moneda del folio toma tipo de cambio `1`. Un lado en otra moneda necesita su tipo de cambio: si los dos lados están en la misma moneda, el tipo que mandes para uno sirve para el otro; si no mandas ninguno, el alta responde **422** («… es requerido cuando se usa una moneda diferente a la del folio») en vez de calcular la utilidad con `1`.
- **Utilidad.** `profit_amount = income_amount × exchange_rate − expense_amount × expense_exchange_rate`, en la moneda del folio. `profit_percentage = profit_amount ÷ (income_amount × exchange_rate) × 100`; es `0` si la línea no tiene venta o no tiene utilidad.
- **Totales del servicio y del folio.** Cada alta, cambio o baja recalcula los totales del servicio y del folio (`income_amount`, `expense_amount`, `profit_amount`, `profit_percentage` del [folio](#el-objeto-folio-operativo)). Las líneas de servicios cancelados no suman en los totales del folio.
- **Proveedor y cliente.** Cada línea lleva un proveedor (`supplier_code` o `supplier_id`, obligatorio): a quien le compras. La venta es siempre para el cliente del folio; no se elige por línea.
- **Concepto.** `concept` es el texto de la línea (obligatorio). `item_id` es opcional y liga la línea a un concepto del catálogo (`GET /api/v1/items`, ver [Catálogos](#catalogos)). Aquí no se acepta `item_sku`: busca el `id` en el catálogo.
- **Impuestos.** Las líneas no llevan impuestos. Al [generar una factura](#generar-una-factura-desde-un-folio-operativo) o una [factura de proveedor](#generar-una-factura-de-proveedor-desde-un-folio-operativo), cada línea del documento toma los impuestos y retenciones de la línea de cotización de la que vino; si no vino de una cotización, los del concepto (`item`).

<aside class="notice">Los cambios (<code>PATCH</code>) no aplican estos valores por omisión: si cambias una moneda, manda también su tipo de cambio.</aside>

> Petición · línea en MXN en un folio en USD

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/cost_centers \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cost_center": {
      "concept": "Demoras de contenedor",
      "supplier_code": "NAVPAC",
      "currency_code": "MXN",
      "exchange_rate": "0.0541",
      "income_amount": "18500",
      "expense_currency_code": "MXN",
      "expense_amount": "15000"
    }
  }'
```

## Líneas bloqueadas por una factura

Cuando una línea está ligada a una factura vigente (no cancelada ni eliminada, incluidos los borradores), el lado que ya se facturó queda fijo para que los totales cuadren con el documento. La liga se crea al [generar la factura](#generar-una-factura-desde-un-folio-operativo) o la [factura de proveedor](#generar-una-factura-de-proveedor-desde-un-folio-operativo) desde el folio, o al ligar líneas desde [Facturas](#facturas) o [Facturas de proveedor](#facturas-de-proveedor). `linked` dice a qué está ligada cada línea.

La línea está ligada a | No puedes cambiar
---------------------- | -----------------
Una factura de cliente vigente | `income_amount` (o `income_unit_price`), `currency`, `exchange_rate` y `quantity`
Una factura de proveedor vigente | `expense_amount` (o `expense_unit_price`), `expense_currency`, `expense_exchange_rate` y `quantity`
Cualquiera de las dos | Tampoco se elimina la línea: `DELETE` responde **422** `reject` con `code` `linked_documents` y el folio del documento en `message`

- Lo demás sí cambia: `concept`, `supplier`, `item_id`, `notes` y el lado que no está facturado.
- Mandar el mismo valor que ya tiene (`"4000"` en lugar de `"4000.0"`) no cuenta como cambio.
- Un cambio bloqueado responde **422** `validation_failed` y no guarda nada de la petición. `errors` dice qué campo y por qué.
- Para desbloquear la línea, cancela o elimina la factura, o desliga la línea desde [Facturas](#facturas) o [Facturas de proveedor](#facturas-de-proveedor).

> Error 422 · venta facturada

```json
{
  "errors": ["Importe de Venta no se puede modificar porque esta línea ya tiene una factura de cliente"],
  "message": "No se pudo actualizar la línea de centro de costos",
  "error": "validation_failed",
  "request_id": "e2b6f1c9-4d7a-4b3e-8f05-1a9c6d2e7b48"
}
```

## Permiso de importes y utilidad

La plataforma muestra y deja editar los importes del centro de costos solo a quien tiene `operations_profit_read`. La API aplica la misma regla:

Sin `operations_profit_read` | Qué pasa
---------------------------- | --------
Al leer una línea (listados, detalle, dentro de un servicio o de un folio) | `income_amount`, `expense_amount`, `profit_amount`, `profit_percentage`, `currency`, `exchange_rate`, `expense_currency` y `expense_exchange_rate` vienen en `null`. `concept`, `quantity`, `supplier`, `item` y lo demás sí vienen
Al leer un folio | `income_amount`, `expense_amount`, `profit_amount` y `profit_percentage` vienen en `null`
Al crear o cambiar una línea | Mandar `currency_code`/`currency_id`, `exchange_rate`, `income_amount`, `income_unit_price`, `expense_currency_code`/`expense_currency_id`, `expense_exchange_rate`, `expense_amount` o `expense_unit_price` responde **403** `forbidden` con esos campos en `fields`. Sin ellos, el alta crea la línea en la moneda del folio con importes en 0

> Error 403 · sin operations_profit_read

```json
{
  "error": "forbidden",
  "message": "Tu usuario no tiene el permiso operations_profit_read: no puede escribir importes, monedas ni tipos de cambio del centro de costos.",
  "errors": ["Tu usuario no tiene el permiso operations_profit_read: no puede escribir importes, monedas ni tipos de cambio del centro de costos."],
  "fields": ["income_amount"],
  "request_id": "4c1e8b37-92d0-4f6a-a5b3-0e7d2c9f1a68"
}
```

## El objeto línea de centro de costos

Los listados devuelven los campos de la primera parte de la tabla. El detalle, el alta y el cambio agregan `notes` y `linked`. Dentro de un [servicio](#el-objeto-servicio) o de un [folio](#el-objeto-folio-operativo) cada línea viene con `notes` y `linked`, sin `service`. `profit_amount` y `profit_percentage` responden **422** `read_only_fields` si los mandas; los demás campos de solo lectura se ignoran. Los importes, monedas, tipos de cambio y la utilidad vienen en `null` sin `operations_profit_read`.

Campo | Tipo | Descripción
----- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Identificador de la línea
`concept` | string | Texto de la línea (`Flete marítimo Shanghai - Manzanillo`)
`quantity` | decimal | Cantidad. Mayor que 0. Por omisión `1`
`income_amount` | decimal | Venta: importe total en `currency`. Por omisión `0`
`expense_amount` | decimal | Compra: importe total en `expense_currency`. Por omisión `0`
`profit_amount` | decimal | <span class="ro">solo lectura</span> Utilidad en la moneda del folio
`profit_percentage` | decimal | <span class="ro">solo lectura</span> Utilidad sobre la venta convertida, × 100
`currency` | object | Moneda de venta: `code` (ISO) y `name`. Se escribe con `currency_code` o `currency_id`
`exchange_rate` | decimal | Tipo de cambio de la venta hacia la moneda del folio. Por omisión `1`
`expense_currency` | object | Moneda de compra: `code` y `name`, o `null`. Se escribe con `expense_currency_code` o `expense_currency_id`
`expense_exchange_rate` | decimal | Tipo de cambio de la compra hacia la moneda del folio. Por omisión `1`
`supplier` | object | Proveedor: `id`, `alias`, `name`. Se escribe con `supplier_code` o `supplier_id`
`item` | object | Concepto del catálogo: `id` y `name`, o `null`. Se escribe con `item_id`
`created_at`, `updated_at` | datetime | <span class="ro">solo lectura</span> Alta y último cambio
`service` | object | <span class="ro">solo lectura</span> Servicio de la línea: `id`, `identification` y `operation_id` (id del folio)
`notes` | string | Solo detalle. Notas internas
`linked` | object | <span class="ro">solo lectura</span> Solo detalle. Ligas de la línea: `quote_line_item_id` (línea de la cotización de la que vino), `invoice_line_item_id` (línea de factura de cliente) y `bill_line_item_id` (línea de factura de proveedor). `null` si no hay liga

> Objeto línea de centro de costos

```json
{
  "id": 5501,
  "concept": "Flete marítimo Shanghai - Manzanillo",
  "quantity": "2.0",
  "income_amount": "4000.0",
  "expense_amount": "3000.0",
  "profit_amount": "1000.0",
  "profit_percentage": "25.0",
  "currency": { "code": "USD", "name": "Dólar estadounidense" },
  "exchange_rate": "1.0",
  "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
  "expense_exchange_rate": "1.0",
  "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
  "item": { "id": 44, "name": "Flete marítimo internacional" },
  "created_at": "2026-11-03T11:02:10.000-06:00",
  "updated_at": "2026-11-03T11:02:10.000-06:00",
  "service": { "id": 2210, "identification": "SRV-000731", "operation_id": 1042 },
  "notes": "Tarifa spot noviembre",
  "linked": {
    "quote_line_item_id": null,
    "invoice_line_item_id": null,
    "bill_line_item_id": null
  }
}
```

## Listar líneas de un servicio

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/cost_centers</code></div>

<p class="perm">Permiso: <code>services_read</code></p>

Devuelve las líneas del servicio, de la más reciente a la más antigua (`created_at`). Con `updated_since` el orden es `updated_at`, `id`. Cada línea trae los campos del listado y `service`. Responde **404** si el servicio no existe o el usuario no lo puede ver.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion)
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas de `deleted_since` traen `id`, `deleted`, `deleted_at` y `updated_at`, sin código

> Petición

```shell
curl "https://control.apunto.io/api/v1/services/2210/cost_centers" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "cost_centers": [
    {
      "id": 5501,
      "concept": "Flete marítimo Shanghai - Manzanillo",
      "quantity": "2.0",
      "income_amount": "4000.0",
      "expense_amount": "3000.0",
      "profit_amount": "1000.0",
      "profit_percentage": "25.0",
      "currency": { "code": "USD", "name": "Dólar estadounidense" },
      "exchange_rate": "1.0",
      "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
      "expense_exchange_rate": "1.0",
      "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "item": { "id": 44, "name": "Flete marítimo internacional" },
      "created_at": "2026-11-03T11:02:10.000-06:00",
      "updated_at": "2026-11-03T11:02:10.000-06:00",
      "service": { "id": 2210, "identification": "SRV-000731", "operation_id": 1042 }
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Listar líneas de un folio operativo

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/cost_centers</code></div>

<p class="perm">Permiso: <code>operations_read</code></p>

Vista de solo lectura del centro de costos de un folio: las líneas de **todos** sus servicios, incluidos los cancelados y los archivados, de la más reciente a la más antigua. Usa `service.id` de cada línea para saber de qué servicio es y para escribirla en su ruta. Las líneas de servicios cancelados aparecen aquí pero no suman en los totales del folio.

Acepta los mismos parámetros que [Listar líneas de un servicio](#listar-lineas-de-un-servicio) y responde con la misma forma. Responde **404** si el folio no existe o el usuario no lo puede ver.

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations/1042/cost_centers?updated_since=2026-11-10T00:00:00Z" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "cost_centers": [
    {
      "id": 5501,
      "concept": "Flete marítimo Shanghai - Manzanillo",
      "quantity": "2.0",
      "income_amount": "4000.0",
      "expense_amount": "3000.0",
      "profit_amount": "1000.0",
      "profit_percentage": "25.0",
      "currency": { "code": "USD", "name": "Dólar estadounidense" },
      "exchange_rate": "1.0",
      "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
      "expense_exchange_rate": "1.0",
      "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "item": { "id": 44, "name": "Flete marítimo internacional" },
      "created_at": "2026-11-03T11:02:10.000-06:00",
      "updated_at": "2026-11-10T17:42:05.000-06:00",
      "service": { "id": 2210, "identification": "SRV-000731", "operation_id": 1042 }
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Obtener una línea de centro de costos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/cost_centers/:id</code></div>

<p class="perm">Permiso: <code>services_read</code></p>

Devuelve la línea con `notes` y `linked`. La línea tiene que ser del servicio de la URL: si es de otro servicio responde **404**, aunque exista.

> Petición

```shell
curl https://control.apunto.io/api/v1/services/2210/cost_centers/5501 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "cost_center": {
    "id": 5501,
    "concept": "Flete marítimo Shanghai - Manzanillo",
    "quantity": "2.0",
    "income_amount": "4000.0",
    "expense_amount": "3000.0",
    "profit_amount": "1000.0",
    "profit_percentage": "25.0",
    "currency": { "code": "USD", "name": "Dólar estadounidense" },
    "exchange_rate": "1.0",
    "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
    "expense_exchange_rate": "1.0",
    "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "item": { "id": 44, "name": "Flete marítimo internacional" },
    "created_at": "2026-11-03T11:02:10.000-06:00",
    "updated_at": "2026-11-03T11:02:10.000-06:00",
    "service": { "id": 2210, "identification": "SRV-000731", "operation_id": 1042 },
    "notes": "Tarifa spot noviembre",
    "linked": {
      "quote_line_item_id": null,
      "invoice_line_item_id": 18842,
      "bill_line_item_id": null
    }
  }
}
```

## Crear una línea de centro de costos

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:service_id/cost_centers</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Agrega una línea de venta y compra al servicio de la URL. El usuario del token queda como creador. Los totales del servicio y del folio se recalculan al guardar.

### Cuerpo de la petición

Todo va dentro de `cost_center`. Para cada referencia manda el código o el id, no los dos.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`concept` | string | <span class="req">obligatorio</span> Texto de la línea
`supplier_code` | string | <span class="req">obligatorio</span> Alias del proveedor. Alternativa: `supplier_id` (debe ser de la cuenta)
`currency_code` | string | <span class="opt">opcional</span> Moneda de venta en ISO 4217 (`USD`, `MXN`). Alternativa: `currency_id`. Por omisión, la moneda del folio
`exchange_rate` | decimal | <span class="opt">opcional</span> Tipo de cambio de la venta hacia la moneda del folio. Por omisión `1` si la venta está en la moneda del folio. En otra moneda es obligatorio, salvo que la compra esté en la misma moneda y mandes `expense_exchange_rate`
`income_amount` | decimal | <span class="opt">opcional</span> Venta total. Por omisión `0`
`income_unit_price` | decimal | <span class="opt">opcional</span> Precio unitario de venta. Si lo mandas, `income_amount` = precio × `quantity`
`expense_currency_code` | string | <span class="opt">opcional</span> Moneda de compra. Alternativa: `expense_currency_id`. Por omisión, la moneda del folio
`expense_exchange_rate` | decimal | <span class="opt">opcional</span> Tipo de cambio de la compra hacia la moneda del folio. Por omisión `1` si la compra está en la moneda del folio, o el `exchange_rate` que mandaste si la compra está en la misma moneda que la venta. Si no, es obligatorio
`expense_amount` | decimal | <span class="opt">opcional</span> Compra total. Por omisión `0`
`expense_unit_price` | decimal | <span class="opt">opcional</span> Costo unitario. Si lo mandas, `expense_amount` = costo × `quantity`
`quantity` | decimal | <span class="opt">opcional</span> Cantidad, mayor que 0. Por omisión `1`
`item_id` | integer | <span class="opt">opcional</span> Concepto del catálogo de la cuenta. Recomendado si vas a facturar la línea
`notes` | string | <span class="opt">opcional</span> Notas internas

`profit_amount` y `profit_percentage` no se aceptan: responden **422** `read_only_fields`. Sin `operations_profit_read`, los campos de moneda, tipo de cambio e importe responden **403** (ver [Permiso de importes y utilidad](#permiso-de-importes-y-utilidad)).

### Respuesta

**201** con `{ "cost_center": {...}, "message": "Línea de centro de costos creada exitosamente" }`. La línea viene con `service`, `notes` y `linked`.

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El servicio no existe o el usuario no lo puede ver
`422` `validation_failed` | `supplier_code`, `currency_code` o `expense_currency_code` no existen
`422` `validation_failed` | Falta `concept` o el proveedor
`422` `validation_failed` | Un lado está en una moneda distinta a la del folio y no tiene tipo de cambio: «Tipo de Cambio de venta es requerido cuando se usa una moneda diferente a la del folio» (o «Tipo de cambio de compra …»)
`422` `read_only_fields` | Mandaste `profit_amount` o `profit_percentage`
`403` `forbidden` | Sin `operations_profit_read` mandaste importes, monedas o tipos de cambio
`422` `validation_failed` | `quantity` o un tipo de cambio es 0 o negativo, o un tipo de cambio pasa de 10,000
`422` `validation_failed` | `supplier_id` o `item_id` son de otra cuenta
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/services/2210/cost_centers \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cost_center": {
      "concept": "Flete marítimo Shanghai - Manzanillo",
      "item_id": 44,
      "supplier_code": "NAVPAC",
      "quantity": 2,
      "currency_code": "USD",
      "exchange_rate": 1,
      "income_unit_price": 2000,
      "expense_currency_code": "USD",
      "expense_exchange_rate": 1,
      "expense_unit_price": 1500,
      "notes": "Tarifa spot noviembre"
    }
  }'
```

```javascript
const { status, body } = await api("/services/2210/cost_centers", {
  method: "POST",
  body: JSON.stringify({
    cost_center: {
      concept: "Flete marítimo Shanghai - Manzanillo",
      item_id: 44,
      supplier_code: "NAVPAC",
      quantity: 2,
      currency_code: "USD",
      exchange_rate: 1,
      income_unit_price: 2000,
      expense_currency_code: "USD",
      expense_exchange_rate: 1,
      expense_unit_price: 1500,
      notes: "Tarifa spot noviembre",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/services/2210/cost_centers", json={
    "cost_center": {
        "concept": "Flete marítimo Shanghai - Manzanillo",
        "item_id": 44,
        "supplier_code": "NAVPAC",
        "quantity": 2,
        "currency_code": "USD",
        "exchange_rate": 1,
        "income_unit_price": 2000,
        "expense_currency_code": "USD",
        "expense_exchange_rate": 1,
        "expense_unit_price": 1500,
        "notes": "Tarifa spot noviembre",
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "cost_center": {
    "id": 5501,
    "concept": "Flete marítimo Shanghai - Manzanillo",
    "quantity": "2.0",
    "income_amount": "4000.0",
    "expense_amount": "3000.0",
    "profit_amount": "1000.0",
    "profit_percentage": "25.0",
    "currency": { "code": "USD", "name": "Dólar estadounidense" },
    "exchange_rate": "1.0",
    "expense_currency": { "code": "USD", "name": "Dólar estadounidense" },
    "expense_exchange_rate": "1.0",
    "supplier": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "item": { "id": 44, "name": "Flete marítimo internacional" },
    "created_at": "2026-11-03T11:02:10.000-06:00",
    "updated_at": "2026-11-03T11:02:10.000-06:00",
    "service": { "id": 2210, "identification": "SRV-000731", "operation_id": 1042 },
    "notes": "Tarifa spot noviembre",
    "linked": {
      "quote_line_item_id": null,
      "invoice_line_item_id": null,
      "bill_line_item_id": null
    }
  },
  "message": "Línea de centro de costos creada exitosamente"
}
```

## Actualizar una línea de centro de costos

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/services/:service_id/cost_centers/:id</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Cambio parcial: manda dentro de `cost_center` solo los campos que cambian; los omitidos no cambian. Acepta los mismos campos que el alta. `PUT` funciona igual. Los totales del servicio y del folio se recalculan al guardar.

- Si la línea está ligada a una factura vigente, el lado facturado y `quantity` no cambian. Ver [Líneas bloqueadas por una factura](#lineas-bloqueadas-por-una-factura).
- `quantity` sola no cambia los importes: son totales. Para recalcularlos manda también `income_unit_price` o `expense_unit_price`, o los importes nuevos.
- Cambiar `exchange_rate` no cambia `expense_exchange_rate`, ni al revés. Los valores por omisión del alta no se aplican aquí.
- `profit_amount` y `profit_percentage` responden **422** `read_only_fields`.
- Sin `operations_profit_read`, mandar importes, monedas o tipos de cambio responde **403** `forbidden`.
- En un servicio o folio archivado responde **422** `archived_read_only`.

### Respuesta

**200** con `{ "cost_center": {...}, "message": "Línea de centro de costos actualizada exitosamente" }`. Responde **404** si la línea no es del servicio de la URL.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/services/2210/cost_centers/5501 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "cost_center": { "expense_amount": "2800", "notes": "Tarifa renegociada" } }'
```

## Eliminar una línea de centro de costos

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/services/:service_id/cost_centers/:id</code></div>

<p class="perm">Permiso: <code>services_edit</code></p>

Elimina la línea (borrado lógico), igual que en la plataforma: recalcula los totales del servicio y del folio y deja la baja en la actividad del servicio. Después aparece como lápida en `deleted_since`.

Responde la decisión del ciclo de vida, no la línea. No pide confirmación. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).

### Respuesta

- **200** `allow`: la línea quedó eliminada.
- **422** `reject` con `code` `linked_documents`: la línea está ligada a una factura o factura de proveedor vigente. `message` dice en qué documentos está. `suggested_action` es `null`: cancela esos documentos o desliga la línea y vuelve a intentar.

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | La línea no existe o no es del servicio de la URL
`422` `linked_documents` | La línea está en una factura o factura de proveedor vigente
`422` `archived_read_only` | El servicio o su folio están archivados

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/services/2210/cost_centers/5501 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "outcome": "allow",
  "code": null,
  "title": null,
  "message": null,
  "suggested_action": null
}
```

> Error 422

```json
{
  "outcome": "reject",
  "code": "linked_documents",
  "title": "No puedes eliminar esta línea",
  "message": "No puedes eliminar esta línea de costo porque está en F-1532. Cancela esos documentos o desvincula la línea y vuelve a intentar.",
  "suggested_action": null,
  "errors": ["No puedes eliminar esta línea de costo porque está en F-1532. Cancela esos documentos o desvincula la línea y vuelve a intentar."],
  "error": "linked_documents",
  "request_id": "9d3c7b21-6e4f-4a18-b0d5-3f2e8a1c7d64"
}
```
