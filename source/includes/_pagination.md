# Paginación

Todos los endpoints de listado soportan paginación.

## Parámetros

Parámetro | Tipo | Por Defecto | Descripción
--------- | ---- | ----------- | -----------
page | integer | 1 | Número de página
per_page | integer | 25 | Registros por página (máx: 100)

## Respuesta

```json
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 250,
    "per_page": 25,
    "prev_page": null,
    "next_page": 2
  }
}
```
