# Errors

The Apunto API uses conventional HTTP response codes to indicate the success or failure of an API request.

## HTTP Status Codes

Code | Meaning | Description
---- | ------- | -----------
200 | OK | Request succeeded
201 | Created | Resource was successfully created
204 | No Content | Request succeeded with no content to return (typically for DELETE)
400 | Bad Request | The request was invalid or cannot be served
401 | Unauthorized | Authentication failed or API token is missing/invalid
403 | Forbidden | You don't have permission to access this resource
404 | Not Found | The requested resource doesn't exist
422 | Unprocessable Entity | Validation failed - check the response for details
429 | Too Many Requests | Rate limit exceeded
500 | Internal Server Error | Something went wrong on our end
503 | Service Unavailable | Temporary server issue - try again later

## Error Response Format

> Error Response Example:

```json
{
  "error": "Validation failed",
  "message": "The operation could not be created due to validation errors",
  "details": {
    "contact_id": ["can't be blank"],
    "kind": ["is not included in the list"],
    "mode": ["can't be blank"]
  },
  "status": 422
}
```

All error responses follow this format:

Field | Type | Description
----- | ---- | -----------
error | string | Short error type
message | string | Human-readable error message
details | object | Detailed validation errors (for 422 responses)
status | integer | HTTP status code

## Common Errors

### Authentication Error

```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing API token",
  "status": 401
}
```

**Cause:** Missing or invalid `Authorization` header.

**Solution:** Ensure you're sending a valid API token in the format `Bearer YOUR_API_TOKEN`.

### Validation Error

```json
{
  "error": "Validation failed",
  "message": "The resource could not be saved",
  "details": {
    "title": ["can't be blank"],
    "email": ["is invalid"]
  },
  "status": 422
}
```

**Cause:** Required fields are missing or data doesn't meet validation requirements.

**Solution:** Check the `details` object for specific field errors and correct the data.

### Resource Not Found

```json
{
  "error": "Not Found",
  "message": "The requested operation was not found",
  "status": 404
}
```

**Cause:** The resource ID doesn't exist or you don't have access to it.

**Solution:** Verify the resource ID is correct and you have permission to access it.

### Rate Limit Exceeded

```json
{
  "error": "Rate limit exceeded",
  "message": "You have exceeded the rate limit. Please try again later.",
  "retry_after": 3600,
  "status": 429
}
```

**Cause:** Too many requests in a short time period.

**Solution:** Wait for the time specified in `retry_after` (seconds) before making more requests. Implement exponential backoff in your application.

### Permission Denied

```json
{
  "error": "Forbidden",
  "message": "You don't have permission to perform this action",
  "status": 403
}
```

**Cause:** Your account or API token doesn't have the required permissions.

**Solution:** Contact your account administrator to request the necessary permissions.

### Server Error

```json
{
  "error": "Internal Server Error",
  "message": "An unexpected error occurred. Please try again later.",
  "status": 500
}
```

**Cause:** An unexpected error on the server.

**Solution:** Try the request again. If the problem persists, contact support with the request details.

## Best Practices for Error Handling

1. **Always check status codes** - Don't rely solely on the response body
2. **Implement retry logic** - For 5xx errors and rate limits (429)
3. **Use exponential backoff** - When retrying failed requests
4. **Log error details** - Save error responses for debugging
5. **Validate before sending** - Reduce 422 errors by validating data client-side first
6. **Handle token expiration** - Be prepared to refresh or request new tokens
7. **Provide user feedback** - Show meaningful error messages to end users

## Error Handling Example

```ruby
require 'net/http'
require 'json'

def make_api_request(url, method = :get, body = nil)
  uri = URI(url)
  request = case method
            when :get then Net::HTTP::Get.new(uri)
            when :post then Net::HTTP::Post.new(uri)
            when :patch then Net::HTTP::Patch.new(uri)
            when :delete then Net::HTTP::Delete.new(uri)
            end
  
  request['Authorization'] = "Bearer #{ENV['API_TOKEN']}"
  request['Content-Type'] = 'application/json'
  request.body = body.to_json if body
  
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  
  case response.code.to_i
  when 200..299
    JSON.parse(response.body)
  when 401
    raise 'Authentication failed. Check your API token.'
  when 404
    raise 'Resource not found.'
  when 422
    errors = JSON.parse(response.body)
    raise "Validation failed: #{errors['details']}"
  when 429
    retry_after = response['Retry-After'].to_i
    sleep(retry_after)
    make_api_request(url, method, body) # Retry
  when 500..599
    raise 'Server error. Please try again later.'
  else
    raise "Unexpected error: #{response.code}"
  end
rescue JSON::ParserError
  raise 'Invalid JSON response from server'
end
```

```python
import requests
import time
from typing import Dict, Any

def make_api_request(url: str, method: str = 'GET', body: Dict = None) -> Dict[Any, Any]:
    headers = {
        'Authorization': f'Bearer {os.environ["API_TOKEN"]}',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.request(method, url, json=body, headers=headers)
        
        if 200 <= response.status_code < 300:
            return response.json()
        elif response.status_code == 401:
            raise Exception('Authentication failed. Check your API token.')
        elif response.status_code == 404:
            raise Exception('Resource not found.')
        elif response.status_code == 422:
            errors = response.json()
            raise Exception(f'Validation failed: {errors.get("details")}')
        elif response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            time.sleep(retry_after)
            return make_api_request(url, method, body)  # Retry
        elif response.status_code >= 500:
            raise Exception('Server error. Please try again later.')
        else:
            raise Exception(f'Unexpected error: {response.status_code}')
            
    except requests.exceptions.RequestException as e:
        raise Exception(f'Request failed: {str(e)}')
```

```javascript
const axios = require('axios');

async function makeApiRequest(url, method = 'GET', body = null) {
  const config = {
    method: method,
    url: url,
    headers: {
      'Authorization': `Bearer ${process.env.API_TOKEN}`,
      'Content-Type': 'application/json'
    },
    data: body
  };
  
  try {
    const response = await axios(config);
    return response.data;
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      const data = error.response.data;
      
      switch (status) {
        case 401:
          throw new Error('Authentication failed. Check your API token.');
        case 404:
          throw new Error('Resource not found.');
        case 422:
          throw new Error(`Validation failed: ${JSON.stringify(data.details)}`);
        case 429:
          const retryAfter = parseInt(error.response.headers['retry-after']) || 60;
          await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
          return makeApiRequest(url, method, body); // Retry
        case 500:
        case 502:
        case 503:
          throw new Error('Server error. Please try again later.');
        default:
          throw new Error(`Unexpected error: ${status}`);
      }
    } else if (error.request) {
      throw new Error('No response from server');
    } else {
      throw new Error(`Request failed: ${error.message}`);
    }
  }
}
```
