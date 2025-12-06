# Library Management System - Frontend

Frontend cho hệ thống quản lý thư viện được xây dựng với React và TailwindCSS.

## Tech Stack

- React 18
- Vite
- TailwindCSS
- React Router DOM
- React Hook Form
- Axios
- Context API

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Chạy development server:
```bash
npm run dev
```

3. Build cho production:
```bash
npm run build
```

## Cấu trúc thư mục

```
frontend/
├── src/
│   ├── components/      # React components
│   │   └── Layout/     # Layout components (Header, Footer, Layout)
│   ├── context/        # Context API (AuthContext)
│   ├── config/         # Configuration (axios)
│   ├── pages/          # Page components
│   ├── App.jsx         # Main app component
│   ├── main.jsx        # Entry point
│   └── index.css       # Global styles
├── public/             # Static files
└── package.json
```

## Tính năng

- ✅ Landing Page
- ✅ Đăng ký tài khoản
- ✅ Khung giao diện chung (Layout, Header, Footer)
- ⏳ Đăng nhập (sẽ triển khai sau)
- ⏳ Quản lý sách (sẽ triển khai sau)

