# Kiểu Dữ Liệu Oracle Database

Hiểu về các kiểu dữ liệu Oracle Database là điều cơ bản để thiết kế và phát triển cơ sở dữ liệu hiệu quả. Oracle cung cấp một bộ kiểu dữ liệu tích hợp sẵn toàn diện để lưu trữ các loại thông tin khác nhau một cách hiệu quả. Hướng dẫn này bao gồm tất cả các kiểu dữ liệu chính có sẵn trong Oracle Database.




## Tóm Tắt Kiểu Dữ Liệu Oracle

### Bảng Tóm Tắt Nhanh

| **Nhóm** | **Kiểu Dữ Liệu** | **Kích Thước** | **Mô Tả Ngắn** |
|----------|-------------------|----------------|-----------------|
| **Ký Tự** 
| | VARCHAR2(size) | 1-4000 byte | Văn bản độ dài biến đổi |
| | CHAR(size) | 1-2000 byte | Văn bản độ dài cố định |
| | NVARCHAR2(size) | 1-4000 byte | Unicode văn bản biến đổi |
| | NCHAR(size) | 1-2000 byte | Unicode văn bản cố định |
| **Số** 
| | NUMBER(p,s) | 1-22 byte | Số thập phân với độ chính xác |
| | INTEGER | Biến đổi | Số nguyên 32-bit (-2^31 đến 2^31-1) |
| | SMALLINT | Biến đổi | Số nguyên nhỏ (tối ưu) (-32768 đến 32767) |
| | FLOAT | 1-22 byte | Số dấu phẩy động |
| | BINARY_FLOAT | 4 byte | Số thực 32-bit IEEE 754 |
| | BINARY_DOUBLE | 8 byte | Số thực 64-bit IEEE 754 |
| **Ngày/Giờ** 
| | DATE | 7 byte | Ngày và giờ |
| | TIMESTAMP | 7-11 byte | Ngày giờ với độ chính xác cao |
| | TIMESTAMP WITH TIME ZONE | 13 byte | Có múi giờ |
| | INTERVAL | 5-11 byte | Khoảng thời gian |
| **Nhị Phân** 
| | RAW(size) | 1-2000 byte | Dữ liệu nhị phân nhỏ |
| | BLOB | Đến 128TB | Đối tượng nhị phân lớn |
| **Văn Bản Lớn** 
| | CLOB | Đến 128TB | Văn bản lớn |
| | NCLOB | Đến 128TB | Unicode văn bản lớn |
| **Đặc Biệt** 
| | ROWID | 10 byte | Định danh hàng |
| | JSON | Biến đổi | Dữ liệu JSON (21c+) |
| | VECTOR (oracle 23ai)

### Lựa Chọn Nhanh Theo Mục Đích

- 🔤 **Tên, địa chỉ**: VARCHAR2(50-500)
- 💰 **Tiền tệ**: NUMBER(10,2)
- 📅 **Ngày tháng**: DATE hoặc TIMESTAMP
- 🔢 **Đếm, ID**: INTEGER hoặc NUMBER
- 📱 **Mã quốc gia**: CHAR(2)
- 📄 **Tài liệu dài**: CLOB
- 🖼️ **Hình ảnh, file**: BLOB
- 🌍 **Đa ngôn ngữ**: NVARCHAR2

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
- **precision**: Tổng số chữ số có nghĩa (1-38)
- **scale**: Số chữ số bên phải dấu thập phân (-84 đến 127)
- **Phạm vi**: 
  - Số dương: 1.0 x 10^-130 đến 9.99...99 x 10^125 (với 38 chữ số)
  - Số âm: -9.99...99 x 10^125 đến -1.0 x 10^-130 (với 38 chữ số)
  - Số 0
- **Trường hợp sử dụng**: Tiền tệ, tính toán, đo lường
- **Ví dụ**: 
  - `NUMBER(10,2)` cho tiền tệ (tối đa 99,999,999.99)
  - `NUMBER(5,-2)` cho tiền tệ làm tròn đến hàng trăm (11510 -> )
  - `NUMBER(5)` cho giá trị nguyên lên đến 99,999
  - `NUMBER` cho độ chính xác không giới hạn (trong phạm vi hỗ trợ)
  **Trường hợp đặc biệt**: `NUMBER(5, 10)`: có phần scale > precision, khi đó oracle chỉ lưu trữ 5 chữ số có nghĩa đầu tiên, 5 chữ số phía sau sẽ hiển thị 0.
    **Ví dụ**:
      - **Với giá trị: 0.123456789123456** khi lưu trữ trong oracle sẽ thành 0.1234500000 (số 0 phần nguyên sẽ không được xem là một số có nghĩa theo định nghĩa oracle)
      - **với giá trị: 66,666,666** là số nguyên có 8 chữ số trước dấu phẩy (tất cả đều là số có nghĩa), nhưng `NUMBER(5, 10)` chỉ chứa 5 số có nghĩa nên khi lưu trữ trong oracle sẽ bị lỗi **ORA-06502: PL/SQL: numeric or value error: number precision too larg**

