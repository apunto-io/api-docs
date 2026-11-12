# Historial de cambios

Cambios de la API v1 que afectan a las integraciones, del más reciente al más antiguo. Los marcados como **cambio incompatible** pueden requerir ajustes en tu código.

## Noviembre 2026

Versión endurecida de la API para integraciones (ERP y sistemas contables), con sincronización incremental y un contrato consistente en todos los recursos.

### Nuevo

- **Sincronización incremental** con `updated_since` y `deleted_since` en todos los listados principales. Ver [Sincronización incremental](#sincronizacion-incremental).
- `GET /api/v1/me` responde el usuario del token y la cuenta activa; `GET /api/v1/accounts` lista sus cuentas con `current_account_id`.
- Catálogos para dar de alta sin adivinar ids: `GET /api/v1/boards` (tableros y columnas de servicio), `GET /api/v1/items` y `GET /api/v1/items/:id` (conceptos), `GET /api/v1/taxes`, `GET /api/v1/quotation_pipelines`, `GET /api/v1/quote_won_reasons`, `GET /api/v1/quote_lost_reasons`. Ver [Catálogos](#catalogos).
- `GET /api/v1/contacts/search` y `GET /api/v1/addresses/search` para autocompletar.
- Paginación (`page`, `per_page`, `pagination.total`) en todos los listados. Ver [Paginación](#paginacion).
- `request_id` en todos los errores y en el header `X-Request-Id`.
- Límite de **300 peticiones por minuto por token** con respuesta 429 y `Retry-After`. Ver [Límites de uso](#limites-de-uso).
- Precios de solicitudes comerciales con moneda y proveedor por línea (`supplier_code`, `currency_code`).
- Los servicios devuelven su tablero y columna (`board`, `list`).
- Las líneas de centro de costos toman la moneda del folio cuando no mandas moneda, igual que la plataforma.
- Los contactos devuelven `trade_identification`, y las direcciones aceptan y devuelven `aeat_city_code`.
- Búsqueda de alias de direcciones y de `sku` de conceptos sin distinguir mayúsculas.
- Las facturas devuelven `operation_kind`, `operation_mode` y `tags`.
- Eliminar un archivo lo manda a la papelera de la plataforma (30 días para restaurarlo) en lugar de borrarlo para siempre.
- Las cotizaciones devuelven sus partidas (`line_items`) y aceptan `line_items_attributes` para crear, cambiar o quitar partidas.
- Las solicitudes comerciales devuelven `deal_currency`, `volumetric_factor_code`, puertos, rutas, `result_at`, `result_notes`, motivos y `quote_ids`; los prospectos, `trade_identification` y `nationality`; las oportunidades, `archived` y `archived_at`.
- Las sugerencias del tarifario filtran por `supplier_id`.

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
- **Importes y utilidad** del centro de costos y de los totales del folio requieren `operations_profit_read`: sin ese permiso vienen en `null` y escribirlos responde 403.
- **Generar facturas desde un folio** (`generate_invoice`, `generate_bill`) solo acepta líneas de ese folio, con concepto y sin factura vigente; si no, 422. Antes podía duplicar facturas.
- **Eliminar una línea de centro de costos** responde la decisión del ciclo de vida (`outcome`) en lugar de `{ "message": ... }`, y se rechaza si la línea ya está en un documento.
- **Campos calculados de las líneas** (`profit_amount`, `profit_percentage`) responden 422 `read_only_fields` en lugar de ignorarse.
- **`kind` de contactos** solo acepta `client` y `supplier`; los prospectos se crean con `quick_create` o en `/leads`.
- **Claves del SAT** (`payment_method_code`, `payment_type_code`, `cfdi_use_code`) se buscan en el país de la cuenta, los ids crudos de catálogos fiscales se validan y `errors` lista todos los códigos inválidos, no solo el primero.
- **Domicilio fiscal solo en su ruta.** `/addresses` ya no lista, muestra ni modifica domicilios fiscales de contactos (404) y rechaza `addressable_type`/`addressable_id` (422). Usa `contacts/:contact_id/addresses`, que pide `contacts_read` para leer y `contacts_edit` para escribir.
- **Alias de direcciones** únicos por cuenta sin distinguir mayúsculas.
- **Motivos de ganada y pérdida** de otra cuenta, archivados o inexistentes responden 422 en lugar de ignorarse.
- **Facturas y facturas de proveedor:** `status`, `uuid`, `stamped_at` y los totales responden 422 `read_only_fields`; `update_documents` solo funciona en borrador; ligar líneas de centro de costos de otra cuenta, repetidas o ya en otra factura de proveedor responde 422. Los bloqueos de estado al vincular responden 422 (403 queda solo para permisos). La entrada documentada es `link_cost_center_id`.
- **Tareas:** `completed` y `completed_at` responden 422 (usa `POST .../complete`); fechas inválidas y valores inválidos del filtro `completed` responden 422.
- **Carpetas y archivos:** un `parent_id` inexistente, ajeno o borrado responde 422, y `file` debe ir como `multipart/form-data` (422 si llega como texto).
- **Generar la cotización de una solicitud** (`create_quote`) corre completo o no hace nada, ignora precios en borrador y arma una partida por línea de precio con el costo del proveedor y la venta en 0, como la plataforma. Fija la venta con `PATCH /quotes/:id`.
- **Estados comerciales:** `status` de oportunidades y `lead_status`/`status` de prospectos responden 422 en PATCH (usa `transition`); al crear, una oportunidad no puede nacer `won`/`lost` y una solicitud solo puede nacer en `start` o `requested`.
- **Cotizaciones:** el PATCH respeta si la cotización es editable (422 si no); clonar ya no copia archivado, resultado ni timbrado; `create_operation` con `existing` responde 422 si no pudo agregar las partidas, sin dejar nada ligado.
- **Prospectos:** `kind` distinto de `prospect` responde 422; la conversión a cliente se hace en la plataforma.
- **Fechas de resultado** (`won_at`, `lost_at`) ilegibles y `pricing_catalog_id` de otra cuenta responden 422.
- **Filtro `result=pending`** de solicitudes incluye las que aún no tienen resultado.
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
