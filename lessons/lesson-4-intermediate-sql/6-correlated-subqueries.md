# Correlated Subqueries trong Oracle Database

## Mục Tiêu Học Tập
Sau khi hoàn thành phần này, bạn sẽ hiểu được:
- Correlated subqueries là gì và chúng khác với regular subqueries như thế nào
- Khi nào sử dụng correlated subqueries hiệu quả
- Tác động hiệu suất và chiến lược tối ưu hóa
- Các mẫu nâng cao sử dụng correlated subqueries
- Các lựa chọn thay thế cho correlated subqueries

## Giới Thiệu về Correlated Subqueries

Correlated subquery là một subquery tham chiếu đến các cột từ truy vấn ngoài (chính). Không giống như regular subqueries thực thi một lần và trả về một tập kết quả, correlated subqueries thực thi một lần cho mỗi hàng của truy vấn ngoài, làm cho chúng mạnh mẽ hơn nhưng có thể kém hiệu quả hơn.

### Cấu Trúc Cơ Bản
```sql
SELECT outer_table.column1, outer_table.column2
FROM outer_table
WHERE outer_table.column3 operator (
    SELECT inner_table.column1
    FROM inner_table
    WHERE inner_table.column2 = outer_table.column2  -- Tương quan
);
```

### Đặc Điểm Chính
- Tham chiếu các cột truy vấn ngoài
- Thực thi cho mỗi hàng của truy vấn ngoài
- Không thể được thực thi độc lập
- Thường được sử dụng với EXISTS, NOT EXISTS
- Hữu ích cho so sánh từng hàng

## Ví Dụ Correlated Subquery Cơ Bản

### 1. So Sánh Lương Nhân Viên
```sql
-- Tìm nhân viên kiếm được nhiều hơn mức trung bình trong department của họ
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id  -- Tương quan với truy vấn ngoài
);
```

### 2. Bản Ghi Mới Nhất Theo Nhóm
```sql
-- Tìm thay đổi công việc gần nhất của mỗi nhân viên
SELECT 
    jh.employee_id,
    jh.start_date,
    jh.end_date,
    jh.job_id,
    jh.department_id
FROM job_history jh
WHERE jh.start_date = (
    SELECT MAX(start_date)
    FROM job_history jh2
    WHERE jh2.employee_id = jh.employee_id  -- Tương quan
);
```

### 3. Kiểm Tra Sự Tồn Tại
```sql
-- Tìm nhân viên có bản ghi lịch sử công việc
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id  -- Tương quan
);
```

## Các Mẫu Correlated Subquery Nâng Cao

### 1. Tính Toán Running
```sql
-- Tính tổng cộng dồn của lương theo ngày thuê
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    e.salary,
    (SELECT SUM(e2.salary)
     FROM employees e2
     WHERE e2.hire_date <= e.hire_date) AS running_total_salary
FROM employees e
ORDER BY e.hire_date;

-- Đếm running các nhân viên được thuê trước mỗi nhân viên
SELECT 
    e.employee_id,
    e.first_name,
    e.hire_date,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.hire_date < e.hire_date) AS employees_hired_before
FROM employees e
ORDER BY e.hire_date;
```

### 2. Xếp Hạng và Top-N
```sql
-- Tìm top 3 nhân viên có lương cao nhất trong mỗi department
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.department_id = e.department_id
    AND e2.salary > e.salary
) < 3
ORDER BY e.department_id, e.salary DESC;

-- Cách thay thế: Tìm nhân viên có lương trong top 3 của department họ
SELECT 
    e.employee_id,
    e.first_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary IN (
    SELECT DISTINCT salary
    FROM (
        SELECT salary
        FROM employees e2
        WHERE e2.department_id = e.department_id
        ORDER BY salary DESC
    )
    WHERE rownum <= 3
);
```

### 3. Chất Lượng Dữ Liệu và Xác Thực
```sql
-- Tìm nhân viên có lương cao hơn quản lý của họ
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.manager_id
FROM employees e
WHERE e.salary > (
    SELECT m.salary
    FROM employees m
    WHERE m.employee_id = e.manager_id  -- Tương quan
)
AND e.manager_id IS NOT NULL;

-- Tìm departments mà tất cả nhân viên kiếm được hơn 5000
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id  -- Tương quan
    AND e.salary <= 5000
)
AND EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id  -- Ít nhất một nhân viên
);
```

### 4. Phân Tích Dữ Liệu Tuần Tự
```sql
-- Tìm nhân viên được thuê ngay sau khi nhân viên khác rời đi
SELECT 
    e.employee_id,
    e.first_name,
    e.hire_date,
    e.department_id
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.department_id = e.department_id  -- Cùng department
    AND jh.end_date = e.hire_date - 1  -- Được thuê ngày sau khi ai đó rời đi
);

-- Tìm khoảng trống trong chuỗi employee ID
SELECT 
    e1.employee_id AS current_id,
    e1.employee_id + 1 AS missing_id
FROM employees e1
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.employee_id = e1.employee_id + 1  -- ID tiếp theo không tồn tại
)
AND e1.employee_id < (SELECT MAX(employee_id) FROM employees)
ORDER BY e1.employee_id;
```

