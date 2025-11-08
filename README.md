# Documentación API de Apunto

Documentación completa de la API de Apunto, generada con [Slate](https://github.com/slatedocs/slate).

## 📚 Contenido

La documentación incluye:

- **Autenticación**: Tokens de API y Bearer authentication
- **Operaciones**: Gestión de operaciones de freight forwarding
- **Servicios**: Control de servicios de transporte (marítimo, aéreo, terrestre, aduanas)
- **Tareas**: Creación y seguimiento de tareas
- **Comentarios**: Sistema de comunicación y notas
- **Contactos**: Gestión de clientes, proveedores y prospectos
- **Direcciones**: Administración de ubicaciones (embarques, facturación, puertos, aduanas)
- **Limitación de Tasa**: Control de uso de la API
- **Paginación**: Manejo de grandes conjuntos de datos
- **Webhooks**: Notificaciones en tiempo real
- **Gestión de Errores**: Códigos y manejo de errores

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

### GitHub Pages

```bash
bundle exec middleman build --clean
./deploy.sh
```

### Netlify

1. Conecta tu repositorio a Netlify
2. Build command: `bundle exec middleman build --clean`
3. Publish directory: `build`

### Vercel

1. Conecta tu repositorio
2. Build command: `bundle install && bundle exec middleman build --clean`
3. Output directory: `build`

### Servidor Propio

```bash
# Generar build
bundle exec middleman build --clean

# Copiar a servidor
rsync -avz build/ usuario@servidor:/var/www/api-docs/
```

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

## 📞 Soporte

Para preguntas sobre la API o documentación:

- **Email**: soporte@apunto.com
- **Documentación Online**: http://localhost:4567 (local)

## 🎯 Próximas Actualizaciones

Considera agregar:

- [ ] Documentación de facturación (invoices/bills)
- [ ] Endpoints de tracking en tiempo real
- [ ] Guías de integración paso a paso
- [ ] Casos de uso comunes con ejemplos completos
- [ ] Postman Collection
- [ ] OpenAPI/Swagger spec

---

**Versión de API**: v1  
**Última actualización**: Noviembre 2024
