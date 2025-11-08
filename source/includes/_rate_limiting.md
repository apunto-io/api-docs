# Limitación de Tasa (Rate Limiting)

La API de Apunto implementa limitación de tasa para garantizar un uso justo y la estabilidad del sistema.

## Headers de Limitación de Tasa

Todas las respuestas de la API incluyen información sobre el límite de tasa en los headers:

Header | Descripción
------ | -----------
X-RateLimit-Limit | Número máximo de peticiones por hora
X-RateLimit-Remaining | Número de peticiones restantes en la ventana actual
X-RateLimit-Reset | Timestamp Unix cuando se reinicia el límite de tasa

## Detalles de Limitación de Tasa

- **Límite de Tasa Estándar:** 1000 peticiones por hora por token de API
- **Límite de Ráfaga:** 100 peticiones por minuto por token de API

## Exceder los Límites de Tasa

Cuando excedes el límite de tasa, la API responderá con:

```json
{
  "error": "Límite de tasa excedido",
  "message": "Has excedido el límite de tasa. Por favor, intenta de nuevo más tarde.",
  "retry_after": 3600
}
```

Código de Estado HTTP: `429 Too Many Requests`

## Mejores Prácticas

1. **Monitorea los headers**: Revisa `X-RateLimit-Remaining` para saber cuántas peticiones te quedan
2. **Implementa backoff exponencial**: Cuando recibas un 429, espera antes de reintentar
3. **Cachea respuestas**: Reduce peticiones almacenando datos que no cambian frecuentemente
4. **Usa webhooks**: En lugar de hacer polling constante, usa webhooks para notificaciones en tiempo real
5. **Batch de operaciones**: Agrupa múltiples operaciones cuando sea posible

