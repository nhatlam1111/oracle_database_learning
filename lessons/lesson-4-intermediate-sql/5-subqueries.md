# Subqueries trong Oracle Database

## Mục Tiêu Học Tập
Sau khi hoàn thành phần này, bạn sẽ hiểu được:
- Các loại subqueries khác nhau (scalar, single-row, multi-row, multi-column)
- Nơi có thể sử dụng subqueries (SELECT, FROM, WHERE, HAVING)
- Single-row vs multi-row subqueries
- Cân nhắc hiệu suất và tối ưu hóa
- Khi nào sử dụng subqueries vs joins

## Giới Thiệu về Subqueries

Subquery là một truy vấn được lồng bên trong một truy vấn khác. Subqueries cho phép bạn:
- Chia nhỏ các vấn đề phức tạp thành các phần dễ quản lý
- Sử dụng kết quả từ một truy vấn làm đầu vào cho truy vấn khác
- Thực hiện so sánh với dữ liệu tổng hợp
- Tạo điều kiện động, dựa trên dữ liệu

### Cấu Trúc Subquery Cơ Bản
```sql
SELECT column1, column2
FROM table1
WHERE column1 operator (
    SELECT column1
    FROM table2
    WHERE condition
);
```

## Các Loại Subqueries

### 1. Scalar Subqueries (Giá Trị Đơn)

Trả về chính xác một hàng và một cột. Có thể được sử dụng ở bất kỳ đâu mà một giá trị đơn được mong đợi.

```sql
-- Tìm nhân viên kiếm được nhiều hơn mức lương trung bình
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- Sử dụng trong mệnh đề SELECT
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    salary - (SELECT AVG(salary) FROM employees) AS salary_diff_from_avg
FROM employees
ORDER BY salary_diff_from_avg DESC;
```

### 2. Single-Row Subqueries

Trả về một hàng nhưng có thể có nhiều cột. Sử dụng với các toán tử single-row (=, !=, <, >, <=, >=).

```sql
-- Tìm nhân viên có mức lương cao nhất
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- Tìm nhân viên trong cùng department với 'John'
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE first_name = 'John'
    AND rownum = 1  -- Đảm bảo single row nếu có nhiều John
);
```

### 3. Multi-Row Subqueries

Trả về nhiều hàng. Sử dụng với các toán tử multi-row (IN, NOT IN, ANY, ALL, EXISTS).

```sql
-- Tìm nhân viên trong departments ở 'Seattle' hoặc 'London'
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id IN (
    SELECT d.department_id
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.city IN ('Seattle', 'London')
);

-- Tìm nhân viên kiếm được nhiều hơn BẤT KỲ nhân viên nào ở department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);

-- Tìm nhân viên kiếm được nhiều hơn TẤT CẢ nhân viên ở department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);
```

### 4. Multi-Column Subqueries

Trả về nhiều cột. Được sử dụng cho các so sánh phức tạp.

```sql
-- Tìm nhân viên có cùng job và department với nhân viên cụ thể
SELECT employee_id, first_name, last_name, job_id, department_id
FROM employees
WHERE (job_id, department_id) = (
    SELECT job_id, department_id
    FROM employees
    WHERE employee_id = 100
);

-- Tìm nhân viên có mức lương tối đa trong department của họ
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees
WHERE (department_id, salary) IN (
    SELECT department_id, MAX(salary)
    FROM employees
    GROUP BY department_id
);
```

## Vị Trí Subquery

### 1. Trong Mệnh Đề SELECT (Scalar Subqueries)
```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    (SELECT department_name 
     FROM departments d 
     WHERE d.department_id = e.department_id) AS department_name,
    (SELECT COUNT(*) 
     FROM employees e2 
     WHERE e2.department_id = e.department_id) AS dept_employee_count
FROM employees e
ORDER BY department_name, last_name;
```

