# Centro de costos (CostCenter)

Las líneas del **centro de costos** registran **ingresos** y **gastos** por servicio. En el API se identifican como **CostCenter** (respuestas y rutas). Internamente Apunto las persiste como registros de ingreso/gasto por servicio.

Cada línea puede vincularse opcionalmente a cotización, factura de cliente o factura de proveedor.

## Objeto CostCenter

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | Identificador único |
| concept | string | Concepto / descripción |
| quantity | decimal | Cantidad |
| income_amount | decimal | Ingreso (subtotal de venta) |
| expense_amount | decimal | Gasto (subtotal de costo) |
| profit_amount | decimal | Utilidad (calculada) |
| profit_percentage | decimal | Margen % (calculado) |
| currency | object | Moneda del ingreso |
| expense_currency | object | Moneda del gasto |
| exchange_rate | decimal | Tipo de cambio ingreso |
| expense_exchange_rate | decimal | Tipo de cambio gasto |
| supplier | object | Proveedor del gasto |
| item | object | Producto/servicio SAT (opcional) |
| service | object | Servicio padre (en listados agregados) |
| linked | object | `quote_line_item_id`, `invoice_line_item_id`, `bill_line_item_id` |
| notes | string | Notas (detalle) |
| created_at / updated_at | datetime | Auditoría |

Listados devuelven `{ "cost_centers": [...], "pagination": {...} }`. Show/create/update devuelven `{ "cost_center": { ... } }`.

## Listar líneas de un servicio <span class="badge badge-success">GET</span>

```
GET /api/v1/services/:service_id/cost_centers
```

Parámetros de consulta: `page`, `per_page` (máx. 100).

## Listar líneas de una operación (agregado) <span class="badge badge-success">GET</span>

```
GET /api/v1/operations/:operation_id/cost_centers
```

Solo lectura: incluye todas las líneas de los servicios de la operación.

## Crear línea <span class="badge badge-warning">POST</span>

```
POST /api/v1/services/:service_id/cost_centers
```

```json
{
  "cost_center": {
    "concept": "Flete marítimo",
    "supplier_code": "MAERSK",
    "currency_code": "MXN",
    "income_amount": 15000,
    "expense_amount": 9000,
    "quantity": 1
  }
}
```

También puedes usar `supplier_id`, `currency_id`, `expense_currency_code`, `item_id`, `income_unit_price`, `expense_unit_price`, `notes`.

## Ver / actualizar / eliminar

```
GET    /api/v1/services/:service_id/cost_centers/:id
PATCH  /api/v1/services/:service_id/cost_centers/:id
DELETE /api/v1/services/:service_id/cost_centers/:id
```

`DELETE` es eliminación lógica (soft-delete).

<aside class="notice">
Por compatibilidad transitoria, algunos cuerpos legacy (<code>service_pricing</code>, <code>service_pricing_ids</code>) siguen aceptándose en peticiones; las respuestas usan siempre <code>cost_center</code> / <code>cost_centers</code>.
</aside>
