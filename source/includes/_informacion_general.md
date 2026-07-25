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
6. **Documentos comerciales** — Facturas de cliente (`Invoice`) y facturas o gastos de proveedor (`Bill`), con opción de vincular líneas al centro de costos o generar borradores desde una operación.
7. **Colaboración** — Comentarios (`messages`), tareas (`to_dos`) y carpetas de archivos en operaciones, servicios y contactos.

La API refleja ese mismo modelo: casi siempre navegarás **operación → servicios → centro de costos**, y usarás contactos y direcciones como catálogos de referencia.

```
Cuenta (tenant)
├── Operaciones
│   ├── Servicios
│   │   └── Centros de costo (líneas ingreso/gasto)
│   ├── Comentarios, tareas, carpetas de archivos
│   └── Agregado de centros de costo (solo lectura)
├── Contactos (+ direcciones anidadas, mensajes, tareas)
├── Direcciones (nivel cuenta)
├── Facturas y bills
└── Adjuntos (p. ej. extensión Chrome)
```

## Qué puedes construir con la API

Algunos ejemplos habituales de integración:

- **Sincronizar operaciones** con un ERP, WMS o portal del cliente (estado, referencias, fechas clave).
- **Crear o actualizar servicios** cuando un carrier, aduana o sistema de tracking confirme un hito.
- **Registrar ingresos y gastos** en el centro de costos desde herramientas de compras o conciliación.
- **Generar borradores de factura o bill** a partir de líneas de centro de costos ya capturadas en la operación.
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
| `DELETE` | Eliminar (cuando el recurso lo permite) |

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

Los errores combinan el **código HTTP** y un cuerpo JSON. La forma exacta depende del tipo de fallo:

**Autenticación (401)** — sin cuerpo en algunos casos, o:

```json
{
  "error": "Invalid email or password."
}
```

**Validación (422)** — campos con mensajes:

```json
{
  "errors": {
    "contact_code": ["can't be blank"],
    "kind": ["is invalid"]
  }
}
```

**Recurso no encontrado (404)**:

```json
{
  "error": "Operation not found."
}
```

Consulta la sección [Errores](#errores) para el catálogo de códigos y buenas prácticas de reintento.

## Alcance de la cuenta y permisos

- Cada **token de API** pertenece a un **usuario**. Las peticiones se ejecutan con su sesión y permisos (roles y políticas de la cuenta).
- Los listados y búsquedas solo devuelven registros de **`Current.account`** — la cuenta activa de ese usuario.
- Un usuario **bloqueado** recibe **403** aunque el token siga siendo válido.
- Si tu integración necesita acciones que el usuario no puede hacer en la web, la API tampoco las permitirá.

## Identificadores: ID numérico y códigos (`*_code`)

En **lecturas** (`GET`) recibirás `id` numérico en JSON.

En **altas y cambios** (`POST` / `PATCH` / `PUT`) conviene usar **códigos legibles** que ya manejas en Apunto, por ejemplo:

| Parámetro | Resuelve |
|-----------|----------|
| `contact_code` | Alias del contacto (cliente/proveedor) |
| `supplier_code` | Alias del proveedor |
| `currency_code` | Moneda (`MXN`, `USD`, …) |
| `operational_agent_email` | Usuario agente operativo |
| `address_code` | Alias de dirección |

Así evitas hardcodear IDs internos entre entornos. Si un código no existe en la cuenta, obtendrás error de validación o 404 según el endpoint.

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

Evita bucles que recorran “toda la cuenta” sin paginar; usa `total` y `page` hasta agotar resultados.

## Versionado

La versión actual es **`v1`** (prefijo `/api/v1/`). Dentro de una misma versión mayor intentamos no romper contratos existentes; cambios incompatibles implicarán una nueva versión (`v2`, etc.).

## Cómo empezar (checklist)

1. **Acceso** — Usuario activo en tu cuenta Apunto con permisos para los módulos que integrarás.
2. **Token** — En la web: **Configuración → Tokens de API** → crea un token y guárdalo de forma segura (solo se muestra al crearlo).
3. **Primera petición** — Prueba `GET /api/v1/operations` con `Authorization: Bearer TU_TOKEN`.
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