### INTEGER
- **Mô tả**: Kiểu số nguyên 32-bit có dấu
- **Lưu trữ**: Biến đổi (1 đến 22 byte)
- **Phạm vi**: -2,147,483,648 đến 2,147,483,647 (-(2^31) đến (2^31)-1)
- **Trường hợp sử dụng**: Số nguyên, bộ đếm, ID trong phạm vi giới hạn
- **Ví dụ**: `INTEGER` cho khóa chính, số lượng sản phẩm
- **Thực hành tốt**: Sử dụng cho số nguyên trong phạm vi 32-bit; dùng NUMBER cho phạm vi lớn hơn

### FLOAT(binary_precision)
- **Mô tả**: Số dấu phẩy động với độ chính xác nhị phân
- **Lưu trữ**: 1 đến 22 byte
- **Độ chính xác nhị phân**: 1 đến 126 bit (mặc định 126)
- **Phạm vi**: Tương tự NUMBER nhưng với biểu diễn nhị phân
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
- **Phạm vi**: ±2.22507485850720E-308 đến ±1.79769313486231E+308
- **Độ chính xác**: Khoảng 15-17 chữ số thập phân
- **Trường hợp sử dụng**: Tính toán khoa học độ chính xác cao
- **Thực hành tốt**: Sử dụng cho tính toán dấu phẩy động độ chính xác cao

### SMALLINT
- **Mô tả**: Đồng nghĩa với NUMBER(38), nhưng được tối ưu cho số nguyên nhỏ
- **Lưu trữ**: Biến đổi (1 đến 22 byte)
- **Phạm vi**: Tương tự NUMBER, nhưng thường dùng cho giá trị nhỏ
- **Trường hợp sử dụng**: Số tuổi, số tháng, cờ trạng thái số
- **Ví dụ**: `SMALLINT` cho trường age, status_code
- **Thực hành tốt**: Sử dụng cho số nguyên có giá trị nhỏ để tối ưu hiệu suất


### So Sánh Các Kiểu Số Oracle

| **Kiểu** | **Phạm vi** | **Độ chính xác** | **Khi nào sử dụng** |
|-----------|-------------|------------------|---------------------|
| **INTEGER** | -2,147,483,648 đến 2,147,483,647 | Số nguyên | ID, đếm trong phạm vi 32-bit |
| **SMALLINT** | Tương tự NUMBER(38) | Số nguyên | Số nhỏ (tuổi, tháng, trạng thái) |
| **NUMBER** | 1.0×10^-130 đến 9.99×10^125 | Lên đến 38 chữ số | Tiền tệ, tính toán chính xác |
| **NUMBER(p,s)** | Theo precision/scale | p chữ số, s thập phân | Tiền tệ với định dạng cố định |
| **FLOAT** | Tương tự NUMBER | Nhị phân | Tính toán khoa học |
| **BINARY_FLOAT** | ±1.17549E-38 đến ±3.40282E+38 | ~7 chữ số | Hiệu suất cao, IEEE 754 |
| **BINARY_DOUBLE** | ±2.22507E-308 đến ±1.79769E+308 | ~15-17 chữ số | Độ chính xác cao, IEEE 754 |

### Lưu Ý Quan Trọng Về Kiểu Số

#### INTEGER vs NUMBER
- **INTEGER** không phải là NUMBER(38) như nhiều người nghĩ
- **INTEGER** có giới hạn 32-bit: -2,147,483,648 đến 2,147,483,647
- **NUMBER(38)** có thể lưu trữ số lên đến 38 chữ số (rất lớn)
- **Khuyến nghị**: Dùng INTEGER cho ID và đếm nhỏ, NUMBER cho giá trị lớn

#### Chọn Kiểu Số Phù Hợp
```sql
-- Cho ID sản phẩm (thường < 2 tỷ)
product_id INTEGER

-- Cho doanh số (cần chính xác thập phân)
revenue NUMBER(15,2)

-- Cho tỷ lệ phần trăm
percentage NUMBER(5,2)  -- 999.99%

-- Cho tính toán khoa học
calculation_result BINARY_DOUBLE

-- Cho đếm số lượng lớn
total_records NUMBER(12)  -- Lên đến 999,999,999,999
```

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

