# Views và Materialized Views

Views là một trong những khái niệm quan trọng nhất trong thiết kế cơ sở dữ liệu, cung cấp trừu tượng hóa dữ liệu, bảo mật và truy cập đơn giản đến các truy vấn phức tạp. Materialized views đưa khái niệm này đi xa hơn bằng cách lưu trữ vật lý kết quả truy vấn để cải thiện hiệu suất.

## 🎯 Mục Tiêu Học Tập

Sau khi hoàn thành phần này, bạn sẽ hiểu được:

1. **Cơ bản về View**: View là gì và tại sao chúng quan trọng
2. **Tạo và Quản lý View**: Tạo, sửa đổi và xóa views
3. **Các loại View**: Simple views vs complex views
4. **Materialized Views**: Lợi ích hiệu suất và trường hợp sử dụng
5. **Bảo mật View**: Sử dụng views để kiểm soát truy cập dữ liệu
6. **Cân nhắc Hiệu suất**: Khi nào và cách sử dụng views hiệu quả

## 📖 Mục Lục

1. [Hiểu về Views](#understanding-views)
2. [Tạo Simple Views](#creating-simple-views)
3. [Complex Views](#complex-views)
4. [Updatable Views](#updatable-views)
5. [Materialized Views](#materialized-views)
6. [Bảo mật View](#view-security)
7. [Cân nhắc Hiệu suất](#performance-considerations)
8. [Thực hành Tốt](#best-practices)

---

## Hiểu về Views

### View là gì?

**View** là một bảng ảo dựa trên tập kết quả của câu lệnh SELECT. Views không lưu trữ dữ liệu; chúng truy xuất dữ liệu động từ các bảng cơ sở khi được truy vấn.

**Đặc điểm Chính:**
- **Bảng Ảo**: Không lưu trữ vật lý dữ liệu
- **Động**: Luôn hiển thị dữ liệu hiện tại từ bảng cơ sở
- **Truy cập Đơn giản**: Ẩn các truy vấn phức tạp đằng sau giao diện đơn giản
- **Lớp Bảo mật**: Kiểm soát truy cập đến dữ liệu nhạy cảm
- **Trừu tượng hóa Dữ liệu**: Trình bày dữ liệu ở các định dạng khác nhau

### Các loại Views

#### 1. Simple Views
- Dựa trên một bảng đơn
- Không có functions hoặc tính toán
- Thường có thể update

#### 2. Complex Views
- Dựa trên nhiều bảng
- Có thể bao gồm JOINs, functions, GROUP BY
- Thường chỉ đọc

#### 3. Materialized Views
- Lưu trữ vật lý kết quả truy vấn
- Refresh định kỳ hoặc theo yêu cầu
- Lợi ích hiệu suất đáng kể

### Lợi ích của việc Sử dụng Views

#### **Bảo mật Dữ liệu**
```sql
-- Ẩn thông tin lương nhạy cảm
CREATE VIEW employee_public_info AS
SELECT employee_id, first_name, last_name, email, hire_date, department_id
FROM employees;
-- Cột salary không được hiển thị
```

#### **Đơn giản hóa Truy vấn**
```sql
-- Truy vấn phức tạp được đơn giản hóa thành view
CREATE VIEW employee_department_summary AS
SELECT 
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    MIN(e.hire_date) as oldest_hire_date
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- Bây giờ người dùng có thể truy vấn đơn giản:
SELECT * FROM employee_department_summary;
```

#### **Trừu tượng hóa Dữ liệu**
```sql
-- Trình bày dữ liệu ở định dạng thân thiện với business
CREATE VIEW sales_summary AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
    COUNT(o.order_id) as total_orders,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    COUNT(DISTINCT o.customer_id) as unique_customers
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY sales_month;
```

---

## Tạo Simple Views

### Cú pháp Cơ bản

```sql
CREATE [OR REPLACE] VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
[WITH CHECK OPTION]
[WITH READ ONLY];
```

### Simple View Examples

#### Example 1: Basic Employee View
```sql
-- Create a simple view showing active employees
CREATE OR REPLACE VIEW active_employees AS
SELECT employee_id, first_name, last_name, email, hire_date, department_id
FROM employees
WHERE hire_date <= SYSDATE;

-- Query the view
SELECT * FROM active_employees WHERE department_id = 20;
```

#### Example 2: Filtered Product View
```sql
-- View showing only products in stock
CREATE OR REPLACE VIEW products_in_stock AS
SELECT product_id, product_name, category_id, unit_price
FROM sales.products
WHERE units_in_stock > 0
WITH READ ONLY;
```

#### Example 3: Renamed Column View
```sql
-- View with user-friendly column names
CREATE OR REPLACE VIEW customer_list AS
SELECT 
    customer_id as "Customer ID",
    customer_name as "Customer Name", 
    city as "City",
    country as "Country",
    phone as "Phone Number"
FROM sales.customers
ORDER BY customer_name;
```

### Siêu dữ liệu View

```sql
-- Kiểm tra định nghĩa view
SELECT text FROM user_views WHERE view_name = 'ACTIVE_EMPLOYEES';

-- Liệt kê tất cả views thuộc sở hữu của user hiện tại
SELECT view_name, text FROM user_views ORDER BY view_name;

-- Kiểm tra các cột của view
SELECT column_name, data_type, nullable 
FROM user_tab_columns 
WHERE table_name = 'ACTIVE_EMPLOYEES';
```

---

## Complex Views

Complex views bao gồm nhiều bảng, functions và các tính năng SQL nâng cao.

### Views Nhiều Bảng

#### Ví dụ 1: View Chi tiết Nhân viên
```sql
CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.hire_date,
    e.salary,
    d.department_name,
    l.city || ', ' || l.country as location,
    j.job_title,
    m.first_name || ' ' || m.last_name as manager_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

#### Ví dụ 2: View Phân tích Bán hàng
```sql
CREATE OR REPLACE VIEW sales_analysis AS
SELECT 
    c.customer_name,
    c.city,
    c.country,
    COUNT(o.order_id) as total_orders,
    MIN(o.order_date) as first_order,
    MAX(o.order_date) as last_order,
    SUM(oi.quantity * oi.unit_price) as total_spent,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) as avg_order_value,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as customer_rank
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, c.country;
```

### Views với Tính toán

#### Ví dụ 3: Chỉ số Hiệu suất Nhân viên
```sql
CREATE OR REPLACE VIEW employee_performance AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.hire_date,
    MONTHS_BETWEEN(SYSDATE, e.hire_date) as tenure_months,
    e.salary,
    CASE 
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) < 12 THEN 'New Employee'
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) < 60 THEN 'Experienced'
        ELSE 'Veteran'
    END as experience_level,
    ROUND((e.salary / dept_avg.avg_salary) * 100, 2) as salary_vs_dept_avg,
    CASE 
        WHEN e.commission_pct IS NOT NULL THEN 'Commission'
        ELSE 'Salary Only'
    END as compensation_type
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id;
```

### Views Phân cấp

#### Ví dụ 4: Cơ cấu Tổ chức
```sql
CREATE OR REPLACE VIEW org_hierarchy AS
```sql
CREATE OR REPLACE VIEW org_hierarchy AS
SELECT 
    employee_id,
    first_name || ' ' || last_name as employee_name,
    manager_id,
    LEVEL as hierarchy_level,
    SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' -> ') as hierarchy_path,
    CONNECT_BY_ROOT (first_name || ' ' || last_name) as top_manager
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name, first_name;
```

---

## Updatable Views

Không phải tất cả views đều có thể cập nhật. Oracle có các quy tắc cụ thể về khi nào một view có thể cập nhật được.

### Quy tắc cho Updatable Views

Một view có thể cập nhật được nếu:
1. **Bảng Đơn**: Dựa trên một bảng duy nhất
2. **Không có Hàm Tổng hợp**: Không có GROUP BY, HAVING, DISTINCT
3. **Không có Phép Toán Tập hợp**: Không có UNION, INTERSECT, MINUS
4. **Không có Subqueries**: Trong mệnh đề SELECT hoặc WHERE
5. **Tất cả Cột Bắt buộc**: Tất cả cột NOT NULL đều được bao gồm

### Ví dụ: View Nhân viên có thể Cập nhật

```sql
-- Tạo một view có thể cập nhật
CREATE OR REPLACE VIEW dept_20_employees AS
SELECT employee_id, first_name, last_name, email, salary, department_id
FROM employees
WHERE department_id = 20
WITH CHECK OPTION;

-- Điều này sẽ hoạt động - INSERT
INSERT INTO dept_20_employees 
VALUES (999, 'John', 'Doe', 'jdoe@company.com', 5000, 20);

-- Điều này sẽ hoạt động - UPDATE
UPDATE dept_20_employees 
SET salary = 5500 
WHERE employee_id = 999;

-- Điều này sẽ thất bại do CHECK OPTION
UPDATE dept_20_employees 
SET department_id = 30 
WHERE employee_id = 999;
-- Lỗi: view WITH CHECK OPTION where-clause violation

-- Điều này sẽ hoạt động - DELETE
DELETE FROM dept_20_employees WHERE employee_id = 999;
```

### WITH CHECK OPTION

Đảm bảo rằng các thao tác INSERT và UPDATE thỏa mãn mệnh đề WHERE của view:

```sql
CREATE OR REPLACE VIEW high_salary_employees AS
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees
WHERE salary > 10000
WITH CHECK OPTION;

-- Điều này sẽ thất bại
INSERT INTO high_salary_employees 
VALUES (998, 'Jane', 'Smith', 8000, 20);
-- Lỗi: CHECK OPTION constraint violated
```

### INSTEAD OF Triggers cho Complex Views

Đối với các complex views không thể cập nhật một cách tự nhiên:

```sql
-- Tạo một complex view
CREATE OR REPLACE VIEW employee_department_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Tạo INSTEAD OF trigger cho updates
CREATE OR REPLACE TRIGGER employee_dept_update_trigger
INSTEAD OF UPDATE ON employee_department_view
FOR EACH ROW
BEGIN
    UPDATE employees
    SET first_name = :NEW.first_name,
        last_name = :NEW.last_name,
        salary = :NEW.salary
    WHERE employee_id = :NEW.employee_id;
END;
```

---

## Materialized Views

Materialized views lưu trữ vật lý tập kết quả, cung cấp lợi ích hiệu suất đáng kể cho các truy vấn phức tạp.

### Tạo Materialized Views

#### Cú pháp Cơ bản
```sql
CREATE MATERIALIZED VIEW mv_name
[BUILD IMMEDIATE | BUILD DEFERRED]
[REFRESH FAST | COMPLETE | FORCE]
[ON DEMAND | ON COMMIT]
[ENABLE | DISABLE QUERY REWRITE]
AS
SELECT ...;
```

#### Ví dụ 1: Materialized View Cơ bản
```sql
-- Tạo materialized view cho tóm tắt doanh số hàng tháng
CREATE MATERIALIZED VIEW mv_monthly_sales
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
    COUNT(o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.quantity * oi.unit_price) as avg_order_value
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM');

-- Truy vấn materialized view (rất nhanh)
SELECT * FROM mv_monthly_sales ORDER BY sales_month;
```

#### Ví dụ 2: Materialized View Hiệu suất Sản phẩm
```sql
CREATE MATERIALIZED VIEW mv_product_performance
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    COUNT(oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    MAX(o.order_date) as last_order_date
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category_id;
```

### Tùy chọn Refresh

#### ON DEMAND Refresh
```sql
-- Refresh thủ công
EXEC DBMS_MVIEW.REFRESH('MV_MONTHLY_SALES', 'C');

-- Refresh nhiều materialized views
EXEC DBMS_MVIEW.REFRESH_ALL_MVIEWS();
```

#### ON COMMIT Refresh (cho fast refresh)
```sql
-- Tạo materialized view log cho fast refresh
CREATE MATERIALIZED VIEW LOG ON sales.orders;
CREATE MATERIALIZED VIEW LOG ON sales.order_items;

-- Tạo fast refresh materialized view
CREATE MATERIALIZED VIEW mv_daily_sales
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT 
    TRUNC(o.order_date) as order_date,
    COUNT(*) as order_count,
    SUM(oi.quantity * oi.unit_price) as daily_revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TRUNC(o.order_date);
```

### Quản lý Materialized View

```sql
-- Kiểm tra trạng thái materialized view
SELECT mview_name, refresh_mode, refresh_method, last_refresh_date
FROM user_mviews;

-- Kiểm tra lịch sử refresh
SELECT mview_name, refresh_date, refresh_method 
FROM user_mview_refresh_times
ORDER BY refresh_date DESC;

-- Xóa materialized view
DROP MATERIALIZED VIEW mv_monthly_sales;
```

---

## Bảo mật View

Views là công cụ mạnh mẽ để triển khai bảo mật cơ sở dữ liệu bằng cách kiểm soát truy cập dữ liệu.

### Bảo mật Cấp Cột

```sql
-- Ẩn dữ liệu nhạy cảm của nhân viên
CREATE OR REPLACE VIEW employee_public AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    hire_date,
    department_id
    -- salary, ssn và các trường nhạy cảm khác được loại trừ
FROM employees;

-- Cấp quyền truy cập vào view thay vì bảng
GRANT SELECT ON employee_public TO hr_users;
```

### Bảo mật Cấp Hàng

```sql
-- Quản lý phòng ban chỉ có thể xem nhân viên của phòng ban họ
CREATE OR REPLACE VIEW manager_employee_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.department_id = (
    SELECT department_id 
    FROM employees 
    WHERE employee_id = USER  -- Giả sử USER chứa employee_id
    AND job_id LIKE '%MANAGER%'
);
```

### Bảo mật Application Context

```sql
-- Sử dụng application context cho bảo mật động
CREATE OR REPLACE VIEW secure_employee_view AS
SELECT 
    employee_id,
    first_name,
    last_name,
    CASE 
        WHEN SYS_CONTEXT('HR_CONTEXT', 'ROLE') = 'MANAGER' THEN salary
        ELSE NULL
    END as salary,
    department_id
FROM employees;
```

---

## Cân nhắc Hiệu suất

### Khi nào Sử dụng Views

#### **Trường hợp Sử dụng Tốt:**
- **Truy vấn Phức tạp Thường xuyên**: Tiết kiệm thời gian phát triển
- **Bảo mật Dữ liệu**: Kiểm soát truy cập thông tin nhạy cảm  
- **Trừu tượng hóa Dữ liệu**: Ẩn độ phức tạp khỏi người dùng cuối
- **Chuẩn hóa**: Đảm bảo logic business nhất quán

#### **Cân nhắc Hiệu suất:**
- **Simple Views**: Tác động hiệu suất tối thiểu
- **Complex Views**: Có thể ảnh hưởng hiệu suất, cân nhắc materialized views
- **Nested Views**: Tránh views dựa trên views khác (giết hiệu suất)

### Mẹo Hiệu suất View

#### 1. Sử dụng Indexes trên Base Tables
```sql
-- Đảm bảo base tables có indexes phù hợp
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date);
```

#### 2. Tránh SELECT *
```sql
-- XẤU: Sử dụng tất cả các cột
CREATE VIEW all_employee_data AS
SELECT * FROM employees e JOIN departments d ON e.department_id = d.department_id;

-- TỐT: Chỉ các cột cần thiết
CREATE VIEW employee_summary AS
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e JOIN departments d ON e.department_id = d.department_id;
```

#### 3. Cân nhặc Materialized Views cho Aggregations Nặng
```sql
-- Aggregation nặng - ứng cử viên tốt cho materialized view
CREATE MATERIALIZED VIEW sales_summary_mv AS
SELECT 
    p.category_id,
    EXTRACT(YEAR FROM o.order_date) as sales_year,
    EXTRACT(MONTH FROM o.order_date) as sales_month,
    COUNT(DISTINCT o.customer_id) as customers,
    SUM(oi.quantity * oi.unit_price) as revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id  
JOIN sales.products p ON oi.product_id = p.product_id
GROUP BY p.category_id, EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date);
```

---

## Thực hành Tốt

### 1. Quy ước Đặt tên

```sql
-- Sử dụng tên rõ ràng, mô tả
CREATE VIEW vw_employee_department_summary AS ...     -- Tốt
CREATE VIEW emp_dept AS ...                           -- Kém

-- Tiền tố materialized views
CREATE MATERIALIZED VIEW mv_monthly_sales AS ...      -- Tốt
CREATE MATERIALIZED VIEW monthly_sales AS ...         -- Không rõ ràng
```

### 2. Tài liệu

```sql
-- Tài liệu hóa complex views với comments
CREATE OR REPLACE VIEW employee_performance_metrics AS
-- Mục đích: Cung cấp phân tích hiệu suất nhân viên toàn diện
-- Tạo: 2025-01-15
-- Tác giả: HR Analytics Team
-- Phụ thuộc: employees, departments, jobs tables
-- Refresh: Thời gian thực (regular view)
-- Ghi chú: Bao gồm tính toán thâm niên và xếp hạng lương
SELECT 
    e.employee_id,
    -- ... phần còn lại của truy vấn
```

### 3. Xử lý Lỗi

```sql
-- Xử lý các giá trị NULL tiềm ẩn
CREATE OR REPLACE VIEW safe_employee_metrics AS
SELECT 
    employee_id,
    COALESCE(salary, 0) as salary,
    COALESCE(commission_pct, 0) as commission_pct,
    ROUND(COALESCE(salary, 0) * (1 + COALESCE(commission_pct, 0)), 2) as total_compensation
FROM employees;
```

### 4. Kiểm tra và Xác thực

```sql
-- Kiểm tra hiệu suất view
EXPLAIN PLAN FOR SELECT * FROM employee_department_summary;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Xác thực kết quả view
SELECT COUNT(*) FROM employee_department_summary;  -- Nên khớp với kỳ vọng
SELECT MAX(salary), MIN(salary) FROM employee_department_summary;  -- Kiểm tra phạm vi
```

### 5. Bảo trì

```sql
-- Nhiệm vụ bảo trì thường xuyên
-- 1. Giám sát việc sử dụng view
SELECT view_name, num_rows FROM user_tables WHERE table_name LIKE 'VW_%';

-- 2. Cập nhật materialized views
EXEC DBMS_MVIEW.REFRESH_ALL_MVIEWS();

-- 3. Kiểm tra views không hợp lệ
SELECT object_name, status FROM user_objects WHERE object_type = 'VIEW' AND status = 'INVALID';

-- 4. Biên dịch lại views không hợp lệ
ALTER VIEW invalid_view_name COMPILE;
```

---

## Tóm Tắt

Views và materialized views là công cụ thiết yếu cho:

- **Bảo mật Dữ liệu**: Kiểm soát truy cập đến thông tin nhạy cảm
- **Đơn giản hóa Truy vấn**: Ẩn logic phức tạp đằng sau giao diện đơn giản  
- **Tối ưu hóa Hiệu suất**: Tính toán trước các aggregations phức tạp
- **Trừu tượng hóa Dữ liệu**: Trình bày dữ liệu ở định dạng thân thiện với business
- **Chuẩn hóa**: Đảm bảo logic business nhất quán trên các ứng dụng

### Điểm Chính:

1. **Regular Views**: Bảng ảo, không lưu trữ, dữ liệu thời gian thực
2. **Materialized Views**: Lưu trữ vật lý, refresh định kỳ, hiệu suất cao
3. **Bảo mật**: Views cung cấp bảo mật tuyệt vời ở cấp cột và hàng
4. **Hiệu suất**: Cân nhắc materialized views cho aggregations phức tạp
5. **Bảo trì**: Giám sát thường xuyên và chiến lược refresh là cần thiết

### Bước Tiếp Theo:

- Thực hành tạo views cho yêu cầu business cụ thể của bạn
- Thử nghiệm với các chiến lược refresh materialized view
- Triển khai bảo mật dựa trên view trong ứng dụng của bạn
- Giám sát và tối ưu hóa hiệu suất view

**File Thực hành**: Làm việc qua `src/advanced/views-materialized-views.sql` cho các ví dụ và bài tập thực hành.
