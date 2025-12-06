# Hệ Thống Quản Lý Thư Viện

Hệ thống quản lý thư viện web-based cho phép độc giả mượn trả sách, nhân viên quản lý kho sách và quản lý viên xem báo cáo thống kê.

## Cấu Trúc Dự Án

```
library_starter/
├── backend/          # Backend API (Express.js, Prisma, PostgreSQL)
├── frontend/         # Frontend (React, TailwindCSS)
├── design/           # Tài liệu thiết kế và flowchart
├── migrations/       # Database migration scripts
└── PRD.md           # Product Requirements Document
```

## Tech Stack

### Backend
- Node.js (v18+)
- Express.js
- Prisma ORM
- PostgreSQL
- JWT Authentication
- Joi Validation

### Frontend
- React 18
- Vite
- TailwindCSS
- React Router DOM
- React Hook Form
- Axios
- Context API

## Cài Đặt

### 1. Backend Setup

```bash
cd backend
npm install
```

Tạo file `.env`:
```env
DATABASE_URL="postgresql://user:password@localhost:5432/library_db?schema=public"
JWT_SECRET="your-secret-key-change-this-in-production"
JWT_EXPIRES_IN="24h"
PORT=3000
NODE_ENV=development
```

Chạy database migration:
```bash
# Chạy file schema.sql trong thư mục migrations
# Hoặc sử dụng Prisma migrate nếu đã setup
npm run prisma:generate
```

Chạy server:
```bash
npm run dev
```

### 2. Frontend Setup

```bash
cd frontend
npm install
```

Chạy development server:
```bash
npm run dev
```

Frontend sẽ chạy tại `http://localhost:5173`
Backend API sẽ chạy tại `http://localhost:3000`

## Tính Năng Đã Triển Khai

### ✅ Backend
- [x] Cấu trúc dự án Express.js
- [x] Prisma ORM setup
- [x] JWT authentication middleware
- [x] Validation với Joi
- [x] API đăng ký (`POST /api/auth/register`)

### ✅ Frontend
- [x] Cấu trúc dự án React với Vite
- [x] TailwindCSS setup
- [x] Khung giao diện chung (Layout, Header, Footer)
- [x] Landing Page
- [x] Trang đăng ký với form validation
- [x] Context API cho authentication
- [x] Axios configuration

## API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký tài khoản mới

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "Nguyễn Văn A",
  "password": "password123",
  "confirmPassword": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "Nguyễn Văn A",
      "role": "reader",
      "status": "active"
    }
  }
}
```

## Lưu Ý

### Database Schema
Schema database được thiết kế để tích hợp với Supabase Auth. Trong phiên bản hiện tại:
- Backend đang sử dụng email làm `authUserId` (simplified version)
- Trong production, cần tích hợp với Supabase Auth để:
  1. Tạo user trong Supabase Auth
  2. Lấy `auth_user_id` từ Supabase
  3. Tạo profile trong bảng `users` với `auth_user_id` đó

### Validation Rules
- Email: Định dạng email hợp lệ, không được trùng
- Tên: Không được để trống, tối đa 50 ký tự
- Mật khẩu: Tối thiểu 8 ký tự, tối đa 16 ký tự
- Confirm mật khẩu: Phải trùng với mật khẩu

## Phát Triển Tiếp Theo

Các tính năng sẽ được triển khai theo thứ tự:
1. ✅ Đăng ký (2.1.1)
2. ⏳ Đăng nhập (2.1.2)
3. ⏳ Hồ sơ cá nhân (2.1.3)
4. ⏳ Quản lý sách (2.2.x)
5. ⏳ Quản lý mượn trả (2.3.x, 2.4.x)
6. ⏳ Quản lý phạt (2.5.x)
7. ⏳ Quản lý người dùng (2.6.x)
8. ⏳ Báo cáo & thống kê (2.7.x)

## License

ISC

