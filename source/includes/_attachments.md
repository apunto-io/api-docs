# Documentos (carpetas y archivos)

Los documentos de una operación o servicio se organizan en **carpetas** (`AttachmentFolder`) con archivos adjuntos (Active Storage). Puedes listarlos, subirlos, renombrarlos y eliminarlos vía API.

<aside class="notice">
El endpoint <code>GET /operations/:id</code> (show) incluye arrays <code>to_dos</code> y <code>folders</code> con el árbol completo y metadatos de archivos. Los contadores <code>tasks_count</code> y <code>folders_count</code> siguen presentes en listados (index) por rendimiento.
</aside>

## Objeto Folder (árbol)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID de la carpeta |
| name | string | Nombre |
| parent_id | integer | Carpeta padre (null = raíz) |
| files_count | integer | Número de archivos directos |
| attachments | array | Archivos en esta carpeta (ver abajo) |
| children | array | Subcarpetas (misma estructura, recursivo) |

## Objeto Attachment (archivo)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| id | integer | ID del adjunto (ActiveStorage::Attachment) — usar para PATCH/DELETE |
| blob_id | integer | ID del blob |
| filename | string | Nombre del archivo |
| byte_size | integer | Tamaño en bytes |
| content_type | string | MIME type |
| created_at | datetime | Fecha de subida |
| url | string | URL firmada/temporal para descarga (requiere mismo token/host) |

## Listar carpetas y archivos <span class="badge badge-success">GET</span>

> Definición

```
GET /api/v1/operations/:operation_id/folders
GET /api/v1/services/:service_id/folders
```

> Ejemplo

```shell
curl "https://control.apunto.io/api/v1/operations/123/folders" \
  -H "Authorization: Bearer TU_TOKEN"
```

> Respuesta JSON

```json
{
  "folderable": { "type": "Operation", "id": 123 },
  "folders": [
    {
      "id": 10,
      "name": "BL",
      "parent_id": null,
      "files_count": 1,
      "attachments": [
        {
          "id": 501,
          "blob_id": 9001,
          "filename": "bl.pdf",
          "byte_size": 245000,
          "content_type": "application/pdf",
          "created_at": "2024-01-15T12:00:00Z",
          "url": "https://control.apunto.io/rails/active_storage/blobs/redirect/..."
        }
      ],
      "children": []
    }
  ]
}
```

## Crear carpeta <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/operations/:operation_id/folders
POST /api/v1/services/:service_id/folders
```

### Parámetros (`folder`)

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| name | string | Sí | Nombre de la carpeta |
| parent_id | integer | No | ID de carpeta padre (misma operación/servicio) |

```json
{
  "folder": {
    "name": "Documentos aduana",
    "parent_id": 10
  }
}
```

## Subir archivo <span class="badge badge-info">POST</span>

> Definición

```
POST /api/v1/attachments
Content-Type: multipart/form-data
```

### Campos multipart

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| file | Sí | Archivo (máx. 25 MB) |
| folderable_type | Sí | `Operation` o `Service` |
| folderable_id | Sí | ID de la operación o servicio |
| parent_folder_id | No | ID de carpeta destino; si se omite, usa carpeta raíz `Gmail` |
| source_url | No | URL de origen (metadata) |
| source_message | No | Contexto (metadata) |

> Ejemplo cURL

```shell
curl -X POST "https://control.apunto.io/api/v1/attachments" \
  -H "Authorization: Bearer TU_TOKEN" \
  -F "folderable_type=Operation" \
  -F "folderable_id=123" \
  -F "parent_folder_id=10" \
  -F "file=@/ruta/al/archivo.pdf"
```

> Respuesta (201)

```json
{
  "success": true,
  "attachment": {
    "id": 501,
    "filename": "archivo.pdf",
    "folder_id": 10,
    "folder_name": "BL",
    "folderable_type": "Operation",
    "folderable_id": 123
  },
  "message": "Archivo subido exitosamente"
}
```

## Renombrar archivo <span class="badge badge-warning">PATCH</span>

> Definición

```
PATCH /api/v1/attachments/:id
```

```json
{
  "filename": "bl-final.pdf"
}
```

## Eliminar archivo <span class="badge badge-danger">DELETE</span>

> Definición

```
DELETE /api/v1/attachments/:id
```

Elimina el adjunto del storage (purge). El `:id` es el **`id` del attachment** devuelto en listados, no el `blob_id`.

## Tareas en operaciones y servicios

Las tareas tienen CRUD anidado. Ver [Tareas (To-Dos)](#tareas-to-dos).

Resumen de rutas bajo operación:

```
GET    /api/v1/operations/:operation_id/to_dos
POST   /api/v1/operations/:operation_id/to_dos
GET    /api/v1/operations/:operation_id/to_dos/:id
PATCH  /api/v1/operations/:operation_id/to_dos/:id
POST   /api/v1/operations/:operation_id/to_dos/:id/complete
DELETE /api/v1/operations/:operation_id/to_dos/:id
```

El **show** de operación incluye hasta 100 tareas recientes en `to_dos[]`; use el listado paginado para conjuntos grandes.
