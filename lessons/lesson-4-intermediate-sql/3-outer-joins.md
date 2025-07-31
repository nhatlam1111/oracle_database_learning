# OUTER JOINs - Kết Nối Bao Gồm Dữ Liệu Không Khớp

## Mục Lục
1. [Khái Niệm OUTER JOIN](#1-khái-niệm-outer-join)
2. [Cách Hoạt Động của OUTER JOIN](#2-cách-hoạt-động-của-outer-join)
3. [LEFT OUTER JOIN](#3-left-outer-join)
4. [RIGHT OUTER JOIN](#4-right-outer-join)
5. [FULL OUTER JOIN](#5-full-outer-join)
6. [So Sánh Cú Pháp Oracle (+) và ANSI](#6-so-sánh-cú-pháp-oracle--và-ansi)
7. [Xử Lý Giá Trị NULL](#7-xử-lý-giá-trị-null)
8. [Lỗi Thường Gặp](#8-lỗi-thường-gặp)

---

## 1. Khái Niệm OUTER JOIN

### Định Nghĩa
**OUTER JOIN** kết hợp dữ liệu từ hai bảng nhưng **GIỮ LẠI** các hàng không khớp từ một hoặc cả hai bảng. Khác với INNER JOIN chỉ lấy dữ liệu khớp, OUTER JOIN bao gồm cả dữ liệu "mồ côi".

### Tại Sao Cần OUTER JOIN?

```
TÌNH HUỐNG THỰC TẾ:
├─ Tìm khách hàng CHƯA từng mua hàng
├─ Liệt kê TẤT CẢ sản phẩm (kể cả chưa bán)  
├─ Phòng ban nào KHÔNG có nhân viên
└─ Nhân viên nào CHƯA được phân công
```

### So Sánh với INNER JOIN

```
INNER JOIN: Chỉ lấy KHỚP          OUTER JOIN: Lấy KHỚP + KHÔNG KHỚP
┌─────────────────┐               ┌─────────────────┐
│ A ∩ B           │               │ A ∪ B           │
│ (Giao nhau)     │               │ (Hợp tập)       │
└─────────────────┘               └─────────────────┘
```

---

## 2. Cách Hoạt Động của OUTER JOIN

### Dữ Liệu Mẫu
Sử dụng trong tất cả ví dụ:

```
Bảng EMPLOYEES:                 Bảng DEPARTMENTS:
┌─────┬─────┬─────────┐         ┌─────────┬─────────────┐
│ EID │NAME │DEPT_ID  │         │DEPT_ID  │DEPT_NAME    │
├─────┼─────┼─────────┤         ├─────────┼─────────────┤
│ 100 │John │   10    │         │   10    │Sales        │
│ 101 │Jane │   20    │         │   20    │Marketing    │  
│ 102 │Bob  │  NULL   │         │   30    │HR           │
│ 103 │Alice│   99    │         │   40    │Finance      │
└─────┴─────┴─────────┘         └─────────┴─────────────┘

PHÂN TÍCH:
✓ John  (EID=100, DEPT=10) → Khớp với Sales
✓ Jane  (EID=101, DEPT=20) → Khớp với Marketing  
✗ Bob   (EID=102, DEPT=NULL) → Không khớp
✗ Alice (EID=103, DEPT=99) → Không khớp (dept 99 không tồn tại)
✗ HR    (DEPT=30) → Không có nhân viên
✗ Finance (DEPT=40) → Không có nhân viên
```

### Nguyên Lý Hoạt Động

```
Bước 1: INNER JOIN (tìm khớp)
┌─────┬─────┬─────────────┐
│ EID │NAME │DEPT_NAME    │
├─────┼─────┼─────────────┤
│ 100 │John │Sales        │
│ 101 │Jane │Marketing    │
└─────┴─────┴─────────────┘

Bước 2: THÊM dữ liệu không khớp (tùy loại OUTER JOIN)
- LEFT: + Bob, Alice (nhân viên không có dept)
- RIGHT: + HR, Finance (dept không có emp)  
- FULL: + Cả hai
```

---

## 3. LEFT OUTER JOIN

### Khái Niệm
**LEFT OUTER JOIN** giữ **TẤT CẢ** hàng từ bảng TRÁI + các hàng khớp từ bảng PHẢI.

### Cú Pháp
```sql
SELECT cột1, cột2, ...
FROM bảng_trái
LEFT OUTER JOIN bảng_phải ON điều_kiện;

-- Hoặc ngắn gọn
SELECT cột1, cột2, ...  
FROM bảng_trái
LEFT JOIN bảng_phải ON điều_kiện;
```

### Biểu Diễn Trực Quan

```sql
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

**Cách hoạt động:**
```
BẢNG TRÁI (EMPLOYEES) ←── GIỮ TẤT CẢ
┌─────┬─────┬─────────┐
│ 100 │John │   10    │ ──┐
│ 101 │Jane │   20    │ ──┼─→ Tìm khớp trong DEPARTMENTS
│ 102 │Bob  │  NULL   │ ──┼─→ NULL = không tìm được
│ 103 │Alice│   99    │ ──┘   99 = không tồn tại
└─────┴─────┴─────────┘

KẾT QUẢ LEFT JOIN:
┌─────┬─────────────┐
│NAME │DEPT_NAME    │
├─────┼─────────────┤
│John │Sales        │ ← Khớp
│Jane │Marketing    │ ← Khớp  
│Bob  │NULL         │ ← Giữ lại (không khớp)
│Alice│NULL         │ ← Giữ lại (không khớp)
└─────┴─────────────┘

🎯 Ý nghĩa: "Cho tôi TẤT CẢ nhân viên, có thông tin phòng ban thì hiển thị"
```

### Ứng Dụng Thực Tế

```sql
-- Tìm nhân viên CHƯA có phòng ban
SELECT e.name
FROM employees e  
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Liệt kê TẤT CẢ khách hàng với tổng đơn hàng (kể cả khách chưa mua)
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;
```

---

## 4. RIGHT OUTER JOIN

### Khái Niệm
**RIGHT OUTER JOIN** giữ **TẤT CẢ** hàng từ bảng PHẢI + các hàng khớp từ bảng TRÁI.

### Cú Pháp
```sql
SELECT cột1, cột2, ...
FROM bảng_trái
RIGHT OUTER JOIN bảng_phải ON điều_kiện;

-- Hoặc ngắn gọn
SELECT cột1, cột2, ...
FROM bảng_trái  
RIGHT JOIN bảng_phải ON điều_kiện;
```

### Biểu Diễn Trực Quan

```sql
SELECT e.name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

**Cách hoạt động:**
```
                    BẢNG PHẢI (DEPARTMENTS) ←── GIỮ TẤT CẢ
                    ┌─────────┬─────────────┐
              ┌──── │   10    │Sales        │
              │     │   20    │Marketing    │  
Tìm emp có    │     │   30    │HR           │ ← Không có emp
dept tương    │     │   40    │Finance      │ ← Không có emp
ứng           └──── └─────────┴─────────────┘

KẾT QUẢ RIGHT JOIN:
┌─────┬─────────────┐
│NAME │DEPT_NAME    │
├─────┼─────────────┤
│John │Sales        │ ← Khớp
│Jane │Marketing    │ ← Khớp
│NULL │HR           │ ← Giữ lại (không có emp)
│NULL │Finance      │ ← Giữ lại (không có emp)  
└─────┴─────────────┘

🎯 Ý nghĩa: "Cho tôi TẤT CẢ phòng ban, có nhân viên thì hiển thị"
```

### Ứng Dụng Thực Tế

```sql
-- Tìm phòng ban TRỐNG (không có nhân viên)
SELECT d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id  
WHERE e.emp_id IS NULL;

-- Liệt kê TẤT CẢ sản phẩm với doanh số (kể cả sản phẩm chưa bán)
SELECT 
    p.product_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM sales s
RIGHT JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name;
```

---

## 5. FULL OUTER JOIN

### Khái Niệm
**FULL OUTER JOIN** giữ **TẤT CẢ** hàng từ **CẢ HAI** bảng, bất kể có khớp hay không.

### Cú Pháp
```sql
SELECT cột1, cột2, ...
FROM bảng1
FULL OUTER JOIN bảng2 ON điều_kiện;

-- Hoặc ngắn gọn
SELECT cột1, cột2, ...
FROM bảng1
FULL JOIN bảng2 ON điều_kiện;
```

### Biểu Diễn Trực Quan

```sql
SELECT e.name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;
```

**Cách hoạt động:**
```
BẢNG TRÁI ←── GIỮ TẤT CẢ     BẢNG PHẢI ←── GIỮ TẤT CẢ
┌─────┬─────────┐            ┌─────────┬─────────────┐
│ 100 │   10    │ ◄────────► │   10    │Sales        │
│ 101 │   20    │ ◄────────► │   20    │Marketing    │
│ 102 │  NULL   │            │   30    │HR           │
│ 103 │   99    │            │   40    │Finance      │
└─────┴─────────┘            └─────────┴─────────────┘

KẾT QUẢ FULL OUTER JOIN:
┌─────┬─────────────┐
│NAME │DEPT_NAME    │
├─────┼─────────────┤
│John │Sales        │ ← Khớp
│Jane │Marketing    │ ← Khớp
│Bob  │NULL         │ ← Chỉ trong EMPLOYEES
│Alice│NULL         │ ← Chỉ trong EMPLOYEES  
│NULL │HR           │ ← Chỉ trong DEPARTMENTS
│NULL │Finance      │ ← Chỉ trong DEPARTMENTS
└─────┴─────────────┘

🎯 Ý nghĩa: "Cho tôi TẤT CẢ nhân viên VÀ TẤT CẢ phòng ban"
```

### Công Thức FULL OUTER JOIN
```
FULL OUTER JOIN = LEFT JOIN ∪ RIGHT JOIN
                = LEFT ONLY + MATCHES + RIGHT ONLY
```

### Ứng Dụng Thực Tế

```sql
-- Phân tích toàn diện: ai không có gì?
SELECT 
    COALESCE(e.name, 'Không có NV') AS employee,
    COALESCE(d.dept_name, 'Không có phòng ban') AS department,
    CASE 
        WHEN e.emp_id IS NULL THEN 'Phòng ban trống'
        WHEN d.dept_id IS NULL THEN 'NV chưa phân công'  
        ELSE 'Đã khớp'
    END AS status
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;
```

---

## 6. So Sánh Cú Pháp Oracle (+) và ANSI

### Cú Pháp Oracle Truyền Thống (+)

Oracle có cú pháp riêng sử dụng dấu `(+)` cho OUTER JOIN:

```sql
-- LEFT OUTER JOIN (ANSI)
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Tương đương với Oracle (+)
SELECT e.name, d.dept_name  
FROM employees e, departments d
WHERE e.dept_id = d.dept_id(+);
```

### Quy Tắc Dấu (+)

**Nguyên tắc:** Đặt `(+)` ở phía **CÓ THỂ NULL** (phía tùy chọn)

```sql
-- LEFT JOIN: Giữ tất cả LEFT, phải có thể NULL
WHERE left.col = right.col(+)
       ↑              ↑
    Giữ tất cả    Có thể NULL

-- RIGHT JOIN: Giữ tất cả RIGHT, trái có thể NULL  
WHERE left.col(+) = right.col
       ↑              ↑
   Có thể NULL    Giữ tất cả
```

### Bảng So Sánh

| **Khía Cạnh** | **Cú Pháp (+)** | **Cú Pháp ANSI** |
|----------------|------------------|-------------------|
| **Độ rõ ràng** | ❌ Khó hiểu | ✅ Rất rõ ràng |
| **FULL OUTER JOIN** | ❌ Không hỗ trợ | ✅ Hỗ trợ |
| **Tương thích** | ❌ Chỉ Oracle | ✅ Tất cả DBMS |
| **Phức tạp** | ❌ Khó với nhiều bảng | ✅ Dễ mở rộng |
| **Khuyến nghị** | 👎 Tránh sử dụng | 👍 Nên dùng |

### **Khuyến Nghị: Sử Dụng Cú Pháp ANSI**

---

## 7. Xử Lý Giá Trị NULL

### Hiểu Về NULL trong OUTER JOIN

```
OUTER JOIN tạo ra NULL khi:
├─ LEFT JOIN: Bảng phải không có dữ liệu khớp
├─ RIGHT JOIN: Bảng trái không có dữ liệu khớp
└─ FULL JOIN: Một trong hai bảng không có dữ liệu khớp
```

### Các Hàm Xử Lý NULL

```sql
-- NVL: Thay thế NULL bằng giá trị khác
SELECT 
    e.name,
    NVL(d.dept_name, 'Chưa phân công') AS department
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- COALESCE: Lấy giá trị không NULL đầu tiên
SELECT 
    COALESCE(e.name, 'Không có NV') AS employee_name,
    COALESCE(d.dept_name, 'Không có phòng ban') AS dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

-- CASE: Logic phức tạp hơn
SELECT 
    e.name,
    CASE 
        WHEN d.dept_name IS NULL AND e.dept_id IS NULL THEN 'Chưa có phòng ban'
        WHEN d.dept_name IS NULL AND e.dept_id IS NOT NULL THEN 'Phòng ban không tồn tại'
        ELSE d.dept_name
    END AS department_status
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

### Mẹo Tìm Dữ Liệu Không Khớp

```sql
-- Tìm bản ghi CHỈ trong bảng trái (LEFT ONLY)
SELECT e.name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Tìm bản ghi CHỈ trong bảng phải (RIGHT ONLY)  
SELECT d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
```

---

## 8. Lỗi Thường Gặp

### Lỗi 1: Nhầm Lẫn LEFT và RIGHT

```sql
-- ❌ SAI: Muốn tất cả phòng ban nhưng dùng LEFT JOIN
SELECT d.dept_name, e.name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Kết quả: Tất cả nhân viên (không phải tất cả phòng ban)

-- ✅ ĐÚNG: Tất cả phòng ban
SELECT d.dept_name, e.name  
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;
-- HOẶC
SELECT d.dept_name, e.name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

### Lỗi 2: WHERE Phá Vỡ OUTER JOIN

```sql
-- ❌ SAI: WHERE làm mất ý nghĩa OUTER JOIN
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name IS NOT NULL;  -- Loại bỏ NULL = thành INNER JOIN

-- ✅ ĐÚNG: Dùng INNER JOIN nếu không muốn NULL
SELECT e.name, d.dept_name
FROM employees e  
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

### Lỗi 3: Xử Lý NULL Không Đúng

```sql
-- ❌ SAI: So sánh trực tiếp với NULL
SELECT * FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = NULL;  -- Luôn trả về 0 hàng

-- ✅ ĐÚNG: Sử dụng IS NULL
SELECT * FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id  
WHERE d.dept_name IS NULL;
```

### Lỗi 4: Trộn Cú Pháp

```sql
-- ❌ SAI: Trộn ANSI và Oracle (+)
SELECT e.name, d.dept_name, l.location
FROM employees e, departments d
LEFT JOIN locations l ON d.location_id = l.location_id
WHERE e.dept_id = d.dept_id(+);

-- ✅ ĐÚNG: Nhất quán cú pháp ANSI
SELECT e.name, d.dept_name, l.location
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN locations l ON d.location_id = l.location_id;
```

---

## Tóm Tắt Quan Trọng

### So Sánh Các Loại JOIN

| **Loại JOIN** | **Ý Nghĩa** | **Khi Nào Dùng** |
|---------------|-------------|-------------------|
| **INNER** | Chỉ khớp | Cần dữ liệu chính xác |
| **LEFT OUTER** | Tất cả bên trái + khớp | Tất cả A, có B thì hiển thị |
| **RIGHT OUTER** | Khớp + tất cả bên phải | Tất cả B, có A thì hiển thị |  
| **FULL OUTER** | Tất cả từ cả hai | Tất cả A và tất cả B |

### Biểu Đồ Venn
```
INNER:    LEFT:     RIGHT:    FULL:
  A∩B      A∪(A∩B)   (A∩B)∪B   A∪B
┌───┐    ┌█████┐    ┌───┐    ┌█████┐
│ ● │    │██●██│    │ ●█│    │██●██│  
└───┘    └───█┘    └███┘    └█████┘
```

### Thực Hành Tốt Nhất
1. **Sử dụng cú pháp ANSI** thay vì Oracle (+)
2. **Xử lý NULL** với NVL, COALESCE, CASE
3. **Đặt tên bảng rõ ràng** (LEFT/RIGHT có ý nghĩa)
4. **Kiểm tra kết quả** để đảm bảo logic đúng
5. **Tránh WHERE** phá vỡ OUTER JOIN

### Câu Hỏi Tự Kiểm Tra
- Khi nào dùng LEFT vs RIGHT JOIN?
- FULL OUTER JOIN khác gì với UNION?
- Tại sao nên tránh cú pháp (+)?
- Làm sao tìm dữ liệu chỉ ở một bảng?

**Bảng EMPLOYEES (E)**
```
employee_id | first_name | department_id
------------|------------|-------------
    100     |    John    |     10
    101     |    Jane    |     20
    102     |    Bob     |   NULL
    103     |   Alice    |     30
```

**Bảng DEPARTMENTS (D)**
```
department_id | department_name
--------------|----------------
      10      |       IT
      20      |    Sales
      40      |      HR
      50      |   Finance
```

**Lưu ý:** 
- Nhân viên Bob (102) không có phòng ban (NULL)
- Nhân viên Alice (103) thuộc phòng ban 30 (không tồn tại)
- Phòng ban HR (40) và Finance (50) không có nhân viên

## Các Loại Outer Joins

### 1. LEFT OUTER JOIN (hoặc LEFT JOIN)

Trả về TẤT CẢ các hàng từ bảng bên trái và các hàng khớp từ bảng bên phải. Nếu không có khớp, giá trị NULL được trả về cho các cột bảng bên phải.

**Cú pháp:**
```sql
SELECT columns
FROM table1 LEFT OUTER JOIN table2
ON table1.column = table2.column;

-- Cú pháp ngắn hơn
SELECT columns
FROM table1 LEFT JOIN table2
ON table1.column = table2.column;
```

#### Biểu Diễn Trực Quan - LEFT JOIN

**Truy vấn:**
```sql
SELECT e.first_name, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id;
```

**Kết quả LEFT JOIN:**
```
┌─────────────────────────────────────────────┐
│           LEFT OUTER JOIN                   │
│   (Tất cả từ bảng TRÁI + khớp từ bảng PHẢI) │
└─────────────────────────────────────────────┘

first_name | department_name
-----------|----------------
   John    |       IT       ← Khớp (emp 100, dept 10)
   Jane    |     Sales      ← Khớp (emp 101, dept 20)
   Bob     |     NULL       ← Không khớp (emp 102, dept NULL)
  Alice    |     NULL       ← Không khớp (emp 103, dept 30 không tồn tại)

📊 Biểu đồ minh họa:
[EMPLOYEES] ←── GIỮ TẤT CẢ     [DEPARTMENTS]
┌─────────┐                   ┌─────────┐
│   100   │────────────────▶  │   10    │  ✓ Khớp
│   101   │────────────────▶  │   20    │  ✓ Khớp  
│   102   │  ✗ (NULL dept)    │   40    │  ⚪ Bỏ qua
│   103   │  ✗ (dept 30 N/A)  │   50    │  ⚪ Bỏ qua
└─────────┘                   └─────────┘
    ▲                             ▲
    │                             │
 TẤT CẢ BAO GỒM               CHỈ CÁC KHỚP

🎯 Khi nào dùng LEFT JOIN?
"Tôi muốn thấy TẤT CẢ nhân viên, kể cả người chưa có phòng ban"
```

**Trường Hợp Sử Dụng:**
- Liệt kê tất cả khách hàng và đơn hàng của họ (bao gồm khách hàng không có đơn hàng)
- Hiển thị tất cả nhân viên và các dự án được giao (bao gồm nhân viên không được giao việc)
- Hiển thị tất cả sản phẩm và doanh số của chúng (bao gồm sản phẩm chưa bao giờ được bán)

### 2. RIGHT OUTER JOIN (hoặc RIGHT JOIN)

Trả về TẤT CẢ các hàng từ bảng bên phải và các hàng khớp từ bảng bên trái. Nếu không có khớp, giá trị NULL được trả về cho các cột bảng bên trái.

**Cú pháp:**
```sql
SELECT columns
FROM table1 RIGHT OUTER JOIN table2
ON table1.column = table2.column;

-- Cú pháp ngắn hơn
SELECT columns
FROM table1 RIGHT JOIN table2
ON table1.column = table2.column;
```

#### Biểu Diễn Trực Quan - RIGHT JOIN

**Truy vấn:**
```sql
SELECT e.first_name, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id;
```

**Kết quả RIGHT JOIN:**
```
┌─────────────────────────────────────────────┐
│          RIGHT OUTER JOIN                   │
│   (Khớp từ bảng TRÁI + tất cả từ bảng PHẢI) │
└─────────────────────────────────────────────┘

first_name | department_name
-----------|----------------
   John    |       IT       ← Khớp (emp 100, dept 10)
   Jane    |     Sales      ← Khớp (emp 101, dept 20)
   NULL    |       HR       ← Không khớp (dept 40, không có emp)
   NULL    |    Finance     ← Không khớp (dept 50, không có emp)

📊 Biểu đồ minh họa:
[EMPLOYEES]                [DEPARTMENTS] ←── GIỮ TẤT CẢ
┌─────────┐                ┌─────────┐
│   100   │ ─────────────▶ │   10    │  ✓ Khớp
│   101   │ ─────────────▶ │   20    │  ✓ Khớp  
│   102   │ ⚪ Bỏ qua       │   40    │  ✗ Không có emp
│   103   │ ⚪ Bỏ qua       │   50    │  ✗ Không có emp
└─────────┘                └─────────┘
    ▲                          ▲
    │                          │
  CHỈ CÁC KHỚP             TẤT CẢ BAO GỒM

🎯 Khi nào dùng RIGHT JOIN?
"Tôi muốn thấy TẤT CẢ phòng ban, kể cả phòng ban trống"
```

**Trường Hợp Sử Dụng:**
- Liệt kê tất cả phòng ban và nhân viên của họ (bao gồm phòng ban trống)
- Hiển thị tất cả danh mục và sản phẩm của chúng (bao gồm danh mục trống)
- Hiển thị tất cả địa điểm và văn phòng của chúng (bao gồm địa điểm không sử dụng)

### 3. FULL OUTER JOIN (hoặc FULL JOIN)

Trả về TẤT CẢ các hàng từ cả hai bảng. Nếu không có khớp, giá trị NULL được trả về cho các cột của bảng không khớp.

**Cú pháp:**
```sql
SELECT columns
FROM table1 FULL OUTER JOIN table2
ON table1.column = table2.column;

-- Cú pháp ngắn hơn
SELECT columns
FROM table1 FULL JOIN table2
ON table1.column = table2.column;
```

#### Biểu Diễn Trực Quan - FULL OUTER JOIN

**Truy vấn:**
```sql
SELECT e.first_name, d.department_name
FROM employees e FULL OUTER JOIN departments d
ON e.department_id = d.department_id;
```

**Kết quả FULL OUTER JOIN:**
```
┌─────────────────────────────────────────────┐
│           FULL OUTER JOIN                   │
│      (Tất cả từ CẢ HAI bảng)                │
└─────────────────────────────────────────────┘

first_name | department_name
-----------|----------------
   John    |       IT       ← Khớp (emp 100, dept 10)
   Jane    |     Sales      ← Khớp (emp 101, dept 20)
   Bob     |     NULL       ← Chỉ trong EMPLOYEES
  Alice    |     NULL       ← Chỉ trong EMPLOYEES  
   NULL    |       HR       ← Chỉ trong DEPARTMENTS
   NULL    |    Finance     ← Chỉ trong DEPARTMENTS

📊 Biểu đồ minh họa:
[EMPLOYEES] ←── GIỮ TẤT CẢ     [DEPARTMENTS] ←── GIỮ TẤT CẢ
┌─────────┐                   ┌─────────┐
│   100   │ ◄────────────────▶│   10    │  ✓ Khớp
│   101   │ ◄────────────────▶│   20    │  ✓ Khớp  
│   102   │ ✗ (NULL dept)     │   40    │  ✗ Không có emp
│   103   │ ✗ (dept 30 N/A)   │   50    │  ✗ Không có emp
└─────────┘                   └─────────┘
    ▲                             ▲
    │                             │
 TẤT CẢ BAO GỒM              TẤT CẢ BAO GỒM

🎯 Khi nào dùng FULL OUTER JOIN?
"Tôi muốn thấy TẤT CẢ nhân viên VÀ TẤT CẢ phòng ban"

┌─────────────────────────────────────────────┐
│            UNION CONCEPT                    │
│   LEFT ONLY + MATCHES + RIGHT ONLY         │
└─────────────────────────────────────────────┘
```

#### So Sánh Các Loại JOIN với Biểu Đồ Venn
```
INNER JOIN:         LEFT JOIN:          RIGHT JOIN:         FULL OUTER JOIN:
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│    A    │         │█████████│         │    A    │         │█████████│
│    ●    │         │████●████│         │    ●████│         │████●████│
│    B    │         │    B    │         │█████████│         │█████████│
└─────────┘         └─────────┘         └─────────┘         └─────────┘
A ∩ B only          A + (A ∩ B)         (A ∩ B) + B         A ∪ B

● = Matching records (Inner Join portion)
█ = Data included in result
```

#### Workflow Decision Tree
```
🤔 Cần chọn loại JOIN nào?

TÌNH HUỐNG CỤ THỂ:
│
├─ "Tôi muốn TẤT CẢ nhân viên, kể cả người chưa có phòng ban"
│  └─► LEFT OUTER JOIN
│
├─ "Tôi muốn TẤT CẢ phòng ban, kể cả phòng ban trống"  
│  └─► RIGHT OUTER JOIN
│
├─ "Tôi muốn TẤT CẢ nhân viên VÀ TẤT CẢ phòng ban"
│  └─► FULL OUTER JOIN
│
└─ "Chỉ muốn nhân viên có phòng ban rõ ràng"
   └─► INNER JOIN
```

**Trường Hợp Sử Dụng:**
- So sánh hai tập dữ liệu và tìm sự khác biệt
- Hợp nhất dữ liệu từ các nguồn khác nhau
- Nhiệm vụ đối soát dữ liệu
- Tạo báo cáo so sánh toàn diện

## Cú Pháp Truyền Thống (+) của Oracle

Oracle cung cấp cú pháp truyền thống sử dụng toán tử (+) cho outer joins. Mặc dù cú pháp ANSI SQL được ưa chuộng cho phát triển mới, bạn có thể gặp cú pháp này trong mã cũ.

### LEFT OUTER JOIN với (+)
```sql
-- ANSI SQL
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id;

-- Cú pháp truyền thống Oracle
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id(+);
```

### RIGHT OUTER JOIN với (+)
```sql
-- ANSI SQL
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id;

-- Cú pháp truyền thống Oracle
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e, departments d
WHERE e.department_id(+) = d.department_id;
```

**Lưu ý:** Toán tử (+) đặt ở phía có thể có giá trị NULL (phía "tùy chọn").

## Ví Dụ Thực Tế

### Ví Dụ 1: Tìm Nhân Viên Không Có Phòng Ban
```sql
-- Liệt kê tất cả nhân viên, hiển thị tên phòng ban hoặc 'Không Có Phòng Ban'
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    NVL(d.department_name, 'Không Có Phòng Ban') AS department
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id;
```

### Ví Dụ 2: Tìm Phòng Ban Không Có Nhân Viên
```sql
-- Liệt kê tất cả phòng ban, hiển thị số lượng nhân viên
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;
```

### Ví Dụ 3: Phân Tích Hoàn Chỉnh Nhân Viên-Phòng Ban
```sql
-- Full outer join để xem tất cả nhân viên và tất cả phòng ban
SELECT 
    COALESCE(e.employee_id, 0) AS employee_id,
    COALESCE(e.first_name || ' ' || e.last_name, 'Không Có Nhân Viên') AS employee_name,
    COALESCE(d.department_name, 'Không Có Phòng Ban') AS department_name,
    CASE 
        WHEN e.employee_id IS NULL THEN 'Phòng Ban Trống'
        WHEN d.department_id IS NULL THEN 'Nhân Viên Chưa Phân Công'
        ELSE 'Đã Khớp'
    END AS match_status
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id
ORDER BY match_status, d.department_name, e.last_name;
```

## Xử Lý NULL trong Outer Joins

### Hiểu về Giá Trị NULL
Khi outer join không tìm thấy khớp, nó trả về NULL cho các cột từ bảng không khớp. Điều quan trọng là xử lý các NULL này một cách phù hợp.

### Các Hàm Xử Lý NULL Phổ Biến
1. **NVL(expr1, expr2)**: Trả về expr2 nếu expr1 là NULL
2. **NVL2(expr1, expr2, expr3)**: Trả về expr2 nếu expr1 không NULL, expr3 nếu NULL
3. **COALESCE(expr1, expr2, ...)**: Trả về biểu thức không NULL đầu tiên
4. **CASE**: Cung cấp logic điều kiện cho xử lý NULL

### Ví Dụ: Xử Lý NULL Nâng Cao
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    NVL(d.department_name, 'Chưa Phân Công') AS department_name,
    NVL2(e.salary, TO_CHAR(e.salary, '$999,999'), 'Không Có Thông Tin Lương') AS salary_display,
    COALESCE(e.commission_pct, 0) AS commission_rate,
    CASE 
        WHEN d.department_id IS NULL THEN 'Nhân viên cần phân công phòng ban'
        WHEN e.manager_id IS NULL THEN 'Quản lý cấp cao'
        ELSE 'Nhân viên thường'
    END AS employee_status
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id;
```

## Cân Nhắc Về Hiệu Suất

### Sử Dụng Index
- Đảm bảo các cột join được lập index
- Xem xét composite indexes cho joins nhiều cột
- Outer joins có thể ngăn một số tối ưu hóa index

### Mẹo Tối Ưu Truy Vấn
1. **Lọc Sớm**: Áp dụng điều kiện WHERE trước khi joining khi có thể
2. **Sử Dụng EXISTS**: Đôi khi EXISTS hiệu quả hơn outer joins
3. **Xem Xét Subqueries**: Có thể hiệu quả hơn cho một số tình huống cụ thể
4. **Phân Tích Execution Plans**: Sử dụng EXPLAIN PLAN để hiểu hiệu suất truy vấn

### Ví Dụ: Outer Join Được Tối Ưu
```sql
-- Kém hiệu quả - lọc sau khi join
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.hire_date >= DATE '2020-01-01';

-- Hiệu quả hơn - lọc trước khi join
SELECT e.employee_id, e.first_name, d.department_name
FROM (
    SELECT employee_id, first_name, department_id
    FROM employees
    WHERE hire_date >= DATE '2020-01-01'
) e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

## Mẫu Phổ Biến và Thực Hành Tốt Nhất

### 1. Tìm Bản Ghi Không Khớp
```sql
-- Tìm khách hàng chưa đặt hàng
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
```

### 2. Tổng Hợp với Outer Joins
```sql
-- Đếm đơn hàng cho mỗi khách hàng (bao gồm khách hàng không có đơn hàng)
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    NVL(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;
```

### 3. Outer Joins Nhiều Cấp
```sql
-- Cấu trúc phân cấp nhân viên với thông tin phòng ban và quản lý tùy chọn
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    NVL(d.department_name, 'Không Có Phòng Ban') AS department,
    NVL(m.first_name || ' ' || m.last_name, 'Không Có Quản Lý') AS manager_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY d.department_name, e.last_name;
```

## Lỗi Thường Gặp Cần Tránh

### 1. Nhầm Lẫn Left và Right Joins
```sql
-- SAI: Cố gắng lấy tất cả phòng ban với thông tin nhân viên
SELECT d.department_name, e.first_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- ĐÚNG: Tất cả phòng ban với thông tin nhân viên tùy chọn
SELECT d.department_name, e.first_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;
```

### 2. Lọc NULL Không Đúng Cách
```sql
-- SAI: Điều này phá vỡ mục đích của outer join
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name IS NOT NULL;

-- ĐÚNG: Sử dụng inner join nếu không muốn NULL
SELECT e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

### 3. Trộn Lẫn Cú Pháp Truyền Thống và ANSI
```sql
-- SAI: Không nên trộn lẫn cú pháp
SELECT e.first_name, d.department_name, l.city
FROM employees e, departments d
LEFT JOIN locations l ON d.location_id = l.location_id
WHERE e.department_id = d.department_id(+);

-- ĐÚNG: Sử dụng cú pháp ANSI nhất quán
SELECT e.first_name, d.department_name, l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id;
```

## Bài Tập Thực Hành

### Bài Tập 1: Outer Joins Cơ Bản
Viết truy vấn để:
1. Liệt kê tất cả nhân viên với tên phòng ban của họ (bao gồm nhân viên không có phòng ban)
2. Liệt kê tất cả phòng ban với số lượng nhân viên (bao gồm phòng ban trống)
3. Tìm nhân viên không được phân công vào phòng ban nào

### Bài Tập 2: Tình Huống Phức Tạp
Viết truy vấn để:
1. Hiển thị tất cả sản phẩm và tổng doanh số của chúng (bao gồm sản phẩm chưa bao giờ được bán)
2. Liệt kê tất cả khách hàng và ngày đặt hàng gần nhất của họ (bao gồm khách hàng không có đơn hàng)
3. Tạo báo cáo hiển thị tất cả phòng ban, quản lý của họ, và số lượng nhân viên

### Bài Tập 3: Phân Tích Hiệu Suất
1. So sánh execution plans của inner joins và outer joins tương đương
2. Tối ưu hóa một truy vấn outer join chậm
3. Viết lại outer join sử dụng EXISTS/NOT EXISTS

## Bước Tiếp Theo

Trong phần tiếp theo, chúng ta sẽ khám phá:
- Kỹ thuật join nâng cao (CROSS JOIN, NATURAL JOIN)
- Self-joins và truy vấn phân cấp
- Joins nhiều bảng với điều kiện phức tạp
- Chiến lược tối ưu hóa join

## Tóm Tắt

Outer joins là công cụ thiết yếu để:
- Bao gồm tất cả bản ghi từ một hoặc cả hai bảng
- Tìm dữ liệu thiếu hoặc không khớp
- Tạo báo cáo toàn diện
- Phân tích và đối soát dữ liệu

**Điểm chính cần nhớ:**
- **LEFT JOIN**: Tất cả bản ghi từ bảng trái + khớp từ bảng phải
- **RIGHT JOIN**: Khớp từ bảng trái + tất cả bản ghi từ bảng phải  
- **FULL OUTER JOIN**: Tất cả bản ghi từ cả hai bảng
- Xử lý NULL phù hợp với NVL, COALESCE, hoặc CASE
- Sử dụng cú pháp ANSI SQL để dễ đọc và tương thích tốt hơn
- Cân nhắc ảnh hưởng đến hiệu suất và tối ưu hóa phù hợp

**📊 Quick Reference:**
```
INNER JOIN:  A ∩ B (Intersection)
LEFT JOIN:   A + (A ∩ B) 
RIGHT JOIN:  B + (A ∩ B)
FULL JOIN:   A ∪ B (Union with NULLs)
```
