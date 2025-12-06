# Library Management System - Backend

Backend API cho hệ thống quản lý thư viện.

## Tech Stack

- Node.js (v18+)
- Express.js
- Prisma ORM
- PostgreSQL
- JWT Authentication
- Joi Validation

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Tạo file `.env` từ `.env.example`:
```bash
cp .env.example .env
```

3. Cấu hình database trong `.env`:
```
DATABASE_URL="postgresql://user:password@localhost:5432/library_db?schema=public"
JWT_SECRET="your-secret-key"
```

4. Chạy migration database (nếu chưa có):
```bash
# Chạy file schema.sql trong thư mục migrations
```

5. Generate Prisma Client:
```bash
npm run prisma:generate
```

6. Chạy server:
```bash
npm run dev
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Đăng ký tài khoản mới

## Cấu trúc thư mục

```
backend/
├── src/
│   ├── config/          # Cấu hình (database, JWT)
│   ├── controllers/     # Controllers xử lý logic
│   ├── middleware/      # Middleware (auth, error handler)
│   ├── routes/          # API routes
│   ├── utils/           # Utilities (validation)
│   └── server.js        # Entry point
├── prisma/
│   └── schema.prisma    # Prisma schema
└── package.json
```

