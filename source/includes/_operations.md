# Operaciones

Las operaciones representan las transacciones principales de freight forwarding en el sistema. Cada operación puede contener múltiples servicios.

## Objeto Operation

```json
{
  "id": 123,
  "identification": "IMP-MEX-001-2024",
  "number": 1,
  "kind": "importation",
  "mode": "maritime",
  "status": "active",
  "contact_id": 456,
  "operational_agent_id": 789,
  "currency_id": 1,
  "income_amount": 15000.00,
  "expense_amount": 12000.00,
  "profit_amount": 3000.00,
  "profit_percentage": 20.0,
  "tags": ["urgente", "alto-valor"]
}
```

### Atributos

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
identification | string | ID legible de la operación
kind | string | Tipo: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`
mode | string | Modo de transporte: `land`, `aerial`, `maritime`
status | string | Estado: `confirmed`, `active`, `finished`, `closed`, `canceled`
contact_id | integer | ID del contacto del cliente
operational_agent_id | integer | ID del agente operativo asignado
currency_id | integer | ID de la moneda
profit_amount | decimal | Utilidad calculada
tags | array | Etiquetas

## Listar Operaciones

```shell
curl "https://tu-dominio.com/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

> Respuesta:

```json
{
  "operations": [...],
  "pagination": { "current_page": 1, "total_pages": 5 }
}
```

Obtiene todas las operaciones de la cuenta.

### Petición HTTP

`GET /api/v1/operations`

### Parámetros Query

Parámetro | Tipo | Descripción
--------- | ---- | -----------
page | integer | Número de página
status | string | Filtrar por estado
kind | string | Filtrar por tipo
mode | string | Filtrar por modo

## Obtener una Operación

`GET /api/v1/operations/:id`

## Crear una Operación

```shell
curl -X POST "https://tu-dominio.com/api/v1/operations" \
  -H "Authorization: Bearer TU_TOKEN_API" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "kind": "importation",
      "mode": "maritime",
      "contact_id": 456,
      "currency_id": 1
    }
  }'
```

`POST /api/v1/operations`

## Actualizar una Operación

`PATCH /api/v1/operations/:id`
