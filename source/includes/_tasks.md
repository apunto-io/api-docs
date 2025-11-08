# Tareas

Las tareas son elementos de trabajo asociados a operaciones, servicios u otras entidades.

## Objeto Task

```json
{
  "id": 456,
  "title": "Subir documentos",
  "description": "Documentos requeridos",
  "todoable_type": "Operation",
  "todoable_id": 123,
  "completed": false,
  "required": true,
  "end_at": "2024-01-25T17:00:00Z"
}
```

## Endpoints

- `GET /api/v1/tasks` - Listar tareas
- `GET /api/v1/tasks/:id` - Obtener tarea
- `POST /api/v1/tasks` - Crear tarea
- `PATCH /api/v1/tasks/:id` - Actualizar tarea

