# Hàm Tổng Hợp và Nhóm Dữ Liệu (GROUP BY, HAVING)

## Mục Lục
1. [Khái Niệm Hàm Tổng Hợp](#1-khái-niệm-hàm-tổng-hợp)
2. [Mệnh Đề GROUP BY](#2-mệnh-đề-group-by)
- [So Sánh: Hàm Tổng Hợp Có và Không có GROUP BY](#so-sánh-hàm-tổng-hợp-có-và-không-có-group-by)
- [LƯU Ý QUAN TRỌNG VỀ CỘT TRONG SELECT khi GROUP BY](#️-lưu-ý-quan-trọng-về-cột-trong-select-khi-group-by)
3. [Mệnh Đề HAVING](#3-mệnh-đề-having)
4. [So Sánh WHERE và HAVING](#4-so-sánh-where-và-having)
5. [Thứ Tự Thực Thi Câu Lệnh SQL](#5-thứ-tự-thực-thi-câu-lệnh-sql)
6. [Ví Dụ Tổng Hợp](#6-ví-dụ-tổng-hợp)
7. [Lỗi Thường Gặp](#7-lỗi-thường-gặp)

---

## 1. Khái Niệm Hàm Tổng Hợp

**Hàm tổng hợp (Aggregate Functions)** là những hàm thực hiện phép tính trên một nhóm hàng và trả về một giá trị duy nhất.

### Các Hàm Tổng Hợp Phổ Biến:
- `COUNT()`: Đếm số lượng hàng
- `SUM()`: Tính tổng các giá trị
- `AVG()`: Tính giá trị trung bình
- `MIN()`: Tìm giá trị nhỏ nhất
- `MAX()`: Tìm giá trị lớn nhất
- Các Hàm Tổng Hợp khác: [Tham khảo thêm](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Aggregate-Functions.html#GUID-62BE676B-AF18-4E63-BD14-25206FEA0848)

### Biểu Diễn Trực Quan
```
Nhiều Hàng (Input)          Hàm Tổng Hợp          Một Giá Trị (Output)
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Salary: 5000    │       │                 │       │                 │
│ Salary: 7000    │─────▶│   AVG(salary)   │──────▶│      6000       │
│ Salary: 8000    │       │                 │       │                 │
│ Salary: 4000    │       └─────────────────┘       └─────────────────┘
└─────────────────┘
```

**Ví dụ đơn giản:**
```sql
-- Tính lương trung bình của tất cả nhân viên
SELECT AVG(salary) AS luong_trung_binh
FROM hr.employees;

-- Đếm tổng số nhân viên
SELECT COUNT(*) AS tong_so_nhan_vien
FROM hr.employees;
```

---

## 2. Mệnh Đề GROUP BY

### Khái Niệm
**GROUP BY** chia các hàng trong bảng thành các nhóm dựa trên giá trị của một hoặc nhiều cột. Hàm tổng hợp sẽ được áp dụng cho từng nhóm riêng biệt.

### Cách Hoạt Động: "Chia - Áp Dụng - Kết Hợp"

1. **CHIA (Split)**: Oracle chia dữ liệu thành các nhóm dựa trên giá trị cột GROUP BY
2. **ÁP DỤNG (Apply)**: Áp dụng hàm tổng hợp cho từng nhóm
3. **KẾT HỢP (Combine)**: Kết hợp kết quả từ tất cả các nhóm

### Biểu Diễn Trực Quan
```
Dữ Liệu Gốc:
┌────┬───────┬────────┬──────┐
│ ID │ Name  │ Salary │ Dept │
│ 1  │ Alice │ 5000   │  10  │
│ 2  │ Bob   │ 8000   │  20  │
│ 3  │ Carol │ 6000   │  10  │
│ 4  │ David │ 9000   │  20  │
└────┴───────┴────────┴──────┘

GROUP BY Dept → Chia thành 2 nhóm:

Nhóm Dept 10:           Nhóm Dept 20:
┌───────┬────────┐      ┌───────┬────────┐
│ Alice │ 5000   │      │ Bob   │ 8000   │
│ Carol │ 6000   │      │ David │ 9000   │
└───────┴────────┘      └───────┴────────┘
AVG = 5500              AVG = 8500

Kết Quả Cuối Cùng:
┌──────┬────────────┐
│ Dept │ AVG_SALARY │
├──────┼────────────┤
│  10  │    5500    │
│  20  │    8500    │
└──────┴────────────┘
```

### Quy Tắc Quan Trọng
**Mọi cột trong SELECT không phải hàm tổng hợp đều PHẢI có trong GROUP BY**

```sql
-- ✓ ĐÚNG:
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id;

-- ✗ SAI: last_name không có trong GROUP BY
SELECT department_id, last_name, COUNT(*)
FROM hr.employees
GROUP BY department_id;
-- Lỗi: ORA-00979: not a GROUP BY expression
```

### Ví Dụ Thực Tế
```sql
-- Đếm số nhân viên theo từng phòng ban
SELECT 
    department_id,
    COUNT(*) AS so_nhan_vien,
    ROUND(AVG(salary)) AS luong_trung_binh
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
```

---


### So Sánh: Hàm Tổng Hợp Có và Không có GROUP BY

#### **KHÔNG có GROUP BY** → Tính toán trên toàn bộ bảng
```sql
-- Tính lương trung bình của TẤT CẢ nhân viên
SELECT AVG(salary) AS luong_trung_binh_toan_cty
FROM hr.employees;
```

**Cách hoạt động:**
```
┌─────────────────────────────────────────────┐
│            TOÀN BỘ BẢNG (1 NHÓM)            │
├─────────────────────────────────────────────┤
│ Emp1: Dept=10, Salary=5000                  │
│ Emp2: Dept=10, Salary=6000                  │    ───▶ AVG(salary) = 7000
│ Emp3: Dept=20, Salary=8000                  │         (1 GIÁ TRỊ DUY NHẤT)
│ Emp4: Dept=20, Salary=9000                  │
│ Emp5: Dept=30, Salary=7000                  │
└─────────────────────────────────────────────┘

KẾT QUẢ:
┌─────────────────────┐
│ LUONG_TB_TOAN_CTY   │
├─────────────────────┤
│        7000         │  ← 1 hàng, 1 giá trị
└─────────────────────┘
```

#### **CÓ GROUP BY** → Tính toán theo từng nhóm
```sql
-- Tính lương trung bình THEO TỪNG PHÒNG BAN
SELECT 
    department_id,
    AVG(salary) AS luong_trung_binh_phong_ban
FROM hr.employees
GROUP BY department_id;
```

**Cách hoạt động:**
```
CHIA THEO DEPARTMENT_ID:

┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐
│    NHÓM DEPT 10   │  │    NHÓM DEPT 20   │  │    NHÓM DEPT 30   │
├───────────────────┤  ├───────────────────┤  ├───────────────────┤
│ Emp1: Salary=5000 │  │ Emp3: Salary=8000 │  │ Emp5: Salary=7000 │
│ Emp2: Salary=6000 │  │ Emp4: Salary=9000 │  │                   │
└───────────────────┘  └───────────────────┘  └───────────────────┘
       │                       │                       │
       ▼                       ▼                       ▼
   AVG = 5500              AVG = 8500              AVG = 7000

KẾT QUẢ:
┌─────────────────┬────────────────────────┐
│ DEPARTMENT_ID   │ LUONG_TB_PHONG_BAN     │
├─────────────────┼────────────────────────┤
│       10        │         5500           │  ← Mỗi nhóm 1 hàng
│       20        │         8500           │
│       30        │         7000           │
└─────────────────┴────────────────────────┘
                    3 hàng, mỗi nhóm 1 giá trị
```

### Bảng So Sánh Chi Tiết

| **Khía Cạnh** | **KHÔNG có GROUP BY** | **CÓ GROUP BY** |
|----------------|------------------------|-----------------|
| **Dữ liệu được xử lý** | Toàn bộ bảng như 1 nhóm | Chia thành nhiều nhóm theo cột GROUP BY |
| **Số nhóm** | 1 nhóm duy nhất | Nhiều nhóm (= số giá trị khác nhau trong cột GROUP BY) |
| **Hàm tổng hợp áp dụng** | 1 lần cho toàn bộ bảng | 1 lần cho mỗi nhóm |
| **Số hàng kết quả** | 1 hàng | Nhiều hàng (= số nhóm) |
| **Cột có thể SELECT** | Chỉ hàm tổng hợp + hằng số | Cột GROUP BY + hàm tổng hợp |
| **Câu hỏi trả lời** | "Tổng thể như thế nào?" | "Từng nhóm như thế nào?" |

### ⚠️ LƯU Ý QUAN TRỌNG VỀ CỘT TRONG SELECT khi GROUP BY

#### **KHÔNG có GROUP BY**: Chỉ được SELECT hàm tổng hợp hoặc hằng số
```sql
-- ✗ SAI: Không thể SELECT cột thường khi không có GROUP BY
SELECT first_name, AVG(salary)
FROM hr.employees;
-- Lỗi: ORA-00937: not a single-group group function

-- ✓ ĐÚNG: Chỉ SELECT hàm tổng hợp
SELECT AVG(salary) AS luong_trung_binh
FROM hr.employees;
```

#### **CÓ GROUP BY**: Cột thường phải có trong GROUP BY
```sql
-- ✗ SAI: department_name không có trong GROUP BY
SELECT department_id, department_name, COUNT(*)
FROM hr.employees
GROUP BY department_id;
-- Lỗi: ORA-00979: not a GROUP BY expression

-- ✓ ĐÚNG: Tất cả cột thường đều có trong GROUP BY
SELECT department_id, COUNT(*) AS so_nhan_vien
FROM hr.employees
GROUP BY department_id;
```

### Ví Dụ Thực Tế So Sánh

Giả sử bảng `employees` có dữ liệu:
```
┌─────────────┬─────────────────┬────────┐
│ EMPLOYEE_ID │ DEPARTMENT_ID   │ SALARY │
├─────────────┼─────────────────┼────────┤
│     100     │       10        │  5000  │
│     101     │       10        │  6000  │
│     102     │       20        │  8000  │
│     103     │       20        │  9000  │
│     104     │       30        │  7000  │
└─────────────┴─────────────────┴────────┘
```

**Câu hỏi 1:** "Lương trung bình của toàn công ty là bao nhiêu?"
```sql
SELECT AVG(salary) AS luong_tb_toan_cty
FROM hr.employees;

-- Kết quả: 7000 (chỉ 1 giá trị)
```

**Câu hỏi 2:** "Lương trung bình của từng phòng ban là bao nhiêu?"
```sql
SELECT 
    department_id,
    AVG(salary) AS luong_tb_phong_ban
FROM hr.employees
GROUP BY department_id;

-- Kết quả: 
-- Dept 10: 5500
-- Dept 20: 8500  
-- Dept 30: 7000
```

**Câu hỏi 3:** "Có bao nhiêu nhân viên trong toàn công ty?"
```sql
SELECT COUNT(*) AS tong_nhan_vien
FROM hr.employees;

-- Kết quả: 5 (chỉ 1 giá trị)
```

**Câu hỏi 4:** "Mỗi phòng ban có bao nhiêu nhân viên?"
```sql
SELECT 
    department_id,
    COUNT(*) AS so_nhan_vien
FROM hr.employees
GROUP BY department_id;

-- Kết quả:
-- Dept 10: 2 người
-- Dept 20: 2 người
-- Dept 30: 1 người
```

## 3. Mệnh Đề HAVING

### Khái Niệm
**HAVING** được sử dụng để lọc các nhóm đã được tạo bởi GROUP BY. Nó giống như WHERE nhưng áp dụng cho kết quả của hàm tổng hợp.

### Tại Sao Cần HAVING?
- WHERE lọc từng hàng riêng lẻ **TRƯỚC KHI** nhóm
- HAVING lọc các nhóm **SAU KHI** đã được tạo bởi GROUP BY

### Biểu Diễn Trực Quan
```
Dữ Liệu Gốc
     │
     ▼
┌──────────┐
│  WHERE   │ ← Lọc từng hàng (ví dụ: salary > 3000)
└──────────┘
     │
     ▼
Hàng đã lọc
     │
     ▼
┌──────────┐
│ GROUP BY │ ← Nhóm các hàng
└──────────┘
     │
     ▼
Các nhóm
     │
     ▼
┌──────────┐
│  HAVING  │ ← Lọc các nhóm (ví dụ: COUNT(*) > 5)
└──────────┘
     │
     ▼
Kết quả cuối cùng
```

### Ví Dụ
```sql
-- Tìm các phòng ban có hơn 5 nhân viên
SELECT 
    department_id,
    COUNT(*) AS so_nhan_vien
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY so_nhan_vien DESC;

-- Tìm các chức danh có lương trung bình trên 8000
SELECT 
    job_id,
    COUNT(*) AS so_nhan_vien,
    ROUND(AVG(salary)) AS luong_trung_binh
FROM hr.employees
GROUP BY job_id
HAVING AVG(salary) > 8000
ORDER BY luong_trung_binh DESC;
```

---

## 4. So Sánh WHERE và HAVING

| Đặc Điểm | WHERE | HAVING |
|----------|-------|--------|
| **Mục đích** | Lọc các hàng riêng lẻ | Lọc các nhóm |
| **Thời điểm** | Trước GROUP BY | Sau GROUP BY |
| **Sử dụng với** | Cột bảng thông thường | Hàm tổng hợp |
| **Ví dụ** | `WHERE salary > 5000` | `HAVING COUNT(*) > 3` |

### Ví Dụ Minh Họa
```sql
-- Kết hợp WHERE và HAVING
SELECT 
    department_id,
    COUNT(*) AS so_nhan_vien,
    ROUND(AVG(salary)) AS luong_trung_binh
FROM hr.employees
WHERE salary > 3000              -- WHERE: lọc nhân viên có lương > 3000
GROUP BY department_id
HAVING COUNT(*) >= 3             -- HAVING: chỉ lấy phòng ban có ≥ 3 nhân viên
    AND AVG(salary) > 6000       -- và lương trung bình > 6000
ORDER BY luong_trung_binh DESC;
```

---

## 5. Thứ Tự Thực Thi Câu Lệnh SQL

Oracle thực thi các mệnh đề theo thứ tự logic sau:

1. **FROM** - Xác định bảng nguồn
2. **WHERE** - Lọc các hàng riêng lẻ
3. **GROUP BY** - Nhóm các hàng đã lọc
4. **HAVING** - Lọc các nhóm
5. **SELECT** - Chọn cột và tính toán
6. **ORDER BY** - Sắp xếp kết quả

### Ví Dụ Minh Họa Thứ Tự
```sql
SELECT                           -- 5. Chọn cột và tính toán
    department_id,
    COUNT(*) AS so_nhan_vien,
    AVG(salary) AS luong_tb
FROM hr.employees                -- 1. Từ bảng employees
WHERE hire_date > '2000-01-01'   -- 2. Lọc nhân viên tuyển sau 2000
GROUP BY department_id           -- 3. Nhóm theo phòng ban
HAVING COUNT(*) > 2              -- 4. Chỉ lấy phòng ban có > 2 người
ORDER BY luong_tb DESC;          -- 6. Sắp xếp theo lương giảm dần
```

---

## 6. Ví Dụ Tổng Hợp

### Bài Toán Thực Tế
**Yêu cầu:** Tìm các phòng ban có ít nhất 3 nhân viên được tuyển sau năm 2005, và có mức lương trung bình trên 7000.

```sql
SELECT 
    d.department_name,           -- Tên phòng ban
    COUNT(e.employee_id) AS so_nhan_vien,
    ROUND(AVG(e.salary)) AS luong_trung_binh,
    MIN(e.hire_date) AS ngay_tuyen_som_nhat,
    MAX(e.hire_date) AS ngay_tuyen_muon_nhat
FROM hr.departments d
JOIN hr.employees e ON d.department_id = e.department_id
WHERE e.hire_date > DATE '2005-12-31'    -- Điều kiện cho từng hàng
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 3         -- Điều kiện cho nhóm
    AND AVG(e.salary) > 7000
ORDER BY luong_trung_binh DESC;
```

### Giải Thích Từng Bước:
1. **FROM + JOIN**: Kết hợp bảng departments và employees
2. **WHERE**: Chỉ lấy nhân viên tuyển sau 2005
3. **GROUP BY**: Nhóm theo phòng ban
4. **HAVING**: Chỉ lấy nhóm có ≥3 người và lương TB >7000
5. **SELECT**: Tính toán các thống kê cho mỗi nhóm
6. **ORDER BY**: Sắp xếp theo lương trung bình

---

## 7. Lỗi Thường Gặp

### 1. Lỗi ORA-00979: not a GROUP BY expression
```sql
-- ✗ SAI:
SELECT department_id, employee_id, COUNT(*)
FROM hr.employees
GROUP BY department_id;
-- employee_id phải có trong GROUP BY

-- ✓ ĐÚNG:
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id;
```

### 2. Dùng WHERE thay vì HAVING cho hàm tổng hợp
```sql
-- ✗ SAI:
SELECT department_id, COUNT(*)
FROM hr.employees
WHERE COUNT(*) > 5    -- Không thể dùng WHERE với hàm tổng hợp
GROUP BY department_id;

-- ✓ ĐÚNG:
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 5;
```

### 3. Nhầm lẫn thứ tự thực thi
```sql
-- ✗ SAI: Không thể dùng alias trong WHERE/HAVING
SELECT department_id, COUNT(*) AS so_luong
FROM hr.employees
GROUP BY department_id
HAVING so_luong > 5;  -- 'so_luong' chưa được định nghĩa

-- ✓ ĐÚNG:
SELECT department_id, COUNT(*) AS so_luong
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 5;
```

---

## Tóm Tắt Quan Trọng

- **Hàm tổng hợp**: Nhiều hàng → một giá trị
- **GROUP BY**: Chia dữ liệu thành các nhóm để áp dụng hàm tổng hợp
- **HAVING**: Lọc các nhóm (dùng với hàm tổng hợp)
- **WHERE**: Lọc từng hàng riêng lẻ (trước khi nhóm)
- **Quy tắc vàng**: Cột không phải hàm tổng hợp phải có trong GROUP BY