## Kịch Bản Business Phức Tạp

### 1. Phân Tích Khách Hàng
```sql
-- Find customers whose last order was more than 6 months ago
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    (SELECT MAX(o.order_date)
     FROM orders o
     WHERE o.customer_id = c.customer_id) AS last_order_date
FROM customers c
WHERE (
    SELECT MAX(o.order_date)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) < SYSDATE - 180
OR NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Find customers who have ordered every product in a category
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    -- Find products in category 'Electronics' not ordered by this customer
    SELECT 1
    FROM products p
    WHERE p.category = 'Electronics'
    AND NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = c.customer_id
        AND oi.product_id = p.product_id
    )
);
```

### 2. Inventory and Sales Analysis
```sql
-- Find products with declining sales trend (last 3 months vs previous 3)
SELECT 
    p.product_id,
    p.product_name,
    (SELECT NVL(SUM(oi.quantity), 0)
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.order_id
     WHERE oi.product_id = p.product_id
     AND o.order_date >= SYSDATE - 90) AS recent_sales,
    (SELECT NVL(SUM(oi.quantity), 0)
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.order_id
     WHERE oi.product_id = p.product_id
     AND o.order_date BETWEEN SYSDATE - 180 AND SYSDATE - 91) AS previous_sales
FROM products p
WHERE (
    SELECT NVL(SUM(oi.quantity), 0)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date >= SYSDATE - 90
) < (
    SELECT NVL(SUM(oi.quantity), 0)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date BETWEEN SYSDATE - 180 AND SYSDATE - 91
)
ORDER BY recent_sales;
```

### 3. Hierarchical Data Processing
```sql
-- Find managers who have more direct reports than their own manager
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS manager_name,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.manager_id = e.employee_id) AS direct_reports,
    (SELECT COUNT(*)
     FROM employees e3
     WHERE e3.manager_id = (
         SELECT manager_id FROM employees WHERE employee_id = e.employee_id
     )) AS peer_count
FROM employees e
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.manager_id = e.employee_id
) > (
    SELECT COUNT(*)
    FROM employees e3
    WHERE e3.manager_id = (
        SELECT manager_id FROM employees WHERE employee_id = e.employee_id
    )
)
AND e.manager_id IS NOT NULL;
```

## Cân Nhắc Hiệu Suất

### 1. Hiểu Về Thực Thi
```sql
-- Correlated subquery thực thi cho mỗi hàng ngoài
-- Truy vấn này có thể thực thi subquery 107 lần (một lần cho mỗi nhân viên)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- Cách tiếp cận tốt hơn sử dụng window functions
SELECT employee_id, first_name, salary
FROM (
    SELECT 
        employee_id,
        first_name,
        salary,
        AVG(salary) OVER (PARTITION BY department_id) AS dept_avg_salary
    FROM employees
)
WHERE salary > dept_avg_salary;
```

### 2. Index Optimization
```sql
-- Ensure correlated columns are indexed
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_jobhist_emp_id ON job_history(employee_id);
CREATE INDEX idx_orders_cust_id ON orders(customer_id);

-- Composite indexes for multiple correlations
CREATE INDEX idx_emp_dept_mgr ON employees(department_id, manager_id);
```

### 3. Avoiding Repeated Calculations
```sql
-- INEFFICIENT: Multiple correlated subqueries
SELECT 
    e.employee_id,
    e.first_name,
    (SELECT AVG(salary) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_avg,
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_count
FROM employees e;

-- EFFICIENT: Single join with aggregation
SELECT 
    e.employee_id,
    e.first_name,
    ds.dept_avg,
    ds.dept_count
FROM employees e
JOIN (
    SELECT 
        department_id,
        AVG(salary) AS dept_avg,
        COUNT(*) AS dept_count
    FROM employees
    GROUP BY department_id
) ds ON e.department_id = ds.department_id;
```

## Alternative Approaches

### 1. Window Functions vs Correlated Subqueries
```sql
-- Correlated subquery approach
SELECT 
    e.employee_id,
    e.salary,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.department_id = e.department_id
     AND e2.salary > e.salary) + 1 AS salary_rank
FROM employees e;

-- Window function approach (more efficient)
SELECT 
    employee_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees;
```

### 2. Common Table Expressions (CTEs)
```sql
-- Complex correlated subquery
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- CTE approach (clearer, potentially more efficient)
WITH dept_averages AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
JOIN dept_averages da ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary;
```

