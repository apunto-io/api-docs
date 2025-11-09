#!/bin/bash
# Guía para configurar DNS según tu proveedor

echo "🌐 Configuración de DNS para developers.apunto.io"
echo "=================================================="
echo ""
echo "⚠️  El comando 'gh' NO puede configurar DNS"
echo "    El DNS se configura en tu proveedor de dominio"
echo ""

# Detectar proveedor común
echo "¿Dónde está registrado tu dominio apunto.io?"
echo ""
echo "Opciones comunes:"
echo ""

# CLOUDFLARE
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  CLOUDFLARE (con CLI)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Si usas Cloudflare, puedes usar su CLI:"
echo ""
echo "# Instalar Cloudflare CLI"
echo "npm install -g cloudflare-cli"
echo ""
echo "# Listar zonas"
echo "cfcli zone-list"
echo ""
echo "# Agregar registro CNAME"
echo "cfcli add apunto.io developers CNAME apunto-io.github.io"
echo ""
echo "O usando curl con la API de Cloudflare:"
echo ""
cat << 'EOF'
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "CNAME",
    "name": "developers",
    "content": "apunto-io.github.io",
    "ttl": 3600,
    "proxied": false
  }'
EOF
echo ""

# GODADDY
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  GODADDY (con API)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "GoDaddy API (necesitas API Key):"
echo ""
cat << 'EOF'
curl -X PUT "https://api.godaddy.com/v1/domains/apunto.io/records/CNAME/developers" \
  -H "Authorization: sso-key YOUR_KEY:YOUR_SECRET" \
  -H "Content-Type: application/json" \
  --data '[{
    "data": "apunto-io.github.io",
    "ttl": 3600
  }]'
EOF
echo ""

# AWS ROUTE53
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  AWS ROUTE53 (con aws-cli)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Si usas AWS Route53:"
echo ""
cat << 'EOF'
aws route53 change-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "developers.apunto.io",
        "Type": "CNAME",
        "TTL": 3600,
        "ResourceRecords": [{"Value": "apunto-io.github.io"}]
      }
    }]
  }'
EOF
echo ""

# GOOGLE DOMAINS
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  GOOGLE CLOUD DNS (con gcloud)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Si usas Google Cloud DNS:"
echo ""
cat << 'EOF'
gcloud dns record-sets create developers.apunto.io \
  --type=CNAME \
  --ttl=3600 \
  --rrdatas="apunto-io.github.io." \
  --zone=YOUR_ZONE_NAME
EOF
echo ""

# MANUAL
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  CONFIGURACIÓN MANUAL (Cualquier proveedor)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Inicia sesión en tu proveedor de DNS y agrega:"
echo ""
echo "  Tipo:    CNAME"
echo "  Nombre:  developers"
echo "  Valor:   apunto-io.github.io."
echo "  TTL:     3600"
echo ""
echo "Proveedores comunes:"
echo "  • Cloudflare: https://dash.cloudflare.com"
echo "  • GoDaddy: https://dcc.godaddy.com/manage/dns"
echo "  • Namecheap: https://ap.www.namecheap.com/domains/list"
echo "  • Google Domains: https://domains.google.com"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 DESPUÉS DE CONFIGURAR DNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Verificar DNS (espera 5-30 minutos):"
echo "   ./check-dns.sh"
echo ""
echo "2. Habilitar HTTPS con gh CLI:"
echo "   ./enable-https.sh"
echo ""
echo "3. Verificar en GitHub:"
echo "   gh api repos/apunto-io/api-docs/pages"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 LO QUE SÍ PUEDES HACER CON 'gh'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Ver estado de GitHub Pages"
echo "gh api repos/apunto-io/api-docs/pages"
echo ""
echo "# Ver configuración del dominio"
echo "gh api repos/apunto-io/api-docs/pages --jq .cname"
echo ""
echo "# Habilitar HTTPS (después de DNS)"
echo "gh api --method PUT repos/apunto-io/api-docs/pages \\"
echo "  --field https_enforced=true \\"
echo "  --field cname=developers.apunto.io \\"
echo "  --field source[branch]=gh-pages \\"
echo "  --field source[path]=/"
echo ""
echo "# Ver último build"
echo "gh api repos/apunto-io/api-docs/pages/builds/latest"
echo ""

