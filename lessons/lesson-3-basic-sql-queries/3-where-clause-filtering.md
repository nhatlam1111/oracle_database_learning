# Mệnh Đề WHERE và Lọc Dữ Liệu

## Mục Lục
1. [Cú Pháp Mệnh Đề WHERE Cơ Bản](#cú-pháp-mệnh-đề-where-cơ-bản)
2. [Toán Tử So Sánh](#toán-tử-so-sánh)
3. [Khớp Mẫu Chuỗi](#khớp-mẫu-chuỗi)
4. [Lọc Theo Phạm Vi và Danh Sách](#lọc-theo-phạm-vi-và-danh-sách)
5. [Xử Lý Giá Trị NULL](#xử-lý-giá-trị-null)
6. [Toán Tử Logic](#toán-tử-logic)
7. [Ưu Tiên Toán Tử và Dấu Ngoặc Đơn](#ưu-tiên-toán-tử-và-dấu-ngoặc-đơn)
8. [Kỹ Thuật Lọc Nâng Cao](#kỹ-thuật-lọc-nâng-cao)
9. [Lọc Với Hàm](#lọc-với-hàm)
10. [Cân Nhắc Về Hiệu Suất](#cân-nhắc-về-hiệu-suất)
11. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
12. [Mẫu Mệnh Đề WHERE Phổ Biến](#mẫu-mệnh-đề-where-phổ-biến)

Mệnh đề WHERE được sử dụng để lọc các bản ghi và chỉ truy xuất những bản ghi đáp ứng các điều kiện cụ thể. Đây là một trong những phần quan trọng nhất của SQL cho việc phân tích và báo cáo dữ liệu.

### Biểu Diễn Trực Quan - Hoạt Động WHERE
```
Bảng gốc (ALL ROWS)          Mệnh đề WHERE         Kết quả (FILTERED ROWS)
┌─────────────────────┐     ┌─────────────────┐    ┌─────────────────────┐
│ ID │Name  │Salary   │     │  WHERE salary   │    │ ID │Name  │Salary   │
│ 1  │Alice │ 5000    │────▶│    > 4000       │───▶│ 1  │Alice │ 5000    │
│ 2  │Bob   │ 3000    │     │                 │    │ 4  │Diana │ 6000    │
│ 3  │Carol │ 2000    │     └─────────────────┘    │ 5  │Eve   │ 7000    │
│ 4  │Diana │ 6000    │                            └─────────────────────┘
│ 5  │Eve   │ 7000    │
└─────────────────────┘

                    Luồng Xử Lý WHERE
              ┌─────────────────────────────┐
              │  1. Đọc từng hàng           │
              └─────────────────────────────┘
                          │
              ┌─────────────────────────────┐
              │  2. Áp dụng điều kiện WHERE │
              └─────────────────────────────┘
                          │
              ┌─────────────────────────────┐
              │  3. Trả về hàng thỏa mãn    │
              └─────────────────────────────┘
```

## Cú Pháp Mệnh Đề WHERE Cơ Bản

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

### Biểu Diễn Trực Quan - Cú Pháp WHERE
```
                   Cấu Trúc Câu Lệnh SQL
┌──────────────────────────────────────────────────────────────┐
│ SELECT column1, column2, ...    ← Chọn cột cần hiển thị      │
│ FROM table_name                 ← Chỉ định bảng nguồn       │
│ WHERE condition;                ← Điều kiện lọc              │
└──────────────────────────────────────────────────────────────┘

        Thứ Tự Thực Hiện (Execution Order)
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │ 1. FROM     │───▶│ 2. WHERE    │───▶│ 3. SELECT   │
   │ (Đọc bảng)  │    │ (Lọc dữ liệu)│    │ (Chọn cột)  │
   └─────────────┘    └─────────────┘    └─────────────┘

                    Ví Dụ Đơn Giản
  Employees Table:      WHERE dept_id = 10      Kết Quả:
  ┌────┬──────┬────┐    ┌─────────────────┐    ┌────┬──────┬────┐
  │ ID │ Name │Dept│    │   Chỉ lấy hàng  │    │ 1  │Alice │ 10 │
  │ 1  │Alice │ 10 │───▶│   có dept_id=10 │───▶│ 3  │Carol │ 10 │
  │ 2  │Bob   │ 20 │    │                 │    └────┴──────┴────┘
  │ 3  │Carol │ 10 │    └─────────────────┘
  └────┴──────┴────┘
```

## Toán Tử So Sánh

### Biểu Diễn Trực Quan - Các Toán Tử So Sánh
```
                      Toán Tử So Sánh Oracle
┌──────────────┬─────────────┬─────────────────────────────────┐
│   Toán Tử    │   Ý Nghĩa   │            Ví Dụ               │
├──────────────┼─────────────┼─────────────────────────────────┤
│      =       │   Bằng      │ WHERE salary = 5000             │
│     <> !=    │  Không bằng │ WHERE dept_id <> 10             │
│      >       │   Lớn hơn   │ WHERE age > 25                  │
│      <       │   Nhỏ hơn   │ WHERE price < 100               │
│     >=       │ Lớn hơn =   │ WHERE experience >= 5           │
│     <=       │ Nhỏ hơn =   │ WHERE rating <= 4.5             │
└──────────────┴─────────────┴─────────────────────────────────┘

            Minh Họa So Sánh Số (salary = 5000)
      ┌─────────────────────────────────────────────┐
      │        Dải Giá Trị Lương                    │
      │   2000    3000    4000    5000    6000      │
      │     │       │       │       ●       │       │
      │     │       │       │      TRUE     │       │
      │   FALSE   FALSE   FALSE             FALSE   │
      └─────────────────────────────────────────────┘

            Minh Họa So Sánh Phạm Vi (salary > 4000)
      ┌─────────────────────────────────────────────┐
      │        Dải Giá Trị Lương                    │
      │   2000    3000    4000    5000    6000      │
      │     │       │       │       │       │       │
      │   FALSE   FALSE   FALSE   TRUE    TRUE      │
      │                           ████████████      │
      │                           Vùng TRUE         │
      └─────────────────────────────────────────────┘
```

### 1. Bằng và Không Bằng
```sql
-- Khớp chính xác
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id = 60;

-- Không bằng (nhiều cách)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id != 60;

-- Toán tử không bằng thay thế
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id <> 60;

SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE NOT department_id = 60;
```

### 2. So Sánh Số
```sql
-- Lớn hơn
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary > 10000;

-- Lớn hơn hoặc bằng
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary >= 10000;

-- Nhỏ hơn
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary < 5000;

-- Nhỏ hơn hoặc bằng
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary <= 5000;
```

#### Biểu Diễn Trực Quan - So Sánh Số
```
                 Phân Tích So Sánh Lương (salary > 10000)
      ┌─────────────────────────────────────────────────────────┐
      │           Dải Lương Nhân Viên                           │
      │  2000   5000   8000   10000   12000   15000   20000     │
      │    │     │      │       │       │       │       │       │
      │  FALSE FALSE FALSE    FALSE   TRUE    TRUE    TRUE      │
      │                        ▲       ████████████████████     │
      │                    Điểm cắt    Vùng thỏa mãn (>10000)  │
      └─────────────────────────────────────────────────────────┘

              So Sánh >= vs > (Điểm cắt tại 10000)
      ┌─────────────────────────────────────────────────────────┐
      │  salary > 10000:   ●─────────────────────────▶          │
      │                   FALSE    TRUE                         │
      │                          (không bao gồm 10000)         │
      │                                                         │
      │  salary >= 10000:  ●─────────────────────────▶          │
      │                   FALSE    TRUE                         │
      │                          (bao gồm 10000)               │
      └─────────────────────────────────────────────────────────┘

                    Ví Dụ Thực Tế Với Dữ Liệu
Employees Table:              WHERE salary > 10000:
┌────┬──────┬────────┐        ┌────┬──────┬────────┐
│ ID │ Name │ Salary │        │ ID │ Name │ Salary │
│ 1  │Alice │  8000  │ ✗      │ 3  │Carol │ 12000  │ ✓
│ 2  │Bob   │ 10000  │ ✗      │ 5  │Eve   │ 15000  │ ✓
│ 3  │Carol │ 12000  │ ✓ ───▶ └────┴──────┴────────┘
│ 4  │David │  6000  │ ✗
│ 5  │Eve   │ 15000  │ ✓ ───▶
└────┴──────┴────────┘

                Ghi Chú Quan Trọng
         ┌─────────────────────────────────────┐
         │ • > : Lớn hơn nghiêm ngặt          │
         │ • >= : Lớn hơn hoặc bằng           │
         │ • < : Nhỏ hơn nghiêm ngặt          │
         │ • <= : Nhỏ hơn hoặc bằng           │
         │                                    │
         │ Chú ý: 10000 > 10000 = FALSE      │
         │        10000 >= 10000 = TRUE       │
         └─────────────────────────────────────┘
```

### 3. So Sánh Ngày Tháng
```sql
-- Nhân viên được tuyển sau một ngày cụ thể
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date > DATE '1995-01-01';

-- Nhân viên được tuyển trong 10 năm qua
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date >= ADD_MONTHS(SYSDATE, -120);

-- Nhân viên được tuyển vào một ngày cụ thể
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date = DATE '1987-06-17';
```

#### Biểu Diễn Trực Quan - So Sánh Ngày Tháng
```
                    Timeline So Sánh Ngày (hire_date > '1995-01-01')
      ┌─────────────────────────────────────────────────────────────────┐
      │  1990      1993      1995-01-01    1998      2001      2024     │
      │    │         │           │          │         │         │       │
      │  FALSE     FALSE      ●(FALSE)    TRUE      TRUE      TRUE      │
      │                       ↑          ████████████████████████       │
      │                   Điểm cắt       Vùng thỏa mãn                  │
      └─────────────────────────────────────────────────────────────────┘

            Định Dạng Ngày Trong Oracle (Các Cách Viết)
      ┌─────────────────────────────────────────────────────────────────┐
      │ • DATE '1995-01-01'                    ← Chuẩn ISO (khuyến khích)│
      │ • TO_DATE('01/01/1995', 'MM/DD/YYYY')  ← Với format rõ ràng      │
      │ • TO_DATE('1995-01-01', 'YYYY-MM-DD')  ← Format tường minh       │
      │ • '01-JAN-95'                          ← Oracle default format   │
      └─────────────────────────────────────────────────────────────────┘

                    Ví Dụ Thực Tế Với Dữ Liệu Ngày
Employees Table:                    WHERE hire_date > DATE '1995-01-01':
┌────┬──────┬─────────────┐         ┌────┬──────┬─────────────┐
│ ID │ Name │  Hire_Date  │         │ ID │ Name │  Hire_Date  │
│ 1  │Alice │ 1993-05-15  │ ✗       │ 3  │Carol │ 1997-08-20  │ ✓
│ 2  │Bob   │ 1995-01-01  │ ✗       │ 4  │David │ 2000-03-10  │ ✓
│ 3  │Carol │ 1997-08-20  │ ✓ ────▶ └────┴──────┴─────────────┘
│ 4  │David │ 2000-03-10  │ ✓ ────▶
│ 5  │Eve   │ 1990-12-25  │ ✗
└────┴──────┴─────────────┘

                Phép Tính Ngày Động
      ┌─────────────────────────────────────────────────────────────────┐
      │ ADD_MONTHS(SYSDATE, -120)  ← 10 năm trước (120 tháng)           │
      │                                                                 │
      │ Nếu hôm nay là 2024-01-15:                                      │
      │ ADD_MONTHS('2024-01-15', -120) = '2014-01-15'                   │
      │                                                                 │
      │ Kết Quả Timeline:                                               │
      │ 2010 ──── 2014-01-15 ──── 2018 ──── 2022 ──── 2024             │
      │                   ↑                          ↑                  │
      │                10 năm trước              Hôm nay               │
      │               ████████████████████████████████                  │
      │               Nhân viên được tuyển trong 10 năm qua             │
      └─────────────────────────────────────────────────────────────────┘
```

## Khớp Mẫu Chuỗi

### 1. Toán Tử LIKE
Toán tử LIKE được sử dụng để khớp mẫu với ký tự đại diện:
- `%` - khớp với bất kỳ chuỗi ký tự nào (bao gồm không có ký tự)
- `_` - khớp với chính xác một ký tự

#### Biểu Diễn Trực Quan - Ký Tự Đại Diện LIKE
```
                    Ký Tự Đại Diện (Wildcards)
         ┌─────────────────────────────────────────────────────┐
         │ % = Khớp 0 hoặc nhiều ký tự bất kỳ                  │
         │ _ = Khớp chính xác 1 ký tự                          │
         └─────────────────────────────────────────────────────┘

                Mẫu Khớp Phổ Biến
    ┌──────────────┬─────────────────┬─────────────────────────┐
    │   Mẫu LIKE   │    Ý Nghĩa     │         Ví Dụ           │
    ├──────────────┼─────────────────┼─────────────────────────┤
    │ 'S%'         │ Bắt đầu bằng S  │ 'Steven', 'Sarah'       │
    │ '%n'         │ Kết thúc bằng n │ 'John', 'Steven'        │
    │ '%an%'       │ Chứa 'an'       │ 'Diana', 'Brandon'      │
    │ '____'       │ Chính xác 4 ký tự│ 'John', 'Mary'         │
    │ 'S___n'      │ S + 3 ký tự + n │ 'Steven', 'Susan'       │
    └──────────────┴─────────────────┴─────────────────────────┘

                Minh Họa Cụ Thể: first_name LIKE 'S%'
Names List:                           Kết Quả Khớp:
┌─────────────┐                      ┌─────────────┐
│ Steven      │ ✓ Bắt đầu bằng S ──▶ │ Steven      │
│ Diana       │ ✗ Không bắt đầu S    │ Sarah       │
│ Sarah       │ ✓ Bắt đầu bằng S ──▶ │ Sam         │
│ John        │ ✗ Không bắt đầu S    └─────────────┘
│ Sam         │ ✓ Bắt đầu bằng S ──▶
│ Michael     │ ✗ Không bắt đầu S
└─────────────┘

                Minh Họa: first_name LIKE '____'
Names List:                           Kết Quả Khớ​p:
┌─────────────┐                      ┌─────────────┐
│ John        │ ✓ (4 ký tự) ──────▶  │ John        │
│ Diana       │ ✗ (5 ký tự)          │ Mary        │
│ Mary        │ ✓ (4 ký tự) ──────▶  │ Lisa        │
│ Michael     │ ✗ (7 ký tự)          └─────────────┘
│ Lisa        │ ✓ (4 ký tự) ──────▶
│ Alexander   │ ✗ (9 ký tự)
└─────────────┘

            Sự Khác Biệt % vs _
  ┌───────────────────────────────────────────────────────────┐
  │ Mẫu: 'A%'     → Khớp: 'A', 'Alice', 'Alexander'          │
  │                        ↑     ↑        ↑                   │
  │                     0 ký tự  4 ký tự  8 ký tự             │
  │                                                           │
  │ Mẫu: 'A_'     → Khớp: 'AB', 'Al' (chính xác 2 ký tự)    │
  │                        ↑     ↑                            │
  │                    A + 1 ký tự                            │
  │                                                           │
  │ Mẫu: 'A___'   → Khớp: 'Alex', 'Anna' (chính xác 4 ký tự) │
  │                        ↑      ↑                           │
  │                    A + 3 ký tự                            │
  └───────────────────────────────────────────────────────────┘
```

```sql
-- Tên bắt đầu bằng 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE 'S%';

-- Tên kết thúc bằng 'n'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '%n';

-- Tên chứa 'an'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '%an%';

-- Tên có chính xác 4 ký tự
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '____';

-- Địa chỉ email từ domain cụ thể
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE email LIKE '%@company.com';
```

### 2. Tìm Kiếm Không Phân Biệt Hoa Thường
```sql
-- Sử dụng hàm UPPER cho tìm kiếm không phân biệt hoa thường
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE UPPER(first_name) LIKE 'STEVEN%';

-- Sử dụng hàm LOWER
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE LOWER(first_name) LIKE 'steven%';
```

### 3. NOT LIKE
```sql
-- Tên không bắt đầu bằng 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name NOT LIKE 'S%';

-- Địa chỉ email không từ domain cụ thể
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE email NOT LIKE '%@oldcompany.com';
```

## Lọc Theo Phạm Vi và Danh Sách

### 1. Toán Tử BETWEEN
```sql
-- Phạm vi lương
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary BETWEEN 5000 AND 10000;

-- Phạm vi ngày tháng
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date BETWEEN DATE '1990-01-01' AND DATE '1999-12-31';

-- NOT BETWEEN
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary NOT BETWEEN 5000 AND 10000;
```

### 2. Toán Tử IN
```sql
-- Phòng ban cụ thể
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id IN (10, 20, 30);

-- ID công việc cụ thể
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
WHERE job_id IN ('IT_PROG', 'SA_REP', 'FI_ACCOUNT');

-- NOT IN
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id NOT IN (10, 20, 30);

-- Giá trị chuỗi với IN
SELECT product_id, product_name, category_id
FROM sales.products
WHERE product_name IN ('Chai', 'Chang', 'Aniseed Syrup');
```

## Xử Lý Giá Trị NULL

### 1. IS NULL
```sql
-- Nhân viên không có hoa hồng
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NULL;

-- Nhân viên không có quản lý
SELECT employee_id, first_name, last_name, manager_id
FROM hr.employees
WHERE manager_id IS NULL;
```

### 2. IS NOT NULL
```sql
-- Nhân viên có hoa hồng
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NOT NULL;

-- Sản phẩm có mức đặt hàng lại được thiết lập
SELECT product_id, product_name, reorder_level
FROM sales.products
WHERE reorder_level IS NOT NULL;
```

### 3. Lưu Ý Quan Trọng Về NULL
```sql
-- So sánh NULL luôn trả về FALSE
-- Các truy vấn này không trả về kết quả nào ngay cả khi có giá trị NULL:
SELECT * FROM hr.employees WHERE commission_pct = NULL;  -- Sai!
SELECT * FROM hr.employees WHERE commission_pct != NULL; -- Sai!

-- Cách đúng để kiểm tra NULL:
SELECT * FROM hr.employees WHERE commission_pct IS NULL;     -- Đúng
SELECT * FROM hr.employees WHERE commission_pct IS NOT NULL; -- Đúng
```

## Toán Tử Logic

### 1. Toán Tử AND
```sql
-- Nhiều điều kiện phải đúng
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 8000 AND department_id = 60;

-- Ba điều kiện
SELECT employee_id, first_name, last_name, salary, hire_date
FROM hr.employees
WHERE salary > 5000 
  AND department_id IN (10, 20, 30)
  AND hire_date > DATE '1990-01-01';
```

### 2. Toán Tử OR
```sql
-- Bất kỳ điều kiện nào có thể đúng
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 15000 OR department_id = 90;

-- Nhiều điều kiện OR
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
WHERE job_id = 'IT_PROG' 
   OR job_id = 'SA_REP' 
   OR job_id = 'FI_ACCOUNT';
```

### 3. Toán Tử NOT
```sql
-- Phủ định điều kiện
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE NOT department_id = 60;

-- NOT với điều kiện phức tạp
SELECT employee_id, first_name, last_name, salary, commission_pct
FROM hr.employees
WHERE NOT (salary < 5000 OR commission_pct IS NULL);
```

## Ưu Tiên Toán Tử và Dấu Ngoặc Đơn

### 1. Hiểu Về Ưu Tiên
```sql
-- Không có dấu ngoặc đơn (AND có ưu tiên cao hơn OR)
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE department_id = 60 OR department_id = 90 AND salary > 15000;
-- Điều này được hiểu là: department_id = 60 OR (department_id = 90 AND salary > 15000)

-- Với dấu ngoặc đơn để rõ ràng
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE (department_id = 60 OR department_id = 90) AND salary > 15000;
```

### 2. Điều Kiện Phức Tạp Với Dấu Ngoặc Đơn
```sql
-- Logic nghiệp vụ phức tạp
SELECT employee_id, first_name, last_name, salary, department_id, commission_pct
FROM hr.employees
WHERE (department_id IN (80, 90) AND salary > 10000)
   OR (commission_pct IS NOT NULL AND salary > 8000)
   OR (department_id = 60 AND hire_date < DATE '1995-01-01');
```

## Kỹ Thuật Lọc Nâng Cao

### 1. Biểu Thức Chính Quy (Đặc Trưng Oracle)
```sql
-- Sử dụng REGEXP_LIKE cho khớp mẫu phức tạp
SELECT employee_id, first_name, last_name, phone_number
FROM hr.employees
WHERE REGEXP_LIKE(phone_number, '^[0-9]{3}\.[0-9]{3}\.[0-9]{4}$');

-- Xác thực email với regex
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Tên bắt đầu bằng nguyên âm
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE REGEXP_LIKE(first_name, '^[AEIOU]', 'i');
```

### 2. Toán Tử EXISTS (Xem Trước)
```sql
-- Nhân viên có lịch sử công việc (xem trước về subqueries)
SELECT e.employee_id, e.first_name, e.last_name
FROM hr.employees e
WHERE EXISTS (
    SELECT 1 
    FROM hr.job_history jh 
    WHERE jh.employee_id = e.employee_id
);
```

## Lọc Với Hàm

### 1. Hàm Ngày Tháng Trong WHERE
```sql
-- Nhân viên được tuyển trong năm cụ thể
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(YEAR FROM hire_date) = 1987;

-- Nhân viên được tuyển trong tháng hiện tại
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(MONTH FROM hire_date) = EXTRACT(MONTH FROM SYSDATE);

-- Nhân viên có kỷ niệm ngày làm việc trong tháng này
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(MONTH FROM hire_date) = EXTRACT(MONTH FROM SYSDATE)
  AND EXTRACT(DAY FROM hire_date) = EXTRACT(DAY FROM SYSDATE);
```

### 2. Hàm Chuỗi Trong WHERE
```sql
-- Lọc theo độ dài chuỗi
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE LENGTH(first_name) > 6;

-- Lọc theo chuỗi con
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE SUBSTR(email, 1, 1) = UPPER(SUBSTR(first_name, 1, 1));
```

### 3. Hàm Số Trong WHERE
```sql
-- Làm tròn lương đến nghìn gần nhất
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE MOD(salary, 1000) = 0;

-- Nhân viên có lương kết thúc bằng 00
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE MOD(salary, 100) = 0;
```

## Cân Nhắc Về Hiệu Suất

### 1. Truy Vấn Thân Thiện Với Index
```sql
-- Tốt: So sánh cột trực tiếp (có thể sử dụng index)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE employee_id = 100;

-- Kém hiệu quả hơn: Hàm trên cột (có thể không sử dụng index)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE UPPER(first_name) = 'STEVEN';

-- Tốt hơn: Lưu trữ dữ liệu trong trường hợp nhất quán hoặc sử dụng function-based index
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name = 'Steven';
```

### 2. Lọc Có Chọn Lọc
```sql
-- Điều kiện có tính chọn lọc cao hơn trước
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 15000        -- Chọn lọc cao hơn
  AND department_id = 60;   -- Chọn lọc thấp hơn

-- Sử dụng điều kiện cụ thể khi có thể
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE employee_id BETWEEN 100 AND 110;  -- Quét phạm vi
```

## Ví Dụ Thực Tế

### 1. Hệ Thống Tìm Kiếm Nhân Viên
```sql
-- Tìm kiếm nhân viên toàn diện
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    email,
    phone_number,
    hire_date,
    salary,
    department_id
FROM hr.employees
WHERE (first_name LIKE '%ohn%' OR last_name LIKE '%ohn%')  -- Tìm kiếm tên
  AND salary BETWEEN 5000 AND 15000                        -- Phạm vi lương
  AND hire_date >= DATE '1990-01-01'                       -- Lọc ngày tuyển dụng
  AND commission_pct IS NOT NULL;                          -- Có hoa hồng
```

### 2. Báo Cáo Tồn Kho Sản Phẩm
```sql
-- Sản phẩm cần chú ý
SELECT 
    product_id,
    product_name,
    unit_price,
    units_in_stock,
    reorder_level,
    discontinued
FROM sales.products
WHERE (units_in_stock <= reorder_level OR units_in_stock = 0)  -- Tồn kho thấp hoặc hết hàng
  AND discontinued = 0                                         -- Chỉ sản phẩm đang hoạt động
  AND unit_price > 10                                          -- Mặt hàng giá trị cao
ORDER BY units_in_stock ASC;
```

### 3. Phân Tích Bán Hàng
```sql
-- Đơn hàng giá trị cao gần đây
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.freight
FROM sales.orders o
WHERE o.order_date >= ADD_MONTHS(SYSDATE, -6)  -- 6 tháng qua
  AND o.freight > 50                           -- Chi phí vận chuyển cao
  AND o.shipped_date IS NOT NULL;              -- Đã giao hàng
```

## Mẫu Mệnh Đề WHERE Phổ Biến

### 1. Kiểm Tra Chất Lượng Dữ Liệu
```sql
-- Tìm các vấn đề chất lượng dữ liệu tiềm ẩn
SELECT employee_id, first_name, last_name, email, phone_number
FROM hr.employees
WHERE email IS NULL                          -- Thiếu email
   OR phone_number IS NULL                   -- Thiếu số điện thoại
   OR LENGTH(first_name) < 2                 -- Tên rất ngắn
   OR salary <= 0                            -- Lương không hợp lệ
   OR hire_date > SYSDATE;                   -- Ngày tuyển dụng trong tương lai
```

### 2. Xác Thực Quy Tắc Nghiệp Vụ
```sql
-- Nhân viên vi phạm quy tắc nghiệp vụ
SELECT employee_id, first_name, last_name, salary, commission_pct
FROM hr.employees
WHERE (job_id LIKE 'SA_%' AND commission_pct IS NULL)     -- Bán hàng không có hoa hồng
   OR (job_id NOT LIKE 'SA_%' AND commission_pct IS NOT NULL) -- Không phải bán hàng nhưng có hoa hồng
   OR (salary < 2000)                                     -- Dưới mức lương tối thiểu
   OR (salary > 50000 AND job_id LIKE '%CLERK%');         -- Thư ký với lương cao
```

### 3. Bộ Lọc Báo Cáo
```sql
-- Bộ lọc báo cáo hàng tháng
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM hr.employees
WHERE department_id IN (10, 20, 30, 40, 50)              -- Phòng ban cụ thể
  AND salary BETWEEN 3000 AND 20000                      -- Phạm vi lương
  AND hire_date BETWEEN DATE '2020-01-01' AND DATE '2023-12-31'  -- Phạm vi ngày
  AND (commission_pct IS NULL OR commission_pct < 0.3);   -- Bộ lọc hoa hồng
```

## Bài Tập

### Bài Tập 1: Lọc Cơ Bản
```sql
-- Tìm tất cả lập trình viên IT với lương lớn hơn 5000
-- Truy vấn của bạn ở đây:
```

### Bài Tập 2: Điều Kiện Phức Tạp
```sql
-- Tìm nhân viên thỏa mãn một trong các điều kiện:
-- 1. Làm việc ở phòng ban 60 với lương > 8000, HOẶC
-- 2. Có hoa hồng và lương > 10000, HOẶC  
-- 3. Là quản lý (manager_id IS NULL) ở phòng ban 90
-- Truy vấn của bạn ở đây:
```

### Bài Tập 3: Khớp Mẫu Chuỗi
```sql
-- Tìm tất cả sản phẩm có tên chứa 'ch' (không phân biệt hoa thường)
-- và không bị ngừng sản xuất
-- Truy vấn của bạn ở đây:
```

### Bài Tập 4: Lọc Ngày Tháng
```sql
-- Tìm nhân viên được tuyển trong những năm 1990 và vẫn làm việc ở phòng ban ban đầu
-- (gợi ý: kiểm tra xem họ không xuất hiện trong bảng job_history)
-- Truy vấn của bạn ở đây:
```

## Tóm Tắt Thực Hành Tốt Nhất

1. **Sử dụng toán tử phù hợp** cho từng loại dữ liệu
2. **Xử lý giá trị NULL** một cách rõ ràng với IS NULL/IS NOT NULL
3. **Sử dụng dấu ngoặc đơn** để làm rõ các điều kiện phức tạp
4. **Chú ý đến hiệu suất** khi sử dụng hàm trên các cột
5. **Sử dụng điều kiện cụ thể** thay vì phạm vi rộng khi có thể
6. **Kiểm tra các trường hợp biên** bao gồm NULL, chuỗi rỗng và giá trị biên
7. **Xem xét tính phân biệt hoa thường** cho so sánh chuỗi
8. **Sử dụng index hiệu quả** bằng cách tránh hàm trên các cột có index

## Lỗi Phổ Biến Cần Tránh

1. **Sử dụng = hoặc != với giá trị NULL** (sử dụng IS NULL/IS NOT NULL)
2. **Quên ưu tiên toán tử** (sử dụng dấu ngoặc đơn cho rõ ràng)
3. **Vấn đề phân biệt hoa thường** trong so sánh chuỗi
4. **Định dạng ngày không chính xác** (sử dụng DATE literal hoặc hàm TO_DATE)
5. **Sử dụng LIKE mà không có ký tự đại diện** (sử dụng = thay thế)
6. **Không xem xét NULL** trong điều kiện NOT IN
7. **Sử dụng quá nhiều hàm** trên các cột trong mệnh đề WHERE

## Bước Tiếp Theo

Thành thạo lọc mệnh đề WHERE trước khi chuyển sang:
1. **ORDER BY** - Học cách sắp xếp kết quả đã lọc
2. **Hàm Tổng Hợp** - Tóm tắt dữ liệu đã lọc
3. **GROUP BY và HAVING** - Nhóm và lọc dữ liệu tổng hợp

Mệnh đề WHERE là cơ bản cho tất cả các truy vấn SQL, vì vậy hãy thực hành nhiều với các điều kiện và loại dữ liệu khác nhau!
