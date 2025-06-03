# Thiết Lập Oracle Cloud Database

Oracle Cloud cung cấp một gói miễn phí mạnh mẽ bao gồm các dịch vụ Autonomous Database hoàn hảo cho việc học Oracle Database mà không cần yêu cầu cài đặt cục bộ.

## Tổng Quan Oracle Cloud Free Tier

### Những Gì Được Bao Gồm (Luôn Miễn Phí)
- **Autonomous Transaction Processing**: 20GB lưu trữ, 1 OCPU
- **Autonomous Data Warehouse**: 20GB lưu trữ, 1 OCPU
- **Compute VM**: 1/8 OCPU, 1GB bộ nhớ
- **Block Storage**: 200GB tổng cộng
- **Object Storage**: 20GB
- **Không giới hạn thời gian** - thực sự miễn phí mãi mãi

### Lợi Ích Cho Việc Học Tập
- Các tính năng Oracle Database mới nhất
- Tự động vá lỗi và cập nhật
- Bảo mật và mã hóa tích hợp
- SQL Developer Web được bao gồm
- Khả năng Machine Learning
- Không yêu cầu phần cứng cục bộ

## Hướng Dẫn Thiết Lập Từng Bước

### Bước 1: Tạo Tài Khoản Oracle Cloud

1. Truy cập [cloud.oracle.com](https://cloud.oracle.com)
2. Nhấp "Start for free"
3. Điền vào biểu mẫu đăng ký:
   - Quốc gia/Lãnh thổ
   - Tên và email
   - Số điện thoại (để xác minh)
4. Xác minh số điện thoại qua SMS/cuộc gọi
5. Thêm phương thức thanh toán (bắt buộc nhưng sẽ không bị tính phí cho gói miễn phí)
6. Hoàn tất xác minh tài khoản

### Bước 2: Truy Cập Oracle Cloud Console

1. Đăng nhập vào Oracle Cloud
2. Điều hướng đến Oracle Cloud Infrastructure (OCI) Console
3. Chọn vùng chủ (chọn gần nhất với vị trí của bạn)
4. Làm quen với dashboard

### Bước 3: Tạo Autonomous Database

1. **Điều hướng đến Autonomous Database**:
   - Từ menu chính, chọn "Oracle Database"
   - Chọn "Autonomous Transaction Processing" (ATP)

2. **Tạo Database Instance**:
   - Nhấp "Create Autonomous Database"
   - Điền thông tin bắt buộc:
     - **Display name**: `OracleLearnDB`
     - **Database name**: `LEARNDB`
     - **Workload type**: Transaction Processing
     - **Deployment type**: Shared Infrastructure

3. **Cấu hình Database**:
   - **Always Free**: Bật ON (quan trọng!)
   - **Database version**: Phiên bản mới nhất có sẵn
   - **OCPU count**: 1 (cố định cho gói miễn phí)
   - **Storage**: 20GB (tối đa cho gói miễn phí)
   - **Auto scaling**: OFF (không có sẵn trong gói miễn phí)

4. **Đặt Thông Tin Đăng Nhập Administrator**:
   - **Username**: ADMIN (mặc định)
   - **Password**: Chọn mật khẩu mạnh (lưu lại!)
   - **Confirm password**: Nhập lại mật khẩu

5. **Chọn Network Access**:
   - **Access Type**: Secure access from everywhere
   - **Mutual TLS**: Required (mặc định)

6. **Chọn License Type**:
   - **License Included** (cho gói miễn phí)

7. **Advanced Options** (tùy chọn):
   - **Contact email**: Email của bạn để nhận thông báo
   - Tags: Thêm nếu cần để tổ chức

8. **Tạo Database**:
   - Xem lại cài đặt
   - Nhấp "Create Autonomous Database"
   - Đợi 2-3 phút để cung cấp

### Bước 4: Truy Cập Database Của Bạn

Sau khi database được tạo (trạng thái hiển thị "Available"):

1. **Database Actions (SQL Developer Web)**:
   - Nhấp vào tên database của bạn
   - Nhấp "Database Actions"
   - Đăng nhập với ADMIN và mật khẩu của bạn
   - Bây giờ bạn có quyền truy cập SQL Developer Web

2. **Download Client Credentials (Wallet)**:
   - Nhấp "DB Connection"
   - Nhấp "Download Wallet"
   - Nhập mật khẩu wallet (lưu lại!)
   - Tải xuống và lưu file zip
   - Wallet này cần thiết cho kết nối client desktop

## Kết Nối Với Công Cụ Desktop

### Kết Nối SQL Developer Desktop

1. **Tải SQL Developer**:
   - Truy cập [trang tải SQL Developer của Oracle](https://www.oracle.com/tools/downloads/sqldev-downloads.html)
   - Tải xuống và cài đặt

2. **Tạo Kết Nối Mới**:
   - Mở SQL Developer
   - Right-click "Connections" → "New Connection"
   - Điền chi tiết kết nối:
     - **Connection Name**: Oracle Cloud Learn
     - **Username**: ADMIN
     - **Password**: Mật khẩu ADMIN của bạn
     - **Connection Type**: Cloud Wallet
     - **Configuration File**: Duyệt đến file wallet zip đã tải
     - **Service**: Chọn tên service database của bạn

3. **Test và Kết Nối**:
   - Nhấp "Test" để xác minh kết nối
   - Nhấp "Connect" để thiết lập kết nối

### Sử Dụng SQL Developer Web

SQL Developer Web tự động có sẵn với Autonomous Database của bạn:

1. **Truy Cập Tính Năng**:
   - **SQL Worksheet**: Viết và thực thi lệnh SQL
   - **Data Modeler**: Thiết kế schema database
   - **REST Services**: Tạo REST APIs
   - **JSON**: Làm việc với dữ liệu JSON
   - **Database Actions**: Các tác vụ quản trị

2. **Điều Hướng**:
   - Sử dụng panel bên trái để duyệt các đối tượng database
   - Tạo tables, views và các đối tượng database khác
   - Giám sát hiệu suất database

## Làm Việc Với Oracle Cloud Database

### Các Thao Tác Cơ Bản

1. **Start/Stop Database**:
   - Điều hướng đến database của bạn trong OCI Console
   - Sử dụng nút "Start" hoặc "Stop" để kiểm soát database
   - Dừng database tiết kiệm tài nguyên tính toán

2. **Scaling Resources**:
   - Nhấp "Scale Up/Down" (không có sẵn trong gói miễn phí)
   - Sửa đổi OCPU và storage theo nhu cầu
   - Thay đổi có hiệu lực ngay lập tức

3. **Backup và Recovery**:
   - Backup tự động được bật theo mặc định
   - Thời gian lưu trữ 60 ngày
   - Point-in-time recovery có sẵn

### Giám Sát và Quản Lý

1. **Performance Monitoring**:
   - Giám sát hiệu suất tích hợp
   - Metrics và alerts thời gian thực
   - Thông tin chi tiết về hiệu suất truy vấn

2. **Tính Năng Bảo Mật**:
   - Luôn được mã hóa (khi nghỉ và truyền tải)
   - Kiểm soát truy cập mạng
   - Audit logging được bật

## Quản Lý Chi Phí

### Giới Hạn Free Tier
- **Always Free**: 20GB lưu trữ, 1 OCPU
- **$300 Free Credits**: Trong 30 ngày (nâng cấp tùy chọn)
- **Monitoring**: Theo dõi sử dụng trong billing console

### Best Practices
- Giám sát sử dụng thường xuyên
- Dừng database khi không sử dụng (tiết kiệm credits nếu nâng cấp)
- Sử dụng gói Always Free cho việc học tập
- Thiết lập cảnh báo billing

## Khắc Phục Các Vấn Đề Thường Gặp

### Vấn Đề Kết Nối
```sql
-- Test kết nối từ SQL Developer Web
SELECT 'Connection successful' AS status FROM dual;

-- Kiểm tra trạng thái database
SELECT instance_name, status FROM v$instance;
```

### Vấn Đề Wallet
- Đảm bảo wallet được giải nén đến vị trí an toàn
- Xác minh mật khẩu wallet chính xác
- Kiểm tra sqlnet.ora trỏ đến thư mục wallet đúng

### Vấn Đề Hiệu Suất
- Giám sát sử dụng CPU và storage
- Kiểm tra các truy vấn chạy lâu
- Sử dụng công cụ hiệu suất tích hợp

## Best Practices Bảo Mật

### Quản Lý Mật Khẩu
- Sử dụng mật khẩu mạnh, duy nhất
- Thay đổi mật khẩu mặc định ngay lập tức
- Lưu trữ mật khẩu an toàn

### Bảo Mật Mạng
- Sử dụng VPN khi có thể
- Giới hạn truy cập IP nếu cần
- Bật MFA trên tài khoản Oracle Cloud

### Bảo Vệ Dữ Liệu
- Backup thường xuyên (tự động)
- Test thủ tục restore
- Giám sát access logs

## Tính Năng Nâng Cao Có Sẵn

### Machine Learning
- Thuật toán machine learning trong database
- Khả năng AutoML
- Tích hợp Python và R

### Hỗ Trợ JSON
- Kiểu dữ liệu JSON gốc
- Các hàm truy vấn và thao tác JSON
- Tạo REST API

### Analytics
- Các hàm phân tích tích hợp
- Công cụ trực quan hóa dữ liệu
- Tích hợp với Oracle Analytics Cloud

## Các Bước Tiếp Theo

Sau khi thiết lập Oracle Cloud:

1. **Xác Minh Kết Nối**: Test cả truy cập web và desktop client
2. **Khám Phá Interface**: Làm quen với Database Actions
3. **Tạo Dữ Liệu Mẫu**: Theo dõi hướng dẫn tạo sample database
4. **Bắt Đầu Học**: Bắt đầu với các truy vấn SQL cơ bản

Oracle Cloud database của bạn giờ đã sẵn sàng cho việc học tập và phát triển!
