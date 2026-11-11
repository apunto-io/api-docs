# Guía rápida

En cinco pasos vas a autenticarte, comprobar la conexión, dar de alta un cliente, abrir un folio operativo y traer los cambios desde tu última sincronización. Los ejemplos usan la variable de entorno `APUNTO_TOKEN`.

## 1. Crea un token

1. Entra a la plataforma con el usuario que usará la integración. Te recomendamos un usuario dedicado (por ejemplo `integracion@tuempresa.mx`) con solo los permisos que necesita.
2. Ve a **Configuración → Tokens de API** y crea un token con un nombre que lo identifique (`ERP producción`).
3. Copia el token: solo se muestra una vez. Guárdalo en tu gestor de secretos, nunca en el código.

> Guarda el token

```shell
export APUNTO_TOKEN="pega-aquí-tu-token"
```

<aside class="warning">El token actúa con los permisos de su usuario. Si el usuario no puede ver o editar algo en la plataforma, la API tampoco lo permite.</aside>

## 2. Verifica la conexión

`GET /api/v1/me` responde el usuario dueño del token y la cuenta con la que opera. Si responde **401**, el token no es válido o ya venció.

> Petición

```shell
curl https://control.apunto.io/api/v1/me \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

```javascript
const api = (path, options = {}) =>
  fetch(`https://control.apunto.io/api/v1${path}`, {
    ...options,
    headers: {
      Authorization: `Bearer ${process.env.APUNTO_TOKEN}`,
      "Content-Type": "application/json",
      Accept: "application/json",
      ...options.headers,
    },
  }).then(async (res) => ({ status: res.status, body: await res.json() }));

console.log(await api("/me"));
```

```python
import os, requests

api = requests.Session()
api.headers.update({
    "Authorization": f"Bearer {os.environ['APUNTO_TOKEN']}",
    "Accept": "application/json",
})
BASE = "https://control.apunto.io/api/v1"

print(api.get(f"{BASE}/me").json())
```

```ruby
require "net/http"
require "json"

BASE = "https://control.apunto.io/api/v1"

def api(method, path, body = nil)
  uri = URI("#{BASE}#{path}")
  req = Net::HTTP.const_get(method.capitalize).new(uri)
  req["Authorization"] = "Bearer #{ENV['APUNTO_TOKEN']}"
  req["Content-Type"] = "application/json"
  req.body = body.to_json if body
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
  [res.code.to_i, JSON.parse(res.body)]
end

p api(:get, "/me")
```

> Respuesta 200

```json
{
  "id": 12,
  "name": "Integración ERP",
  "email": "integracion@tuempresa.mx",
  "account": { "id": 3, "name": "Tu Empresa SA de CV" }
}
```

## 3. Da de alta un cliente

Los registros se envían dentro de un objeto raíz con el nombre del recurso (`contact`, `operation`, …). El `alias` es el código con el que después harás referencia al cliente (`contact_code`).

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/contacts \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "name": "Acme Logistics",
      "legal_name": "Acme Logistics SA de CV",
      "alias": "ACME",
      "identification": "ALO010101AB1",
      "kind": ["client"],
      "contact_tax_regime_code": "601",
      "email": "facturas@acme.mx"
    }
  }'
```

```javascript
const { status, body } = await api("/contacts", {
  method: "POST",
  body: JSON.stringify({
    contact: {
      name: "Acme Logistics",
      legal_name: "Acme Logistics SA de CV",
      alias: "ACME",
      identification: "ALO010101AB1",
      kind: ["client"],
      contact_tax_regime_code: "601",
      email: "facturas@acme.mx",
    },
  }),
});
```

```python
res = api.post(f"{BASE}/contacts", json={
    "contact": {
        "name": "Acme Logistics",
        "legal_name": "Acme Logistics SA de CV",
        "alias": "ACME",
        "identification": "ALO010101AB1",
        "kind": ["client"],
        "contact_tax_regime_code": "601",
        "email": "facturas@acme.mx",
    }
})
print(res.status_code, res.json())
```

```ruby
status, body = api(:post, "/contacts", {
  contact: {
    name: "Acme Logistics",
    legal_name: "Acme Logistics SA de CV",
    alias: "ACME",
    identification: "ALO010101AB1",
    kind: ["client"],
    contact_tax_regime_code: "601",
    email: "facturas@acme.mx"
  }
})
```

> Respuesta 201

```json
{
  "contact": {
    "id": 812,
    "alias": "ACME",
    "name": "Acme Logistics",
    "kind": ["client"],
    "email": "facturas@acme.mx",
    "contact_tax_regime": { "code": "601", "name": "General de Ley Personas Morales" }
  },
  "message": "Contacto creado exitosamente"
}
```

Si un campo no pasa la validación, la respuesta es **422** con la lista de mensajes en `errors`. Ver [Errores](#errores).

## 4. Abre un folio operativo

Un folio operativo necesita cliente, moneda, tipo (`kind`) y modo de transporte (`mode`). Usa códigos legibles en vez de ids: `contact_code` es el alias del cliente y `currency_code` la moneda.

> Petición

```shell
curl -X POST https://control.apunto.io/api/v1/operations \
  -H "Authorization: Bearer $APUNTO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "contact_code": "ACME",
      "currency_code": "USD",
      "kind": "importation",
      "mode": "maritime",
      "client_ref": "PO-7781",
      "goods_description": "2x40HC autopartes"
    }
  }'
```

```javascript
const { body } = await api("/operations", {
  method: "POST",
  body: JSON.stringify({
    operation: {
      contact_code: "ACME",
      currency_code: "USD",
      kind: "importation",
      mode: "maritime",
      client_ref: "PO-7781",
    },
  }),
});
console.log(body.operation.identification);
```

```python
res = api.post(f"{BASE}/operations", json={
    "operation": {
        "contact_code": "ACME",
        "currency_code": "USD",
        "kind": "importation",
        "mode": "maritime",
        "client_ref": "PO-7781",
    }
})
print(res.json()["operation"]["identification"])
```

> Respuesta 201

```json
{
  "operation": {
    "id": 1042,
    "identification": "IMP-ACME-000184",
    "kind": "importation",
    "mode": "maritime",
    "status": "confirmed",
    "client_ref": "PO-7781",
    "contact": { "alias": "ACME", "name": "Acme Logistics" },
    "currency": { "code": "USD", "name": "Dólar estadounidense" }
  },
  "message": "Operación creada exitosamente"
}
```

Después agrega [servicios](#servicios) al folio y sus líneas de [centro de costos](#centro-de-costos).

## 5. Sincroniza los cambios

Para mantener tu sistema al día no recorras toda la cuenta: pide solo lo que cambió y lo que se eliminó desde tu última corrida.

> Petición

```shell
curl "https://control.apunto.io/api/v1/operations?updated_since=2026-11-11T18:00:00Z&per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"

curl "https://control.apunto.io/api/v1/operations?deleted_since=2026-11-11T18:00:00Z" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

```python
since = "2026-11-11T18:00:00Z"
page = 1
while True:
    res = api.get(f"{BASE}/operations", params={"updated_since": since, "per_page": 100, "page": page}).json()
    for op in res["operations"]:
        upsert(op)  # tu lógica
    if page * res["pagination"]["per_page"] >= res["pagination"]["total"]:
        break
    page += 1
```

La guía completa, con el manejo de la ventana de solapamiento, está en [Sincronización incremental](#sincronizacion-incremental).

<aside class="success">Siguiente paso: revisa <a href="#permisos-y-alcance">Permisos y alcance</a> para darle al usuario de la integración solo los permisos que necesita.</aside>
