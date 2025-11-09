# 🛠️ Scripts de Despliegue y Administración

Scripts útiles para gestionar la documentación de API en GitHub Pages.

---

## 📜 Scripts Disponibles

### 1. `./deploy.sh` - Desplegar Actualizaciones

**Propósito**: Compilar y desplegar la documentación a GitHub Pages

**Uso**:
```bash
./deploy.sh
```

**Qué hace**:
1. Ejecuta `bundle exec middleman build --clean`
2. Hace commit de los cambios a la rama `gh-pages`
3. Hace push a GitHub
4. GitHub Pages actualiza el sitio en 1-2 minutos

**Cuándo usarlo**: Cada vez que actualices la documentación en `source/`

---

### 2. `./check-dns.sh` - Verificar Estado del Sitio

**Propósito**: Verificar configuración DNS, estado de GitHub Pages y conectividad

**Uso**:
```bash
./check-dns.sh
```

**Qué verifica**:
- ✅ Estado del DNS (CNAME configurado)
- ✅ Estado de GitHub Pages (build, HTTPS)
- ✅ Conectividad HTTP/HTTPS
- ✅ Último build de GitHub Pages
- ✅ Sugerencias de próximos pasos

**Cuándo usarlo**: 
- Después de configurar DNS
- Para verificar que el sitio esté funcionando
- Para troubleshooting

**Ejemplo de salida**:
```
🔍 Verificando configuración de developers.apunto.io
==================================================

📡 Estado DNS:
✅ DNS configurado: apunto-io.github.io.

🌐 Estado GitHub Pages:
Estado: built
URL: https://developers.apunto.io
HTTPS habilitado: true

🌍 Test de conectividad:
✅ Sitio accesible en https://developers.apunto.io (HTTPS 200)
```

---

### 3. `./enable-https.sh` - Habilitar HTTPS

**Propósito**: Habilitar HTTPS forzado después de configurar DNS

**Uso**:
```bash
./enable-https.sh
```

**Qué hace**:
1. Verifica que el DNS esté configurado
2. Verifica que GitHub haya generado el certificado SSL
3. Habilita HTTPS forzado
4. Muestra el estado final

**Cuándo usarlo**: 
- **Después** de configurar el DNS
- **Después** de que el DNS haya propagado (5-30 minutos)
- **Después** de que GitHub haya verificado el dominio

**Requisito previo**: DNS debe estar configurado y propagado

**Si sale error "certificate does not exist"**:
- Es normal si acabas de configurar DNS
- Espera 5-15 minutos más
- Vuelve a ejecutar el script

---

### 4. `./start-docs.sh` - Servidor Local de Desarrollo

**Propósito**: Ver la documentación localmente durante desarrollo

**Uso**:
```bash
./start-docs.sh
```

**Qué hace**:
- Inicia servidor Middleman en http://localhost:4567
- Recarga automáticamente al cambiar archivos
- Útil para preview antes de desplegar

**Cuándo usarlo**: Durante desarrollo de la documentación

---

## 🔄 Flujo de Trabajo Típico

### Primera vez (Setup):

1. **Desplegar a GitHub Pages**:
   ```bash
   ./deploy.sh
   ```

2. **Configurar DNS** en tu proveedor (ejemplo: Cloudflare):
   ```
   Tipo:    CNAME
   Nombre:  developers
   Valor:   apunto-io.github.io.
   ```

3. **Esperar propagación DNS** (5-30 minutos):
   ```bash
   ./check-dns.sh
   ```

4. **Habilitar HTTPS** cuando el DNS esté listo:
   ```bash
   ./enable-https.sh
   ```

5. **✅ Listo**: https://developers.apunto.io

---

### Actualizaciones rutinarias:

1. **Editar archivos** en `source/includes/*.md`

2. **Desplegar**:
   ```bash
   ./deploy.sh
   ```

3. **Verificar** (opcional):
   ```bash
   ./check-dns.sh
   ```

4. **✅ Listo**: Cambios en línea en 1-2 minutos

---

## 🧪 Desarrollo Local

```bash
# Instalar dependencias (solo primera vez)
bundle install

# Iniciar servidor de desarrollo
./start-docs.sh
# o
bundle exec middleman server

# Ver en navegador
open http://localhost:4567
```

---

## 📊 Comandos útiles de gh CLI

```bash
# Ver estado de GitHub Pages
gh api repos/apunto-io/api-docs/pages

# Ver último build
gh api repos/apunto-io/api-docs/pages/builds/latest

# Ver todos los builds
gh api repos/apunto-io/api-docs/pages/builds

# Ver información del repositorio
gh repo view apunto-io/api-docs
```

---

## 🆘 Troubleshooting

### El sitio no actualiza después de deploy

```bash
# Verificar que el deploy fue exitoso
gh api repos/apunto-io/api-docs/pages/builds/latest --jq .status

# Si muestra "built", espera 1-2 minutos más
# Si muestra "error", revisa el mensaje de error
```

### DNS no se configura

```bash
# Verificar DNS
dig developers.apunto.io CNAME +short

# Si no muestra nada, el DNS no está configurado o no ha propagado
# Verifica en tu proveedor DNS
```

### HTTPS no se habilita

```bash
# Verificar estado actual
gh api repos/apunto-io/api-docs/pages --jq .https_enforced

# Si muestra "false" y el DNS está configurado:
./enable-https.sh

# Si sale error "certificate does not exist":
# - Espera 5-15 minutos más
# - GitHub está generando el certificado
# - Vuelve a intentar
```

---

## 📝 Archivos de Documentación

- `README.md` - Documentación general del proyecto
- `GITHUB_PAGES_SETUP.md` - Guía detallada de configuración
- `DEPLOYMENT_STATUS.md` - Estado actual del despliegue
- `SCRIPTS.md` - Este archivo (guía de scripts)

---

## 🔗 Enlaces Rápidos

- **Repositorio**: https://github.com/apunto-io/api-docs
- **GitHub Pages Settings**: https://github.com/apunto-io/api-docs/settings/pages
- **Sitio en producción**: https://developers.apunto.io
- **Sitio GitHub (sin DNS)**: https://apunto-io.github.io/api-docs/

