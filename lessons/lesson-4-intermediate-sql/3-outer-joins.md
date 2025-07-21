# Outer Joins trong Oracle Database

## Mục Lục

1. [Mục Tiêu Học Tập](#mục-tiêu-học-tập)
2. [Giới Thiệu về Outer Joins](#giới-thiệu-về-outer-joins)
3. [Dữ Liệu Mẫu cho Các Ví Dụ](#dữ-liệu-mẫu-cho-các-ví-dụ)
4. [Các Loại Outer Joins](#các-loại-outer-joins)
5. [Cú Pháp Truyền Thống (+) của Oracle](#cú-pháp-truyền-thống--của-oracle)
6. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
7. [Xử Lý NULL trong Outer Joins](#xử-lý-null-trong-outer-joins)
8. [Cân Nhắc Về Hiệu Suất](#cân-nhắc-về-hiệu-suất)
9. [Mẫu Phổ Biến và Thực Hành Tốt Nhất](#mẫu-phổ-biến-và-thực-hành-tốt-nhất)
10. [Lỗi Thường Gặp Cần Tránh](#lỗi-thường-gặp-cần-tránh)
11. [Bài Tập Thực Hành](#bài-tập-thực-hành)
12. [Tóm Tắt](#tóm-tắt)

## Mục Tiêu Học Tập
Đến cuối phần này, bạn sẽ hiểu:
- Các loại outer join khác nhau (LEFT, RIGHT, FULL)
- Khi nào và tại sao sử dụng outer joins
- Cú pháp truyền thống (+) của Oracle so với cú pháp ANSI SQL
- Ứng dụng thực tế của outer joins
- Cân nhắc về hiệu suất

## Giới Thiệu về Outer Joins

Outer joins trả về tất cả các hàng từ một hoặc cả hai bảng, ngay cả khi không có hàng khớp trong bảng được nối. Khác với inner joins chỉ trả về các hàng khớp, outer joins bảo toàn các hàng không khớp bằng cách điền các giá trị thiếu với NULL.

### Tại Sao Sử Dụng Outer Joins?

1. **Tìm Dữ Liệu Thiếu**: Xác định các bản ghi không có mục tương ứng
2. **Báo Cáo Hoàn Chỉnh**: Bao gồm tất cả thực thể ngay cả không có dữ liệu liên quan
3. **Phân Tích Dữ Liệu**: Phân tích khoảng trống và mối quan hệ thiếu
4. **Business Intelligence**: Tạo báo cáo toàn diện

## Dữ Liệu Mẫu cho Các Ví Dụ

Để hiểu rõ các loại Outer Joins, chúng ta sẽ sử dụng dữ liệu mẫu sau trong tất cả các ví dụ:

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
