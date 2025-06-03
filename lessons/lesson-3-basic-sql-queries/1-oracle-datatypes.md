# Kiểu Dữ Liệu Oracle Database

Hiểu về các kiểu dữ liệu Oracle Database là điều cơ bản để thiết kế và phát triển cơ sở dữ liệu hiệu quả. Oracle cung cấp một bộ kiểu dữ liệu tích hợp sẵn toàn diện để lưu trữ các loại thông tin khác nhau một cách hiệu quả. Hướng dẫn này bao gồm tất cả các kiểu dữ liệu chính có sẵn trong Oracle Database.

## Kiểu Dữ Liệu Ký Tự

### VARCHAR2(size)
- **Mô tả**: Dữ liệu ký tự độ dài biến đổi với kích thước tối đa được chỉ định
- **Lưu trữ**: 1 đến 4000 byte (32767 trong PL/SQL)
- **Trường hợp sử dụng**: Tên, mô tả, địa chỉ, dữ liệu văn bản chung
- **Ví dụ**: `VARCHAR2(100)` để lưu trữ tên lên đến 100 ký tự
- **Thực hành tốt**: Luôn chỉ định kích thước; sử dụng cho văn bản độ dài biến đổi

### CHAR(size)
- **Mô tả**: Dữ liệu ký tự độ dài cố định, được đệm bằng khoảng trắng
- **Lưu trữ**: 1 đến 2000 byte
- **Trường hợp sử dụng**: Mã định dạng cố định, cờ trạng thái, mã quốc gia
- **Ví dụ**: `CHAR(2)` để lưu trữ viết tắt bang như 'CA', 'NY'
- **Thực hành tốt**: Chỉ sử dụng khi tất cả giá trị có cùng độ dài

### NVARCHAR2(size)
- **Mô tả**: Dữ liệu ký tự Unicode độ dài biến đổi
- **Lưu trữ**: 1 đến 4000 byte
- **Trường hợp sử dụng**: Ứng dụng đa ngôn ngữ, văn bản quốc tế
- **Ví dụ**: `NVARCHAR2(200)` để lưu trữ tên bằng nhiều ngôn ngữ khác nhau
- **Thực hành tốt**: Sử dụng khi hỗ trợ nhiều bộ ký tự

### NCHAR(size)
- **Mô tả**: Dữ liệu ký tự Unicode độ dài cố định
- **Lưu trữ**: 1 đến 2000 byte
- **Trường hợp sử dụng**: Mã Unicode độ dài cố định
- **Ví dụ**: `NCHAR(10)` cho mã sản phẩm Unicode
- **Thực hành tốt**: Hiếm khi sử dụng; ưu tiên NVARCHAR2 cho dữ liệu Unicode

## Kiểu Dữ Liệu Số

### NUMBER(precision, scale)
- **Mô tả**: Dữ liệu số độ dài biến đổi với độ chính xác và thang đo tùy chọn
- **Lưu trữ**: 1 đến 22 byte
- **Độ chính xác**: Tổng số chữ số có nghĩa (1-38)
- **Thang đo**: Số chữ số bên phải dấu thập phân (-84 đến 127)
- **Trường hợp sử dụng**: Tiền tệ, tính toán, đo lường
- **Ví dụ**: 
  - `NUMBER(10,2)` cho tiền tệ (tối đa 99,999,999.99)
  - `NUMBER(5)` cho giá trị nguyên lên đến 99,999
  - `NUMBER` cho độ chính xác không giới hạn

### INTEGER
- **Mô tả**: Đồng nghĩa với NUMBER(38)
- **Lưu trữ**: Biến đổi (1 đến 22 byte)
- **Trường hợp sử dụng**: Số nguyên, bộ đếm, ID
- **Ví dụ**: `INTEGER` cho khóa chính
- **Thực hành tốt**: Sử dụng để rõ ràng khi xử lý số nguyên

### FLOAT(binary_precision)
- **Mô tả**: Số dấu phẩy động với độ chính xác nhị phân
- **Lưu trữ**: 1 đến 22 byte
- **Trường hợp sử dụng**: Tính toán khoa học cần số học dấu phẩy động
- **Ví dụ**: `FLOAT(24)` cho độ chính xác đơn, `FLOAT(53)` cho độ chính xác kép
- **Thực hành tốt**: Sử dụng NUMBER cho hầu hết ứng dụng kinh doanh

### BINARY_FLOAT
- **Mô tả**: Số dấu phẩy động 32-bit (IEEE 754)
- **Lưu trữ**: 4 byte
- **Trường hợp sử dụng**: Điện toán khoa học, tính toán quan trọng về hiệu suất
- **Phạm vi**: ±1.17549E-38 đến ±3.40282E+38
- **Thực hành tốt**: Sử dụng để tương thích với các hệ thống khác sử dụng chuẩn IEEE

### BINARY_DOUBLE
- **Mô tả**: Số dấu phẩy động 64-bit (IEEE 754)
- **Lưu trữ**: 8 byte
- **Trường hợp sử dụng**: Tính toán khoa học độ chính xác cao
- **Phạm vi**: ±2.22507485850720E-308 đến ±1.79769313486231E+308
- **Thực hành tốt**: Sử dụng cho tính toán dấu phẩy động độ chính xác cao

