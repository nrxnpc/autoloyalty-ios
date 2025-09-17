# NSP QR Bot API Reference

## Overview
REST API for NSP QR Bot mobile application with PostgreSQL backend. Base URL: `http://localhost:8080`

## Authentication
- **API Key**: Required in header `X-API-Key` for all endpoints
- **Bearer Token**: Required in header `Authorization: Bearer <token>` for protected endpoints
- **Session Duration**: 30 days

## Common Response Structure
```json
{
  "success": boolean,
  "error": "string (if error)",
  "pagination": {
    "limit": number,
    "offset": number,
    "has_more": boolean
  }
}
```

## Endpoints

### Authentication

#### Register User
- **POST** `/api/v1/register`
- **Auth**: API Key
- **Request**:
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "password": "string",
  "userType": "individual|company",
  "deviceInfo": "string (optional)"
}
```
- **Response**:
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "phone": "string",
    "userType": "string",
    "points": 100,
    "role": "user|company|admin",
    "registrationDate": "ISO8601",
    "isActive": true
  },
  "token": "string"
}
```

#### Login User
- **POST** `/api/v1/login`
- **Auth**: API Key
- **Request**:
```json
{
  "email": "string",
  "password": "string",
  "deviceInfo": "string (optional)"
}
```
- **Response**: Same as register

### QR Code Operations

#### Scan QR Code
- **POST** `/api/v1/scan`
- **Auth**: API Key + Bearer Token
- **Request**:
```json
{
  "qr_code": "NSP:id:category:points",
  "location": "string (optional)"
}
```
- **Response**:
```json
{
  "valid": true,
  "scan_id": "uuid",
  "product_name": "string",
  "product_category": "string",
  "points_earned": number,
  "description": "string",
  "timestamp": "ISO8601"
}
```

#### Get User Scans
- **GET** `/api/v1/user/scans?limit=50&offset=0`
- **Auth**: API Key + Bearer Token
- **Response**:
```json
{
  "user_id": "uuid",
  "total_scans": number,
  "total_points": number,
  "scans": [
    {
      "id": "uuid",
      "qr_code": "uuid",
      "product_name": "string",
      "product_category": "string",
      "points_earned": number,
      "timestamp": "ISO8601",
      "location": "string"
    }
  ],
  "pagination": {...}
}
```

### Products

#### Get Products
- **GET** `/api/v1/products?limit=50&offset=0`
- **Auth**: API Key
- **Response**:
```json
{
  "products": [
    {
      "id": "uuid",
      "name": "string",
      "category": "string",
      "pointsCost": number,
      "imageURL": "string",
      "description": "string",
      "stockQuantity": number,
      "isActive": boolean,
      "createdAt": "ISO8601",
      "deliveryOptions": []
    }
  ],
  "pagination": {...}
}
```

#### Add Product
- **POST** `/api/v1/products`
- **Auth**: API Key + Bearer Token (admin/operator/company)
- **Request**:
```json
{
  "name": "string",
  "category": "string",
  "pointsCost": number,
  "description": "string (optional)",
  "imageURL": "string (optional)",
  "stockQuantity": number,
  "deliveryOptions": []
}
```
- **Response**:
```json
{
  "success": true,
  "product_id": "uuid",
  "message": "Product added successfully"
}
```

### Cars

#### Get Cars
- **GET** `/api/v1/cars?limit=50&offset=0`
- **Auth**: API Key
- **Response**:
```json
{
  "cars": [
    {
      "id": "uuid",
      "brand": "string",
      "model": "string",
      "year": number,
      "price": "string",
      "imageURL": "string",
      "description": "string",
      "specifications": {
        "engine": "string",
        "transmission": "string",
        "fuelType": "string",
        "bodyType": "string",
        "drivetrain": "string",
        "color": "string"
      },
      "isActive": boolean,
      "createdAt": "ISO8601"
    }
  ],
  "pagination": {...}
}
```

#### Add Car
- **POST** `/api/v1/cars`
- **Auth**: API Key + Bearer Token (admin only)
- **Request**:
```json
{
  "brand": "string",
  "model": "string",
  "year": number,
  "price": "string",
  "description": "string (optional)",
  "engine": "string (optional)",
  "transmission": "string (optional)",
  "fuelType": "string (optional)",
  "bodyType": "string (optional)",
  "drivetrain": "string (optional)",
  "color": "string (optional)"
}
```

### News