### 2. Trong Mệnh Đề FROM (Inline Views)
```sql
-- Sử dụng subquery như một bảng (inline view)
SELECT dept_summary.department_name, dept_summary.avg_salary, e.first_name, e.salary
FROM (
    SELECT d.department_id, d.department_name, AVG(e.salary) AS avg_salary
    FROM departments d
    JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id, d.department_name
) dept_summary
JOIN employees e ON dept_summary.department_id = e.department_id
WHERE e.salary > dept_summary.avg_salary
ORDER BY dept_summary.department_name, e.salary DESC;
```

### 3. Trong Mệnh Đề WHERE
```sql
-- Vị trí phổ biến nhất cho subqueries
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WHERE hire_date > (
    SELECT hire_date
    FROM employees
    WHERE employee_id = 100
)
AND department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);
```

### 4. Trong Mệnh Đề HAVING
```sql
-- Lọc các nhóm dựa trên kết quả subquery
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > (
    SELECT AVG(salary)
    FROM employees
);
```

## Các Toán Tử Multi-Row Subquery

### 1. Toán Tử IN
```sql
-- Tìm nhân viên trong departments cụ thể
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id IN (1400, 1500, 1700)
);
```

### 2. Toán Tử NOT IN
```sql
-- Tìm nhân viên KHÔNG ở trong departments cụ thể
-- CẨNG TRỌNG: NOT IN với giá trị NULL có thể trả về kết quả không mong đợi
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
    AND department_id IS NOT NULL  -- Quan trọng khi sử dụng NOT IN
);
```

### 3. Toán Tử ANY/SOME
```sql
-- Tìm nhân viên kiếm được nhiều hơn BẤT KỲ manager nào
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE job_id LIKE '%MGR%'
)
AND job_id NOT LIKE '%MGR%';

-- SOME là từ đồng nghĩa của ANY
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > SOME (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);
```

### 4. Toán Tử ALL
```sql
-- Tìm nhân viên kiếm được nhiều hơn TẤT CẢ nhân viên ở department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);

-- Tìm departments với TẤT CẢ nhân viên kiếm được > 5000
SELECT department_id, department_name
FROM departments d
WHERE 5000 < ALL (
    SELECT salary
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

## EXISTS và NOT EXISTS

### Toán Tử EXISTS
Kiểm tra sự tồn tại của các hàng trong subquery. Hiệu quả hơn IN trong nhiều kịch bản.

```sql
-- Tìm nhân viên có lịch sử công việc
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Tìm departments có nhân viên
SELECT d.department_id, d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

### Toán Tử NOT EXISTS
```sql
-- Tìm nhân viên không có lịch sử công việc
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Tìm departments không có nhân viên
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

## Ví Dụ Subquery Phức Tạp

### 1. Subqueries Lồng Nhau
```sql
-- Tìm nhân viên trong departments có mức lương trung bình cao nhất
SELECT employee_id, first_name, last_name, department_id, salary
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM (
        SELECT department_id, AVG(salary) AS avg_sal
        FROM employees
        GROUP BY department_id
        ORDER BY avg_sal DESC
    )
    WHERE rownum = 1
);
```

### 2. Subqueries với Analytical Functions
```sql
-- Tìm nhân viên có mức lương trên median của department họ
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    dept_median.median_salary
FROM employees e
JOIN (
    SELECT 
        department_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
    FROM employees
    GROUP BY department_id
) dept_median ON e.department_id = dept_median.department_id
WHERE e.salary > dept_median.median_salary
ORDER BY e.department_id, e.salary DESC;
```

### 3. Subqueries cho Xác Thực Dữ Liệu
```sql
-- Tìm không nhất quán: nhân viên có department_id không hợp lệ
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE department_id IS NOT NULL
)
AND department_id IS NOT NULL;

-- Tìm bản ghi mồ côi
SELECT 'EMPLOYEES' AS table_name, COUNT(*) AS orphaned_count
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d WHERE d.department_id = e.department_id
)
UNION ALL
SELECT 'DEPARTMENTS', COUNT(*)
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM locations l WHERE l.location_id = d.location_id
);
```

## Cân Nhắc Hiệu Suất

### 1. Subqueries vs Joins
```sql
-- Cách tiếp cận Subquery
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);

