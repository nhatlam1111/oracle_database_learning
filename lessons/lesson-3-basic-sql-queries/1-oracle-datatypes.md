# Kiểu Dữ Liệu Oracle Database

Hiểu về các kiểu dữ liệu Oracle Database là điều cơ bản để thiết kế và phát triển cơ sở dữ liệu hiệu quả. Oracle cung cấp một bộ kiểu dữ liệu tích hợp sẵn toàn diện để lưu trữ các loại thông tin khác nhau một cách hiệu quả. Hướng dẫn này bao gồm tất cả các kiểu dữ liệu chính có sẵn trong Oracle Database.

# Reference:
https://g.co/gemini/share/1767eef8f265
https://www.databasestar.com/oracle-data-types/
https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Data-Types.html#GUID-1E278F1C-0EC1-4626-8D93-80D8230AB8F1



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
- **Mô tả**: Kiểu dữ liệu ký tự có độ dài biến đổi, chỉ sử dụng đúng bằng số byte cần thiết để lưu trữ dữ liệu thực tế. Đây là kiểu dữ liệu phổ biến nhất cho văn bản trong Oracle.
- **Lưu trữ**: 
  - Trong bảng: 1 đến 4000 byte
  - Trong PL/SQL: 1 đến 32767 byte
  - Sử dụng encoding UTF-8, mỗi ký tự tiếng Việt có thể chiếm 2-3 byte
- **Đặc điểm kỹ thuật**:
  - Không đệm khoảng trắng (space-efficient)
  - Hỗ trợ bộ ký tự database charset (thường AL32UTF8)
  - So sánh theo quy tắc case-sensitive
- **Trường hợp sử dụng**: 
  - Tên người, địa chỉ, email, số điện thoại
  - Mô tả sản phẩm, ghi chú
  - URL, username, password hash
- **Ví dụ thực tế**: 
  ```sql
  customer_name VARCHAR2(100)    -- 'Nguyễn Văn A'
  email VARCHAR2(150)           -- 'user@example.com'  
  description VARCHAR2(500)     -- Mô tả chi tiết sản phẩm
  ```
- **Thực hành tốt**: 
  - Luôn chỉ định kích thước phù hợp (không quá lớn)
  - Lựa chọn mặc định cho hầu hết dữ liệu văn bản
  - Cân nhắc tăng kích thước 20-30% để dự phòng mở rộng

### CHAR(size)
- **Mô tả**: Kiểu dữ liệu ký tự có độ dài cố định, luôn sử dụng đúng số byte được khai báo và tự động đệm khoảng trắng bên phải nếu dữ liệu ngắn hơn.
- **Lưu trữ**: 1 đến 2000 byte (luôn chiếm đủ size được khai báo)
- **Đặc điểm kỹ thuật**:
  - Tự động đệm khoảng trắng (space-padded)
  - Hiệu suất so sánh nhanh hơn VARCHAR2 một chút
  - Phù hợp cho dữ liệu có format cố định
- **Trường hợp sử dụng**: 
  - Mã quốc gia: VN, US, JP (luôn 2 ký tự)
  - Trạng thái: Y/N, A/I (Active/Inactive)
  - Mã phân loại có độ dài cố định
- **Ví dụ thực tế**: 
  ```sql
  country_code CHAR(2)      -- 'VN', 'US' (lưu thành 'VN ', 'US ')
  gender CHAR(1)           -- 'M', 'F', 'O'
  status CHAR(1)           -- 'A' (Active), 'I' (Inactive)
  currency_code CHAR(3)    -- 'USD', 'VND', 'EUR'
  ```
- **Lưu ý quan trọng**:
  ```sql
  -- CHAR tự động đệm khoảng trắng
  INSERT INTO countries VALUES ('VN');  -- Thực tế lưu 'VN '
  
  -- So sánh vẫn hoạt động bình thường
  WHERE country_code = 'VN'   -- ✅ Tìm thấy
  WHERE country_code = 'VN '  -- ✅ Cũng tìm thấy
  
  -- Nhưng LENGTH trả về kích thước không đệm
  SELECT LENGTH(country_code) FROM countries; -- Trả về 2, không phải 3
  ```
- **Thực hành tốt**: 
  - Chỉ dùng khi dữ liệu thực sự có độ dài cố định
  - Tránh dùng cho dữ liệu có thể thay đổi độ dài
  - Tiết kiệm cho việc indexing và joining

