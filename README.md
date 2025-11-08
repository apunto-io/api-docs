# Apunto API Documentation

Esta carpeta contiene la documentación completa de la API de Apunto, generada con [Slate](https://github.com/slatedocs/slate).

## 📚 Contenido

La documentación incluye:

- **Autenticación**: Cómo obtener y usar tokens de API
- **Operaciones**: Crear, listar y actualizar operaciones de freight forwarding
- **Servicios**: Gestión de servicios de transporte y aduanas
- **Tareas (To-Dos)**: Crear y gestionar tareas asociadas a operaciones y servicios
- **Comentarios**: Agregar comentarios a operaciones, servicios y tareas
- **Gestión de Errores**: Códigos de error HTTP y ejemplos de manejo
- **Rate Limiting**: Límites de uso de la API
- **Webhooks**: Notificaciones en tiempo real

## 🚀 Visualizar la Documentación

### Opción 1: Servidor de Desarrollo (Recomendado para desarrollo)

Para ver la documentación en tiempo real con hot-reload:

```bash
cd api-docs
bundle install  # Solo la primera vez
bundle exec middleman server
```

Luego abre tu navegador en: `http://localhost:4567`

Los cambios en los archivos fuente se reflejarán automáticamente.

### Opción 2: Build Estático (Para despliegue)

Para generar archivos HTML estáticos:

```bash
cd api-docs
bundle exec middleman build --clean
```

Los archivos se generarán en la carpeta `build/`. Puedes desplegar estos archivos en cualquier servidor web estático.

### Opción 3: Docker

Si prefieres usar Docker:

```bash
cd api-docs
docker build -t apunto-api-docs .
docker run -p 4567:4567 apunto-api-docs
```

## 📝 Editar la Documentación

La documentación está escrita en Markdown. Los archivos principales son:

- **`source/index.html.md`**: Documentación principal de la API
- **`source/includes/_errors.md`**: Documentación de errores
- **`source/stylesheets/`**: Estilos CSS personalizados
- **`source/images/`**: Imágenes y logos

### Estructura del Archivo Principal

```markdown
---
title: API Reference
language_tabs:
  - shell
  - ruby
  - python
  - javascript
---

# Sección Principal

Contenido de la documentación...
```

### Agregar Ejemplos de Código

Slate soporta múltiples lenguajes en tabs. Usa bloques de código con el lenguaje especificado:

```markdown
> Ejemplo de código:

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

## 🔧 Configuración

### Cambiar Colores y Estilos

Edita `source/stylesheets/_variables.scss` para personalizar:

```scss
// Colores principales
$nav-bg: #2E3336 !default;
$main-bg: #F3F7F9 !default;
$code-bg: #1E2224 !default;
```

### Agregar Secciones

Para agregar una nueva sección, simplemente añade contenido en `source/index.html.md`:

```markdown
# Nueva Sección

Descripción de la nueva sección...

## Subsección

Contenido de la subsección...
```

### Agregar Includes

Para mantener el código organizado, puedes crear archivos separados en `source/includes/`:

1. Crea un archivo: `source/includes/_nombre.md`
2. Agrégalo al header del archivo principal:

```yaml
includes:
  - errors
  - nombre
```

## 📤 Despliegue

### GitHub Pages

```bash
# Generar build
bundle exec middleman build --clean

# Desplegar a GitHub Pages
./deploy.sh
```

### Netlify

1. Conecta tu repositorio a Netlify
2. Configura el build:
   - Build command: `bundle exec middleman build --clean`
   - Publish directory: `build`

### Vercel

1. Conecta tu repositorio a Vercel
2. Configura el proyecto:
   - Framework: Other
   - Build command: `bundle install && bundle exec middleman build --clean`
   - Output directory: `build`

### Servidor Propio

Simplemente copia el contenido de la carpeta `build/` a tu servidor web:

```bash
# Generar build
bundle exec middleman build --clean

# Copiar a servidor (ejemplo con rsync)
rsync -avz build/ user@server:/var/www/api-docs/
```

## 🔄 Git Independiente

Esta carpeta tiene su propio repositorio Git independiente del proyecto principal. Esto permite:

- Versionar la documentación por separado
- Desplegarla independientemente
- Mantener un historial limpio de cambios en la documentación

Para ver el historial de cambios:

```bash
cd api-docs
git log
```

## 🛠️ Troubleshooting

### Error al ejecutar bundle install

Si obtienes errores con las gemas nativas:

```bash
# macOS
brew install libffi

# Ubuntu/Debian
sudo apt-get install libffi-dev
```

### Puerto 4567 ya en uso

```bash
# Cambiar el puerto
bundle exec middleman server -p 8080
```

### Problemas con Ruby

Asegúrate de usar Ruby >= 2.6:

```bash
ruby --version

# Si necesitas actualizar, usa rbenv o rvm
rbenv install 3.0.0
rbenv local 3.0.0
```

## 📚 Recursos

- [Documentación de Slate](https://github.com/slatedocs/slate/wiki)
- [Markdown Syntax](https://github.com/slatedocs/slate/wiki/Markdown-Syntax)
- [Middleman Documentation](https://middlemanapp.com/basics/install/)

## 📄 Licencia

Esta documentación es propiedad de Apunto y está sujeta a las mismas condiciones de licencia que el proyecto principal.

## 🤝 Contribuir

Para contribuir a la documentación:

1. Edita los archivos en `source/`
2. Verifica los cambios localmente con `bundle exec middleman server`
3. Haz commit de tus cambios en este repositorio git independiente
4. Genera el build final con `bundle exec middleman build --clean`

## 📞 Soporte

Si tienes preguntas sobre la documentación o la API:

- Email: support@apunto.com
- Issues: Crea un issue en el repositorio principal
