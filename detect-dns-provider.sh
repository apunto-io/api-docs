#!/bin/bash
# Detectar proveedor DNS de apunto.io

echo "🔍 Detectando proveedor DNS de apunto.io..."
echo ""

# Obtener nameservers
NAMESERVERS=$(dig NS apunto.io +short 2>/dev/null | sort)

if [ -z "$NAMESERVERS" ]; then
    echo "❌ No se pudo detectar el proveedor DNS"
    echo "   Verifica que el dominio apunto.io esté activo"
    exit 1
fi

echo "📡 Nameservers detectados:"
echo "$NAMESERVERS"
echo ""

# Detectar proveedor común
PROVIDER="DESCONOCIDO"

if echo "$NAMESERVERS" | grep -qi "cloudflare"; then
    PROVIDER="Cloudflare"
elif echo "$NAMESERVERS" | grep -qi "domaincontrol.com\|godaddy"; then
    PROVIDER="GoDaddy"
elif echo "$NAMESERVERS" | grep -qi "awsdns"; then
    PROVIDER="AWS Route53"
elif echo "$NAMESERVERS" | grep -qi "googledomains.com"; then
    PROVIDER="Google Domains"
elif echo "$NAMESERVERS" | grep -qi "nsone.net"; then
    PROVIDER="NS1"
elif echo "$NAMESERVERS" | grep -qi "dnsimple"; then
    PROVIDER="DNSimple"
elif echo "$NAMESERVERS" | grep -qi "namecheap"; then
    PROVIDER="Namecheap"
fi

echo "🏢 Proveedor DNS: $PROVIDER"
echo ""

# Instrucciones específicas por proveedor
case $PROVIDER in
    "Cloudflare")
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 CLOUDFLARE - Instrucciones"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Opción 1: Panel Web (Más fácil)"
        echo "  1. Ve a: https://dash.cloudflare.com"
        echo "  2. Selecciona el dominio: apunto.io"
        echo "  3. Ve a DNS → Records"
        echo "  4. Click en 'Add record'"
        echo "  5. Configura:"
        echo "     Type: CNAME"
        echo "     Name: developers"
        echo "     Target: apunto-io.github.io"
        echo "     Proxy status: DNS only (nube gris)"
        echo "     TTL: Auto"
        echo "  6. Click 'Save'"
        echo ""
        echo "Opción 2: API de Cloudflare (CLI)"
        echo "  Necesitas tu Zone ID y API Token"
        echo ""
        echo "  # Instalar wrangler (CLI de Cloudflare)"
        echo "  npm install -g wrangler"
        echo ""
        echo "  # O usar curl directamente:"
        echo "  curl -X POST 'https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records' \\"
        echo "    -H 'Authorization: Bearer YOUR_API_TOKEN' \\"
        echo "    -H 'Content-Type: application/json' \\"
        echo "    --data '{\"type\":\"CNAME\",\"name\":\"developers\",\"content\":\"apunto-io.github.io\",\"ttl\":3600,\"proxied\":false}'"
        echo ""
        ;;
    
    "GoDaddy")
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 GODADDY - Instrucciones"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Opción 1: Panel Web (Más fácil)"
        echo "  1. Ve a: https://dcc.godaddy.com"
        echo "  2. My Products → DNS"
        echo "  3. Selecciona apunto.io"
        echo "  4. Click 'Add' en DNS Records"
        echo "  5. Configura:"
        echo "     Type: CNAME"
        echo "     Name: developers"
        echo "     Value: apunto-io.github.io"
        echo "     TTL: 1 Hour"
        echo "  6. Click 'Save'"
        echo ""
        echo "Opción 2: API de GoDaddy"
        echo "  curl -X PUT 'https://api.godaddy.com/v1/domains/apunto.io/records/CNAME/developers' \\"
        echo "    -H 'Authorization: sso-key YOUR_KEY:YOUR_SECRET' \\"
        echo "    -H 'Content-Type: application/json' \\"
        echo "    --data '[{\"data\":\"apunto-io.github.io\",\"ttl\":3600}]'"
        echo ""
        ;;
    
    "AWS Route53")
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 AWS ROUTE53 - Instrucciones"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Opción 1: AWS Console"
        echo "  1. Ve a: https://console.aws.amazon.com/route53"
        echo "  2. Hosted zones → apunto.io"
        echo "  3. Click 'Create record'"
        echo "  4. Configura:"
        echo "     Record name: developers"
        echo "     Record type: CNAME"
        echo "     Value: apunto-io.github.io"
        echo "     TTL: 300"
        echo "  5. Click 'Create records'"
        echo ""
        echo "Opción 2: AWS CLI"
        echo "  aws route53 change-resource-record-sets \\"
        echo "    --hosted-zone-id YOUR_ZONE_ID \\"
        echo "    --change-batch file://change-batch.json"
        echo ""
        echo "  Donde change-batch.json contiene:"
        cat << 'EOF'
  {
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "developers.apunto.io",
        "Type": "CNAME",
        "TTL": 3600,
        "ResourceRecords": [{"Value": "apunto-io.github.io"}]
      }
    }]
  }
EOF
        echo ""
        ;;
    
    "Google Domains")
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 GOOGLE DOMAINS - Instrucciones"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Panel Web:"
        echo "  1. Ve a: https://domains.google.com"
        echo "  2. Selecciona apunto.io"
        echo "  3. DNS → Manage custom records"
        echo "  4. Click 'Create new record'"
        echo "  5. Configura:"
        echo "     Host name: developers"
        echo "     Type: CNAME"
        echo "     TTL: 1H"
        echo "     Data: apunto-io.github.io"
        echo "  6. Click 'Save'"
        echo ""
        ;;
    
    *)
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 INSTRUCCIONES GENÉRICAS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Inicia sesión en tu proveedor DNS y agrega:"
        echo ""
        echo "  Tipo:    CNAME"
        echo "  Nombre:  developers (o developers.apunto.io)"
        echo "  Valor:   apunto-io.github.io"
        echo "  TTL:     3600 (1 hora)"
        echo ""
        ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DESPUÉS DE CONFIGURAR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Espera 5-30 minutos para propagación DNS"
echo ""
echo "2. Verifica que el DNS esté configurado:"
echo "   ./check-dns.sh"
echo ""
echo "3. Habilita HTTPS con gh CLI:"
echo "   ./enable-https.sh"
echo ""
echo "4. ¡Listo! Tu sitio estará en:"
echo "   https://developers.apunto.io"
echo ""

