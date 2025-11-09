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
  - contacts
  - addresses
  - messages
  - to_dos
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

**URL Base:** `https://control.apunto.io/api/v1`

<aside class="notice">
Para instalaciones personalizadas, la URL base será: <code>https://nombre-empresa.apunto.io/api/v1</code><br>
Donde <code>nombre-empresa</code> corresponde al subdominio de su organización.
</aside>

## Características Principales

- **Operaciones**: Gestión completa de operaciones de freight forwarding
- **Servicios**: Control de servicios de transporte marítimo, aéreo, terrestre y aduanas
- **Tareas**: Creación y seguimiento de tareas asociadas a operaciones y servicios
- **Comentarios**: Sistema de comunicación y notas en cada recurso
- **Contactos**: Gestión de clientes, proveedores y prospectos
- **Direcciones**: Administración de ubicaciones para embarques y facturación
- **Autenticación Segura**: Tokens de API con Bearer authentication

## Paginación

Todos los endpoints que retornan listas están paginados automáticamente. Cada página contiene **25 registros** por defecto.

Puedes especificar la página deseada usando el parámetro `page`:

`GET /api/v1/operations?page=2`

La información de paginación se incluye en la respuesta JSON:

```json
{
  "operations": [...],
  "pagination": {
    "page": 2,
    "per_page": 25,
    "total": 150
  }
}
```

## Versionado de la API

La versión actual de la API es **v1**. Todos los endpoints tienen el prefijo `/api/v1/`.

Mantendremos compatibilidad hacia atrás dentro de las versiones principales. Los cambios que rompan compatibilidad resultarán en una nueva versión de la API.

## Soporte

Si tienes preguntas o necesitas asistencia con la API de Apunto:

- **Email:** soporte@apunto.com
- **Documentación:** https://docs.apunto.com
