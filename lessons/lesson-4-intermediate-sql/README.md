# Bài 4: Các Khái Niệm SQL Trung Cấp

Chào mừng đến với Bài 4! Bài học này bao gồm các khái niệm SQL trung cấp quan trọng từ việc tạo và quản lý cấu trúc cơ sở dữ liệu đến việc kết hợp dữ liệu từ nhiều bảng. Bạn sẽ học cách tạo bảng, thiết lập mối quan hệ, áp dụng ràng buộc, và viết các truy vấn phức tạp sử dụng joins và subqueries.

## Mục Tiêu Học Tập

Khi kết thúc bài học này, bạn sẽ có thể:
- Tạo, chỉnh sửa và quản lý cấu trúc bảng trong Oracle Database
- Thiết lập khóa chính, khóa ngoại và các ràng buộc tính toàn vẹn
- Hiểu và áp dụng các loại mối quan hệ cơ sở dữ liệu
- Thiết kế schema cơ sở dữ liệu hoàn chỉnh cho ứng dụng thực tế
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
- Hiểu vững về các kiểu dữ liệu Oracle và SELECT, WHERE, ORDER BY
- Nắm vững các hàm tổng hợp và cú pháp SQL cơ bản
- Có quyền truy cập Oracle Database với các schema mẫu HR và SALES
- Hiểu khái niệm cơ bản về cơ sở dữ liệu quan hệ

## Cấu Trúc Bài Học

### 1. Tạo Bảng, Mối Quan Hệ và Ràng Buộc (`1-table-relationships-constraints.md`)
- **Tạo Bảng Cơ Bản**: CREATE TABLE, CTAS, tablespace và storage options
- **Chỉnh Sửa Cấu Trúc**: ALTER TABLE để thêm/sửa/xóa cột, đổi tên
- **Quản Lý Bảng**: DROP TABLE, TRUNCATE, Recycle Bin và khôi phục
- **Khóa Chính và Khóa Ngoại**: Thiết lập mối quan hệ và tính toàn vẹn
- **Ràng Buộc Tích Hợp**: CHECK, UNIQUE, NOT NULL, DEFAULT constraints
- **Thiết Kế Schema Thực Tế**: Xây dựng hệ thống HR Management hoàn chỉnh
- **Tối Ưu Hóa**: Sequences, indexes và performance considerations

**Tệp Thực Hành**: `src/intermediate/table-relationships-constraints.sql`

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

1. **Bắt đầu với Thiết Kế Cơ Sở Dữ Liệu**: Học cách tạo và quản lý cấu trúc bảng
2. **Thực hành Tạo Schema**: Xây dựng hệ thống HR Management từ đầu
3. **Áp dụng Ràng Buộc**: Thiết lập tính toàn vẹn và mối quan hệ dữ liệu
4. **Chuyển sang Truy Vấn**: Học các loại JOIN để kết hợp dữ liệu
5. **Nâng cao với Subqueries**: Viết các truy vấn phức tạp và tối ưu hóa
6. **Tích hợp Toàn Diện**: Kết hợp tất cả kỹ năng trong các dự án thực tế

## Các Khái Niệm Chính Cần Thành Thạo

### Quản Lý Cấu Trúc Cơ Sở Dữ Liệu:
- **CREATE TABLE**: Tạo bảng với các kiểu dữ liệu và ràng buộc phù hợp
- **ALTER TABLE**: Thêm, sửa, xóa cột và ràng buộc
- **DROP/TRUNCATE**: Quản lý xóa bảng và dữ liệu
- **Constraints**: PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE, NOT NULL
- **Indexes**: Tối ưu hóa hiệu suất truy vấn
- **Sequences**: Tạo giá trị tự động tăng

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

### Tình Huống Thiết Kế Schema:
- Xây dựng hệ thống quản lý nhân sự (HR Management)
- Thiết kế cơ sở dữ liệu thương mại điện tử
- Tạo schema quản lý dự án và assignment
- Thiết lập hệ thống audit và log
- Xây dựng cấu trúc dữ liệu phân cấp

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

### Thiết Kế Schema:
1. **Lựa chọn kiểu dữ liệu phù hợp** để tối ưu storage
2. **Tạo indexes hợp lý** trên Foreign Keys và cột thường query
3. **Sử dụng constraints** để đảm bảo tính toàn vẹn dữ liệu
4. **Normalize schema** để tránh redundancy nhưng không over-normalize

