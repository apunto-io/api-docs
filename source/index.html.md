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

- **Operaciones**: Gestión completa de operaciones de freight forwarding
- **Servicios**: Control de servicios de transporte marítimo, aéreo, terrestre y aduanas
- **Tareas**: Creación y seguimiento de tareas asociadas a operaciones y servicios
- **Comentarios**: Sistema de comunicación y notas
- **Contactos**: Gestión de clientes, proveedores y prospectos
- **Direcciones**: Administración de ubicaciones para embarques y facturación
- **Webhooks**: Notificaciones en tiempo real
- **Autenticación Segura**: Tokens de API con Bearer authentication

## Versionado de la API

La versión actual de la API es **v1**. Todos los endpoints tienen el prefijo `/api/v1/`.

Mantendremos compatibilidad hacia atrás dentro de las versiones principales. Los cambios que rompan compatibilidad resultarán en una nueva versión de la API.

## Soporte

Si tienes preguntas o necesitas asistencia con la API de Apunto:

- **Email:** soporte@apunto.com
- **Documentación:** https://docs.apunto.com
- **Página de Estado:** https://status.apunto.com

## Registro de Cambios

### Versión 1.0 (2024-01-15)
- Lanzamiento inicial de la API
- Soporte para operaciones, servicios, tareas y comentarios
- Gestión de contactos y direcciones
- Autenticación con Bearer token
- Limitación de tasa y paginación
- Sistema de webhooks
