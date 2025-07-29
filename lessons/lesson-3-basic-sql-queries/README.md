# Bài 3: Truy Vấn SQL Cơ Bản và Kiểu Dữ Liệu

Bài học này giới thiệu bạn về các kiểu dữ liệu Oracle Database và các thao tác truy vấn SQL cơ bản. Bạn sẽ học về kiểu dữ liệu trước (điều cần thiết để tạo bảng), sau đó chuyển sang truy xuất, lọc, sắp xếp và tóm tắt dữ liệu bằng các câu lệnh SQL cơ bản.

## Mục Tiêu Học Tập
Sau khi hoàn thành bài học này, bạn sẽ có thể:
- Thành thạo các kiểu dữ liệu tích hợp sẵn của Oracle Database và cách sử dụng phù hợp
- Áp dụng các thực hành tốt nhất cho việc lựa chọn kiểu dữ liệu trong thiết kế cơ sở dữ liệu
- Viết các câu lệnh SELECT cơ bản để truy xuất dữ liệu từ bảng
- Lọc dữ liệu bằng mệnh đề WHERE với các điều kiện khác nhau
- Sắp xếp kết quả truy vấn bằng ORDER BY
- Sử dụng các hàm tổng hợp để tóm tắt dữ liệu
- Áp dụng các hàm tích hợp sẵn để thao tác dữ liệu
- Hiểu về các hàm chuyển đổi kiểu dữ liệu
- Sử dụng toán tử tập hợp (UNION, INTERSECT, MINUS) để kết hợp và so sánh dữ liệu
- Viết các truy vấn hiệu quả theo các thực hành tốt nhất

## Cấu Trúc Bài Học
1. **Kiểu Dữ Liệu Oracle Database** ⭐ **NỀN TẢNG QUAN TRỌNG** - Thành thạo kiểu dữ liệu trước khi tạo bảng
2. **Câu Lệnh SELECT** - Thành thạo nền tảng của việc truy xuất dữ liệu
3. **Mệnh Đề WHERE và Lọc Dữ Liệu** - Học cách lọc dữ liệu với các điều kiện khác nhau
4. **Sắp Xếp với ORDER BY** - Kiểm soát thứ tự trình bày kết quả
5. **Hàm Tổng Hợp** - Tóm tắt dữ liệu với COUNT, SUM, AVG, v.v.
6. **Toán Tử Tập Hợp** ⭐ **MỚI** - UNION, INTERSECT, MINUS cho thao tác tập hợp

## Điều Kiện Tiên Quyết
- Đã hoàn thành Bài 1 (Giới thiệu về Cơ sở dữ liệu)
- Đã hoàn thành Bài 2 (Thiết lập Môi trường)
- Cơ sở dữ liệu mẫu đã được tạo và có thể truy cập
- Client SQL đã được cấu hình và kết nối

## Thời Gian Ước Tính
4-5 tiếng

## Tệp Tin Trong Bài Học Này
- `1-oracle-datatypes.md` ⭐ **MỚI & TOÀN DIỆN** - Hướng dẫn đầy đủ về kiểu dữ liệu Oracle
- `2-select-statements.md` - Hướng dẫn đầy đủ về câu lệnh SELECT và cú pháp cơ bản
- `3-where-clause-filtering.md` - Kỹ thuật lọc dữ liệu và điều kiện
- `4-sorting-order-by.md` - Sắp xếp và tổ chức kết quả truy vấn
- `5-group-by-and-aggregate-functions.md` - Tóm tắt dữ liệu và các thao tác tổng hợp

## Ví Dụ Thực Hành
- `../../src/basic-queries/oracle-datatypes-examples.sql` - Ví dụ toàn diện về kiểu dữ liệu
- `../../src/basic-queries/select-statements.sql` - Ví dụ truy vấn SELECT
- `../../src/basic-queries/where-filtering.sql` - Ví dụ mệnh đề WHERE
- `../../src/basic-queries/sorting-examples.sql` - Ví dụ ORDER BY
- `../../src/basic-queries/aggregate-examples.sql` - Ví dụ hàm tổng hợp

