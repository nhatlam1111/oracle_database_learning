# Câu Lệnh SELECT - Nền Tảng của SQL

Câu lệnh SELECT là lệnh SQL cơ bản và được sử dụng thường xuyên nhất. Nó cho phép bạn truy xuất dữ liệu từ một hoặc nhiều bảng trong cơ sở dữ liệu của bạn.

## Cú Pháp SELECT Cơ Bản

### Cấu Trúc SELECT Đơn Giản
```sql
SELECT column1, column2, ...
FROM table_name;
```

### Mẫu Truy Vấn Chung
```sql
SELECT [DISTINCT] column_list
FROM table_name
[WHERE condition]
[ORDER BY column_list]
[GROUP BY column_list]
[HAVING condition];
```

## Các Thao Tác SELECT Cơ Bản

### 1. Chọn Tất Cả Cột
Sử dụng dấu sao (*) để chọn tất cả cột từ một bảng:

```sql
-- Chọn tất cả cột từ bảng employees
SELECT * FROM hr.employees;

-- Chọn tất cả cột từ bảng departments  
SELECT * FROM hr.departments;
```

**Thực Hành Tốt**: Tránh sử dụng `SELECT *` trong mã sản xuất. Luôn chỉ định các cột bạn cần.

### 2. Chọn Cột Cụ Thể
Chỉ định những cột bạn cần:

```sql
-- Chọn thông tin nhân viên cụ thể
SELECT employee_id, first_name, last_name, email
FROM hr.employees;

-- Chọn thông tin cơ bản phòng ban
SELECT department_id, department_name
FROM hr.departments;
```

### 3. Bí Danh Cột
Sử dụng bí danh để cung cấp tên có ý nghĩa cho các cột:

```sql
-- Sử dụng từ khóa AS (được khuyến nghị)
SELECT 
    employee_id AS "Mã Nhân Viên",
    first_name AS "Tên",
    last_name AS "Họ",
    salary AS "Lương Tháng"
FROM hr.employees;

-- Không có từ khóa AS (cũng hợp lệ)
SELECT 
    employee_id "Mã Nhân Viên",
    first_name "Tên",
    last_name "Họ", 
    salary "Lương Tháng"
FROM hr.employees;

-- Bí danh đơn giản không có dấu ngoặc kép
SELECT 
    employee_id emp_id,
    first_name fname,
    last_name lname,
    salary monthly_salary
FROM hr.employees;
```

## Thao Tác Chuỗi và Nối Chuỗi

### 1. Nối Chuỗi
Oracle cung cấp nhiều cách để nối chuỗi:

```sql
-- Sử dụng toán tử || (chuẩn Oracle)
SELECT 
    first_name || ' ' || last_name AS full_name,
    'Nhân viên: ' || first_name || ' ' || last_name AS employee_label
FROM hr.employees;

-- Sử dụng hàm CONCAT (giới hạn 2 đối số)
SELECT 
    CONCAT(first_name, last_name) AS name_no_space,
    CONCAT(CONCAT(first_name, ' '), last_name) AS full_name
FROM hr.employees;
```

### 2. Hàm Chuỗi
```sql
-- Các hàm chuỗi phổ biến
SELECT 
    employee_id,
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower,
    INITCAP(email) AS email_proper_case,
    LENGTH(first_name) AS name_length,
    SUBSTR(first_name, 1, 3) AS first_three_chars
FROM hr.employees;
```

## Phép Toán Số Học

### 1. Số Học Cơ Bản
```sql
-- Tính lương năm và thưởng
SELECT 
    employee_id,
    first_name,
    last_name,
    salary AS monthly_salary,
    salary * 12 AS annual_salary,
    salary * 0.1 AS monthly_bonus,
    (salary * 12) + (salary * 0.1 * 12) AS total_annual_compensation
FROM hr.employees;
```

