# Historial de cambios

Cambios de la API v1 que afectan a las integraciones, del más reciente al más antiguo. Los marcados como **cambio incompatible** pueden requerir ajustes en tu código.

## Noviembre 2026

Versión endurecida de la API para integraciones (ERP, Aspel y sistemas contables), con sincronización incremental y un contrato consistente en todos los recursos.

### Nuevo

- **Sincronización incremental** con `updated_since` y `deleted_since` en todos los listados principales. Ver [Sincronización incremental](#sincronizacion-incremental).
- `GET /api/v1/me` responde el usuario del token y la cuenta activa; `GET /api/v1/accounts` lista sus cuentas con `current_account_id`.
- Catálogos para dar de alta sin adivinar ids: `GET /api/v1/boards` (tableros y columnas de servicio), `GET /api/v1/items` y `GET /api/v1/items/:id` (conceptos), `GET /api/v1/taxes`, `GET /api/v1/quotation_pipelines`, `GET /api/v1/quote_won_reasons`, `GET /api/v1/quote_lost_reasons`. Ver [Catálogos](#catalogos).
- `GET /api/v1/contacts/search` y `GET /api/v1/addresses/search` para autocompletar.
- Paginación (`page`, `per_page`, `pagination.total`) en todos los listados. Ver [Paginación](#paginacion).
- `request_id` en todos los errores y en el header `X-Request-Id`.
- Límite de **300 peticiones por minuto por token** con respuesta 429 y `Retry-After`. Ver [Límites de uso](#limites-de-uso).
- Precios de solicitudes comerciales con moneda y proveedor por línea (`supplier_code`, `currency_code`).

### Cambios incompatibles

- **Formato de error único.** `error` ahora es siempre un **código** (`not_found`, `forbidden`, `validation_failed`, …) y el texto está en `message`. Antes algunos endpoints mandaban el texto en `error`. Si mostrabas `error` al usuario, muestra `message`. Ver [Errores](#errores).
- **JSON mal formado** responde 400 `invalid_json` (antes 500).
- **Permisos.** La API aplica los mismos permisos por módulo y la misma visibilidad por registro que la plataforma. Un usuario sin permiso recibe 403, y un registro que no puede ver, 404. Ver [Permisos y alcance](#permisos-y-alcance).
- **Tokens vencidos** responden 401.
- **Referencias de otra cuenta** (`contact_id`, `operation_id`, usuarios, …) responden 422 en lugar de guardarse.
- **Campos de solo lectura.** Mandar `status` o totales calculados responde 422 `read_only_fields` en lugar de ignorarse. El estado cambia con su acción (`close`, `cancel`, `transition`, …).
- **Etiquetas.** `tag_list` solo acepta etiquetas que ya existen en el catálogo de la cuenta.
- **Facturas paginadas.** `GET /api/v1/invoices` ya no devuelve un arreglo plano con todas las facturas: responde `{ "invoices": [...], "pagination": {...} }` con 25 por página (máximo 100).
- **Facturas timbradas.** Una factura o factura de proveedor que ya no es editable en la plataforma tampoco se edita por API (422).
- **Reabrir una solicitud comercial** que ya generó un folio operativo responde 422.
- **Direcciones del contacto.** `contacts/:contact_id/addresses` maneja solo el domicilio fiscal del contacto. Las direcciones de operación (origen, destino, aduana) están en `/api/v1/addresses`. Ver [Direcciones](#direcciones).
- **Precios de solicitudes comerciales.** La moneda ya no va en el precio sino en cada proveedor de línea.

### Eliminado

- `POST /api/v1/users`. Los usuarios entran a la cuenta por invitación desde la plataforma.
- `contacts/:id/messages` y `contacts/:id/to_dos`. Los [comentarios](#comentarios) y las [tareas](#tareas) viven en folios y servicios.

## Octubre 2026

- **Archivar, restaurar y eliminar** con la decisión del ciclo de vida (`outcome`, `code`, `suggested_action`) en todos los recursos principales. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
- Ciclo comercial documentado: prospectos, oportunidades, solicitudes comerciales y cotizaciones.

## Julio 2026

- Centro de costos (`cost_centers`) por servicio y agregado por folio. Reemplaza a `service_pricings`.
