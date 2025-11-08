---
title: Apunto API Documentation

language_tabs:
  - shell: cURL
  - ruby: Ruby
  - python: Python
  - javascript: JavaScript

toc_footers:
  - <a href='https://apunto.com'>Apunto Platform</a>
  - <a href='https://github.com/slatedocs/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true

code_clipboard: true

meta:
  - name: description
    content: Documentation for the Apunto API
---

# Introduction

Welcome to the **Apunto API**! This API allows you to integrate with the Apunto freight forwarding platform to manage operations, services, tasks, and comments programmatically.

The API is designed following RESTful principles and returns JSON responses. All endpoints require authentication using API tokens.

**Base URL:** `https://your-domain.com/api/v1`

# Authentication

## Overview

The Apunto API uses Bearer token authentication. To access the API, you need to:

1. Create an API token in your account settings
2. Include the token in the `Authorization` header of each request

## Creating an API Token

API tokens can be created through the web interface:

1. Navigate to **Settings** → **API Tokens**
2. Click **New API Token**
3. Give your token a descriptive name
4. Copy the generated token (it will only be shown once)

## Using the API Token

> To authorize, include the token in the Authorization header:

```shell
curl "https://your-domain.com/api/v1/operations" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/operations")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://your-domain.com/api/v1/operations',
    headers=headers
)
```

```javascript
const axios = require('axios');

const config = {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
};

axios.get('https://your-domain.com/api/v1/operations', config)
  .then(response => console.log(response.data))
  .catch(error => console.error(error));
```

Include your API token in the `Authorization` header of all API requests:

`Authorization: Bearer YOUR_API_TOKEN`

<aside class="notice">
Replace <code>YOUR_API_TOKEN</code> with your actual API token.
</aside>

<aside class="warning">
Keep your API tokens secure! They provide full access to your account.
</aside>

## Login (Alternative Authentication)

If you need to authenticate programmatically and obtain a token:

```shell
curl -X POST "https://your-domain.com/api/v1/auth" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "your_password"
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/auth")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request.body = JSON.dump({
  "email" => "user@example.com",
  "password" => "your_password"
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests
import json

url = 'https://your-domain.com/api/v1/auth'
payload = {
    'email': 'user@example.com',
    'password': 'your_password'
}

response = requests.post(url, json=payload)
token = response.json()['token']
```

```javascript
const axios = require('axios');

axios.post('https://your-domain.com/api/v1/auth', {
  email: 'user@example.com',
  password: 'your_password'
})
.then(response => {
  const token = response.data.token;
  console.log('Token:', token);
})
.catch(error => console.error(error));
```

> Response:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### HTTP Request

`POST /api/v1/auth`

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
email | string | Yes | User's email address
password | string | Yes | User's password
otp_attempt | string | No | OTP code (if 2FA is enabled)

### Response

Returns an object containing the API token.

# Operations

Operations represent the main freight forwarding transactions in the system. Each operation can contain multiple services.

## Operation Object

```json
{
  "id": 123,
  "identification": "IMP-MEX-001-2024",
  "number": 1,
  "kind": "importation",
  "mode": "maritime",
  "status": "active",
  "regime": "general",
  "service_scope": "door_to_port_cy",
  "incoterm": "FOB",
  "goods_description": "Electronic components",
  "client_ref": "CLIENT-REF-001",
  "quote_external_id": "QUOTE-123",
  "nomenclature": "8471.30",
  "contact_id": 456,
  "contact": {
    "id": 456,
    "name": "ABC Trading Company",
    "alias": "ABC Trading"
  },
  "operational_agent_id": 789,
  "operational_agent": {
    "id": 789,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "currency_id": 1,
  "currency": {
    "id": 1,
    "code": "USD",
    "symbol": "$"
  },
  "income_amount": 15000.00,
  "expense_amount": 12000.00,
  "profit_amount": 3000.00,
  "profit_percentage": 20.0,
  "tags": ["urgent", "high-value"],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T14:20:00Z",
  "closed_at": null,
  "finished_at": null,
  "invoice_progress": {
    "total": 10,
    "invoiced": 7,
    "pending": 3,
    "percentage": 70.0
  },
  "bill_progress": {
    "total": 10,
    "billed": 8,
    "pending": 2,
    "percentage": 80.0
  }
}
```

