# Documentación API de Apunto

<p align="center">
  <img src="source/images/logo.png" alt="Apunto Logo" width="200"/>
</p>

<p align="center">
  <strong>Documentación oficial de la API REST de Apunto</strong><br>
  La plataforma todo-en-uno para freight forwarders que buscan crecer sin caos
</p>

---

## 🚢 Acerca de Apunto

**Apunto** es una plataforma integral diseñada específicamente para optimizar y automatizar las operaciones de empresas de **freight forwarding** y **logística** en América Latina. Fundada en Monterrey, Nuevo León, Apunto transforma la manera en que las empresas gestionan sus procesos logísticos, eliminando la dependencia de hojas de cálculo dispersas y sistemas desconectados.

### ✨ ¿Para Quién es Apunto?

Apunto está diseñado para freight forwarders y brokers de logística que:

- 📊 Gestionan operaciones de **importación**, **exportación** y **transporte doméstico**
- 🌊 Manejan embarques **marítimos**, **aéreos** y **terrestres**
- 🎯 Buscan **escalar** sin perder el control de la rentabilidad
- 🔄 Quieren **automatizar** procesos repetitivos y reducir errores operativos
- 📈 Necesitan **visibilidad en tiempo real** de cada operación

### 🎯 Características Principales de la Plataforma

#### 💰 Profit Tracker
Visualiza instantáneamente la rentabilidad de cada carga. Identifica oportunidades de mejora y toma decisiones basadas en datos reales, no en estimaciones.

#### 📊 Reportes Operativos
Dashboards y KPIs listos para tus reuniones. Di adiós a las hojas de cálculo y obtén información clara sobre el desempeño operativo.

#### ⚡ Workflows Inteligentes
Automatiza tareas repetitivas y reduce errores mediante flujos de trabajo que se adaptan a las necesidades específicas de tu empresa.

#### 🤝 Gestión de Proveedores
Centraliza, valida y califica a todos tus transportistas. Desde la documentación hasta las evaluaciones operativas, todo en un solo lugar.

#### 📝 Cartas de Instrucciones Automáticas
Genera instrucciones claras y precisas sin copiar y pegar. Evita errores y retrabajos con plantillas inteligentes.

#### 🔌 Integraciones Flexibles
Conéctate con tu CRM o ERP existente. Apunto se adapta a tus herramientas actuales sin necesidad de reemplazarlas.

### 🌟 Beneficios Clave

✅ **Automatización y Escalabilidad** - Crece sin aumentar tu carga operativa  
✅ **Operación Unificada** - Desde la cotización hasta la entrega, todo en un solo lugar  
✅ **Reducción de Errores** - Workflows inteligentes que previenen errores costosos  
✅ **Visibilidad Total** - Sabe exactamente qué está pasando con cada embarque  
✅ **Toma de Decisiones Informada** - Datos en tiempo real sobre rentabilidad y desempeño  
✅ **Adopción Rápida** - Tu equipo operando en días, no en meses  

### 🏆 Confianza de la Industria

Más de **30 empresas** de freight forwarding en América Latina confían en Apunto para operar sin errores y maximizar su rentabilidad.

> *"Apunto permite llevar el seguimiento de las operaciones al visualizar la información necesaria que se transmite entre el ejecutivo, cliente y proveedor, haciendo los procesos y la comunicación interna más fluida."*  
> — **Priscila Alfaro**, Gerente de Operaciones

---

## 🔌 Acerca de esta API

Esta documentación describe la **API REST de Apunto v1**, que permite a desarrolladores y empresas integrar sus sistemas existentes con la plataforma Apunto de forma programática.

### 📚 ¿Qué puedes hacer con esta API?

La API de Apunto te permite:

- **Operaciones**: Crear, actualizar y consultar operaciones de freight forwarding
- **Servicios**: Gestionar servicios de transporte (marítimo, aéreo, terrestre, aduanas)
- **Tareas**: Automatizar la creación y seguimiento de tareas operativas
- **Comentarios**: Agregar notas y comunicación a operaciones y servicios
- **Contactos**: Sincronizar clientes, proveedores y prospectos
- **Direcciones**: Administrar ubicaciones de embarques, puertos y aduanas
- **Webhooks**: Recibir notificaciones en tiempo real sobre cambios importantes
- **Reportes**: Extraer datos para análisis y dashboards personalizados

## 🚀 Inicio Rápido

### Ver la Documentación Localmente

```bash
# Opción 1: Usando el script helper
./start-docs.sh

# Opción 2: Comando directo
bundle exec middleman server
```

La documentación estará disponible en: **http://localhost:4567**

### Generar Versión Estática

```bash
bundle exec middleman build --clean
```

Los archivos se generarán en la carpeta `build/`

## 📁 Estructura de Archivos

