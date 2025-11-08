# Servicios

Los servicios representan servicios individuales de transporte o aduanas dentro de una operación.

## Objeto Service

```json
{
  "id": 789,
  "identification": "SRV-001-2024",
  "operation_id": 123,
  "mode": "maritime",
  "status": "active",
  "shipment_type": "fcl",
  "shipment_kind": "international",
  "supplier_id": 111,
  "service_agent_id": 222,
  "bl": "BL123456",
  "booking": "BOOK789"
}
```

### Atributos Principales

Atributo | Tipo | Descripción
-------- | ---- | -----------
id | integer | Identificador único
identification | string | ID del servicio
operation_id | integer | ID de la operación padre
mode | string | Modo: `land`, `aerial`, `maritime`, `customs`
status | string | Estado: `active`, `finished`, `closed`, `canceled`
shipment_type | string | Tipo de envío
supplier_id | integer | ID del proveedor
bl | string | Bill of Lading
booking | string | Booking

## Listar Servicios

`GET /api/v1/services`

## Obtener un Servicio

`GET /api/v1/services/:id`

## Crear un Servicio

`POST /api/v1/services`

## Actualizar un Servicio

`PATCH /api/v1/services/:id`

