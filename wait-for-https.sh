#!/bin/bash
# Script para esperar y habilitar HTTPS automáticamente

echo "⏳ Esperando a que GitHub genere el certificado SSL..."
echo "=================================================="
echo ""

MAX_ATTEMPTS=30
ATTEMPT=1
SLEEP_TIME=30

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo "Intento $ATTEMPT de $MAX_ATTEMPTS..."
    
    # Intentar habilitar HTTPS
    RESULT=$(./enable-https.sh 2>&1)
    
    if echo "$RESULT" | grep -q "HTTPS habilitado exitosamente"; then
        echo ""
        echo "✅ ¡HTTPS HABILITADO!"
        echo ""
        echo "Tu sitio ahora está disponible en:"
        echo "🚀 https://developers.apunto.io"
        echo ""
        exit 0
    elif echo "$RESULT" | grep -q "El certificado SSL aún no está listo"; then
        echo "   ⏳ Certificado aún no listo, esperando ${SLEEP_TIME}s..."
        sleep $SLEEP_TIME
        ATTEMPT=$((ATTEMPT + 1))
    else
        echo "❌ Error inesperado:"
        echo "$RESULT"
        exit 1
    fi
done

echo ""
echo "⚠️  Timeout: El certificado no se generó en ~15 minutos"
echo ""
echo "Esto puede deberse a:"
echo "  - El DNS aún está propagando (puede tardar hasta 48h)"
echo "  - GitHub está experimentando retrasos"
echo ""
echo "Soluciones:"
echo "  1. Espera otros 15-30 minutos e intenta:"
echo "     ./enable-https.sh"
echo ""
echo "  2. Verifica en GitHub Pages:"
echo "     https://github.com/apunto-io/api-docs/settings/pages"
echo ""
echo "  3. El sitio funciona en HTTP mientras tanto:"
echo "     http://developers.apunto.io"
echo ""

