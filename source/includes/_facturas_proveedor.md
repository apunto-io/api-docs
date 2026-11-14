# Facturas de proveedor

<p class="lead">Una factura de proveedor (<code>bill</code>) registra lo que te cobra un proveedor: naviera, transportista, agente aduanal. Con la API la capturas desde tu sistema, la vinculas a las líneas de gasto del centro de costos del folio y consultas su saldo.</p>

- **Apunto nunca timbra una factura de proveedor**: el proveedor emite su CFDI y Apunto solo la registra. La API tampoco sube ni valida el PDF o el XML del proveedor, ni registra pagos o aprobaciones de pago; eso se hace en la plataforma.
- El contacto (`contact_code` / `contact_id`) es el **proveedor**. Toda factura de proveedor es un gasto.
- Una factura de proveedor creada por API nace **abierta** (`opened`). Se edita mientras está en `opened` o `need_review` y no está sincronizada con Alegra; si no, responde **422**.
- `status` y los totales (`subtotal`, `total`, `due_amount`, `total_paid`) no se escriben: mandarlos en un alta o cambio responde **422** `read_only_fields`.
- Permisos: `bills_read` para leer, `bills_create` para crear, `bills_edit` para editar, archivar, restaurar y vincular, y `bills_delete` para eliminar. Sin `bills_read` el listado sale vacío y el detalle responde 404. Ver [Permisos y alcance](#permisos-y-alcance).
- Para crearla directamente desde las líneas de gasto de un folio usa `POST /api/v1/operations/:id/generate_bill`, en [Folios operativos](#folios-operativos).
- A diferencia de [Facturas](#facturas), aquí las respuestas sí van dentro de `bill` y el alta y los cambios traen `message`. No hay `update_documents`.

## Estados de una factura de proveedor

`status` cambia en la plataforma (validar, pagar, anular). No se escribe por API: mandarlo responde 422 `read_only_fields`.

Valor | Significado | ¿Se edita por API?
----- | ----------- | ------------------
`opened` | Abierta. Así nace toda factura de proveedor creada por API. | Sí
`need_review` | En revisión. | Sí
`drafted` | Borrador: se capturó en la plataforma con PDF o XML pendientes de validar. | No
`completed` | Validada con sus documentos. | No
`partial` | Pagada en parte. | No
`paid` | Pagada por completo. | No
`voided` | Anulada. | No

## El objeto factura de proveedor

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la factura de proveedor.
`identification` | string | <span class="ro">solo lectura</span> Folio interno. Lo genera la numeración de la cuenta.
`date` | datetime | Fecha de la factura. Por omisión, el momento del alta. Puedes mandar `YYYY-MM-DD`.
`due_at` | datetime | Vencimiento del pago. Por omisión, el momento del alta.
`description` | string | Descripción u observaciones.
`status` | string | <span class="ro">solo lectura</span> Ver [Estados de una factura de proveedor](#estados-de-una-factura-de-proveedor).
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivada.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó.
`external_id` | string | Id externo de la factura (por ejemplo, en tu sistema).
`external_number` | string | Número de factura del proveedor.
`exchange_rate` | decimal | Tipo de cambio. Obligatorio si la moneda no es la moneda base de la cuenta. En cuentas en pesos son pesos por unidad de la moneda de la factura (`18.25` por USD).
`subtotal` | decimal | <span class="ro">solo lectura</span> Suma de las líneas sin impuestos.
`total` | decimal | <span class="ro">solo lectura</span> Total con impuestos y retenciones.
`due_amount` | decimal | <span class="ro">solo lectura</span> Saldo por pagar.
`total_paid` | decimal | <span class="ro">solo lectura</span> Pagado hasta ahora (pagos y notas de crédito del proveedor aplicadas). Puede venir `null` si nunca ha tenido pagos.
`paid_at` | datetime | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Cuándo quedó pagada por completo, o `null` si tiene saldo. Si vuelve a tener saldo (por ejemplo, se cancela un pago), regresa a `null`.
`operation_ids` | array&lt;integer&gt; | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Ids de los [folios operativos](#folios-operativos) que cubre, sacados de sus líneas vinculadas al [centro de costos](#facturas-de-proveedor-y-centro-de-costos). Puede cubrir varios folios. `[]` si ninguna línea está vinculada.
`contact` | object | Proveedor: `id`, `alias` y `name`. Se escribe con `contact_code` o `contact_id`.
`currency` | object | Moneda: `id` y `code` (ISO 4217). Se escribe con `currency_code` o `currency_id`.
`created_at` | datetime | <span class="ro">solo lectura</span> Fecha de creación.
`updated_at` | datetime | <span class="ro">solo lectura</span> Última modificación.
`external_pdf_url` | string | <span class="ro">solo lectura</span> Liga de descarga del PDF del proveedor, si se subió en la plataforma. `null` si no hay. **Solo en el detalle.**
`external_xml_url` | string | <span class="ro">solo lectura</span> Liga de descarga del XML. `null` si no hay. **Solo en el detalle.**
`tags` | array&lt;string&gt; | <span class="ro">solo lectura</span> Etiquetas. Se escriben con `tag_list`. **Solo en el detalle.**
`line_items` | array&lt;object&gt; | Líneas. **Solo en el detalle.** Ver la tabla siguiente.

Cada elemento de `line_items`:

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la línea. Úsalo para editarla o quitarla.
`item_id` | integer | Concepto del catálogo (ver [Catálogos](#catalogos)).
`item_sku` | string | <span class="new">nuevo</span> SKU del concepto.
`description` | string | Texto de la línea.
`quantity` | decimal | Cantidad.
`price` | decimal | Precio unitario sin impuestos.
`discount` | decimal | Descuento en importe (no porcentaje).
`taxes` | array&lt;object&gt; | <span class="new">nuevo</span> Impuestos trasladados: `id`, `account_contribution_id`, `name`, `percentage` y `amount`, igual que en [El objeto factura](#el-objeto-factura).
`retentions` | array&lt;object&gt; | <span class="new">nuevo</span> Retenciones, con la misma forma.
`link_cost_center_id` | integer | Línea de gasto del [centro de costos](#centro-de-costos) vinculada. `null` si no tiene. Ver [Facturas de proveedor y centro de costos](#facturas-de-proveedor-y-centro-de-costos).
`linked_to_cost_center` | boolean | <span class="ro">solo lectura</span> `true` si la línea está vinculada al centro de costos.

> Objeto factura de proveedor

```json
{
  "id": 7720,
  "identification": "FP-0457",
  "date": "2026-11-10T00:00:00.000-06:00",
  "due_at": "2026-12-10T00:00:00.000-06:00",
  "description": "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
  "status": "opened",
  "archived": false,
  "archived_at": null,
  "external_id": null,
  "external_number": "NP-77812",
  "exchange_rate": "18.25",
  "subtotal": "1800.0",
  "total": "1800.0",
  "due_amount": "1800.0",
  "total_paid": null,
  "paid_at": null,
  "operation_ids": [1042],
  "contact": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
  "currency": { "id": 2, "code": "USD" },
  "created_at": "2026-11-11T11:14:52.306-06:00",
  "updated_at": "2026-11-11T11:20:09.874-06:00",
  "external_pdf_url": null,
  "external_xml_url": null,
  "tags": ["Marítimo"],
  "line_items": [
    {
      "id": 20530,
      "item_id": 641,
      "item_sku": "FLETE-MAR",
      "description": "Flete marítimo",
      "quantity": "1.0",
      "price": "1800.0",
      "discount": "0.0",
      "taxes": [
        {
          "id": 31002,
          "account_contribution_id": 1,
          "name": "IVA 0%",
          "percentage": "0.0",
          "amount": "0.0"
        }
      ],
      "retentions": [],
      "link_cost_center_id": 9102,
      "linked_to_cost_center": true
    }
  ]
}
```

## Listar facturas de proveedor

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/bills</code></div>

<p class="perm">Permiso: <code>bills_read</code></p>

Devuelve las facturas de proveedor de la cuenta, de la más reciente a la más antigua (por `created_at`). Cada elemento trae todos los campos del objeto menos `external_pdf_url`, `external_xml_url`, `tags` y `line_items`; pídelos en el detalle.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Solo facturas con ese estado. Para varios, repítelo: `status[]=opened&status[]=partial`.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo las archivadas. Sin él, solo las no archivadas.
`operation_id` | integer | <span class="opt">opcional</span> <span class="new">nuevo</span> Solo las facturas de proveedor con al menos una línea vinculada al centro de costos de ese folio.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas traen `identification` como código.

> Petición

```shell
curl "https://control.apunto.io/api/v1/bills?status=opened" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "bills": [
    {
      "id": 7720,
      "identification": "FP-0457",
      "date": "2026-11-10T00:00:00.000-06:00",
      "due_at": "2026-12-10T00:00:00.000-06:00",
      "description": "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
      "status": "opened",
      "archived": false,
      "archived_at": null,
      "external_id": null,
      "external_number": "NP-77812",
      "exchange_rate": "18.25",
      "subtotal": "1800.0",
      "total": "1800.0",
      "due_amount": "1800.0",
      "total_paid": null,
      "paid_at": null,
      "operation_ids": [1042],
      "contact": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
      "currency": { "id": 2, "code": "USD" },
      "created_at": "2026-11-11T11:14:52.306-06:00",
      "updated_at": "2026-11-11T11:20:09.874-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Obtener una factura de proveedor

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/bills/:id</code></div>

<p class="perm">Permiso: <code>bills_read</code></p>

Devuelve la factura de proveedor completa, con líneas e impuestos, dentro de `bill`. Las archivadas también se leen.

> Petición

```shell
curl https://control.apunto.io/api/v1/bills/7720 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "bill": {
    "id": 7720,
    "identification": "FP-0457",
    "status": "opened",
    "external_number": "NP-77812",
    "total": "1800.0",
    "contact": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "currency": { "id": 2, "code": "USD" },
    "tags": ["Marítimo"]
  }
}
```

La respuesta trae todos los campos de [El objeto factura de proveedor](#el-objeto-factura-de-proveedor); arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | No existe, es de otra cuenta, ya se eliminó o no tienes `bills_read` («Factura de proveedor no encontrada»).

## Crear una factura de proveedor

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/bills</code></div>

<p class="perm">Permiso: <code>bills_create</code></p>

Registra la factura de proveedor con sus líneas. Queda en `opened` y el usuario del token como quien la creó.

### Cuerpo de la petición

Va dentro del objeto `bill`. Para cada referencia manda el código o el id, no ambos.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`contact_code` | string | <span class="req">obligatorio</span> Alias del proveedor. O `contact_id`. Tiene que ser un contacto de tu cuenta; la API no revisa que esté marcado como proveedor.
`currency_code` | string | <span class="req">obligatorio</span> Moneda ISO 4217. O `currency_id`.
`exchange_rate` | decimal | <span class="opt">opcional</span> Obligatorio si la moneda no es la base de la cuenta.
`date` | date | <span class="opt">opcional</span> Fecha de la factura. Por omisión, ahora.
`due_at` | date | <span class="opt">opcional</span> Vencimiento. Por omisión, ahora.
`description` | string | <span class="opt">opcional</span> Descripción u observaciones.
`external_number` | string | <span class="opt">opcional</span> Número de factura del proveedor.
`external_id` | string | <span class="opt">opcional</span> Id externo (por ejemplo, el de tu sistema).
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta (**Configuración → Etiquetas**).
`line_items_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Líneas. Misma forma que en [Crear una factura](#crear-una-factura): `item_sku` o `item_id` (obligatorio), `description`, `quantity`, `price`, `discount`, `line_item_taxes_attributes`, `line_item_retentions_attributes` y `link_cost_center_id` (también se acepta `link_service_pricing_id`).

<span class="new">nuevo</span> Una línea nueva sin `line_item_taxes_attributes` **ni** `line_item_retentions_attributes` toma los impuestos y retenciones del concepto; sin `description` o `price`, toma los del concepto.

La factura de proveedor no lleva uso de CFDI, forma ni método de pago.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/bills \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bill": {
      "contact_code": "NAVPAC",
      "currency_code": "USD",
      "exchange_rate": 18.25,
      "date": "2026-11-10",
      "due_at": "2026-12-10",
      "external_number": "NP-77812",
      "description": "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
      "tag_list": ["Marítimo"],
      "line_items_attributes": [
        {
          "item_sku": "FLETE-MAR",
          "quantity": 1,
          "price": 1800,
          "line_item_taxes_attributes": [{ "account_contribution_id": 1 }]
        }
      ]
    }
  }'
```

```javascript
const { status, body } = await api("/bills", {
  method: "POST",
  body: JSON.stringify({
    bill: {
      contact_code: "NAVPAC",
      currency_code: "USD",
      exchange_rate: 18.25,
      date: "2026-11-10",
      due_at: "2026-12-10",
      external_number: "NP-77812",
      description: "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
      tag_list: ["Marítimo"],
      line_items_attributes: [
        {
          item_sku: "FLETE-MAR",
          quantity: 1,
          price: 1800,
          line_item_taxes_attributes: [{ account_contribution_id: 1 }],
        },
      ],
    },
  }),
});
console.log(status, body.bill.identification);
```

```python
res = api.post(f"{BASE}/bills", json={
    "bill": {
        "contact_code": "NAVPAC",
        "currency_code": "USD",
        "exchange_rate": 18.25,
        "date": "2026-11-10",
        "due_at": "2026-12-10",
        "external_number": "NP-77812",
        "description": "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
        "tag_list": ["Marítimo"],
        "line_items_attributes": [
            {
                "item_sku": "FLETE-MAR",
                "quantity": 1,
                "price": 1800,
                "line_item_taxes_attributes": [{"account_contribution_id": 1}],
            }
        ],
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "bill": {
    "id": 7720,
    "identification": "FP-0457",
    "date": "2026-11-10T00:00:00.000-06:00",
    "due_at": "2026-12-10T00:00:00.000-06:00",
    "description": "Flete marítimo Shanghái–Manzanillo IMP-ACME-000184",
    "status": "opened",
    "archived": false,
    "archived_at": null,
    "external_id": null,
    "external_number": "NP-77812",
    "exchange_rate": "18.25",
    "subtotal": "1800.0",
    "total": "1800.0",
    "due_amount": "1800.0",
    "total_paid": null,
    "paid_at": null,
    "operation_ids": [],
    "contact": { "id": 815, "alias": "NAVPAC", "name": "Naviera del Pacífico" },
    "currency": { "id": 2, "code": "USD" },
    "created_at": "2026-11-11T11:14:52.306-06:00",
    "updated_at": "2026-11-11T11:14:52.306-06:00",
    "external_pdf_url": null,
    "external_xml_url": null,
    "tags": ["Marítimo"],
    "line_items": [
      {
        "id": 20530,
        "item_id": 641,
        "item_sku": "FLETE-MAR",
        "description": "Flete marítimo",
        "quantity": "1.0",
        "price": "1800.0",
        "discount": "0.0",
        "taxes": [
          {
            "id": 31002,
            "account_contribution_id": 1,
            "name": "IVA 0%",
            "percentage": "0.0",
            "amount": "0.0"
          }
        ],
        "retentions": [],
        "link_cost_center_id": null,
        "linked_to_cost_center": false
      }
    ]
  },
  "message": "Factura de proveedor creada exitosamente"
}
```

### Respuesta

**201** con la factura de proveedor completa en `bill` y un texto en `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta proveedor o moneda; un código no existe («Contact code Contacto no encontrado con el código proporcionado»); un concepto no existe («Line items Concepto no encontrado: FLETE-MAR»); falta `exchange_rate`; una etiqueta no está en el catálogo; el contacto es de otra cuenta. El detalle viene en `errors`.
`422` `validation_failed` | Un `link_cost_center_id` no es una línea del centro de costos de tu cuenta, se repite en dos líneas, o ya está en otra factura de proveedor vigente («Estas líneas del centro de costos ya están en otra factura de proveedor vigente: 9102 (FP-0450)…»).
`422` `read_only_fields` | Mandaste `status`, `subtotal`, `total`, `due_amount` o `total_paid`. La lista viene en `fields`.
`403` `forbidden` | El usuario no tiene `bills_create`.

> Error 422

```json
{
  "errors": ["Contact code Contacto no encontrado con el código proporcionado"],
  "message": "No se pudo crear la factura de proveedor",
  "error": "validation_failed",
  "request_id": "4f6b8d0a-2c3e-4a5b-9d7f-1e3a5c7e9b0d"
}
```

## Actualizar una factura de proveedor

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/bills/:id</code></div>

<p class="perm">Permiso: <code>bills_edit</code></p>

Cambia solo lo que mandas; lo que omites no cambia. `PUT` funciona igual. Acepta los campos del alta. <span class="new">nuevo</span> Solo funciona con la factura de proveedor en `opened` o `need_review` y sin sincronizar con Alegra; si no, responde 422 y no cambia nada.

- **Líneas.** Igual que en [Actualizar una factura](#actualizar-una-factura): con `id` se edita, con `id` y `"_destroy": true` se quita, sin `id` se agrega. Las que no mandas quedan igual.
- **Vínculos.** `link_cost_center_id` en una línea sigue las reglas de [Facturas de proveedor y centro de costos](#facturas-de-proveedor-y-centro-de-costos). Dejar en una línea el vínculo que ya tenía no es conflicto.
- `status` y los totales responden 422 `read_only_fields`. Otros campos que no están en la tabla del alta (`identification`, …) se ignoran.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/bills/7720 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "bill": { "due_at": "2026-12-15", "external_id": "ERP-CXP-55120" } }'
```

> Respuesta 200

```json
{
  "bill": {
    "id": 7720,
    "identification": "FP-0457",
    "due_at": "2026-12-15T00:00:00.000-06:00",
    "status": "opened",
    "external_id": "ERP-CXP-55120",
    "external_number": "NP-77812"
  },
  "message": "Factura de proveedor actualizada exitosamente"
}
```

La respuesta trae la factura de proveedor completa; arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Está sincronizada con Alegra («Primero cancela este registro en Alegra. Mientras exista ahí no se puede editar, borrar, regresar a borrador ni anularlo solo en Apunto.»), ya no está en `opened` ni `need_review` («Esta factura de proveedor ya no se puede editar (status completed).»), o los datos no pasan las validaciones del alta.
`422` `validation_failed` | Un `link_cost_center_id` no es de tu cuenta, se repite o ya está en otra factura de proveedor vigente.
`422` `read_only_fields` | Mandaste `status` o un total.
`422` `archived_read_only` | Está archivada. Restáurala primero.
`404` `not_found` | No existe, o un `id` de `line_items_attributes` no es una línea de esta factura de proveedor.
`403` `forbidden` | El usuario no tiene `bills_edit`.

## Archivar y restaurar una factura de proveedor

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/bills/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/bills/:id/restore</code></div>

<p class="perm">Permiso: <code>bills_edit</code></p>

Responden la decisión del ciclo de vida (ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar)), sin paso de confirmación. Archivar y restaurar no cambian `status`.

**Solo se archiva una factura de proveedor anulada** (`voided`). En los demás casos la respuesta es `reject`:

`code` | Cuándo | `suggested_action`
------ | ------ | ------------------
`delete_instead` | Está en `drafted` o `need_review`. | `delete`
`in_progress` | Tiene un trámite en curso. | `null`
`cancel_first` | Está abierta, validada o pagada (`opened`, `completed`, `partial`, `paid`): primero hay que anularla, y eso se hace en la plataforma. | `cancel`
`already_archived` | Ya está archivada. | `null`

Una factura de proveedor abierta (`opened`) que no está en Alegra ni tiene una aprobación de pago pendiente o aprobada sí se puede [eliminar](#eliminar-una-factura-de-proveedor), aunque archivarla sugiera `cancel`.

Restaurar responde `allow` si está archivada y `reject` con `code` `not_archived` si no lo está.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/bills/7720/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 422

```json
{
  "outcome": "reject",
  "code": "cancel_first",
  "title": "No se puede archivar esta factura de proveedor",
  "message": "Primero cancela esta factura de proveedor. Después puedes archivarla.",
  "suggested_action": "cancel",
  "errors": ["Primero cancela esta factura de proveedor. Después puedes archivarla."],
  "error": "cancel_first",
  "request_id": "e5a7c9b1-3d4f-4b6a-8c0e-2f4a6c8e0b1d"
}
```

### Errores

Código | Cuándo
------ | ------
`422` (decisión `reject`) | Ver la tabla de arriba.
`403` `forbidden` | El usuario no tiene `bills_edit`.
`404` `not_found` | No existe o ya se eliminó.

## Eliminar una factura de proveedor

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/bills/:id</code></div>

<p class="perm">Permiso: <code>bills_delete</code></p>

Borrado lógico: deja de aparecer y sale como lápida en `deleted_since`. Se eliminan las que están en `opened`, `drafted` o `need_review`. Las líneas de gasto del centro de costos que tenía vinculadas quedan libres para otra factura de proveedor. Responde la decisión del ciclo de vida, sin paso de confirmación.

`code` | Cuándo | `suggested_action`
------ | ------ | ------------------
`fiscal_history` | Está validada o pagada (`completed`, `partial`, `paid`). | `cancel`
`voided_never_deleted` | Está anulada: archívala. | `archive`
`alegra_synced` | Sigue sincronizada con Alegra. Cancélala allá primero. | `null`
`payment_approval` | Su última aprobación de pago está pendiente o aprobada. | `null`
`integrity` | Tiene timbre fiscal, datos de anulación, un trámite de cancelación, o notas de crédito o pagos relacionados. El motivo viene en `message`. | `null`
`status_not_supported` | Cualquier otro estado. | `null`

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/bills/7720 \
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

### Errores

Código | Cuándo
------ | ------
`422` (decisión `reject`) | Ver la tabla de arriba.
`403` `forbidden` | El usuario no tiene `bills_delete`.
`404` `not_found` | No existe o ya se eliminó.

## Facturas de proveedor y centro de costos

Cada línea de una factura de proveedor se puede vincular con una línea de gasto del [centro de costos](#centro-de-costos) de un folio. Así la plataforma sabe qué costos ya tienen su factura. Hay tres caminos:

1. **Generar la factura de proveedor desde el folio** con `POST /api/v1/operations/:id/generate_bill` (ver [Folios operativos](#folios-operativos)). Las líneas nacen vinculadas.
2. **Vincular después** con [Vincular líneas de una factura de proveedor al centro de costos](#vincular-lineas-de-una-factura-de-proveedor-al-centro-de-costos). Es el camino recomendado: revisa proveedor, moneda e importe.
3. **Vincular al crear o editar** mandando `link_cost_center_id` en la línea (también se acepta `link_service_pricing_id`). La línea de gasto tiene que ser de tu cuenta, no puede repetirse en la misma petición y no puede estar ya en otra factura de proveedor vigente; si no, responde 422 y no se guarda nada. No revisa importe, proveedor ni moneda.

Los endpoints de vincular y desvincular no dependen del estado fiscal: también funcionan con una factura de proveedor validada o pagada, mientras no esté anulada ni archivada. Si está anulada, o si ya no tiene líneas sin vincular, responden 422 con el motivo; el 403 queda solo para la falta de `bills_edit`.

## Buscar líneas del centro de costos para una factura de proveedor

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/bills/:id/cost_center_link_options</code></div>

<p class="perm">Permiso: <code>bills_edit</code></p>

Te dice con qué folios y líneas de gasto puedes vincular las líneas pendientes de esta factura de proveedor. Una línea del centro de costos es candidata si es de un servicio no cancelado, su proveedor es el **mismo** de la factura, su moneda de gasto (o su moneda, si no tiene una aparte) es la de la factura, tiene concepto y todavía no tiene factura de proveedor. Los folios archivados no aparecen, salvo el que pidas o el que ya esté vinculado.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="opt">opcional</span> Folio del que quieres las líneas. Sin él, `cost_centers` viene vacío y solo obtienes los folios candidatos.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`operations` | array&lt;object&gt; | Folios con al menos una línea candidata: `id` e `identification`.
`cost_centers` | array&lt;object&gt; | Líneas candidatas del folio pedido: `id`, `concept`, `expense_amount`, `currency.code` (moneda del gasto) y `service` (`id`, `identification`).
`unlinked_line_items` | array&lt;object&gt; | Líneas de la factura de proveedor sin vincular: `id`, `item_id`, `description`, `quantity`, `price` y `amount` (cantidad × precio − descuento, sin impuestos).

> Petición

```shell
curl "https://control.apunto.io/api/v1/bills/7720/cost_center_link_options?operation_id=1042" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "operations": [
    { "id": 1042, "identification": "IMP-ACME-000184" }
  ],
  "cost_centers": [
    {
      "id": 9102,
      "concept": "Flete marítimo",
      "expense_amount": "1800.0",
      "currency": { "code": "USD" },
      "service": { "id": 2210, "identification": "SRV-002210" }
    }
  ],
  "unlinked_line_items": [
    {
      "id": 20530,
      "item_id": 641,
      "description": "Flete marítimo",
      "quantity": "1.0",
      "price": "1800.0",
      "amount": "1800.0"
    }
  ]
}
```

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La factura de proveedor está anulada («La factura de proveedor está anulada: sus líneas ya no se vinculan ni se desvinculan del centro de costos.») o ya tiene todas sus líneas vinculadas.
`403` `forbidden` | El usuario no tiene `bills_edit`.
`404` `not_found` | No existe.

## Vincular líneas de una factura de proveedor al centro de costos

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/bills/:id/link_cost_centers</code></div>

<p class="perm">Permiso: <code>bills_edit</code></p>

Vincula una o varias líneas de la factura de proveedor con líneas de gasto de un folio. Se guardan todas o ninguna.

### Cuerpo de la petición

Va dentro del objeto `bill_cost_center_link_form`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="req">obligatorio</span> Folio de las líneas del centro de costos.
`links` | object | <span class="req">obligatorio</span> Pares `"<id de línea de la factura>": <id de línea del centro de costos>`. Al menos uno.

Cada par tiene que cumplir:

- La línea es de esta factura de proveedor y todavía no está vinculada.
- La línea del centro de costos es candidata para ese folio (ver [Buscar líneas del centro de costos para una factura de proveedor](#buscar-lineas-del-centro-de-costos-para-una-factura-de-proveedor)).
- El importe de la línea (cantidad × precio − descuento, sin impuestos) es igual al `expense_amount` de la línea del centro de costos, con tolerancia de 0.01.
- Cada línea del centro de costos aparece una sola vez.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/bills/7720/link_cost_centers \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bill_cost_center_link_form": {
      "operation_id": 1042,
      "links": { "20530": 9102 }
    }
  }'
```

> Respuesta 200

```json
{
  "bill": {
    "id": 7720,
    "identification": "FP-0457",
    "line_items": [
      {
        "id": 20530,
        "item_sku": "FLETE-MAR",
        "description": "Flete marítimo",
        "link_cost_center_id": 9102,
        "linked_to_cost_center": true
      }
    ]
  },
  "message": "Las líneas de la factura de proveedor se vincularon correctamente con las líneas de costo del centro de costos"
}
```

La respuesta trae la factura de proveedor completa en `bill`; arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `operation_id` o `links`, una línea no es válida o ya está vinculada, la línea del centro de costos no es candidata o se repite, o los importes no coinciden (el mensaje dice qué línea de gasto y ambos importes).
`422` `validation_failed` | La factura de proveedor está anulada o ya no tiene líneas sin vincular (mismos mensajes que en la búsqueda).
`422` `archived_read_only` | Está archivada.
`403` `forbidden` | El usuario no tiene `bills_edit`.

## Desvincular una línea de factura de proveedor del centro de costos

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/bills/:id/line_items/:line_item_id/unlink_cost_center</code></div>

<p class="perm">Permiso: <code>bills_edit</code></p>

Quita el vínculo de una línea. La línea de gasto del centro de costos vuelve a quedar pendiente de factura de proveedor.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/bills/7720/line_items/20530/unlink_cost_center \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "message": "La línea se desvinculó del centro de costos" }
```

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La línea no está vinculada («Esta línea no tiene una vinculación activa»).
`422` `archived_read_only` | Está archivada.
`422` `validation_failed` | La factura de proveedor está anulada.
`404` `not_found` | No existe, o la línea no es de esta factura de proveedor («Línea de factura de proveedor no encontrada»).
`403` `forbidden` | El usuario no tiene `bills_edit`.
