#!/bin/bash
# Script para verificar el estado de DNS y GitHub Pages

echo "🔍 Verificando configuración de developers.apunto.io"
echo "=================================================="
echo ""

# Verificar DNS
echo "📡 Estado DNS:"
DNS_RESULT=$(dig developers.apunto.io CNAME +short 2>/dev/null)
if [ -z "$DNS_RESULT" ]; then
    echo "❌ DNS no configurado o no propagado aún"
    echo "   Configura un registro CNAME: developers → apunto-io.github.io"
else
    echo "✅ DNS configurado: $DNS_RESULT"
fi
echo ""

# Verificar GitHub Pages
echo "🌐 Estado GitHub Pages:"
if command -v gh &> /dev/null; then
    gh api repos/apunto-io/api-docs/pages --jq '{
        "Estado": .status,
        "URL": .html_url,
        "Dominio personalizado": .cname,
        "HTTPS habilitado": .https_enforced,
        "Estado del dominio": .protected_domain_state
    }' 2>/dev/null | sed 's/[{}]//g' | sed 's/,//g' | sed 's/"//g'
else
    echo "⚠️  Instala 'gh' CLI para ver el estado: brew install gh"
fi
echo ""

# Test de conectividad
echo "🌍 Test de conectividad:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://developers.apunto.io 2>/dev/null || echo "000")
if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Sitio accesible en http://developers.apunto.io (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" == "000" ]; then
    echo "❌ No se puede conectar (DNS probablemente no propagado)"
else
    echo "⚠️  Respuesta HTTP $HTTP_CODE"
fi

HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://developers.apunto.io 2>/dev/null || echo "000")
if [ "$HTTPS_CODE" == "200" ]; then
    echo "✅ Sitio accesible en https://developers.apunto.io (HTTPS $HTTPS_CODE)"
elif [ "$HTTPS_CODE" == "000" ]; then
    echo "⏳ HTTPS aún no disponible (esperando verificación DNS)"
else
    echo "⚠️  Respuesta HTTPS $HTTPS_CODE"
fi
echo ""

# Último build
echo "🔨 Último build:"
if command -v gh &> /dev/null; then
    gh api repos/apunto-io/api-docs/pages/builds/latest --jq '{
        "Estado": .status,
        "Fecha": .updated_at,
        "Duración": (.duration / 1000),
        "Error": .error.message
    }' 2>/dev/null | sed 's/[{}]//g' | sed 's/,//g' | sed 's/"//g'
fi
echo ""

echo "=================================================="
echo "💡 Comandos útiles:"
echo "   ./deploy.sh           - Actualizar el sitio"
echo "   ./check-dns.sh        - Verificar estado (este script)"
echo "   ./enable-https.sh     - Habilitar HTTPS (cuando DNS esté listo)"
echo "   gh api repos/apunto-io/api-docs/pages  - Ver configuración completa"
echo ""

# Verificar si se puede habilitar HTTPS
if [ ! -z "$DNS_RESULT" ] && command -v gh &> /dev/null; then
    HTTPS_STATUS=$(gh api repos/apunto-io/api-docs/pages --jq .https_enforced 2>/dev/null)
    if [ "$HTTPS_STATUS" == "false" ]; then
        echo "🔒 HTTPS disponible para habilitar:"
        echo "   ./enable-https.sh"
    fi
fi

