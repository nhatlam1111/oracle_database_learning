# Hàm Tổng Hợp - Tóm Tắt Dữ Liệu

Hàm tổng hợp thực hiện các phép tính trên nhóm hàng và trả về một kết quả duy nhất. Chúng rất quan trọng cho việc phân tích dữ liệu, báo cáo và tính toán thống kê.

## Tổng Quan Về Hàm Tổng Hợp

Hàm tổng hợp hoạt động trên tập hợp các hàng và trả về một giá trị duy nhất. Chúng thường được sử dụng với GROUP BY để tạo báo cáo tóm tắt.

### Hàm Tổng Hợp Phổ Biến:
- **COUNT()** - Đếm hàng hoặc giá trị không NULL
- **SUM()** - Tính tổng các giá trị số
- **AVG()** - Tính trung bình các giá trị số
- **MIN()** - Tìm giá trị nhỏ nhất
- **MAX()** - Tìm giá trị lớn nhất
- **STDDEV()** - Tính độ lệch chuẩn
- **VARIANCE()** - Tính phương sai

## Hàm COUNT

### 1. COUNT(*) - Đếm Tất Cả Hàng
```sql
-- Đếm tổng số nhân viên
SELECT COUNT(*) AS total_employees
FROM hr.employees;

-- Đếm nhân viên trong phòng ban cụ thể
SELECT COUNT(*) AS it_employees
FROM hr.employees
WHERE department_id = 60;
```

### 2. COUNT(column) - Đếm Giá Trị Không NULL
```sql
-- Đếm nhân viên có hoa hồng (loại trừ NULL)
SELECT COUNT(commission_pct) AS employees_with_commission
FROM hr.employees;

-- Đếm nhân viên có số điện thoại
SELECT COUNT(phone_number) AS employees_with_phone
FROM hr.employees;

-- So sánh tổng số với số lượng không NULL
SELECT 
    COUNT(*) AS total_employees,
    COUNT(commission_pct) AS employees_with_commission,
    COUNT(*) - COUNT(commission_pct) AS employees_without_commission
FROM hr.employees;
```

### 3. COUNT(DISTINCT) - Đếm Giá Trị Duy Nhất
```sql
-- Đếm phòng ban duy nhất
SELECT COUNT(DISTINCT department_id) AS unique_departments
FROM hr.employees;

-- Đếm loại công việc duy nhất
SELECT COUNT(DISTINCT job_id) AS unique_jobs
FROM hr.employees;

-- Đếm quản lý duy nhất
SELECT COUNT(DISTINCT manager_id) AS unique_managers
FROM hr.employees;
```

## Hàm SUM

### 1. Phép Tính SUM Cơ Bản
```sql
-- Tổng chi phí lương
SELECT SUM(salary) AS total_salary_expense
FROM hr.employees;

-- Tổng lương cho phòng ban cụ thể
SELECT SUM(salary) AS it_department_salary
FROM hr.employees
WHERE department_id = 60;

-- Sum với xử lý điều kiện
SELECT 
    SUM(salary) AS total_base_salary,
    SUM(salary * NVL(commission_pct, 0)) AS total_commission,
    SUM(salary + (salary * NVL(commission_pct, 0))) AS total_compensation
FROM hr.employees;
```

### 2. SUM Có Điều Kiện
```sql
-- Sum dựa trên điều kiện sử dụng CASE
SELECT 
    SUM(salary) AS total_salary,
    SUM(CASE WHEN department_id = 60 THEN salary ELSE 0 END) AS it_salary,
    SUM(CASE WHEN department_id = 80 THEN salary ELSE 0 END) AS sales_salary,
    SUM(CASE WHEN commission_pct IS NOT NULL THEN salary ELSE 0 END) AS commissioned_salary
FROM hr.employees;
```