-- Cách tiếp cận JOIN tương đương (thường hiệu quả hơn)
SELECT DISTINCT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.location_id = 1700;
```

### 2. Hiệu Suất EXISTS vs IN
```sql
-- EXISTS thường hiệu quả hơn, đặc biệt với bộ dữ liệu lớn
-- EXISTS dừng lại ở kết quả khớp đầu tiên
SELECT e.employee_id, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- IN xử lý tất cả giá trị (kém hiệu quả với bộ kết quả lớn)
SELECT employee_id, first_name
FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM job_history
);
```

### 3. Tránh Subqueries Không Cần Thiết
```sql
-- KHÔNG HIỆU QUẢ: Subquery cho tra cứu đơn giản
SELECT 
    employee_id,
    first_name,
    (SELECT department_name FROM departments WHERE department_id = e.department_id) AS dept_name
FROM employees e;

-- HIỆU QUẢ: Join đơn giản
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

## Các Mẫu Subquery Phổ Biến

### 1. Phân Tích Top-N
```sql
-- Top 5 nhân viên có lương cao nhất
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary IN (
    SELECT salary
    FROM (
        SELECT DISTINCT salary
        FROM employees
        ORDER BY salary DESC
    )
    WHERE rownum <= 5
)
ORDER BY salary DESC;

-- Cách thay thế với window functions (hiệu quả hơn)
SELECT employee_id, first_name, last_name, salary
FROM (
    SELECT 
        employee_id, first_name, last_name, salary,
        RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employees
)
WHERE salary_rank <= 5;
```

### 2. Running Totals và So Sánh
```sql
-- Nhân viên kiếm được trên mức trung bình running của thứ tự tuyển dụng
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.hire_date,
    (SELECT AVG(salary)
     FROM employees e2
     WHERE e2.hire_date <= e.hire_date) AS running_avg_salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.hire_date <= e.hire_date
)
ORDER BY e.hire_date;
```

### 3. Đối Chiếu Dữ Liệu
```sql
-- Tìm departments mà tổng lương không khớp với bảng tóm tắt
SELECT 
    d.department_id,
    d.department_name,
    calc_total.calculated_total,
    summary.summary_total
FROM departments d
CROSS JOIN (
    SELECT SUM(salary) AS calculated_total
    FROM employees
    WHERE department_id = d.department_id
) calc_total
LEFT JOIN salary_summary summary ON d.department_id = summary.department_id
WHERE ABS(calc_total.calculated_total - NVL(summary.summary_total, 0)) > 0.01;
```

## Mẹo Tối Ưu Hóa Subquery

### 1. Sử Dụng Indexes trên Các Cột Subquery
```sql
-- Đảm bảo các cột filter subquery được đánh index
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_emp_hire_date ON employees(hire_date);
```

### 2. Giảm Thiểu Việc Thực Thi Subquery
```sql
-- KHÔNG HIỆU QUẢ: Subquery thực thi cho mỗi hàng
SELECT employee_id, first_name,
    CASE WHEN salary > (SELECT AVG(salary) FROM employees) 
         THEN 'Above Average' 
         ELSE 'Below Average' 
    END AS salary_category
FROM employees;

-- HIỆU QUẢ: Tính toán một lần sử dụng mệnh đề WITH
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal FROM employees
)
SELECT e.employee_id, e.first_name,
    CASE WHEN e.salary > a.avg_sal 
         THEN 'Above Average' 
         ELSE 'Below Average' 
    END AS salary_category
FROM employees e
CROSS JOIN avg_salary a;
```

### 3. Sử Dụng Loại Subquery Phù Hợp
```sql
-- Để kiểm tra sự tồn tại, sử dụng EXISTS thay vì IN
-- EXISTS (hiệu suất tốt hơn)
SELECT d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.department_id
);

-- IN (có thể chậm hơn)
SELECT department_name
FROM departments
WHERE department_id IN (
    SELECT DISTINCT department_id FROM employees
);
```

