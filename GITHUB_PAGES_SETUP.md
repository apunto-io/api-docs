# Configuración de GitHub Pages para developers.apunto.io

## ✅ Pasos Completados

1. ✅ Build de la documentación generado
2. ✅ Archivo CNAME creado con el dominio `developers.apunto.io`
3. ✅ Desplegado a la rama `gh-pages`
4. ✅ Push exitoso a GitHub

---

## 🌐 Configuración DNS Requerida

Para que `developers.apunto.io` apunte a GitHub Pages, necesitas configurar los siguientes registros DNS en tu proveedor de dominio (apunto.io):

### Opción 1: Usando CNAME (Recomendado)

Agrega un registro **CNAME** en tu DNS:

```
Tipo:    CNAME
Nombre:  developers
Valor:   apunto-io.github.io
TTL:     3600 (o automático)
```

### Opción 2: Usando registros A (Alternativa)

Si tu proveedor no soporta CNAME para subdominios, usa registros A:

```
Tipo:    A
Nombre:  developers
Valor:   185.199.108.153
TTL:     3600

Tipo:    A
Nombre:  developers
Valor:   185.199.109.153
TTL:     3600

Tipo:    A
Nombre:  developers
Valor:   185.199.110.153
TTL:     3600

Tipo:    A
Nombre:  developers
Valor:   185.199.111.153
TTL:     3600
```

---

## ⚙️ Configuración en GitHub

### 1. Verificar GitHub Pages está habilitado

1. Ve a tu repositorio: https://github.com/apunto-io/api-docs
2. Ve a **Settings** → **Pages**
3. Verifica que:
   - **Source**: Deploy from a branch
   - **Branch**: `gh-pages` / `/ (root)`
   - **Custom domain**: `developers.apunto.io`
   - **Enforce HTTPS**: ✅ (habilitado después de configurar DNS)

### 2. Configurar el dominio personalizado (si no está configurado)

Si el dominio personalizado no aparece configurado:

1. Ve a **Settings** → **Pages**
2. En **Custom domain**, ingresa: `developers.apunto.io`
3. Click en **Save**
4. Espera a que GitHub verifique el DNS (puede tardar unos minutos)

---

## 🔒 Habilitar HTTPS

Una vez que el DNS esté propagado (puede tardar de 5 minutos a 48 horas):

1. Ve a **Settings** → **Pages**
2. Marca la casilla **Enforce HTTPS**
3. GitHub generará automáticamente un certificado SSL gratuito

---

## 🧪 Verificar la Configuración

### 1. Verificar DNS (después de configurar)

```bash
# Verificar registro CNAME
dig developers.apunto.io CNAME +short

# Debería mostrar:
# apunto-io.github.io.
```

### 2. Verificar que el sitio esté en línea

Después de la propagación DNS, visita:
- https://developers.apunto.io

---

## 🚀 Flujo de Trabajo para Futuras Actualizaciones

Cada vez que quieras actualizar la documentación:

```bash
# 1. Edita los archivos en source/includes/
# 2. Genera el build y despliega:
./deploy.sh

# O manualmente:
bundle exec middleman build --clean
./deploy.sh --push-only
```

El script `deploy.sh` automáticamente:
- Genera el build en la carpeta `build/`
- Hace commit de los cambios a la rama `gh-pages`
- Hace push a GitHub
- GitHub Pages actualiza el sitio automáticamente (tarda 1-2 minutos)

---

## 📋 Checklist de Configuración

- [x] Archivo CNAME creado
- [x] Build generado correctamente
- [x] Desplegado a rama `gh-pages`
- [ ] Registros DNS configurados (CNAME o A)
- [ ] DNS propagado (verificar con `dig`)
- [ ] Dominio personalizado configurado en GitHub Pages
- [ ] HTTPS habilitado en GitHub Pages
- [ ] Sitio accesible en https://developers.apunto.io

---

## 🆘 Troubleshooting

### El sitio no carga después de configurar DNS

**Problema**: DNS aún no ha propagado  
**Solución**: Espera de 5 minutos a 48 horas. Verifica con `dig developers.apunto.io`

### Error "Domain's DNS record could not be retrieved"

**Problema**: GitHub no puede verificar el DNS  
**Solución**: 
1. Verifica que el registro CNAME o A esté configurado correctamente
2. Espera unos minutos y vuelve a intentar
3. Usa `dig developers.apunto.io` para verificar

### El sitio carga pero sin estilos

**Problema**: Rutas de assets incorrectas  
**Solución**: Ya está configurado correctamente con Middleman, pero verifica que `build/` contenga todos los archivos CSS/JS

### HTTPS no está disponible

**Problema**: DNS no ha propagado o HTTPS no habilitado  
**Solución**:
1. Espera a que DNS propague completamente
2. Ve a Settings → Pages → Enforce HTTPS
3. Espera unos minutos para que GitHub genere el certificado

---

## 📞 Proveedores DNS Comunes

### Cloudflare
1. Dashboard → DNS → Add record
2. Type: CNAME, Name: developers, Target: apunto-io.github.io
3. Proxy status: DNS only (nube gris, no naranja)

### GoDaddy
1. DNS Management → Add → CNAME
2. Name: developers, Value: apunto-io.github.io

### Namecheap
1. Advanced DNS → Add New Record
2. Type: CNAME Record, Host: developers, Value: apunto-io.github.io

### Google Domains
1. DNS → Custom records → Manage custom records
2. Create new record → CNAME, developers, apunto-io.github.io

---

## 🎉 ¡Listo!

Una vez completados todos los pasos, tu documentación estará disponible en:

**https://developers.apunto.io**

La documentación se actualizará automáticamente cada vez que ejecutes `./deploy.sh`