### 3. EXISTS vs IN Performance
```sql
-- EXISTS (usually more efficient for correlated scenarios)
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= SYSDATE - 365
);

-- IN (processes all values, less efficient for large datasets)
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= SYSDATE - 365
);
```

## Debugging and Troubleshooting

### 1. Testing Correlated Logic
```sql
-- Test the correlation logic separately
-- First, test outer query
SELECT employee_id, first_name, salary, department_id
FROM employees
WHERE employee_id = 100;

-- Then test inner query with specific correlation value
SELECT AVG(salary)
FROM employees
WHERE department_id = 90;  -- Use actual department_id from above

-- Finally, combine
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.employee_id = 100
AND e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

### 2. Performance Analysis
```sql
-- Check execution plan
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- View the plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Look for:
-- - Nested loops (common with correlated subqueries)
-- - Index usage on correlation columns
-- - Filter operations
```

### 3. Common Issues and Solutions
```sql
-- Issue: Subquery returns no rows (NULL comparison)
-- Problem query
SELECT e.employee_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = 999  -- Non-existent department
);

-- Solution: Handle NULL case
SELECT e.employee_id
FROM employees e
WHERE e.salary > NVL((
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
), 0);
```

## Best Practices

### 1. Code Organization
```sql
-- Format correlated subqueries for readability
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id  -- Clear correlation
      AND e2.hire_date <= e.hire_date         -- Additional conditions
);
```

### 2. Performance Guidelines
- Use indexes on correlated columns
- Consider window functions for aggregations
- Test with realistic data volumes
- Monitor execution plans
- Consider materializing complex subqueries

### 3. When to Use Correlated Subqueries
**Good Use Cases:**
- Row-by-row comparisons
- Existence checking
- Finding latest/earliest records per group
- Complex conditional logic

**Consider Alternatives When:**
- Simple aggregations (use window functions)
- Large result sets (consider joins)
- Multiple correlations (use CTEs)
- Performance is critical

## Bài Tập Thực Hành

### Bài Tập 1: Tương Quan Cơ Bản
1. Tìm nhân viên kiếm được nhiều hơn mức lương median trong category công việc của họ
2. Liệt kê khách hàng chưa đặt hàng trong 6 tháng qua
3. Tìm sản phẩm được đặt hàng nhiều hơn mức trung bình cho category của chúng

### Bài Tập 2: Kịch Bản Nâng Cao
1. Xác định nhân viên có lương hiện tại thấp hơn mức tối đa lịch sử của họ
2. Tìm departments mà quản lý kiếm được ít hơn mức trung bình department
3. Liệt kê sản phẩm có doanh số tăng đều đặn hàng tháng trong năm qua

### Bài Tập 3: Tối Ưu Hóa Hiệu Suất
1. Chuyển đổi correlated subquery chậm để sử dụng window functions
2. Tối ưu hóa multiple-correlation subquery sử dụng CTEs
3. So sánh execution plans cho các cách tiếp cận khác nhau cho cùng một vấn đề

## Tóm Tắt Các Mẫu Phổ Biến

| Mẫu | Trường hợp sử dụng | Ví dụ |
|---------|----------|---------|
| EXISTS | Kiểm tra sự tồn tại | Tìm khách hàng có đơn hàng |
| NOT EXISTS | Anti-join | Tìm khách hàng không có đơn hàng |
| Scalar correlation | So sánh giá trị | Lương > trung bình department |
| Aggregation correlation | Thống kê nhóm | Đếm theo category |
| Sequential comparison | Phân tích theo thời gian | Bản ghi mới nhất theo nhóm |
| Ranking correlation | Top-N theo nhóm | Top 3 nhân viên mỗi department |

## Tóm Tắt

Correlated subqueries cung cấp khả năng mạnh mẽ cho:
- Xử lý và so sánh từng hàng
- Logic điều kiện phức tạp
- Kiểm tra sự tồn tại và không tồn tại
- Phân tích dữ liệu phân cấp và tuần tự

Các cân nhắc chính:
- **Hiệu suất**: Thực thi một lần cho mỗi hàng ngoài
- **Indexing**: Quan trọng cho các cột tương quan
- **Lựa chọn thay thế**: Window functions, CTEs, joins
- **Debugging**: Kiểm tra logic tương quan riêng biệt
- **Khả năng đọc**: Format rõ ràng với thụt lề phù hợp

Chọn correlated subqueries khi:
- Logic yêu cầu đánh giá từng hàng
- Cần ngữ nghĩa EXISTS/NOT EXISTS
- Các cách tiếp cận thay thế phức tạp hơn
- Hiệu suất chấp nhận được với khối lượng dữ liệu

Điều này hoàn thành phạm vi toàn diện của chúng ta về subqueries. Tiếp theo, chúng ta sẽ chuyển sang các kỹ thuật SQL nâng cao bao gồm stored procedures, functions và triggers.