### NVARCHAR2(size)
- **Mô tả**: Kiểu dữ liệu ký tự Unicode độ dài biến đổi, được thiết kế đặc biệt để hỗ trợ đa ngôn ngữ và các bộ ký tự đặc biệt. Sử dụng National Character Set của database.
- **Lưu trữ**: 
  - 1 đến 4000 byte (có thể ít ký tự hơn do Unicode)
  - Mỗi ký tự có thể chiếm 1-4 byte tùy theo bộ ký tự
- **Đặc điểm kỹ thuật**:
  - Sử dụng National Character Set (thường UTF-16 hoặc UTF-8)
  - Hỗ trợ tốt nhất cho đa ngôn ngữ
  - Tự động chuyển đổi encoding khi cần
- **Trường hợp sử dụng**: 
  - Ứng dụng đa ngôn ngữ (tiếng Việt, Trung, Nhật, Ả Rập...)
  - Tên người dùng có ký tự đặc biệt
  - Nội dung cần hiển thị trên nhiều locale khác nhau
- **Ví dụ thực tế**: 
  ```sql
  -- Ứng dụng đa ngôn ngữ
  product_name_intl NVARCHAR2(200)  -- 'Điện thoại', '电话', 'टेलीफोन'
  user_display_name NVARCHAR2(100)  -- 'Nguyễn Văn A', '王小明', 'أحمد علي'
  
  -- Website đa quốc gia
  page_title NVARCHAR2(150)         -- Tiêu đề trang bằng nhiều ngôn ngữ
  meta_description NVARCHAR2(300)   -- SEO description đa ngôn ngữ
  ```
- **So sánh với VARCHAR2**:
  ```sql
  -- VARCHAR2: Dùng database charset
  name_local VARCHAR2(100)     -- Tốt cho tiếng Việt đơn thuần
  
  -- NVARCHAR2: Dùng national charset  
  name_global NVARCHAR2(100)   -- Tốt cho hỗ trợ nhiều ngôn ngữ
  ```
- **Thực hành tốt**: 
  - Sử dụng khi ứng dụng cần hỗ trợ nhiều ngôn ngữ
  - Cân nhắc hiệu suất: NVARCHAR2 chậm hơn VARCHAR2 một chút
  - Đảm bảo National Character Set được cấu hình đúng

### NCHAR(size)
- **Mô tả**: Kiểu dữ liệu ký tự Unicode độ dài cố định, tương tự CHAR nhưng sử dụng National Character Set để hỗ trợ đa ngôn ngữ.
- **Lưu trữ**: 1 đến 2000 byte (luôn chiếm đủ size, đệm khoảng trắng)
- **Đặc điểm kỹ thuật**:
  - Kết hợp đặc điểm của CHAR (fixed-length) và Unicode support
  - Tự động đệm khoảng trắng như CHAR
  - Sử dụng National Character Set
- **Trường hợp sử dụng**: 
  - Mã định danh cố định trong môi trường đa ngôn ngữ  
  - Trạng thái/flag cần hiển thị bằng nhiều ngôn ngữ
  - Hiếm khi sử dụng trong thực tế
- **Ví dụ thực tế**: 
  ```sql
  -- Rất hiếm dùng, chỉ trong trường hợp đặc biệt
  language_code NCHAR(5)     -- 'vi-VN', 'en-US', 'zh-CN'
  status_unicode NCHAR(2)    -- Trạng thái hiển thị đa ngôn ngữ
  ```
- **Thực hành tốt**: 
  - Hiếm khi sử dụng; ưu tiên NVARCHAR2 cho dữ liệu Unicode
  - Chỉ dùng khi thực sự cần fixed-length Unicode
  - Cân nhắc VARCHAR2 hoặc CHAR trước khi dùng NCHAR

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
- **Mô tả**: Kiểu số nguyên 32-bit có dấu, được Oracle tối ưu hóa cho các phép toán số nguyên cơ bản. Đây là subtype của NUMBER với một số ràng buộc về phạm vi giá trị.
- **Lưu trữ**: Biến đổi (1 đến 22 byte, tùy thuộc vào giá trị)
- **Phạm vi**: -2,147,483,648 đến 2,147,483,647 (-(2^31) đến (2^31)-1)
- **Đặc điểm kỹ thuật**:
  - Không cho phép số thập phân
  - Tự động làm tròn nếu gán số thập phân
  - Hiệu suất tốt cho indexing và sorting
- **Trường hợp sử dụng**: 
  - ID bản ghi, khóa chính (trong phạm vi 2 tỷ)
  - Số lượng sản phẩm, số thứ tự
  - Bộ đếm, số trang, số thứ tự
