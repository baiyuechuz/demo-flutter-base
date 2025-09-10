---
title: "API Reference"
description: "Complete reference for all available APIs and methods"
order: 3
category: "reference"
---

# API Reference

Complete reference for all available APIs and methods.

## Authentication

All API requests require authentication using JWT tokens.

### Get Access Token

```bash
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "user": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

## Core APIs

### Users API

#### Get User Profile

```bash
GET /api/users/me
Authorization: Bearer {token}
```

#### Update User Profile

```bash
PUT /api/users/me
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Updated Name",
  "email": "new@example.com"
}
```

### Projects API

#### List Projects

```bash
GET /api/projects
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | number | Page number (default: 1) |
| `limit` | number | Items per page (default: 20) |
| `search` | string | Search term |
| `status` | string | Filter by status |

#### Create Project

```bash
POST /api/projects
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "My New Project",
  "description": "Project description",
  "visibility": "private"
}
```

## Error Handling

The API uses standard HTTP status codes:

- `200` - Success
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

**Error Response Format:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## Rate Limiting

API requests are rate limited:

- **Authenticated users**: 1000 requests per hour
- **Unauthenticated users**: 100 requests per hour

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```