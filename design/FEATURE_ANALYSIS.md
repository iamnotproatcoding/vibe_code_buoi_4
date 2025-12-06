# Phân Tích Tính Năng - Hệ Thống Quản Lý Thư Viện

## Tổng Quan
Tài liệu này phân tích tất cả các tính năng trong PRD, bao gồm luồng chính, luồng thay thế và các trường hợp lỗi/edge cases.

---

## 1. QUẢN LÝ TÀI KHOẢN

### 1.1 Đăng Ký (2.1.1)
**Actor:** Mọi người  
**Yêu cầu:** Không có

**Luồng chính:**
1. Người dùng click "Đăng ký"
2. Nhập thông tin: Email, Tên, Mật khẩu, Confirm mật khẩu
3. Hệ thống validate dữ liệu
4. Tạo tài khoản với trạng thái "Chờ xác nhận"
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Validation thất bại → Hiển thị lỗi cụ thể → Người dùng sửa và thử lại

**Edge cases:**
- Email đã tồn tại trong hệ thống
- Mật khẩu và confirm mật khẩu không khớp
- Email không đúng định dạng
- Tên quá dài (>50 ký tự)
- Mật khẩu quá ngắn (<8 ký tự) hoặc quá dài (>16 ký tự)

---

### 1.2 Đăng Nhập (2.1.2)
**Actor:** Mọi người  
**Yêu cầu:** Không có

**Luồng chính:**
1. Người dùng nhập Email & Mật khẩu
2. Hệ thống xác thực thông tin
3. Tạo JWT token (thời hạn 24h)
4. Chuyển hướng tới dashboard theo vai trò (Độc giả/Nhân viên)

**Luồng thay thế:**
- Email/Mật khẩu sai → Hiển thị lỗi "Email hoặc mật khẩu không đúng"
- Tài khoản chưa được xác nhận → Hiển thị thông báo "Tài khoản chưa được xác nhận"
- Tài khoản bị vô hiệu hóa → Hiển thị thông báo "Tài khoản đã bị vô hiệu hóa"

**Edge cases:**
- Email không tồn tại
- Mật khẩu sai
- Token hết hạn (sau 24h)
- Đăng nhập từ nhiều thiết bị

---

### 1.3 Hồ Sơ Cá Nhân (2.1.3)
**Actor:** Độc giả  
**Yêu cầu:** Đăng nhập với vai trò độc giả

**Luồng chính - Xem hồ sơ:**
1. Độc giả truy cập trang hồ sơ
2. Hiển thị: Tên, Email, Số điện thoại, Địa chỉ, Ngày tham gia, Số lần mượn, Tổng số tiền phạt

**Luồng chính - Cập nhật thông tin:**
1. Click "Chỉnh sửa"
2. Cập nhật thông tin (Tên, Số điện thoại, Địa chỉ)
3. Validate dữ liệu
4. Lưu thay đổi
5. Hiển thị thông báo thành công

**Luồng chính - Đổi mật khẩu:**
1. Click "Đổi mật khẩu"
2. Nhập mật khẩu cũ, mật khẩu mới, xác nhận mật khẩu mới
3. Validate
4. Cập nhật mật khẩu
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Validation thất bại → Hiển thị lỗi → Sửa và thử lại
- Mật khẩu cũ sai → Hiển thị lỗi "Mật khẩu cũ không đúng"

**Edge cases:**
- Số điện thoại không đúng định dạng
- Địa chỉ quá dài (>255 ký tự)
- Mật khẩu mới trùng với mật khẩu cũ

---

## 2. QUẢN LÝ SÁCH

### 2.1 Quản lý thể loại sách (2.2.1)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính - Xem danh sách:**
1. Nhân viên truy cập trang quản lý thể loại
2. Hiển thị danh sách thể loại dạng bảng
3. Có thể sửa trực tiếp trên bảng

**Luồng chính - Thêm thể loại:**
1. Click "Thêm thể loại sách"
2. Nhập tên thể loại
3. Validate
4. Lưu thể loại mới
5. Hiển thị thông báo thành công

**Luồng chính - Xóa thể loại:**
1. Click "Xóa" trên bảng
2. Hệ thống kiểm tra có sách thuộc thể loại không
3. Nếu không có → Hiển thị xác nhận
4. Xác nhận xóa
5. Xóa thể loại