### 3. SUM Với Bảng Sản Phẩm
```sql
-- Tổng giá trị tồn kho
SELECT SUM(unit_price * units_in_stock) AS total_inventory_value
FROM sales.products
WHERE discontinued = 0;

-- Tổng giá trị đơn hàng
SELECT SUM(unit_price * quantity) AS total_order_value
FROM sales.order_details;
```

## Hàm AVG

### 1. Trung Bình Đơn Giản
```sql
-- Lương trung bình của tất cả nhân viên
SELECT AVG(salary) AS average_salary
FROM hr.employees;

-- Lương trung bình theo phòng ban
SELECT 
    department_id,
    AVG(salary) AS avg_dept_salary,
    COUNT(*) AS employee_count
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY avg_dept_salary DESC;
```

### 2. Trung Bình Có Trọng Số
```sql
-- Giá sản phẩm trung bình có trọng số theo số lượng tồn kho
SELECT 
    AVG(unit_price) AS simple_avg_price,
    SUM(unit_price * units_in_stock) / SUM(units_in_stock) AS weighted_avg_price
FROM sales.products
WHERE units_in_stock > 0;
```

### 3. Lọc Với AVG
```sql
-- Nhân viên có lương trên mức trung bình
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    salary - (SELECT AVG(salary) FROM hr.employees) AS salary_difference
FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees)
ORDER BY salary DESC;
```

## Hàm MIN và MAX

### 1. MIN/MAX Cơ Bản
```sql
-- Thông tin phạm vi lương
SELECT 
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary,
    MAX(salary) - MIN(salary) AS salary_range,
    AVG(salary) AS average_salary
FROM hr.employees;
```

### 2. MIN/MAX Ngày Tháng
```sql
-- Phạm vi ngày tuyển dụng
SELECT 
    MIN(hire_date) AS earliest_hire_date,
    MAX(hire_date) AS latest_hire_date,
    MAX(hire_date) - MIN(hire_date) AS hiring_span_days
FROM hr.employees;

-- Thông tin đơn hàng gần đây nhất
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) AS total_orders
FROM sales.orders;
```

### 3. MIN/MAX Chuỗi
```sql
-- Phạm vi tên theo thứ tự bảng chữ cái
SELECT 
    MIN(last_name) AS first_alphabetically,
    MAX(last_name) AS last_alphabetically
FROM hr.employees;

-- Phạm vi tên sản phẩm
SELECT 
    MIN(product_name) AS first_product_alphabetically,
    MAX(product_name) AS last_product_alphabetically
FROM sales.products;
```

## Hàm Tổng Hợp Nâng Cao

### 1. Hàm Thống Kê
```sql
-- Thống kê lương
SELECT 
    COUNT(*) AS employee_count,
    AVG(salary) AS mean_salary,
    STDDEV(salary) AS salary_std_dev,
    VARIANCE(salary) AS salary_variance,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM hr.employees;
```

### 2. Hàm LISTAGG (Tổng Hợp Chuỗi)
```sql
-- Ghép tên nhân viên theo phòng ban
SELECT 
    department_id,
    LISTAGG(first_name || ' ' || last_name, ', ') 
        WITHIN GROUP (ORDER BY last_name) AS employee_list
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;

-- Tên sản phẩm theo danh mục
SELECT 
    category_id,
    LISTAGG(product_name, '; ') 
        WITHIN GROUP (ORDER BY product_name) AS product_list
FROM sales.products
GROUP BY category_id
ORDER BY category_id;
```

## GROUP BY Với Hàm Tổng Hợp

### 1. Nhóm Cơ Bản
```sql
-- Số lượng nhân viên và lương trung bình theo phòng ban
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
```

### 2. Nhóm Nhiều Cột
```sql
-- Thống kê theo phòng ban và công việc
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id, job_id
ORDER BY department_id, job_id;
```