## Cách Phân Biệt Kiểu Dữ Liệu Bằng Mắt

### 1. Nhận Diện Qua Giá Trị Mẫu

#### Kiểu Văn Bản:
- **VARCHAR2/CHAR**: `'John Doe'`, `'Hà Nội'`, `'hello@email.com'`
- **Dấu hiệu**: Có dấu ngoặc đơn `' '`, chứa chữ cái, ký tự đặc biệt

#### Kiểu Số:
- **NUMBER**: `123`, `456.78`, `-999.99`, `0`
- **INTEGER**: `1`, `100`, `-50` (không có dấu thập phân)
- **Dấu hiệu**: Chỉ chứa chữ số, dấu âm, dấu thập phân

#### Kiểu Ngày:
- **DATE**: `'2023-12-25'`, `'25-DEC-23'`, `'2023/12/25 14:30:00'`
- **TIMESTAMP**: `'2023-12-25 14:30:25.123456'`
- **Dấu hiệu**: Định dạng ngày/tháng/năm, có thể kèm giờ:phút:giây

#### Kiểu Đặc Biệt:
- **NULL**: Không có giá trị, hiển thị là `NULL`
- **BLOB/CLOB**: Hiển thị như `<BLOB>` hoặc text rất dài
- **ROWID**: Dạng `AAAEPAAGAAAAACAAA`


### 2. Dấu Hiệu Trực Quan Trong SQL Developer/Tools

- **Số**: Căn phải trong cột
- **Văn bản**: Căn trái trong cột  
- **Ngày**: Định dạng ngày/giờ đặc trưng
- **NULL**: Hiển thị rỗng hoặc `(null)`

## Chuyển Đổi Kiểu Dữ Liệu

### 1. Chuyển Đổi Tự Động (Implicit Conversion)

Oracle tự động chuyển đổi trong một số trường hợp:

```sql
-- Số thành văn bản (khi nối chuỗi)
SELECT 'ID: ' || 123 FROM dual;
-- Kết quả: 'ID: 123'

-- Văn bản thành số (khi tính toán)
SELECT '100' + 50 FROM dual;
-- Kết quả: 150

-- Ngày thành văn bản
SELECT 'Hôm nay: ' || SYSDATE FROM dual;
-- Kết quả: 'Hôm nay: 22-JUN-25'
```

### 2. Chuyển Đổi Thủ Công (Explicit Conversion)

#### A. Chuyển Thành Số

```sql
-- Văn bản thành số
SELECT TO_NUMBER('123.45') FROM dual;
SELECT TO_NUMBER('1,234.56', '9,999.99') FROM dual;

-- Ngày thành số (số ngày từ epoch)
SELECT TO_NUMBER(SYSDATE - DATE '1970-01-01') FROM dual;

-- Xử lý lỗi chuyển đổi
SELECT TO_NUMBER('123abc', DEFAULT 0 ON CONVERSION ERROR) FROM dual;
-- Kết quả: 0 (thay vì lỗi)
```

#### B. Chuyển Thành Văn Bản

```sql
-- Số thành văn bản
SELECT TO_CHAR(12345.67) FROM dual;
SELECT TO_CHAR(12345.67, '999,999.99') FROM dual;
SELECT TO_CHAR(12345.67, 'L999,999.99') FROM dual; -- Với ký hiệu tiền tệ

-- Ngày thành văn bản
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM dual;
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') FROM dual;
SELECT TO_CHAR(SYSDATE, 'Day, DD Month YYYY', 'NLS_DATE_LANGUAGE=VIETNAMESE') FROM dual;

-- Số với định dạng đặc biệt
SELECT TO_CHAR(1234567.89, '9,999,999.99') FROM dual; -- 1,234,567.89
SELECT TO_CHAR(123, '000000') FROM dual; -- 000123
```

#### C. Chuyển Thành Ngày

```sql
-- Văn bản thành ngày
SELECT TO_DATE('2023-12-25', 'YYYY-MM-DD') FROM dual;
SELECT TO_DATE('25/12/2023 14:30', 'DD/MM/YYYY HH24:MI') FROM dual;
SELECT TO_DATE('Dec 25, 2023', 'MON DD, YYYY') FROM dual;

-- Số thành ngày (từ timestamp)
SELECT TO_DATE('1703520000', 'J') FROM dual; -- Julian date
```

### 3. Chuyển Đổi Giữa Các Kiểu Ngày/Giờ

