# ADVANCED JOINs - Kỹ Thuật Nối Nâng Cao

## Mục Lục
1. [CROSS JOIN - Tích Cartesian](#1-cross-join---tích-cartesian)
2. [SELF JOIN - Nối Bảng Với Chính Nó](#2-self-join---nối-bảng-với-chính-nó)
3. [NATURAL JOIN và USING](#3-natural-join-và-using)
4. [Joins Nhiều Bảng Phức Tạp](#4-joins-nhiều-bảng-phức-tạp)
5. [Lỗi Thường Gặp](#5-lỗi-thường-gặp)

---

## 1. CROSS JOIN - Tích Cartesian

### Khái Niệm
**CROSS JOIN** kết hợp **MỌI** hàng từ bảng thứ nhất với **MỌI** hàng từ bảng thứ hai. Không có điều kiện nối.

### Công Thức
```
Kết quả = Số hàng bảng A × Số hàng bảng B
```

### Biểu Diễn Trực Quan

```
Bảng A (3 hàng):        Bảng B (2 hàng):
┌─────┬─────┐           ┌─────┬───────┐
│ ID  │NAME │           │SIZE │PRICE  │
├─────┼─────┤           ├─────┼───────┤
│  1  │Tea  │           │  S  │ 10    │
│  2  │Coffee│          │  L  │ 15    │
│  3  │Juice│           └─────┴───────┘
└─────┴─────┘

CROSS JOIN → 3 × 2 = 6 hàng:
┌─────┬─────┬─────┬───────┐
│ ID  │NAME │SIZE │PRICE  │
├─────┼─────┼─────┼───────┤
│  1  │Tea  │  S  │  10   │ ← A[1] + B[1]
│  1  │Tea  │  L  │  15   │ ← A[1] + B[2]
│  2  │Coffee│ S  │  10   │ ← A[2] + B[1]
│  2  │Coffee│ L  │  15   │ ← A[2] + B[2]
│  3  │Juice│  S  │  10   │ ← A[3] + B[1]
│  3  │Juice│  L  │  15   │ ← A[3] + B[2]
└─────┴─────┴─────┴───────┘
```

### Cú Pháp

```sql
-- Cách 1: CROSS JOIN (ANSI)
SELECT a.id, a.name, b.size, b.price
FROM products a
CROSS JOIN sizes b;

-- Cách 2: Không có WHERE (Oracle cũ)
SELECT a.id, a.name, b.size, b.price
FROM products a, sizes b;
```

### Ứng Dụng Thực Tế

```sql
-- Tạo tất cả kết hợp sản phẩm-kích cỡ
SELECT 
    p.product_name,
    s.size_name,
    p.base_price * s.multiplier AS final_price
FROM products p
CROSS JOIN product_sizes s
ORDER BY p.product_name, s.size_order;

-- Tạo lịch làm việc (tất cả ngày × tất cả ca)
SELECT 
    d.work_date,
    sh.shift_name,
    sh.start_time,
    sh.end_time
FROM work_dates d
CROSS JOIN shifts sh
WHERE d.work_date BETWEEN DATE '2024-01-01' AND DATE '2024-01-31';
```

### ⚠️ Cảnh Báo
```
1000 hàng × 1000 hàng = 1,000,000 hàng!
→ Rất dễ tạo ra kết quả khổng lồ
→ Luôn kiểm tra số lượng trước khi chạy
```

---

## 2. SELF JOIN - Nối Bảng Với Chính Nó

### Khái Niệm
**SELF JOIN** nối một bảng với **chính nó** để so sánh các hàng trong cùng bảng hoặc tìm mối quan hệ phân cấp.

### Dữ Liệu Mẫu - Bảng EMPLOYEES
```
┌─────┬─────┬────────────┬────────────┐
│ EID │NAME │ MANAGER_ID │ SALARY     │
├─────┼─────┼────────────┼────────────┤
│ 100 │King │    NULL    │   24000    │ ← CEO
│ 101 │John │    100     │   17000    │ ← Manager
│ 102 │Jane │    100     │   17000    │ ← Manager  
│ 103 │Bob  │    101     │   9000     │ ← Employee
│ 104 │Alice│    101     │   9000     │ ← Employee
└─────┴─────┴────────────┴────────────┘
```

### Trường Hợp 1: Tìm Nhân Viên và Quản Lý

```sql
SELECT 
    emp.name AS employee_name,
    mgr.name AS manager_name,
    emp.salary AS employee_salary,
    mgr.salary AS manager_salary
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.emp_id;
```

**Kết quả:**
```
┌───────────────┬──────────────┬─────────────────┬────────────────┐
│EMPLOYEE_NAME  │MANAGER_NAME  │EMPLOYEE_SALARY  │MANAGER_SALARY  │
├───────────────┼──────────────┼─────────────────┼────────────────┤
│King           │NULL          │     24000       │     NULL       │
│John           │King          │     17000       │     24000      │
│Jane           │King          │     17000       │     24000      │
│Bob            │John          │      9000       │     17000      │
│Alice          │John          │      9000       │     17000      │
└───────────────┴──────────────┴─────────────────┴────────────────┘
```

### Trường Hợp 2: So Sánh Trong Cùng Bảng

```sql
-- Tìm nhân viên có lương cao hơn quản lý
SELECT 
    emp.name AS employee_name,
    emp.salary AS employee_salary,
    mgr.name AS manager_name,
    mgr.salary AS manager_salary
FROM employees emp
INNER JOIN employees mgr ON emp.manager_id = mgr.emp_id
WHERE emp.salary > mgr.salary;

-- Tìm cặp nhân viên cùng lương
SELECT 
    e1.name AS employee1,
    e2.name AS employee2,
    e1.salary
FROM employees e1
INNER JOIN employees e2 ON e1.salary = e2.salary
WHERE e1.emp_id < e2.emp_id;  -- Tránh trùng lặp
```

### Trường Hợp 3: Phân Cấp Nhiều Tầng

```sql
-- Hiển thị CEO → Manager → Employee
SELECT 
    ceo.name AS ceo_name,
    mgr.name AS manager_name,  
    emp.name AS employee_name
FROM employees emp
INNER JOIN employees mgr ON emp.manager_id = mgr.emp_id
INNER JOIN employees ceo ON mgr.manager_id = ceo.emp_id;
```

### Quy Tắc Quan Trọng

```sql
-- ✅ PHẢI sử dụng alias khác nhau
FROM employees emp    -- emp = nhân viên
JOIN employees mgr    -- mgr = quản lý

-- ❌ KHÔNG được dùng cùng alias
FROM employees emp
JOIN employees emp    -- LỖI!
```

---

## 3. NATURAL JOIN và USING

### NATURAL JOIN

**NATURAL JOIN** tự động nối dựa trên **tất cả cột cùng tên**.

```sql
-- Oracle tự động tìm cột chung
SELECT employee_id, first_name, department_name
FROM employees NATURAL JOIN departments;

-- Tương đương với:
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

### USING Clause

**USING** chỉ định **cột cụ thể** để nối.

```sql
-- Chỉ định cột department_id
SELECT employee_id, first_name, department_name  
FROM employees 
JOIN departments USING (department_id);

-- Nhiều cột
SELECT *
FROM employees 
JOIN job_history USING (employee_id, job_id);
```

### So Sánh và Khuyến Nghị

| **Khía Cạnh** | **NATURAL JOIN** | **USING** | **ON** |
|----------------|------------------|-----------|---------|
| **Kiểm soát** | ❌ Tự động | ⚠️ Một phần | ✅ Hoàn toàn |
| **Rõ ràng** | ❌ Không rõ | ⚠️ Trung bình | ✅ Rất rõ |
| **An toàn** | ❌ Dễ lỗi | ⚠️ Tương đối | ✅ An toàn |
| **Khuyến nghị** | 👎 Tránh | 👌 Thỉnh thoảng | 👍 Luôn dùng |

**Lý do tránh NATURAL JOIN:**
- Không rõ cột nào được dùng để nối
- Dễ lỗi khi thay đổi structure bảng
- Khó debug và maintain

---

## 4. Joins Nhiều Bảng Phức Tạp

### Chiến Lược Nối Nhiều Bảng

```sql
-- Thông tin nhân viên đầy đủ (6 bảng)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    j.job_title,
    d.department_name,
    l.city,
    c.country_name,
    mgr.first_name || ' ' || mgr.last_name AS manager_name
FROM employees e                                    -- Bảng chính
    INNER JOIN jobs j ON e.job_id = j.job_id       -- Thông tin công việc  
    INNER JOIN departments d ON e.department_id = d.department_id  -- Phòng ban
    INNER JOIN locations l ON d.location_id = l.location_id        -- Địa điểm
    INNER JOIN countries c ON l.country_id = c.country_id          -- Quốc gia
    LEFT JOIN employees mgr ON e.manager_id = mgr.employee_id      -- Quản lý
WHERE e.salary > 10000
ORDER BY c.country_name, l.city, d.department_name;
```

### Nguyên Tắc Tối Ưu

```
1. ĐẶT BẢNG CHÍNH TRƯỚC (bảng có nhiều điều kiện WHERE)
2. NỐI THEO CHUỖI LOGIC (không nhảy cóc)
3. SỬ DỤNG LEFT JOIN cho dữ liệu tùy chọn
4. LỌC SỚM với WHERE
5. KIỂM TRA EXECUTION PLAN
```

### Joins Có Điều Kiện Phức Tạp

```sql
-- Nối với điều kiện phụ thuộc vào dữ liệu
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    CASE 
        WHEN o.order_date >= DATE '2024-01-01' THEN p.current_price
        ELSE ph.historical_price
    END AS effective_price
FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN price_history ph ON p.product_id = ph.product_id 
        AND o.order_date BETWEEN ph.start_date AND ph.end_date
WHERE o.order_date >= DATE '2023-01-01';
```

---

## 5. Lỗi Thường Gặp

### Lỗi 1: CROSS JOIN Không Cố Ý

```sql
-- ❌ SAI: Thiếu điều kiện JOIN
SELECT e.name, d.dept_name, l.city
FROM employees e, departments d, locations l
WHERE e.salary > 5000;
-- Kết quả: employee_count × dept_count × location_count hàng

-- ✅ ĐÚNG: Có đầy đủ điều kiện JOIN  
SELECT e.name, d.dept_name, l.city
FROM employees e
    INNER JOIN departments d ON e.dept_id = d.dept_id
    INNER JOIN locations l ON d.location_id = l.location_id
WHERE e.salary > 5000;
```

### Lỗi 2: Self-Join Alias Trùng

```sql
-- ❌ SAI: Cùng alias
SELECT e.name, e.name AS manager_name
FROM employees e
JOIN employees e ON e.manager_id = e.employee_id;

-- ✅ ĐÚNG: Alias khác nhau
SELECT emp.name, mgr.name AS manager_name
FROM employees emp
JOIN employees mgr ON emp.manager_id = mgr.employee_id;
```

### Lỗi 3: NATURAL JOIN Không Kiểm Soát

```sql
-- ❌ RỦI RO: Không biết nối trên cột nào
SELECT * FROM employees NATURAL JOIN departments;

-- ✅ RÕ RÀNG: Chỉ định cột nối
SELECT e.*, d.department_name  
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

---

## Tóm Tắt Quan Trọng

### Bảng Tóm Tắt Các Loại JOIN

| **Loại JOIN** | **Mục Đích** | **Khi Nào Dùng** |
|---------------|--------------|-------------------|
| **CROSS** | Tất cả kết hợp | Tạo data test, lịch làm việc |
| **SELF** | So sánh trong cùng bảng | Phân cấp, tìm duplicate |
| **NATURAL** | Tự động nối | ❌ Tránh sử dụng |
| **USING** | Nối cột cụ thể | Khi cột cùng tên, ít dùng |

### Nguyên Tắc Thực Hành

1. **Luôn dùng alias** có ý nghĩa cho bảng
2. **Tránh NATURAL JOIN** trong production
3. **Kiểm tra execution plan** với nhiều bảng
4. **Lọc sớm** với WHERE để giảm dữ liệu
5. **Sử dụng DISTINCT** khi cần loại bỏ trùng lặp

### Decision Tree

```
🤔 Cần loại JOIN nào?

├─ Tất cả kết hợp có thể → CROSS JOIN
├─ So sánh trong cùng bảng → SELF JOIN  
├─ Tự động nối cột cùng tên → NATURAL JOIN (không khuyến nghị)
├─ Nối cột cụ thể → USING
└─ Kết hợp nhiều bảng → INNER/OUTER JOIN
```

**Lưu ý cuối:** Advanced JOINs rất mạnh nhưng cần cẩn thận về hiệu suất và logic. Luôn test với dữ liệu thực và kiểm tra execution plan!

**Cú pháp:**
```sql
SELECT columns
FROM table1 NATURAL JOIN table2;
```

**Ví dụ:**
```sql
-- Nếu cả hai bảng đều có cột DEPARTMENT_ID
SELECT employee_id, first_name, department_name
FROM employees NATURAL JOIN departments;

-- Tương đương với:
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

**Cẩn trọng với NATURAL JOIN:**
- Ít rõ ràng hơn so với điều kiện JOIN tường minh
- Có thể bị lỗi nếu cấu trúc bảng thay đổi
- Có thể join trên các cột không mong muốn
- Thường không được khuyến nghị cho code production

### 3. Mệnh đề USING

Mệnh đề USING chỉ định cột nào để join khi chúng có cùng tên trong cả hai bảng.

**Cú pháp:**
```sql
SELECT columns
FROM table1 JOIN table2 USING (column_name);
```

**Ví dụ:**
```sql
-- Join sử dụng cột cụ thể
SELECT employee_id, first_name, department_name
FROM employees JOIN departments USING (department_id);

-- Nhiều cột
SELECT *
FROM employees JOIN job_history USING (employee_id, job_id);
```

## Self-Joins

Self-joins cho phép bạn join một bảng với chính nó, hữu ích cho dữ liệu phân cấp hoặc so sánh các hàng trong cùng một bảng.

### Phân cấp Nhân viên-Quản lý
```sql
-- Tìm nhân viên và quản lý của họ
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_id AS employee_job,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.job_id AS manager_job
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;
```

### Tìm Các Cấp Phân cấp
```sql
-- Phân cấp nhân viên với các cấp độ
WITH emp_hierarchy AS (
    -- Quản lý cấp cao nhất (không có quản lý)
    SELECT 
        employee_id,
        first_name || ' ' || last_name AS name,
        manager_id,
        1 AS level,
        CAST(employee_id AS VARCHAR2(4000)) AS path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Phần đệ quy
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name,
        e.manager_id,
        eh.level + 1,
        eh.path || '/' || e.employee_id
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
    LPAD(' ', (level - 1) * 4) || name AS hierarchy_display,
    level,
    path
FROM emp_hierarchy
ORDER BY path;
```

### So sánh Các Hàng Trong Cùng Bảng
```sql
-- Tìm nhân viên được tuyển dụng trong cùng năm
SELECT 
    e1.employee_id AS emp1_id,
    e1.first_name || ' ' || e1.last_name AS emp1_name,
    e2.employee_id AS emp2_id,
    e2.first_name || ' ' || e2.last_name AS emp2_name,
    EXTRACT(YEAR FROM e1.hire_date) AS hire_year
FROM employees e1
JOIN employees e2 ON EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date)
WHERE e1.employee_id < e2.employee_id  -- Tránh trùng lặp
ORDER BY hire_year, e1.employee_id;
```

## Joins Nhiều Bảng

### Kịch bản Nhiều Bảng Phức tạp
```sql
-- Chi tiết nhân viên với phân cấp địa điểm đầy đủ
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    d.department_name,
    l.city,
    c.country_name,
    r.region_name,
    e.salary,
    mgr.first_name || ' ' || mgr.last_name AS manager_name
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
JOIN regions r ON c.region_id = r.region_id
LEFT JOIN employees mgr ON e.manager_id = mgr.employee_id
WHERE e.salary > 10000
ORDER BY r.region_name, c.country_name, l.city, d.department_name;
```

### Joins Có Điều kiện
```sql
-- Điều kiện join khác nhau dựa trên dữ liệu
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    oi.quantity,
    CASE 
        WHEN o.order_date >= DATE '2024-01-01' THEN p.current_price
        ELSE ph.historical_price
    END AS effective_price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN price_history ph ON p.product_id = ph.product_id 
    AND o.order_date BETWEEN ph.effective_start AND ph.effective_end
WHERE o.order_date >= DATE '2023-01-01'
ORDER BY o.order_date DESC;
```

## Anti-Joins và Semi-Joins

### Anti-Join (NOT EXISTS / NOT IN)
Anti-joins tìm các hàng trong một bảng không có hàng khớp trong bảng khác.

```sql
-- Khách hàng chưa đặt hàng (Anti-join với NOT EXISTS)
SELECT c.customer_id, c.customer_name, c.email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- Cách thay thế với LEFT JOIN
SELECT c.customer_id, c.customer_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- Sản phẩm chưa bao giờ được đặt
SELECT p.product_id, p.product_name, p.category
FROM products p
WHERE p.product_id NOT IN (
    SELECT DISTINCT oi.product_id 
    FROM order_items oi 
    WHERE oi.product_id IS NOT NULL
);
```

### Semi-Join (EXISTS / IN)
Semi-joins tìm các hàng trong một bảng có hàng khớp trong bảng khác, nhưng chỉ trả về cột từ bảng đầu tiên.

```sql
-- Khách hàng đã đặt hàng (Semi-join với EXISTS)
SELECT c.customer_id, c.customer_name, c.registration_date
FROM customers c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- Nhân viên có lịch sử công việc
SELECT e.employee_id, e.first_name, e.last_name, e.hire_date
FROM employees e
WHERE e.employee_id IN (
    SELECT jh.employee_id 
    FROM job_history jh
);
```

## Tối Ưu Hóa Join Nâng Cao

### 1. Tối Ưu Thứ Tự Join
```sql
-- Optimizer của Oracle thường xử lý điều này, nhưng hiểu biết sẽ giúp ích
-- Join bảng nhỏ trước, sau đó đến bảng lớn hơn
-- Sử dụng hint khi cần thiết (hiếm khi cần)

-- Ví dụ: Nếu departments nhỏ, employees trung bình, locations lớn
SELECT /*+ ORDERED */ 
    d.department_name,
    e.first_name,
    l.city
FROM departments d,     -- Bảng nhỏ nhất trước
     employees e,       -- Bảng trung bình thứ hai  
     locations l        -- Bảng lớn nhất cuối cùng
WHERE d.department_id = e.department_id
  AND d.location_id = l.location_id;
```

### 2. Cân nhắc Index cho Joins
```sql
-- Đảm bảo các cột join được đánh index
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_emp_manager_id ON employees(manager_id);

-- Composite indexes cho multi-column joins
CREATE INDEX idx_job_hist_emp_job ON job_history(employee_id, job_id);

-- Cân nhắc covering indexes
CREATE INDEX idx_emp_covering ON employees(department_id, employee_id, first_name, last_name, salary);
```

### 3. Sử dụng Hash Joins cho Bộ Dữ liệu Lớn
```sql
-- Hash joins hiệu quả cho bảng lớn với selectivity tốt
SELECT /*+ USE_HASH(e d) */ 
    e.employee_id,
    e.first_name,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 50000;
```

## Các Mẫu Nâng Cao Phổ Biến

### 1. Bản Ghi Mới Nhất Theo Nhóm
```sql
-- Đơn hàng mới nhất cho mỗi khách hàng
SELECT c.customer_id, c.customer_name, o.order_date, o.total_amount
FROM customers c
JOIN (
    SELECT customer_id, MAX(order_date) AS latest_order_date
    FROM orders
    GROUP BY customer_id
) latest ON c.customer_id = latest.customer_id
JOIN orders o ON latest.customer_id = o.customer_id 
    AND latest.latest_order_date = o.order_date;

-- Sử dụng window functions (thanh lịch hơn)
WITH ranked_orders AS (
    SELECT 
        o.*,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders o
)
SELECT c.customer_id, c.customer_name, ro.order_date, ro.total_amount
FROM customers c
JOIN ranked_orders ro ON c.customer_id = ro.customer_id
WHERE ro.rn = 1;
```

### 2. Thao tác giống Pivot với Joins
```sql
-- Doanh số theo quý sử dụng joins
SELECT 
    p.product_name,
    SUM(CASE WHEN EXTRACT(QUARTER FROM o.order_date) = 1 THEN oi.quantity * oi.unit_price ELSE 0 END) AS q1_sales,
    SUM(CASE WHEN EXTRACT(QUARTER FROM o.order_date) = 2 THEN oi.quantity * oi.unit_price ELSE 0 END) AS q2_sales,
    SUM(CASE WHEN EXTRACT(QUARTER FROM o.order_date) = 3 THEN oi.quantity * oi.unit_price ELSE 0 END) AS q3_sales,
    SUM(CASE WHEN EXTRACT(QUARTER FROM o.order_date) = 4 THEN oi.quantity * oi.unit_price ELSE 0 END) AS q4_sales
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= DATE '2024-01-01' OR o.order_date IS NULL
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name;
```

### 3. Joins Đệ quy (Connect By Prior)
```sql
-- Truy vấn phân cấp đặc thù của Oracle
SELECT 
    LEVEL,
    LPAD(' ', (LEVEL - 1) * 4) || first_name || ' ' || last_name AS hierarchy,
    employee_id,
    manager_id,
    job_id
FROM employees
START WITH manager_id IS NULL  -- Quản lý cấp cao nhất
CONNECT BY PRIOR employee_id = manager_id  -- Quan hệ đệ quy
ORDER SIBLINGS BY last_name;

-- Đường dẫn từ gốc
SELECT 
    LEVEL,
    SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' -> ') AS path,
    employee_id
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;
```

## Giám Sát và Điều Chỉnh Hiệu Suất

### 1. Phân Tích Execution Plan
```sql
-- Explain plan cho join phức tạp
EXPLAIN PLAN FOR
SELECT e.first_name, d.department_name, l.city
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE e.salary > 50000;

-- Xem execution plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

### 2. Thống Kê Join
```sql
-- Phân tích hiệu suất join
SELECT 
    operation,
    options,
    object_name,
    cost,
    cardinality,
    access_predicates,
    filter_predicates
FROM v$sql_plan
WHERE sql_id = '&sql_id'
ORDER BY id;
```

## Thực Hành Tốt cho Joins Nâng Cao

### 1. Khả Năng Đọc Code
- Sử dụng alias bảng có ý nghĩa
- Căn chỉnh điều kiện JOIN để dễ đọc
- Comment logic join phức tạp
- Chia nhỏ truy vấn phức tạp thành CTEs khi có thể

### 2. Hướng Dẫn Hiệu Suất
- Join trên các cột được đánh index khi có thể
- Lọc sớm trong quá trình truy vấn
- Sử dụng loại join phù hợp với nhu cầu
- Giám sát và phân tích execution plans

### 3. Khả Năng Bảo Trì
- Tránh joins quá phức tạp khi có lựa chọn đơn giản hơn
- Tài liệu hóa logic business đằng sau joins phức tạp
- Sử dụng views để đóng gói các mẫu join thường dùng
- Kiểm tra hiệu suất join với khối lượng dữ liệu thực tế

## Lỗi Phổ Biến trong Joins Nâng Cao

### 1. Tích Cartesian Không Cần Thiết
```sql
-- SAI: Thiếu điều kiện join
SELECT e.first_name, d.department_name
FROM employees e, departments d
WHERE e.salary > 50000;

-- ĐÚNG: Bao gồm điều kiện join phù hợp
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 50000;
```

### 2. Nhầm Lẫn trong Self-Join
```sql
-- SAI: Cùng alias cho self-join
SELECT e.first_name, e.first_name AS manager_name
FROM employees e
JOIN employees e ON e.manager_id = e.employee_id;

-- ĐÚNG: Alias khác nhau
SELECT e.first_name, m.first_name AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id;
```

### 3. Anti-Patterns về Hiệu Suất
```sql
-- SAI: Function trong điều kiện join
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON UPPER(e.department_name) = UPPER(d.department_name);

-- ĐÚNG: Function-based index hoặc dọn dẹp dữ liệu
CREATE INDEX idx_dept_name_upper ON departments(UPPER(department_name));
-- Hoặc khắc phục vấn đề chất lượng dữ liệu
```

## Bài Tập Thực Hành

### Bài Tập 1: Kịch bản Joins Nâng Cao
1. Tạo một CROSS JOIN để tạo ra tất cả các phân công nhân viên-dự án có thể
2. Viết một self-join để tìm nhân viên kiếm được nhiều hơn quản lý của họ
3. Sử dụng nhiều joins để tạo báo cáo nhân viên toàn diện

### Bài Tập 2: Tối Ưu Hóa Hiệu Suất
1. Phân tích execution plans cho các thứ tự join khác nhau
2. So sánh hiệu suất của EXISTS vs IN vs JOIN cho cùng một truy vấn logic
3. Tối ưu hóa một truy vấn join nhiều bảng chậm

### Bài Tập 3: Logic Business Phức Tạp
1. Tạo báo cáo nhân viên phân cấp hiển thị cấu trúc tổ chức
2. Tìm khoảng trống trong dữ liệu tuần tự sử dụng self-joins
3. Thực hiện thao tác giống pivot chỉ sử dụng joins

## Tóm Tắt

Joins nâng cao cho phép:
- Quan hệ dữ liệu và phân cấp phức tạp
- Báo cáo và phân tích tinh vi
- Tối ưu hóa hiệu suất cho bộ dữ liệu lớn
- Giải pháp thanh lịch cho các vấn đề business phức tạp

Các khái niệm chính:
- **CROSS JOIN**: Tất cả kết hợp (sử dụng cẩn thận!)
- **Self-joins**: Dữ liệu phân cấp và so sánh hàng
- **Anti-joins**: Tìm bản ghi không khớp
- **Semi-joins**: Kiểm tra sự tồn tại
- **Multiple joins**: Kịch bản business phức tạp
- **Hiệu suất**: Sử dụng index, execution plans, tối ưu hóa

Thành thạo các kỹ thuật join nâng cao này để xử lý các yêu cầu dữ liệu phức tạp một cách hiệu quả và thanh lịch.
