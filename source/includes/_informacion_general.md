# Información general

La **API de Apunto** es el canal programático hacia tu cuenta en [Apunto](https://apunto.io): la plataforma donde tu equipo de freight forwarding gestiona operaciones, servicios, contactos, documentos y la economía de cada embarque (centro de costos, facturas y gastos).

Con la API puedes leer y actualizar la misma información que ves en la aplicación web, conectar sistemas externos y automatizar flujos sin depender de captura manual.

## Qué es Apunto (contexto del sistema)

Apunto está pensado para **forwarders y operadores logísticos** que coordinan importaciones, exportaciones y movimientos domésticos. En la plataforma web el trabajo se organiza así:

1. **Cuenta (account)** — Es tu organización. Todos los datos de la API pertenecen a la cuenta asociada al usuario del token; no hay acceso cruzado entre cuentas.
2. **Operación** — El expediente del embarque o proyecto logístico (cliente, moneda, agente operativo, estado, márgenes).
3. **Servicio** — Cada tramo o actividad dentro de la operación (marítimo, aéreo, terrestre, aduanas, etc.).
4. **Centro de costos (`CostCenter`)** — Líneas de ingreso y gasto ligadas a un servicio; son la base para rentabilidad y para facturar o registrar compras.
5. **Contactos y direcciones** — Catálogo de clientes, proveedores, carriers y ubicaciones (puertos, plantas, domicilios fiscales).
6. **Ciclo comercial** — Prospecto, oportunidad, solicitud comercial y cotización. La cotización abierta se convierte en operación.
7. **Documentos comerciales** — Facturas de cliente (`Invoice`) y facturas o gastos de proveedor (`Bill`), con opción de vincular líneas al centro de costos o generar borradores desde una operación.
8. **Colaboración** — Comentarios (`messages`), tareas (`to_dos`) y carpetas de archivos en operaciones y servicios.

La API refleja ese mismo modelo. El ciclo comercial va de [prospecto](#prospectos) a [oportunidad](#oportunidades), [solicitud](#solicitudes-comerciales) y [cotización](#cotizaciones). En la operación navegas **operación → servicios → centro de costos**, y usas contactos y direcciones como catálogos de referencia.

```
Cuenta (tenant)
├── Prospectos
├── Oportunidades
│   └── Solicitudes comerciales
│       ├── Columnas del flujo (list_id)
│       ├── Motivos de ganado y perdido
│       ├── Precios
│       └── Cotizaciones → Operaciones
├── Operaciones
│   ├── Servicios
│   │   └── Centros de costo (líneas ingreso/gasto)
│   ├── Comentarios, tareas, carpetas de archivos
│   └── Agregado de centros de costo (solo lectura)
├── Contactos (+ domicilio fiscal en /contacts/:id/addresses)
├── Direcciones (nivel cuenta)
├── Facturas y bills
├── Catálogos: tableros de servicios, conceptos, impuestos, motivos
└── Adjuntos (p. ej. extensión Chrome)
```

## Qué puedes construir con la API

Algunos ejemplos habituales de integración:

- **Sincronizar operaciones** con un ERP, WMS o portal del cliente (estado, referencias, fechas clave).
- **Crear o actualizar servicios** cuando un carrier, aduana o sistema de tracking confirme un hito.
- **Registrar ingresos y gastos** en el centro de costos desde herramientas de compras o conciliación.
- **Generar borradores de factura o bill** a partir de líneas de centro de costos ya capturadas en la operación.
- **Llevar el ciclo comercial** desde un prospecto hasta la cotización abierta y la operación.
- **Mantener contactos y direcciones** alineados con tu CRM o directorio maestro.
- **Publicar comentarios o tareas** desde bots, correo o tickets internos.
- **Subir documentos** (BL, pedimentos, POD) a la carpeta correcta de una operación o servicio.

## Principios REST y formato de datos

La API sigue **REST**: recursos con URLs predecibles y verbos HTTP estándar.

| Método | Uso típico |
|--------|------------|
| `GET` | Leer uno o listar (con paginación) |
| `POST` | Crear |
| `PUT` / `PATCH` | Actualizar |
| `DELETE` | Eliminar (borrado lógico, cuando el registro lo permite; si no, responde 422 y sugiere archivar) |

El cuerpo de las peticiones y **todas las respuestas** usan **JSON**. Envía `Content-Type: application/json` y `Accept: application/json` en operaciones con cuerpo o cuando quieras dejar explícito el formato esperado.

**URL base (producción):** `https://control.apunto.io/api/v1`

<aside class="notice">
Toda la comunicación con la API debe hacerse por <strong>HTTPS</strong>. No envíes tokens ni datos de embarque por HTTP sin cifrar.
</aside>

<aside class="notice">
En instalaciones con subdominio dedicado, la base es <code>https://nombre-empresa.apunto.io/api/v1</code>, donde <code>nombre-empresa</code> es el subdominio de tu organización.
</aside>

### Respuesta exitosa (HTTP 200)

Ejemplo simplificado de una operación (`GET /api/v1/operations/:id`):

```json
{
  "operation": {
    "id": 1042,
    "identification": "IMP-2024-0847",
    "kind": "importation",
    "mode": "maritime",
    "status": "active",
    "client_ref": "PO-7781",
    "contact": {
      "id": 88,
      "name": "Acme Logistics",
      "alias": "ACME"
    },
    "currency": {
      "id": 1,
      "name": "USD"
    },
    "profit_amount": "1250.00",
    "profit_percentage": "18.5",
    "services_count": 3,
    "created_at": "2024-03-15T10:30:00.000Z",
    "updated_at": "2024-03-20T14:22:00.000Z"
  }
}
```

Las creaciones exitosas suelen responder **201 Created** con el recurso en el cuerpo.

### Respuesta de error

Todos los errores responden JSON con el **código HTTP** correspondiente:

```json
{
  "error": "validation_failed",
  "message": "Moneda no puede estar en blanco",
  "errors": ["Moneda no puede estar en blanco"],
  "request_id": "0f055872-5929-4ab8-ab2c-128a6029f73b"
}
```

Consulta la sección [Errores](#errores) para el catálogo de códigos, límites y buenas prácticas de reintento.

## Alcance de la cuenta y permisos

- Cada **token de API** pertenece a un **usuario**. Las peticiones se ejecutan con sus permisos: rol, permisos por módulo y visibilidad de registros (todos, de su equipo o solo propios), igual que en la web.
- Los listados y búsquedas solo devuelven registros de la cuenta activa que el usuario puede ver. Un registro que no puede ver responde **404**; una acción que no tiene permitida responde **403**.
- Si el usuario pertenece a varias cuentas, elige una con `account_id` (ver [Autenticación](#autenticacion)).
- Un usuario **bloqueado** recibe **403** aunque el token siga siendo válido.
- Un id de otra cuenta (contacto, folio, lista, oportunidad, concepto o usuario) se rechaza con 422.
- Recomendación: crea un usuario dedicado para la integración, con solo los permisos que necesita.

## Identificadores: ID numérico y códigos (`*_code`)

En **lecturas** (`GET`) recibirás `id` numérico en JSON.

En **altas y cambios** (`POST` / `PATCH` / `PUT`) conviene usar **códigos legibles** que ya manejas en Apunto, por ejemplo:

| Parámetro | Resuelve |
|-----------|----------|
| `contact_code` | Alias del contacto (cliente/proveedor) |
| `supplier_code` | Alias del proveedor |
| `currency_code` | Moneda (`MXN`, `USD`, …) |
| `operational_agent_email` | Usuario agente operativo |
| `customs_address_code` | Alias de dirección aduanal |
| `contact_tax_regime_code` | Régimen fiscal SAT del contacto (`601`, `612`, …) |
| `cfdi_use_code`, `payment_method_code`, `payment_type_code` | Catálogos SAT (`G03`, `01`, `PUE`, …) |
| `item_sku` | Concepto (en líneas de factura y bill) |
| `board_id` / `list_id` | Tablero o columna de un servicio (ver `GET /api/v1/boards`) |

Así evitas hardcodear IDs internos entre entornos. Si un código no existe en la cuenta, la API responde **422** y nombra el campo; nunca guarda el registro sin ese dato.

## Paginación

Los listados están paginados. Por defecto **`page=1`** y **`per_page=25`** (máximo **100**).

`GET /api/v1/operations?page=2&per_page=50`

```json
{
  "operations": [],
  "pagination": {
    "page": 2,
    "per_page": 50,
    "total": 150
  }
}
```

`total` cuenta los registros que cumplen los filtros de la petición. Evita bucles que recorran “toda la cuenta” sin paginar; usa `total` y `page` hasta agotar resultados.

## Sincronización incremental (`updated_since` / `deleted_since`)

Todos los listados principales aceptan dos filtros para sincronizar solo lo que cambió:

Parámetro | Qué devuelve | Orden
--------- | ------------ | -----
`updated_since` | Registros vivos con `updated_at` igual o posterior a la fecha, **incluidos los archivados** (archivar es un cambio). Manda `archived=false` para excluirlos. | `updated_at` ascendente, luego `id`
`deleted_since` | Registros eliminados con `deleted_at` igual o posterior a la fecha: `id`, `deleted: true`, `deleted_at`, `updated_at` y el código del registro (`alias`, `identification` o `sku`). | `deleted_at` ascendente, luego `id`

**Formato de fecha:** ISO 8601. Recomendado en UTC con `Z`: `2026-11-11T18:00:00Z`. Una fecha sin zona se interpreta en hora de Ciudad de México. Una fecha inválida responde 422.

```shell
curl "https://control.apunto.io/api/v1/contacts?updated_since=2026-11-11T18:00:00Z&per_page=100" \
  -H "Authorization: Bearer TU_TOKEN_API"

curl "https://control.apunto.io/api/v1/contacts?deleted_since=2026-11-11T18:00:00Z" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```json
{
  "contacts": [
    { "id": 812, "deleted": true, "alias": "ACME", "deleted_at": "2026-11-11T12:40:03.112-06:00", "updated_at": "2026-11-11T12:40:03.112-06:00" }
  ],
  "pagination": { "page": 1, "per_page": 25, "total": 1 }
}
```

Listados con sincronización: contactos, prospectos, oportunidades, solicitudes comerciales, cotizaciones, folios, servicios, direcciones, facturas, bills, conceptos, centros de costos, comentarios y tareas.

**Cómo sincronizar sin perder cambios:**

1. Guarda como marca el instante en que **empiezas** cada corrida (no el último `updated_at` recibido).
2. En la siguiente corrida pide `updated_since` y `deleted_since` con la marca anterior **menos 15 minutos** y deduplica por `id`. Una transacción larga puede guardar un `updated_at` anterior a tu corte.
3. Recorre todas las páginas de cada filtro antes de mover la marca.
4. Un registro que aparece en `deleted_since` y después en `updated_since` fue restaurado: trátalo como vivo.

## Versionado

La versión actual es **`v1`** (prefijo `/api/v1/`). Dentro de una misma versión mayor intentamos no romper contratos existentes; cambios incompatibles implicarán una nueva versión (`v2`, etc.).

## Cómo empezar (checklist)

1. **Acceso** — Usuario activo en tu cuenta Apunto con permisos para los módulos que integrarás.
2. **Token** — En la web: **Configuración → Tokens de API** → crea un token y guárdalo de forma segura (solo se muestra al crearlo).
3. **Primera petición** — Prueba `GET /api/v1/me` con `Authorization: Bearer TU_TOKEN`: confirma el usuario y la cuenta.
4. **Explora recursos** — Lee una operación (`show`), luego sus servicios y centros de costo anidados o vía endpoints dedicados.
5. **Escrituras** — Empieza con contactos o comentarios de bajo riesgo antes de tocar facturación o centro de costos.
6. **Errores y límites** — Implementa logging del status HTTP y del cuerpo JSON; respeta paginación y reintentos prudentes en 5xx.

<aside class="warning">
Las peticiones con token de producción <strong>modifican datos reales</strong> de tu cuenta. Prueba primero en un entorno o cuenta de staging si tu organización lo tiene disponible.
</aside>

## Siguiente paso

Antes de implementar integraciones completas, revisa:

- [Autenticación](#autenticacion) — Bearer token y login alternativo (`POST /api/v1/auth`)
- [Operaciones](#operaciones) y [Servicios](#servicios) — núcleo del dominio
- [Centro de costos (CostCenter)](#centro-de-costos-costcenter) — ingresos, gastos y vínculo con facturas
- [Errores](#errores) — códigos HTTP y formatos de error

**Soporte:** soporte@apunto.com · Manuales de producto: https://docs.apunto.com
