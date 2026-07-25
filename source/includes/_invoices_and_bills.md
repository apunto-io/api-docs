# Facturas y facturas de proveedor

## Facturas de cliente (Invoice)

Captura básica para integraciones. **No incluye timbrado CFDI** por API; en cuentas mexicanas la creación exige campos CFDI para dejar el borrador listo para timbrar desde la web.

### Endpoints principales

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/invoices` | Listado |
| GET | `/invoices/:id` | Detalle (incluye `line_items`, CFDI, totales) |
| POST | `/invoices` | Crear con `line_items_attributes` |
| PATCH | `/invoices/:id` | Actualizar |
| DELETE | `/invoices/:id` | Eliminar (libera vínculos del centro de costos) |
| POST | `/invoices/:id/update_documents` | PDF/XML externos |

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
        "item_id": 456,
        "description": "Flete marítimo",
        "quantity": 1,
        "price": 15000
      }
    ]
  }
}
```

Códigos alternativos: `cfdi_use_id`, `payment_method_id`, `payment_type_id`.

### Vincular líneas de factura ↔ centro de costos

1. `GET /invoices/:id/service_pricing_link_options?operation_id=123` — operaciones candidatas, líneas de venta disponibles y líneas de factura sin vincular.
2. `POST /invoices/:id/link_service_pricings` — el importe de la línea de factura debe coincidir con el **ingreso** de la línea del centro de costos (tolerancia $0.01).

```json
{
  "invoice_service_pricing_link_form": {
    "operation_id": 789,
    "links": {
      "321": "654"
    }
  }
}
```

`links` mapea `line_item_id` → `service_pricing_id`.

3. `DELETE /invoices/:id/line_items/:line_item_id/unlink_service_pricing` — desvincular.

---

## Facturas de proveedor (Bill)

`contact_code` / `contact_id` es el **proveedor**. El API fuerza `kind: expense`. Sin CFDI ni validación XML por API.

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/bills` | Listado paginado |
| GET | `/bills/:id` | Detalle con `line_items` |
| POST | `/bills` | Crear |
| PATCH | `/bills/:id` | Actualizar |
| DELETE | `/bills/:id` | Eliminar |

Vinculación análoga a facturas de cliente, con `bill_service_pricing_link_form` y comparación contra el **gasto** (`expense_amount`) de la línea del centro de costos.

---

## Generar borrador desde el centro de costos

Desde una operación, puedes crear un documento a partir de líneas seleccionadas (equivalente al botón «Generar factura» en la web). **La API persiste el borrador de inmediato** (a diferencia de la web, que solo abre el formulario de revisión).

### Generar factura de cliente

```
POST /api/v1/operations/:id/generate_invoice
```

```json
{
  "service_pricing_ids": [654, 655],
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
  "service_pricing_ids": [654]
}
```

Las bills creadas por API suelen quedar en estado `opened` tras el guardado (regla de negocio del modelo Bill).