### Attributes

Attribute | Type | Description
--------- | ---- | -----------
id | integer | Unique identifier
identification | string | Human-readable operation ID
number | integer | Sequential number for the operation
kind | string | Type of operation: `importation`, `exportation`, `domestic`, `crosstrade`, `transportation`, `consulting`, `export_trading_company`, `import_trading_company`
mode | string | Transport mode: `land`, `aerial`, `maritime`
status | string | Current status: `confirmed`, `active`, `finished`, `closed`, `canceled`
regime | string | Customs regime
service_scope | string | Service scope (e.g., `door_to_port_cy`, `port_cy_to_door`, `door_to_door`)
incoterm | string | Incoterm used (e.g., FOB, CIF, EXW)
goods_description | string | Description of goods being shipped
client_ref | string | Client's reference number
quote_external_id | string | External quote reference
nomenclature | string | HS code or tariff classification
contact_id | integer | ID of the client contact
operational_agent_id | integer | ID of the assigned operational agent
currency_id | integer | ID of the operation's currency
income_amount | decimal | Total income amount
expense_amount | decimal | Total expense amount
profit_amount | decimal | Calculated profit
profit_percentage | decimal | Profit percentage
tags | array | Array of tag names
created_at | datetime | Creation timestamp
updated_at | datetime | Last update timestamp
closed_at | datetime | Closing timestamp (if closed)
finished_at | datetime | Finish timestamp (if finished)

## List Operations

```shell
curl "https://your-domain.com/api/v1/operations" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/operations")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/operations',
    headers=headers
)
operations = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/operations', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "operations": [
    {
      "id": 123,
      "identification": "IMP-MEX-001-2024",
      "kind": "importation",
      "mode": "maritime",
      "status": "active",
      "profit_amount": 3000.00,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 50,
    "per_page": 10
  }
}
```

Retrieves a list of all operations for the authenticated account.

### HTTP Request

`GET /api/v1/operations`

### Query Parameters

Parameter | Type | Default | Description
--------- | ---- | ------- | -----------
page | integer | 1 | Page number for pagination
per_page | integer | 25 | Number of records per page
status | string | all | Filter by status: `confirmed`, `active`, `finished`, `closed`, `canceled`
kind | string | all | Filter by operation kind
mode | string | all | Filter by transport mode
sort | string | created_at | Sort field
direction | string | desc | Sort direction: `asc` or `desc`

## Get a Specific Operation

```shell
curl "https://your-domain.com/api/v1/operations/123" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/operations/123")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/operations/123',
    headers=headers
)
operation = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/operations/123', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 123,
  "identification": "IMP-MEX-001-2024",
  "number": 1,
  "kind": "importation",
  "mode": "maritime",
  "status": "active",
  "contact": {
    "id": 456,
    "name": "ABC Trading Company"
  },
  "services": [
    {
      "id": 789,
      "identification": "SRV-001",
      "mode": "maritime",
      "status": "active"
    }
  ]
}
```

Retrieves the details of a specific operation.

### HTTP Request

`GET /api/v1/operations/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the operation to retrieve

## Create an Operation

```shell
curl -X POST "https://your-domain.com/api/v1/operations" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "kind": "importation",
      "mode": "maritime",
      "contact_id": 456,
      "currency_id": 1,
      "goods_description": "Electronic components",
      "client_ref": "CLIENT-REF-001",
      "incoterm": "FOB",
      "service_scope": "door_to_port_cy",
      "operational_agent_id": 789,
      "tags": ["urgent", "high-value"]
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/operations")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "operation" => {
    "kind" => "importation",
    "mode" => "maritime",
    "contact_id" => 456,
    "currency_id" => 1,
    "goods_description" => "Electronic components"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'operation': {
        'kind': 'importation',
        'mode': 'maritime',
        'contact_id': 456,
        'currency_id': 1,
        'goods_description': 'Electronic components',
        'client_ref': 'CLIENT-REF-001'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/operations',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  operation: {
    kind: 'importation',
    mode: 'maritime',
    contact_id: 456,
    currency_id: 1,
    goods_description: 'Electronic components',
    client_ref: 'CLIENT-REF-001'
  }
};

