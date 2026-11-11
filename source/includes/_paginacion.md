# Paginación

Todos los listados se devuelven por páginas. La respuesta trae el arreglo con el nombre del recurso y un objeto `pagination`.

Parámetro | Tipo | Descripción
--------- | ---- | -----------
`page` | integer | <span class="opt">opcional</span> Página a pedir. Empieza en `1` (valor por omisión).
`per_page` | integer | <span class="opt">opcional</span> Registros por página. Por omisión `25`, máximo `100`. Un valor mayor se ajusta a `100`; uno vacío o menor a 1, a `25`.

Campo | Descripción
----- | -----------
`pagination.page` | Página devuelta
`pagination.per_page` | Tamaño de página aplicado (ya ajustado al máximo)
`pagination.total` | Total de registros que cumplen los filtros, en todas las páginas

> Petición

```shell
curl "https://control.apunto.io/api/v1/contacts?kind=client&page=2&per_page=100" \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

> Respuesta 200

```json
{
  "contacts": [
    { "id": 812, "alias": "ACME", "name": "Acme Logistics" }
  ],
  "pagination": { "page": 2, "per_page": 100, "total": 101 }
}
```

## Recorrer todas las páginas

Sigue pidiendo mientras `page * per_page < total`. Una página después de la última devuelve el arreglo vacío, no un error.

> Recorrer páginas

```javascript
async function* listAll(path, params = {}) {
  for (let page = 1; ; page++) {
    const qs = new URLSearchParams({ ...params, page, per_page: 100 });
    const { body } = await api(`${path}?${qs}`);
    const key = Object.keys(body).find((k) => k !== "pagination");
    yield* body[key];
    if (page * body.pagination.per_page >= body.pagination.total) break;
  }
}

for await (const contact of listAll("/contacts", { kind: "client" })) {
  console.log(contact.alias);
}
```

```python
def list_all(path, **params):
    page = 1
    while True:
        res = api.get(f"{BASE}{path}", params={**params, "page": page, "per_page": 100}).json()
        key = next(k for k in res if k != "pagination")
        yield from res[key]
        if page * res["pagination"]["per_page"] >= res["pagination"]["total"]:
            break
        page += 1

for contact in list_all("/contacts", kind="client"):
    print(contact["alias"])
```

```ruby
def list_all(path, params = {})
  Enumerator.new do |out|
    page = 1
    loop do
      query = URI.encode_www_form(params.merge(page: page, per_page: 100))
      _, body = api(:get, "#{path}?#{query}")
      key = (body.keys - ["pagination"]).first
      body[key].each { |row| out << row }
      break if page * body["pagination"]["per_page"] >= body["pagination"]["total"]
      page += 1
    end
  end
end

list_all("/contacts", kind: "client").each { |c| puts c["alias"] }
```

## Orden

Cada listado tiene un orden fijo que se indica en su sección (por lo general, del más reciente al más antiguo). Con `updated_since` el orden cambia a `updated_at` ascendente y luego `id`, para que las páginas no se muevan mientras recorres (ver [Sincronización incremental](#sincronizacion-incremental)).

<aside class="warning">Si recorres un listado ordenado por fecha de creación mientras otros usuarios crean registros, las páginas se desplazan y puedes ver un registro dos veces. Para cargas completas o periódicas usa <code>updated_since</code>: su orden es estable.</aside>

## Búsquedas

Los endpoints `search` (por ejemplo `GET /api/v1/contacts/search?q=acme`) buscan por texto y están pensados para autocompletar. No sustituyen al listado con filtros: úsalos para encontrar un registro, no para recorrer la cuenta.
