# Permisos y alcance

El token hereda todo lo que su usuario puede hacer en la plataforma, ni más ni menos.

## Qué controla el acceso

1. **La cuenta.** Solo ves y escribes registros de la cuenta activa (ver [Elegir la cuenta](#elegir-la-cuenta)). No hay acceso cruzado entre cuentas.
2. **El rol del usuario.** Cada módulo tiene permisos de lectura, alta, edición y borrado (por ejemplo `operations_read`, `operations_create`, `operations_edit`, `operations_delete`). El administrador de la cuenta los asigna en **Configuración → Roles y permisos**.
3. **La visibilidad por registro.** Si la cuenta limita la visibilidad (todos, de su equipo o solo propios), la API respeta la misma regla en listados, detalles y cambios.

Situación | Respuesta
--------- | ---------
Sin permiso de lectura del módulo (`*_read`) | El listado responde **200** con el arreglo vacío y el detalle **404**
Sin permiso de alta, edición o borrado (`*_create`, `*_edit`, `*_delete`) | **403** `forbidden`
El registro existe pero el usuario no lo puede ver (visibilidad) | **404** `not_found` (no se revela que existe)
El registro es de otra cuenta | **404** en lectura, **422** si lo mandas como referencia

<aside class="notice">Si un listado te llega vacío y sabes que hay registros, revisa que el rol del usuario del token tenga el permiso de lectura de ese módulo y visibilidad sobre esos registros.</aside>

> Sin permiso · 403

```json
{
  "error": "forbidden",
  "message": "No tienes permiso para esta acción.",
  "request_id": "97300d19-d813-463b-8313-c5d0101274b9"
}
```

## Permisos por módulo

Módulo | Permisos
------ | --------
Contactos | `contacts_read`, `contacts_create`, `contacts_edit`, `contacts_delete`
Prospectos | `leads_read`, `leads_create`, `leads_edit`, `leads_delete`
Oportunidades | `opportunities_read`, `opportunities_create`, `opportunities_edit`, `opportunities_delete`
Solicitudes comerciales | `quote_requests_read`, `quote_requests_create`, `quote_requests_edit`, `quote_requests_delete`
Cotizaciones | `quotes_read`, `quotes_create`, `quotes_edit`, `quotes_delete`
Folios operativos | `operations_read`, `operations_create`, `operations_edit`, `operations_delete`
Servicios y centro de costos | `services_read`, `services_create`, `services_edit`, `services_delete`
Facturas | `invoices_read`, `invoices_create`, `invoices_edit`, `invoices_delete`
Facturas de proveedor | `bills_read`, `bills_create`, `bills_edit`, `bills_delete`
Direcciones | `addresses_read`, `addresses_create`, `addresses_edit`, `addresses_delete`
Conceptos e impuestos | `items_read`

Los comentarios, tareas, carpetas y archivos usan los permisos de su folio o servicio: leer necesita verlo y escribir necesita editarlo. El dueño de la cuenta tiene todos los permisos.

## Referencias a otros registros

Cuando un alta o un cambio apunta a otro registro (`contact_id`, `operation_id`, `list_id`, `item_id`, …), ese registro tiene que ser de la misma cuenta. Los usuarios que asignas (`owner_id`, `seller_id`, `operational_agent_id`, `service_agent_id`, `assignee_id`, según el recurso) tienen que ser miembros activos de la cuenta. Si no, la respuesta es **422** y nada se guarda.

Siempre que puedas, usa los códigos (`contact_code`, `seller_email`, …) en vez de ids: se resuelven dentro de la cuenta. Ver [Convenciones](#convenciones).

## Usuario recomendado para integraciones

- Crea un usuario dedicado (`integracion@tuempresa.mx`) en lugar de usar el de una persona.
- Dale un rol con solo los permisos que la integración usa: si solo sincroniza contactos y folios, no necesita facturación.
- Dale visibilidad de **todos** los registros de los módulos que sincroniza; con visibilidad «solo propios» la integración solo vería lo que ella misma creó.
- Crea un token por sistema conectado para poder revocar uno sin afectar a los demás.