### Truy Vấn:
1. **Sử dụng các index phù hợp** trên các cột join
2. **Lọc sớm** với các mệnh đề WHERE trước khi join
3. **Chọn loại join phù hợp** cho logic nghiệp vụ của bạn
4. **Xem xét kế hoạch thực thi truy vấn** để tối ưu hóa
5. **Sử dụng EXISTS thay vì IN** để có hiệu suất tốt hơn với NULL
6. **Tránh các subquery không cần thiết** có thể chuyển đổi thành joins

## Lỗi Phổ Biến Cần Tránh

### Thiết Kế Schema:
- Không đặt Primary Key cho bảng
- Thiết kế Foreign Key không đúng dẫn đến orphaned records
- Chọn kiểu dữ liệu không phù hợp (quá lớn hoặc quá nhỏ)
- Quên tạo indexes cho Foreign Keys
- Thiết lập constraints quá nghiêm ngặt hoặc quá lỏng lẻo
- Không xem xét performance khi thiết kế schema

### Truy Vấn:
- Quên điều kiện join (dẫn đến tích Cartesian)
- Sử dụng sai loại join cho yêu cầu nghiệp vụ
- Không xử lý giá trị NULL trong outer joins
- Viết correlated subqueries không hiệu quả
- Trộn lẫn các kiểu cú pháp join (ANSI vs Oracle truyền thống)
- Không xem xét tác động hiệu suất của các truy vấn phức tạp

## Công Cụ và Kỹ Thuật

- **Oracle SQL Developer** để thiết kế và quản lý schema
- **EXPLAIN PLAN** để phân tích hiệu suất truy vấn
- **Data Modeler** để thiết kế ERD và schema
- **Bí danh bảng** để dễ đọc và tránh nhầm lẫn
- **Thụt lề phù hợp** cho khả năng đọc truy vấn phức tạp
- **Chú thích** để ghi chép logic nghiệp vụ phức tạp
- **Xây dựng từng bước** các truy vấn phức tạp

## Thời Gian Ước Tính

Tổng cộng 6-8 giờ:
- Thiết kế schema và DDL: 2-2.5 giờ
- Đọc lý thuyết JOIN và Subquery: 1.5 giờ  
- Bài tập thực hành: 2.5-3 giờ
- Tình huống phức tạp và tích hợp: 1-2 giờ

## Đánh Giá

Sau khi hoàn thành bài học này, bạn nên có thể:
- Tạo và quản lý schema cơ sở dữ liệu hoàn chỉnh từ đầu
- Thiết lập các ràng buộc và mối quan hệ đảm bảo tính toàn vẹn dữ liệu
- Sử dụng ALTER TABLE để chỉnh sửa cấu trúc bảng một cách linh hoạt
- Tạo indexes và sequences để tối ưu hóa hiệu suất
- Viết joins để kết hợp dữ liệu từ 3+ bảng
- Chọn loại join phù hợp cho các tình huống nghiệp vụ
- Sử dụng subqueries để giải quyết các vấn đề lọc phức tạp
- Tối ưu hóa truy vấn để có hiệu suất tốt hơn
- Xử lý dữ liệu phân cấp với self-joins
- Kết hợp joins và subqueries trong các truy vấn phức tạp

## Bước Tiếp Theo

Sau khi thành thạo bài học này, bạn sẽ sẵn sàng cho:
- **Bài 5**: Kỹ Thuật SQL Nâng Cao (Views, Stored Procedures, Functions, Triggers)
- **Bài 6**: Thực Hành và Ứng Dụng (Performance Tuning, Dự Án Thực Tế)
- **Dự Án Capstone**: Xây dựng các ứng dụng cơ sở dữ liệu hoàn chỉnh

---

**Lưu Ý Quan Trọng**: Bài học này bao gồm cả thiết kế cơ sở dữ liệu và truy vấn dữ liệu, tăng đáng kể về độ phức tạp. Hãy dành thời gian với từng khái niệm, đặc biệt là phần thiết kế schema, vì đây là nền tảng cho tất cả công việc với cơ sở dữ liệu. Thực hành nhiều với việc tạo bảng và thiết lập mối quan hệ trước khi chuyển sang các truy vấn phức tạp.