La documentación está organizada en archivos modulares para facilitar el mantenimiento:

```
api-docs/
├── source/
│   ├── index.html.md              # Archivo principal (introducción)
│   ├── includes/
│   │   ├── _authentication.md     # Autenticación
│   │   ├── _operations.md         # Operaciones
│   │   ├── _services.md           # Servicios
│   │   ├── _tasks.md              # Tareas
│   │   ├── _comments.md           # Comentarios
│   │   ├── _contacts.md           # Contactos ✨ NUEVO
│   │   ├── _addresses.md          # Direcciones ✨ NUEVO
│   │   ├── _rate_limiting.md      # Limitación de tasa
│   │   ├── _pagination.md         # Paginación
│   │   ├── _webhooks.md           # Webhooks
│   │   └── _errors.md             # Errores
│   ├── stylesheets/               # Estilos CSS
│   └── images/                    # Imágenes y logos
├── build/                         # Archivos generados (ignorado)
└── README.md                      # Este archivo
```

## ✏️ Editar la Documentación

### Modificar Contenido

1. **Editar secciones existentes**: Abre el archivo correspondiente en `source/includes/`
2. **Ver cambios en tiempo real**: Ejecuta `./start-docs.sh` 
3. **Agregar nueva sección**: 
   - Crea un nuevo archivo `source/includes/_nombre.md`
   - Agrégalo al header de `source/index.html.md`:
   ```yaml
   includes:
     - authentication
     - operations
     - nombre  # <- Tu nueva sección
   ```

### Ejemplos de Código

Slate soporta tabs para múltiples lenguajes:

```markdown
> Ejemplo:

```shell
curl "https://api.example.com/endpoint"
\```

```ruby
# Código Ruby aquí
\```

```python
# Código Python aquí
\```

```javascript
// Código JavaScript aquí
\```
```

## 🎨 Personalización

### Colores y Estilos

Edita `source/stylesheets/_variables.scss`:

```scss
// Colores principales
$nav-bg: #2E3336 !default;
$main-bg: #F3F7F9 !default;
$code-bg: #1E2224 !default;
```

### Logo

Reemplaza `source/images/logo.png` con tu logo.

## 🌐 Despliegue

### GitHub Pages (Configurado ✅)

El sitio está configurado en **https://developers.apunto.io** usando GitHub Pages.

#### Scripts Disponibles:

```bash
# Detectar tu proveedor DNS
./detect-dns-provider.sh

# Verificar estado del sitio y DNS
./check-dns.sh

# Desplegar actualizaciones
./deploy.sh

# Habilitar HTTPS (después de configurar DNS)
./enable-https.sh

# Configurar DNS en GoDaddy (con API)
./setup-godaddy-dns.sh
```

#### Flujo de trabajo:

1. **Configurar DNS** (solo la primera vez)
   - GoDaddy detectado: Ve a https://dcc.godaddy.com
   - O usa: `./setup-godaddy-dns.sh` (requiere API Key)
   - Configuración:
     ```
     Tipo:    CNAME
     Nombre:  developers
     Valor:   apunto-io.github.io
     TTL:     1 Hour
     ```

2. **Verificar DNS** (espera 5-30 minutos)
   ```bash
   ./check-dns.sh
   ```

3. **Habilitar HTTPS**
   ```bash
   ./enable-https.sh
   ```

4. **Actualizar contenido**
   ```bash
   ./deploy.sh
   ```

#### Ver documentación completa:
- `DEPLOYMENT_STATUS.md` - Estado actual del despliegue
- `GITHUB_PAGES_SETUP.md` - Guía detallada de configuración
- `SCRIPTS.md` - Documentación de todos los scripts

### Netlify (Alternativa)

1. Conecta tu repositorio a Netlify
2. Build command: `bundle exec middleman build --clean`
3. Publish directory: `build`

### Vercel (Alternativa)

1. Conecta tu repositorio
2. Build command: `bundle install && bundle exec middleman build --clean`
3. Output directory: `build`

## 🔄 Git Independiente

Esta carpeta tiene su propio repositorio Git independiente del proyecto principal:

```bash
# Ver historial de cambios
git log

# Hacer commit de cambios
git add .
git commit -m "Descripción del cambio"
```

## 📝 Documentación en Español

Toda la documentación está en **español**, manteniendo las variables técnicas en inglés tal como están definidas en el código:

- ✅ Descripciones en español
- ✅ Explicaciones en español
- ✅ Mensajes de error en español
- ✅ Variables técnicas en inglés (`operation_id`, `status`, `kind`, etc.)

## 🔧 Troubleshooting

### Error al ejecutar bundle install

```bash
# macOS
brew install libffi

# Ubuntu/Debian
sudo apt-get install libffi-dev
```

### Puerto 4567 ya en uso

```bash
bundle exec middleman server -p 8080
```

