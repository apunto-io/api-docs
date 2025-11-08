# Paginación

Todos los endpoints de listado soportan paginación usando parámetros estándar.

## Parámetros de Paginación

Parámetro | Tipo | Por Defecto | Descripción
--------- | ---- | ----------- | -----------
page | integer | 1 | Número de página a obtener
per_page | integer | 25 | Número de registros por página (máximo: 100)

## Respuesta de Paginación

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

Todas las respuestas paginadas incluyen un objeto `pagination` con:

Campo | Descripción
----- | -----------
current_page | Número de página actual
total_pages | Número total de páginas
total_count | Número total de registros
per_page | Registros por página
prev_page | Número de página anterior (null si está en la primera página)
next_page | Número de página siguiente (null si está en la última página)

## Ejemplo de Uso

```shell
# Obtener la segunda página con 50 registros por página
curl "https://tu-dominio.com/api/v1/operations?page=2&per_page=50" \
  -H "Authorization: Bearer TU_TOKEN_API"
```

```ruby
# Iterar por todas las páginas
page = 1
loop do
  response = hacer_peticion("/api/v1/operations?page=#{page}")
  procesar(response['operations'])
  break if response['pagination']['next_page'].nil?
  page = response['pagination']['next_page']
end
```

```python
# Obtener todos los registros paginados
def obtener_todos_los_registros(url):
    registros = []
    page = 1
    while True:
        response = requests.get(f"{url}?page={page}", headers=headers)
        data = response.json()
        registros.extend(data['operations'])
        if data['pagination']['next_page'] is None:
            break
        page = data['pagination']['next_page']
    return registros
```

```javascript
// Obtener página específica
async function obtenerPagina(page, perPage = 25) {
  const response = await axios.get(
    `https://tu-dominio.com/api/v1/operations?page=${page}&per_page=${perPage}`,
    { headers: { 'Authorization': `Bearer ${token}` } }
  );
  return response.data;
}
```

## Límites

- El número máximo de registros por página es **100**
- Si solicitas más de 100 registros por página, se retornarán solo 100
- Para obtener todos los registros, itera por las páginas usando `next_page`

