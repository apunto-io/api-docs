# Auditoría API de Apunto

## Endpoints DOCUMENTADOS vs IMPLEMENTADOS

### ✅ Implementado y Funcional
- **Auth (Autenticación)**
  - POST `/api/v1/auth` - Login ✅
  - DELETE `/api/v1/auth` - Logout ✅
  
- **Me (Usuario actual)**
  - GET `/api/v1/me` - Info del usuario ✅

- **Passwords**
  - POST `/api/v1/password` - Cambiar contraseña ✅

- **Accounts**
  - GET `/api/v1/accounts` - Listar cuentas ✅
  - Otros endpoints ✅

- **Users**
  - Endpoints de usuarios ✅

- **Contacts (Parcial)**
  - POST `/api/v1/contacts/quick_create` - Crear contacto rápido ✅
  - ❌ NO: index, show, update, destroy

- **Invoices**
  - GET `/api/v1/invoices` - Listar facturas ✅
  - GET `/api/v1/invoices/:id` - Ver factura ✅
  - PUT `/api/v1/invoices/:id` - Actualizar factura ✅
  - POST `/api/v1/invoices/:id/update_documents` - Actualizar docs ✅

- **Quote Request Pricings**
  - GET `/api/v1/quote_requests/:id/quote_request_pricings` ✅
  - POST `/api/v1/quote_requests/:id/quote_request_pricings` ✅
  - GET `/api/v1/quote_requests/:id/quote_request_pricings/suggestions` ✅

### ❌ NO Implementado (pero DOCUMENTADO incorrectamente)

- **Operations**
  - ❌ GET `/api/v1/operations` - Listar operaciones
  - ❌ GET `/api/v1/operations/:id` - Ver operación
  - ❌ POST `/api/v1/operations` - Crear operación
  - ❌ PUT `/api/v1/operations/:id` - Actualizar operación

- **Services**
  - ❌ GET `/api/v1/services` - Listar servicios
  - ❌ GET `/api/v1/services/:id` - Ver servicio
  - ❌ POST `/api/v1/services` - Crear servicio
  - ❌ PUT `/api/v1/services/:id` - Actualizar servicio

- **Tasks (ToDos)**
  - ❌ GET `/api/v1/to_dos` - Listar tareas
  - ❌ GET `/api/v1/to_dos/:id` - Ver tarea
  - ❌ POST `/api/v1/to_dos` - Crear tarea
  - ❌ PUT `/api/v1/to_dos/:id` - Actualizar tarea

- **Messages (Comentarios)**
  - ❌ POST `/api/v1/messages` - Crear comentario
  - ❌ GET `/api/v1/messages` - Listar comentarios

- **Addresses**
  - ❌ GET `/api/v1/addresses` - Listar direcciones
  - ❌ POST `/api/v1/addresses` - Crear dirección
  - ❌ PUT `/api/v1/addresses/:id` - Actualizar dirección

- **Contacts CRUD Completo**
  - ❌ GET `/api/v1/contacts` - Listar contactos
  - ❌ GET `/api/v1/contacts/:id` - Ver contacto
  - ❌ PUT `/api/v1/contacts/:id` - Actualizar contacto

## Problema Identificado: Uso de IDs en lugar de CÓDIGOS

### Ejemplo del problema actual en Invoices Controller:

```ruby
# app/controllers/api/v1/invoices_controller.rb
def invoice_params
  params.require(:invoice).permit(:date, :due_at, :contact_id, :currency_id, :description,
                                  :operation_kind, :operation_mode, :exchange_rate,
                                  :cfdi_use_id, :payment_method_id, :payment_type_id,
                                  :external_pdf, :external_xml)
end
```

### Problemas:
- Usa `contact_id` ❌
- Usa `currency_id` ❌ 
- Usa `cfdi_use_id` ❌
- Usa `payment_method_id` ❌
- Usa `payment_type_id` ❌

### Solución (como en Actiun):
- Debe usar `contact_code` o `contact_alias` ✅
- Debe usar `currency_code` (ej: "MXN", "USD") ✅
- Debe usar `payment_method` (ej: "cash", "wire-transfer") ✅
- Debe usar `payment_type` (ej: "PUE", "PPD") ✅

## Enums y Códigos - ANÁLISIS COMPLETADO ✅

### Operation ✅
- `kind`: importation, exportation, domestic, crosstrade, transportation, consulting, export_trading_company, import_trading_company
- `mode`: land, aerial, maritime
- `status`: confirmed, active, finished, closed, canceled
- `service_scope`: door_to_port_cy, door_to_door, airport_to_airport, etc. (27 opciones)

### Service ✅
- `shipment_type`: Existe en BD
- `shipment_kind`: Existe en BD
- `mode`: land, aerial, maritime
- `status`: active, finished, closed, canceled

### Contact ✅
- `kind`: client, supplier, prospect (array de strings)
- `status`: active, inactive
- `nationality`: national, foreign
- `alias`: campo único que puede usarse como código ✅

### Currency ❌ PROBLEMA
- Tabla: `name`, `currency_name`, `status`
- ❌ NO tiene campo `code` para ISO 4217
- Solución: Usar `name` field temporalmente (ya contiene MXN, USD, etc.)

### PaymentMethod ✅
- Campos: `name`, `value`, `sat_code`, `status`
- ✅ Podemos usar `value` o `sat_code` como código

### PaymentType ✅ (hereda de Catalog)
- Campos: `name`, `value` (alias: `code`), `country`, `type`
- ✅ Podemos usar `value` como código (PUE, PPD)

### CfdiUse ✅ (hereda de Catalog)
- Campos: `name`, `value` (alias: `code`)
- ✅ Podemos usar `value` como código (G01, G02, G03, etc.)

### Address ✅
- `address_type`: billing, shipping, port, customs, airport, general
- `status`: active, inactive
- `alias`: puede usarse como código ✅

## Estrategia de Implementación

### Para Crear/Actualizar recursos:
1. **Contact**: Buscar por `alias` (código único)
2. **Currency**: Buscar por `name` (MXN, USD, EUR)
3. **PaymentMethod**: Buscar por `value` o `sat_code`
4. **PaymentType**: Buscar por `value` (PUE, PPD)
5. **CfdiUse**: Buscar por `value` (G01, G02, etc.)
6. **Address**: Buscar por `id` o `alias`
7. **Operation**: Usar enums directamente (kind, mode, status)
8. **Service**: Usar enums directamente (mode, status)

### Métodos Helper Necesarios:
```ruby
def find_contact_by_code(code)
  Current.account.contacts.find_by(alias: code)
end

def find_currency_by_code(code)
  Currency.find_by(name: code) # MXN, USD, EUR
end

def find_payment_method_by_code(code)
  PaymentMethod.find_by(value: code)
end

def find_payment_type_by_code(code)
  PaymentType.find_by(value: code, country: 'MX')
end

def find_cfdi_use_by_code(code)
  CfdiUse.find_by(value: code, country: 'MX')
end
```

## Acción Requerida

1. ✅ Auditar qué existe vs qué está documentado
2. 🔄 Revisar modelos para códigos/enums
3. ⏸️ Crear controladores API faltantes
4. ⏸️ Modificar controladores existentes para usar códigos
5. ⏸️ Actualizar rutas
6. ⏸️ Actualizar documentación para reflejar realidad

