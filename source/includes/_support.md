# Soporte

Si tienes preguntas o necesitas asistencia con la API de Apunto:

- **Email:** soporte@apunto.com
- **Documentación:** https://docs.apunto.com
- **Página de Estado:** https://status.apunto.com

## Versionado de la API

La versión actual de la API es **v1**. Todos los endpoints tienen el prefijo `/api/v1/`.

Mantendremos compatibilidad hacia atrás dentro de las versiones principales. Los cambios que rompan compatibilidad resultarán en una nueva versión de la API.

## Registro de Cambios

### Versión 1.0 (2024-01-15)
- Lanzamiento inicial de la API
- Soporte para operaciones, servicios, tareas y comentarios
- Soporte para contactos y direcciones
- Autenticación con Bearer token
- Limitación de tasa y paginación
- Sistema de webhooks

## Solicitar Nuevas Funcionalidades

¿Necesitas un endpoint que no está disponible? Contáctanos en soporte@apunto.com con:

1. Descripción del endpoint o funcionalidad
2. Caso de uso específico
3. Datos de ejemplo que necesitas enviar/recibir
4. Volumen estimado de peticiones

## Reportar Problemas

Si encuentras un bug o problema con la API:

1. Verifica que estés usando la versión más reciente
2. Revisa esta documentación para confirmar el uso correcto
3. Contacta a soporte@apunto.com con:
   - Descripción del problema
   - Petición y respuesta completas (sin datos sensibles)
   - Timestamp del error
   - Tu ID de cuenta

## Bibliotecas y SDKs

Actualmente no tenemos SDKs oficiales, pero la API es compatible con cualquier cliente HTTP estándar.

### Clientes Recomendados

- **Ruby**: [HTTParty](https://github.com/jnunemaker/httparty), [Faraday](https://github.com/lostisland/faraday)
- **Python**: [Requests](https://requests.readthedocs.io/)
- **JavaScript/Node.js**: [Axios](https://axios-http.com/), [node-fetch](https://github.com/node-fetch/node-fetch)
- **PHP**: [Guzzle](https://docs.guzzlephp.org/)

## Ejemplos de Integración

¿Tienes ejemplos de integración que quieres compartir con la comunidad? Envíanoslos a soporte@apunto.com

## Términos de Uso

Al usar la API de Apunto, aceptas:

1. No exceder los límites de tasa establecidos
2. No intentar acceder a recursos de otras cuentas
3. Mantener tus tokens de API seguros
4. Usar la API de acuerdo con nuestros Términos de Servicio

## SLA (Acuerdo de Nivel de Servicio)

- **Disponibilidad**: 99.9% uptime mensual
- **Tiempo de respuesta**: < 500ms para el 95% de las peticiones
- **Ventana de mantenimiento**: Sábados 2:00-4:00 AM (tiempo del servidor)

