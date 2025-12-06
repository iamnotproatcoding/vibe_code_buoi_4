# Design Flowcharts - Hệ Thống Quản Lý Thư Viện

Thư mục này chứa các flowchart Mermaid mô tả chi tiết các luồng chức năng của hệ thống quản lý thư viện.

## Cấu Trúc File

Tất cả các file flowchart được đặt tên theo format: `X.X-feature-name.md`

## Danh Sách Flowchart

### 1. Quản Lý Tài Khoản
- [2.1.1 - Đăng Ký](./2.1.1-user-registration-flow.md)
- [2.1.2 - Đăng Nhập](./2.1.2-login-flow.md)
- [2.1.3 - Hồ Sơ Cá Nhân](./2.1.3-user-profile-flow.md)

### 2. Quản Lý Sách
- [2.2.1 - Quản lý thể loại sách](./2.2.1-category-management-flow.md)
- [2.2.2 - Thêm Sách Mới](./2.2.2-add-book-flow.md)
- [2.2.3 - Xem Danh Sách Sách](./2.2.3-book-list-flow.md)
- [2.2.4 - Xem Chi Tiết Sách](./2.2.4-book-detail-flow.md)
- [2.2.5 - Sửa & Xóa Sách](./2.2.5-edit-delete-book-flow.md)

### 3. Quản Lý Mượn Sách
- [2.3.1 - Mượn Sách (Độc Giả)](./2.3.1-borrow-book-reader-flow.md)
- [2.3.2 - Mượn Sách (Nhân Viên)](./2.3.2-borrow-book-librarian-flow.md)
- [2.3.3 - Xem Lịch Sử Mượn Sách](./2.3.3-borrow-history-flow.md)

### 4. Trả Sách
- [2.4.1 - Yêu Cầu Trả Sách](./2.4.1-return-request-flow.md)
- [2.4.2 - Xác Nhận Trả Sách](./2.4.2-confirm-return-flow.md)

### 5. Quản Lý Nợ & Phạt
- [2.5.1 - Quản lý mức phạt](./2.5.1-penalty-level-management-flow.md)
- [2.5.2 - Xem & Thanh Toán Phạt (Độc Giả)](./2.5.2-penalty-payment-reader-flow.md)
- [2.5.3 - Xem & Thanh Toán Phạt (Nhân Viên)](./2.5.3-penalty-payment-librarian-flow.md)

### 6. Quản Lý Người Dùng
- [2.6.1 - Danh Sách Người Dùng](./2.6.1-user-list-flow.md)
- [2.6.2 - Gán Vai Trò](./2.6.2-assign-role-flow.md)

### 7. Báo Cáo & Thống Kê
- [2.7.1 - Báo Cáo Tổng Quan](./2.7.1-dashboard-overview-flow.md)
- [2.7.2 - Báo Cáo Chi Tiết](./2.7.2-detailed-reports-flow.md)

## Tài Liệu Phân Tích

- [FEATURE_ANALYSIS.md](./FEATURE_ANALYSIS.md) - Phân tích chi tiết tất cả các tính năng, luồng chính, luồng thay thế và edge cases

## Cách Sử Dụng

1. Mở file `.md` tương ứng với tính năng cần xem
2. Flowchart Mermaid sẽ được hiển thị tự động trong các editor hỗ trợ Mermaid (VS Code, GitHub, GitLab, etc.)
3. Mỗi file chứa:
   - Mô tả tính năng
   - Actor và yêu cầu
   - Flowchart Mermaid
   - Validation Rules
   - Edge Cases

## Lưu Ý

- Tất cả flowchart được viết bằng cú pháp Mermaid
- Các flowchart bao gồm cả luồng chính (happy path) và luồng lỗi (error handling)
- Màu sắc trong flowchart:
  - Xanh nhạt (#e1f5ff): Bắt đầu
  - Xanh lá (#c8e6c9): Thành công/Kết thúc
  - Đỏ nhạt (#ffcdd2): Lỗi
  - Vàng nhạt (#fff9c4): Cảnh báo/Thông tin