### 2. Xử Lý Giá Trị NULL
```sql
-- Sử dụng NVL để xử lý giá trị NULL
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    commission_pct,
    -- Xử lý commission NULL
    NVL(commission_pct, 0) AS commission_safe,
    -- Tính tổng thu nhập
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees;

-- Sử dụng NVL2 cho xử lý NULL phức tạp hơn
SELECT 
    employee_id,
    first_name,
    last_name,
    commission_pct,
    NVL2(commission_pct, 'Có Hoa Hồng', 'Không Hoa Hồng') AS commission_status
FROM hr.employees;
```

## Làm Việc với Ngày Tháng

### 1. Hàm Ngày Tháng
```sql
-- Các thao tác ngày tháng phổ biến
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    SYSDATE AS current_date,
    SYSDATE - hire_date AS days_employed,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_employed,
    ADD_MONTHS(hire_date, 12) AS first_anniversary
FROM hr.employees;
```

### 2. Định Dạng Ngày Tháng
```sql
-- Định dạng ngày để hiển thị
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    TO_CHAR(hire_date, 'DD-MON-YYYY') AS hire_date_formatted,
    TO_CHAR(hire_date, 'Month DD, YYYY') AS hire_date_long,
    TO_CHAR(hire_date, 'DY') AS hire_day_of_week,
    EXTRACT(YEAR FROM hire_date) AS hire_year
FROM hr.employees;
```

## Chuyển Đổi Kiểu Dữ Liệu

### 1. Chuyển Đổi Số sang Chuỗi
```sql
-- Chuyển đổi số sang chuỗi định dạng
SELECT 
    employee_id,
    first_name,
    salary,
    TO_CHAR(salary, '$999,999.99') AS salary_formatted,
    TO_CHAR(salary, 'L999,999.99') AS salary_with_currency,
    TO_CHAR(salary * 12, '$9,999,999.99') AS annual_salary_formatted
FROM hr.employees;
```

### 2. Chuyển Đổi Chuỗi sang Số/Ngày
```sql
-- Chuyển đổi chuỗi sang số và ngày
SELECT 
    TO_NUMBER('12345') AS string_to_number,
    TO_NUMBER('$1,234.56', '$9,999.99') AS formatted_string_to_number,
    TO_DATE('2023-12-25', 'YYYY-MM-DD') AS string_to_date,
    TO_DATE('December 25, 2023', 'Month DD, YYYY') AS long_string_to_date
FROM dual;
```

## Từ Khóa DISTINCT

### 1. Loại Bỏ Trùng Lặp
```sql
-- Lấy ID phòng ban duy nhất
SELECT DISTINCT department_id
FROM hr.employees
ORDER BY department_id;

-- Lấy chức danh công việc duy nhất
SELECT DISTINCT job_id
FROM hr.employees
ORDER BY job_id;

-- DISTINCT nhiều cột
SELECT DISTINCT department_id, job_id
FROM hr.employees
ORDER BY department_id, job_id;
```

### 2. Đếm Giá Trị Riêng Biệt
```sql
-- Đếm giá trị duy nhất
SELECT 
    COUNT(*) AS total_employees,
    COUNT(DISTINCT department_id) AS unique_departments,
    COUNT(DISTINCT job_id) AS unique_jobs,
    COUNT(DISTINCT manager_id) AS unique_managers
FROM hr.employees;
```

## Logic Điều Kiện với CASE

### 1. Biểu Thức CASE Đơn Giản
```sql
-- Phân loại nhân viên theo lương
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    CASE 
        WHEN salary >= 15000 THEN 'Cao'
        WHEN salary >= 8000 THEN 'Trung Bình'
        WHEN salary >= 4000 THEN 'Thấp'
        ELSE 'Mới Vào'
    END AS salary_category
FROM hr.employees;
```

