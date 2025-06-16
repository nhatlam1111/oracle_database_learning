# Bài 4: Các Khái Niệm SQL Trung Cấp

Chào mừng đến với Bài 4! Bài học này bao gồm các khái niệm SQL trung cấp sẽ mở rộng đáng kể khả năng làm việc của bạn với cơ sở dữ liệu quan hệ. Bạn sẽ học cách kết hợp dữ liệu từ nhiều bảng bằng cách sử dụng joins và cách viết các truy vấn phức tạp sử dụng subqueries.

## Mục Tiêu Học Tập

Khi kết thúc bài học này, bạn sẽ có thể:
- Hiểu các nguyên tắc cơ sở dữ liệu quan hệ và mối quan hệ giữa các bảng
- Viết INNER JOINs để kết hợp dữ liệu liên quan từ nhiều bảng
- Sử dụng OUTER JOINs (LEFT, RIGHT, FULL) để bao gồm các bản ghi không khớp
- Áp dụng CROSS JOINs và SELF JOINs cho các tình huống đặc biệt
- Viết và tối ưu hóa subqueries trong các mệnh đề SELECT, WHERE, và FROM
- Sử dụng correlated subqueries cho xử lý từng hàng
- Áp dụng EXISTS và NOT EXISTS để kiểm tra sự tồn tại
- Kết hợp joins và subqueries trong các truy vấn phức tạp

## Điều Kiện Tiên Quyết

Trước khi bắt đầu bài học này, hãy đảm bảo bạn đã:
- Hoàn thành Bài 1-3 (Kiến thức cơ bản về cơ sở dữ liệu và SQL cơ bản)
- Hiểu vững về SELECT, WHERE, ORDER BY, và các hàm tổng hợp
- Có quyền truy cập Oracle Database với các schema mẫu HR và SALES
- Quen thuộc với khóa chính và mối quan hệ khóa ngoại

## Cấu Trúc Bài Học

### 1. Mối Quan Hệ Bảng và Kiến Thức Cơ Bản về Join (`1-table-relationships.md`)
- Hiểu về khóa chính và khóa ngoại
- Mối quan hệ một-nhiều, nhiều-nhiều, và một-một
- Các khái niệm về tính toàn vẹn tham chiếu
- Giới thiệu cú pháp JOIN

**Tệp Thực Hành**: `src/intermediate/table-relationships.sql`

### 2. INNER JOINs (`2-inner-joins.md`)
- Cú pháp và cơ chế INNER JOIN cơ bản
- Nối hai bảng và nhiều bảng
- Sử dụng bí danh bảng để dễ đọc
- Các điều kiện nối và mẫu phổ biến
- Cân nhắc về hiệu suất

**Tệp Thực Hành**: `src/intermediate/inner-joins.sql`

### 3. OUTER JOINs (`3-outer-joins.md`)
- LEFT OUTER JOIN để bao gồm các bản ghi không khớp từ bảng bên trái
- RIGHT OUTER JOIN để bao gồm các bản ghi không khớp từ bảng bên phải
- FULL OUTER JOIN để bao gồm tất cả các bản ghi không khớp
- Xử lý giá trị NULL trong outer joins
- Các tình huống nghiệp vụ cho từng loại join

**Tệp Thực Hành**: `src/intermediate/outer-joins.sql`

### 4. Các Loại Join Nâng Cao (`4-advanced-joins.md`)
- CROSS JOIN cho tích Cartesian
- SELF JOIN cho dữ liệu phân cấp
- Non-equi joins với các toán tử khác nhau
- Nhiều điều kiện join
- Kỹ thuật tối ưu hóa join

**Tệp Thực Hành**: `src/intermediate/advanced-joins.sql`

### 5. Kiến Thức Cơ Bản về Subquery (`5-subqueries.md`)
- Subqueries đơn hàng và đa hàng
- Subqueries trong các mệnh đề SELECT, WHERE, và FROM
- Scalar subqueries cho tính toán
- Sử dụng subqueries với các toán tử so sánh
- Các mẫu subquery phổ biến

**Tệp Thực Hành**: `src/intermediate/subqueries.sql`

### 6. Correlated Subqueries và EXISTS (`6-correlated-subqueries.md`)
- Hiểu về correlated vs non-correlated subqueries
- Các toán tử EXISTS và NOT EXISTS
- Tác động hiệu suất của correlated subqueries
- Chuyển đổi EXISTS thành joins và ngược lại
- Kỹ thuật correlation nâng cao

**Tệp Thực Hành**: `src/intermediate/correlated-subqueries.sql`

## Tham Khảo Dữ Liệu Mẫu

Bài học này sử dụng rộng rãi các mối quan hệ giữa các bảng trong schemas HR và SALES:

### Mối Quan Hệ HR Schema:
- **EMPLOYEES** ↔ **DEPARTMENTS** (thông qua department_id)
- **EMPLOYEES** ↔ **JOBS** (thông qua job_id)
- **EMPLOYEES** ↔ **EMPLOYEES** (tự tham chiếu manager_id)
- **DEPARTMENTS** ↔ **LOCATIONS** (thông qua location_id)
- **LOCATIONS** ↔ **COUNTRIES** (thông qua country_id)

### Mối Quan Hệ SALES Schema:
- **ORDERS** ↔ **CUSTOMERS** (thông qua customer_id)
- **ORDER_ITEMS** ↔ **ORDERS** (thông qua order_id)
- **ORDER_ITEMS** ↔ **PRODUCTS** (thông qua product_id)

