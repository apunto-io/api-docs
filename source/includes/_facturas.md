# Facturas

<p class="lead">Una factura (<code>invoice</code>) es el documento de venta al cliente: conceptos, impuestos y, en México, los datos del CFDI. Con la API capturas el borrador, lo vinculas al centro de costos del folio y lees el resultado del timbrado que se hace en la plataforma.</p>

- **La API no timbra ni cancela.** Crea y edita borradores; el timbrado, el envío al cliente, la cancelación ante el SAT y el registro de cobros se hacen en la plataforma. Después la API te devuelve `status`, `uuid`, `stamped_at` y las ligas al PDF y al XML.
- Una factura **solo se edita en `drafted` o `need_review`**. Timbrada, enviada, pagada o cancelada es evidencia fiscal: cambiarla responde **422**.
- `status`, `uuid`, `stamped_at` y los totales (`subtotal`, `total`, `due_amount`, `total_paid`) no se escriben: mandarlos en un alta o cambio responde **422** `read_only_fields`.
- En cuentas de México el uso de CFDI y la forma de pago son obligatorios, y la fecha de emisión tiene que ser hoy, ayer o anteayer.
- Permisos: `invoices_read` para leer, `invoices_create` para crear, `invoices_edit` para editar, archivar, restaurar, subir archivos y vincular, e `invoices_delete` para eliminar. Sin `invoices_read` el listado sale vacío y el detalle responde 404. Ver [Permisos y alcance](#permisos-y-alcance).
- Para crear la factura directamente desde las líneas de ingreso de un folio usa `POST /api/v1/operations/:id/generate_invoice`, en [Folios operativos](#folios-operativos).

<aside class="notice">A diferencia de los demás recursos, el detalle, el alta, el cambio, la subida de archivos y la vinculación de una factura responden el objeto <strong>directo</strong>, sin envolverlo en <code>{"invoice": …}</code> y sin <code>message</code>.</aside>

## Estados de una factura

`status` cambia en la plataforma (timbrar, enviar, cobrar, cancelar). No se escribe por API: mandarlo responde 422 `read_only_fields`.

Valor | Significado | ¿Se edita por API?
----- | ----------- | ------------------
`drafted` | Borrador. Así nace toda factura creada por API. | Sí
`need_review` | En revisión, por ejemplo después de un intento de timbrado fallido. | Sí
`approval_requested` | En aprobación. | No
`stamping` | Timbrándose. | No
`completed` | Timbrada (CFDI emitido) o registrada con sus documentos externos. | No
`opened` | Abierta (aprobada, sin timbre). | No
`sent` | Enviada al cliente. | No
`viewed` | Vista por el cliente. | No
`partial` | Cobrada en parte. | No
`paid` | Cobrada por completo. | No
`cancellation_requested` | Cancelación en trámite ante el SAT; el CFDI sigue vigente. | No
`voided` | Cancelada. | No

## El objeto factura

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la factura.
`identification` | string | <span class="ro">solo lectura</span> Folio legible. Lo genera la numeración de la cuenta.
`date` | datetime | Fecha de emisión. Por omisión, el momento del alta. Puedes mandar `YYYY-MM-DD`. En México: hoy, ayer o anteayer.
`due_at` | datetime | Vencimiento. Por omisión, el momento del alta.
`description` | string | Descripción u observaciones.
`status` | string | <span class="ro">solo lectura</span> Ver [Estados de una factura](#estados-de-una-factura).
`archived` | boolean | <span class="ro">solo lectura</span> `true` si está archivada.
`archived_at` | datetime | <span class="ro">solo lectura</span> Cuándo se archivó.
`created_at` | datetime | <span class="ro">solo lectura</span> Fecha de creación.
`updated_at` | datetime | <span class="ro">solo lectura</span> Última modificación.
`uuid` | string | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Folio fiscal (UUID del SAT). Se llena al timbrar en la plataforma; `null` mientras no esté timbrada. Con algunos proveedores de timbrado solo se guarda `external_id`.
`stamped_at` | datetime | <span class="ro">solo lectura</span> <span class="new">nuevo</span> Cuándo se timbró.
`exchange_rate` | decimal | Tipo de cambio. Obligatorio si la moneda no es la moneda base de la cuenta. En cuentas en pesos son pesos por unidad de la moneda de la factura (`18.25` por USD), el mismo valor que el `TipoCambio` del CFDI.
`subtotal` | decimal | <span class="ro">solo lectura</span> Suma de las líneas sin impuestos.
`total` | decimal | <span class="ro">solo lectura</span> Total con impuestos y retenciones.
`due_amount` | decimal | <span class="ro">solo lectura</span> Saldo por cobrar.
`total_paid` | decimal | <span class="ro">solo lectura</span> Cobrado hasta ahora (pagos y notas de crédito aplicadas). Puede venir `null` si nunca ha tenido cobros.
`external_id` | string | <span class="ro">solo lectura</span> Id del documento en el proveedor de timbrado o del CFDI externo.
`operation_kind` | string | <span class="new">nuevo</span> Tipo de operación: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company` o `import_trading_company`. `null` si no tiene.
`operation_mode` | string | <span class="new">nuevo</span> Modo: `land`, `aerial` o `maritime`. `null` si no tiene.
`tags` | array&lt;string&gt; | <span class="new">nuevo</span> Etiquetas. Se escriben con `tag_list`.
`external_pdf_url` | string | <span class="ro">solo lectura</span> Liga de descarga del PDF (timbrado o subido). `null` si no hay. No pide el token: no la publiques.
`external_xml_url` | string | <span class="ro">solo lectura</span> Liga de descarga del XML. `null` si no hay.
`contact` | object | Cliente: `id`, `alias` y `name`. Se escribe con `contact_code` o `contact_id`.
`currency` | object | Moneda: `id` y `code` (ISO 4217). Se escribe con `currency_code` o `currency_id`.
`cfdi_use` | object | Uso del CFDI: `id` y `code` (`G03`, `S01`, …). `null` si no tiene.
`payment_method` | object | Forma de pago del SAT: `id` y `code` (`01` efectivo, `03` transferencia, `99` por definir). `null` si no tiene.
`payment_type` | object | Método de pago del SAT: `id` y `code` (`PUE` o `PPD`). `null` si no tiene.
`line_items` | array&lt;object&gt; | Líneas (conceptos). Ver la tabla siguiente.

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
`taxes` | array&lt;object&gt; | <span class="new">nuevo</span> Impuestos trasladados de la línea.
`retentions` | array&lt;object&gt; | <span class="new">nuevo</span> Retenciones de la línea.
`link_cost_center_id` | integer | Línea del [centro de costos](#centro-de-costos) vinculada. `null` si no tiene. Ver [Facturas y centro de costos](#facturas-y-centro-de-costos).
`linked_to_cost_center` | boolean | <span class="ro">solo lectura</span> `true` si la línea está vinculada al centro de costos.

Cada impuesto de `taxes` y cada retención de `retentions`:

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id del impuesto en esta línea. Úsalo con `_destroy` para quitarlo.
`account_contribution_id` | integer | Impuesto o retención del catálogo (`GET /api/v1/taxes`, ver [Catálogos](#catalogos)).
`name` | string | <span class="ro">solo lectura</span> Nombre (`IVA 16%`).
`percentage` | decimal | <span class="ro">solo lectura</span> Tasa.
`amount` | decimal | <span class="ro">solo lectura</span> Importe calculado.

> Objeto factura

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "date": "2026-11-11T00:00:00.000-06:00",
  "due_at": "2026-12-11T00:00:00.000-06:00",
  "description": "Maniobras en puerto IMP-ACME-000184",
  "status": "completed",
  "archived": false,
  "archived_at": null,
  "created_at": "2026-11-11T10:30:12.448-06:00",
  "updated_at": "2026-11-11T12:05:40.913-06:00",
  "uuid": "5F3A9C1E-7B2D-4E8F-A1C6-0D9B3E7F2A41",
  "stamped_at": "2026-11-11T12:05:38.102-06:00",
  "exchange_rate": "18.25",
  "subtotal": "700.0",
  "total": "812.0",
  "due_amount": "812.0",
  "total_paid": null,
  "external_id": "5F3A9C1E-7B2D-4E8F-A1C6-0D9B3E7F2A41",
  "operation_kind": "importation",
  "operation_mode": "maritime",
  "tags": [],
  "external_pdf_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDJ9fQ==--3a7c9e1b5d2f/FAC-1203.pdf",
  "external_xml_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDN9fQ==--6b2d8f0a4c1e/FAC-1203.xml",
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "currency": { "id": 2, "code": "USD" },
  "cfdi_use": { "id": 3, "code": "G03" },
  "payment_method": { "id": 4, "code": "03" },
  "payment_type": { "id": 1, "code": "PUE" },
  "line_items": [
    {
      "id": 20417,
      "item_id": 640,
      "item_sku": "MANIOBRAS",
      "description": "Maniobras en puerto",
      "quantity": "2.0",
      "price": "350.0",
      "discount": "0.0",
      "taxes": [
        {
          "id": 30881,
          "account_contribution_id": 2,
          "name": "IVA 16%",
          "percentage": "16.0",
          "amount": "112.0"
        }
      ],
      "retentions": [],
      "link_cost_center_id": 9101,
      "linked_to_cost_center": true
    }
  ]
}
```

## Listar facturas

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/invoices</code></div>

<p class="perm">Permiso: <code>invoices_read</code></p>

Devuelve las facturas de la cuenta, de la más reciente a la más antigua (por `created_at`). Cada elemento es un resumen: trae `id`, `identification`, `date`, `due_at`, `description`, `status`, `archived`, `archived_at`, `created_at`, `updated_at`, `external_id`, `uuid`, `stamped_at`, `exchange_rate`, `subtotal`, `total`, `external_pdf_url`, `external_xml_url`, `contact` y `currency`. Para líneas, datos del CFDI, `due_amount` y `total_paid` pide el detalle.

<aside class="notice"><span class="new">nuevo</span> El listado ahora responde <code>{"invoices": [...], "pagination": {...}}</code>. Antes era un arreglo sin paginar.</aside>

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`status` | string | <span class="opt">opcional</span> <span class="new">nuevo</span> Solo facturas con ese estado (ver [Estados de una factura](#estados-de-una-factura)). Para varios, repítelo: `status[]=drafted&status[]=need_review`.
`archived` | boolean | <span class="opt">opcional</span> `true` lista solo las archivadas. Sin él, solo las no archivadas.
`page`, `per_page` | integer | <span class="opt">opcional</span> Ver [Paginación](#paginacion).
`updated_since`, `deleted_since` | datetime | <span class="opt">opcional</span> <span class="new">nuevo</span> Ver [Sincronización incremental](#sincronizacion-incremental). Las lápidas traen `identification` como código.

> Petición

```shell
curl "https://control.apunto.io/api/v1/invoices?status=completed&per_page=50" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "invoices": [
    {
      "id": 5531,
      "identification": "FAC-1203",
      "date": "2026-11-11T00:00:00.000-06:00",
      "due_at": "2026-12-11T00:00:00.000-06:00",
      "description": "Maniobras en puerto IMP-ACME-000184",
      "status": "completed",
      "archived": false,
      "archived_at": null,
      "created_at": "2026-11-11T10:30:12.448-06:00",
      "updated_at": "2026-11-11T12:05:40.913-06:00",
      "external_id": "5F3A9C1E-7B2D-4E8F-A1C6-0D9B3E7F2A41",
      "uuid": "5F3A9C1E-7B2D-4E8F-A1C6-0D9B3E7F2A41",
      "stamped_at": "2026-11-11T12:05:38.102-06:00",
      "exchange_rate": "18.25",
      "subtotal": "700.0",
      "total": "812.0",
      "external_pdf_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDJ9fQ==--3a7c9e1b5d2f/FAC-1203.pdf",
      "external_xml_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDN9fQ==--6b2d8f0a4c1e/FAC-1203.xml",
      "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
      "currency": { "id": 2, "code": "USD" }
    }
  ],
  "pagination": { "page": 1, "per_page": 50, "total": 1 }
}
```

## Obtener una factura

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/invoices/:id</code></div>

<p class="perm">Permiso: <code>invoices_read</code></p>

Devuelve la factura completa, con sus líneas, impuestos y datos del CFDI, sin objeto raíz. Las archivadas también se leen.

> Petición

```shell
curl https://control.apunto.io/api/v1/invoices/5531 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "status": "completed",
  "uuid": "5F3A9C1E-7B2D-4E8F-A1C6-0D9B3E7F2A41",
  "stamped_at": "2026-11-11T12:05:38.102-06:00",
  "total": "812.0",
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "currency": { "id": 2, "code": "USD" }
}
```

La respuesta completa tiene todos los campos de [El objeto factura](#el-objeto-factura); arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | La factura no existe, es de otra cuenta, ya se eliminó o no tienes `invoices_read` («Factura no encontrada»).

## Crear una factura

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/invoices</code></div>

<p class="perm">Permiso: <code>invoices_create</code></p>

Crea la factura en borrador (`drafted`) con sus líneas. El usuario del token queda como quien la creó. La API no la timbra.

### Cuerpo de la petición

Va dentro del objeto `invoice`. Para cada referencia manda el código o el id, no ambos.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`contact_code` | string | <span class="req">obligatorio</span> Alias del cliente. O `contact_id`. Tiene que ser un contacto de tu cuenta.
`currency_code` | string | <span class="req">obligatorio</span> Moneda ISO 4217 (`MXN`, `USD`). O `currency_id`.
`exchange_rate` | decimal | <span class="opt">opcional</span> Obligatorio si la moneda no es la base de la cuenta. Ver [El objeto factura](#el-objeto-factura).
`date` | date | <span class="opt">opcional</span> Fecha de emisión. Por omisión, ahora. En cuentas de México tiene que ser hoy, ayer o anteayer.
`due_at` | date | <span class="opt">opcional</span> Vencimiento. Por omisión, ahora.
`description` | string | <span class="opt">opcional</span> Descripción u observaciones.
`cfdi_use_code` | string | <span class="opt">opcional</span> Uso del CFDI (`G03`). O `cfdi_use_id`. **Obligatorio en cuentas de México.**
`payment_method_code` | string | <span class="opt">opcional</span> Forma de pago del SAT (`01`, `03`, `99`). O `payment_method_id`. **Obligatorio en cuentas de México.**
`payment_type_code` | string | <span class="opt">opcional</span> Método de pago del SAT (`PUE`, `PPD`). O `payment_type_id`.
`operation_kind` | string | <span class="opt">opcional</span> Tipo de operación: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company` o `import_trading_company`. Otro valor responde 422 con los valores permitidos.
`operation_mode` | string | <span class="opt">opcional</span> Modo: `land`, `aerial` o `maritime`. Otro valor responde 422 con los valores permitidos.
`tag_list` | array&lt;string&gt; | <span class="opt">opcional</span> Etiquetas que ya existan en el catálogo de la cuenta (**Configuración → Etiquetas**). Vuelven en `tags`.
`line_items_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Líneas. Ver la tabla siguiente.

Cada elemento de `line_items_attributes`:

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`item_sku` | string | <span class="req">obligatorio</span> <span class="new">nuevo</span> SKU de un concepto no archivado del catálogo (`GET /api/v1/items`). O `item_id`.
`description` | string | <span class="opt">opcional</span> Texto de la línea. Si va vacío, toma el nombre del concepto.
`quantity` | decimal | <span class="opt">opcional</span> Cantidad. `1` por omisión.
`price` | decimal | <span class="opt">opcional</span> Precio unitario sin impuestos. Si va vacío, toma el precio del concepto.
`discount` | decimal | <span class="opt">opcional</span> Descuento en importe. `0` por omisión.
`line_item_taxes_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Impuestos: `[{ "account_contribution_id": 2 }]`, con ids de `GET /api/v1/taxes`.
`line_item_retentions_attributes` | array&lt;object&gt; | <span class="opt">opcional</span> Retenciones, con la misma forma.
`link_cost_center_id` | integer | <span class="opt">opcional</span> Id de una línea del centro de costos de tu cuenta para vincularla al crear. También se acepta con su nombre interno, `link_service_pricing_id`. Ver [Facturas y centro de costos](#facturas-y-centro-de-costos).

<span class="new">nuevo</span> **Impuestos por omisión.** Si una línea nueva no trae `line_item_taxes_attributes` **ni** `line_item_retentions_attributes`, toma los impuestos y retenciones del concepto, igual que la plataforma. Si mandas cualquiera de las dos listas, no se toma ninguno del concepto: manda `"line_item_taxes_attributes": []` para una línea sin impuestos.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/invoices \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "invoice": {
      "contact_code": "ACME",
      "currency_code": "USD",
      "exchange_rate": 18.25,
      "date": "2026-11-11",
      "due_at": "2026-12-11",
      "description": "Maniobras en puerto IMP-ACME-000184",
      "cfdi_use_code": "G03",
      "payment_method_code": "03",
      "payment_type_code": "PUE",
      "line_items_attributes": [
        {
          "item_sku": "MANIOBRAS",
          "quantity": 2,
          "price": 350,
          "line_item_taxes_attributes": [{ "account_contribution_id": 2 }]
        }
      ]
    }
  }'
```

```javascript
const { status, body } = await api("/invoices", {
  method: "POST",
  body: JSON.stringify({
    invoice: {
      contact_code: "ACME",
      currency_code: "USD",
      exchange_rate: 18.25,
      date: "2026-11-11",
      due_at: "2026-12-11",
      description: "Maniobras en puerto IMP-ACME-000184",
      cfdi_use_code: "G03",
      payment_method_code: "03",
      payment_type_code: "PUE",
      line_items_attributes: [
        {
          item_sku: "MANIOBRAS",
          quantity: 2,
          price: 350,
          line_item_taxes_attributes: [{ account_contribution_id: 2 }],
        },
      ],
    },
  }),
});
console.log(status, body.identification);
```

```python
res = api.post(f"{BASE}/invoices", json={
    "invoice": {
        "contact_code": "ACME",
        "currency_code": "USD",
        "exchange_rate": 18.25,
        "date": "2026-11-11",
        "due_at": "2026-12-11",
        "description": "Maniobras en puerto IMP-ACME-000184",
        "cfdi_use_code": "G03",
        "payment_method_code": "03",
        "payment_type_code": "PUE",
        "line_items_attributes": [
            {
                "item_sku": "MANIOBRAS",
                "quantity": 2,
                "price": 350,
                "line_item_taxes_attributes": [{"account_contribution_id": 2}],
            }
        ],
    }
})
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "date": "2026-11-11T00:00:00.000-06:00",
  "due_at": "2026-12-11T00:00:00.000-06:00",
  "description": "Maniobras en puerto IMP-ACME-000184",
  "status": "drafted",
  "archived": false,
  "archived_at": null,
  "created_at": "2026-11-11T10:30:12.448-06:00",
  "updated_at": "2026-11-11T10:30:12.448-06:00",
  "uuid": null,
  "stamped_at": null,
  "exchange_rate": "18.25",
  "subtotal": "700.0",
  "total": "812.0",
  "due_amount": "812.0",
  "total_paid": null,
  "external_id": null,
  "operation_kind": "importation",
  "operation_mode": "maritime",
  "tags": [],
  "external_pdf_url": null,
  "external_xml_url": null,
  "contact": { "id": 812, "alias": "ACME", "name": "Acme Logistics" },
  "currency": { "id": 2, "code": "USD" },
  "cfdi_use": { "id": 3, "code": "G03" },
  "payment_method": { "id": 4, "code": "03" },
  "payment_type": { "id": 1, "code": "PUE" },
  "line_items": [
    {
      "id": 20417,
      "item_id": 640,
      "item_sku": "MANIOBRAS",
      "description": "Maniobras en puerto",
      "quantity": "2.0",
      "price": "350.0",
      "discount": "0.0",
      "taxes": [
        {
          "id": 30881,
          "account_contribution_id": 2,
          "name": "IVA 16%",
          "percentage": "16.0",
          "amount": "112.0"
        }
      ],
      "retentions": [],
      "link_cost_center_id": null,
      "linked_to_cost_center": false
    }
  ]
}
```

### Respuesta

**201** con la factura completa, sin objeto raíz y sin `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta cliente o moneda; un código no existe («Contact code Contacto no encontrado con el código proporcionado»); un concepto no existe («Line items Concepto no encontrado: MANIOBRAS»); en México falta el uso de CFDI o la forma de pago, o `date` cae fuera de hoy, ayer o anteayer; falta `exchange_rate`; una etiqueta no está en el catálogo; el contacto es de otra cuenta; `operation_kind` u `operation_mode` no es un valor permitido («Valor inválido. Valores permitidos: …»). El detalle viene en `errors`.
`422` `validation_failed` | Un `link_cost_center_id` no es una línea del centro de costos de tu cuenta («Estas líneas del centro de costos no existen en esta cuenta: 9999…»), o la misma línea viene en dos líneas de la factura.
`422` `read_only_fields` | Mandaste `status`, `uuid`, `stamped_at`, `subtotal`, `total`, `due_amount` o `total_paid`. La lista viene en `fields`.
`403` `forbidden` | El usuario no tiene `invoices_create`.

> Error 422

```json
{
  "errors": [
    "Cfdi use debes seleccionar un uso de CFDI",
    "Payment method debes seleccionar una forma de pago"
  ],
  "message": "No se pudo crear la factura",
  "error": "validation_failed",
  "request_id": "7b3e5a1c-9d2f-4c8e-a6b0-1e3c5a7d9f2b"
}
```

## Actualizar una factura

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/invoices/:id</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Cambia solo lo que mandas; lo que omites no cambia. `PUT` funciona igual. Acepta los campos del alta. <span class="new">nuevo</span> Solo funciona con la factura en `drafted` o `need_review`; en cualquier otro estado responde 422 y no cambia nada.

- **Líneas.** En `line_items_attributes`, una línea con `id` se edita; con `"id": 20417, "_destroy": true` se quita; sin `id` se agrega. Las líneas que no mandas quedan igual. Una línea existente no toma valores ni impuestos del concepto.
- **Impuestos de una línea.** Para agregar uno manda `{ "account_contribution_id": 2 }`; para quitarlo, `{ "id": 30881, "_destroy": true }` con el `id` que trae `taxes`.
- **Fecha y CFDI (cuentas de México).** La regla de hoy, ayer o anteayer solo se revisa si cambias `date`. El uso de CFDI y la forma de pago no se pueden dejar vacíos.
- **Vínculos.** `link_cost_center_id` en una línea sigue las reglas de [Facturas y centro de costos](#facturas-y-centro-de-costos).
- `status`, `uuid`, `stamped_at` y los totales responden 422 `read_only_fields`. Otros campos que no están en la tabla del alta (`identification`, …) se ignoran.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/invoices/5531 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "invoice": {
      "payment_type_code": "PPD",
      "payment_method_code": "99",
      "line_items_attributes": [
        { "id": 20417, "quantity": 3 }
      ]
    }
  }'
```

> Respuesta 200

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "status": "drafted",
  "subtotal": "1050.0",
  "total": "1218.0",
  "payment_method": { "id": 7, "code": "99" },
  "payment_type": { "id": 2, "code": "PPD" }
}
```

La respuesta trae la factura completa, como en [Obtener una factura](#obtener-una-factura); arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La factura ya no está en `drafted` ni `need_review` («Esta factura ya no se puede editar (status completed). Solo se editan facturas en borrador o en revisión.»), o los datos no pasan las validaciones del alta.
`422` `read_only_fields` | Mandaste `status`, `uuid`, `stamped_at` o un total.
`422` `archived_read_only` | La factura está archivada. Restáurala primero.
`404` `not_found` | La factura no existe, o un `id` de `line_items_attributes` no es una línea de esta factura.
`403` `forbidden` | El usuario no tiene `invoices_edit`.

> Error 422

```json
{
  "errors": ["Esta factura ya no se puede editar (status completed). Solo se editan facturas en borrador o en revisión."],
  "message": "No se pudo actualizar la factura",
  "error": "validation_failed",
  "request_id": "0e4a6c8f-2b1d-4e3a-9f5c-7a9b1d3f5e70"
}
```

## Subir el PDF y el XML de una factura

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/invoices/:id/update_documents</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Guarda en la factura el PDF, el XML o ambos, y reemplaza los que tuviera. Sirve para facturas emitidas fuera de Apunto. La petición es `multipart/form-data` con los archivos dentro de `invoice`.

- <span class="new">nuevo</span> **Solo en borrador.** Igual que en la plataforma, los archivos solo se suben a una factura en `drafted`. En cualquier otro estado (incluido `need_review`) responde 422: una factura timbrada o emitida conserva sus archivos.
- **No lee el XML.** No cambia `status`, `uuid`, `external_id` ni `stamped_at`. Registrar la factura como emitida (folio fiscal y estado) se hace en la plataforma.
- Si la factura tiene líneas vinculadas al centro de costos de uno o más folios (o gastos a cuenta de terceros), los archivos también se copian a una carpeta raíz `Factura <identification>` de cada folio. Si no hay folio relacionado, solo quedan en la factura. Si esa copia falla, los archivos ya quedaron en la factura y la respuesta sigue siendo 200. Ver [Documentos y archivos](#documentos-y-archivos).

### Campos del formulario

Campo | Tipo | Descripción
--------- | ---- | -----------
`invoice[external_pdf]` | archivo | <span class="opt">opcional</span> PDF de la factura.
`invoice[external_xml]` | archivo | <span class="opt">opcional</span> XML del CFDI.

Manda al menos uno, como archivo del formulario. Un texto (base64, URL) responde 422. No se valida el tipo ni el contenido de los archivos.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/invoices/5531/update_documents \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -F "invoice[external_pdf]=@FAC-1203.pdf;type=application/pdf" \
  -F "invoice[external_xml]=@FAC-1203.xml;type=application/xml"
```

> Respuesta 200

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "status": "drafted",
  "external_pdf_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDJ9fQ==--3a7c9e1b5d2f/FAC-1203.pdf",
  "external_xml_url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTEwMDN9fQ==--6b2d8f0a4c1e/FAC-1203.xml"
}
```

La respuesta trae la factura completa; arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`422` `parameter_missing` | No mandaste `invoice[external_pdf]` ni `invoice[external_xml]` («Envía external_pdf y/o external_xml dentro de invoice (multipart/form-data).»).
`422` `validation_failed` | La factura no está en `drafted` («El PDF y el XML solo se suben a una factura en borrador (status actual: completed)…»), o un archivo llegó como texto y no como archivo del formulario.
`422` `archived_read_only` | La factura está archivada.
`403` `forbidden` | El usuario no tiene `invoices_edit`.

> Error 422

```json
{
  "error": "validation_failed",
  "message": "El PDF y el XML solo se suben a una factura en borrador (status actual: completed). Una factura timbrada o emitida conserva sus archivos.",
  "errors": ["El PDF y el XML solo se suben a una factura en borrador (status actual: completed). Una factura timbrada o emitida conserva sus archivos."],
  "request_id": "3e5a7c9b-1d2f-4a6c-8e0b-4f6a8c0e2b3d"
}
```

## Archivar y restaurar una factura

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/invoices/:id/archive</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/invoices/:id/restore</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Responden la decisión del ciclo de vida (ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar)). Ninguna de las dos pide confirmación: responden `allow` o `reject`. Archivar y restaurar no cambian `status`.

**Solo se archiva una factura cancelada** (`voided`). En los demás casos la respuesta es `reject`:

`code` | Cuándo | `suggested_action`
------ | ------ | ------------------
`delete_instead` | Está en `drafted` o `need_review`: un borrador se elimina, no se archiva. | `delete`
`approval_pending` | Está en `approval_requested`. | `null`
`in_progress` | Se está timbrando o procesando. | `null`
`cancellation_pending` | Está en `cancellation_requested`. | `null`
`cancel_first` | Está timbrada, emitida o cobrada: primero hay que cancelarla, y eso se hace en la plataforma. | `cancel`
`already_archived` | Ya está archivada. | `null`

Restaurar responde `allow` si la factura está archivada y `reject` con `code` `not_archived` si no lo está.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/invoices/5531/archive \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 422

```json
{
  "outcome": "reject",
  "code": "cancel_first",
  "title": "No se puede archivar esta factura",
  "message": "Primero cancela esta factura. Después puedes archivarla.",
  "suggested_action": "cancel",
  "errors": ["Primero cancela esta factura. Después puedes archivarla."],
  "error": "cancel_first",
  "request_id": "c2e4a6b8-0d1f-4a3c-8e5b-7d9f1b3c5e7a"
}
```

### Errores

Código | Cuándo
------ | ------
`422` (decisión `reject`) | Ver la tabla de arriba.
`403` `forbidden` | El usuario no tiene `invoices_edit`.
`404` `not_found` | La factura no existe o ya se eliminó.

## Eliminar una factura

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/invoices/:id</code></div>

<p class="perm">Permiso: <code>invoices_delete</code></p>

Borrado lógico: la factura deja de aparecer y sale como lápida en `deleted_since`. Solo se eliminan facturas en `drafted` o `need_review`. Las líneas del centro de costos que tenía vinculadas quedan libres para facturarse otra vez. Responde la decisión del ciclo de vida, sin paso de confirmación.

`code` | Cuándo | `suggested_action`
------ | ------ | ------------------
`fiscal_history` | Está emitida, timbrada o cobrada (`opened`, `sent`, `viewed`, `completed`, `partial`, `paid`). | `cancel`
`voided_never_deleted` | Está cancelada: archívala. | `archive`
`approval_pending` | Está en `approval_requested`. | `null`
`in_progress` | Se está timbrando. | `null`
`cancellation_pending` | Está en `cancellation_requested`. | `null`
`integrity` | Es borrador pero tiene timbre fiscal, datos de cancelación, un trámite de cancelación, o notas de crédito o pagos relacionados. El motivo viene en `message`. | `null`
`status_not_supported` | Cualquier otro estado. | `null`

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/invoices/5531 \
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
`403` `forbidden` | El usuario no tiene `invoices_delete`.
`404` `not_found` | La factura no existe o ya se eliminó.

## Facturas y centro de costos

Cada línea de factura se puede vincular con una línea de ingreso del [centro de costos](#centro-de-costos) de un folio. Así la plataforma sabe qué ingresos ya se facturaron y no los ofrece otra vez. Hay tres caminos:

1. **Generar la factura desde el folio** con `POST /api/v1/operations/:id/generate_invoice` (ver [Folios operativos](#folios-operativos)). Las líneas nacen vinculadas.
2. **Vincular después** con [Vincular líneas de una factura al centro de costos](#vincular-lineas-de-una-factura-al-centro-de-costos). Es el camino recomendado: revisa folio, cliente, moneda e importe.
3. **Vincular al crear o editar** mandando `link_cost_center_id` en la línea (también se acepta `link_service_pricing_id`). La línea del centro de costos tiene que ser de tu cuenta y no puede repetirse en la misma petición; si no, responde 422 y no se guarda nada. No compara importes, cliente ni moneda. Si esa línea del centro de costos ya está en otra factura viva, la línea de tu factura queda sin vincular, sin error: revisa `linked_to_cost_center` en la respuesta.

Los endpoints de vincular y desvincular no dependen del estado fiscal: también funcionan con una factura timbrada, mientras no esté cancelada ni archivada. Si está cancelada, o si ya no tiene líneas sin vincular, responden 422 con el motivo; el 403 queda solo para la falta de `invoices_edit`. El camino 3, en cambio, solo sirve mientras la factura se puede editar.

## Buscar líneas del centro de costos para una factura

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/invoices/:id/cost_center_link_options</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Te dice con qué folios y líneas de ingreso puedes vincular las líneas pendientes de esta factura. Una línea del centro de costos es candidata si es de un servicio no cancelado de un folio del **mismo cliente**, está en la **misma moneda** que la factura, tiene concepto y todavía no está facturada. Los folios archivados no aparecen, salvo el que pidas o el que ya esté vinculado a esta factura.

### Parámetros de consulta

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="opt">opcional</span> Folio del que quieres las líneas. Sin él, `cost_centers` viene vacío y solo obtienes los folios candidatos.

### Respuesta

Campo | Tipo | Descripción
--------- | ---- | -----------
`operations` | array&lt;object&gt; | Folios con al menos una línea candidata: `id` e `identification`.
`cost_centers` | array&lt;object&gt; | Líneas candidatas del folio pedido: `id`, `concept`, `income_amount`, `currency.code` y `service` (`id`, `identification`).
`unlinked_line_items` | array&lt;object&gt; | Líneas de la factura sin vincular: `id`, `item_id`, `description`, `quantity`, `price` y `amount` (cantidad × precio − descuento, sin impuestos).

> Petición

```shell
curl "https://control.apunto.io/api/v1/invoices/5531/cost_center_link_options?operation_id=1042" \
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
      "id": 9101,
      "concept": "Maniobras en puerto",
      "income_amount": "700.0",
      "currency": { "code": "USD" },
      "service": { "id": 2210, "identification": "SRV-002210" }
    }
  ],
  "unlinked_line_items": [
    {
      "id": 20417,
      "item_id": 640,
      "description": "Maniobras en puerto",
      "quantity": "2.0",
      "price": "350.0",
      "amount": "700.0"
    }
  ]
}
```

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | La factura está cancelada («La factura está cancelada: sus líneas ya no se vinculan ni se desvinculan del centro de costos.») o ya tiene todas sus líneas vinculadas («Todas las líneas de esta factura ya están vinculadas al centro de costos…»).
`403` `forbidden` | El usuario no tiene `invoices_edit`.
`404` `not_found` | La factura no existe.

## Vincular líneas de una factura al centro de costos

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/invoices/:id/link_cost_centers</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Vincula una o varias líneas de la factura con líneas de ingreso de un folio. Se guardan todas o ninguna.

### Cuerpo de la petición

Va dentro del objeto `invoice_cost_center_link_form`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`operation_id` | integer | <span class="req">obligatorio</span> Folio de las líneas del centro de costos.
`links` | object | <span class="req">obligatorio</span> Pares `"<id de línea de factura>": <id de línea del centro de costos>`. Al menos uno.

Cada par tiene que cumplir:

- La línea de factura es de esta factura y todavía no está vinculada.
- La línea del centro de costos es candidata para ese folio (ver [Buscar líneas del centro de costos para una factura](#buscar-lineas-del-centro-de-costos-para-una-factura)).
- El importe de la línea de factura (cantidad × precio − descuento, sin impuestos) es igual al `income_amount` de la línea del centro de costos, con tolerancia de 0.01.
- Cada línea del centro de costos aparece una sola vez.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/invoices/5531/link_cost_centers \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "invoice_cost_center_link_form": {
      "operation_id": 1042,
      "links": { "20417": 9101 }
    }
  }'
```

> Respuesta 200

```json
{
  "id": 5531,
  "identification": "FAC-1203",
  "line_items": [
    {
      "id": 20417,
      "item_sku": "MANIOBRAS",
      "description": "Maniobras en puerto",
      "link_cost_center_id": 9101,
      "linked_to_cost_center": true
    }
  ]
}
```

La respuesta trae la factura completa; arriba se recortó.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `operation_id` o `links`, una línea no es válida o ya está vinculada, la línea del centro de costos no es candidata o se repite, o los importes no coinciden (el mensaje dice qué línea de venta y ambos importes).
`422` `validation_failed` | La factura está cancelada o ya no tiene líneas sin vincular (mismos mensajes que en la búsqueda).
`422` `archived_read_only` | La factura está archivada.
`403` `forbidden` | El usuario no tiene `invoices_edit`.

> Error 422

```json
{
  "errors": ["Una de las líneas de venta seleccionadas no es válida."],
  "message": "No se pudieron vincular las líneas de la factura con el centro de costos",
  "error": "validation_failed",
  "request_id": "9d1f3b5e-7a2c-4e6b-8f0a-2c4e6a8b0d1f"
}
```

## Desvincular una línea de factura del centro de costos

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/invoices/:id/line_items/:line_item_id/unlink_cost_center</code></div>

<p class="perm">Permiso: <code>invoices_edit</code></p>

Quita el vínculo de una línea de la factura. La línea del centro de costos vuelve a quedar pendiente de facturar.

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/invoices/5531/line_items/20417/unlink_cost_center \
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
`422` `archived_read_only` | La factura está archivada.
`422` `validation_failed` | La factura está cancelada.
`404` `not_found` | La factura no existe o la línea no es de esta factura («Línea de factura no encontrada»).
`403` `forbidden` | El usuario no tiene `invoices_edit`.