### 2. Logic CASE Phức Tạp
```sql
-- Trạng thái nhân viên dựa trên nhiều yếu tố
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    salary,
    CASE 
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 AND salary >= 10000 THEN 'Cao Cấp Thu Nhập Cao'
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN 'Nhân Viên Cao Cấp'
        WHEN salary >= 10000 THEN 'Thu Nhập Cao'
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 5 THEN 'Trung Cấp'
        ELSE 'Nhân Viên Mới'
    END AS employee_category
FROM hr.employees;
```

## Làm Việc với Nhiều Bảng (Xem Trước)

### 1. Tích Descartes (Không Khuyến Nghị)
```sql
-- Điều này tạo ra tích descartes - thường không phải là điều bạn muốn
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e, hr.departments d;
```

### 2. Xem Trước JOIN Đúng Cách
```sql
-- Xem trước JOIN (được đề cập chi tiết trong Bài 4)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id;
```

## Tham Khảo Hàm Phổ Biến

### 1. Hàm Chuỗi
```sql
SELECT 
    'Oracle Database' AS original,
    UPPER('Oracle Database') AS upper_case,
    LOWER('Oracle Database') AS lower_case,
    INITCAP('oracle database') AS proper_case,
    LENGTH('Oracle Database') AS string_length,
    SUBSTR('Oracle Database', 1, 6) AS substring,
    REPLACE('Oracle Database', 'Oracle', 'MySQL') AS replaced,
    TRIM('  Oracle Database  ') AS trimmed,
    LPAD('123', 6, '0') AS left_padded,
    RPAD('123', 6, '0') AS right_padded
FROM dual;
```

### 2. Hàm Số
```sql
SELECT 
    ABS(-15) AS absolute_value,
    CEIL(15.7) AS ceiling,
    FLOOR(15.7) AS floor_value,
    ROUND(15.789, 2) AS rounded,
    TRUNC(15.789, 1) AS truncated,
    MOD(17, 5) AS modulus,
    POWER(2, 3) AS power,
    SQRT(16) AS square_root
FROM dual;
```

### 3. Hàm Ngày Tháng
```sql
SELECT 
    SYSDATE AS current_date,
    ADD_MONTHS(SYSDATE, 6) AS six_months_later,
    NEXT_DAY(SYSDATE, 'MONDAY') AS next_monday,
    LAST_DAY(SYSDATE) AS last_day_of_month,
    MONTHS_BETWEEN(SYSDATE, DATE '2023-01-01') AS months_since_new_year,
    EXTRACT(YEAR FROM SYSDATE) AS current_year,
    EXTRACT(MONTH FROM SYSDATE) AS current_month
FROM dual;
```

## Cân Nhắc Hiệu Suất

### 1. Lựa Chọn Cột
```sql
-- Tốt: Chỉ chọn các cột cần thiết
SELECT employee_id, first_name, last_name
FROM hr.employees;

-- Tránh: Sử dụng SELECT * không cần thiết
-- SELECT * FROM hr.employees;
```

### 2. Sử Dụng Hàm
```sql
-- Hiệu quả: Sử dụng hàm trên hằng số khi có thể
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 10000;

-- Kém hiệu quả: Sử dụng hàm trên cột trong mệnh đề WHERE
-- SELECT employee_id, first_name, salary
-- FROM hr.employees
-- WHERE UPPER(first_name) = 'JOHN';
```

## Ví Dụ Thực Hành

### 1. Báo Cáo Thông Tin Nhân Viên
```sql
-- Báo cáo nhân viên toàn diện
SELECT 
    employee_id AS "ID",
    first_name || ' ' || last_name AS "Họ Tên Đầy Đủ",
    UPPER(email) AS "Email",
    TO_CHAR(hire_date, 'Month DD, YYYY') AS "Ngày Tuyển Dụng",
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS "Năm Làm Việc",
    TO_CHAR(salary, '$999,999') AS "Lương Tháng",
    TO_CHAR(salary * 12, '$9,999,999') AS "Lương Năm",
    CASE 
        WHEN commission_pct IS NOT NULL THEN 'Có'
        ELSE 'Không'
    END AS "Có Hoa Hồng"
FROM hr.employees
ORDER BY employee_id;
```