axios.post('https://your-domain.com/api/v1/operations', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 124,
  "identification": "IMP-MEX-002-2024",
  "kind": "importation",
  "mode": "maritime",
  "status": "confirmed",
  "created_at": "2024-01-16T10:00:00Z"
}
```

Creates a new operation.

### HTTP Request

`POST /api/v1/operations`

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
kind | string | Yes | Operation type
mode | string | Yes | Transport mode
contact_id | integer | Yes | Client contact ID
currency_id | integer | Yes | Currency ID
goods_description | string | No | Description of goods
client_ref | string | No | Client reference
quote_external_id | string | No | External quote reference
incoterm | string | No | Incoterm (FOB, CIF, etc.)
service_scope | string | No | Service scope
operational_agent_id | integer | No | Assigned agent ID
nomenclature | string | No | HS code
regime | string | No | Customs regime
tags | array | No | Array of tag names

## Update an Operation

```shell
curl -X PATCH "https://your-domain.com/api/v1/operations/123" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": {
      "status": "active",
      "operational_agent_id": 789,
      "goods_description": "Updated description"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/operations/123")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "operation" => {
    "status" => "active",
    "operational_agent_id" => 789
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'operation': {
        'status': 'active',
        'operational_agent_id': 789
    }
}

response = requests.patch(
    'https://your-domain.com/api/v1/operations/123',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  operation: {
    status: 'active',
    operational_agent_id: 789
  }
};

axios.patch('https://your-domain.com/api/v1/operations/123', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 123,
  "identification": "IMP-MEX-001-2024",
  "status": "active",
  "operational_agent_id": 789,
  "updated_at": "2024-01-16T11:00:00Z"
}
```

Updates an existing operation.

### HTTP Request

`PATCH /api/v1/operations/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the operation to update

### Request Body

All operation fields are optional. Only include the fields you want to update.

<aside class="notice">
Note: Some fields like <code>kind</code>, <code>mode</code>, and <code>contact_id</code> can only be edited when the operation is in <code>confirmed</code> status.
</aside>

# Services

Services represent individual transport or customs services within an operation. Each service can have its own routing, pricing, and tracking information.

## Service Object

```json
{
  "id": 789,
  "identification": "SRV-001-2024",
  "operation_id": 123,
  "mode": "maritime",
  "status": "active",
  "shipment_type": "fcl",
  "shipment_kind": "international",
  "supplier_id": 111,
  "supplier": {
    "id": 111,
    "name": "Ocean Freight Inc",
    "alias": "Ocean Freight"
  },
  "service_agent_id": 222,
  "service_agent": {
    "id": 222,
    "name": "Jane Smith",
    "email": "jane@example.com"
  },
  "bl": "BL123456",
  "booking": "BOOK789",
  "guide_number": "GN123",
  "flight_number": null,
  "airline_name": null,
  "shipping_line_name": "Maersk",
  "income_amount": 8000.00,
  "expense_amount": 6000.00,
  "profit_amount": 2000.00,
  "tags": ["priority"],
  "created_at": "2024-01-15T11:00:00Z",
  "updated_at": "2024-01-15T15:30:00Z"
}
```

### Attributes

Attribute | Type | Description
--------- | ---- | -----------
id | integer | Unique identifier
identification | string | Human-readable service ID
operation_id | integer | Parent operation ID
mode | string | Transport mode: `land`, `aerial`, `maritime`, `customs`
status | string | Current status: `active`, `finished`, `closed`, `canceled`
shipment_type | string | Shipment type (e.g., `fcl`, `lcl`, `air`)
shipment_kind | string | Shipment kind: `national`, `international`
supplier_id | integer | Supplier/carrier contact ID
service_agent_id | integer | Assigned service agent ID
bl | string | Bill of Lading number
booking | string | Booking reference
guide_number | string | Guide number
flight_number | string | Flight number (for air services)
airline_name | string | Airline name
shipping_line_name | string | Shipping line name
pedimento | string | Pedimento number (customs)
carta_porte | string | Carta Porte number (land)
income_amount | decimal | Total income
expense_amount | decimal | Total expenses
profit_amount | decimal | Calculated profit
tags | array | Service tags

## List Services

```shell
curl "https://your-domain.com/api/v1/services" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/services")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/services',
    headers=headers
)
services = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/services', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "services": [
    {
      "id": 789,
      "identification": "SRV-001-2024",
      "operation_id": 123,
      "mode": "maritime",
      "status": "active",
      "created_at": "2024-01-15T11:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 30,
    "per_page": 10
  }
}
```