**Luồng thay thế:**
- Có sách thuộc thể loại → Hiển thị lỗi "Không thể xóa thể loại đang có sách"
- Tên thể loại trùng → Hiển thị lỗi "Tên thể loại đã tồn tại"
- Validation thất bại → Hiển thị lỗi

**Edge cases:**
- Tên thể loại quá dài (>50 ký tự)
- Tên thể loại trống
- Xóa thể loại đang được sử dụng

---

### 2.2 Thêm Sách Mới (2.2.2)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính:**
1. Click "Thêm Sách Mới"
2. Nhập: Tên sách, Tác giả, Năm xuất bản, ISBN, Thể loại, Mô tả, Số lượng bản sách
3. Validate tất cả trường
4. Lưu sách vào database với trạng thái "Có sẵn"
5. Hiển thị thông báo "Thêm sách thành công"

**Luồng thay thế:**
- Validation thất bại → Hiển thị lỗi cụ thể → Sửa và thử lại
- ISBN đã tồn tại → Hiển thị lỗi "ISBN đã tồn tại"

**Edge cases:**
- Tên sách quá dài (>100 ký tự)
- ISBN không đúng định dạng (ISBN-10 hoặc ISBN-13)
- Số lượng <= 0
- Năm xuất bản không hợp lệ (<1900 hoặc >năm hiện tại)
- Thể loại không tồn tại
- Mô tả quá dài (>255 ký tự)

---

### 2.3 Xem Danh Sách Sách (2.2.3)
**Actor:** Tất cả người dùng (không cần login)

**Luồng chính:**
1. Truy cập trang danh sách sách
2. Hiển thị danh sách: Tên sách, Tác giả, Năm xuất bản, Thể loại, Số lượng có sẵn, Số lượng đang mượn
3. Phân trang: 10 sách/trang

**Luồng tìm kiếm:**
1. Nhập từ khóa (tên sách hoặc tác giả)
2. Click "Tìm kiếm"
3. Hiển thị kết quả

**Luồng lọc:**
1. Chọn thể loại từ dropdown
2. Hiển thị sách theo thể loại đã chọn

**Luồng sắp xếp:**
1. Chọn tiêu chí sắp xếp (Tên A-Z, Năm xuất bản mới nhất, Lượt mượn phổ biến)
2. Hiển thị danh sách đã sắp xếp

**Edge cases:**
- Không có kết quả tìm kiếm
- Danh sách rỗng
- Kết hợp tìm kiếm + lọc + sắp xếp

---

### 2.4 Xem Chi Tiết Sách (2.2.4)
**Actor:** Tất cả người dùng (không cần login)

**Luồng chính:**
1. Click vào sách từ danh sách
2. Hiển thị: Tên, Tác giả, ISBN, Năm xuất bản, Mô tả chi tiết, Số lượng bản đang có, đang mượn
3. Nếu là nhân viên → Hiển thị thêm lịch sử mượn (Độc giả, Ngày mượn, Ngày hết hạn)
4. Nếu là độc giả đã đăng nhập → Hiển thị nút "Mượn sách"

**Luồng thay thế:**
- Sách không tồn tại → Hiển thị lỗi 404
- Độc giả chưa đăng nhập → Không hiển thị nút "Mượn sách"

**Edge cases:**
- Sách đã bị xóa
- Sách không có sẵn (số lượng = 0)

---

### 2.5 Sửa & Xóa Sách (2.2.5)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính - Sửa sách:**
1. Xem chi tiết sách
2. Click "Sửa"
3. Chỉnh sửa thông tin
4. Validate
5. Lưu thay đổi
6. Hiển thị thông báo thành công

**Luồng chính - Xóa sách:**
1. Xem chi tiết sách
2. Click "Xóa"
3. Hệ thống kiểm tra có đơn mượn hoạt động không
4. Nếu không có → Hiển thị xác nhận
5. Xác nhận xóa
6. Xóa sách

**Luồng thay thế:**
- Có đơn mượn hoạt động → Hiển thị lỗi "Không thể xóa sách đang có đơn mượn"
- Validation thất bại → Hiển thị lỗi