```sql
-- DATE thành TIMESTAMP
SELECT CAST(SYSDATE AS TIMESTAMP) FROM dual;

-- TIMESTAMP thành DATE
SELECT CAST(SYSTIMESTAMP AS DATE) FROM dual;

-- Thêm múi giờ
SELECT FROM_TZ(TIMESTAMP '2023-12-25 14:30:00', '+07:00') FROM dual;

-- Chuyển múi giờ
SELECT SYSTIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh' FROM dual;
```

### 4. Chuyển Đổi LOB

```sql
-- CLOB thành VARCHAR2 (nếu đủ nhỏ)
SELECT SUBSTR(clob_column, 1, 4000) FROM table_name;

-- VARCHAR2 thành CLOB
SELECT TO_CLOB(varchar2_column) FROM table_name;

-- BLOB thành RAW (nếu đủ nhỏ)
SELECT UTL_RAW.SUBSTR(blob_column, 1, 2000) FROM table_name;
```

### 5. Chuyển Đổi Trong DDL (Thay Đổi Cấu Trúc Bảng)

```sql
-- Thay đổi kiểu dữ liệu cột
ALTER TABLE employees MODIFY (salary NUMBER(10,2));

-- Thay đổi từ VARCHAR2 thành NUMBER (cần đảm bảo dữ liệu hợp lệ)
ALTER TABLE products MODIFY (price NUMBER(8,2));

-- Thay đổi kích thước VARCHAR2
ALTER TABLE customers MODIFY (customer_name VARCHAR2(200));

-- Chuyển đổi phức tạp qua cột tạm
ALTER TABLE orders ADD (order_date_new DATE);
UPDATE orders SET order_date_new = TO_DATE(order_date_text, 'DD/MM/YYYY');
ALTER TABLE orders DROP COLUMN order_date_text;
ALTER TABLE orders RENAME COLUMN order_date_new TO order_date;
```

### 6. Hàm Chuyển Đổi Hữu Ích

```sql
-- CAST - Chuyển đổi chuẩn SQL
SELECT CAST('123' AS NUMBER) FROM dual;
SELECT CAST(SYSDATE AS VARCHAR2(20)) FROM dual;

-- CONVERT - Chuyển đổi bộ ký tự
SELECT CONVERT('Hội nghị', 'UTF8', 'AL32UTF8') FROM dual;

-- HEXTORAW và RAWTOHEX - Chuyển đổi hex
SELECT HEXTORAW('48656C6C6F') FROM dual; -- 'Hello' in hex
SELECT RAWTOHEX(UTL_RAW.CAST_TO_RAW('Hello')) FROM dual;

-- Kiểm tra khả năng chuyển đổi
SELECT VALIDATE_CONVERSION('123.45' AS NUMBER) FROM dual; -- 1 nếu OK
SELECT VALIDATE_CONVERSION('abc' AS NUMBER) FROM dual; -- 0 nếu lỗi
```


### 8. Bảng Tham Khảo Chuyển Đổi

| **Từ** | **Sang** | **Hàm** | **Ví Dụ** |
|---------|----------|---------|-----------|
| VARCHAR2 | NUMBER | TO_NUMBER() | `TO_NUMBER('123.45')` |
| NUMBER | VARCHAR2 | TO_CHAR() | `TO_CHAR(123.45, '999.99')` |
| VARCHAR2 | DATE | TO_DATE() | `TO_DATE('2023-12-25', 'YYYY-MM-DD')` |
| DATE | VARCHAR2 | TO_CHAR() | `TO_CHAR(SYSDATE, 'DD/MM/YYYY')` |
| DATE | TIMESTAMP | CAST() | `CAST(SYSDATE AS TIMESTAMP)` |
| TIMESTAMP | DATE | CAST() | `CAST(SYSTIMESTAMP AS DATE)` |
| CLOB | VARCHAR2 | SUBSTR() | `SUBSTR(clob_col, 1, 4000)` |
| VARCHAR2 | CLOB | TO_CLOB() | `TO_CLOB(varchar_col)` |

### 9. Lưu Ý Quan Trọng

- ⚠️ **Luôn backup** trước khi thay đổi kiểu dữ liệu
- 🔍 **Kiểm tra dữ liệu** trước khi chuyển đổi
- 📏 **Chú ý kích thước**: VARCHAR2(10) không thể chứa số 12345.67890
- 🌐 **Múi giờ**: Cẩn thận khi chuyển đổi TIMESTAMP có múi giờ
- 🎯 **Độ chính xác**: NUMBER(5,2) chỉ chứa được 999.99

Hiểu rõ cách phân biệt và chuyển đổi kiểu dữ liệu sẽ giúp bạn làm việc hiệu quả hơn với Oracle Database và tránh được nhiều lỗi phổ biến trong quá trình phát triển ứng dụng.