## Lỗi Subquery Phổ Biến

### 1. Xử Lý NULL với NOT IN
```sql
-- SAI: NOT IN với giá trị NULL
SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id FROM departments WHERE location_id = 1700
);
-- Nếu có bất kỳ department_id nào là NULL, điều này sẽ không trả về hàng nào!

-- ĐÚNG: Xử lý NULLs một cách tường minh
SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id 
    FROM departments 
    WHERE location_id = 1700 
    AND department_id IS NOT NULL
);

-- HOẶC sử dụng NOT EXISTS (được khuyến nghị)
SELECT e.employee_id, e.first_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.department_id = e.department_id 
    AND d.location_id = 1700
);
```

### 2. Subquery Trả Về Nhiều Hàng
```sql
-- SAI: Toán tử single-row với multi-row subquery
SELECT employee_id, first_name
FROM employees
WHERE department_id = (
    SELECT department_id FROM departments WHERE location_id IN (1400, 1700)
);
-- LỖI: ORA-01427: single-row subquery returns more than one row

-- ĐÚNG: Sử dụng toán tử multi-row
SELECT employee_id, first_name
FROM employees
WHERE department_id IN (
    SELECT department_id FROM departments WHERE location_id IN (1400, 1700)
);
```

### 3. Correlated Subqueries Không Hiệu Quả
```sql
-- KHÔNG HIỆU QUẢ: Correlated subquery trong SELECT
SELECT 
    e.employee_id,
    e.first_name,
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_count
FROM employees e;

-- HIỆU QUẢ: Sử dụng window function
SELECT 
    employee_id,
    first_name,
    COUNT(*) OVER (PARTITION BY department_id) AS dept_count
FROM employees;
```

## Bài Tập Thực Hành

### Bài Tập 1: Subqueries Cơ Bản
1. Tìm nhân viên kiếm được nhiều hơn mức lương trung bình trong department của họ
2. Liệt kê departments có hơn 5 nhân viên
3. Tìm nhân viên có mức lương cao thứ hai

### Bài Tập 2: Subqueries Nâng Cao
1. Tìm nhân viên đã thay đổi công việc (sử dụng bảng job_history)
2. Liệt kê sản phẩm chưa bao giờ được đặt hàng
3. Tìm khách hàng đã đặt hàng trong các tháng liên tiếp

### Bài Tập 3: Tối Ưu Hóa Hiệu Suất
1. Viết lại correlated subquery sử dụng window functions
2. So sánh execution plans cho EXISTS vs IN vs JOIN
3. Tối ưu hóa một nested subquery phức tạp

## Tóm Tắt

Subqueries là công cụ mạnh mẽ cho:
- Chia nhỏ các vấn đề phức tạp thành các phần đơn giản hơn
- Điều kiện động dựa trên dữ liệu
- Truy vấn phân tích và báo cáo
- Kiểm tra xác thực và chất lượng dữ liệu

Các khái niệm chính:
- **Scalar subqueries**: Giá trị đơn, sử dụng ở bất cứ đâu
- **Multi-row subqueries**: Sử dụng với IN, ANY, ALL, EXISTS
- **Correlated subqueries**: Tham chiếu truy vấn ngoài
- **Hiệu suất**: Cân nhắc joins và window functions như các lựa chọn thay thế
- **Xử lý NULL**: Cẩn thận với NOT IN và giá trị NULL

Chọn cách tiếp cận phù hợp dựa trên:
- Độ phức tạp và khả năng đọc của truy vấn
- Yêu cầu hiệu suất
- Khối lượng dữ liệu và indexes
- Cân nhắc bảo trì

Tiếp theo, chúng ta sẽ khám phá correlated subqueries chi tiết, cung cấp khả năng truy vấn phức tạp hơn nữa.