**Edge cases:**
- Sách đang được mượn
- Sách có lịch sử mượn nhưng không có đơn hoạt động

---

## 3. QUẢN LÝ MƯỢN SÁCH

### 3.1 Mượn Sách (Độc Giả) (2.3.1)
**Actor:** Độc giả  
**Yêu cầu:** Đăng nhập với vai trò độc giả

**Luồng chính:**
1. Độc giả xem chi tiết sách
2. Click "Mượn Sách"
3. Hệ thống kiểm tra điều kiện:
   - Sách còn sẵn (số lượng > 0)
   - Độc giả không vượt quá số sách mượn tối đa (5 cuốn)
   - Không có khoản phạt chưa thanh toán
4. Chọn thời hạn mượn (mặc định 14 ngày, tối đa 30 ngày)
5. Tạo đơn mượn ở trạng thái "Chờ xác nhận"
6. Hiển thị thông báo thành công

**Luồng thay thế:**
- Sách không còn sẵn → Hiển thị lỗi "Sách không còn sẵn"
- Đã mượn quá 5 cuốn → Hiển thị lỗi "Bạn đã mượn tối đa số sách cho phép"
- Có khoản phạt chưa thanh toán → Hiển thị lỗi "Vui lòng thanh toán các khoản phạt trước khi mượn sách"

**Edge cases:**
- Độc giả đã mượn sách này trước đó (chưa trả)
- Thời hạn mượn vượt quá 30 ngày
- Độc giả có đơn mượn sách này đang chờ xác nhận

---

### 3.2 Mượn Sách (Nhân Viên Thư Viện) (2.3.2)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính - Xác nhận:**
1. Xem danh sách sách mượn chờ xác nhận
2. Click "Xác nhận"
3. Hệ thống cập nhật trạng thái đơn mượn thành "Đã mượn"
4. Giảm số lượng sách có sẵn
5. Hiển thị thông báo thành công

**Luồng chính - Từ chối:**
1. Xem danh sách sách mượn chờ xác nhận
2. Click "Từ chối"
3. Nhập lý do từ chối (bắt buộc)
4. Hệ thống cập nhật trạng thái thành "Bị từ chối" và lưu lý do
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Lý do từ chối trống → Hiển thị lỗi "Vui lòng nhập lý do từ chối"
- Đơn mượn không tồn tại → Hiển thị lỗi

**Edge cases:**
- Sách đã hết (số lượng = 0) khi xác nhận
- Độc giả đã mượn quá số lượng cho phép khi xác nhận
- Độc giả có khoản phạt khi xác nhận

---

### 3.3 Xem Lịch Sử Mượn Sách (Độc Giả) (2.3.3)
**Actor:** Độc giả  
**Yêu cầu:** Đăng nhập với vai trò độc giả

**Luồng chính - Xem danh sách:**
1. Truy cập trang "Lịch sử mượn sách"
2. Hiển thị:
   - Sách đang mượn: Tên, Tác giả, Ngày mượn, Hạn trả, Số ngày còn lại
   - Sách đã trả: Tên, Ngày mượn, Ngày trả
   - Sách bị từ chối: Tên, Tác giả, Lý do từ chối
3. Trạng thái: "Chờ xác nhận", "Đang mượn", "Quá hạn", "Đã trả", "Bị từ chối"

**Luồng chính - Lọc:**
1. Chọn trạng thái từ dropdown
2. Hiển thị danh sách theo trạng thái

**Luồng chính - Gia hạn:**
1. Tìm sách đang mượn chưa hết hạn
2. Click "Gia hạn"
3. Hệ thống kiểm tra: chưa hết hạn, chưa gia hạn lần nào
4. Gia hạn thêm 7 ngày
5. Hiển thị thông báo thành công

**Luồng chính - Yêu cầu trả sách:**
1. Tìm sách đang mượn
2. Click "Xin trả sách"
3. Xác nhận trong modal
4. Tạo yêu cầu trả sách ở trạng thái "Chờ xác nhận"