## Lộ Trình Học Tập

1. **Bắt đầu với Lý thuyết**: Đọc từng tệp markdown để hiểu các khái niệm
2. **Thực hành Từng bước**: Làm việc với các tệp thực hành theo thứ tự
3. **Xây dựng Độ phức tạp**: Bắt đầu với joins 2 bảng đơn giản, tiến tới các truy vấn nhiều bảng phức tạp
4. **Ứng dụng Thực tế**: Áp dụng các khái niệm vào các tình huống nghiệp vụ
5. **Nhận thức về Hiệu suất**: Học cách viết các truy vấn hiệu quả

## Các Khái Niệm Chính Cần Thành Thạo

### Các Loại Join:
- **INNER JOIN**: Chỉ trả về các bản ghi khớp
- **LEFT JOIN**: Trả về tất cả bản ghi bảng trái + các bản ghi khớp
- **RIGHT JOIN**: Trả về tất cả bản ghi bảng phải + các bản ghi khớp
- **FULL JOIN**: Trả về tất cả bản ghi từ cả hai bảng
- **CROSS JOIN**: Tích Cartesian của cả hai bảng
- **SELF JOIN**: Bảng được nối với chính nó

### Các Loại Subquery:
- **Scalar Subqueries**: Trả về một giá trị duy nhất
- **Row Subqueries**: Trả về một hàng với nhiều cột
- **Table Subqueries**: Trả về nhiều hàng và cột
- **Correlated Subqueries**: Tham chiếu các cột truy vấn ngoài
- **EXISTS Subqueries**: Kiểm tra sự tồn tại của các hàng

## Các Trường Hợp Sử Dụng Phổ Biến

### Tình Huống Nghiệp Vụ cho Joins:
- Báo cáo thông tin nhân viên và phòng ban
- Phân tích lịch sử đặt hàng khách hàng
- Theo dõi hiệu suất bán hàng sản phẩm
- Báo cáo cấu trúc tổ chức
- Phân tích bán hàng theo địa lý

### Tình Huống Nghiệp Vụ cho Subqueries:
- Tìm những người có hiệu suất trên mức trung bình
- Xác định khách hàng không có đơn hàng gần đây
- Danh mục sản phẩm có doanh số cao nhất
- Nhân viên trong các phòng ban có tiêu chí cụ thể
- Lọc phức tạp dựa trên dữ liệu tổng hợp

## Mẹo Về Hiệu Suất

1. **Sử dụng các index phù hợp** trên các cột join
2. **Lọc sớm** với các mệnh đề WHERE trước khi join
3. **Chọn loại join phù hợp** cho logic nghiệp vụ của bạn
4. **Xem xét kế hoạch thực thi truy vấn** để tối ưu hóa
5. **Sử dụng EXISTS thay vì IN** để có hiệu suất tốt hơn với NULL
6. **Tránh các subquery không cần thiết** có thể chuyển đổi thành joins

## Lỗi Phổ Biến Cần Tránh

- Quên điều kiện join (dẫn đến tích Cartesian)
- Sử dụng sai loại join cho yêu cầu nghiệp vụ
- Không xử lý giá trị NULL trong outer joins
- Viết correlated subqueries không hiệu quả
- Trộn lẫn các kiểu cú pháp join (ANSI vs Oracle truyền thống)
- Không xem xét tác động hiệu suất của các truy vấn phức tạp

## Công Cụ và Kỹ Thuật

- **EXPLAIN PLAN** để phân tích hiệu suất truy vấn
- **Bí danh bảng** để dễ đọc và tránh nhầm lẫn
- **Thụt lề phù hợp** cho khả năng đọc truy vấn phức tạp
- **Chú thích** để ghi chép logic nghiệp vụ phức tạp
- **Xây dựng từng bước** các truy vấn phức tạp

## Thời Gian Ước Tính

Tổng cộng 4-6 giờ:
- Đọc lý thuyết: 1.5 giờ
- Bài tập thực hành: 2.5 giờ
- Tình huống phức tạp: 1-2 giờ

## Đánh Giá

Sau khi hoàn thành bài học này, bạn nên có thể:
- Viết joins để kết hợp dữ liệu từ 3+ bảng
- Chọn loại join phù hợp cho các tình huống nghiệp vụ
- Sử dụng subqueries để giải quyết các vấn đề lọc phức tạp
- Tối ưu hóa truy vấn để có hiệu suất tốt hơn
- Xử lý dữ liệu phân cấp với self-joins
- Kết hợp joins và subqueries trong các truy vấn phức tạp

## Bước Tiếp Theo

Sau khi thành thạo bài học này, bạn sẽ sẵn sàng cho:
- **Bài 5**: Kỹ Thuật SQL Nâng Cao (Stored Procedures, Functions, Triggers)
- **Bài 6**: Thiết Kế và Tối Ưu Hóa Cơ Sở Dữ Liệu
- **Dự Án Thực Tế**: Xây dựng các ứng dụng cơ sở dữ liệu hoàn chỉnh

---

**Lưu Ý Quan Trọng**: Bài học này tăng đáng kể về độ phức tạp. Hãy dành thời gian với từng khái niệm và thực hành nhiều trước khi chuyển sang chủ đề tiếp theo. Các khái niệm học được ở đây tạo nền tảng cho phát triển cơ sở dữ liệu nâng cao.