### 3. Nhóm Với Trường Tính Toán
```sql
-- Nhóm nhân viên theo phạm vi lương
SELECT 
    CASE 
        WHEN salary < 5000 THEN 'Thấp (< 5000)'
        WHEN salary < 10000 THEN 'Trung Bình (5000-9999)'
        WHEN salary < 15000 THEN 'Cao (10000-14999)'
        ELSE 'Rất Cao (>= 15000)'
    END AS salary_range,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary_in_range,
    MIN(salary) AS min_salary_in_range,
    MAX(salary) AS max_salary_in_range
FROM hr.employees
GROUP BY 
    CASE 
        WHEN salary < 5000 THEN 'Thấp (< 5000)'
        WHEN salary < 10000 THEN 'Trung Bình (5000-9999)'
        WHEN salary < 15000 THEN 'Cao (10000-14999)'
        ELSE 'Rất Cao (>= 15000)'
    END
ORDER BY MIN(salary);
```

## Mệnh Đề HAVING

### 1. Lọc Kết Quả Tổng Hợp
```sql
-- Phòng ban có hơn 5 nhân viên
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY employee_count DESC;
```

### 2. Điều Kiện HAVING Phức Tạp
```sql
-- Phòng ban có lương trung bình cao và nhiều nhân viên
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) >= 3 
   AND AVG(salary) > 8000
ORDER BY avg_salary DESC;
```

### 3. HAVING Với Nhiều Điều Kiện
```sql
-- Danh mục sản phẩm có giá trị tồn kho đáng kể
SELECT 
    category_id,
    COUNT(*) AS product_count,
    AVG(unit_price) AS avg_price,
    SUM(unit_price * units_in_stock) AS total_inventory_value
FROM sales.products
WHERE discontinued = 0
GROUP BY category_id
HAVING COUNT(*) >= 2
   AND SUM(unit_price * units_in_stock) > 1000
   AND AVG(unit_price) > 15
ORDER BY total_inventory_value DESC;
```

## Kết Hợp WHERE và HAVING

```sql
-- Ví dụ lọc phức tạp
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MAX(hire_date) AS most_recent_hire
FROM hr.employees
WHERE salary > 3000                    -- WHERE lọc từng hàng riêng lẻ
  AND hire_date >= DATE '1990-01-01'
  AND department_id IS NOT NULL
GROUP BY department_id, job_id
HAVING COUNT(*) >= 2                   -- HAVING lọc kết quả đã nhóm
   AND AVG(salary) > 6000
ORDER BY department_id, avg_salary DESC;
```

## Hàm Tổng Hợp Lồng Nhau và Truy Vấn Con

### 1. Truy Vấn Con Với Hàm Tổng Hợp
```sql
-- Nhân viên có lương trên mức trung bình phòng ban
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary,
    dept_avg.avg_salary,
    e.salary - dept_avg.avg_salary AS difference
FROM hr.employees e
JOIN (
    SELECT 
        department_id,
        AVG(salary) AS avg_salary
    FROM hr.employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY e.department_id, difference DESC;
```

### 2. So Sánh Với Thống Kê Tổng Thể
```sql
-- Phòng ban so với mức trung bình công ty
SELECT 
    department_id,
    COUNT(*) AS dept_employee_count,
    AVG(salary) AS dept_avg_salary,
    (SELECT AVG(salary) FROM hr.employees) AS company_avg_salary,
    AVG(salary) - (SELECT AVG(salary) FROM hr.employees) AS salary_difference,
    ROUND(AVG(salary) / (SELECT AVG(salary) FROM hr.employees) * 100, 2) AS salary_ratio_percent
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY dept_avg_salary DESC;
```

## Ví Dụ Báo Cáo Thực Tế