**Luồng thay thế:**
- Đã gia hạn rồi → Hiển thị lỗi "Bạn đã gia hạn sách này rồi"
- Sách đã hết hạn → Không hiển thị nút "Gia hạn"
- Đã có yêu cầu trả chờ xác nhận → Hiển thị lỗi "Đã có yêu cầu trả sách đang chờ xác nhận"

**Edge cases:**
- Sách quá hạn (hiển thị số ngày quá hạn)
- Đã gia hạn 1 lần (không cho gia hạn nữa)
- Xem lý do từ chối

---

## 4. TRẢ SÁCH

### 4.1 Yêu Cầu Trả Sách (2.4.1)
**Actor:** Độc giả  
**Yêu cầu:** Đăng nhập với vai trò độc giả

**Luồng chính:**
1. Vào trang "Lịch sử mượn sách"
2. Xem danh sách sách đang mượn
3. Click "Xin trả sách" trên sách muốn trả
4. Xác nhận trong modal
5. Hệ thống kiểm tra: chưa có yêu cầu trả chờ xác nhận
6. Tạo yêu cầu trả sách ở trạng thái "Chờ xác nhận"
7. Hiển thị thông báo thành công

**Luồng thay thế:**
- Đã có yêu cầu trả chờ xác nhận → Hiển thị lỗi "Đã có yêu cầu trả sách đang chờ xác nhận"
- Hủy xác nhận → Đóng modal, không tạo yêu cầu

**Edge cases:**
- Sách không tồn tại trong danh sách đang mượn
- Đơn mượn không hợp lệ

---

### 4.2 Xác Nhận Trả Sách (2.4.2)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính - Trả bình thường:**
1. Vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Nhận sách vật lý từ độc giả
4. Click "Xác nhận trả"
5. Chọn tình trạng sách: "Bình thường"
6. Xác nhận trả
7. Cập nhật đơn mượn thành "Đã trả"
8. Tăng sách có sẵn, giảm sách đang mượn
9. Hiển thị thông báo thành công

**Luồng chính - Trả hư hỏng:**
1. Vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Nhận sách vật lý từ độc giả
4. Click "Xác nhận trả"
5. Chọn tình trạng sách: "Hư hỏng"
6. Chọn mức phạt từ danh sách
7. Nhập ghi chú (bắt buộc)
8. Kiểm tra có trả muộn không
9. Nếu muộn → Tạo phiếu phạt "Trả muộn"
10. Tạo phiếu phạt cho hư hỏng
11. Cập nhật đơn mượn thành "Đã trả"
12. Hiển thị thông báo thành công

**Luồng chính - Trả mất:**
1. Vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Click "Xác nhận trả"
4. Chọn tình trạng sách: "Mất"
5. Chọn mức phạt từ danh sách
6. Nhập ghi chú (bắt buộc)
7. Kiểm tra có trả muộn không
8. Nếu muộn → Tạo phiếu phạt "Trả muộn"
9. Tạo phiếu phạt cho mất sách
10. Cập nhật đơn mượn thành "Đã trả"
11. Hiển thị thông báo thành công

**Luồng thay thế:**
- Chưa chọn tình trạng sách → Hiển thị lỗi "Vui lòng chọn tình trạng sách"
- Chưa chọn mức phạt (khi hư hỏng/mất) → Hiển thị lỗi "Vui lòng chọn mức phạt"
- Chưa nhập ghi chú (khi hư hỏng/mất) → Hiển thị lỗi "Vui lòng nhập ghi chú"
- Ghi chú quá dài (>500 ký tự) → Hiển thị lỗi

**Edge cases:**
- Sách vừa hư hỏng vừa trả muộn (tạo 2 phiếu phạt)
- Sách vừa mất vừa trả muộn (tạo 2 phiếu phạt)
- Không có mức phạt nào được cấu hình

---

## 5. QUẢN LÝ NỢ & PHẠT

### 5.1 Quản lý mức phạt (2.5.1)
**Actor:** Quản lý viên  
**Yêu cầu:** Đăng nhập với vai trò quản lý viên

**Luồng chính - Xem danh sách:**
1. Truy cập trang quản lý mức phạt
2. Hiển thị danh sách mức phạt dạng bảng
3. Có thể sửa trực tiếp trên bảng