## Kiểu Dữ Liệu Ngày và Thời Gian

### DATE
- **Mô tả**: Ngày và thời gian từ 1 tháng 1, 4712 BC đến 31 tháng 12, 9999 AD
- **Lưu trữ**: 7 byte
- **Độ chính xác**: Giây
- **Trường hợp sử dụng**: Ngày sinh, ngày đặt hàng, thời gian hẹn
- **Ví dụ**: `DATE` lưu trữ cả thành phần ngày và thời gian
- **Thực hành tốt**: Lựa chọn mặc định cho hầu hết nhu cầu ngày/thời gian

### TIMESTAMP(fractional_seconds_precision)
- **Mô tả**: Ngày và thời gian với giây phân số
- **Lưu trữ**: 7 đến 11 byte
- **Độ chính xác**: 0 đến 9 chữ số cho giây phân số (mặc định 6)
- **Trường hợp sử dụng**: Audit trail, thời gian độ chính xác cao
- **Ví dụ**: `TIMESTAMP(3)` cho độ chính xác mili giây
- **Thực hành tốt**: Sử dụng khi cần độ chính xác dưới giây

### TIMESTAMP WITH TIME ZONE
- **Mô tả**: TIMESTAMP với thông tin múi giờ
- **Lưu trữ**: 13 byte
- **Trường hợp sử dụng**: Ứng dụng toàn cầu, lập lịch qua các múi giờ
- **Ví dụ**: Lưu trữ '2023-05-15 14:30:00.000000 -07:00'
- **Thực hành tốt**: Sử dụng cho ứng dụng kéo dài nhiều múi giờ

### TIMESTAMP WITH LOCAL TIME ZONE
- **Mô tả**: TIMESTAMP được chuẩn hóa theo múi giờ cơ sở dữ liệu
- **Lưu trữ**: 7 đến 11 byte
- **Trường hợp sử dụng**: Ứng dụng mà tất cả thời gian nên ở múi giờ cơ sở dữ liệu
- **Thực hành tốt**: Sử dụng khi muốn chuyển đổi múi giờ tự động

### INTERVAL YEAR TO MONTH
- **Mô tả**: Khoảng thời gian tính bằng năm và tháng
- **Lưu trữ**: 5 byte
- **Trường hợp sử dụng**: Tính tuổi, giai đoạn đăng ký
- **Ví dụ**: `INTERVAL YEAR(4) TO MONTH` cho đến 9999 năm
- **Thực hành tốt**: Sử dụng cho giai đoạn kinh doanh (hợp đồng, bảo hành)

### INTERVAL DAY TO SECOND
- **Mô tả**: Khoảng thời gian tính bằng ngày, giờ, phút, giây
- **Lưu trữ**: 11 byte
- **Trường hợp sử dụng**: Tính thời lượng, thời gian trôi qua
- **Ví dụ**: `INTERVAL DAY(2) TO SECOND(6)` cho đến 99 ngày với độ chính xác micro giây
- **Thực hành tốt**: Sử dụng cho đo lường thời lượng chính xác

## Kiểu Dữ Liệu Nhị Phân

### RAW(size)
- **Mô tả**: Dữ liệu nhị phân độ dài biến đổi
- **Lưu trữ**: 1 đến 2000 byte
- **Trường hợp sử dụng**: Đối tượng nhị phân nhỏ, checksum, dữ liệu mã hóa
- **Ví dụ**: `RAW(16)` để lưu trữ hash MD5
- **Thực hành tốt**: Sử dụng cho dữ liệu nhị phân nhỏ; ưu tiên BLOB cho dữ liệu lớn hơn

### LONG RAW
- **Mô tả**: Dữ liệu nhị phân độ dài biến đổi lên đến 2GB
- **Lưu trữ**: Lên đến 2GB
- **Trường hợp sử dụng**: Lưu trữ dữ liệu nhị phân legacy
- **Thực hành tốt**: **Đã lỗi thời** - sử dụng BLOB thay thế cho ứng dụng mới

## Kiểu Dữ Liệu Đối Tượng Lớn (LOB)

### CLOB
- **Mô tả**: Character Large Object cho dữ liệu văn bản lớn
- **Lưu trữ**: Lên đến 128TB
- **Trường hợp sử dụng**: Tài liệu, bài viết, trường văn bản lớn
- **Ví dụ**: Lưu trữ nội dung bài viết đầy đủ, bình luận người dùng
- **Thực hành tốt**: Sử dụng cho dữ liệu văn bản lớn hơn giới hạn VARCHAR2

### NCLOB
- **Mô tả**: National Character Large Object cho văn bản Unicode
- **Lưu trữ**: Lên đến 128TB
- **Trường hợp sử dụng**: Tài liệu văn bản đa ngôn ngữ lớn
- **Thực hành tốt**: Sử dụng cho dữ liệu văn bản Unicode lớn