### 1. Tóm Tắt Bảng Điều Khiển Điều Hành
```sql
-- Thống kê toàn công ty
SELECT 
    'Tóm Tắt Nhân Viên' AS metric_category,
    COUNT(*) AS total_employees,
    COUNT(DISTINCT department_id) AS total_departments,
    COUNT(DISTINCT job_id) AS total_job_types,
    TO_CHAR(AVG(salary), '$999,999.99') AS avg_salary,
    TO_CHAR(SUM(salary), '$99,999,999.99') AS total_salary_expense,
    COUNT(CASE WHEN commission_pct IS NOT NULL THEN 1 END) AS commissioned_employees
FROM hr.employees

UNION ALL

SELECT 
    'Phân Bổ Lương',
    COUNT(CASE WHEN salary < 5000 THEN 1 END),
    COUNT(CASE WHEN salary BETWEEN 5000 AND 9999 THEN 1 END),
    COUNT(CASE WHEN salary BETWEEN 10000 AND 14999 THEN 1 END),
    COUNT(CASE WHEN salary >= 15000 THEN 1 END),
    NULL,
    NULL
FROM hr.employees;
```

### 2. Báo Cáo Hiệu Suất Bán Hàng
```sql
-- Tóm tắt bán hàng sản phẩm
SELECT 
    p.product_name,
    COUNT(DISTINCT od.order_id) AS number_of_orders,
    SUM(od.quantity) AS total_quantity_sold,
    AVG(od.quantity) AS avg_quantity_per_order,
    MIN(od.unit_price) AS min_price,
    MAX(od.unit_price) AS max_price,
    AVG(od.unit_price) AS avg_price,
    SUM(od.unit_price * od.quantity) AS total_revenue
FROM sales.products p
JOIN sales.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(od.quantity) >= 10  -- Chỉ sản phẩm có doanh số đáng kể
ORDER BY total_revenue DESC;
```

### 3. Báo Cáo Phân Tích Phòng Ban
```sql
-- Phân tích phòng ban toàn diện
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    TO_CHAR(AVG(e.salary), '$999,999.99') AS avg_salary,
    TO_CHAR(MIN(e.salary), '$999,999.99') AS min_salary,
    TO_CHAR(MAX(e.salary), '$999,999.99') AS max_salary,
    TO_CHAR(SUM(e.salary), '$99,999,999.99') AS total_payroll,
    ROUND(AVG(SYSDATE - e.hire_date) / 365.25, 1) AS avg_years_service,
    COUNT(CASE WHEN e.commission_pct IS NOT NULL THEN 1 END) AS commissioned_count,
    TO_CHAR(AVG(CASE WHEN e.commission_pct IS NOT NULL THEN e.commission_pct END) * 100, '99.9') || '%' AS avg_commission_rate
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC, avg_salary DESC;
```

## Cân Nhắc Hiệu Suất

### 1. Truy Vấn Tổng Hợp Hiệu Quả
```sql
-- Tốt: Sử dụng WHERE để lọc trước khi tổng hợp
SELECT 
    department_id,
    COUNT(*) AS active_employee_count,
    AVG(salary) AS avg_salary
FROM hr.employees
WHERE salary > 3000  -- Lọc trước khi nhóm
GROUP BY department_id;

-- Kém hiệu quả hơn: Lọc sau khi tổng hợp khi có thể
-- Chỉ sử dụng HAVING khi cần lọc trên kết quả tổng hợp
```

### 2. Sử Dụng Index
```sql
-- Hàm tổng hợp có thể hưởng lợi từ index trên cột GROUP BY
-- CREATE INDEX emp_dept_idx ON hr.employees(department_id);

-- Tổng hợp trên cột có index nhanh hơn
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id;  -- Sử dụng index nếu có
```

## Mẫu Hàm Tổng Hợp Phổ Biến

### 1. Tổng Tích Lũy (Xem Trước Hàm Phân Tích)
```sql
-- Tính toán tích lũy đơn giản
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    SUM(salary) OVER (ORDER BY employee_id) AS running_total_salary
FROM hr.employees
ORDER BY employee_id;
```

### 2. Tính Phần Trăm
```sql
-- Lương phòng ban như phần trăm của tổng
SELECT 
    department_id,
    SUM(salary) AS dept_total_salary,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM hr.employees), 2) AS percentage_of_total
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY percentage_of_total DESC;
```

