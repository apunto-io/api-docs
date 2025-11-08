#!/bin/bash
# Script para iniciar el servidor de documentación de Apunto API

echo "🚀 Iniciando servidor de documentación Apunto API..."
echo ""
echo "La documentación estará disponible en: http://localhost:4567"
echo "Presiona Ctrl+C para detener el servidor"
echo ""

bundle exec middleman server
