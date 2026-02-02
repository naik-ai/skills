---
name: api-design
description: Design RESTful and GraphQL APIs with OpenAPI specifications. Use when user needs "API design", "REST endpoints", "API architecture", "OpenAPI spec", "GraphQL schema", "endpoint design", or "API documentation". Creates consistent, well-documented APIs following industry best practices. Outputs OpenAPI specs, route handlers, and type definitions.
---

# API Design Skill

Design production-ready APIs with consistent patterns, proper documentation, and type safety.

## When to Use

- Designing new API endpoints
- Documenting existing APIs
- Creating OpenAPI/Swagger specifications
- Designing GraphQL schemas
- Establishing API conventions for a project

## Workflow

### Phase 1: Requirements Analysis

**Goal**: Understand what the API needs to support

**Actions**:
1. Identify resources (nouns) from requirements
2. Map operations (verbs) to HTTP methods
3. Define relationships between resources
4. Identify authentication/authorization needs

**Output**: Resource list with operations

### Phase 2: API Design

**Goal**: Design endpoint structure and contracts

**Actions**:
1. Define URL patterns following REST conventions
2. Design request/response schemas
3. Plan error handling strategy
4. Define pagination, filtering, sorting

**Output**: API specification document

### Phase 3: Documentation

**Goal**: Create comprehensive API documentation

**Actions**:
1. Generate OpenAPI spec
2. Document all endpoints with examples
3. Define error responses
4. Create authentication guide

**Output**: `openapi.yaml` and type definitions

## REST Conventions

### URL Structure

```
# Resource naming (plural nouns)
GET    /users              # List users
POST   /users              # Create user
GET    /users/{id}         # Get user
PUT    /users/{id}         # Replace user
PATCH  /users/{id}         # Update user
DELETE /users/{id}         # Delete user

# Nested resources
GET    /users/{id}/posts   # List user's posts
POST   /users/{id}/posts   # Create post for user

# Actions (when CRUD doesn't fit)
POST   /users/{id}/activate
POST   /orders/{id}/cancel
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Read resource | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource | Yes | No |
| PATCH | Partial update | Yes | No |
| DELETE | Remove resource | Yes | No |

### Status Codes

```typescript
// Success
200 OK              // Successful GET, PUT, PATCH
201 Created         // Successful POST (include Location header)
204 No Content      // Successful DELETE

// Client Errors
400 Bad Request     // Invalid input
401 Unauthorized    // Missing/invalid authentication
403 Forbidden       // Valid auth, insufficient permissions
404 Not Found       // Resource doesn't exist
409 Conflict        // Resource state conflict
422 Unprocessable   // Validation failed

// Server Errors
500 Internal Error  // Unexpected server error
503 Service Unavailable // Temporary outage
```

## Request/Response Patterns

### Standard Response Envelope

```typescript
// Success response
{
  "data": { ... },           // The actual data
  "meta": {                  // Optional metadata
    "page": 1,
    "perPage": 20,
    "total": 100
  }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Pagination

```typescript
// Request
GET /users?page=2&per_page=20

// Response
{
  "data": [...],
  "meta": {
    "page": 2,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  },
  "links": {
    "self": "/users?page=2&per_page=20",
    "first": "/users?page=1&per_page=20",
    "prev": "/users?page=1&per_page=20",
    "next": "/users?page=3&per_page=20",
    "last": "/users?page=8&per_page=20"
  }
}
```

### Filtering & Sorting

```typescript
// Filtering
GET /users?status=active&role=admin
GET /users?created_at[gte]=2024-01-01
GET /posts?author_id=123

// Sorting
GET /users?sort=created_at        // Ascending
GET /users?sort=-created_at       // Descending
GET /users?sort=name,-created_at  // Multiple fields

// Field selection
GET /users?fields=id,name,email
```

### Partial Updates (PATCH)

```typescript
// Only send fields to update
PATCH /users/123
{
  "name": "New Name"
}

// Response includes full object
{
  "data": {
    "id": 123,
    "name": "New Name",
    "email": "unchanged@example.com"
  }
}
```

## OpenAPI Specification

```yaml
# openapi.yaml
openapi: 3.1.0
info:
  title: My API
  version: 1.0.0
  description: API for managing users and posts

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging

paths:
  /users:
    get:
      summary: List users
      operationId: listUsers
      tags: [Users]
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'

    post:
      summary: Create user
      operationId: createUser
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          headers:
            Location:
              schema:
                type: string
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '422':
          $ref: '#/components/responses/ValidationError'

  /users/{id}:
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
          format: uuid

    get:
      summary: Get user
      operationId: getUser
      tags: [Users]
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '404':
          $ref: '#/components/responses/NotFound'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
        role:
          type: string
          enum: [user, admin]
        created_at:
          type: string
          format: date-time
      required: [id, email, name, role, created_at]

    CreateUserRequest:
      type: object
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          minLength: 1
          maxLength: 100
        password:
          type: string
          minLength: 8
      required: [email, name, password]

    UserResponse:
      type: object
      properties:
        data:
          $ref: '#/components/schemas/User'

    UserListResponse:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/User'
        meta:
          $ref: '#/components/schemas/PaginationMeta'

    PaginationMeta:
      type: object
      properties:
        page:
          type: integer
        per_page:
          type: integer
        total:
          type: integer
        total_pages:
          type: integer

    Error:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
            details:
              type: array
              items:
                type: object

  responses:
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error:
              code: NOT_FOUND
              message: User not found

    ValidationError:
      description: Validation error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

## TypeScript Types

```typescript
// types/api.ts
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'admin';
  created_at: string;
}

export interface CreateUserRequest {
  email: string;
  name: string;
  password: string;
}

export interface UpdateUserRequest {
  email?: string;
  name?: string;
}

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

export interface ApiResponse<T> {
  data: T;
  meta?: PaginationMeta;
}

export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Array<{
      field: string;
      message: string;
    }>;
  };
}

export type ApiResult<T> = ApiResponse<T> | ApiError;
```

## Versioning Strategies

```typescript
// URL versioning (recommended)
GET /v1/users
GET /v2/users

// Header versioning
GET /users
Accept: application/vnd.myapi.v1+json

// Query parameter
GET /users?version=1
```

## Authentication Patterns

```typescript
// Bearer token (JWT)
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

// API key (header)
X-API-Key: your-api-key

// API key (query - less secure, only for webhooks)
GET /webhooks/callback?api_key=your-api-key
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Verbs in URLs | `/getUsers`, `/createUser` | Use nouns: `/users` with HTTP methods |
| Inconsistent naming | `user_id` vs `userId` | Pick one convention (snake_case recommended) |
| No pagination | Memory issues, slow responses | Always paginate list endpoints |
| Returning 200 for errors | Client confusion | Use appropriate status codes |
| No versioning | Breaking changes break clients | Version from day one |
| Missing error details | Hard to debug | Return specific error codes and messages |

## Key Principles

1. **Consistency**: Same patterns everywhere
2. **Predictability**: Clients can guess endpoint structure
3. **Self-documenting**: Clear naming, no surprises
4. **Versioned**: Plan for change from the start
5. **Secure by default**: Authentication required unless explicitly public

## References

- `references/graphql-patterns.md` - GraphQL schema design
- `references/error-codes.md` - Standard error code catalog