#### Get News
- **GET** `/api/v1/news?limit=50&offset=0`
- **Auth**: API Key
- **Response**:
```json
{
  "news": [
    {
      "id": "uuid",
      "title": "string",
      "content": "string",
      "imageURL": "string",
      "isImportant": boolean,
      "createdAt": "ISO8601",
      "publishedAt": "ISO8601",
      "isPublished": boolean,
      "authorId": "uuid",
      "tags": []
    }
  ],
  "pagination": {...}
}
```

#### Add News
- **POST** `/api/v1/news`
- **Auth**: API Key + Bearer Token (admin/operator/company)
- **Request**:
```json
{
  "title": "string",
  "content": "string",
  "imageURL": "string (optional)",
  "isImportant": boolean,
  "isPublished": boolean,
  "tags": [],
  "articleType": "news|promotion|campaign"
}
```

### Promo Campaigns

#### Get Campaigns
- **GET** `/api/v1/campaigns?limit=50&offset=0`
- **Auth**: API Key
- **Response**:
```json
{
  "campaigns": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string",
      "campaignType": "discount|bonus_points|free_shipping",
      "discountPercent": number,
      "bonusPoints": number,
      "minPurchaseAmount": number,
      "startDate": "ISO8601",
      "endDate": "ISO8601",
      "imageURL": "string",
      "usageCount": number,
      "maxUsage": number,
      "companyId": "uuid"
    }
  ],
  "pagination": {...}
}
```

#### Create Campaign
- **POST** `/api/v1/campaigns`
- **Auth**: API Key + Bearer Token (admin/operator/company)
- **Request**:
```json
{
  "title": "string",
  "description": "string",
  "campaignType": "discount|bonus_points|free_shipping",
  "discountPercent": number,
  "bonusPoints": number,
  "minPurchaseAmount": number,
  "startDate": "ISO8601",
  "endDate": "ISO8601",
  "imageURL": "string (optional)",
  "targetAudience": {},
  "maxUsage": number
}
```

### Transactions

#### Get User Transactions
- **GET** `/api/v1/user/transactions?limit=50&offset=0`
- **Auth**: API Key + Bearer Token
- **Response**:
```json
{
  "transactions": [
    {
      "id": "uuid",
      "userId": "uuid",
      "type": "earned|spent|bonus|penalty",
      "amount": number,
      "description": "string",
      "timestamp": "ISO8601",
      "relatedId": "uuid"
    }
  ],
  "pagination": {...}
}
```

### File Upload

#### Upload File
- **POST** `/api/v1/upload`
- **Auth**: API Key + Bearer Token (admin/operator/company)
- **Content-Type**: `multipart/form-data`
- **Response**:
```json
{
  "success": true,
  "file_url": "/uploads/filename.ext",
  "filename": "string",
  "size": number
}
```

#### Get Uploaded File
- **GET** `/uploads/{filename}`
- **Auth**: None
- **Response**: File binary data

### Analytics

#### Company Analytics
- **GET** `/api/v1/company/analytics`
- **Auth**: API Key + Bearer Token (company only)
- **Response**:
```json
{
  "company_id": "uuid",
  "company_name": "string",
  "analytics": {
    "products": {
      "total": number
    },
    "news": {
      "total": number
    },
    "campaigns": {
      "total": number,
      "active": number
    }
  },
  "timestamp": "ISO8601"
}
```

#### General Statistics
- **GET** `/api/v1/statistics`
- **Auth**: API Key
- **Response**:
```json
{
  "qr_codes": {
    "total": number,
    "unused": number,
    "used": number,
    "total_scans": number
  },
  "users": {
    "total": number,
    "active": number
  },
  "scans": {
    "total": number,
    "unique_scanners": number,
    "total_points_earned": number
  },
  "timestamp": "ISO8601"
}
```

## Error Responses
```json
{
  "error": "Error message",
  "status": 400|401|403|404|409|413|500|503
}
```

## Status Codes
- **200**: Success
- **400**: Bad Request
- **401**: Unauthorized (Invalid API key or token)
- **403**: Forbidden (Insufficient permissions)
- **404**: Not Found
- **409**: Conflict (QR code already used)
- **413**: Payload Too Large (File upload)
- **500**: Internal Server Error
- **503**: Service Unavailable (Database connection failed)

## Rate Limiting
No rate limiting implemented currently.

## API Keys
- Mobile App: `nsp_mobile_app_api_key_2024`
- Admin: `nsp_admin_api_key_2024`