Retrieves a list of all services for the authenticated account.

### HTTP Request

`GET /api/v1/services`

### Query Parameters

Parameter | Type | Default | Description
--------- | ---- | ------- | -----------
page | integer | 1 | Page number
per_page | integer | 25 | Records per page
operation_id | integer | null | Filter by operation ID
mode | string | all | Filter by transport mode
status | string | all | Filter by status
sort | string | created_at | Sort field
direction | string | desc | Sort direction

## Get a Specific Service

```shell
curl "https://your-domain.com/api/v1/services/789" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/services/789")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/services/789',
    headers=headers
)
service = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/services/789', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 789,
  "identification": "SRV-001-2024",
  "operation_id": 123,
  "mode": "maritime",
  "status": "active",
  "shipment_type": "fcl",
  "service_routes": [
  {
    "id": 1,
      "address_kind": "origin",
      "address_type": "shipping",
      "address": {
        "name": "Shanghai Port",
        "city": "Shanghai",
        "country": "China"
      }
    }
  ]
}
```

Retrieves the details of a specific service.

### HTTP Request

`GET /api/v1/services/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the service to retrieve

## Create a Service

```shell
curl -X POST "https://your-domain.com/api/v1/services" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "operation_id": 123,
      "mode": "maritime",
      "shipment_type": "fcl",
      "shipment_kind": "international",
      "supplier_id": 111,
      "service_agent_id": 222,
      "bl": "BL123456",
      "booking": "BOOK789",
      "shipping_line_name": "Maersk"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/services")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "service" => {
    "operation_id" => 123,
    "mode" => "maritime",
    "shipment_type" => "fcl",
    "shipment_kind" => "international",
    "supplier_id" => 111
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'service': {
        'operation_id': 123,
        'mode': 'maritime',
        'shipment_type': 'fcl',
        'shipment_kind': 'international',
        'supplier_id': 111,
        'bl': 'BL123456'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/services',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  service: {
    operation_id: 123,
    mode: 'maritime',
    shipment_type: 'fcl',
    shipment_kind: 'international',
    supplier_id: 111,
    bl: 'BL123456'
  }
};

axios.post('https://your-domain.com/api/v1/services', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 790,
  "identification": "SRV-002-2024",
  "operation_id": 123,
  "mode": "maritime",
  "status": "active",
  "created_at": "2024-01-16T10:30:00Z"
}
```

Creates a new service within an operation.

### HTTP Request

`POST /api/v1/services`

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
operation_id | integer | Yes | Parent operation ID
mode | string | Yes | Transport mode
shipment_type | string | Yes | Shipment type
shipment_kind | string | Yes | Shipment kind
supplier_id | integer | No | Supplier/carrier ID
service_agent_id | integer | No | Service agent ID
bl | string | No | Bill of Lading
booking | string | No | Booking reference
guide_number | string | No | Guide number
flight_number | string | No | Flight number
airline_name | string | No | Airline name
shipping_line_name | string | No | Shipping line
pedimento | string | No | Pedimento (customs)
tags | array | No | Service tags

## Update a Service

```shell
curl -X PATCH "https://your-domain.com/api/v1/services/789" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "status": "finished",
      "bl": "BL123456-UPDATED",
      "guide_number": "GN456"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/services/789")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "service" => {
    "status" => "finished",
    "bl" => "BL123456-UPDATED"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'service': {
        'status': 'finished',
        'bl': 'BL123456-UPDATED'
    }
}

response = requests.patch(
    'https://your-domain.com/api/v1/services/789',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  service: {
    status: 'finished',
    bl: 'BL123456-UPDATED'
  }
};

axios.patch('https://your-domain.com/api/v1/services/789', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 789,
  "identification": "SRV-001-2024",
  "status": "finished",
  "bl": "BL123456-UPDATED",
  "updated_at": "2024-01-16T12:00:00Z"
}
```

Updates an existing service.

### HTTP Request

`PATCH /api/v1/services/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the service to update

### Request Body

All service fields are optional. Only include the fields you want to update.

# Tasks (To-Dos)

Tasks (also called To-Dos) are work items that can be attached to operations, services, or other entities. They help track activities and requirements.

## Task Object

