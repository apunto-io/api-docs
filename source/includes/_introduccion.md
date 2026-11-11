# Introducción

<p class="lead">La API de Apunto conecta tu cuenta con tus otros sistemas: ERP, contabilidad, portales de clientes, CRM o herramientas internas. Todo lo que tu equipo ve en la plataforma (folios operativos, servicios, ciclo comercial, facturas, contactos) se puede leer y escribir por HTTP con JSON.</p>

<div class="cards">
  <a class="card" href="#guia-rapida"><span class="card-kicker">5 minutos</span><strong>Guía rápida</strong><span>Crea un token, verifica la conexión y haz tus primeras llamadas.</span></a>
  <a class="card" href="#autenticacion"><span class="card-kicker">Concepto</span><strong>Autenticación</strong><span>Tokens, el header Authorization y cuentas múltiples.</span></a>
  <a class="card" href="#sincronizacion-incremental"><span class="card-kicker">Integraciones</span><strong>Sincronización incremental</strong><span>Trae solo lo que cambió o se eliminó desde tu última corrida.</span></a>
  <a class="card" href="#flujos-completos"><span class="card-kicker">Recetas</span><strong>Flujos completos</strong><span>Del prospecto a la factura, paso a paso.</span></a>
</div>

## Qué puedes construir

- **Sincronizar clientes y proveedores** con tu ERP o sistema contable, con RFC, régimen fiscal y domicilio fiscal.
- **Crear folios operativos y servicios** cuando llega una orden desde otro sistema, y actualizar fechas, BL o pedimento cuando cambian.
- **Capturar ingresos y gastos** en el centro de costos y **generar borradores de factura** desde ellos.
- **Llevar el ciclo comercial**: prospecto, oportunidad, solicitud comercial, cotización y su conversión en folio.
- **Publicar comentarios, tareas y archivos** desde bots, correo o tickets.
- **Alimentar reportes externos** con cargas incrementales de lo que cambió.

## URL base

Todas las rutas de esta referencia cuelgan de la URL base de tu instancia.

Instancia | URL base
--------- | --------
Apunto (general) | `https://control.apunto.io/api/v1`
Instancia dedicada | `https://<tu-empresa>.apunto.io/api/v1`

Si tu empresa usa una instancia dedicada, el administrador de tu cuenta te dará su dominio. Toda la comunicación es por **HTTPS**.

> Primera llamada

```shell
curl https://control.apunto.io/api/v1/me \
  -H "Authorization: Bearer $APUNTO_TOKEN"
```

```javascript
const res = await fetch("https://control.apunto.io/api/v1/me", {
  headers: { Authorization: `Bearer ${process.env.APUNTO_TOKEN}` },
});
console.log(await res.json());
```

```python
import os, requests

res = requests.get(
    "https://control.apunto.io/api/v1/me",
    headers={"Authorization": f"Bearer {os.environ['APUNTO_TOKEN']}"},
)
print(res.json())
```

```ruby
require "net/http"
require "json"

uri = URI("https://control.apunto.io/api/v1/me")
req = Net::HTTP::Get.new(uri, "Authorization" => "Bearer #{ENV['APUNTO_TOKEN']}")
res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
puts JSON.parse(res.body)
```

> Respuesta 200

```json
{
  "id": 12,
  "name": "Integración ERP",
  "email": "integracion@tuempresa.mx",
  "time_zone": "America/Mexico_City",
  "preferred_language": "es",
  "avatar_url": null,
  "account": { "id": 3, "name": "Tu Empresa SA de CV" }
}
```

## Cómo se organiza la información

La API sigue el mismo modelo que la plataforma. Cada recurso pertenece a una **cuenta** (tu empresa) y el token solo ve los registros de la cuenta en la que opera.

- **Comercial.** Un [prospecto](#prospectos) se convierte en [oportunidad](#oportunidades). La oportunidad agrupa [solicitudes comerciales](#solicitudes-comerciales). Cada solicitud se cotiza con [cotizaciones](#cotizaciones), y una cotización ganada abre un folio.
- **Operación.** Un [folio operativo](#folios-operativos) es el expediente del embarque. Contiene [servicios](#servicios) (cada tramo o actividad), y cada servicio tiene líneas de [centro de costos](#centro-de-costos) con su ingreso y su gasto.
- **Facturación.** Las [facturas](#facturas) y [facturas de proveedor](#facturas-de-proveedor) se capturan directo o se generan desde el centro de costos.
- **Catálogos.** [Contactos](#contactos), [direcciones](#direcciones) y [catálogos](#catalogos) (tableros de servicio, conceptos, impuestos, motivos).

> Modelo de datos

```text
Cuenta
├── Comercial
│   ├── Prospectos  ──convierte──▶  Contactos (clientes)
│   ├── Oportunidades
│   │   └── Solicitudes comerciales
│   │       ├── Precios (por proveedor)
│   │       └── Cotizaciones ──abre──▶ Folio operativo
│   └── Cotizaciones directas
├── Operación
│   └── Folios operativos
│       ├── Servicios
│       │   └── Centro de costos (ingreso / gasto)
│       ├── Comentarios · Tareas · Carpetas y archivos
│       └── Facturas y facturas de proveedor (generadas)
├── Facturación
│   ├── Facturas (clientes)
│   └── Facturas de proveedor
└── Catálogos
    ├── Contactos (clientes, proveedores) + domicilio fiscal
    ├── Direcciones
    └── Tableros, conceptos, impuestos, motivos
```

## Cómo leer esta referencia

Cada endpoint sigue la misma estructura: el método y la ruta, el permiso que necesita el usuario del token, los parámetros, la respuesta y los errores más comunes. Los ejemplos de petición y respuesta están en la columna oscura de la derecha (debajo del texto en pantallas pequeñas).

Marca | Significado
----- | -----------
<span class="req">obligatorio</span> | La petición falla con 422 si falta
<span class="opt">opcional</span> | Puedes omitirlo
<span class="ro">solo lectura</span> | Viene en la respuesta pero no se escribe. Si lo mandas se ignora, salvo estados y totales, que responden 422 (ver [Campos de solo lectura](#campos-de-solo-lectura))
<span class="new">nuevo</span> | Agregado en la última versión (ver [Historial de cambios](#historial-de-cambios))

Elige el lenguaje de los ejemplos arriba de la columna derecha. Si un ejemplo no existe en ese lenguaje, se muestra en cURL. Los ejemplos en JavaScript, Python y Ruby usan el helper `api` que se define en la [Guía rápida](#2-verifica-la-conexion).

<aside class="success">¿Integras con un LLM o un generador de clientes? La referencia completa en Markdown está en <a href="llms-full.txt">llms-full.txt</a>.</aside>
