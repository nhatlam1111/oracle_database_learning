# INNER JOINs - Kết Hợp Dữ Liệu Khớp

## Mục Lục
1. [Khái Niệm INNER JOIN](#1-khái-niệm-inner-join)
2. [Cách Hoạt Động của INNER JOIN](#2-cách-hoạt-động-của-inner-join)
3. [Cú Pháp và So Sánh](#3-cú-pháp-và-so-sánh)
4. [Bí Danh Bảng](#4-bí-danh-bảng)
5. [INNER JOIN Nhiều Bảng](#5-inner-join-nhiều-bảng)
6. [Lỗi Thường Gặp](#6-lỗi-thường-gặp)

---

## 1. Khái Niệm INNER JOIN

### Định Nghĩa
**INNER JOIN** kết hợp dữ liệu từ hai hoặc nhiều bảng dựa trên điều kiện khớp. Chỉ trả về các dòng có giá trị khớp trong **TẤT CẢ** các bảng được nối.

### Biểu Diễn Trực Quan

```
Bảng EMPLOYEES           Bảng DEPARTMENTS         Kết Quả INNER JOIN
┌─────┬─────┬──────┐     ┌──────┬─────────────┐    ┌─────┬─────┬─────────────┐
│ EID │NAME │DEPT_ID│     │DEPT_ID│DEPT_NAME   │    │ EID │NAME │DEPT_NAME    │
├─────┼─────┼──────┤     ├──────┼─────────────┤    ├─────┼─────┼─────────────┤
│ 100 │Alice│  10  │ ◄──►│  10  │Sales        │───►│ 100 │Alice│Sales        │
│ 101 │Bob  │  20  │ ◄──►│  20  │Marketing    │───►│ 101 │Bob  │Marketing    │
│ 102 │Carol│  99  │  ✗  │  30  │HR           │    │ 103 │Dave │HR           │
│ 103 │Dave │  30  │ ◄──►└──────┴─────────────┘    └─────┴─────┴─────────────┘
└─────┴─────┴──────┘
      ↑                                                      ↑
   Carol bị loại                                    Chỉ có 3 dòng khớp
   (DEPT_ID=99 không tồn tại)
```

### Đặc Điểm Quan Trọng
- **Chỉ lấy dữ liệu khớp**: Bỏ qua các dòng không có cặp khớp
- **Kết quả nhỏ hơn hoặc bằng**: Số dòng kết quả ≤ số dòng của bảng nhỏ nhất
- **Lọc tự động**: Loại bỏ dữ liệu "mồ côi" (orphaned data)

---

## 2. Cách Hoạt Động của INNER JOIN

### Thuật Toán Cơ Bản

```
Bước 1: QUÉT BẢNG THỨ NHẤT
┌─────────────────────────┐
│ Lấy từng dòng từ bảng A │
└─────────────────────────┘
            │
            ▼
Bước 2: TÌM KIẾM KHỚP
┌─────────────────────────┐
│ Với mỗi dòng A, tìm tất │
│ cả dòng khớp trong B    │
└─────────────────────────┘
            │
            ▼
Bước 3: KẾT HỢP DỮ LIỆU
┌─────────────────────────┐
│ Ghép cột từ A và B      │
│ thành 1 dòng kết quả    │
└─────────────────────────┘
```

### Ví Dụ Minh Họa

Dữ liệu mẫu:
```sql
-- Bảng EMPLOYEES
EMP_ID | NAME  | DEPT_ID
   100 | Alice |      10
   101 | Bob   |      20  
   102 | Carol |      99  -- Không khớp

-- Bảng DEPARTMENTS  
DEPT_ID | DEPT_NAME
     10 | Sales
     20 | Marketing
     30 | HR          -- Không khớp
```

Quá trình thực thi:
```sql
-- dòng 1: Alice (DEPT_ID=10)
-- Tìm trong DEPARTMENTS: Tìm thấy → Kết hợp
-- Kết quả: 100, Alice, 10, Sales

-- dòng 2: Bob (DEPT_ID=20)  
-- Tìm trong DEPARTMENTS: Tìm thấy → Kết hợp
-- Kết quả: 101, Bob, 20, Marketing

-- dòng 3: Carol (DEPT_ID=99)
-- Tìm trong DEPARTMENTS: KHÔNG tìm thấy → Bỏ qua
```

### Kết Quả Cuối Cùng
```
EMP_ID | NAME  | DEPT_ID | DEPT_NAME
   100 | Alice |      10 | Sales
   101 | Bob   |      20 | Marketing
```

---

## 3. Cú Pháp và So Sánh

### Cú Pháp JOIN (ANSI SQL - Khuyến nghị)

```sql
SELECT cột1, cột2, ...  
FROM bảng1
INNER JOIN bảng2 ON bảng1.cột = bảng2.cột;
```

**Ví dụ:**
```sql
SELECT e.emp_id, e.name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

### Cú Pháp WHERE (Oracle truyền thống)

```sql
SELECT cột1, cột2, ...
FROM bảng1, bảng2  
WHERE bảng1.cột = bảng2.cột;
```

**Ví dụ:**
```sql
SELECT e.emp_id, e.name, d.dept_name
FROM employees e, departments d
WHERE e.dept_id = d.dept_id;
```

### So Sánh Chi Tiết

| **Khía Cạnh** | **Cú Pháp JOIN** | **Cú Pháp WHERE** |
|----------------|-------------------|--------------------|
| **Độ rõ ràng** | ✅ Rất rõ ràng | ❌ Dễ nhầm lẫn |
| **Tách biệt logic** | ✅ JOIN riêng, WHERE riêng | ❌ Trộn lẫn điều kiện |
| **Đọc hiểu** | ✅ Dễ đọc với nhiều bảng | ❌ Khó đọc khi phức tạp |
| **Ngăn lỗi Cartesian** | ✅ Bắt buộc có điều kiện | ❌ Dễ quên điều kiện |
| **Chuẩn SQL** | ✅ ANSI SQL chuẩn | ❌ Cú pháp cũ |
| **Hiệu suất** | ✅ Tương đương | ✅ Tương đương |

### Ví Dụ So Sánh Thực Tế

**Trường hợp đơn giản (2 bảng):**
```sql
-- JOIN: Rõ ràng
SELECT e.name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 5000;

-- WHERE: Vẫn OK
SELECT e.name, d.dept_name  
FROM employees e, departments d
WHERE e.dept_id = d.dept_id
  AND e.salary > 5000;
```

**Trường hợp phức tạp (4 bảng):**
```sql
-- JOIN: Dễ đọc và hiểu
SELECT e.name, d.dept_name, l.city, c.country_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN locations l ON d.location_id = l.location_id  
INNER JOIN countries c ON l.country_id = c.country_id
WHERE e.salary > 5000;

-- WHERE: Khó đọc, dễ sai
SELECT e.name, d.dept_name, l.city, c.country_name
FROM employees e, departments d, locations l, countries c
WHERE e.dept_id = d.dept_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND e.salary > 5000;
```

### **Khuyến Nghị: Sử Dụng Cú Pháp JOIN**

**Lý do:**
1. **Tách biệt rõ ràng**: Điều kiện nối ≠ Điều kiện lọc
2. **Dễ bảo trì**: Thêm/bớt bảng không ảnh hưởng WHERE
3. **Ngăn lỗi**: Bắt buộc phải có ON, tránh Cartesian Product
4. **Chuẩn mực**: Tuân thủ chuẩn SQL hiện đại

---

## 4. Bí Danh Bảng

### Tại Sao Cần Bí Danh?

```sql
-- ✗ KHÔNG dùng bí danh: Dài dòng, khó đọc
SELECT employees.employee_id, employees.first_name, departments.department_name
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;

-- ✓ DÙNG bí danh: Ngắn gọn, rõ ràng  
SELECT e.employee_id, e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Quy Tắc Bí Danh Tốt

```sql
-- ✓ BÍ DANH CÓ Ý NGHĨA
SELECT emp.employee_id, emp.first_name, dept.department_name
FROM hr.employees emp
INNER JOIN hr.departments dept ON emp.department_id = dept.department_id;

-- ✗ Bí danh khó hiểu
SELECT x.employee_id, x.first_name, y.department_name  
FROM hr.employees x
INNER JOIN hr.departments y ON x.department_id = y.department_id;
```

### Phân Biệt Cột Trùng Tên

```sql
-- Bắt buộc khi cột trùng tên
SELECT 
    e.employee_id,        -- Chỉ có trong employees
    e.first_name,         -- Chỉ có trong employees  
    e.department_id,      -- CÓ TRONG CẢ HAI BẢNG → Phải chỉ rõ
    d.department_id,      -- CÓ TRONG CẢ HAI BẢNG → Phải chỉ rõ
    d.department_name     -- Chỉ có trong departments
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

---

## 5. INNER JOIN Nhiều Bảng

### Cách Hoạt Động

```
Bước 1: A JOIN B = Kết quả AB
┌─────┐    ┌─────┐    ┌─────────┐
│  A  │ +  │  B  │ =  │   AB    │
└─────┘    └─────┘    └─────────┘

Bước 2: AB JOIN C = Kết quả ABC  
┌─────────┐    ┌─────┐    ┌─────────┐
│   AB    │ +  │  C  │ =  │   ABC   │
└─────────┘    └─────┘    └─────────┘
```

### Ví Dụ 3 Bảng

```sql
-- Nhân viên → Phòng ban → Địa điểm
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id;
```

**Cách hoạt động:**
```
1. employees INNER JOIN departments  
   → Lấy nhân viên có phòng ban

2. Kết quả bước 1 INNER JOIN locations
   → Lấy những nhân viên có phòng ban VÀ phòng ban có địa điểm
```

### Ví Dụ 4 Bảng

```sql
-- Chuỗi quan hệ: Nhân viên → Phòng ban → Địa điểm → Quốc gia
SELECT 
    e.first_name,
    d.department_name,
    l.city,
    c.country_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id  
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id;
```

### Lưu Ý Quan Trọng

⚠️ **Thứ tự JOIN quan trọng:**
```sql
-- ✓ ĐÚNG: Nối theo chuỗi logic
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id  -- e → d
INNER JOIN locations l ON d.location_id = l.location_id        -- d → l

-- ✗ SAI: Không thể nối trực tiếp
FROM employees e  
INNER JOIN locations l ON e.??? = l.???  -- Không có cột liên kết trực tiếp
```

---

## 6. Lỗi Thường Gặp

### Lỗi 1: Cột Nhập Nhằng (Ambiguous Column)

```sql
-- ✗ LỖI: Oracle không biết department_id của bảng nào
SELECT employee_id, department_id, department_name
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;
-- ORA-00918: column ambiguously defined

-- ✓ SỬA: Chỉ rõ bảng chứa cột
SELECT e.employee_id, e.department_id, d.department_name  
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Lỗi 2: Thiếu Điều Kiện JOIN (Cartesian Product)

```sql
-- ✗ SAI: Thiếu điều kiện nối
SELECT e.first_name, d.department_name
FROM hr.employees e, hr.departments d;
-- Kết quả: employee_count × department_count dòng

-- ✓ ĐÚNG: Có điều kiện nối
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Lỗi 3: Điều Kiện JOIN Sai

```sql
-- ✗ SAI: Nối sai cột
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.employee_id = d.department_id;
-- Logic sai: so sánh employee_id với department_id

-- ✓ ĐÚNG: Nối đúng cột
SELECT e.first_name, d.department_name  
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Lỗi 4: Quên Alias Khi Cần Thiết

```sql
-- ✗ SAI: Self-join không có alias
SELECT * 
FROM hr.employees
INNER JOIN hr.employees ON employees.manager_id = employees.employee_id;
-- Không thể phân biệt nhân viên và quản lý

-- ✓ ĐÚNG: Self-join với alias
SELECT 
    emp.first_name AS employee_name,
    mgr.first_name AS manager_name
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id;
```

---

## Tóm Tắt Quan Trọng

### Điểm Chính
- **INNER JOIN**: Chỉ lấy dữ liệu khớp từ tất cả bảng
- **Cú pháp JOIN**: Rõ ràng hơn, dễ bảo trì hơn cú pháp WHERE
- **Bí danh bảng**: Bắt buộc khi có cột trùng tên hoặc self-join
- **Nhiều bảng**: Nối theo chuỗi logic, từng cặp một

### Thực Hành Tốt Nhất
1. **Luôn dùng cú pháp INNER JOIN** thay vì WHERE
2. **Đặt alias có ý nghĩa** cho tất cả bảng  
3. **Chỉ rõ tên bảng** cho tất cả cột
4. **Kiểm tra logic JOIN** trước khi chạy
5. **Format code** dễ đọc với nhiều bảng

### Câu Hỏi Tự Kiểm Tra  
- Tại sao INNER JOIN tốt hơn cú pháp WHERE?
- Khi nào bắt buộc phải dùng alias?
- Làm sao tránh Cartesian Product?
- Thứ tự JOIN có quan trọng không?

## Cú Pháp INNER JOIN Cơ Bản

### Cú Pháp Chuẩn ANSI (Khuyến nghị)

```sql
SELECT column1, column2, ...
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Cú Pháp Truyền Thống Oracle (Cũ)

```sql
SELECT column1, column2, ...
FROM table1, table2
WHERE table1.column = table2.column;
```

### Ví Dụ Đơn Giản

```sql
-- Lấy tên nhân viên với tên phòng ban của họ
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Điều Kiện Join và Mối Quan Hệ

### Equality Joins (Equi-Joins)

Loại phổ biến nhất sử dụng toán tử bằng (=).

```sql
-- Nhân viên với chức danh công việc của họ
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    j.job_title
FROM hr.employees e
INNER JOIN hr.jobs j ON e.job_id = j.job_id;
```

### Joins Nhiều Cột

Khi mối quan hệ yêu cầu nhiều cột.

```sql
-- Ví dụ với khóa tổ hợp
SELECT 
    oi.order_id,
    oi.product_id,
    p.product_name,
    oi.quantity
FROM sales.order_items oi
INNER JOIN sales.products p ON oi.product_id = p.product_id;
```

### Điều Kiện Join với Hàm

```sql
-- Join không phân biệt hoa thường
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d 
    ON UPPER(e.department_name) = UPPER(d.department_name);
```

## Bí Danh Bảng và Khả Năng Đọc

### Tại Sao Sử Dụng Bí Danh?

1. **Truy vấn ngắn hơn**: Ít gõ hơn và dễ đọc hơn
2. **Phân biệt rõ ràng**: Rõ ràng cột nào đến từ bảng nào
3. **Bắt buộc cho self-joins**: Phải sử dụng bí danh khi nối bảng với chính nó

### Thực Hành Tốt Nhất cho Bí Danh

```sql
-- Tốt: Bí danh có ý nghĩa
SELECT 
    emp.first_name,
    emp.last_name,
    dept.department_name,
    mgr.first_name AS manager_first_name
FROM hr.employees emp
INNER JOIN hr.departments dept ON emp.department_id = dept.department_id
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id;

-- Tránh: Bí danh không rõ ràng
SELECT e.first_name, d.department_name
FROM hr.employees x
INNER JOIN hr.departments y ON x.department_id = y.department_id;
```

### Phân Biệt Cột

```sql
-- Bắt buộc khi tên cột tồn tại trong nhiều bảng
SELECT 
    e.employee_id,        -- Rõ ràng từ bảng nào
    e.first_name,
    e.last_name,
    d.department_id,      -- Cả hai bảng đều có department_id
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## JOINs Nhiều Bảng

### JOIN Ba Bảng

```sql
-- Nhân viên với thông tin phòng ban và địa điểm
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    l.country_id
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id;
```

### JOIN Bốn Bảng

```sql
-- Cấu trúc phân cấp địa điểm nhân viên hoàn chỉnh
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    c.country_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id;
```

### Phân Tích Bán Hàng Phức Tạp

```sql
-- Thông tin đơn hàng hoàn chỉnh
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN sales.products p ON oi.product_id = p.product_id
ORDER BY o.order_date, c.last_name;
```

## Kỹ Thuật JOIN Nâng Cao

### JOINs với Mệnh Đề WHERE

```sql
-- Lọc trước hoặc sau khi nối
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.salary > 10000
  AND d.department_name LIKE '%Sales%';
```

### JOINs với Hàm Tổng Hợp

```sql
-- Thống kê phòng ban
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    SUM(e.salary) AS total_payroll
FROM hr.departments d
INNER JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;
```

### JOINs với Subqueries

```sql
-- Nhân viên trong các phòng ban có số lượng nhân viên trên mức trung bình
SELECT 
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.department_id IN (
    SELECT department_id
    FROM hr.employees
    GROUP BY department_id
    HAVING COUNT(*) > (
        SELECT AVG(emp_count)
        FROM (
            SELECT COUNT(*) AS emp_count
            FROM hr.employees
            GROUP BY department_id
        )
    )
);
```

## Cân Nhắc Về Hiệu Suất

### Sử Dụng Index

```sql
-- Đảm bảo index tồn tại trên các cột join
CREATE INDEX idx_emp_dept_id ON hr.employees(department_id);
CREATE INDEX idx_dept_location_id ON hr.departments(location_id);

-- Query optimizer có thể sử dụng các index này cho joins nhanh hơn
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Tối Ưu Thứ Tự Join

```sql
-- Cost-based optimizer của Oracle thường xử lý điều này tự động
-- Nhưng hiểu biết giúp tối ưu thủ công

-- Thường: Nối các bảng nhỏ trước, lọc sớm
SELECT /*+ USE_NL(e d) */ 
    e.first_name, 
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.salary > 15000;  -- Lọc giảm tập kết quả sớm
```

### Tránh Tích Cartesian

```sql
-- Sai: Thiếu điều kiện join tạo ra tích Cartesian
SELECT e.first_name, d.department_name
FROM hr.employees e, hr.departments d;  -- Kết quả là employee_count * dept_count hàng

-- Đúng: Điều kiện join phù hợp
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Mẫu Phổ Biến và Trường Hợp Sử Dụng

### 1. Báo Cáo Master-Detail

```sql
-- Tóm tắt đơn hàng với các mục hàng
SELECT 
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer,
    COUNT(oi.product_id) AS item_count,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name
ORDER BY o.order_date DESC;
```

### 2. Dữ Liệu Phân Cấp

```sql
-- Mối quan hệ nhân viên-quản lý
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee,
    mgr.first_name || ' ' || mgr.last_name AS manager,
    emp.salary,
    mgr.salary AS manager_salary
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY mgr.last_name, emp.last_name;
```

### 3. Xác Thực Dữ Liệu

```sql
-- Tìm đơn hàng có tham chiếu sản phẩm không hợp lệ
SELECT DISTINCT o.order_id
FROM sales.orders o
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.products p 
    WHERE p.product_id = oi.product_id
);
```

### 4. Truy Vấn Tham Chiếu Chéo

```sql
-- Sản phẩm chưa bao giờ được đặt hàng
SELECT p.product_id, p.product_name
FROM sales.products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.order_items oi 
    WHERE oi.product_id = p.product_id
);
```

### 5. Phân Tích Thống Kê

```sql
-- Hiệu suất nhân viên theo phòng ban và công việc
SELECT 
    d.department_name,
    j.job_title,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.hire_date) AS earliest_hire,
    MAX(e.hire_date) AS latest_hire
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
GROUP BY d.department_name, j.job_title
HAVING COUNT(e.employee_id) > 1
ORDER BY d.department_name, avg_salary DESC;
```

## Thực Hành Tốt Nhất

### 1. Luôn Sử Dụng Bí Danh Bảng

```sql
-- Tốt
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Tránh
SELECT first_name, department_name
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;
```

### 2. Phân Định Tất Cả Tên Cột

```sql
-- Tốt: Nguồn cột rõ ràng
SELECT 
    e.employee_id,
    e.first_name,
    d.department_id,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### 3. Sử Dụng Bí Danh Có Ý Nghĩa

```sql
-- Tốt: Bí danh mô tả
FROM hr.employees emp
INNER JOIN hr.departments dept ON emp.department_id = dept.department_id
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id;
```

### 4. Định Dạng Để Dễ Đọc

```sql
-- Định dạng tốt
SELECT 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    dept.department_name,
    job.job_title
FROM hr.employees emp
    INNER JOIN hr.departments dept 
        ON emp.department_id = dept.department_id
    INNER JOIN hr.jobs job 
        ON emp.job_id = job.job_id
WHERE emp.salary > 5000
ORDER BY dept.department_name, emp.last_name;
```

### 5. Lọc Sớm và Phù Hợp

```sql
-- Lọc trước khi join khi có thể
SELECT e.first_name, d.department_name
FROM (
    SELECT employee_id, first_name, department_id
    FROM hr.employees
    WHERE salary > 10000
) e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Lỗi Phổ Biến và Giải Pháp

### Lỗi 1: Tên Cột Nhập Nhằng

```sql
-- Lỗi: column ambiguously defined
SELECT employee_id, department_id
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;

-- Giải pháp: Sử dụng bí danh bảng
SELECT e.employee_id, d.department_id
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Lỗi 2: Thiếu Điều Kiện Join

```sql
-- Sai: Tích Cartesian
SELECT e.first_name, d.department_name
FROM hr.employees e, hr.departments d;

-- Đúng: Điều kiện join phù hợp
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Lỗi 3: Không Khớp Kiểu Dữ Liệu

```sql
-- Vấn đề tiềm ẩn: Chuyển đổi ngầm
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = TO_CHAR(d.department_id);

-- Tốt hơn: Đảm bảo kiểu dữ liệu khớp
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Kiểm Tra và Xác Thực

### Xác Minh Kết Quả Join

```sql
-- Kiểm tra số lượng bản ghi trước và sau join
SELECT COUNT(*) AS employee_count FROM hr.employees;
SELECT COUNT(*) AS department_count FROM hr.departments;

-- So sánh với kết quả join
SELECT COUNT(*) AS join_result_count
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Điều tra sự khác biệt
SELECT COUNT(*) AS employees_without_dept
FROM hr.employees
WHERE department_id IS NULL;
```

### Xác Thực Logic Nghiệp Vụ

```sql
-- Đảm bảo join có ý nghĩa nghiệp vụ
SELECT 
    e.first_name,
    e.last_name,
    e.department_id AS emp_dept_id,
    d.department_id AS dept_dept_id,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.department_id != d.department_id;  -- Không nên trả về dòng nào
```

## Bước Tiếp Theo

Sau khi thành thạo INNER JOINs, bạn nên:

1. **Thực hành với nhiều bảng**: Thử nối 3-4 bảng với nhau
2. **Hiểu về hiệu suất**: Học về kế hoạch thực thi và tối ưu hóa
3. **Chuyển sang OUTER JOINs**: Học khi nào bạn cần bao gồm các bản ghi không khớp
4. **Kết hợp với các tính năng SQL khác**: Sử dụng JOINs với window functions, CTEs, v.v.

INNER JOINs tạo nền tảng cho việc viết truy vấn quan hệ. Thực hành nhiều với các tình huống khác nhau trước khi chuyển sang các loại join phức tạp hơn.

---

**Điểm Chính**: INNER JOINs chỉ trả về các bản ghi khớp từ cả hai bảng. Luôn đảm bảo điều kiện join của bạn phản ánh chính xác mối quan hệ nghiệp vụ giữa các bảng.
