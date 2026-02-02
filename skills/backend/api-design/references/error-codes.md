# Standard Error Codes

## Error Response Format

```typescript
interface ApiError {
  error: {
    code: string;          // Machine-readable code
    message: string;       // Human-readable message
    details?: ErrorDetail[]; // Field-level errors
    request_id?: string;   // For debugging
  };
}

interface ErrorDetail {
  field: string;
  code: string;
  message: string;
}
```

## Authentication Errors (401)

| Code | Message | When to Use |
|------|---------|-------------|
| `AUTH_REQUIRED` | Authentication required | No token provided |
| `AUTH_INVALID` | Invalid authentication token | Token malformed |
| `AUTH_EXPIRED` | Authentication token expired | Token expired |
| `AUTH_REVOKED` | Authentication token revoked | Token was invalidated |

## Authorization Errors (403)

| Code | Message | When to Use |
|------|---------|-------------|
| `FORBIDDEN` | Access denied | Generic permission denied |
| `INSUFFICIENT_PERMISSIONS` | Insufficient permissions | Missing required role |
| `RESOURCE_FORBIDDEN` | Cannot access this resource | Resource-level denial |
| `ACTION_FORBIDDEN` | Cannot perform this action | Action-level denial |

## Validation Errors (422)

| Code | Message | When to Use |
|------|---------|-------------|
| `VALIDATION_ERROR` | Validation failed | Generic validation failure |
| `REQUIRED_FIELD` | Field is required | Missing required field |
| `INVALID_FORMAT` | Invalid format | Wrong data format |
| `INVALID_VALUE` | Invalid value | Value not in allowed set |
| `TOO_SHORT` | Value too short | Below minimum length |
| `TOO_LONG` | Value too long | Above maximum length |
| `TOO_SMALL` | Value too small | Below minimum value |
| `TOO_LARGE` | Value too large | Above maximum value |

## Resource Errors (404, 409)

| Code | Status | Message | When to Use |
|------|--------|---------|-------------|
| `NOT_FOUND` | 404 | Resource not found | Resource doesn't exist |
| `ALREADY_EXISTS` | 409 | Resource already exists | Duplicate creation |
| `CONFLICT` | 409 | Resource conflict | State conflict |
| `GONE` | 410 | Resource no longer available | Permanently deleted |

## Rate Limiting (429)

| Code | Message | When to Use |
|------|---------|-------------|
| `RATE_LIMITED` | Too many requests | Rate limit exceeded |
| `QUOTA_EXCEEDED` | API quota exceeded | Usage quota reached |

## Server Errors (500, 503)

| Code | Status | Message | When to Use |
|------|--------|---------|-------------|
| `INTERNAL_ERROR` | 500 | Internal server error | Unexpected error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable | Maintenance/overload |
| `DEPENDENCY_ERROR` | 502 | Upstream service error | Third-party failure |

## Example Responses

### Validation Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Invalid email format"
      },
      {
        "field": "password",
        "code": "TOO_SHORT",
        "message": "Password must be at least 8 characters"
      }
    ],
    "request_id": "req_abc123"
  }
}
```

### Not Found Error
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "request_id": "req_abc123"
  }
}
```

### Rate Limited Error
```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests. Please retry after 60 seconds.",
    "request_id": "req_abc123"
  }
}
```

## Headers for Errors

```http
# Rate limiting
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640000000
Retry-After: 60

# Request tracking
X-Request-Id: req_abc123
```
