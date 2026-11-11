# Flujos completos

Recetas paso a paso para los casos más comunes. Cada paso enlaza al endpoint con todos sus parámetros; aquí solo va lo indispensable.

## Del prospecto a la factura

El ciclo completo, igual que en la plataforma: negocio, solicitud, precios, cotización, folio, servicios, centro de costos y factura.

Paso | Endpoint | Qué guardar
---- | -------- | -----------
1. Oportunidad del cliente | [`POST /opportunities`](#crear-una-oportunidad) | `identification`
2. Solicitud comercial | [`POST /quote_requests`](#crear-una-solicitud-comercial) | `id` de la solicitud
3. Precios de proveedores | [`POST /quote_requests/:id/quote_request_pricings`](#agregar-un-precio-a-una-solicitud) | —
4. Cotización | [`POST /quote_requests/:id/create_quote`](#generar-la-cotizacion-de-una-solicitud) | `quote.id`
5. Ajustar y aprobar | [`PATCH /quotes/:id`](#actualizar-una-cotizacion), [`POST /quotes/:id/open`](#aprobar-una-cotizacion) | —
6. Ganar la solicitud | [`POST /quote_requests/:id/mark_as_won`](#marcar-una-solicitud-como-ganada) | —
7. Folio operativo | [`POST /quotes/:id/create_operation`](#crear-un-folio-desde-una-cotizacion) | `operation.id`
8. Servicios del folio | [`POST /services`](#crear-un-servicio) | `service.id`
9. Ingresos y gastos | [`POST /services/:id/cost_centers`](#crear-una-linea-de-centro-de-costos) | `cost_center.id`
10. Facturas | [`POST /operations/:id/generate_invoice`](#generar-una-factura-desde-un-folio-operativo), [`generate_bill`](#generar-una-factura-de-proveedor-desde-un-folio-operativo) | `invoice.id`, `bill.id`

Antes de empezar, consulta una vez los catálogos que vas a usar: la columna del pipeline para `list_id` ([`GET /quotation_pipelines`](#pipelines-de-cotizacion)), el tablero del servicio para `board_id` ([`GET /boards`](#tableros-de-servicio)) y los conceptos para `item_id` ([`GET /items`](#catalogo-de-conceptos)).

> 1–2. Oportunidad y solicitud

```shell
curl -X POST https://control.apunto.io/api/v1/opportunities \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "opportunity": { "title": "Importación autopartes Q4", "contact_code": "ACME" } }'

curl -X POST https://control.apunto.io/api/v1/quote_requests \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quote_request": {
      "list_id": 610,
      "contact_code": "ACME",
      "opportunity_identification": "OP-000045",
      "origin": "Shanghai, China",
      "destination": "Manzanillo, Colima",
      "operation_kind": "importation",
      "operation_mode": "maritime"
    }
  }'
```

> 4–7. Cotización, resultado y folio

```shell
curl -X POST https://control.apunto.io/api/v1/quote_requests/457/create_quote \
  -H "Authorization: Bearer $APUNTO_TOKEN"

curl -X POST https://control.apunto.io/api/v1/quotes/905/open \
  -H "Authorization: Bearer $APUNTO_TOKEN"

curl -X POST https://control.apunto.io/api/v1/quote_requests/457/mark_as_won \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "won_at": "2026-11-11", "quote_won_reason_id": 8 }'

curl -X POST https://control.apunto.io/api/v1/quotes/905/create_operation \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "operation_type": "new" }'
```

> 8–10. Servicio, centro de costos y factura

```shell
curl -X POST https://control.apunto.io/api/v1/services \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "service": { "operation_id": 1042, "board_id": 31, "supplier_code": "NAVPAC" } }'

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
      "income_unit_price": 2000,
      "expense_currency_code": "USD",
      "expense_unit_price": 1500
    }
  }'

curl -X POST https://control.apunto.io/api/v1/operations/1042/generate_invoice \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "cost_center_ids": [5501], "cfdi_use_code": "G03", "payment_method_code": "03", "payment_type_code": "PUE" }'
```

<aside class="notice">Un prospecto se puede cotizar, pero para abrir un folio el contacto tiene que ser cliente. Si tu negocio empieza con un <a href="#prospectos">prospecto</a>, conviértelo en cliente en la plataforma antes del paso 7.</aside>

<aside class="warning">La factura que genera la API queda como borrador: la API no timbra. Revisa y timbra en la plataforma. Ver <a href="#facturas">Facturas</a>.</aside>

## Abrir un folio desde tu sistema

Cuando la orden nace en tu ERP o portal y no necesitas el ciclo comercial.

1. **Asegura el cliente.** Busca por alias con [`GET /contacts/search?q=ACME`](#buscar-contactos) y compara `alias` exacto. Si no existe, créalo con [`POST /contacts`](#crear-un-contacto) usando como `alias` la clave del cliente en tu sistema.
2. **Crea el folio** con [`POST /operations`](#crear-un-folio-operativo), usando `contact_code` y `client_ref` con tu número de orden. Guarda `id` e `identification`.
3. **Agrega los servicios** con [`POST /services`](#crear-un-servicio) (`operation_id` y `board_id`).
4. **Captura ingresos y gastos** de cada servicio con [`POST /services/:id/cost_centers`](#crear-una-linea-de-centro-de-costos).
5. **Sube documentos** (BL, factura comercial, pedimento) con [`POST /attachments`](#documentos-y-archivos).
6. **Actualiza fechas e hitos** con [`PATCH /services/:id`](#actualizar-un-servicio) cuando cambien en tu sistema.

<aside class="success">Usa <code>client_ref</code> como llave de idempotencia. Si un alta falla por timeout, busca el folio por esa referencia con <a href="#buscar-folios-operativos"><code>GET /operations/search</code></a> antes de reintentar, para no duplicarlo.</aside>

> Folio desde una orden

```javascript
async function openOperation(order) {
  const found = await api(`/operations/search?q=${encodeURIComponent(order.number)}`);
  const existing = found.body.operations.find((op) => op.client_ref === order.number);
  if (existing) return existing;

  const { status, body } = await api("/operations", {
    method: "POST",
    body: JSON.stringify({
      operation: {
        contact_code: order.customerCode,
        currency_code: order.currency,
        kind: "importation",
        mode: "maritime",
        client_ref: order.number,
      },
    }),
  });
  if (status !== 201) throw new Error(body.errors?.join(", ") ?? body.message);
  return body.operation;
}
```

## Sincronizar clientes y proveedores con tu ERP

Mantén el catálogo de contactos igual en los dos sistemas.

**De Apunto a tu ERP**, cada 5 a 15 minutos:

1. `GET /contacts?updated_since=<última corrida − 5 min>&per_page=100`, todas las páginas. Haz upsert por `alias`. Si `archived` es `true`, desactívalo en tu ERP.
2. `GET /contacts?deleted_since=<misma marca>`. Elimina o desactiva esos `alias`.

**De tu ERP a Apunto**, cuando cambia un cliente:

1. Busca por alias. Si existe, [`PATCH /contacts/:id`](#actualizar-un-contacto) solo con los campos que cambiaron; si no, [`POST /contacts`](#crear-un-contacto).
2. Para el domicilio fiscal usa [`contacts/:contact_id/addresses`](#domicilio-fiscal-de-un-contacto).

El patrón completo de ventana y solapamiento está en [Sincronización incremental](#receta-recomendada).

<aside class="warning">Si los dos sistemas pueden editar el mismo contacto, define cuál manda en cada campo (por ejemplo, datos fiscales desde el ERP y vendedor desde Apunto). Sin esa regla, cada sincronización puede deshacer los cambios de la otra.</aside>

## Exportar facturas a tu contabilidad

1. Pide [`GET /invoices?updated_since=<marca>&per_page=100`](#listar-facturas) y, para gastos, [`GET /bills?updated_since=<marca>`](#listar-facturas-de-proveedor).
2. Filtra por estado: solo las timbradas tienen `uuid` y valor fiscal. Ver [Estados de una factura](#estados-de-una-factura).
3. Usa `uuid` como llave única en tu contabilidad, y `identification` como referencia legible.
4. Pide también `deleted_since` y revisa las canceladas para revertir sus pólizas.

> Facturas que cambiaron

```shell
curl "https://control.apunto.io/api/v1/invoices?updated_since=2026-11-11T18:00:00Z&per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

## Publicar comentarios y tareas desde otro sistema

Útil para bots, correo entrante o tickets de soporte.

- **Comentario** en el folio: [`POST /operations/:id/messages`](#comentarios). Quedan a nombre del usuario del token, así que usa un usuario dedicado con un nombre claro («Bot de correo»).
- **Tarea** para el equipo: [`POST /operations/:id/to_dos`](#tareas), y [`POST .../to_dos/:id/complete`](#tareas) cuando se resuelva en tu sistema.
- **Archivo** recibido por correo: [`POST /attachments`](#documentos-y-archivos) con la carpeta del folio.
