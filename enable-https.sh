#!/bin/bash
# Script para habilitar HTTPS en GitHub Pages

echo "🔒 Habilitando HTTPS para developers.apunto.io"
echo "=================================================="
echo ""

# Verificar que gh esté instalado
if ! command -v gh &> /dev/null; then
    echo "❌ Error: 'gh' CLI no está instalado"
    echo "   Instala con: brew install gh"
    exit 1
fi

# Verificar DNS primero
echo "📡 Verificando DNS..."
DNS_RESULT=$(dig developers.apunto.io CNAME +short 2>/dev/null)
if [ -z "$DNS_RESULT" ]; then
    echo "❌ DNS no está configurado o no ha propagado"
    echo ""
    echo "Por favor configura el registro DNS primero:"
    echo "   Tipo:    CNAME"
    echo "   Nombre:  developers"
    echo "   Valor:   apunto-io.github.io."
    echo ""
    echo "Espera 5-30 minutos para la propagación y vuelve a ejecutar este script."
    exit 1
else
    echo "✅ DNS configurado correctamente: $DNS_RESULT"
fi
echo ""

# Verificar estado actual de HTTPS
echo "🔍 Verificando estado actual de HTTPS..."
HTTPS_STATUS=$(gh api repos/apunto-io/api-docs/pages --jq .https_enforced 2>/dev/null)
if [ "$HTTPS_STATUS" == "true" ]; then
    echo "✅ HTTPS ya está habilitado"
    exit 0
fi
echo ""

# Intentar habilitar HTTPS
echo "🚀 Intentando habilitar HTTPS..."
RESPONSE=$(gh api --method PUT repos/apunto-io/api-docs/pages --input - <<'EOF' 2>&1
{
  "cname": "developers.apunto.io",
  "https_enforced": true,
  "source": {
    "branch": "gh-pages",
    "path": "/"
  }
}
EOF
)

# Verificar el resultado
if echo "$RESPONSE" | grep -q "certificate does not exist"; then
    echo "⏳ El certificado SSL aún no está listo"
    echo ""
    echo "Esto es normal si acabas de configurar el DNS."
    echo "GitHub está verificando tu dominio y generando el certificado."
    echo ""
    echo "Espera 5-15 minutos más y vuelve a ejecutar:"
    echo "   ./enable-https.sh"
    echo ""
    echo "💡 Puedes verificar el estado con:"
    echo "   ./check-dns.sh"
    exit 1
elif echo "$RESPONSE" | grep -q "https_enforced"; then
    echo "✅ ¡HTTPS habilitado exitosamente!"
    echo ""
    echo "Tu sitio ahora está disponible en:"
    echo "   https://developers.apunto.io"
    echo ""
    echo "GitHub redirigirá automáticamente HTTP a HTTPS."
else
    echo "❌ Error inesperado:"
    echo "$RESPONSE"
    exit 1
fi
echo ""

# Verificar estado final
echo "📊 Estado final:"
gh api repos/apunto-io/api-docs/pages --jq '{
    "URL": .html_url,
    "HTTPS habilitado": .https_enforced,
    "Estado del dominio": .protected_domain_state
}' | sed 's/[{}]//g' | sed 's/,//g' | sed 's/"//g'

echo ""
echo "=================================================="
echo "✅ Configuración completa"