### 2. Hiển Thị Danh Mục Sản Phẩm
```sql
-- Thông tin sản phẩm cho danh mục
SELECT 
    product_id AS "Mã Sản Phẩm",
    INITCAP(product_name) AS "Tên Sản Phẩm",
    TO_CHAR(unit_price, '$999.99') AS "Giá Đơn Vị",
    units_in_stock AS "Tồn Kho",
    CASE 
        WHEN units_in_stock = 0 THEN 'Hết Hàng'
        WHEN units_in_stock <= reorder_level THEN 'Hàng Sắp Hết'
        ELSE 'Còn Hàng'
    END AS "Trạng Thái Kho",
    CASE 
        WHEN discontinued = 1 THEN 'Ngừng Sản Xuất'
        ELSE 'Đang Hoạt Động'
    END AS "Trạng Thái Sản Phẩm"
FROM sales.products
ORDER BY category_id, product_name;
```

## Bài Tập

### Bài Tập 1: Thông Tin Nhân Viên Cơ Bản
```sql
-- Viết truy vấn hiển thị mã nhân viên, họ tên đầy đủ (tên + họ),
-- email viết thường, và ngày tuyển dụng định dạng 'DD-MON-YYYY'
-- Truy vấn của bạn ở đây:
```

### Bài Tập 2: Phân Tích Lương
```sql
-- Tạo truy vấn hiển thị mã nhân viên, họ tên đầy đủ, lương tháng,
-- lương năm, và phân loại lương (Cao/Trung Bình/Thấp theo tiêu chí của bạn)
-- Truy vấn của bạn ở đây:
```

### Bài Tập 3: Thông Tin Sản Phẩm
```sql
-- Hiển thị tên sản phẩm viết hoa chữ cái đầu, giá đơn vị định dạng,
-- trạng thái kho, và liệu sản phẩm đang hoạt động hay ngừng sản xuất
-- Truy vấn của bạn ở đây:
```

## Tóm Tắt Thực Hành Tốt

1. **Luôn chỉ định tên cột** thay vì sử dụng SELECT *
2. **Sử dụng bí danh có ý nghĩa** để dễ đọc hơn
3. **Xử lý giá trị NULL** phù hợp với NVL/NVL2
4. **Định dạng đầu ra** để trình bày tốt hơn bằng TO_CHAR
5. **Sử dụng câu lệnh CASE** cho logic điều kiện
6. **Ghi chú truy vấn** để tài liệu hóa
7. **Kiểm tra với tập dữ liệu nhỏ** trước
8. **Cân nhắc hiệu suất** khi sử dụng hàm

## Lỗi Phổ Biến Cần Tránh

1. **Quên dấu chấm phẩy** ở cuối câu lệnh
2. **Dấu ngoặc kép sai** cho bí danh (sử dụng dấu ngoặc kép cho khoảng trắng)
3. **Không xử lý giá trị NULL** trong tính toán
4. **Sử dụng hàm không cần thiết** trong mệnh đề WHERE
5. **Trộn lẫn dấu ngoặc đơn và kép** không đúng cách
6. **Quên bí danh bảng** khi tên cột không rõ ràng

## Bước Tiếp Theo

Bây giờ bạn đã hiểu về câu lệnh SELECT, tiến tới:
1. **Mệnh Đề WHERE và Lọc Dữ Liệu** - Học cách lọc dữ liệu
2. **ORDER BY** - Sắp xếp kết quả hiệu quả
3. **Hàm Tổng Hợp** - Tóm tắt dữ liệu
4. Thực hành với các bài tập được cung cấp

Thành thạo những kiến thức cơ bản này trước khi chuyển sang join và subquery trong Bài 4!
