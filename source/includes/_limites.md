# Límites de uso

Los límites protegen la plataforma para todas las cuentas. Están pensados para que una integración normal nunca los toque.

Límite | Valor | Alcance
------ | ----- | -------
Peticiones a la API | **300 por minuto** | Por token
Inicio de sesión (`POST /auth`) | 10 por minuto | Por IP
Inicio de sesión (`POST /auth`) | 5 cada 5 minutos | Por correo
Registros por página | 100 | Por petición (`per_page`)

Al superar un límite la respuesta es **429** con el header `Retry-After` (segundos) y este cuerpo:

> Respuesta 429

```json
{
  "error": "rate_limited",
  "message": "Demasiadas peticiones al API. Espera 60 segundos e intenta de nuevo.",
  "retry_after": 60
}
```

## Buenas prácticas

- **Pide solo lo que cambió.** Una [sincronización incremental](#sincronizacion-incremental) cada pocos minutos consume una fracción del límite; recorrer toda la cuenta cada vez, no.
- **Usa `per_page=100`** en cargas y sincronizaciones: menos peticiones por el mismo resultado.
- **Un token por integración.** El límite es por token, así que dos sistemas no se estorban si cada uno tiene el suyo.
- **No consultes en ciclo cerrado.** Si esperas un cambio, consulta cada pocos minutos en vez de cada segundo.
- **Respeta `Retry-After`** y no reintentes de inmediato (ver [Qué hacer con cada error](#que-hacer-con-cada-error)).

<aside class="notice">¿Necesitas una carga inicial grande o un volumen mayor de forma sostenida? Escríbenos a soporte antes de lanzarla y lo revisamos con tu caso.</aside>