- **Ví dụ thực tế**: 
  ```sql
  customer_id INTEGER               -- ID khách hàng
  quantity INTEGER                  -- Số lượng sản phẩm (1, 100, 500)
  page_number INTEGER              -- Số trang (1, 2, 3...)
  year_established INTEGER        -- Năm thành lập (2020, 2021...)
  ```
- **Lưu ý quan trọng**:
  ```sql
  -- INTEGER tự động làm tròn số thập phân
  INSERT INTO products (quantity) VALUES (10.7);  -- Lưu thành 11
  INSERT INTO products (quantity) VALUES (10.3);  -- Lưu thành 10
  
  -- Vượt quá phạm vi sẽ lỗi
  INSERT INTO products (quantity) VALUES (3000000000);  -- ORA-01438
  ```
- **Thực hành tốt**: 
  - Dùng cho ID và đếm trong phạm vi 32-bit
  - Chuyển sang NUMBER khi cần phạm vi lớn hơn
  - Phù hợp cho foreign key và primary key nhỏ

### FLOAT(binary_precision)
- **Mô tả**: Kiểu số dấu phẩy động với độ chính xác nhị phân có thể tùy chỉnh. Được thiết kế cho tính toán khoa học và kỹ thuật cần độ chính xác linh hoạt.
- **Lưu trữ**: 1 đến 22 byte (tùy thuộc vào binary_precision)
- **Độ chính xác nhị phân**: 1 đến 126 bit (mặc định 126 nếu không chỉ định)
- **Phạm vi**: Tương tự NUMBER nhưng với biểu diễn nhị phân
- **Đặc điểm kỹ thuật**:
  - Độ chính xác được định nghĩa theo bit, không phải chữ số thập phân
  - FLOAT(24) ≈ 7 chữ số thập phân (single precision)
  - FLOAT(53) ≈ 15 chữ số thập phân (double precision)
- **Trường hợp sử dụng**: 
  - Tính toán khoa học, kỹ thuật
  - Xử lý dữ liệu cần độ chính xác linh hoạt
  - Tương thích với hệ thống legacy sử dụng float
- **Ví dụ thực tế**: 
  ```sql
  scientific_calculation FLOAT(53)    -- Tính toán khoa học độ chính xác cao
  sensor_reading FLOAT(24)           -- Đọc sensor (độ chính xác vừa phải)
  gps_coordinate FLOAT(53)           -- Tọa độ GPS (cần độ chính xác cao)
  ```
- **So sánh độ chính xác**:
  ```sql
  FLOAT(24)   -- ~7 chữ số thập phân  (tương đương BINARY_FLOAT)
  FLOAT(53)   -- ~15 chữ số thập phân (tương đương BINARY_DOUBLE)  
  FLOAT(126)  -- ~38 chữ số thập phân (độ chính xác tối đa)
  ```
- **Thực hành tốt**: 
  - Dùng NUMBER cho ứng dụng kinh doanh (tránh rounding error)
  - Dùng FLOAT cho tính toán khoa học cần hiệu suất
  - Xem xét BINARY_FLOAT/BINARY_DOUBLE cho chuẩn IEEE 754

### BINARY_FLOAT
- **Mô tả**: Kiểu số dấu phẩy động 32-bit tuân theo chuẩn IEEE 754, được tối ưu hóa cho hiệu suất tính toán và tương thích với các ngôn ngữ lập trình khác.
- **Lưu trữ**: 4 byte (cố định)
- **Phạm vi**: 
  - Dương: 1.17549E-38 đến 3.40282E+38
  - Âm: -3.40282E+38 đến -1.17549E-38
  - Giá trị đặc biệt: +INF, -INF, NaN
- **Độ chính xác**: Khoảng 7 chữ số thập phân có nghĩa
- **Đặc điểm kỹ thuật**:
  - Tuân theo chuẩn IEEE 754 Single Precision
  - Hỗ trợ giá trị đặc biệt: Infinity, NaN (Not a Number)
  - Hiệu suất tính toán cao nhất trong Oracle
- **Trường hợp sử dụng**: 
  - Ứng dụng gaming, graphics
  - Tính toán khoa học cần hiệu suất cao
  - Tương thích với Java float, C# float
  - Machine learning, AI calculations
