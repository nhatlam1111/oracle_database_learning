# Câu Lệnh SELECT - Nền Tảng của SQL

Câu lệnh SELECT là lệnh SQL cơ bản và được sử dụng thường xuyên nhất. Nó cho phép bạn truy xuất dữ liệu từ một hoặc nhiều bảng trong cơ sở dữ liệu của bạn.

# Quy tắc chung đặc tên cột, tên bảng:
- không phân biệt hoa thường, bao gồm chữ, số và dấu _ 
- không chứa ký tự đặc biệt (ngoại trừ dấu _ )
- Ký tự đầu tiên không được bắt đầu bằng số
* Ngoại lệ: muốn đặc tên bảng hoặc tên cột phá vỡ mấy quy tắc trên: thì rào tên đó trong dấu ngoặc kép, ví dụ: cột SELECT trùng với từ khóa select trong select ...from..., nên phải để trong ngoặc kép: "SELECT",
* tuy nhiên giá trị trong ngoặc kép sẽ phân biệt hoa thường

# Lưu ý:
- trên cùng một cột chỉ có một kiểu dữ liệu (trường hợp thường sai: case when, decode, union, intersect, minus)

## Chỉ Mục Bài Học

1. [Cú Pháp SELECT Cơ Bản](#cú-pháp-select-cơ-bản)
2. [Bảng DUAL trong Oracle](#bảng-dual-trong-oracle)
3. [Các Thao Tác SELECT Cơ Bản](#các-thao-tác-select-cơ-bản)
4. [Bí Danh Cột và Phân Biệt Dấu Nháy](#bí-danh-cột-và-phân-biệt-dấu-nháy)
5. [Thao Tác Chuỗi và Nối Chuỗi](#thao-tác-chuỗi-và-nối-chuỗi)
6. [Phép Toán Số Học](#phép-toán-số-học)
7. [Làm Việc với Ngày Tháng](#làm-việc-với-ngày-tháng)
8. [Chuyển Đổi Kiểu Dữ Liệu](#chuyển-đổi-kiểu-dữ-liệu)
9. [Từ Khóa DISTINCT](#từ-khóa-distinct)
10. [Toán Tử Tập Hợp (UNION, INTERSECT, MINUS)](#toán-tử-tập-hợp-union-intersect-minus)
11. [Logic Điều Kiện với CASE](#logic-điều-kiện-với-case)
12. [Làm Việc với Nhiều Bảng (Xem Trước)](#làm-việc-với-nhiều-bảng-xem-trước)
13. [Tham Khảo Hàm Phổ Biến](#tham-khảo-hàm-phổ-biến)
14. [Cân Nhắc Hiệu Suất](#cân-nhắc-hiệu-suất)
15. [Ví Dụ Thực Hành](#ví-dụ-thực-hành)
16. [Bài Tập](#bài-tập)

## Cú Pháp SELECT Cơ Bản

### Biểu Diễn Trực Quan - Cấu Trúc SELECT
```
                        Cú Pháp SELECT Đầy Đủ
    ┌─────────────────────────────────────────────────────────────────┐
    │ SELECT [DISTINCT] column_list                                   │
    │ FROM table_name                                                 │
    │ [WHERE condition]                  ← Lọc dữ liệu               │
    │ [GROUP BY column_list]             ← Nhóm dữ liệu              │
    │ [HAVING condition]                 ← Lọc nhóm                  │
    │ [ORDER BY column_list [ASC|DESC]]  ← Sắp xếp                   │
    └─────────────────────────────────────────────────────────────────┘

                    Thứ Tự Thực Hiện (Logical Order)
              ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
              │ 1. FROM     │───▶│ 2. WHERE    │───▶│ 3. GROUP BY │
              └─────────────┘    └─────────────┘    └─────────────┘
                     │                   │                   │
              ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
              │ 6. ORDER BY │◀───│ 5. SELECT   │◀───│ 4. HAVING   │
              └─────────────┘    └─────────────┘    └─────────────┘

                      Ví Dụ Đơn Giản vs Phức Tạp
Đơn Giản:                          Phức Tạp:
┌─────────────────────────┐       ┌─────────────────────────────────┐
│ SELECT *                │       │ SELECT DISTINCT                 │
│ FROM employees;         │       │   department_id,                │
└─────────────────────────┘       │   AVG(salary) as avg_sal       │
                                  │ FROM employees                  │
                                  │ WHERE hire_date > '2020-01-01'  │
                                  │ GROUP BY department_id          │
                                  │ HAVING AVG(salary) > 5000       │
                                  │ ORDER BY avg_sal DESC;          │
                                  └─────────────────────────────────┘
```

### Cấu Trúc SELECT Đơn Giản
```sql
SELECT column1, column2, ...
FROM table_name;
```

#### Biểu Diễn Trực Quan - SELECT Cơ Bản
```
                    Chọn Cột Từ Bảng
     Bảng EMPLOYEES:                    SELECT first_name, salary
     ┌────┬────────────┬─────────┬────────┐    FROM employees;
     │ ID │ FIRST_NAME │LAST_NAME│ SALARY │
     ├────┼────────────┼─────────┼────────┤         ↓
     │100 │ Steven     │ King    │ 24000  │    ┌────────────┬────────┐
     │101 │ Neena      │ Kochhar │ 17000  │    │ FIRST_NAME │ SALARY │
     │102 │ Lex        │ De Haan │ 17000  │    ├────────────┼────────┤
     │103 │ Alexander  │ Hunold  │  9000  │───▶│ Steven     │ 24000  │
     │104 │ Bruce      │ Ernst   │  6000  │    │ Neena      │ 17000  │
     │105 │ David      │ Austin  │  4800  │    │ Lex        │ 17000  │
     └────┴────────────┴─────────┴────────┘    │ Alexander  │  9000  │
                                               │ Bruce      │  6000  │
                SELECT *                       │ David      │  4800  │
                FROM employees;                └────────────┴────────┘
                      ↓
              ┌────┬────────────┬─────────┬────────┐
              │ ID │ FIRST_NAME │LAST_NAME│ SALARY │ ← Tất cả cột
              ├────┼────────────┼─────────┼────────┤
              │100 │ Steven     │ King    │ 24000  │
              │101 │ Neena      │ Kochhar │ 17000  │
              │... │    ...     │   ...   │  ...   │
              └────┴────────────┴─────────┴────────┘

                    Lưu Ý Quan Trọng
         ┌─────────────────────────────────────────┐
         │ • SELECT * : Chọn tất cả cột            │
         │ • SELECT col1, col2 : Chọn cột cụ thể   │
         │ • Thứ tự cột trong SELECT định thứ tự   │
         │   hiển thị trong kết quả                │
         │ • Dấu phẩy (,) để ngăn cách các cột     │
         └─────────────────────────────────────────┘
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

#### Biểu Diễn Trực Quan - Mẫu Truy Vấn Chung
```
              Các Thành Phần Tùy Chọn trong SELECT
    ┌─────────────────────────────────────────────────────────────┐
    │ SELECT [DISTINCT] column_list          ← BẮT BUỘC          │
    │ FROM table_name                        ← BẮT BUỘC          │
    │ [WHERE condition]                      ← Tùy chọn          │
    │ [GROUP BY column_list]                 ← Tùy chọn          │
    │ [HAVING condition]                     ← Tùy chọn          │
    │ [ORDER BY column_list [ASC|DESC]]      ← Tùy chọn          │
    └─────────────────────────────────────────────────────────────┘

                    Ví Dụ Từng Bước Xây Dựng
Bước 1 - Cơ bản:         Bước 2 - Thêm điều kiện:   Bước 3 - Thêm sắp xếp:
┌─────────────────┐      ┌─────────────────────┐    ┌─────────────────────────┐
│ SELECT name     │      │ SELECT name         │    │ SELECT name             │
│ FROM employees; │  ──▶ │ FROM employees      │──▶ │ FROM employees          │
└─────────────────┘      │ WHERE salary > 5000;│    │ WHERE salary > 5000     │
                         └─────────────────────┘    │ ORDER BY name;          │
                                                    └─────────────────────────┘

                        Mức Độ Phức Tạp
              ┌─────────────────────────────────────────┐
              │ Level 1: SELECT + FROM                  │ ← Cơ bản
              │ Level 2: + WHERE                        │
              │ Level 3: + ORDER BY                     │ 
              │ Level 4: + GROUP BY + HAVING            │
              │ Level 5: + DISTINCT + Functions         │ ← Nâng cao
              └─────────────────────────────────────────┘
```

## Bảng DUAL trong Oracle

### Giới Thiệu về DUAL
Bảng DUAL là một bảng đặc biệt trong Oracle Database với những đặc điểm sau:

- **Mục đích**: Dùng để thực hiện phép tính, gọi hàm, hoặc lấy giá trị hằng số khi không cần dữ liệu từ bảng thực
- **Cấu trúc**: Chỉ có 1 cột tên `DUMMY` kiểu VARCHAR2(1) và 1 dòng dữ liệu có giá trị 'X'
- **Sở hữu**: Thuộc về schema SYS nhưng có thể truy cập từ bất kỳ user nào

#### Biểu Diễn Trực Quan - Bảng DUAL
```
                           Bảng DUAL
                     ┌─────────────────┐
                     │     DUMMY       │ ← Cột duy nhất
                     ├─────────────────┤
                     │       X         │ ← Hàng duy nhất
                     └─────────────────┘

              Mục Đích Sử Dụng DUAL
    ┌─────────────────────────────────────────────────────────┐
    │ 1. Tính Toán Số Học                                    │
    │    SELECT 2 + 3 FROM DUAL;                             │
    │                                                        │
    │ 2. Gọi Hàm Hệ Thống                                    │
    │    SELECT SYSDATE FROM DUAL;                           │
    │                                                        │
    │ 3. Chuyển Đổi Dữ Liệu                                  │
    │    SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM DUAL;    │
    │                                                        │
    │ 4. Tạo Giá Trị Hằng Số                                 │
    │    SELECT 'Hello World' FROM DUAL;                     │
    └─────────────────────────────────────────────────────────┘

                  So Sánh Với/Không DUAL
Không có DUAL (Sai):              Có DUAL (Đúng):
┌─────────────────────┐           ┌─────────────────────┐
│ SELECT 2 + 3;       │     ✗     │ SELECT 2 + 3        │   ✓
│ -- Lỗi cú pháp      │           │ FROM DUAL;          │
└─────────────────────┘           └─────────────────────┘

              Kết Quả Điển Hình
    ┌─────────────────────────────────────────────────────────┐
    │ SQL> SELECT 'Hello' AS greeting,                        │
    │           SYSDATE AS current_date,                      │
    │           5 * 4 AS calculation                          │
    │      FROM DUAL;                                         │
    │                                                         │
    │ GREETING  CURRENT_DATE         CALCULATION              │
    │ --------  -----------------    -----------              │
    │ Hello     2024-01-15 14:30:25  20                      │
    └─────────────────────────────────────────────────────────┘

                      Đặc Điểm DUAL
         ┌─────────────────────────────────────────┐
         │ ✓ Luôn có sẵn trong Oracle              │
         │ ✓ Chỉ 1 hàng → Kết quả không lặp lại    │
         │ ✓ Nhanh → Không cần đọc dữ liệu thực     │
         │ ✓ Thuận tiện cho testing và demo        │
         │ ✗ Chỉ có trong Oracle (không chuẩn SQL) │
         └─────────────────────────────────────────┘
```

### Khi Nào Sử Dụng DUAL?
```sql
-- 1. Thực hiện phép tính số học
SELECT 2 + 3 AS result FROM dual;
SELECT 10 * 5 AS multiplication FROM dual;

-- 2. Gọi hàm hệ thống
SELECT SYSDATE AS current_date FROM dual;
SELECT USER AS current_user FROM dual;

-- 3. Chuyển đổi kiểu dữ liệu
SELECT TO_DATE('2023-12-25', 'YYYY-MM-DD') AS christmas FROM dual;
SELECT TO_CHAR(12345.67, '$999,999.99') AS formatted_number FROM dual;

-- 4. Kiểm tra hàm chuỗi
SELECT UPPER('oracle database') AS upper_text FROM dual;
SELECT LENGTH('Hello World') AS text_length FROM dual;

-- 5. Tạo dữ liệu test/constant
SELECT 'Xin chào Oracle!' AS greeting FROM dual;
SELECT 100 AS constant_value FROM dual;
```

### Ví Dụ Thực Tế với DUAL
```sql
-- Kiểm tra kết nối database
SELECT 'Kết nối thành công!' AS status FROM dual;

-- Lấy thông tin hệ thống
SELECT 
    SYSDATE AS current_datetime,
    USER AS logged_in_user,
    'Oracle Database' AS database_type
FROM dual;

-- Test công thức trước khi áp dụng vào bảng thực
SELECT 
    ROUND(1234.5678, 2) AS rounded_number,
    TRUNC(SYSDATE) AS today_no_time,
    ADD_MONTHS(SYSDATE, 6) AS six_months_later
FROM dual;
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

## Bí Danh Cột và Phân Biệt Dấu Nháy

### 1. Bí Danh Cột (Column Alias)
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

### 2. Phân Biệt Dấu Nháy Đơn và Nháy Kép

**Quan trọng**: Sau khi làm quen với SELECT cơ bản, bạn cần hiểu sự khác nhau giữa dấu nháy:

#### Dấu Nháy Đơn (' ')
- **Mục đích**: Dùng để định nghĩa **giá trị chuỗi (string literals)**
- **Sử dụng**: Trong mệnh đề WHERE, VALUES, và bất kỳ nơi nào cần giá trị chuỗi
```sql
-- Ví dụ dấu nháy đơn
SELECT * FROM employees WHERE first_name = 'John';
SELECT 'Xin chào' AS greeting FROM dual;
INSERT INTO employees (first_name) VALUES ('Jane');
```

#### Dấu Nháy Kép (" ")
- **Mục đích**: Dùng để định nghĩa **tên định danh (identifiers)** như tên cột, tên bảng, bí danh
- **Sử dụng**: Khi tên có khoảng trắng, ký tự đặc biệt, hoặc muốn giữ nguyên chữ hoa/thường
```sql
-- Ví dụ dấu nháy kép (như các ví dụ bí danh ở trên)
SELECT employee_id AS "Mã Nhân Viên" FROM employees;
SELECT first_name AS "Tên Đầu" FROM employees;
CREATE TABLE "Bảng Nhân Viên" (id NUMBER);
```

#### So Sánh Trực Quan
```sql
-- SAI: Sử dụng dấu nháy kép cho giá trị chuỗi
SELECT * FROM employees WHERE first_name = "John";  -- LỖI!

-- ĐÚNG: Sử dụng dấu nháy đơn cho giá trị chuỗi
SELECT * FROM employees WHERE first_name = 'John';  -- ĐÚNG

-- SAI: Sử dụng dấu nháy đơn cho bí danh có khoảng trắng
SELECT employee_id AS 'Mã Nhân Viên' FROM employees;  -- LỖI!

-- ĐÚNG: Sử dụng dấu nháy kép cho bí danh có khoảng trắng
SELECT employee_id AS "Mã Nhân Viên" FROM employees;  -- ĐÚNG
```

#### Quy Tắc Ghi Nhớ
1. **Dấu nháy đơn** = **Dữ liệu** (giá trị chuỗi, ngày tháng)
2. **Dấu nháy kép** = **Tên** (bí danh, tên cột, tên bảng)
3. **Không có dấu nháy** = Tên đơn giản không có khoảng trắng

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

## Toán Tử Tập Hợp (UNION, INTERSECT, MINUS)

Toán tử tập hợp cho phép bạn kết hợp kết quả từ hai hoặc nhiều truy vấn SELECT. Đây là các công cụ mạnh mẽ để thao tác với dữ liệu từ nhiều nguồn khác nhau.

### Quy Tắc Chung cho Toán Tử Tập Hợp

**Điều kiện tiên quyết:**
1. **Số cột phải giống nhau** trong tất cả các truy vấn SELECT
2. **Kiểu dữ liệu tương ứng phải tương thích**
3. **Thứ tự cột phải nhất quán**
4. **ORDER BY chỉ có thể sử dụng ở cuối** truy vấn cuối cùng

### 1. UNION - Hợp Tập Hợp

**UNION**: Kết hợp kết quả từ hai truy vấn và **loại bỏ trùng lặp**
**UNION ALL**: Kết hợp kết quả từ hai truy vấn và **giữ tất cả dòng** (bao gồm trùng lặp)

```sql
-- UNION: Loại bỏ trùng lặp (chậm hơn do phải sắp xếp)
SELECT first_name, last_name, 'Employee' AS source_type
FROM hr.employees
WHERE department_id = 10
UNION
SELECT first_name, last_name, 'Manager' AS source_type  
FROM hr.employees
WHERE employee_id IN (SELECT DISTINCT manager_id FROM hr.employees WHERE manager_id IS NOT NULL);

-- UNION ALL: Giữ tất cả dòng (nhanh hơn)
SELECT first_name, last_name, 'IT Department' AS department_type
FROM hr.employees
WHERE department_id = 60
UNION ALL
SELECT first_name, last_name, 'Sales Department' AS department_type
FROM hr.employees  
WHERE department_id = 80;
```

### 2. INTERSECT - Giao Tập Hợp

**INTERSECT**: Trả về các dòng **chung** có trong cả hai truy vấn

```sql
-- Tìm nhân viên vừa là manager vừa có lương > 10000
SELECT first_name, last_name, employee_id
FROM hr.employees
WHERE employee_id IN (SELECT DISTINCT manager_id FROM hr.employees WHERE manager_id IS NOT NULL)
INTERSECT
SELECT first_name, last_name, employee_id
FROM hr.employees
WHERE salary > 10000;

-- Tìm các phòng ban có cả nhân viên và manager
SELECT department_id, department_name
FROM hr.departments
WHERE department_id IN (SELECT department_id FROM hr.employees)
INTERSECT
SELECT department_id, department_name  
FROM hr.departments
WHERE department_id IN (SELECT DISTINCT department_id FROM hr.employees WHERE manager_id IS NOT NULL);
```

### 3. MINUS - Hiệu Tập Hợp

**MINUS**: Trả về các dòng có trong truy vấn đầu tiên nhưng **không có** trong truy vấn thứ hai

```sql
-- Tìm nhân viên không phải là manager
SELECT first_name, last_name, employee_id
FROM hr.employees
MINUS
SELECT first_name, last_name, employee_id
FROM hr.employees
WHERE employee_id IN (SELECT DISTINCT manager_id FROM hr.employees WHERE manager_id IS NOT NULL);

-- Tìm các phòng ban không có nhân viên nào
SELECT department_id, department_name
FROM hr.departments
MINUS
SELECT d.department_id, d.department_name
FROM hr.departments d
JOIN hr.employees e ON d.department_id = e.department_id;
```

### 4. Ví Dụ Thực Tế Phức Tạp

```sql
-- Báo cáo tổng hợp: Danh sách tất cả người liên quan đến IT
SELECT 
    employee_id AS id,
    first_name || ' ' || last_name AS full_name,
    'IT Employee' AS role_type,
    salary,
    hire_date
FROM hr.employees
WHERE department_id = 60  -- IT Department

UNION

SELECT 
    employee_id AS id,
    first_name || ' ' || last_name AS full_name,
    'IT Manager' AS role_type,
    salary,
    hire_date
FROM hr.employees
WHERE employee_id IN (
    SELECT DISTINCT manager_id 
    FROM hr.employees 
    WHERE department_id = 60 AND manager_id IS NOT NULL
)

ORDER BY role_type, full_name;
```

### 5. Sử Dụng với Subquery và CTE

```sql
-- Sử dụng UNION với subquery để tạo báo cáo phân tích
WITH high_earners AS (
    SELECT employee_id, first_name, last_name, salary, 'High Earner' AS category
    FROM hr.employees
    WHERE salary >= 15000
),
long_tenure AS (
    SELECT employee_id, first_name, last_name, salary, 'Long Tenure' AS category  
    FROM hr.employees
    WHERE ROUND((SYSDATE - hire_date) / 365.25) >= 10
)
SELECT * FROM high_earners
UNION
SELECT * FROM long_tenure
ORDER BY salary DESC;
```

### 6. Hiệu Suất và Thực Hành Tốt

```sql
-- TỐT: Sử dụng UNION ALL khi không cần loại bỏ trùng lặp
SELECT 'Current Year' AS period, COUNT(*) AS employee_count
FROM hr.employees  
WHERE EXTRACT(YEAR FROM hire_date) = EXTRACT(YEAR FROM SYSDATE)
UNION ALL
SELECT 'Previous Year' AS period, COUNT(*) AS employee_count
FROM hr.employees
WHERE EXTRACT(YEAR FROM hire_date) = EXTRACT(YEAR FROM SYSDATE) - 1;

-- TRÁNH: Sử dụng UNION không cần thiết khi UNION ALL đủ
-- SELECT ... UNION SELECT ... (khi không cần loại bỏ trùng lặp)
```

### 7. Xử Lý Kiểu Dữ Liệu Khác Nhau

```sql
-- Chuyển đổi kiểu dữ liệu để tương thích
SELECT 
    TO_CHAR(employee_id) AS identifier,
    first_name || ' ' || last_name AS name,
    'Employee' AS type
FROM hr.employees
WHERE department_id = 10

UNION

SELECT 
    'DEPT-' || TO_CHAR(department_id) AS identifier,
    department_name AS name,
    'Department' AS type
FROM hr.departments
WHERE department_id = 10;
```

### 8. Debugging và Phân Tích

```sql
-- Kiểm tra số lượng kết quả trước và sau UNION
-- Truy vấn 1
SELECT COUNT(*) AS query1_count 
FROM hr.employees WHERE department_id IN (10, 20);

-- Truy vấn 2  
SELECT COUNT(*) AS query2_count
FROM hr.employees WHERE salary > 5000;

-- UNION (sẽ ít hơn tổng của 2 truy vấn nếu có trùng lặp)
SELECT COUNT(*) AS union_count FROM (
    SELECT employee_id FROM hr.employees WHERE department_id IN (10, 20)
    UNION  
    SELECT employee_id FROM hr.employees WHERE salary > 5000
);

-- UNION ALL (sẽ bằng tổng của 2 truy vấn)
SELECT COUNT(*) AS union_all_count FROM (
    SELECT employee_id FROM hr.employees WHERE department_id IN (10, 20)
    UNION ALL
    SELECT employee_id FROM hr.employees WHERE salary > 5000
);
```

### So Sánh Toán Tử Tập Hợp

| Toán Tử | Mục Đích | Trùng Lặp | Hiệu Suất | Khi Nào Dùng |
|----------|----------|-----------|------------|-------------|
| UNION | Hợp tập hợp | Loại bỏ | Chậm hơn | Cần kết quả duy nhất |
| UNION ALL | Hợp tập hợp | Giữ nguyên | Nhanh hơn | Chấp nhận trùng lặp |
| INTERSECT | Giao tập hợp | Loại bỏ | Trung bình | Tìm phần tử chung |
| MINUS | Hiệu tập hợp | Loại bỏ | Trung bình | Tìm phần tử khác biệt |

## Logic Điều Kiện với CASE

Biểu thức CASE trong Oracle SQL cho phép bạn thực hiện logic điều kiện trực tiếp trong câu lệnh SELECT. Đây là công cụ mạnh mẽ để tạo ra các cột tính toán dựa trên điều kiện, tương tự như câu lệnh if-else trong các ngôn ngữ lập trình.

### Khái Niệm và Cú Pháp

**CASE Expression** là một biểu thức SQL cho phép bạn:
- **Kiểm tra điều kiện** và trả về giá trị khác nhau tùy theo kết quả
- **Thay thế nhiều câu lệnh IF** phức tạp
- **Tạo cột tính toán** với logic nghiệp vụ
- **Phân loại dữ liệu** một cách linh hoạt

#### Cấu Trúc Chung CASE WHEN
```sql
-- Cú pháp tổng quát
CASE 
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN condition3 THEN result3
    ...
    [ELSE default_result]
END

-- Ví dụ cấu trúc cơ bản
SELECT 
    column1,
    column2,
    CASE 
        WHEN column1 > 100 THEN 'Lớn'
        WHEN column1 > 50 THEN 'Trung bình'
        WHEN column1 > 0 THEN 'Nhỏ'
        ELSE 'Không hợp lệ'
    END AS category
FROM table_name;
```

#### Các Thành Phần Chính
- **CASE**: Từ khóa bắt đầu biểu thức điều kiện
- **WHEN condition**: Điều kiện cần kiểm tra
- **THEN result**: Giá trị trả về khi điều kiện đúng
- **ELSE default**: Giá trị mặc định (tùy chọn)
- **END**: Từ khóa kết thúc biểu thức CASE

#### Biểu Diễn Trực Quan - Cách Hoạt Động CASE
```
                     Logic Điều Kiện CASE
    ┌─────────────────────────────────────────────────────────┐
    │ Đọc từng hàng → Kiểm tra điều kiện → Trả về giá trị     │
    └─────────────────────────────────────────────────────────┘

              Ví Dụ: Phân Loại Lương
    Input (Salary):     CASE Logic:              Output:
    ┌──────────────┐    ┌─────────────────┐      ┌──────────┐
    │ 5000         │    │ >= 15000? NO    │      │ 'Thấp'   │
    │ 12000        │───▶│ >= 8000?  YES   │ ───▶ │ 'Trung'  │
    │ 20000        │    │ Return 'Trung'  │      │ 'Cao'    │
    │ 3000         │    │ >= 4000?  NO    │      │ 'Mới'    │
    └──────────────┘    │ ELSE 'Mới'     │      └──────────┘
                        └─────────────────┘

                  Thứ Tự Đánh Giá (Quan Trọng!)
    ┌─────────────────────────────────────────────────────────┐
    │ WHEN condition1 THEN result1  ← Kiểm tra đầu tiên       │
    │ WHEN condition2 THEN result2  ← Chỉ kiểm tra nếu #1 sai │
    │ WHEN condition3 THEN result3  ← Chỉ kiểm tra nếu #2 sai │
    │ ELSE default_result          ← Nếu tất cả đều sai       │
    └─────────────────────────────────────────────────────────┘
```

### Hai Dạng CASE Expression

#### 1. Simple CASE (So sánh trực tiếp)
```sql
-- Cú pháp
CASE expression
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ...
    ELSE default_result
END

-- Ví dụ thực tế
SELECT 
    employee_id,
    first_name,
    department_id,
    CASE department_id
        WHEN 10 THEN 'Administration'
        WHEN 20 THEN 'Marketing'
        WHEN 60 THEN 'IT'
        WHEN 80 THEN 'Sales'
        ELSE 'Other'
    END AS department_name
FROM hr.employees;
```

#### 2. Searched CASE (Điều kiện phức tạp)
```sql
-- Cú pháp
CASE 
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ...
    ELSE default_result
END

-- Ví dụ thực tế (được khuyến nghị vì linh hoạt hơn)
SELECT 
    employee_id,
    first_name,
    salary,
    CASE 
        WHEN salary >= 15000 THEN 'Cao'
        WHEN salary >= 8000 THEN 'Trung Bình'
        WHEN salary >= 4000 THEN 'Thấp'
        ELSE 'Mới Vào'
    END AS salary_category
FROM hr.employees;
```

### Quy Tắc và Lưu Ý Quan Trọng

#### Quy Tắc Kiểu Dữ Liệu
- **Tất cả kết quả phải có cùng kiểu dữ liệu** hoặc có thể chuyển đổi được
- **Oracle tự động chuyển đổi** kiểu dữ liệu khi cần thiết
- **NULL được phép** trong bất kỳ mệnh đề THEN hoặc ELSE nào

```sql
-- ĐÚNG: Tất cả kết quả đều là VARCHAR2
CASE 
    WHEN salary > 10000 THEN 'Cao'
    WHEN salary > 5000 THEN 'Trung'
    ELSE 'Thấp'
END

-- SAI: Trộn lẫn kiểu dữ liệu không tương thích
CASE 
    WHEN salary > 10000 THEN 'Cao'      -- VARCHAR2
    WHEN salary > 5000 THEN salary      -- NUMBER
    ELSE 0                              -- NUMBER
END
```

#### Thứ Tự Đánh Giá
- **Kiểm tra từ trên xuống dưới**: Điều kiện đầu tiên đúng sẽ được thực thi
- **Dừng ngay khi tìm thấy**: Không kiểm tra các điều kiện sau
- **ELSE là tùy chọn**: Nếu không có ELSE và không có điều kiện nào đúng → trả về NULL

### Các Trường Hợp Sử Dụng Thực Tế

#### 1. Phân Loại và Nhóm Dữ Liệu
```sql
-- Phân loại nhân viên theo nhiều tiêu chí
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    ROUND((SYSDATE - hire_date) / 365.25) AS years_worked,
    CASE 
        WHEN salary >= 15000 AND ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN 'Senior High Earner'
        WHEN salary >= 15000 THEN 'High Earner'
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN 'Senior Staff'
        WHEN salary >= 8000 THEN 'Mid Level'
        ELSE 'Junior'
    END AS employee_level
FROM hr.employees;
```

#### 2. Tính Toán Có Điều Kiện
```sql
-- Tính thưởng dựa trên hiệu suất và thâm niên
SELECT 
    employee_id,
    first_name,
    salary,
    CASE 
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN salary * 0.15  -- 15% cho > 10 năm
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 5 THEN salary * 0.10   -- 10% cho > 5 năm
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 2 THEN salary * 0.05   -- 5% cho > 2 năm
        ELSE 0  -- Không thưởng cho nhân viên mới
    END AS annual_bonus
FROM hr.employees;
```

#### 3. Xử Lý Giá Trị NULL
```sql
-- Hiển thị thông tin hoa hồng
SELECT 
    employee_id,
    first_name,
    commission_pct,
    salary,
    CASE 
        WHEN commission_pct IS NULL THEN 'Không có hoa hồng'
        WHEN commission_pct >= 0.3 THEN 'Hoa hồng cao (' || (commission_pct * 100) || '%)'
        WHEN commission_pct >= 0.1 THEN 'Hoa hồng trung bình (' || (commission_pct * 100) || '%)'
        ELSE 'Hoa hồng thấp (' || (commission_pct * 100) || '%)'
    END AS commission_status
FROM hr.employees;
```

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

### 3. CASE trong Tính Toán Tổng Hợp
```sql
-- Sử dụng CASE với hàm tổng hợp để tạo báo cáo thống kê
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary >= 10000 THEN 1 END) AS high_earners,
    COUNT(CASE WHEN commission_pct IS NOT NULL THEN 1 END) AS employees_with_commission,
    AVG(CASE WHEN salary >= 10000 THEN salary END) AS avg_high_salary,
    SUM(CASE 
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN salary * 0.15
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 5 THEN salary * 0.10
        ELSE salary * 0.05
    END) AS total_bonus_budget
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
```

### 4. CASE Lồng Nhau (Nested CASE)
```sql
-- Phân loại phức tạp với nhiều lớp điều kiện
SELECT 
    employee_id,
    first_name,
    job_id,
    salary,
    CASE 
        WHEN job_id LIKE '%PRES%' THEN 'Executive'
        WHEN job_id LIKE '%VP%' THEN 'Vice President'
        WHEN job_id LIKE '%MGR%' OR job_id LIKE '%MAN%' THEN 
            CASE 
                WHEN salary >= 12000 THEN 'Senior Manager'
                ELSE 'Manager'
            END
        ELSE 
            CASE 
                WHEN salary >= 8000 THEN 'Senior Staff'
                WHEN salary >= 4000 THEN 'Regular Staff'
                ELSE 'Junior Staff'
            END
    END AS position_level
FROM hr.employees;
```

### Hiệu Suất và Thực Hành Tốt

#### Thực Hành Tốt
```sql
-- TỐT: Điều kiện cụ thể trước, chung sau
CASE 
    WHEN salary >= 20000 THEN 'Executive'     -- Ít người thỏa mãn
    WHEN salary >= 15000 THEN 'Senior'        -- Ít hơn
    WHEN salary >= 8000 THEN 'Mid Level'      -- Nhiều hơn
    ELSE 'Junior'                             -- Nhiều nhất
END

-- TỐT: Sử dụng điều kiện đơn giản khi có thể
CASE department_id
    WHEN 10 THEN 'Admin'
    WHEN 20 THEN 'Marketing'
    WHEN 60 THEN 'IT'
    ELSE 'Other'
END
```

#### Tránh
```sql
-- TRÁNH: Điều kiện phức tạp không cần thiết
CASE 
    WHEN UPPER(SUBSTR(job_id, 1, 2)) = 'IT' THEN 'Technology'
    -- Thay vì
    WHEN job_id LIKE 'IT%' THEN 'Technology'
END

-- TRÁNH: Quá nhiều điều kiện phức tạp trong một CASE
-- Hãy chia thành nhiều CASE hoặc sử dụng bảng lookup
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

### Bài Tập 4: Toán Tử Tập Hợp
```sql
-- Sử dụng UNION để tạo danh sách tất cả nhân viên và manager,
-- với cột bổ sung chỉ ra vai trò của họ
-- Truy vấn của bạn ở đây:
```

### Bài Tập 5: Phân Tích Dữ Liệu với INTERSECT
```sql
-- Tìm các nhân viên vừa có lương cao (>= 10000) 
-- vừa làm việc lâu năm (>= 5 năm) sử dụng INTERSECT
-- Truy vấn của bạn ở đây:
```

### Bài Tập 6: Sử Dụng MINUS
```sql
-- Tìm các phòng ban có trong bảng departments 
-- nhưng chưa có nhân viên nào được gán vào
-- Truy vấn của bạn ở đây:
```

## Tóm Tắt Thực Hành Tốt

1. **Luôn chỉ định tên cột** thay vì sử dụng SELECT *
2. **Sử dụng bí danh có ý nghĩa** để dễ đọc hơn
3. **Phân biệt rõ dấu nháy đơn và kép**:
   - Nháy đơn cho dữ liệu/giá trị
   - Nháy kép cho tên/bí danh có khoảng trắng
4. **Sử dụng DUAL** cho phép tính và test hàm đơn giản
5. **Hiểu rõ toán tử tập hợp**:
   - UNION/UNION ALL cho hợp tập hợp  
   - INTERSECT cho giao tập hợp
   - MINUS cho hiệu tập hợp
6. **Xử lý giá trị NULL** phù hợp với NVL/NVL2
7. **Định dạng đầu ra** để trình bày tốt hơn bằng TO_CHAR
8. **Sử dụng câu lệnh CASE** cho logic điều kiện
9. **Ghi chú truy vấn** để tài liệu hóa
10. **Kiểm tra với tập dữ liệu nhỏ** trước
11. **Cân nhắc hiệu suất** khi sử dụng hàm

## Lỗi Phổ Biến Cần Tránh

1. **Quên dấu chấm phẩy** ở cuối câu lệnh
2. **Nhầm lẫn dấu nháy đơn và kép**:
   - Dùng nháy kép cho giá trị chuỗi: `WHERE name = "John"` ❌
   - Dùng nháy đơn cho bí danh có khoảng trắng: `AS 'Mã NV'` ❌
3. **Không xử lý giá trị NULL** trong tính toán
4. **Sử dụng hàm không cần thiết** trong mệnh đề WHERE
5. **Quên bí danh bảng** khi tên cột không rõ ràng
6. **Không hiểu khi nào dùng DUAL** cho các phép tính đơn giản
7. **Sai cấu trúc toán tử tập hợp**:
   - Số cột không khớp trong UNION: `SELECT a, b UNION SELECT c` ❌
   - Kiểu dữ liệu không tương thích: `SELECT 1 UNION SELECT 'text'` ❌
   - ORDER BY ở vị trí sai: `SELECT a UNION ORDER BY a SELECT b` ❌

## Bước Tiếp Theo

Bây giờ bạn đã hiểu về câu lệnh SELECT, tiến tới:
1. **Mệnh Đề WHERE và Lọc Dữ Liệu** - Học cách lọc dữ liệu
2. **ORDER BY** - Sắp xếp kết quả hiệu quả
3. **Hàm Tổng Hợp** - Tóm tắt dữ liệu
4. Thực hành với các bài tập được cung cấp

Thành thạo những kiến thức cơ bản này trước khi chuyển sang join và subquery trong Bài 4!
