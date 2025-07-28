# Sắp Xếp Dữ Liệu với ORDER BY

## Mục Lục
1. [Khái Niệm ORDER BY](#1-khái-niệm-order-by)
2. [Thứ Tự Thực Thi và Hiệu Suất](#2-thứ-tự-thực-thi-và-hiệu-suất)
3. [Sắp Xếp Tăng Dần và Giảm Dần](#3-sắp-xếp-tăng-dần-và-giảm-dần)
4. [Sắp Xếp Theo Nhiều Cột](#4-sắp-xếp-theo-nhiều-cột)
5. [Sắp Xếp Với Giá Trị NULL](#5-sắp-xếp-với-giá-trị-null)
6. [Sắp Xếp Theo Vị Trí Cột](#6-sắp-xếp-theo-vị-trí-cột)
7. [Sắp Xếp Với Biểu Thức và Hàm](#7-sắp-xếp-với-biểu-thức-và-hàm)
8. [Lỗi Thường Gặp](#8-lỗi-thường-gặp)

---

## 1. Khái Niệm ORDER BY

**ORDER BY** là mệnh đề được sử dụng để sắp xếp kết quả truy vấn theo một hoặc nhiều cột theo thứ tự mong muốn.

### Tại Sao Cần ORDER BY?
Khi không sử dụng ORDER BY, Oracle **không đảm bảo** thứ tự cụ thể nào cho kết quả trả về. Thứ tự có thể phụ thuộc vào:

- **Thứ tự vật lý** dữ liệu được lưu trữ trên đĩa
- **Cách Oracle đọc** dữ liệu (theo block, extent)
- **Execution plan** mà Oracle optimizer chọn
- **Index** được sử dụng (nếu có)
- **Parallel processing** (xử lý song song)

### Biểu Diễn: Thứ Tự Không Đảm Bảo
```
Không có ORDER BY:
┌─────────────────────────────────────────┐
│ Lần chạy 1: Alice, Bob, Carol, David    │
│ Lần chạy 2: David, Alice, Carol, Bob    │ ← Khác thứ tự
│ Lần chạy 3: Carol, Bob, Alice, David    │ ← Lại khác
└─────────────────────────────────────────┘
→ Kết quả không thể dự đoán được

Có ORDER BY name:
┌─────────────────────────────────────────┐
│ Mọi lần chạy: Alice, Bob, Carol, David  │ ← Luôn cố định
└─────────────────────────────────────────┘
→ Kết quả đảm bảo nhất quán
```

### Đặc Điểm Quan Trọng:
- ORDER BY **luôn được thực thi cuối cùng** trong câu lệnh SQL
- Kết quả được sắp xếp **sau khi** tất cả các bước khác (WHERE, GROUP BY, HAVING) đã hoàn thành
- Không có ORDER BY = kết quả **không đảm bảo** thứ tự cố định
- **Quy tắc vàng**: Nếu cần thứ tự cụ thể, **PHẢI** sử dụng ORDER BY

### Biểu Diễn Trực Quan
```
Dữ Liệu Chưa Sắp Xếp          ORDER BY           Dữ Liệu Đã Sắp Xếp
┌────┬───────┬────────┐       ┌─────────┐       ┌────┬───────┬────────┐
│ ID │ Name  │ Salary │       │         │       │ ID │ Name  │ Salary │
│ 3  │ Carol │ 8000   │─────▶│ ORDER   │──────▶│ 1  │ Alice │ 5000   │
│ 1  │ Alice │ 5000   │       │   BY    │       │ 2  │ Bob   │ 6000   │
│ 4  │ David │ 9000   │       │ Salary  │       │ 3  │ Carol │ 8000   │
│ 2  │ Bob   │ 6000   │       │   ASC   │       │ 4  │ David │ 9000   │
└────┴───────┴────────┘       └─────────┘       └────┴───────┴────────┘
     (Thứ tự ngẫu nhiên)                             (Tăng dần theo lương)
```

### Cú Pháp Cơ Bản
```sql
SELECT column1, column2, ...
FROM table_name
ORDER BY column_name [ASC|DESC];
```

**Ví dụ đơn giản:**
```sql
-- Sắp xếp nhân viên theo lương tăng dần
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary;

-- Sắp xếp nhân viên theo tên
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY last_name;
```

---

## 2. Thứ Tự Thực Thi và Hiệu Suất

### Thứ Tự Thực Thi SQL
```
1. FROM     ← Xác định bảng
2. WHERE    ← Lọc hàng
3. GROUP BY ← Nhóm dữ liệu
4. HAVING   ← Lọc nhóm
5. SELECT   ← Chọn cột
6. ORDER BY ← Sắp xếp (CUỐI CÙNG)
```

### Biểu Diễn Trực Quan
```
Dữ Liệu Thô
     │
     ▼ WHERE
Dữ Liệu Đã Lọc
     │
     ▼ GROUP BY
Dữ Liệu Đã Nhóm
     │
     ▼ HAVING
Nhóm Đã Lọc
     │
     ▼ SELECT
Cột Được Chọn
     │
     ▼ ORDER BY ← Bước cuối cùng
Kết Quả Cuối Cùng
```

### Cân Nhắc Hiệu Suất
- ORDER BY có thể **tốn kém** với dữ liệu lớn
- Sử dụng **INDEX** trên cột sắp xếp để tăng tốc
- Tránh ORDER BY không cần thiết

### Ví Dụ Tổng Hợp
```sql
SELECT                                    -- 5. Chọn cột
    department_id,
    COUNT(*) AS so_nhan_vien,
    ROUND(AVG(salary)) AS luong_tb
FROM hr.employees                         -- 1. Từ bảng
WHERE salary > 5000                       -- 2. Lọc lương > 5000
GROUP BY department_id                    -- 3. Nhóm theo phòng ban
HAVING COUNT(*) >= 3                      -- 4. Nhóm có ≥ 3 người
ORDER BY luong_tb DESC, so_nhan_vien DESC; -- 6. Sắp xếp cuối cùng
```

---

## 3. Sắp Xếp Tăng Dần và Giảm Dần

### ASC (Ascending) - Tăng Dần
- Là **mặc định** nếu không chỉ định
- Sắp xếp từ nhỏ đến lớn (A→Z, 1→9, ngày cũ→mới)

### DESC (Descending) - Giảm Dần  
- Sắp xếp từ lớn đến nhỏ (Z→A, 9→1, ngày mới→cũ)

### Biểu Diễn Trực Quan
```
ASC (Tăng Dần)                    DESC (Giảm Dần)
┌─────────────────┐              ┌─────────────────┐
│ Salary: 5000    │              │ Salary: 9000    │
│ Salary: 6000    │              │ Salary: 8000    │
│ Salary: 8000    │              │ Salary: 6000    │
│ Salary: 9000    │              │ Salary: 5000    │
└─────────────────┘              └─────────────────┘
   Từ thấp → cao                    Từ cao → thấp

Tên (ASC)                        Tên (DESC)
┌─────────────────┐              ┌─────────────────┐
│ Alice           │              │ David           │
│ Bob             │              │ Carol           │
│ Carol           │              │ Bob             │
│ David           │              │ Alice           │
└─────────────────┘              └─────────────────┘
   A → Z                           Z → A
```

### Ví Dụ
```sql
-- Lương từ thấp đến cao (ASC - mặc định)
SELECT first_name, last_name, salary
FROM hr.employees
ORDER BY salary ASC;

-- Tương đương với:
SELECT first_name, last_name, salary
FROM hr.employees
ORDER BY salary;

-- Lương từ cao xuống thấp (DESC)
SELECT first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC;
```

---

## 4. Sắp Xếp Theo Nhiều Cột

### Khái Niệm
Có thể sắp xếp theo nhiều cột với **thứ tự ưu tiên** từ trái sang phải.

### Nguyên Tắc Hoạt Động
1. **Cột đầu tiên**: Sắp xếp chính
2. **Cột thứ hai**: Sắp xếp phụ khi cột đầu có giá trị giống nhau
3. **Cột thứ ba**: Sắp xếp khi cả hai cột trước giống nhau

### Biểu Diễn Trực Quan
```
Dữ Liệu Gốc:
┌──────┬───────┬────────┐
│ Dept │ Name  │ Salary │
│  20  │ Bob   │ 6000   │
│  10  │ Alice │ 5000   │
│  20  │ Carol │ 6000   │
│  10  │ David │ 7000   │
└──────┴───────┴────────┘

ORDER BY Dept, Salary DESC:
┌──────┬───────┬────────┐
│ Dept │ Name  │ Salary │
├──────┼───────┼────────┤
│  10  │ David │ 7000   │ ← Dept 10, lương cao nhất
│  10  │ Alice │ 5000   │ ← Dept 10, lương thấp hơn
│  20  │ Bob   │ 6000   │ ← Dept 20, lương = Carol
│  20  │ Carol │ 6000   │ ← Dept 20, lương = Bob
└──────┴───────┴────────┘
   ↑        ↑
 Ưu tiên 1  Ưu tiên 2
```

### Ví Dụ
```sql
-- Sắp xếp theo phòng ban tăng dần, sau đó theo lương giảm dần
SELECT department_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id IS NOT NULL
ORDER BY department_id ASC, salary DESC;

-- Sắp xếp theo tên họ, tên đệm, tên
SELECT first_name, last_name, salary
FROM hr.employees
ORDER BY last_name, first_name, salary;
```

---

## 5. Sắp Xếp Với Giá Trị NULL

### Hành Vi Mặc Định trong Oracle
- **NULL** được coi là **giá trị lớn nhất**
- ASC: NULL xuất hiện **cuối cùng**
- DESC: NULL xuất hiện **đầu tiên**

### Điều Khiển Vị Trí NULL
- `NULLS FIRST`: Đưa NULL lên đầu
- `NULLS LAST`: Đưa NULL xuống cuối

### Biểu Diễn Trực Quan
```
Dữ Liệu Có NULL:               ORDER BY Salary ASC:
┌────────────────┐             ┌────────────────┐
│ Alice: 5000    │             │ Alice: 5000    │
│ Bob: NULL      │      ──▶    │ Carol: 6000    │
│ Carol: 6000    │             │ David: 8000    │
│ David: 8000    │             │ Bob: NULL      │ ← NULL ở cuối
└────────────────┘             └────────────────┘

ORDER BY Salary DESC:          ORDER BY Salary ASC NULLS FIRST:
┌────────────────┐             ┌────────────────┐
│ Bob: NULL      │ ← NULL đầu   │ Bob: NULL      │ ← NULL ở đầu
│ David: 8000    │             │ Alice: 5000    │
│ Carol: 6000    │             │ Carol: 6000    │
│ Alice: 5000    │             │ David: 8000    │
└────────────────┘             └────────────────┘
```

### Ví Dụ
```sql
-- Mặc định: NULL ở cuối khi ASC
SELECT first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct ASC;

-- Đưa NULL lên đầu
SELECT first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct ASC NULLS FIRST;

-- Đưa NULL xuống cuối khi DESC
SELECT first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC NULLS LAST;
```

---

## 6. Sắp Xếp Theo Vị Trí Cột

### Khái Niệm
Có thể sử dụng **số thứ tự** của cột trong SELECT thay vì tên cột.

### Ưu và Nhược Điểm
- **Ưu điểm**: Ngắn gọn, tiện lợi
- **Nhược điểm**: Khó đọc, dễ lỗi khi thay đổi SELECT

### Biểu Diễn Trực Quan
```
SELECT first_name, last_name, salary    ← Cột 1, 2, 3
FROM hr.employees
ORDER BY 3 DESC, 1 ASC;
         ↑       ↑
      Cột 3   Cột 1
    (salary) (first_name)
```

### Ví Dụ
```sql
-- Sử dụng vị trí cột
SELECT first_name, last_name, salary, department_id
FROM hr.employees
ORDER BY 4, 3 DESC;  -- department_id tăng dần, salary giảm dần

-- Tương đương với:
SELECT first_name, last_name, salary, department_id
FROM hr.employees
ORDER BY department_id, salary DESC;
```

---

## 7. Sắp Xếp Với Biểu Thức và Hàm

### Khái Niệm
ORDER BY có thể sử dụng:
- **Biểu thức** tính toán
- **Hàm** xử lý dữ liệu
- **Alias** (bí danh) từ SELECT

### Ví Dụ Với Biểu Thức
```sql
-- Sắp xếp theo tổng thu nhập (lương + hoa hồng)
SELECT 
    first_name, 
    last_name, 
    salary,
    salary * NVL(commission_pct, 0) AS commission,
    salary + salary * NVL(commission_pct, 0) AS total_income
FROM hr.employees
ORDER BY total_income DESC;  -- Sử dụng alias

-- Hoặc sử dụng biểu thức trực tiếp
SELECT first_name, last_name, salary, commission_pct
FROM hr.employees
ORDER BY salary + salary * NVL(commission_pct, 0) DESC;
```

### Ví Dụ Với Hàm
```sql
-- Sắp xếp theo độ dài tên
SELECT first_name, last_name
FROM hr.employees
ORDER BY LENGTH(first_name) DESC, first_name;

-- Sắp xếp theo năm tuyển dụng
SELECT first_name, last_name, hire_date
FROM hr.employees
ORDER BY EXTRACT(YEAR FROM hire_date) DESC, hire_date DESC;
```

---

## 7. Thứ Tự Thực Thi và Hiệu Suất

### Thứ Tự Thực Thi SQL
```
1. FROM     ← Xác định bảng
2. WHERE    ← Lọc hàng
3. GROUP BY ← Nhóm dữ liệu
4. HAVING   ← Lọc nhóm
5. SELECT   ← Chọn cột
6. ORDER BY ← Sắp xếp (CUỐI CÙNG)
```

### Biểu Diễn Trực Quan
```
Dữ Liệu Thô
     │
     ▼ WHERE
Dữ Liệu Đã Lọc
     │
     ▼ GROUP BY
Dữ Liệu Đã Nhóm
     │
     ▼ HAVING
Nhóm Đã Lọc
     │
     ▼ SELECT
Cột Được Chọn
     │
     ▼ ORDER BY ← Bước cuối cùng
Kết Quả Cuối Cùng
```

### Cân Nhắc Hiệu Suất
- ORDER BY có thể **tốn kém** với dữ liệu lớn
- Sử dụng **INDEX** trên cột sắp xếp để tăng tốc
- Tránh ORDER BY không cần thiết

### Ví Dụ Tổng Hợp
```sql
SELECT                                    -- 5. Chọn cột
    department_id,
    COUNT(*) AS so_nhan_vien,
    ROUND(AVG(salary)) AS luong_tb
FROM hr.employees                         -- 1. Từ bảng
WHERE salary > 5000                       -- 2. Lọc lương > 5000
GROUP BY department_id                    -- 3. Nhóm theo phòng ban
HAVING COUNT(*) >= 3                      -- 4. Nhóm có ≥ 3 người
ORDER BY luong_tb DESC, so_nhan_vien DESC; -- 6. Sắp xếp cuối cùng
```

---

## 8. Lỗi Thường Gặp

### 1. Sử Dụng Cột Không Có Trong SELECT
```sql
-- ✗ SAI: (Một số DBMS không cho phép)
SELECT first_name, salary
FROM hr.employees
ORDER BY last_name;  -- last_name không có trong SELECT

-- ✓ ĐÚNG:
SELECT first_name, last_name, salary
FROM hr.employees
ORDER BY last_name;
```

### 2. Sử Dụng Alias Chưa Được Định Nghĩa
```sql
-- ✗ SAI:
SELECT first_name, salary
FROM hr.employees
ORDER BY luong_cao;  -- 'luong_cao' không tồn tại

-- ✓ ĐÚNG:
SELECT first_name, salary AS luong_cao
FROM hr.employees
ORDER BY luong_cao;
```

### 3. Vị Trí Cột Sai
```sql
-- ✗ SAI:
SELECT first_name, salary
FROM hr.employees
ORDER BY 3;  -- Chỉ có 2 cột, không có cột thứ 3

-- ✓ ĐÚNG:
SELECT first_name, salary
FROM hr.employees
ORDER BY 2;  -- Cột thứ 2 (salary)
```

### 4. Quên Xử Lý NULL
```sql
-- Có thể không mong muốn:
SELECT first_name, commission_pct
FROM hr.employees
ORDER BY commission_pct;  -- NULL sẽ ở cuối

-- Rõ ràng hơn:
SELECT first_name, commission_pct
FROM hr.employees
ORDER BY commission_pct NULLS FIRST;
```

---

## Tóm Tắt Quan Trọng

- **ORDER BY**: Sắp xếp kết quả truy vấn
- **ASC**: Tăng dần (mặc định)
- **DESC**: Giảm dần  
- **Nhiều cột**: Ưu tiên từ trái sang phải
- **NULL**: Mặc định ở cuối (ASC) hoặc đầu (DESC)
- **Thực thi cuối**: ORDER BY luôn thực hiện cuối cùng
- **Hiệu suất**: Cân nhắc sử dụng INDEX cho cột sắp xếp