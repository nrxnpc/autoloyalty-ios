# Настройка Backend для NSP Автолояльность

## Обзор архитектуры

Приложение NSP Автолояльность требует REST API backend для полноценной работы. Текущая версия использует демо-данные, но готова к интеграции с реальным сервером.

## Требуемые API Endpoints

### 1. Аутентификация
```
POST /api/auth/login
POST /api/auth/register  
POST /api/auth/refresh
POST /api/auth/logout
```

### 2. Пользователи
```
GET /api/users/profile
PUT /api/users/profile
GET /api/users/{id}
PUT /api/users/{id}/role (только админы)
```

### 3. Товары
```
GET /api/products
POST /api/products (поставщики/админы)
PUT /api/products/{id}
DELETE /api/products/{id}
GET /api/products/{id}
```

### 4. QR-коды и сканирование
```
POST /api/qr/scan
GET /api/qr/history
POST /api/qr/generate (поставщики)
```

### 5. Новости
```
GET /api/news
POST /api/news (поставщики/админы)
PUT /api/news/{id}
DELETE /api/news/{id}
```

### 6. Лотереи
```
GET /api/lotteries
POST /api/lotteries (админы)
POST /api/lotteries/{id}/participate
```

### 7. Модерация
```
GET /api/moderation/pending
PUT /api/moderation/{type}/{id}/approve
PUT /api/moderation/{type}/{id}/reject
```

## Рекомендуемые технологии Backend

### Node.js + Express
```bash
npm init -y
npm install express mongoose bcryptjs jsonwebtoken cors helmet
npm install -D nodemon
```

### Python + FastAPI
```bash
pip install fastapi uvicorn sqlalchemy alembic bcrypt python-jose
```

### PHP + Laravel
```bash
composer create-project laravel/laravel nsp-backend
composer require laravel/sanctum
```

## Структура базы данных

### Основные таблицы:

#### users
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    points INT DEFAULT 0,
    role ENUM('customer', 'supplier', 'platformAdmin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### products
```sql
CREATE TABLE products (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category ENUM('merchandise', 'discounts', 'accessories', 'services'),
    points_cost INT NOT NULL,
    description TEXT,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    supplier_id VARCHAR(36),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES users(id)
);
```

#### qr_scans
```sql
CREATE TABLE qr_scans (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    product_name VARCHAR(255),
    points_earned INT NOT NULL,
    qr_code VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### news
```sql
CREATE TABLE news (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_important BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    status ENUM('draft', 'pending', 'approved', 'rejected') DEFAULT 'draft',
    author_id VARCHAR(36) NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,
    FOREIGN KEY (author_id) REFERENCES users(id)
);
```

## Пример Express.js сервера

### package.json
```json
{
  "name": "nsp-backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "multer": "^1.4.5"
  }
}
```

### server.js
```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const mongoose = require('mongoose');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/nsp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/products', require('./routes/products'));
app.use('/api/qr', require('./routes/qr'));
app.use('/api/news', require('./routes/news'));
app.use('/api/lotteries', require('./routes/lotteries'));
app.use('/api/moderation', require('./routes/moderation'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## Конфигурация в iOS приложении

Обновите файл `AppConfig.swift`:

```swift
struct AppConfig {
    static let baseURL = "https://your-api-domain.com/api"
    // или для локальной разработки:
    // static let baseURL = "http://localhost:3000/api"
    
    static let timeout: TimeInterval = 30
    static let enableDemoMode = false // установите false для продакшена
}
```

## Аутентификация и безопасность

### JWT токены
- Access token: срок жизни 15 минут
- Refresh token: срок жизни 7 дней
- Храните refresh token в Keychain

### Middleware для проверки ролей
```javascript
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};
```

## Загрузка изображений

### Multer конфигурация
```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});
```

## Развертывание

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/nsp
      - JWT_SECRET=your-secret-key
    depends_on:
      - mongo
  
  mongo:
    image: mongo:5
    volumes:
      - mongo_data:/data/db
    
volumes:
  mongo_data:
```

## Мониторинг и логирование

### Winston для логирования
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

## Тестирование API

### Postman коллекция
Создайте коллекцию с примерами запросов для всех endpoints.

### Автоматические тесты
```javascript
const request = require('supertest');
const app = require('../server');

describe('Auth Endpoints', () => {
  test('POST /api/auth/login', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });
    
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });
});
```

## Следующие шаги

1. Выберите технологию backend
2. Настройте базу данных
3. Реализуйте основные endpoints
4. Настройте аутентификацию
5. Добавьте систему модерации
6. Протестируйте интеграцию с iOS приложением
7. Настройте мониторинг и логирование
8. Разверните на продакшен сервере

## Поддержка

Для вопросов по интеграции обращайтесь к разработчику iOS приложения.