**Luồng chính - Thêm mức phạt:**
1. Click "Thêm mức phạt"
2. Nhập: Tên mức phạt, Số tiền, Ngày phạt (mặc định ngày hiện tại)
3. Validate
4. Lưu mức phạt mới
5. Hiển thị thông báo thành công

**Luồng chính - Xóa mức phạt:**
1. Click "Xóa" trên bảng
2. Xác nhận xóa
3. Xóa mức phạt

**Luồng thay thế:**
- Validation thất bại → Hiển thị lỗi
- Tên mức phạt trùng → Hiển thị lỗi

**Edge cases:**
- Tên mức phạt quá dài (>25 ký tự)
- Số tiền <= 0
- Ngày phạt không hợp lệ
- Mức phạt đang được sử dụng trong phiếu phạt

---

### 5.2 Xem & Thanh Toán Khoản Phạt (Độc Giả) (2.5.2)
**Actor:** Độc giả  
**Yêu cầu:** Đăng nhập với vai trò độc giả

**Luồng chính - Xem danh sách:**
1. Truy cập trang "Khoản phạt"
2. Hiển thị danh sách khoản phạt chưa thanh toán
3. Thông tin: Nguyên nhân phạt, Số tiền, Ngày phạt, Trạng thái

**Luồng chính - Thanh toán:**
1. Chọn phiếu phạt ở trạng thái "Chưa thanh toán"
2. Click "Thanh toán"
3. Thanh toán bằng chuyển khoản qua ngân hàng
4. Nhấn "Đã thanh toán"
5. Phiếu phạt chuyển sang trạng thái "Chờ xác nhận"
6. Hiển thị thông báo "Đã gửi yêu cầu thanh toán, vui lòng chờ nhân viên xác nhận"

**Luồng thay thế:**
- Không có khoản phạt → Hiển thị "Bạn không có khoản phạt nào"

**Edge cases:**
- Phiếu phạt đã được xác nhận
- Phiếu phạt bị từ chối (hiển thị lý do)

---

### 5.3 Xem & Thanh Toán Khoản Phạt (Nhân Viên Thư Viện) (2.5.3)
**Actor:** Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò nhân viên

**Luồng chính - Xem danh sách:**
1. Truy cập trang "Quản lý khoản phạt"
2. Xem danh sách khoản phạt chưa thanh toán

**Luồng chính - Xem chi tiết:**
1. Click vào khoản phạt
2. Hiển thị chi tiết: Độc giả, Nguyên nhân, Số tiền, Ngày phạt, Trạng thái, Ghi chú

**Luồng chính - Xác nhận thanh toán:**
1. Xem chi tiết khoản phạt ở trạng thái "Chờ xác nhận"
2. Kiểm tra số tiền thanh toán có phù hợp không
3. Nếu phù hợp → Click "Đã thanh toán"
4. Cập nhật trạng thái thành "Đã thanh toán"
5. Hiển thị thông báo thành công

**Luồng chính - Từ chối thanh toán:**
1. Xem chi tiết khoản phạt ở trạng thái "Chờ xác nhận"
2. Kiểm tra số tiền thanh toán không phù hợp
3. Click "Từ chối"
4. Nhập lý do từ chối (bắt buộc)
5. Cập nhật trạng thái thành "Từ chối" và lưu lý do
6. Hiển thị thông báo thành công

**Luồng thay thế:**
- Lý do từ chối trống → Hiển thị lỗi "Vui lòng nhập lý do từ chối"

**Edge cases:**
- Số tiền thanh toán không khớp với số tiền phạt
- Độc giả chưa thanh toán nhưng nhấn "Đã thanh toán"

---

## 6. QUẢN LÝ NGƯỜI DÙNG

### 6.1 Danh Sách Người Dùng (2.6.1)
**Actor:** Quản lý viên  
**Yêu cầu:** Đăng nhập với vai trò quản lý viên

**Luồng chính - Xem danh sách:**
1. Truy cập trang "Quản lý người dùng"
2. Hiển thị: Email, Tên, Vai trò (Reader/Librarian/Admin), Ngày tham gia, Trạng thái (Kích hoạt/Vô hiệu hóa)

**Luồng chính - Tìm kiếm:**
1. Nhập từ khóa (email/tên) vào ô tìm kiếm
2. Click "Tìm kiếm" hoặc Enter
3. Hiển thị kết quả