```json
{
  "id": 456,
  "title": "Upload shipping documents",
  "description": "Upload all required shipping documents before departure",
  "type": null,
  "todoable_type": "Operation",
  "todoable_id": 123,
  "owner_id": 789,
  "owner": {
    "id": 789,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "completed": false,
  "completed_at": null,
  "completed_by_id": null,
  "rejected": false,
  "required": true,
  "start_at": "2024-01-20T09:00:00Z",
  "end_at": "2024-01-25T17:00:00Z",
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

### Attributes

Attribute | Type | Description
--------- | ---- | -----------
id | integer | Unique identifier
title | string | Task title
description | text | Detailed description (supports rich text)
type | string | Task type (`PodToDo`, `ArrivalToDo`, or null for regular tasks)
todoable_type | string | Type of parent record (`Operation`, `Service`, etc.)
todoable_id | integer | ID of parent record
owner_id | integer | Task owner/creator ID
completed | boolean | Whether task is completed
completed_at | datetime | Completion timestamp
completed_by_id | integer | User who completed the task
rejected | boolean | Whether task was rejected (for approval tasks)
required | boolean | Whether task is mandatory
start_at | datetime | Scheduled start time
end_at | datetime | Due date
created_at | datetime | Creation timestamp
updated_at | datetime | Last update timestamp

## List Tasks

```shell
curl "https://your-domain.com/api/v1/tasks" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/tasks")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/tasks',
    headers=headers
)
tasks = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/tasks', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "tasks": [
    {
      "id": 456,
      "title": "Upload shipping documents",
      "todoable_type": "Operation",
      "todoable_id": 123,
      "completed": false,
      "required": true,
      "end_at": "2024-01-25T17:00:00Z",
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 2,
    "total_count": 15,
    "per_page": 10
  }
}
```

Retrieves a list of tasks for the authenticated user.

### HTTP Request

`GET /api/v1/tasks`

### Query Parameters

Parameter | Type | Default | Description
--------- | ---- | ------- | -----------
page | integer | 1 | Page number
per_page | integer | 25 | Records per page
completed | boolean | false | Filter by completion status
todoable_type | string | null | Filter by parent type
todoable_id | integer | null | Filter by parent ID
required | boolean | null | Filter required tasks
overdue | boolean | null | Filter overdue tasks

## Get a Specific Task

```shell
curl "https://your-domain.com/api/v1/tasks/456" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/tasks/456")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.get(
    'https://your-domain.com/api/v1/tasks/456',
    headers=headers
)
task = response.json()
```

```javascript
const axios = require('axios');

axios.get('https://your-domain.com/api/v1/tasks/456', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 456,
  "title": "Upload shipping documents",
  "description": "Upload all required shipping documents before departure",
  "todoable_type": "Operation",
  "todoable_id": 123,
  "owner_id": 789,
  "completed": false,
  "required": true,
  "start_at": "2024-01-20T09:00:00Z",
  "end_at": "2024-01-25T17:00:00Z",
  "attachments": []
}
```

Retrieves the details of a specific task.

### HTTP Request

`GET /api/v1/tasks/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the task to retrieve

## Create a Task

```shell
curl -X POST "https://your-domain.com/api/v1/tasks" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "Review shipment documents",
      "description": "Check all documents for accuracy",
      "todoable_type": "Operation",
      "todoable_id": 123,
      "required": true,
      "start_at": "2024-01-20T09:00:00Z",
      "end_at": "2024-01-25T17:00:00Z"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/tasks")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "task" => {
    "title" => "Review shipment documents",
    "todoable_type" => "Operation",
    "todoable_id" => 123,
    "required" => true
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'task': {
        'title': 'Review shipment documents',
        'description': 'Check all documents for accuracy',
        'todoable_type': 'Operation',
        'todoable_id': 123,
        'required': True,
        'end_at': '2024-01-25T17:00:00Z'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/tasks',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  task: {
    title: 'Review shipment documents',
    description: 'Check all documents for accuracy',
    todoable_type: 'Operation',
    todoable_id: 123,
    required: true,
    end_at: '2024-01-25T17:00:00Z'
  }
};

axios.post('https://your-domain.com/api/v1/tasks', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 457,
  "title": "Review shipment documents",
  "todoable_type": "Operation",
  "todoable_id": 123,
  "completed": false,
  "required": true,
  "created_at": "2024-01-16T10:00:00Z"
}
```

