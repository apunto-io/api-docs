# Limitación de Tasa

La API implementa limitación de tasa para garantizar uso justo y estabilidad del sistema.

## Límites

- **Estándar:** 1000 peticiones por hora por token
- **Ráfaga:** 100 peticiones por minuto por token

## Headers de Respuesta

Header | Descripción
------ | -----------
X-RateLimit-Limit | Máximo de peticiones por hora
X-RateLimit-Remaining | Peticiones restantes
X-RateLimit-Reset | Timestamp de reinicio

## Respuesta al Exceder Límites

```json
{
  "error": "Límite de tasa excedido",
  "message": "Has excedido el límite. Intenta más tarde.",
  "retry_after": 3600
}
```

Código de Estado: `429 Too Many Requests`