**Luồng chính - Lọc theo vai trò:**
1. Chọn vai trò từ dropdown (Reader/Librarian/Admin/Tất cả)
2. Hiển thị danh sách theo vai trò

**Luồng chính - Vô hiệu hóa/Kích hoạt:**
1. Tìm người dùng trong danh sách
2. Click "Vô hiệu hóa" hoặc "Kích hoạt"
3. Xác nhận
4. Cập nhật trạng thái tài khoản
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không có kết quả tìm kiếm → Hiển thị "Không tìm thấy người dùng"
- Vô hiệu hóa chính mình → Hiển thị lỗi "Không thể vô hiệu hóa chính mình"

**Edge cases:**
- Tìm kiếm kết hợp với lọc
- Vô hiệu hóa tài khoản đang có đơn mượn hoạt động

---

### 6.2 Gán Vai Trò (2.6.2)
**Actor:** Quản lý viên  
**Yêu cầu:** Đăng nhập với vai trò quản lý viên

**Luồng chính:**
1. Xem danh sách người dùng
2. Click "Gán vai trò" trên người dùng
3. Chọn vai trò mới (Reader/Librarian/Admin)
4. Xác nhận
5. Cập nhật vai trò người dùng
6. Hiển thị thông báo thành công

**Luồng thay thế:**
- Gán vai trò cho chính mình → Hiển thị cảnh báo
- Vai trò không thay đổi → Hiển thị thông báo "Vai trò không thay đổi"

**Edge cases:**
- Gán vai trò Admin cho người dùng khác
- Thay đổi vai trò của người dùng đang hoạt động

---

## 7. BÁO CÁO & THỐNG KÊ

### 7.1 Báo Cáo Tổng Quan (Dashboard) (2.7.1)
**Actor:** Quản lý viên, Nhân viên  
**Yêu cầu:** Đăng nhập với vai trò quản lý viên hoặc nhân viên

**Luồng chính:**
1. Truy cập trang Dashboard
2. Hiển thị các thống kê:
   - Tổng số sách: Có sẵn / Đang mượn / Bị mất / Hư hỏng
   - Tổng số độc giả: Hoạt động / Vô hiệu hóa
   - Tổng đơn mượn hôm nay
   - Top 5 sách phổ biến nhất
   - Danh sách độc giả nợ quá hạn

**Luồng thay thế:**
- Không có dữ liệu → Hiển thị "Chưa có dữ liệu"

**Edge cases:**
- Dữ liệu rỗng
- Làm mới dữ liệu real-time

---

### 7.2 Báo Cáo Chi Tiết (2.7.2)
**Actor:** Quản lý viên, Nhân viên thư viện  
**Yêu cầu:** Đăng nhập với vai trò quản lý viên hoặc nhân viên

**Luồng chính - Xem báo cáo:**
1. Truy cập trang "Báo cáo chi tiết"
2. Chọn loại báo cáo:
   - Báo cáo Sách: Tổng số sách, tình trạng, số lần mượn
   - Báo cáo Mượn Trả: Số lần mượn/trả theo ngày/tháng/quý
   - Báo cáo Phạt: Tổng doanh thu phạt, người nợ ngoài hạn
   - Báo cáo Sách Mất/Hư: Danh sách sách cần thay thế
3. Chọn khoảng thời gian (Ngày, Tuần, Tháng, Quý, Năm)
4. Hiển thị báo cáo

**Luồng chính - Xuất CSV:**
1. Sau khi xem báo cáo
2. Click "Xuất CSV"
3. Tải file CSV về máy

**Luồng thay thế:**
- Không có dữ liệu trong khoảng thời gian → Hiển thị "Không có dữ liệu"

**Edge cases:**
- Khoảng thời gian không hợp lệ
- File CSV quá lớn

---

## Tổng Kết

Tổng cộng có **22 tính năng chính** được phân tích, mỗi tính năng có:
- Luồng chính (happy path)
- Luồng thay thế (alternative flows)
- Edge cases (các trường hợp đặc biệt)

Tất cả các flowchart sẽ được tạo trong các file riêng biệt theo format: `design/X.X-feature-name.md`