Creates a new task.

### HTTP Request

`POST /api/v1/tasks`

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
title | string | Yes | Task title
description | text | No | Task description
todoable_type | string | Yes | Parent type (`Operation`, `Service`, etc.)
todoable_id | integer | Yes | Parent record ID
required | boolean | No | Is task required (default: false)
start_at | datetime | No | Start date/time
end_at | datetime | No | Due date/time

## Update a Task

```shell
curl -X PATCH "https://your-domain.com/api/v1/tasks/456" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "completed": true,
      "description": "All documents uploaded successfully"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/tasks/456")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "task" => {
    "completed" => true
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'task': {
        'completed': True,
        'description': 'All documents uploaded successfully'
    }
}

response = requests.patch(
    'https://your-domain.com/api/v1/tasks/456',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  task: {
    completed: true,
    description: 'All documents uploaded successfully'
  }
};

axios.patch('https://your-domain.com/api/v1/tasks/456', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 456,
  "title": "Upload shipping documents",
  "completed": true,
  "completed_at": "2024-01-16T11:30:00Z",
  "completed_by_id": 789,
  "updated_at": "2024-01-16T11:30:00Z"
}
```

Updates an existing task.

### HTTP Request

`PATCH /api/v1/tasks/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the task to update

### Request Body

All task fields are optional. Only include the fields you want to update.

# Comments (Messages)

Comments (called Messages in the system) allow users to communicate and add notes to operations, services, tasks, and other entities.

## Comment Object

```json
{
  "id": 999,
  "content": "<p>This is a comment with <strong>rich text</strong> support</p>",
  "messageable_type": "Operation",
  "messageable_id": 123,
  "owner_id": 789,
  "owner": {
    "id": 789,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar_url": "https://example.com/avatar.jpg"
  },
  "created_at": "2024-01-15T14:30:00Z",
  "updated_at": "2024-01-15T14:30:00Z",
  "edited": false
}
```

### Attributes

Attribute | Type | Description
--------- | ---- | -----------
id | integer | Unique identifier
content | text | Comment content (supports rich text HTML)
messageable_type | string | Type of parent record (`Operation`, `Service`, `ToDo`)
messageable_id | integer | ID of parent record
owner_id | integer | Comment author ID
owner | object | Author user object
created_at | datetime | Creation timestamp
updated_at | datetime | Last update timestamp
edited | boolean | Whether comment was edited

## Create a Comment on an Operation

```shell
curl -X POST "https://your-domain.com/api/v1/operations/123/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "comment": {
      "content": "Shipment has been cleared by customs"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/operations/123/comments")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "comment" => {
    "content" => "Shipment has been cleared by customs"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'comment': {
        'content': 'Shipment has been cleared by customs'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/operations/123/comments',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  comment: {
    content: 'Shipment has been cleared by customs'
  }
};

axios.post('https://your-domain.com/api/v1/operations/123/comments', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 1000,
  "content": "Shipment has been cleared by customs",
  "messageable_type": "Operation",
  "messageable_id": 123,
  "owner_id": 789,
  "created_at": "2024-01-16T10:45:00Z"
}
```

Creates a comment on an operation.

### HTTP Request

`POST /api/v1/operations/:operation_id/comments`

### URL Parameters

Parameter | Description
--------- | -----------
operation_id | The ID of the operation

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
content | text | Yes | Comment content (plain text or HTML)

## Create a Comment on a Service

```shell
curl -X POST "https://your-domain.com/api/v1/services/789/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "comment": {
      "content": "Container has arrived at the port"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/services/789/comments")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "comment" => {
    "content" => "Container has arrived at the port"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'comment': {
        'content': 'Container has arrived at the port'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/services/789/comments',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  comment: {
    content: 'Container has arrived at the port'
  }
};

axios.post('https://your-domain.com/api/v1/services/789/comments', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 1001,
  "content": "Container has arrived at the port",
  "messageable_type": "Service",
  "messageable_id": 789,
  "owner_id": 789,
  "created_at": "2024-01-16T11:00:00Z"
}
```

Creates a comment on a service.

### HTTP Request

`POST /api/v1/services/:service_id/comments`

### URL Parameters

Parameter | Description
--------- | -----------
service_id | The ID of the service

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
content | text | Yes | Comment content

## Create a Comment on a Task

```shell
curl -X POST "https://your-domain.com/api/v1/tasks/456/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "comment": {
      "content": "Documents have been reviewed and approved"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/tasks/456/comments")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "comment" => {
    "content" => "Documents have been reviewed and approved"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'comment': {
        'content': 'Documents have been reviewed and approved'
    }
}

