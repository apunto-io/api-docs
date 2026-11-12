# Convenciones

Reglas que aplican a todos los endpoints. Si las conoces, cada recurso se lee igual.

## Peticiones y respuestas

- Envía y recibe **JSON** (`Content-Type: application/json`). La única excepción es la subida de archivos, que usa `multipart/form-data` (ver [Documentos y archivos](#documentos-y-archivos)).
- **Actualizar es parcial.** `PATCH` (o `PUT`, que se comporta igual) cambia solo los campos que mandas; lo que omites no cambia. Para vaciar un campo mándalo en `null` o `""`.
- Los cuerpos de alta y cambio van dentro de un **objeto raíz** con el nombre del recurso en singular. Un alta sin ese objeto responde **422** con los campos que faltan.

Operación | Método | Éxito | Cuerpo de la respuesta
--------- | ------ | ----- | ----------------------
Listar | `GET /recursos` | 200 | `{ "recursos": [...], "pagination": {...} }`
Obtener | `GET /recursos/:id` | 200 | `{ "recurso": {...} }`
Crear | `POST /recursos` | 201 | `{ "recurso": {...}, "message": "..." }`
Actualizar | `PATCH /recursos/:id` | 200 | `{ "recurso": {...}, "message": "..." }`
Archivar, restaurar, eliminar | `POST .../archive`, `POST .../restore`, `DELETE` | 200 | Decisión del ciclo de vida (ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar))

<aside class="notice">Excepción: <a href="#facturas">facturas</a> y <a href="#facturas-de-proveedor">facturas de proveedor</a> devuelven el objeto sin raíz y sin <code>message</code> al obtener, crear y actualizar. Cada sección lo muestra.</aside>

> Objeto raíz

```shell
curl -X PATCH https://control.apunto.io/api/v1/operations/1042 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "operation": { "client_ref": "PO-7781-B" } }'
```

> Respuesta 200

```json
{
  "operation": {
    "id": 1042,
    "identification": "IMP-ACME-000184",
    "client_ref": "PO-7781-B"
  },
  "message": "Operación actualizada exitosamente"
}
```

## Códigos en lugar de ids

Casi todas las referencias aceptan un **código legible** además del id interno. Los códigos se resuelven dentro de tu cuenta, así que tu integración no necesita guardar ids de Apunto. Manda uno u otro, no ambos.

Código | Equivale a | Qué contiene
------ | ---------- | ------------
`contact_code` | `contact_id` | Alias del contacto (`ACME`)
`supplier_code` | `supplier_id` | Alias del proveedor
`currency_code` | `currency_id` | Moneda ISO 4217 (`MXN`, `USD`, `EUR`)
`*_email` (`seller_email`, `owner_email`, `operational_agent_email`, …) | `*_id` del usuario | Correo de un miembro de la cuenta
`contact_tax_regime_code`, `cfdi_use_code`, `payment_method_code`, `payment_type_code` | ids de catálogos SAT | Clave del SAT, en ese orden: régimen `601`, uso de CFDI `G03`, forma de pago `03`, método de pago `PUE`

Si el código no existe, la respuesta es **422** con un mensaje como «Contacto no encontrado con el código proporcionado».

<aside class="notice">El <code>alias</code> de un contacto es único en la cuenta y es lo que usan los demás recursos como <code>contact_code</code>. Elige alias estables (la clave del cliente en tu ERP, por ejemplo).</aside>

## Identificadores

- `id` es un entero, único por tipo de recurso. No cambia nunca.
- `identification` es el folio legible (`IMP-ACME-000184`, `COT-000031`). Lo genera la cuenta según su formato de numeración y **no** se manda al crear.
- `alias` es el código del contacto o la dirección; lo eliges tú.

## Fechas y horas

Tipo | Formato | Ejemplo
---- | ------- | -------
`date` | `YYYY-MM-DD` | `2026-11-20`
`datetime` | ISO 8601 con offset | `2026-11-11T17:14:06.816-06:00`

- Las respuestas traen fecha-hora en la zona de la plataforma (`America/Mexico_City`) **con su offset**, así que se convierten sin ambigüedad.
- Al enviar fecha-hora incluye el offset o `Z` (UTC). Un valor sin offset se interpreta en `America/Mexico_City`.
- `created_at` y `updated_at` vienen en todos los recursos. `updated_at` cambia con cualquier edición, archivo o restauración, y es la base de la [sincronización incremental](#sincronizacion-incremental).

## Montos y decimales

Los montos, cantidades y tipos de cambio salen como **string decimal** (`"1500.5"`) para no perder precisión. Al enviarlos puedes usar número (`1500.50`) o string (`"1500.50"`). Convierte con un tipo decimal, no con flotantes, si vas a sumar.

## Enums

Los campos con valores fijos (`kind`, `mode`, `status`, …) aceptan y devuelven el valor en inglés (`importation`, `maritime`, `confirmed`). Cada recurso lista sus valores. Un valor fuera de la lista responde **422** con los valores permitidos.

## Campos de solo lectura

Algunos campos se devuelven pero no se escriben. La API trata distinto dos grupos:

- **Estados y totales: responden 422.** `status` cambia solo con su acción (`close`, `cancel`, `transition`, `approve`, …) y los totales del folio y la utilidad de cada línea (`profit_amount`, `profit_percentage`) los calcula la plataforma desde el centro de costos. Si los mandas, la respuesta es **422** `read_only_fields` con la lista en `fields`, para que no creas que el cambio se aplicó.
- **Folios y metadatos: se ignoran.** `id`, `identification`, `created_at`, `updated_at` y `archived_at` no se escriben; si vienen en el cuerpo, la API los ignora sin error.

Cada recurso marca estos campos con <span class="ro">solo lectura</span>.

> Error 422 · read_only_fields

```json
{
  "error": "read_only_fields",
  "message": "El status del folio cambia con sus acciones: POST /operations/:id/close, /reopen o /cancel.",
  "errors": ["status no se escribe en esta petición"],
  "fields": ["status"],
  "request_id": "6c0f6a8e-2a7e-4c55-9d3e-1b0c2f8d9e11"
}
```

## Etiquetas

`tag_list` recibe un arreglo de nombres. Cada nombre debe existir en el catálogo de etiquetas de la cuenta para ese módulo (**Configuración → Etiquetas**); la API no crea etiquetas nuevas. Un nombre desconocido responde **422** con la lista de los que faltan.

## Idioma de los mensajes

`message` y `errors` salen en el idioma de la cuenta (español para cuentas de México). Para forzarlo agrega `locale=es` o `locale=en` en la URL. Los códigos (`error`, `outcome`, `code`) y los valores de enums no cambian con el idioma: úsalos para tu lógica y deja los textos para mostrarlos o guardarlos en logs.

## Cuenta activa

Todas las rutas operan sobre una sola cuenta. Si el usuario del token pertenece a varias, indica cuál con `account_id` (ver [Elegir la cuenta](#elegir-la-cuenta)).
