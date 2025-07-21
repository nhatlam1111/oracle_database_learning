# Sắp Xếp Với ORDER BY

## Mục Lục
1. [Cú Pháp ORDER BY Cơ Bản](#cú-pháp-order-by-cơ-bản)
2. [Sắp Xếp Một Cột](#sắp-xếp-một-cột)
3. [Sắp Xếp Nhiều Cột](#sắp-xếp-nhiều-cột)
4. [Sắp Xếp Theo Các Loại Dữ Liệu Khác Nhau](#sắp-xếp-theo-các-loại-dữ-liệu-khác-nhau)
5. [Sắp Xếp Với Biểu Thức và Hàm](#sắp-xếp-với-biểu-thức-và-hàm)
6. [Sắp Xếp Với Bí Danh](#sắp-xếp-với-bí-danh)
7. [Xử Lý Giá Trị NULL Trong Sắp Xếp](#xử-lý-giá-trị-null-trong-sắp-xếp)
8. [Sắp Xếp Dựa Trên CASE](#sắp-xếp-dựa-trên-case)
9. [Kỹ Thuật Sắp Xếp Nâng Cao](#kỹ-thuật-sắp-xếp-nâng-cao)
10. [Cân Nhắc Về Hiệu Suất](#cân-nhắc-về-hiệu-suất)
11. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
12. [Mẫu ORDER BY Phổ Biến](#mẫu-order-by-phổ-biến)

Mệnh đề ORDER BY cho phép bạn sắp xếp kết quả truy vấn theo thứ tự tăng dần hoặc giảm dần dựa trên một hoặc nhiều cột. Sắp xếp phù hợp làm cho việc phân tích và trình bày dữ liệu hiệu quả hơn nhiều.

### Biểu Diễn Trực Quan - Tổng Quan ORDER BY
```
                    Luồng Hoạt Động ORDER BY
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   TABLE     │──▶│   WHERE     │───▶│  ORDER BY   │───▶│   RESULT    │
│ (Dữ liệu)   │    │ (Lọc)       │    │ (Sắp xếp)   │    │ (Đã sắp)    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘

                Before ORDER BY              After ORDER BY
               ┌────┬──────┬────────┐       ┌────┬──────┬────────┐
               │ ID │ Name │ Salary │       │ ID │ Name │ Salary │
               │ 3  │Carol │ 12000  │       │ 5  │Alice │ 15000  │
               │ 1  │Bob   │  8000  │  ───▶ │ 3  │Carol │ 12000  │
               │ 5  │Alice │ 15000  │       │ 1  │Bob   │  8000  │
               │ 2  │David │  6000  │       │ 2  │David │  6000  │
               └────┴──────┴────────┘       └────┴──────┴────────┘
                  (Không có thứ tự)            (Sắp xếp theo Salary DESC)

                        Mức Độ Phức Tạp Sắp Xếp
                ┌─────────────────────────────────────────┐
                │ Level 1: ORDER BY column                │ ← Cơ bản
                │ Level 2: ORDER BY col1, col2            │
                │ Level 3: ORDER BY expr, function        │
                │ Level 4: ORDER BY CASE, NULLS handling  │ ← Nâng cao
                └─────────────────────────────────────────┘
```

## Cú Pháp ORDER BY Cơ Bản

```sql
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC], ...;
```

### Biểu Diễn Trực Quan - Cú Pháp ORDER BY
```
                     Cấu Trúc Câu Lệnh SQL Với ORDER BY
    ┌─────────────────────────────────────────────────────────────────┐
    │ SELECT column1, column2, ...        ← Chọn cột                  │
    │ FROM table_name                     ← Bảng nguồn                │
    │ [WHERE condition]                   ← Lọc (tùy chọn)            │
    │ ORDER BY col1 [ASC|DESC], ...       ← Sắp xếp (cuối cùng)       │
    └─────────────────────────────────────────────────────────────────┘

              Hướng Sắp Xếp (Sort Direction)
    ┌──────────────┬─────────────────┬──────────────────────┐
    │  Từ Khóa     │   Ý Nghĩa       │      Ví Dụ           │
    ├──────────────┼─────────────────┼──────────────────────┤
    │ ASC (mặc định)│ Tăng dần       │ 1, 2, 3, 4, 5        │
    │               │ A → Z           │ Alice, Bob, Carol    │
    │               │ Cũ → Mới        │ 1990 → 2024          │
    ├──────────────┼─────────────────┼──────────────────────┤
    │ DESC          │ Giảm dần       │ 5, 4, 3, 2, 1        │
    │               │ Z → A           │ Carol, Bob, Alice    │
    │               │ Mới → Cũ        │ 2024 → 1990          │
    └──────────────┴─────────────────┴──────────────────────┘

                    Ví Dụ Thực Tế
Data:                    ORDER BY salary ASC:     ORDER BY salary DESC:
┌──────┬────────┐       ┌──────┬────────┐        ┌──────┬────────┐
│ Name │ Salary │       │ Name │ Salary │        │ Name │ Salary │
│Alice │ 15000  │       │David │  6000  │        │Alice │ 15000  │
│Bob   │  8000  │  ───▶ │Bob   │  8000  │   ───▶ │Carol │ 12000  │
│Carol │ 12000  │       │Carol │ 12000  │        │Bob   │  8000  │
│David │  6000  │       │Alice │ 15000  │        │David │  6000  │
└──────┴────────┘       └──────┴────────┘        └──────┴────────┘
```

## Sắp Xếp Một Cột

### 1. Thứ Tự Tăng Dần (Mặc Định)
```sql
-- Sắp xếp nhân viên theo họ (A đến Z)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name;

-- Chỉ định rõ ràng ASC (kết quả giống như trên)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name ASC;
```

#### Biểu Diễn Trực Quan - Sắp Xếp Tăng Dần
```
                    Sắp Xếp Theo Tên (ASC)
Original Data:                        After ORDER BY last_name ASC:
┌────┬───────┬─────────┬────────┐     ┌────┬───────┬─────────┬────────┐
│ ID │ First │ Last    │ Salary │     │ ID │ First │ Last    │ Salary │
│100 │Steven │ King    │ 24000  │     │104 │Bruce  │ Austin  │  4800  │
│101 │Neena  │ Kochhar │ 17000  │ ──▶ │102 │Lex    │ De Haan │ 17000  │
│102 │Lex    │ De Haan │ 17000  │     │103 │Alexander│ Hunold │  9000  │
│103 │Alexander│ Hunold │  9000  │     │100 │Steven │ King    │ 24000  │
│104 │Bruce  │ Austin  │  4800  │     │101 │Neena  │ Kochhar │ 17000  │
└────┴───────┴─────────┴────────┘     └────┴───────┴─────────┴────────┘

                    Thứ Tự Alphabet (A → Z)
              A  Austin  De Haan  Hunold  King  Kochhar  Z
              ├────┼────────┼────────┼──────┼──────┤
              │    ✓        ✓        ✓      ✓      ✓
              └────────────────────────────────────┘
                          Tăng dần →
```

### 2. Thứ Tự Giảm Dần
```sql
-- Sắp xếp nhân viên theo lương (cao nhất đến thấp nhất)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC;

-- Sắp xếp theo ngày tuyển dụng (gần đây nhất trước)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date DESC;
```

#### Biểu Diễn Trực Quan - Sắp Xếp Giảm Dần
```
                    Sắp Xếp Theo Lương (DESC)
Original Data:                        After ORDER BY salary DESC:
┌────┬───────┬─────────┬────────┐     ┌────┬───────┬─────────┬────────┐
│ ID │ First │ Last    │ Salary │     │ ID │ First │ Last    │ Salary │
│100 │Steven │ King    │ 24000  │     │100 │Steven │ King    │ 24000  │ ← Cao nhất
│101 │Neena  │ Kochhar │ 17000  │ ──▶ │101 │Neena  │ Kochhar │ 17000  │
│102 │Lex    │ De Haan │ 17000  │     │102 │Lex    │ De Haan │ 17000  │
│103 │Alexander│ Hunold │  9000  │     │103 │Alexander│ Hunold │  9000  │
│104 │Bruce  │ Austin  │  4800  │     │104 │Bruce  │ Austin  │  4800  │ ← Thấp nhất
└────┴───────┴─────────┴────────┘     └────┴───────┴─────────┴────────┘

                    Dải Lương (Cao → Thấp)
              24000   17000   17000    9000    4800
                ├───────┼───────┼───────┼───────┤
                │       │       │       │       │
                ✓       ✓       ✓      ✓       ✓
                └───────────────────────────────┘
                           Giảm dần ←

                    Sắp Xếp Theo Ngày (DESC)
                2024-01-15  2020-05-10  2015-03-20  2010-12-01
                    ├───────────┼───────────┼───────────┤
                    │           │           │           │
                   Mới ────────────────────────────── Cũ
                    ✓           ✓          ✓           ✓
                    └───────────────────────────────────┘
                              Gần đây ← Xa xưa
```

## Sắp Xếp Nhiều Cột

### 1. Sắp Xếp Chính và Phụ
```sql
-- Sắp xếp theo phòng ban trước, sau đó theo lương trong mỗi phòng ban
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY department_id ASC, salary DESC;

-- Sắp xếp theo job_id, sau đó theo họ, rồi theo tên
SELECT employee_id, first_name, last_name, job_id, salary
FROM hr.employees
ORDER BY job_id, last_name, first_name;
```

#### Biểu Diễn Trực Quan - Sắp Xếp Nhiều Cột
```
          Sắp Xếp Theo department_id ASC, salary DESC
Original Data:                  After Multi-Column Sort:
┌────┬──────┬──────┬────────┐   ┌────┬──────┬──────┬────────┐
│ ID │ Name │ Dept │ Salary │   │ ID │ Name │ Dept │ Salary │
│100 │Alice │  60  │ 15000  │   │103 │Carol │  10  │ 12000  │ ← Dept 10, highest salary
│101 │Bob   │  90  │  8000  │   │104 │David │  10  │  8000  │ ← Dept 10, lower salary
│102 │Carol │  10  │ 12000  │──▶│100 │Alice │  60  │ 15000  │ ← Dept 60, highest salary
│103 │Carol │  10  │ 12000  │   │105 │Eve   │  60  │ 10000  │ ← Dept 60, lower salary
│104 │David │  10  │  8000  │   │101 │Bob   │  90  │  8000  │ ← Dept 90
│105 │Eve   │  60  │ 10000  │   └────┴──────┴──────┴────────┘
└────┴──────┴──────┴────────┘

                    Thứ Tự Ưu Tiên Sắp Xếp
    ┌─────────────────────────────────────────────────────────┐
    │ 1. department_id ASC    ← Ưu tiên cao nhất              │
    │    │                                                    │
    │    └─▶ 2. salary DESC  ← Ưu tiên thứ hai (trong cùng dept) │
    └─────────────────────────────────────────────────────────┘

                      Nhóm Theo Dept
      Dept 10          Dept 60          Dept 90
   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
   │Carol │12000 │  │Alice│15000 │  │Bob  │ 8000 │
   │David │ 8000 │  │Eve  │10000 │  └─────────────┘
   └─────────────┘  └─────────────┘
   Trong nhóm:      Trong nhóm:      Chỉ 1 người
   Salary DESC      Salary DESC

                 Quy Tắc "Tie-Breaking"
    ┌─────────────────────────────────────────────────────────┐
    │ Khi cột đầu tiên bằng nhau → sử dụng cột thứ hai        │
    │ Khi cả 2 cột đầu bằng nhau → sử dụng cột thứ ba         │
    │ ...và tiếp tục như vậy                                  │
    └─────────────────────────────────────────────────────────┘
```

### 2. Thứ Tự Sắp Xếp Hỗn Hợp
```sql
-- Phòng ban tăng dần, lương giảm dần, ngày tuyển dụng tăng dần
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    department_id, 
    salary, 
    hire_date
FROM hr.employees
ORDER BY 
    department_id ASC,
    salary DESC,
    hire_date ASC;
```

## Sắp Xếp Theo Các Loại Dữ Liệu Khác Nhau

### 1. Sắp Xếp Số
```sql
-- Sắp xếp theo lương (số)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary IS NOT NULL
ORDER BY salary DESC;

-- Sắp xếp theo ID nhân viên
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY employee_id;
```

### 2. Sắp Xếp Chuỗi
```sql
-- Sắp xếp theo bảng chữ cái (phân biệt hoa thường trong Oracle)
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY last_name, first_name;

-- Sắp xếp không phân biệt hoa thường
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY UPPER(last_name), UPPER(first_name);

-- Sắp xếp theo độ dài chuỗi
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY LENGTH(last_name) DESC, last_name;
```

### 3. Sắp Xếp Ngày Tháng
```sql
-- Sắp xếp theo ngày tuyển dụng (cũ nhất trước)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date ASC;

-- Sắp xếp theo ngày tuyển dụng (mới nhất trước)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date DESC;

-- Sắp xếp theo tháng của ngày tuyển dụng
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY EXTRACT(MONTH FROM hire_date), hire_date;
```

## Sắp Xếp Với Biểu Thức và Hàm

### 1. Cột Tính Toán
```sql
-- Sắp xếp theo lương hàng năm được tính toán
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    salary * 12 AS annual_salary
FROM hr.employees
ORDER BY salary * 12 DESC;

-- Sắp xếp theo tổng thu nhập (lương + hoa hồng)
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    commission_pct,
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees
ORDER BY salary + (salary * NVL(commission_pct, 0)) DESC;
```

### 2. Sắp Xếp Dựa Trên Hàm
```sql
-- Sắp xếp theo số năm làm việc
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    hire_date,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_service
FROM hr.employees
ORDER BY (SYSDATE - hire_date) DESC;

-- Sắp xếp theo họ tên đầy đủ
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY first_name || ' ' || last_name;

-- Sắp xếp theo chênh lệch tuyệt đối so với lương trung bình
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    ABS(salary - (SELECT AVG(salary) FROM hr.employees)) AS salary_diff
FROM hr.employees
ORDER BY ABS(salary - (SELECT AVG(salary) FROM hr.employees));
```

## Sắp Xếp Với Bí Danh

### 1. Sử Dụng Bí Danh Cột
```sql
-- Sắp xếp theo tên bí danh
SELECT 
    employee_id AS emp_id,
    first_name || ' ' || last_name AS full_name,
    salary * 12 AS annual_salary
FROM hr.employees
ORDER BY annual_salary DESC, full_name;

-- Lưu ý: Bạn có thể sử dụng bí danh trong ORDER BY được định nghĩa trong SELECT
```

### 2. Số Thứ Tự Cột
```sql
-- Sắp xếp theo vị trí cột (không khuyến nghị cho sản xuất)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY 4 DESC, 3, 2;  -- 4=salary, 3=last_name, 2=first_name

-- Tốt hơn là sử dụng tên cột cho rõ ràng
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC, last_name, first_name;
```

## Xử Lý Giá Trị NULL Trong Sắp Xếp

### 1. Hành Vi NULL Mặc Định
```sql
-- Trong Oracle, NULL được sắp xếp cuối cùng trong ASC, đầu tiên trong DESC theo mặc định
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct ASC;  -- NULL xuất hiện cuối

SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC; -- NULL xuất hiện đầu
```

#### Biểu Diễn Trực Quan - Xử Lý NULL
```
                    Hành Vi NULL Mặc Định Trong Oracle
Data with NULL:                ORDER BY commission_pct ASC:
┌────┬──────┬─────────────┐   ┌────┬──────┬─────────────┐
│ ID │ Name │Commission   │   │ ID │ Name │Commission   │
│100 │Alice │ 0.15        │   │102 │Carol │ 0.10        │ ← Thấp nhất
│101 │Bob   │ NULL        │   │100 │Alice │ 0.15        │
│102 │Carol │ 0.10        │──▶│103 │David │ 0.25        │ ← Cao nhất
│103 │David │ 0.25        │   │101 │Bob   │ NULL        │ ← NULL cuối
│104 │Eve   │ NULL        │   │104 │Eve   │ NULL        │ ← NULL cuối
└────┴──────┴─────────────┘   └────┴──────┴─────────────┘

Data with NULL:                ORDER BY commission_pct DESC:
┌────┬──────┬─────────────┐   ┌────┬──────┬─────────────┐
│ ID │ Name │Commission   │   │ ID │ Name │Commission   │
│100 │Alice │ 0.15        │   │101 │Bob   │ NULL        │ ← NULL đầu
│101 │Bob   │ NULL        │   │104 │Eve   │ NULL        │ ← NULL đầu
│102 │Carol │ 0.10        │──▶│103 │David │ 0.25        │ ← Cao nhất
│103 │David │ 0.25        │   │100 │Alice │ 0.15        │
│104 │Eve   │ NULL        │   │102 │Carol │ 0.10        │ ← Thấp nhất
└────┴──────┴─────────────┘   └────┴──────┴─────────────┘

                    Quy Tắc NULL Trong Oracle
              ┌─────────────────────────────────────────┐
              │ ASC (Tăng dần):  0.1  0.15  0.25  NULL  │
              │                   ↑               ↑     │
              │                 Thấp           NULL cuối│
              │                                         │
              │ DESC (Giảm dần): NULL  0.25  0.15  0.1  │
              │                    ↑               ↑    │
              │                 NULL đầu        Thấp   │
              └─────────────────────────────────────────┘

                    So Sánh Với Các DBMS Khác
    ┌──────────────┬─────────────┬─────────────────────────┐
    │   Database   │ NULL trong  │    NULL trong DESC      │
    │              │    ASC      │                         │
    ├──────────────┼─────────────┼─────────────────────────┤
    │ Oracle       │ Cuối cùng   │ Đầu tiên                │
    │ SQL Server   │ Đầu tiên    │ Đầu tiên                │
    │ MySQL        │ Đầu tiên    │ Cuối cùng               │
    │ PostgreSQL   │ Cuối cùng   │ Đầu tiên                │
    └──────────────┴─────────────┴─────────────────────────┘
```

### 2. Kiểm Soát Vị Trí NULL
```sql
-- Buộc NULL xuất hiện đầu tiên trong sắp xếp tăng dần
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct NULLS FIRST;

-- Buộc NULL xuất hiện cuối cùng trong sắp xếp giảm dần
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC NULLS LAST;

-- Ví dụ phức tạp với nhiều cột
SELECT employee_id, first_name, last_name, manager_id, commission_pct
FROM hr.employees
ORDER BY 
    manager_id NULLS LAST,
    commission_pct DESC NULLS LAST,
    last_name;
```

#### Biểu Diễn Trực Quan - Kiểm Soát NULL
```
                Control NULL Position với NULLS FIRST/LAST
Original Data:                 ORDER BY commission_pct NULLS FIRST:
┌────┬──────┬─────────────┐    ┌────┬──────┬─────────────┐
│ ID │ Name │Commission   │    │ ID │ Name │Commission   │
│100 │Alice │ 0.15        │    │101 │Bob   │ NULL        │ ← NULL đầu
│101 │Bob   │ NULL        │    │104 │Eve   │ NULL        │ ← NULL đầu
│102 │Carol │ 0.10        │──▶ │102 │Carol │ 0.10        │
│103 │David │ 0.25        │    │100 │Alice │ 0.15        │
│104 │Eve   │ NULL        │    │103 │David │ 0.25        │
└────┴──────┴─────────────┘    └────┴──────┴─────────────┘

Original Data:                 ORDER BY commission_pct DESC NULLS LAST:
┌────┬──────┬─────────────┐    ┌────┬──────┬─────────────┐
│ ID │ Name │Commission   │    │ ID │ Name │Commission   │
│100 │Alice │ 0.15        │    │103 │David │ 0.25        │ ← Cao nhất
│101 │Bob   │ NULL        │    │100 │Alice │ 0.15        │
│102 │Carol │ 0.10        │──▶ │102 │Carol │ 0.10        │ ← Thấp nhất
│103 │David │ 0.25        │    │101 │Bob   │ NULL        │ ← NULL cuối
│104 │Eve   │ NULL        │    │104 │Eve   │ NULL        │ ← NULL cuối
└────┴──────┴─────────────┘    └────┴──────┴─────────────┘

              Bảng Tổng Hợp NULLS FIRST/LAST
    ┌──────────────┬──────────────┬─────────────────────┐
    │   Trường hợp │  NULL vị trí │      Kết quả        │
    ├──────────────┼──────────────┼─────────────────────┤
    │ ASC          │ Mặc định     │ value1, value2, NULL│
    │ ASC NULLS FIRST│ Buộc đầu   │ NULL, value1, value2│
    │ ASC NULLS LAST │ Buộc cuối  │ value1, value2, NULL│
    ├──────────────┼──────────────┼─────────────────────┤
    │ DESC         │ Mặc định     │ NULL, value2, value1│
    │ DESC NULLS FIRST│ Buộc đầu  │ NULL, value2, value1│
    │ DESC NULLS LAST│ Buộc cuối  │ value2, value1, NULL│
    └──────────────┴──────────────┴─────────────────────┘

                    Ví Dụ Thực Tế - Multi-Column
    ORDER BY manager_id NULLS LAST, commission_pct DESC NULLS LAST:
    ┌────┬──────┬──────────┬─────────────┐
    │ ID │ Name │ Manager  │ Commission  │
    │103 │David │   100    │    0.25     │ ← Manager 100, cao nhất commission
    │100 │Alice │   100    │    0.15     │ ← Manager 100, thấp hơn
    │102 │Carol │   101    │    0.10     │ ← Manager 101
    │105 │Frank │   101    │    NULL     │ ← Manager 101, NULL commission cuối
    │101 │Bob   │   NULL   │    NULL     │ ← NULL manager cuối cùng
    └────┴──────┴──────────┴─────────────┘
```

### 3. Xử Lý NULL Thay Thế
```sql
-- Thay thế NULL bằng một giá trị để sắp xếp
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY NVL(commission_pct, -1) DESC;

-- Sắp xếp NULL như thể chúng bằng không
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY NVL(commission_pct, 0), last_name;
```

## Sắp Xếp Dựa Trên CASE

### 1. Thứ Tự Sắp Xếp Tùy Chỉnh
```sql
-- Sắp xếp phòng ban theo thứ tự tùy chỉnh
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
ORDER BY 
    CASE department_id
        WHEN 90 THEN 1  -- Điều hành trước
        WHEN 60 THEN 2  -- IT thứ hai
        WHEN 80 THEN 3  -- Bán hàng thứ ba
        ELSE 4          -- Tất cả khác cuối cùng
    END,
    last_name;
```

### 2. Sắp Xếp Dựa Trên Ưu Tiên
```sql
-- Sắp xếp theo ưu tiên danh mục lương
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    CASE 
        WHEN salary >= 15000 THEN 'Cao'
        WHEN salary >= 8000 THEN 'Trung Bình'
        ELSE 'Thấp'
    END AS salary_category
FROM hr.employees
ORDER BY 
    CASE 
        WHEN salary >= 15000 THEN 1
        WHEN salary >= 8000 THEN 2
        ELSE 3
    END,
    salary DESC;
```

### 3. Sắp Xếp Kiểu Boolean
```sql
-- Sắp xếp theo trạng thái hoa hồng (có hoa hồng trước)
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY 
    CASE WHEN commission_pct IS NOT NULL THEN 0 ELSE 1 END,
    commission_pct DESC,
    last_name;
```

## Kỹ Thuật Sắp Xếp Nâng Cao

### 1. Sắp Xếp Tự Nhiên Cho Dữ Liệu Chữ-Số
```sql
-- Cho dữ liệu như 'Item1', 'Item2', 'Item10' để sắp xếp tự nhiên
-- Đây là ví dụ đơn giản - sắp xếp tự nhiên thực tế phức tạp hơn
SELECT product_id, product_name
FROM sales.products
ORDER BY 
    LENGTH(product_name),
    product_name;
```

### 2. Sắp Xếp Theo Nhiều Tiêu Chí Với Trọng Số
```sql
-- Tính điểm có trọng số để xếp hạng nhân viên
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_service,
    -- Điểm có trọng số: 70% lương, 30% kinh nghiệm
    (salary * 0.7) + (ROUND((SYSDATE - hire_date) / 365.25, 1) * 1000 * 0.3) AS weighted_score
FROM hr.employees
ORDER BY (salary * 0.7) + (ROUND((SYSDATE - hire_date) / 365.25, 1) * 1000 * 0.3) DESC;
```

### 3. Sắp Xếp Ngẫu Nhiên
```sql
-- Thứ tự ngẫu nhiên (hữu ích cho lấy mẫu)
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY DBMS_RANDOM.VALUE;

-- Mẫu ngẫu nhiên 5 nhân viên
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE ROWNUM <= 5
ORDER BY DBMS_RANDOM.VALUE;
```

## Cân Nhắc Về Hiệu Suất

### 1. Sắp Xếp Thân Thiện Với Index
```sql
-- Tốt: Sắp xếp theo cột có index
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY employee_id;  -- Khóa chính, tự động có index

-- Xem xét tạo index cho các cột thường xuyên được sắp xếp
-- CREATE INDEX emp_lastname_idx ON hr.employees(last_name);
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY last_name;
```

### 2. Giới Hạn Kết Quả Với Sắp Xếp
```sql
-- Truy vấn Top N - hiệu quả hơn việc sắp xếp tất cả các hàng
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE ROWNUM <= 10
ORDER BY salary DESC;

-- Cách tiếp cận tốt hơn sử dụng analytic functions (Oracle 12c+)
SELECT employee_id, first_name, last_name, salary
FROM (
    SELECT employee_id, first_name, last_name, salary
    FROM hr.employees
    ORDER BY salary DESC
)
WHERE ROWNUM <= 10;
```

### 3. Tránh Các Thao Tác Tốn Kém
```sql
-- Tốn kém: Hàm trên mỗi hàng
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY EXTRACT(YEAR FROM hire_date);

-- Tốt hơn: Xem xét thêm cột tính toán hoặc function-based index
-- Nếu truy vấn này thường xuyên, tạo function-based index:
-- CREATE INDEX emp_hire_year_idx ON hr.employees(EXTRACT(YEAR FROM hire_date));
```

## Ví Dụ Thực Tế

### 1. Danh Bạ Nhân Viên
```sql
-- Danh bạ nhân viên được sắp xếp theo phòng ban và tên
SELECT 
    d.department_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.phone_number,
    j.job_title
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY 
    d.department_name,
    e.last_name,
    e.first_name;
```

### 2. Báo Cáo Bán Hàng
```sql
-- Sản phẩm bán chạy nhất theo doanh thu
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_quantity,
    SUM(od.unit_price * od.quantity) AS total_revenue
FROM sales.products p
JOIN sales.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 
    SUM(od.unit_price * od.quantity) DESC,
    SUM(od.quantity) DESC,
    p.product_name;
```

### 3. Báo Cáo Lương
```sql
-- Báo cáo lương được sắp xếp theo phòng ban và lương
SELECT 
    d.department_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    e.salary,
    NVL(e.commission_pct, 0) AS commission_rate,
    e.salary + (e.salary * NVL(e.commission_pct, 0)) AS total_compensation
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY 
    d.department_name,
    e.salary + (e.salary * NVL(e.commission_pct, 0)) DESC,
    e.last_name;
```

## Mẫu ORDER BY Phổ Biến

### 1. Báo Cáo Theo Thời Gian
```sql
-- Hoạt động gần đây trước
SELECT order_id, customer_id, order_date, freight
FROM sales.orders
ORDER BY order_date DESC, order_id DESC;

-- Phân tích lịch sử (cũ nhất trước)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date ASC, employee_id ASC;
```

### 2. Dữ Liệu Phân Cấp
```sql
-- Cấu trúc phân cấp quản lý-nhân viên
SELECT 
    LEVEL,
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    manager_id,
    job_id
FROM hr.employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name, first_name;
```

### 3. Sắp Xếp Thống Kê
```sql
-- Sắp xếp dựa trên tứ phân vị
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM hr.employees
ORDER BY salary_quartile, salary DESC;
```

## Bài Tập

### Bài Tập 1: Sắp Xếp Cơ Bản
```sql
-- Sắp xếp tất cả nhân viên theo ngày tuyển dụng (mới nhất trước), 
-- sau đó theo họ theo thứ tự bảng chữ cái
-- Truy vấn của bạn ở đây:
```

### Bài Tập 2: Sắp Xếp Phức Tạp
```sql
-- Tạo báo cáo hiển thị sản phẩm được sắp xếp theo:
-- 1. Trạng thái tồn kho (hết hàng trước, sau đó tồn kho thấp, rồi bình thường)
-- 2. ID danh mục
-- 3. Đơn giá (cao nhất trước)
-- 4. Tên sản phẩm theo thứ tự bảng chữ cái
-- Truy vấn của bạn ở đây:
```

### Bài Tập 3: Thứ Tự Sắp Xếp Tùy Chỉnh
```sql
-- Sắp xếp nhân viên với ưu tiên này:
-- 1. Điều hành (job_id bắt đầu bằng 'AD_') trước
-- 2. Quản lý (job_id kết thúc bằng '_MGR' hoặc '_MAN') thứ hai  
-- 3. Tất cả khác thứ ba
-- Trong mỗi nhóm, sắp xếp theo lương giảm dần
-- Truy vấn của bạn ở đây:
```

### Bài Tập 4: Xử Lý NULL
```sql
-- Hiển thị tất cả nhân viên được sắp xếp theo commission_pct giảm dần,
-- nhưng đặt nhân viên không có hoa hồng ở cuối,
-- sau đó sắp xếp theo lương giảm dần
-- Truy vấn của bạn ở đây:
```

## Tóm Tắt Thực Hành Tốt Nhất

1. **Luôn chỉ định hướng sắp xếp** một cách rõ ràng (ASC/DESC) cho rõ ràng
2. **Sử dụng tên cột có ý nghĩa** thay vì số thứ tự
3. **Xem xét xử lý NULL** một cách rõ ràng khi cần thiết
4. **Sắp xếp theo cột có index** khi có thể để tối ưu hiệu suất
5. **Sử dụng bí danh** cho các biểu thức phức tạp trong ORDER BY
6. **Giới hạn kết quả** khi có thể để cải thiện hiệu suất
7. **Kiểm tra với dữ liệu thực** để đảm bảo thứ tự sắp xếp đáp ứng yêu cầu
8. **Ghi chú logic sắp xếp phức tạp** bằng comment

## Lỗi Phổ Biến Cần Tránh

1. **Dựa vào thứ tự sắp xếp mặc định** mà không có ORDER BY
2. **Sử dụng vị trí cột** thay vì tên (giảm khả năng đọc)
3. **Bỏ qua hành vi NULL** khi nó quan trọng
4. **Sắp xếp bằng hàm** mà không xem xét tác động hiệu suất
5. **Không xem xét tính phân biệt hoa thường** trong sắp xếp chuỗi
6. **Quên rằng ORDER BY đến cuối cùng** trong cấu trúc câu lệnh SQL
7. **Trộn lẫn kiểu dữ liệu** trong biểu thức sắp xếp

## Mẹo Hiệu Suất

1. **Tạo index** trên các cột thường xuyên được sắp xếp
2. **Sử dụng ROWNUM hoặc FETCH FIRST** để giới hạn kết quả
3. **Tránh hàm** trong ORDER BY khi có thể
4. **Xem xét composite index** cho sắp xếp nhiều cột
5. **Sử dụng analytic functions** cho truy vấn xếp hạng
6. **Kiểm tra hiệu suất** với khối lượng dữ liệu thực tế

## Bước Tiếp Theo

Thành thạo sắp xếp ORDER BY trước khi chuyển sang:
1. **Hàm Tổng Hợp** - Tóm tắt dữ liệu đã sắp xếp
2. **GROUP BY** - Nhóm dữ liệu trước khi sắp xếp
3. **Analytic Functions** - Sắp xếp và xếp hạng nâng cao
4. **Tối Ưu Hiệu Suất** - Tối ưu hóa các thao tác sắp xếp

Sắp xếp rất quan trọng cho việc trình bày và phân tích dữ liệu, vì vậy hãy thực hành với các tình huống và loại dữ liệu khác nhau!