response = requests.post(
    'https://your-domain.com/api/v1/tasks/456/comments',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  comment: {
    content: 'Documents have been reviewed and approved'
  }
};

axios.post('https://your-domain.com/api/v1/tasks/456/comments', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 1002,
  "content": "Documents have been reviewed and approved",
  "messageable_type": "ToDo",
  "messageable_id": 456,
  "owner_id": 789,
  "created_at": "2024-01-16T11:15:00Z"
}
```

Creates a comment on a task.

### HTTP Request

`POST /api/v1/tasks/:task_id/comments`

### URL Parameters

Parameter | Description
--------- | -----------
task_id | The ID of the task

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
content | text | Yes | Comment content

## List Comments

```shell
# Get comments for an operation
curl "https://your-domain.com/api/v1/operations/123/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Get comments for a service
curl "https://your-domain.com/api/v1/services/789/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Get comments for a task
curl "https://your-domain.com/api/v1/tasks/456/comments" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

# Get comments for an operation
uri = URI.parse("https://your-domain.com/api/v1/operations/123/comments")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}

# Get comments for an operation
response = requests.get(
    'https://your-domain.com/api/v1/operations/123/comments',
    headers=headers
)
comments = response.json()
```

```javascript
const axios = require('axios');

// Get comments for an operation
axios.get('https://your-domain.com/api/v1/operations/123/comments', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "comments": [
    {
      "id": 999,
      "content": "Shipment has been cleared by customs",
      "messageable_type": "Operation",
      "messageable_id": 123,
      "owner": {
        "id": 789,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "created_at": "2024-01-15T14:30:00Z",
      "edited": false
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 5,
    "per_page": 25
  }
}
```

Retrieves comments for a specific resource.

### HTTP Requests

- `GET /api/v1/operations/:operation_id/comments`
- `GET /api/v1/services/:service_id/comments`
- `GET /api/v1/tasks/:task_id/comments`

### Query Parameters

Parameter | Type | Default | Description
--------- | ---- | ------- | -----------
page | integer | 1 | Page number
per_page | integer | 25 | Records per page
sort | string | created_at | Sort field
direction | string | desc | Sort direction

## Update a Comment

```shell
curl -X PATCH "https://your-domain.com/api/v1/comments/999" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "comment": {
      "content": "Shipment has been cleared by customs - UPDATE: Now ready for pickup"
    }
  }'
```

```ruby
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://your-domain.com/api/v1/comments/999")
request = Net::HTTP::Patch.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"
request.content_type = "application/json"
request.body = JSON.dump({
  "comment" => {
    "content" => "Updated comment content"
  }
})

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
}

payload = {
    'comment': {
        'content': 'Updated comment content'
    }
}

response = requests.patch(
    'https://your-domain.com/api/v1/comments/999',
    headers=headers,
    json=payload
)
```

```javascript
const axios = require('axios');

const data = {
  comment: {
    content: 'Updated comment content'
  }
};