### 3. Xếp Hạng và So Sánh
```sql
-- Top 3 nhân viên có lương cao nhất mỗi phòng ban
SELECT 
    department_id,
    employee_id,
    first_name,
    last_name,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM hr.employees
WHERE department_id IS NOT NULL
QUALIFY RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) <= 3
ORDER BY department_id, salary_rank;
```

## Bài Tập

### Bài Tập 1: Hàm Tổng Hợp Cơ Bản
```sql
-- Tính toán những điều sau cho tất cả nhân viên:
-- Tổng số lượng, lương trung bình, lương min/max, 
-- số nhân viên có hoa hồng, tỷ lệ hoa hồng trung bình
-- Viết truy vấn của bạn ở đây:
```

### Bài Tập 2: Phân Tích Phòng Ban
```sql
-- Đối với mỗi phòng ban, hiển thị:
-- ID phòng ban, số lượng nhân viên, tổng lương, lương trung bình,
-- lương cao nhất và thấp nhất, số loại công việc khác nhau
-- Chỉ bao gồm phòng ban có hơn 2 nhân viên
-- Viết truy vấn của bạn ở đây:
```

### Bài Tập 3: Phân Tích Tồn Kho Sản Phẩm
```sql
-- Đối với mỗi danh mục sản phẩm, tính toán:
-- Số lượng sản phẩm, giá trung bình, tổng giá trị tồn kho,
-- số sản phẩm đã ngừng sản xuất, phần trăm sản phẩm còn hàng
-- Sắp xếp theo tổng giá trị tồn kho giảm dần
-- Viết truy vấn của bạn ở đây:
```

### Bài Tập 4: Phân Tích Nâng Cao
```sql
-- Tạo báo cáo hiển thị nhân viên có lương cao hơn
-- lương trung bình trong phòng ban của họ, bao gồm:
-- Chi tiết nhân viên, lương của họ, trung bình phòng ban, chênh lệch
-- Viết truy vấn của bạn ở đây:
```

## Tóm Tắt Thực Hành Tốt

1. **Sử dụng hàm tổng hợp phù hợp** cho loại dữ liệu và nhu cầu phân tích của bạn
2. **Xử lý giá trị NULL** một cách rõ ràng trong tính toán tổng hợp
3. **Sử dụng GROUP BY khôn ngoan** - bao gồm tất cả cột không phải tổng hợp
4. **Áp dụng HAVING** chỉ khi lọc trên kết quả tổng hợp
5. **Lọc sớm** với WHERE trước khi tổng hợp khi có thể
6. **Cân nhắc hiệu suất** - sử dụng index trên cột GROUP BY
7. **Định dạng đầu ra** phù hợp cho báo cáo
8. **Kiểm tra với trường hợp đặc biệt** bao gồm giá trị NULL và nhóm rỗng

## Lỗi Phổ Biến Cần Tránh

1. **Quên GROUP BY** khi trộn hàm tổng hợp với cột thường
2. **Sử dụng WHERE thay vì HAVING** cho điều kiện tổng hợp
3. **Không xử lý giá trị NULL** trong tính toán
4. **Trộn cột tổng hợp và không tổng hợp** không đúng cách
5. **Sử dụng hàm tổng hợp trong mệnh đề WHERE** (sử dụng HAVING thay thế)
6. **Không cân nhắc ảnh hưởng hiệu suất** của tổng hợp phức tạp
7. **Quên kiểm tra** với nhóm rỗng hoặc giá trị NULL

## Các Bước Tiếp Theo

Thành thạo hàm tổng hợp trước khi chuyển sang:
1. **Joins** - Kết hợp dữ liệu từ nhiều bảng
2. **Subqueries** - Sử dụng hàm tổng hợp trong truy vấn phức tạp  
3. **Analytic Functions** - Windowing và ranking nâng cao
4. **Data Warehousing** - Kỹ thuật tổng hợp nâng cao

Hàm tổng hợp là nền tảng của phân tích dữ liệu và báo cáo, vì vậy hãy thực hành nhiều với các tình huống khác nhau!
