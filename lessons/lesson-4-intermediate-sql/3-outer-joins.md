# Outer Joins trong Oracle Database

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

## Common Mistakes to Avoid

### 1. Confusing Left and Right Joins
```sql
-- WRONG: Trying to get all departments with employee info
SELECT d.department_name, e.first_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- CORRECT: All departments with optional employee info
SELECT d.department_name, e.first_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;
```

### 2. Incorrect NULL Filtering
```sql
-- WRONG: This defeats the purpose of outer join
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name IS NOT NULL;

-- CORRECT: Use inner join if you don't want NULLs
SELECT e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

### 3. Mixing Traditional and ANSI Syntax
```sql
-- WRONG: Don't mix syntaxes
SELECT e.first_name, d.department_name, l.city
FROM employees e, departments d
LEFT JOIN locations l ON d.location_id = l.location_id
WHERE e.department_id = d.department_id(+);

-- CORRECT: Use consistent ANSI syntax
SELECT e.first_name, d.department_name, l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id;
```

## Practice Exercises

### Exercise 1: Basic Outer Joins
Write queries to:
1. List all employees with their department names (include employees without departments)
2. List all departments with employee count (include empty departments)
3. Find employees who are not assigned to any department

### Exercise 2: Complex Scenarios
Write queries to:
1. Show all products and their total sales (include products never sold)
2. List all customers and their most recent order date (include customers without orders)
3. Generate a report showing all departments, their managers, and employee counts

### Exercise 3: Performance Analysis
1. Compare execution plans for equivalent inner joins vs outer joins
2. Optimize a slow outer join query
3. Rewrite an outer join using EXISTS/NOT EXISTS

## Next Steps

In the next section, we'll explore:
- Advanced join techniques (CROSS JOIN, NATURAL JOIN)
- Self-joins and hierarchical queries
- Multiple table joins with complex conditions
- Join optimization strategies

## Summary

Outer joins are essential for:
- Including all records from one or both tables
- Finding missing or unmatched data
- Generating comprehensive reports
- Data analysis and reconciliation

Key takeaways:
- LEFT JOIN: All records from left table
- RIGHT JOIN: All records from right table  
- FULL OUTER JOIN: All records from both tables
- Handle NULLs appropriately with NVL, COALESCE, or CASE
- Use ANSI SQL syntax for better readability and portability
- Consider performance implications and optimize accordingly
