#!/bin/bash
# Script para configurar DNS en GoDaddy usando su API

echo "🌐 Configuración de DNS en GoDaddy para developers.apunto.io"
echo "=============================================================="
echo ""

# Verificar que tenemos los tokens
if [ -z "$GODADDY_API_KEY" ] || [ -z "$GODADDY_API_SECRET" ]; then
    echo "❌ Error: Variables de entorno no configuradas"
    echo ""
    echo "Necesitas configurar tus credenciales de GoDaddy:"
    echo ""
    echo "1. Obtén tu API Key de GoDaddy:"
    echo "   https://developer.godaddy.com/keys"
    echo ""
    echo "2. Exporta las variables:"
    echo "   export GODADDY_API_KEY='tu_api_key'"
    echo "   export GODADDY_API_SECRET='tu_api_secret'"
    echo ""
    echo "3. Vuelve a ejecutar este script"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 OPCIÓN FÁCIL: Configuración Manual"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1. Ve a: https://dcc.godaddy.com"
    echo "2. My Products → DNS"
    echo "3. Selecciona: apunto.io"
    echo "4. Click 'Add' en DNS Records"
    echo "5. Configura:"
    echo "   Type: CNAME"
    echo "   Name: developers"
    echo "   Value: apunto-io.github.io"
    echo "   TTL: 1 Hour"
    echo "6. Click 'Save'"
    echo ""
    exit 1
fi

echo "✅ Credenciales encontradas"
echo ""

# Verificar si el registro ya existe
echo "🔍 Verificando si el registro CNAME ya existe..."
EXISTING=$(curl -s -X GET \
  "https://api.godaddy.com/v1/domains/apunto.io/records/CNAME/developers" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json")

if echo "$EXISTING" | grep -q "apunto-io.github.io"; then
    echo "✅ El registro CNAME ya existe y está configurado correctamente"
    echo ""
    echo "Ejecuta para verificar:"
    echo "  ./check-dns.sh"
    exit 0
fi

echo "📝 Creando registro CNAME..."
echo ""

# Crear/actualizar el registro CNAME
RESPONSE=$(curl -s -X PUT \
  "https://api.godaddy.com/v1/domains/apunto.io/records/CNAME/developers" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d '[{
    "data": "apunto-io.github.io",
    "ttl": 3600
  }]' \
  -w "\nHTTP_CODE:%{http_code}")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)

if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ ¡Registro CNAME creado exitosamente!"
    echo ""
    echo "Configuración aplicada:"
    echo "  Tipo:    CNAME"
    echo "  Nombre:  developers"
    echo "  Valor:   apunto-io.github.io"
    echo "  TTL:     3600 (1 hora)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⏳ PRÓXIMOS PASOS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1. Espera 5-30 minutos para propagación DNS"
    echo ""
    echo "2. Verifica el DNS:"
    echo "   ./check-dns.sh"
    echo ""
    echo "3. Habilita HTTPS (cuando DNS esté listo):"
    echo "   ./enable-https.sh"
    echo ""
    echo "4. ¡Listo!"
    echo "   https://developers.apunto.io"
    echo ""
else
    echo "❌ Error al crear el registro"
    echo ""
    echo "Respuesta del servidor:"
    echo "$RESPONSE" | grep -v "HTTP_CODE"
    echo ""
    echo "Código HTTP: $HTTP_CODE"
    echo ""
    echo "Verifica:"
    echo "  - Que tus credenciales API sean correctas"
    echo "  - Que tengas permisos para modificar DNS"
    echo "  - Que el dominio apunto.io esté activo"
    echo ""
    echo "O configura manualmente en:"
    echo "  https://dcc.godaddy.com"
    exit 1
fi