### BLOB
- **Mô tả**: Binary Large Object cho dữ liệu nhị phân
- **Lưu trữ**: Lên đến 128TB
- **Trường hợp sử dụng**: Hình ảnh, video, tài liệu, tệp âm thanh
- **Ví dụ**: Lưu trữ tệp PDF, hình ảnh, nội dung đa phương tiện
- **Thực hành tốt**: Lựa chọn chính cho lưu trữ tệp nhị phân

### BFILE
- **Mô tả**: Locator tệp nhị phân trỏ đến tệp bên ngoài
- **Lưu trữ**: Tên thư mục và tên tệp
- **Trường hợp sử dụng**: Tệp lớn được lưu trữ trong hệ điều hành
- **Thực hành tốt**: Sử dụng khi tệp được quản lý bên ngoài cơ sở dữ liệu

## Kiểu Dữ Liệu Chuyên Biệt

### ROWID
- **Mô tả**: Định danh duy nhất cho các hàng trong bảng
- **Lưu trữ**: 10 byte
- **Trường hợp sử dụng**: Truy cập hàng nhanh, gỡ lỗi
- **Ví dụ**: Định danh hàng duy nhất do hệ thống tạo
- **Thực hành tốt**: Hiếm khi sử dụng trực tiếp; tự động được Oracle quản lý

### UROWID
- **Mô tả**: Universal ROWID cho các loại bảng khác nhau
- **Lưu trữ**: Biến đổi
- **Trường hợp sử dụng**: Bảng tổ chức chỉ mục, bảng ngoại
- **Thực hành tốt**: Sử dụng ROWID trừ khi làm việc với các loại bảng đặc biệt

## Kiểu Dữ Liệu JSON (Oracle 21c+)

### JSON
- **Mô tả**: Kiểu dữ liệu JSON gốc với xác thực và tối ưu hóa
- **Lưu trữ**: Biến đổi
- **Trường hợp sử dụng**: Tài liệu JSON, REST API, ứng dụng web hiện đại
- **Ví dụ**: Lưu trữ tùy chọn người dùng, dữ liệu cấu hình
- **Thực hành tốt**: Sử dụng cho dữ liệu JSON có cấu trúc cần xác thực

## Hướng Dẫn Lựa Chọn Kiểu Dữ Liệu

### Cho Dữ Liệu Văn Bản:
- **Văn bản ngắn, biến đổi**: VARCHAR2
- **Mã độ dài cố định**: CHAR
- **Tài liệu văn bản lớn**: CLOB
- **Nội dung đa ngôn ngữ**: NVARCHAR2 hoặc NCLOB

### Cho Số:
- **Tiền tệ/Kinh doanh**: NUMBER với độ chính xác phù hợp
- **Bộ đếm/ID**: INTEGER hoặc NUMBER
- **Tính toán khoa học**: BINARY_FLOAT hoặc BINARY_DOUBLE

### Cho Ngày:
- **Ngày/thời gian chung**: DATE
- **Thời gian độ chính xác cao**: TIMESTAMP
- **Ứng dụng toàn cầu**: TIMESTAMP WITH TIME ZONE
- **Tính toán thời lượng**: Kiểu INTERVAL

### Cho Dữ Liệu Nhị Phân:
- **Nhị phân nhỏ**: RAW
- **Tệp lớn**: BLOB
- **Tệp bên ngoài**: BFILE

## Chuyển Đổi Kiểu Dữ Liệu Phổ Biến

Oracle cung cấp chuyển đổi ngầm và tường minh giữa các kiểu dữ liệu tương thích:

```sql
-- Chuyển đổi ngầm (tự động)
NUMBER ↔ VARCHAR2 (khi là số)
DATE ↔ VARCHAR2 (sử dụng định dạng mặc định)

-- Chuyển đổi tường minh (sử dụng hàm)
TO_NUMBER('123.45')
TO_DATE('2023-05-15', 'YYYY-MM-DD')
TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
```

## Tóm Tắt Thực Hành Tốt

1. **Chọn kích thước phù hợp**: Không phân bổ quá mức (ví dụ: VARCHAR2(4000) cho trường 10 ký tự)
2. **Sử dụng độ chính xác phù hợp**: NUMBER(10,2) cho tiền tệ, không phải NUMBER
3. **Cân nhắc nhu cầu Unicode**: Sử dụng NVARCHAR2 cho ứng dụng quốc tế
4. **Ưu tiên kiểu chuẩn**: Sử dụng DATE thay vì VARCHAR2 cho ngày
5. **Lập kế hoạch cho tăng trưởng**: Cân nhắc khối lượng dữ liệu tương lai khi chọn kiểu LOB
6. **Xác thực ràng buộc**: Sử dụng ràng buộc CHECK để thực thi quy tắc dữ liệu
7. **Tài liệu hóa lựa chọn**: Bình luận về lý do chọn kiểu dữ liệu cụ thể

Hiểu về các kiểu dữ liệu này và cách sử dụng phù hợp là rất quan trọng để thiết kế các cơ sở dữ liệu Oracle hiệu quả, có thể mở rộng và biểu diễn chính xác dữ liệu kinh doanh của bạn.
