# Sincronización incremental

Para mantener otro sistema al día no recorras toda la cuenta en cada corrida. Pide solo lo que **cambió** y lo que **se eliminó** desde la última vez. Los listados que lo soportan aceptan dos parámetros: <span class="new">nuevo</span>

Parámetro | Tipo | Qué devuelve
--------- | ---- | ------------
`updated_since` | datetime | Registros vivos con `updated_at` igual o posterior a ese instante, **incluidos los archivados**. Orden: `updated_at` ascendente y luego `id`.
`deleted_since` | datetime | Registros **eliminados** desde ese instante, como lápidas. Orden: `deleted_at` ascendente y luego `id`.

Los dos se combinan con `page` y `per_page` (ver [Paginación](#paginacion)) y con los filtros del listado. Usa ISO 8601 con offset o `Z`: `2026-11-11T18:00:00Z`. Una fecha inválida responde **422** `invalid_parameter`.

> Cambios desde la última corrida

```shell
curl "https://control.apunto.io/api/v1/contacts?updated_since=2026-11-11T18:00:00Z&per_page=100" \
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
      "archived": false,
      "archived_at": null,
      "updated_at": "2026-11-11T12:04:51.220-06:00"
    }
  ],
  "pagination": { "page": 1, "per_page": 100, "total": 1 }
}
```

> Eliminados desde la última corrida

```shell
curl "https://control.apunto.io/api/v1/contacts?deleted_since=2026-11-11T18:00:00Z" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "contacts": [
    {
      "id": 790,
      "deleted": true,
      "deleted_at": "2026-11-11T13:30:02.118-06:00",
      "updated_at": "2026-11-11T13:30:02.118-06:00",
      "alias": "OLDCO"
    }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

## Recursos que lo soportan

Recurso | Listado | Código en la lápida
------- | ------- | -------------------
Contactos | `GET /contacts` | `alias`
Prospectos | `GET /leads` | `alias`
Oportunidades | `GET /opportunities` | `identification`
Solicitudes comerciales | `GET /quote_requests` | `identification`
Cotizaciones | `GET /quotes` | `identification`
Folios operativos | `GET /operations` | `identification`
Servicios | `GET /services` | `identification`
Centro de costos | `GET /services/:id/cost_centers`, `GET /operations/:id/cost_centers` | solo `id`
Comentarios | `GET /operations/:id/messages`, `GET /services/:id/messages` | solo `id`
Tareas | `GET /operations/:id/to_dos`, `GET /services/:id/to_dos` | solo `id`
Facturas | `GET /invoices` | `identification`
Facturas de proveedor | `GET /bills` | `identification`
Direcciones | `GET /addresses`, `GET /contacts/:id/addresses` | `alias`
Conceptos | `GET /items` | `sku`

## Qué cuenta como cambio

- Crear, editar, archivar o restaurar un registro actualiza su `updated_at`. Por eso `updated_since` incluye los archivados: archivar es un cambio. Revisa `archived` en cada registro para saber si sigue activo. Si mandas `archived` explícitamente, se respeta ese filtro.
- Un cambio en una línea de centro de costos, un comentario o una tarea también actualiza el `updated_at` de su servicio o folio, y un cambio en un servicio actualiza el de su folio. Para sincronizar hijos, recorre los folios y servicios que cambiaron y pide sus hijos con el mismo `updated_since`.
- Vincular o desvincular una línea de factura o de factura de proveedor al centro de costos actualiza el `updated_at` del documento, porque cambia su `operation_ids`. <span class="new">nuevo</span>
- Las eliminaciones no aparecen en `updated_since`: pídelas con `deleted_since`. Las lápidas se conservan, así que puedes pedirlas aunque tu última corrida haya sido hace semanas.

### Datos relacionados

<span class="new">nuevo</span> Si un dato que ves dentro de un registro cambia, ese registro aparece en `updated_since`, aunque el dato viva en otra tabla:

Recurso | También cambia su `updated_at` cuando…
------- | --------------------------------------
Contactos | Cambia su domicilio fiscal, un correo o un teléfono. Al fusionar dos fichas, la ficha que queda.
Folios operativos | Cambia uno de sus servicios o de sus centros de costo, incluido desligarlo o liberarlo de una factura o factura de proveedor; cambian las fechas ETA/ETD o la guía aérea (MAWB/HAWB) de un servicio; cambia un comentario, una tarea o un archivo.
Servicios | Cambia el folio que traen en `operation` (`identification`, `kind`, `client_ref`).
Centro de costos | Su servicio pasa a otro folio (`operation_id`).
Facturas, facturas de proveedor y cotizaciones | Se agrega, cambia o elimina una línea, aunque el total no cambie; cambian sus totales; un servicio ligado pasa a otro folio (`operation_ids`).
Conceptos | Cambian sus impuestos o retenciones.
Solicitudes comerciales | Se liga, desliga, elimina o restaura una cotización (`quote_ids`, `quotes_count`), o cambian sus precios.
Oportunidades | Se crea, se mueve a otra oportunidad, se elimina o se restaura una de sus solicitudes (`quote_requests_count`).

Lo que **no** cambia el `updated_at` de quien lo muestra:

- Los datos de **otro recurso** que un registro solo muestra por referencia: el nombre del contacto en un folio, el vendedor, la moneda, el proveedor de un servicio. Cuando cambian, cambia ese otro recurso. Sincronízalo por su cuenta y relaciona por `id`.
- Renombrar o eliminar una etiqueta en Configuración. Los registros etiquetados no se actualizan.
- Un prospecto que se convierte en cliente sale de `GET /leads` sin lápida y aparece en `GET /contacts` con el mismo `id`, dentro de `updated_since`.

## Receta recomendada

1. Guarda por recurso la marca `last_sync` de la última corrida exitosa. La primera vez, haz una carga completa sin `updated_since`.
2. Antes de pedir datos, toma `now` (hora del servidor o UTC).
3. Pide `updated_since = last_sync − 5 minutos` y recorre todas las páginas. Haz **upsert** por `id` (o por el código). El solapamiento de 5 minutos cubre registros que se guardaron mientras corría la sincronización anterior; como el upsert es idempotente, recibir un registro dos veces no hace daño.
4. Pide `deleted_since = last_sync − 5 minutos` y elimina o marca esos `id` en tu sistema.
5. Si todo salió bien, guarda `last_sync = now`. Si algo falló, no la muevas: la siguiente corrida repite la ventana.

> Sincronizar un recurso

```javascript
async function syncResource(path, lastSync) {
  const now = new Date().toISOString();
  const since = new Date(new Date(lastSync).getTime() - 5 * 60_000).toISOString();

  for await (const row of listAll(path, { updated_since: since })) {
    await upsert(path, row); // tu lógica, idempotente por id
  }
  for await (const row of listAll(path, { deleted_since: since })) {
    await remove(path, row.id);
  }
  return now; // guárdalo como el nuevo lastSync
}
```

```python
from datetime import datetime, timedelta, timezone

def sync_resource(path, last_sync):
    now = datetime.now(timezone.utc)
    since = (last_sync - timedelta(minutes=5)).isoformat()

    for row in list_all(path, updated_since=since):
        upsert(path, row)          # tu lógica, idempotente por id
    for row in list_all(path, deleted_since=since):
        remove(path, row["id"])
    return now                     # guárdalo como el nuevo last_sync
```

`listAll` y `list_all` son los helpers de [Paginación](#recorrer-todas-las-paginas).

<aside class="success">Corre la sincronización cada 5 a 15 minutos. Con <code>per_page=100</code> y los <a href="#limites-de-uso">límites de uso</a> actuales hay margen de sobra para cuentas grandes.</aside>

<aside class="warning">No uses el reloj de tu servidor como <code>since</code> sin solapamiento. Un registro que se guarda en el mismo segundo en que corre tu consulta puede quedar fuera para siempre.</aside>