- **Ví dụ thực tế**: 
  ```sql
  price_usd BINARY_FLOAT              -- Giá USD (không cần độ chính xác cao)
  temperature BINARY_FLOAT            -- Nhiệt độ sensor
  score BINARY_FLOAT                  -- Điểm số game
  probability BINARY_FLOAT            -- Xác suất (0.0 to 1.0)
  
  -- Xử lý giá trị đặc biệt
  calculation_result BINARY_FLOAT     -- Có thể là NaN hoặc Infinity
  ```
- **Giá trị đặc biệt**:
  ```sql
  SELECT BINARY_FLOAT_INFINITY FROM dual;     -- +INF
  SELECT BINARY_FLOAT_NAN FROM dual;          -- NaN
  
  -- Kiểm tra giá trị đặc biệt
  WHERE IS_INFINITE(column_name) = 1          -- Là Infinity
  WHERE IS_NAN(column_name) = 1               -- Là NaN
  ```
- **Thực hành tốt**: 
  - Dùng cho tính toán cần hiệu suất cao
  - Tránh dùng cho tiền tệ (dùng NUMBER thay thế)
  - Xử lý các giá trị đặc biệt (NaN, Infinity) trong application logic

### BINARY_DOUBLE
- **Mô tả**: Kiểu số dấu phẩy động 64-bit tuân theo chuẩn IEEE 754, cung cấp độ chính xác cao nhất cho tính toán dấu phẩy động trong Oracle.
- **Lưu trữ**: 8 byte (cố định)
- **Phạm vi**: 
  - Dương: 2.22507485850720E-308 đến 1.79769313486231E+308
  - Âm: -1.79769313486231E+308 đến -2.22507485850720E-308
  - Giá trị đặc biệt: +INF, -INF, NaN
- **Độ chính xác**: Khoảng 15-17 chữ số thập phân có nghĩa
- **Đặc điểm kỹ thuật**:
  - Tuân theo chuẩn IEEE 754 Double Precision
  - Tương thích hoàn toàn với Java double, C# double
  - Hiệu suất tính toán rất cao, chỉ chậm hơn BINARY_FLOAT một chút
- **Trường hợp sử dụng**: 
  - Tính toán khoa học độ chính xác cao
  - Financial modeling (không phải currency storage)
  - Statistical analysis, data science
  - Geographic calculations (coordinates, distances)
- **Ví dụ thực tế**: 
  ```sql
  latitude BINARY_DOUBLE              -- Tọa độ địa lý (cần độ chính xác cao)
  longitude BINARY_DOUBLE             -- Tọa độ địa lý
  statistical_result BINARY_DOUBLE    -- Kết quả tính toán thống kê
  exchange_rate BINARY_DOUBLE         -- Tỷ giá (cho tính toán, không lưu trữ)
  
  -- Scientific calculations
  physics_constant BINARY_DOUBLE      -- Hằng số vật lý
  measurement_value BINARY_DOUBLE     -- Giá trị đo lường khoa học
  ```
- **So sánh với NUMBER**:
  ```sql
  -- NUMBER: Exact decimal arithmetic
  salary NUMBER(10,2)                 -- 99999999.99 (exact)
  
  -- BINARY_DOUBLE: Approximate arithmetic  
  calculation BINARY_DOUBLE           -- Nhanh hơn nhưng có rounding error
  ```
- **Thực hành tốt**: 
  - Lựa chọn tốt nhất cho tính toán khoa học độ chính xác cao
  - Tránh dùng cho tiền tệ (dùng NUMBER để tránh rounding error)
  - Xử lý các edge case (overflow, underflow, NaN)

### SMALLINT
- **Mô tả**: Kiểu số nguyên được tối ưu cho các giá trị nhỏ, thực chất là một alias của NUMBER(38) nhưng được Oracle tối ưu hóa cho các số nguyên có giá trị nhỏ.
- **Lưu trữ**: Biến đổi (1 đến 22 byte, nhưng thường ít hơn cho giá trị nhỏ)
- **Phạm vi**: Tương tự NUMBER(38), nhưng được khuyến nghị dùng cho giá trị nhỏ
- **Đặc điểm kỹ thuật**:
  - Không có giới hạn chặt chẽ như INTEGER
  - Được tối ưu hóa cho storage và performance với số nhỏ
  - Có thể chứa số thập phân (khác với INTEGER)
- **Trường hợp sử dụng**: 
  - Tuổi, tháng, ngày trong tháng
  - Mức độ ưu tiên (1-10)
  - Trạng thái số (status code)
  - Đánh giá, rating (1-5 sao)
