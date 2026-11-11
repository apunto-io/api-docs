# Facturas y facturas de proveedor

## Facturas de cliente (Invoice)

Captura básica para integraciones. **No incluye timbrado CFDI** por API; en cuentas mexicanas la creación exige campos CFDI para dejar el borrador listo para timbrar desde la web.

### Endpoints principales

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/invoices` | Listado paginado: `{ "invoices": [...], "pagination": {...} }`. Filtros `status`, `archived`, `updated_since`, `deleted_since` |
| GET | `/invoices/:id` | Detalle: `uuid`, `stamped_at`, CFDI, totales y `line_items` con sus impuestos |
| POST | `/invoices` | Crear con `line_items_attributes` |
| PATCH | `/invoices/:id` | Actualizar. Solo en borrador (`drafted`) o en revisión (`need_review`); en otro estatus responde 422 |
| DELETE | `/invoices/:id` | Borrado lógico. Una factura timbrada o con evidencia fiscal responde 422 |
| POST | `/invoices/:id/archive` · `/restore` | Archivar y restaurar |
| POST | `/invoices/:id/update_documents` | PDF/XML externos (`multipart/form-data`, `invoice[external_pdf]`, `invoice[external_xml]`). Sin archivos responde 422 |

Cada `line_item` trae `item_id`, `item_sku`, `description`, `quantity`, `price`, `discount`, `taxes`, `retentions`, `link_cost_center_id` y `linked_to_cost_center`. Cada impuesto trae `account_contribution_id`, `name`, `percentage` y `amount`.

El XML y el PDF timbrados se descargan de `external_xml_url` y `external_pdf_url`. El folio fiscal es `uuid`.

### Conceptos e impuestos

Cada línea necesita un concepto del catálogo de la cuenta:

- `GET /api/v1/items?q=flete` — conceptos: `id`, `name`, `sku`, `price`, `product_key`, `unit_key` y sus impuestos y retenciones por omisión. Acepta `sku`, `archived`, `updated_since` y `deleted_since`.
- `GET /api/v1/taxes` — impuestos (`taxes`) y retenciones (`retentions`) del país de la cuenta: `id`, `name`, `percentage`, `sat_code`.

En la línea manda `item_sku` (o `item_id`). Si la línea es nueva y no traes `line_item_taxes_attributes` ni `line_item_retentions_attributes`, toma los impuestos y retenciones por omisión del concepto, igual que la web. Sin `description` o `price`, toma los del concepto. Un SKU que no existe responde 422.

### Crear factura (cuenta MX)

```json
{
  "invoice": {
    "contact_code": "ACME",
    "currency_code": "MXN",
    "description": "Servicios de flete",
    "cfdi_use_code": "G03",
    "payment_method_code": "01",
    "payment_type_code": "PUE",
    "line_items_attributes": [
      {
        "item_sku": "FLETE-MAR",
        "description": "Flete marítimo",
        "quantity": 1,
        "price": 15000,
        "line_item_taxes_attributes": [{ "account_contribution_id": 2 }]
      }
    ]
  }
}
```

Códigos alternativos: `cfdi_use_id`, `payment_method_id`, `payment_type_id`, `item_id`. `tag_list` acepta etiquetas del catálogo de la cuenta.

### Vincular líneas de factura ↔ centro de costos

1. `GET /invoices/:id/cost_center_link_options?operation_id=123` — operaciones candidatas, líneas de venta disponibles (`cost_centers`) y líneas de factura sin vincular.
2. `POST /invoices/:id/link_cost_centers` — el importe de la línea de factura debe coincidir con el **ingreso** de la línea del centro de costos (tolerancia $0.01).

```json
{
  "invoice_cost_center_link_form": {
    "operation_id": 789,
    "links": {
      "321": "654"
    }
  }
}
```

`links` mapea `line_item_id` → `cost_center_id`.

3. `DELETE /invoices/:id/line_items/:line_item_id/unlink_cost_center` — desvincular.

---

## Facturas de proveedor (Bill)

`contact_code` / `contact_id` es el **proveedor**. El API fuerza `kind: expense`. Sin CFDI ni validación XML por API.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/bills` | Listado paginado. Filtros `status`, `archived`, `updated_since`, `deleted_since` |
| GET | `/bills/:id` | Detalle con `line_items` y sus impuestos |
| POST | `/bills` | Crear. Las líneas aceptan `item_sku` igual que en facturas |
| PATCH | `/bills/:id` | Actualizar. Solo mientras la bill es editable (en revisión o abierta y sin sincronizar con Alegra); si no, 422 |
| DELETE | `/bills/:id` | Borrado lógico |
| POST | `/bills/:id/archive` · `/restore` | Archivar y restaurar |

Vinculación análoga a facturas de cliente, con `bill_cost_center_link_form`, endpoints `cost_center_link_options` / `link_cost_centers` / `unlink_cost_center`, y comparación contra el **gasto** (`expense_amount`) de la línea del centro de costos.

---

## Generar borrador desde el centro de costos

Desde una operación, puedes crear un documento a partir de líneas seleccionadas (equivalente al botón «Generar factura» en la web). **La API persiste el borrador de inmediato** (a diferencia de la web, que solo abre el formulario de revisión).

### Generar factura de cliente

```
POST /api/v1/operations/:id/generate_invoice
```

```json
{
  "cost_center_ids": [654, 655],
  "cfdi_use_code": "G03",
  "payment_method_code": "01",
  "payment_type_code": "PUE"
}
```

Respuesta **201** con resumen de la factura en borrador (`status: drafted`).

### Generar factura de proveedor

```
POST /api/v1/operations/:id/generate_bill
```

```json
{
  "cost_center_ids": [654]
}
```

Las bills creadas por API suelen quedar en estado `opened` tras el guardado (regla de negocio del modelo Bill).