axios.patch('https://your-domain.com/api/v1/comments/999', data, {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN',
    'Content-Type': 'application/json'
  }
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

> Response:

```json
{
  "id": 999,
  "content": "Updated comment content",
  "messageable_type": "Operation",
  "messageable_id": 123,
  "updated_at": "2024-01-16T12:00:00Z",
  "edited": true
}
```

Updates an existing comment.

### HTTP Request

`PATCH /api/v1/comments/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the comment to update

### Request Body

Parameter | Type | Required | Description
--------- | ---- | -------- | -----------
content | text | Yes | Updated comment content

<aside class="notice">
Comments can only be edited by their author.
</aside>

## Delete a Comment

```shell
curl -X DELETE "https://your-domain.com/api/v1/comments/999" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

```ruby
require 'net/http'
require 'uri'

uri = URI.parse("https://your-domain.com/api/v1/comments/999")
request = Net::HTTP::Delete.new(uri)
request["Authorization"] = "Bearer YOUR_API_TOKEN"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end
```

```python
import requests

headers = {'Authorization': 'Bearer YOUR_API_TOKEN'}
response = requests.delete(
    'https://your-domain.com/api/v1/comments/999',
    headers=headers
)
```

```javascript
const axios = require('axios');

axios.delete('https://your-domain.com/api/v1/comments/999', {
  headers: { 'Authorization': 'Bearer YOUR_API_TOKEN' }
})
.then(response => console.log('Comment deleted'))
.catch(error => console.error(error));
```

> Response:

```
HTTP/1.1 204 No Content
```

Deletes a comment.

### HTTP Request

`DELETE /api/v1/comments/:id`

### URL Parameters

Parameter | Description
--------- | -----------
id | The ID of the comment to delete

<aside class="warning">
Deleting a comment is permanent and cannot be undone.
</aside>

# Rate Limiting

The Apunto API implements rate limiting to ensure fair usage and system stability.

## Rate Limit Headers

All API responses include rate limit information in the headers:

Header | Description
------ | -----------
X-RateLimit-Limit | Maximum number of requests per hour
X-RateLimit-Remaining | Number of requests remaining in current window
X-RateLimit-Reset | Unix timestamp when the rate limit resets

## Rate Limit Details

- **Standard Rate Limit:** 1000 requests per hour per API token
- **Burst Limit:** 100 requests per minute per API token

## Exceeding Rate Limits

When you exceed the rate limit, the API will respond with:

```json
{
  "error": "Rate limit exceeded",
  "message": "You have exceeded the rate limit. Please try again later.",
  "retry_after": 3600
}
```

HTTP Status Code: `429 Too Many Requests`

# Pagination

All list endpoints support pagination using standard parameters.

## Pagination Parameters

Parameter | Type | Default | Description
--------- | ---- | ------- | -----------
page | integer | 1 | Page number to retrieve
per_page | integer | 25 | Number of records per page (max: 100)

## Pagination Response

```json
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 250,
    "per_page": 25,
    "prev_page": null,
    "next_page": 2
  }
}
```

All paginated responses include a `pagination` object with:

Field | Description
----- | -----------
current_page | Current page number
total_pages | Total number of pages
total_count | Total number of records
per_page | Records per page
prev_page | Previous page number (null if on first page)
next_page | Next page number (null if on last page)

# Webhooks

Webhooks allow you to receive real-time notifications when certain events occur in your account.

## Available Events

Event | Description
----- | -----------
operation.created | A new operation is created
operation.updated | An operation is updated
operation.status_changed | An operation status changes
service.created | A new service is created
service.updated | A service is updated
service.status_changed | A service status changes
task.created | A new task is created
task.completed | A task is marked as completed
comment.created | A new comment is added

## Webhook Payload

```json
{
  "event": "operation.status_changed",
  "timestamp": "2024-01-16T10:00:00Z",
  "data": {
    "id": 123,
    "identification": "IMP-MEX-001-2024",
    "old_status": "confirmed",
    "new_status": "active"
  },
  "account_id": 456
}
```

All webhook payloads include:

Field | Description
----- | -----------
event | The event type that triggered the webhook
timestamp | When the event occurred (ISO 8601)
data | Event-specific data
account_id | Your account ID

## Webhook Signatures

All webhook requests include an `X-Signature` header that you can use to verify the request came from Apunto.

The signature is an HMAC SHA256 hash of the request body using your webhook secret.

```ruby
require 'openssl'

def verify_webhook_signature(payload, signature, secret)
  expected_signature = OpenSSL::HMAC.hexdigest(
    OpenSSL::Digest.new('sha256'),
    secret,
    payload
  )
  
  Rack::Utils.secure_compare(signature, expected_signature)
end
```

# Support

If you have questions or need assistance with the Apunto API:

- **Email:** support@apunto.com
- **Documentation:** https://docs.apunto.com
- **Status Page:** https://status.apunto.com

## API Versioning

The current API version is **v1**. All endpoints are prefixed with `/api/v1/`.

We will maintain backwards compatibility within major versions. Breaking changes will result in a new API version.

## Changelog

### Version 1.0 (2024-01-15)
- Initial API release
- Support for operations, services, tasks, and comments
- Bearer token authentication
- Rate limiting and pagination