## Dữ Liệu Mẫu Cần Thiết
Bài học này sử dụng schema HR và SALES được tạo trong Bài 2. Đảm bảo bạn có:
- Schema HR: các bảng employees, departments, jobs, locations
- Schema SALES: các bảng customers, products, orders, order_details

## Bước Tiếp Theo
Sau khi hoàn thành bài học này, bạn sẽ có nền tảng vững chắc về kiểu dữ liệu Oracle và truy vấn SQL cơ bản, và sẵn sàng tiến tới Bài 4 cho các khái niệm SQL trung cấp bao gồm join và subquery.

## Tổng Quan Nội Dung Chi Tiết

### 1. Kiểu Dữ Liệu Oracle Database ⭐ **BẮT ĐẦU TẠI ĐÂY**
**Tệp:** `1-oracle-datatypes.md`

Hướng dẫn toàn diện này bao gồm tất cả các kiểu dữ liệu tích hợp sẵn của Oracle:

#### Kiểu Dữ Liệu Ký Tự
- **VARCHAR2(size)** - Dữ liệu ký tự độ dài biến đổi (phổ biến nhất)
- **CHAR(size)** - Dữ liệu ký tự độ dài cố định
- **NVARCHAR2(size)** - Dữ liệu ký tự Unicode độ dài biến đổi
- **NCHAR(size)** - Dữ liệu ký tự Unicode độ dài cố định

#### Kiểu Dữ Liệu Số
- **NUMBER(precision, scale)** - Dữ liệu số độ dài biến đổi
- **INTEGER** - Số nguyên
- **FLOAT(binary_precision)** - Số dấu phẩy động
- **BINARY_FLOAT** - Dấu phẩy động IEEE 754 32-bit
- **BINARY_DOUBLE** - Dấu phẩy động IEEE 754 64-bit

#### Kiểu Dữ Liệu Ngày và Thời Gian
- **DATE** - Ngày và thời gian (phổ biến nhất)
- **TIMESTAMP(fractional_seconds_precision)** - Ngày và thời gian với giây phân số
- **TIMESTAMP WITH TIME ZONE** - TIMESTAMP với thông tin múi giờ
- **TIMESTAMP WITH LOCAL TIME ZONE** - TIMESTAMP được chuẩn hóa theo múi giờ cơ sở dữ liệu
- **INTERVAL YEAR TO MONTH** - Khoảng thời gian tính bằng năm và tháng
- **INTERVAL DAY TO SECOND** - Khoảng thời gian tính bằng ngày, giờ, phút, giây

#### Kiểu Dữ Liệu Nhị Phân
- **RAW(size)** - Dữ liệu nhị phân độ dài biến đổi
- **LONG RAW** - Dữ liệu nhị phân độ dài biến đổi lên đến 2GB (đã lỗi thời)

#### Kiểu Dữ Liệu Đối Tượng Lớn (LOB)
- **CLOB** - Character Large Object cho dữ liệu văn bản lớn
- **NCLOB** - National Character Large Object cho văn bản Unicode
- **BLOB** - Binary Large Object cho dữ liệu nhị phân
- **BFILE** - Locator tệp nhị phân trỏ đến tệp bên ngoài

#### Kiểu Dữ Liệu Chuyên Biệt
- **ROWID** - Định danh duy nhất cho các hàng trong bảng
- **UROWID** - Universal ROWID cho các loại bảng khác nhau
- **JSON** - Kiểu dữ liệu JSON gốc (Oracle 21c+)

#### Điểm Học Tập Chính
- **Hướng Dẫn Lựa Chọn Kiểu Dữ Liệu** - Cách chọn kiểu phù hợp
- **Yêu Cầu Lưu Trữ** - Hiểu về việc sử dụng không gian
- **Cân Nhắc Hiệu Suất** - Tác động đến hiệu suất truy vấn
- **Best Practices** - Industry standards and recommendations
- **Common Conversions** - Converting between data types

### 2. Practical SQL Examples
**File:** `../../src/basic-queries/oracle-datatypes-examples.sql`

Hands-on examples including:
- Table creation with appropriate data types
- Data insertion examples
- Constraint definitions and validation
- Performance optimization techniques
- Common conversion functions
- Best practices demonstrations
