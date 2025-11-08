# Comentarios

Los comentarios permiten comunicación y notas en operaciones, servicios y tareas.

## Objeto Comment

```json
{
  "id": 999,
  "content": "Comentario de ejemplo",
  "messageable_type": "Operation",
  "messageable_id": 123,
  "owner_id": 789,
  "created_at": "2024-01-15T14:30:00Z"
}
```

## Endpoints

- `POST /api/v1/operations/:id/comments` - Comentar operación
- `POST /api/v1/services/:id/comments` - Comentar servicio
- `POST /api/v1/tasks/:id/comments` - Comentar tarea
- `GET /api/v1/[resource]/:id/comments` - Listar comentarios
- `PATCH /api/v1/comments/:id` - Actualizar comentario
- `DELETE /api/v1/comments/:id` - Eliminar comentario