- **Ví dụ thực tế**: 
  ```sql
  age SMALLINT                        -- Tuổi (0-150)
  month_number SMALLINT              -- Tháng (1-12)
  priority_level SMALLINT            -- Mức ưu tiên (1-10)
  rating SMALLINT                    -- Đánh giá (1-5)
  status_code SMALLINT               -- Mã trạng thái (100, 200, 404, 500)
  ```
- **So sánh với INTEGER**:
  ```sql
  -- SMALLINT: Không có giới hạn chặt, tối ưu cho số nhỏ
  age SMALLINT                       -- Có thể lưu 25.5 (tuổi theo tháng)
  
  -- INTEGER: Có giới hạn 32-bit, chỉ số nguyên
  customer_id INTEGER                -- Chỉ lưu được số nguyên, có giới hạn
  ```
- **Thực hành tốt**: 
  - Dùng cho số nguyên nhỏ để tối ưu storage
  - Xem xét NUMBER(3) hoặc NUMBER(2) nếu muốn giới hạn cụ thể
  - Phù hợp cho lookup table, enum values


### So Sánh Các Kiểu Số Oracle

| **Kiểu** | **Phạm vi** | **Độ chính xác** | **Lưu trữ** | **Khi nào sử dụng** |
|-----------|-------------|------------------|-------------|---------------------|
| **INTEGER** | -2,147,483,648 đến 2,147,483,647 | Số nguyên (32-bit) | 1-22 byte | ID, đếm, khóa chính nhỏ |
| **SMALLINT** | Tương tự NUMBER(38) | Số nguyên/thập phân | 1-22 byte | Tuổi, tháng, rating, status |
| **NUMBER** | 1.0×10^-130 đến 9.99×10^125 | Lên đến 38 chữ số | 1-22 byte | Tiền tệ, tính toán chính xác |
| **NUMBER(p,s)** | Theo precision/scale | p chữ số, s thập phân | 1-22 byte | Tiền tệ, đo lường có format |
| **FLOAT** | Tương tự NUMBER | Nhị phân (1-126 bit) | 1-22 byte | Tính toán khoa học linh hoạt |
| **BINARY_FLOAT** | ±1.17549E-38 đến ±3.40282E+38 | ~7 chữ số (IEEE 754) | 4 byte | Hiệu suất cao, gaming, AI |
| **BINARY_DOUBLE** | ±2.22507E-308 đến ±1.79769E+308 | ~15-17 chữ số (IEEE 754) | 8 byte | Khoa học, tọa độ, thống kê |

### Hướng Dẫn Lựa Chọn Kiểu Số

#### **Theo Mục Đích Sử Dụng:**

**🏦 Tài Chính & Kinh Doanh:**
```sql
-- Tiền tệ, giá cả (cần chính xác tuyệt đối)
salary NUMBER(10,2)           -- Lương: 99,999,999.99
product_price NUMBER(8,2)     -- Giá sản phẩm: 999,999.99
tax_rate NUMBER(5,4)          -- Thuế suất: 0.1234 (12.34%)

-- ID và đếm
customer_id INTEGER           -- ID khách hàng (< 2 tỷ)
product_id NUMBER(12)         -- ID sản phẩm (lớn hơn)
order_count SMALLINT          -- Số đơn hàng (nhỏ)
```

**🔬 Khoa Học & Kỹ Thuật:**
```sql
-- Tính toán độ chính xác cao
latitude BINARY_DOUBLE        -- Tọa độ GPS
sensor_reading BINARY_FLOAT   -- Đọc cảm biến
physics_constant BINARY_DOUBLE -- Hằng số vật lý
calculation_result FLOAT(53)  -- Kết quả tính toán
```

**📊 Quản Lý & Phân Loại:**
```sql
-- Trạng thái và phân loại
age SMALLINT                  -- Tuổi (0-150)
rating SMALLINT               -- Đánh giá (1-5)
priority INTEGER              -- Ưu tiên (1-10)
status_code INTEGER           -- HTTP status (200, 404...)
```

#### **Theo Yêu Cầu Kỹ Thuật:**

- **Cần chính xác tuyệt đối**: NUMBER (tiền tệ, kế toán)
- **Cần hiệu suất cao**: BINARY_FLOAT, BINARY_DOUBLE
- **Tương thích với ngôn ngữ khác**: BINARY_FLOAT/DOUBLE (Java, C#)
- **Tiết kiệm storage**: INTEGER cho ID nhỏ, SMALLINT cho giá trị nhỏ
- **Linh hoạt độ chính xác**: FLOAT với binary_precision tùy chỉnh

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
