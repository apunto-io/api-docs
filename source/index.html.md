---
title: Documentación API de Apunto

language_tabs:
  - shell: cURL
  - ruby: Ruby
  - python: Python
  - javascript: JavaScript

toc_footers:
  - <a href='https://apunto.com'>Plataforma Apunto</a>
  - <a href='https://github.com/slatedocs/slate'>Documentación hecha con Slate</a>

includes:
  - authentication
  - operations
  - services
  - tasks
  - comments
  - contacts
  - addresses
  - rate_limiting
  - pagination
  - webhooks
  - support
  - errors

search: true

code_clipboard: true

meta:
  - name: description
    content: Documentación de la API de Apunto
---

# Introducción

Bienvenido a la **API de Apunto**. Esta API te permite integrarte con la plataforma de freight forwarding de Apunto para gestionar operaciones, servicios, tareas, comentarios, contactos y direcciones de forma programática.

La API está diseñada siguiendo los principios RESTful y retorna respuestas en formato JSON. Todos los endpoints requieren autenticación mediante tokens de API.

**URL Base:** `https://tu-dominio.com/api/v1`

## Características Principales

- ✅ **Operaciones**: Gestión completa de operaciones de importación/exportación
- ✅ **Servicios**: Crear y administrar servicios de transporte (marítimo, aéreo, terrestre, aduanas)
- ✅ **Tareas**: Sistema de tareas y to-dos asociados a operaciones y servicios
- ✅ **Comentarios**: Comunicación en tiempo real en operaciones, servicios y tareas
- ✅ **Contactos**: Gestión de clientes, proveedores y prospectos
- ✅ **Direcciones**: Administración de ubicaciones de envío, facturación, puertos y aduanas
- ✅ **Autenticación Segura**: Tokens de API con soporte para 2FA
- ✅ **Rate Limiting**: Límites justos de uso de la API
- ✅ **Webhooks**: Notificaciones en tiempo real de eventos

## Convenciones

Esta documentación usa las siguientes convenciones:

- **Variables en inglés**: Los nombres de campos y parámetros se mantienen como están definidos en el código (ej. `operation_id`, `contact_id`)
- **Descripciones en español**: Toda la documentación y explicaciones están en español
- **Ejemplos de código**: Se proporcionan en 4 lenguajes (Shell/cURL, Ruby, Python, JavaScript)

## Primeros Pasos

1. **Obtén tu Token de API**: Crea un token en **Configuración → Tokens de API**
2. **Prueba la conexión**: Haz una petición GET a `/api/v1/operations`
3. **Explora los endpoints**: Navega por la documentación para conocer todos los recursos disponibles

## Respuestas de la API

Todas las respuestas de la API están en formato JSON:

```json
{
  "data": { ... },
  "pagination": { ... }
}
```

Las respuestas de error incluyen un objeto detallado:

```json
{
  "error": "Tipo de error",
  "message": "Mensaje descriptivo del error",
  "details": { ... }
}
```