### Problemas con Ruby

```bash
ruby --version  # Requiere Ruby >= 2.6

# Actualizar con rbenv
rbenv install 3.0.0
rbenv local 3.0.0
```

## 📖 Recursos

- [Documentación de Slate](https://github.com/slatedocs/slate/wiki)
- [Sintaxis de Markdown](https://github.com/slatedocs/slate/wiki/Markdown-Syntax)
- [Middleman](https://middlemanapp.com/basics/install/)

## 🔐 Autenticación y Seguridad

La API de Apunto utiliza **tokens de autenticación Bearer** para proteger todos los endpoints. Cada cuenta tiene acceso únicamente a sus propios datos, garantizando la privacidad y seguridad de tu información operativa.

Para obtener tu token de API:
1. Inicia sesión en tu cuenta de Apunto
2. Ve a **Configuración** → **API & Integraciones**
3. Genera un nuevo token de API
4. Usa el token en el header `Authorization: Bearer TU_TOKEN`

## 📞 Soporte y Contacto

### 💬 Soporte Técnico

Para preguntas sobre la API, integraciones o asistencia técnica:

- **Email**: hola@apunto.io
- **Teléfono**: +52 81 8526 2238
- **Chat en vivo**: Disponible dentro de la plataforma
- **Documentación API**: http://localhost:4567 (local)

### 🎓 Recursos Adicionales

- **Sitio Web**: [https://www.apunto.io](https://www.apunto.io)
- **Centro de Recursos**: Casos de éxito, guías y herramientas
- **Blog**: Artículos y tendencias del sector logístico
- **Agendar Demo**: Conoce la plataforma con una demostración personalizada

### 🏢 Ubicación

**Apunto**  
Monterrey, Nuevo León, México

---

## 🎯 Roadmap de la API

### ✅ Implementado (v1.0)

- ✅ Autenticación con Bearer tokens
- ✅ CRUD completo de Operaciones
- ✅ CRUD completo de Servicios
- ✅ Gestión de Tareas (To-Dos)
- ✅ Sistema de Comentarios (Messages)
- ✅ Gestión de Contactos
- ✅ Gestión de Direcciones
- ✅ Paginación automática
- ✅ Manejo de errores estructurado
- ✅ Búsqueda por códigos (no solo IDs)
- ✅ Rutas anidadas para recursos relacionados

### 🚀 Próximamente (v1.1)

- [ ] Webhooks en tiempo real
- [ ] Documentación de Facturación (Bills)
- [ ] Endpoints de tracking en vivo
- [ ] Filtros avanzados y búsqueda
- [ ] Exportación masiva de datos
- [ ] Rate limiting transparente
- [ ] Postman Collection oficial
- [ ] OpenAPI/Swagger specification

### 💡 En Exploración (v2.0)

- [ ] GraphQL API
- [ ] WebSocket para actualizaciones en tiempo real
- [ ] Bulk operations (crear múltiples recursos en una llamada)
- [ ] Archivos adjuntos vía API
- [ ] Integración con plataformas de shipping (Maersk, MSC, etc.)
- [ ] API de análisis y reportes avanzados

---

## 🤝 Contribuir

¿Encontraste un error en la documentación? ¿Tienes una sugerencia de mejora?

1. Crea un issue describiendo el problema o sugerencia
2. Si quieres contribuir código, haz un fork y envía un pull request
3. Para cambios mayores, abre primero un issue para discutir

---

## 📄 Licencia

Esta documentación está disponible bajo licencia MIT.

La API de Apunto está sujeta a los [Términos y Condiciones](https://www.apunto.io/terminos-y-condiciones) de uso de la plataforma.

---

## 🌟 ¿Por Qué Elegir Apunto?

### Para Desarrolladores
- ✅ API RESTful bien documentada
- ✅ Ejemplos en múltiples lenguajes (cURL, Ruby, Python, JavaScript)
- ✅ Respuestas JSON consistentes
- ✅ Códigos de error claros y descriptivos
- ✅ Soporte técnico dedicado

### Para Empresas
- ✅ Plataforma diseñada por y para freight forwarders
- ✅ Automatización que realmente funciona
- ✅ Visibilidad de rentabilidad en tiempo real
- ✅ Escalabilidad sin complicaciones
- ✅ Equipo operando en días, no meses

---

<p align="center">
  <strong>¿Listo para transformar tu operación logística?</strong><br>
  <a href="https://www.apunto.io">Visita apunto.io</a> • 
  <a href="mailto:hola@apunto.io">Contáctanos</a> • 
  <a href="https://www.apunto.io/recursos">Recursos</a>
</p>

---

**Versión de API**: v1.0  
**Última actualización**: Noviembre 2024  
**Mantenido por**: Equipo de Desarrollo de Apunto
