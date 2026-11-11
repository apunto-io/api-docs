# Documentos y archivos

<p class="lead">Cada folio operativo y cada servicio tiene su propio árbol de carpetas con archivos: BL, pedimentos, facturas, fotos. Con la API lees ese árbol, creas carpetas y subes, renombras o borras archivos desde tu sistema.</p>

- Las carpetas (`folders`) cuelgan de un folio operativo (`operation`) o de un servicio (`service`). Se pueden anidar hasta 5 niveles.
- Un archivo (`attachment`) siempre vive dentro de una carpeta. Se sube con `multipart/form-data`, no con JSON.
- Leer necesita permiso para ver el folio o servicio (`operations_read` / `services_read`). Crear carpetas y subir, renombrar o borrar archivos necesita permiso para editarlo (`operations_edit` / `services_edit`). Ver [Permisos y alcance](#permisos-y-alcance).
- En un folio o servicio archivado, o en un servicio cuyo folio está archivado, todo es de solo lectura: escribir responde **422** `archived_read_only`. Ver [Archivar, restaurar y eliminar](#archivar-restaurar-y-eliminar).
- La API no renombra, mueve ni borra carpetas. Eso se hace en la plataforma.
- El detalle de un [folio](#folios-operativos) y de un [servicio](#servicios) ya trae este mismo árbol en `folders`.

## El objeto carpeta

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id de la carpeta. Úsalo como `parent_id` o `parent_folder_id`.
`name` | string | Nombre. No se repite entre carpetas hermanas (sin distinguir mayúsculas).
`parent_id` | integer | Carpeta padre. `null` en una carpeta raíz.
`files_count` | integer | <span class="ro">solo lectura</span> Archivos directos de la carpeta, sin contar subcarpetas.
`attachments` | array&lt;object&gt; | <span class="ro">solo lectura</span> Archivos de la carpeta. Ver [El objeto archivo](#el-objeto-archivo).
`children` | array&lt;object&gt; | <span class="ro">solo lectura</span> Subcarpetas, con esta misma forma.

> Objeto carpeta

```json
{
  "id": 5310,
  "name": "BL",
  "parent_id": null,
  "files_count": 1,
  "attachments": [
    {
      "id": 88214,
      "blob_id": 90561,
      "filename": "BL-MSCU1234567.pdf",
      "byte_size": 245812,
      "content_type": "application/pdf",
      "created_at": "2026-11-11T10:42:18.512-06:00",
      "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTA1NjF9fQ==--8f1e2a9c4b7d/BL-MSCU1234567.pdf"
    }
  ],
  "children": []
}
```

## El objeto archivo

Campo | Tipo | Descripción
--------- | ---- | -----------
`id` | integer | <span class="ro">solo lectura</span> Id del archivo. Es el que usas en `PATCH` y `DELETE /api/v1/attachments/:id` (no `blob_id`).
`blob_id` | integer | <span class="ro">solo lectura</span> Id del contenido almacenado. Si el mismo contenido está en dos lugares (por ejemplo, el PDF de una factura copiado a la carpeta del folio), ambos tienen el mismo `blob_id`.
`filename` | string | Nombre con extensión.
`byte_size` | integer | <span class="ro">solo lectura</span> Tamaño en bytes.
`content_type` | string | <span class="ro">solo lectura</span> Tipo MIME, tal como llegó al subirlo.
`created_at` | datetime | <span class="ro">solo lectura</span> Cuándo se agregó a la carpeta.
`url` | string | <span class="ro">solo lectura</span> Liga de descarga. Redirige al archivo y no pide el header `Authorization`: cualquiera que tenga la liga puede descargarlo, así que no la publiques. Puede ser `null` si no se pudo generar.

Al subir un archivo, la respuesta agrega `folder_id`, `folder_name`, `folderable_type` y `folderable_id` (ver [Subir un archivo](#subir-un-archivo)).

## Listar carpetas y archivos

<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/operations/:operation_id/folders</code></div>
<div class="endpoint" data-method="GET"><span class="method method-get">GET</span><code>/api/v1/services/:service_id/folders</code></div>

<p class="perm">Permiso: <code>operations_read</code> (folio) o <code>services_read</code> (servicio)</p>

Devuelve el árbol completo del folio o servicio, sin paginar: las carpetas raíz y, dentro de cada una, sus archivos y subcarpetas. En cada nivel las carpetas van ordenadas por nombre.

Campo | Tipo | Descripción
--------- | ---- | -----------
`folderable.type` | string | `Operation` (folio) o `Service` (servicio).
`folderable.id` | integer | Id del folio o servicio.
`folders` | array&lt;object&gt; | Carpetas raíz. Ver [El objeto carpeta](#el-objeto-carpeta).

> Petición

```shell
curl https://control.apunto.io/api/v1/operations/1042/folders \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "folderable": { "type": "Operation", "id": 1042 },
  "folders": [
    {
      "id": 5311,
      "name": "Aduana",
      "parent_id": null,
      "files_count": 0,
      "attachments": [],
      "children": [
        {
          "id": 5312,
          "name": "Pedimento",
          "parent_id": 5311,
          "files_count": 1,
          "attachments": [
            {
              "id": 88230,
              "blob_id": 90577,
              "filename": "pedimento-26-47-3912-6001234.pdf",
              "byte_size": 182004,
              "content_type": "application/pdf",
              "created_at": "2026-11-12T09:15:40.201-06:00",
              "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTA1Nzd9fQ==--1c7d3e9a0b2f/pedimento-26-47-3912-6001234.pdf"
            }
          ],
          "children": []
        }
      ]
    },
    {
      "id": 5310,
      "name": "BL",
      "parent_id": null,
      "files_count": 1,
      "attachments": [
        {
          "id": 88214,
          "blob_id": 90561,
          "filename": "BL-MSCU1234567.pdf",
          "byte_size": 245812,
          "content_type": "application/pdf",
          "created_at": "2026-11-11T10:42:18.512-06:00",
          "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTA1NjF9fQ==--8f1e2a9c4b7d/BL-MSCU1234567.pdf"
        }
      ],
      "children": []
    }
  ]
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El folio o servicio no existe o no lo puedes ver («Operación o servicio no encontrado»).

Los demás errores son los generales. Ver [Errores](#errores).

## Crear una carpeta

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/operations/:operation_id/folders</code></div>
<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/services/:service_id/folders</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Crea una carpeta vacía en el folio o servicio de la URL. Sin `parent_id` queda en la raíz.

### Cuerpo de la petición

Va dentro del objeto `folder`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`name` | string | <span class="req">obligatorio</span> Nombre. Se le quitan los espacios de los extremos. No puede repetirse entre carpetas hermanas (sin distinguir mayúsculas).
`parent_id` | integer | <span class="opt">opcional</span> Id de una carpeta existente del **mismo** folio o servicio. La nueva carpeta queda dentro de ella. El árbol admite hasta 5 niveles.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations/1042/folders \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "folder": { "name": "Cartas porte", "parent_id": 5311 } }'
```

> Respuesta 201

```json
{
  "folder": {
    "id": 5320,
    "name": "Cartas porte",
    "parent_id": 5311,
    "files_count": 0,
    "attachments": [],
    "children": []
  },
  "message": "Carpeta creada exitosamente"
}
```

### Respuesta

**201** con la carpeta en `folder` y un texto en `message`.

### Errores

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `name`, ya hay una carpeta hermana con ese nombre, `parent_id` es una carpeta de otro folio o servicio, o la carpeta quedaría en un sexto nivel. El detalle viene en `errors`.
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`404` `not_found` | El folio o servicio no existe o no lo puedes ver.
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.

> Error 422

```json
{
  "errors": ["Nombre ya está en uso"],
  "message": "No se pudo crear la carpeta",
  "error": "validation_failed",
  "request_id": "c41a7d2e-5b3f-4e8a-9d10-7f2b6c8e1a90"
}
```

## Subir un archivo

<div class="endpoint" data-method="POST"><span class="method method-post">POST</span><code>/api/v1/attachments</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Sube un archivo a una carpeta de un folio o servicio. La petición es `multipart/form-data` y los campos van en la raíz del formulario, **sin** objeto `attachment`. No mandes el header `Content-Type` a mano: tu cliente HTTP lo arma con su `boundary`.

### Campos del formulario

Campo | Tipo | Descripción
--------- | ---- | -----------
`file` | archivo | <span class="req">obligatorio</span> El archivo. Máximo **25 MB**. Se acepta cualquier tipo; `content_type` es el que manda tu cliente HTTP en esa parte del formulario (`application/octet-stream` si no manda ninguno).
`folderable_type` | string | <span class="req">obligatorio</span> `Operation` (folio) o `Service` (servicio), con esa capitalización.
`folderable_id` | integer | <span class="req">obligatorio</span> Id del folio o servicio.
`parent_folder_id` | integer | <span class="opt">opcional</span> Carpeta **donde se guarda** el archivo; tiene que ser del mismo folio o servicio. Sin este campo, el archivo va a la carpeta raíz `Gmail`, que se crea si no existe.
`source_url` | string | <span class="opt">opcional</span> Liga de donde salió el archivo. Se guarda como dato interno; no se devuelve.
`source_message` | string | <span class="opt">opcional</span> Contexto, por ejemplo el asunto del correo. Se guarda como dato interno; no se devuelve.
`source_app` | string | <span class="opt">opcional</span> Nombre de tu sistema (`api` por omisión). Se guarda como dato interno; no se devuelve.

- Si la carpeta ya tiene un archivo con el mismo nombre, **no lo reemplaza**: agrega otro.
- La API no recibe archivos en base64 ni descarga archivos desde una URL. Siempre manda el contenido como parte `file` del formulario.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/attachments \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -F "folderable_type=Operation" \
  -F "folderable_id=1042" \
  -F "parent_folder_id=5310" \
  -F "file=@BL-MSCU1234567.pdf;type=application/pdf"
```

```javascript
import { readFile } from "node:fs/promises";

const form = new FormData();
form.append("folderable_type", "Operation");
form.append("folderable_id", "1042");
form.append("parent_folder_id", "5310");
form.append(
  "file",
  new Blob([await readFile("BL-MSCU1234567.pdf")], { type: "application/pdf" }),
  "BL-MSCU1234567.pdf"
);

// Sin el helper api(): fetch arma el Content-Type multipart con FormData.
const res = await fetch("https://control.apunto.io/api/v1/attachments", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.APUNTO_TOKEN}` },
  body: form,
});
console.log(res.status, await res.json());
```

```python
with open("BL-MSCU1234567.pdf", "rb") as f:
    res = api.post(
        f"{BASE}/attachments",
        data={"folderable_type": "Operation", "folderable_id": 1042, "parent_folder_id": 5310},
        files={"file": ("BL-MSCU1234567.pdf", f, "application/pdf")},
    )
print(res.status_code, res.json())
```

> Respuesta 201

```json
{
  "success": true,
  "attachment": {
    "id": 88214,
    "blob_id": 90561,
    "filename": "BL-MSCU1234567.pdf",
    "byte_size": 245812,
    "content_type": "application/pdf",
    "created_at": "2026-11-11T10:42:18.512-06:00",
    "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTA1NjF9fQ==--8f1e2a9c4b7d/BL-MSCU1234567.pdf",
    "folder_id": 5310,
    "folder_name": "BL",
    "folderable_type": "Operation",
    "folderable_id": 1042
  },
  "message": "Archivo subido exitosamente"
}
```

### Respuesta

**201** con `success: true`, el archivo en `attachment` (más la carpeta y el folio o servicio donde quedó) y un texto en `message`. Guarda `attachment.id` si después vas a renombrarlo o borrarlo.

### Errores

En estos errores el cuerpo trae además `"success": false`.

Código | Cuándo
------ | ------
`422` `validation_failed` | Falta `file` («Debe enviar un archivo en el parámetro file»), pesa más de 25 MB («El archivo excede el tamaño máximo de 25 MB») o `parent_folder_id` no es una carpeta de ese folio o servicio («La carpeta destino no pertenece al recurso indicado»).
`422` `archived_read_only` | El folio o servicio está archivado (o el folio del servicio).
`404` `not_found` | `folderable_type` no es `Operation` ni `Service`, o el folio o servicio no existe o no lo puedes ver («Operación o servicio no encontrado»).
`403` `forbidden` | Puedes ver el folio o servicio pero no editarlo.

> Error 422

```json
{
  "success": false,
  "error": "validation_failed",
  "message": "El archivo excede el tamaño máximo de 25 MB",
  "errors": ["El archivo excede el tamaño máximo de 25 MB"],
  "request_id": "5e9b0c1d-2f3a-4b6c-8d7e-9f0a1b2c3d4e"
}
```

## Renombrar un archivo

<div class="endpoint" data-method="PATCH"><span class="method method-patch">PATCH</span><code>/api/v1/attachments/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Cambia el nombre del archivo. `PUT` funciona igual. No lo mueve de carpeta ni cambia su contenido.

### Cuerpo de la petición

Va en la raíz del JSON, **sin** objeto `attachment`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`filename` | string | <span class="opt">opcional</span> Nombre nuevo, con extensión. Si no lo mandas o va vacío, responde 200 sin cambios.

El nombre pertenece al contenido almacenado: si el mismo archivo está en otro lugar (mismo `blob_id`, por ejemplo el PDF de una factura copiado a la carpeta del folio), allá también cambia.

> Petición

```shell
curl -X PATCH https://control.apunto.io/api/v1/attachments/88214 \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "filename": "BL-MSCU1234567-final.pdf" }'
```

> Respuesta 200

```json
{
  "attachment": {
    "id": 88214,
    "blob_id": 90561,
    "filename": "BL-MSCU1234567-final.pdf",
    "byte_size": 245812,
    "content_type": "application/pdf",
    "created_at": "2026-11-11T10:42:18.512-06:00",
    "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OTA1NjF9fQ==--8f1e2a9c4b7d/BL-MSCU1234567-final.pdf"
  },
  "message": "Archivo actualizado exitosamente"
}
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El archivo no existe o no está en una carpeta de un folio o servicio de tu cuenta («Archivo no encontrado»).
`422` `archived_read_only` | El folio o servicio del archivo está archivado.
`403` `forbidden` | No puedes editar el folio o servicio del archivo.

## Eliminar un archivo

<div class="endpoint" data-method="DELETE"><span class="method method-delete">DELETE</span><code>/api/v1/attachments/:id</code></div>

<p class="perm">Permiso: <code>operations_edit</code> (folio) o <code>services_edit</code> (servicio)</p>

Quita el archivo de su carpeta y borra su contenido del almacenamiento. Si el mismo contenido también está en otro lugar (mismo `blob_id`, por ejemplo el PDF de una factura copiado a la carpeta del folio), ese otro lugar lo conserva.

<aside class="warning">A diferencia de la plataforma, el borrado por API <strong>no pasa por la papelera</strong>: el archivo no se puede recuperar.</aside>

> Petición

```shell
curl -X DELETE https://control.apunto.io/api/v1/attachments/88214 \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{ "message": "Archivo eliminado exitosamente" }
```

### Errores

Código | Cuándo
------ | ------
`404` `not_found` | El archivo no existe o no está en una carpeta de un folio o servicio de tu cuenta («Archivo no encontrado»).
`422` `archived_read_only` | El folio o servicio del archivo está archivado.
`403` `forbidden` | No puedes editar el folio o servicio del archivo.
