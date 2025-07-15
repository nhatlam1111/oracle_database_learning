# Tạo Bảng, Mối Quan Hệ và Ràng Buộc trong Oracle

Học cách tạo, chỉnh sửa và quản lý các bảng cùng với việc thiết lập mối quan hệ và ràng buộc là kỹ năng cơ bản quan trọng trong Oracle Database. Bài học này sẽ hướng dẫn bạn từ việc tạo bảng đơn giản đến thiết lập hệ thống mối quan hệ phức tạp.

## Mục Lục
1. [Tạo Bảng Cơ Bản](#tạo-bảng-cơ-bản)
2. [Chỉnh Sửa Cấu Trúc Bảng](#chỉnh-sửa-cấu-trúc-bảng)
3. [Xóa Bảng và Dữ Liệu](#xóa-bảng-và-dữ-liệu)
4. [Khóa Chính và Khóa Ngoại](#khóa-chính-và-khóa-ngoại)
5. [Các Loại Mối Quan Hệ](#các-loại-mối-quan-hệ)
6. [Ràng Buộc và Tính Toàn Vẹn](#ràng-buộc-và-tính-toàn-vẹn)
7. [Thiết Kế Schema Thực Tế](#thiết-kế-schema-thực-tế)

## Tạo Bảng Cơ Bản

### Cú Pháp CREATE TABLE

Câu lệnh CREATE TABLE là lệnh DDL (Data Definition Language) để tạo bảng mới trong Oracle Database.

```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
);
```

### Ví Dụ Tạo Bảng Đơn Giản

```sql
-- Tạo bảng employees cơ bản
CREATE TABLE employees (
    employee_id NUMBER(10),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    hire_date DATE,
    salary NUMBER(10,2)
);
```

### Tạo Bảng Với Ràng Buộc Cột

```sql
-- Tạo bảng với các ràng buộc trực tiếp trên cột
CREATE TABLE departments (
    department_id NUMBER(10) PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL UNIQUE,
    location VARCHAR2(100),
    budget NUMBER(15,2) CHECK (budget > 0),
    created_date DATE DEFAULT SYSDATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N'))
);
```

### Tạo Bảng Từ Bảng Khác (CTAS)

```sql
-- Tạo bảng từ truy vấn SELECT (Create Table As Select)
CREATE TABLE employees_backup AS
SELECT * FROM employees WHERE hire_date < DATE '2023-01-01';

-- Tạo bảng với cấu trúc tương tự nhưng không có dữ liệu
CREATE TABLE employees_template AS
SELECT * FROM employees WHERE 1=0;

-- Tạo bảng với một số cột từ bảng khác
CREATE TABLE employee_summary AS
SELECT employee_id, first_name, last_name, salary 
FROM employees;
```

### Tùy Chọn Tablespace và Storage

```sql
-- Tạo bảng với tablespace và storage parameters
CREATE TABLE large_transactions (
    transaction_id NUMBER(15) PRIMARY KEY,
    transaction_date DATE,
    amount NUMBER(15,2),
    description VARCHAR2(500)
)
TABLESPACE users
PCTFREE 10
PCTUSED 80
STORAGE (
    INITIAL 1M
    NEXT 1M
    PCTINCREASE 0
);
```

## Chỉnh Sửa Cấu Trúc Bảng

### Thêm Cột Mới

```sql
-- Thêm một cột
ALTER TABLE employees 
ADD phone_number VARCHAR2(20);

-- Thêm nhiều cột cùng lúc
ALTER TABLE employees 
ADD (
    address VARCHAR2(200),
    city VARCHAR2(50),
    postal_code VARCHAR2(10)
);

-- Thêm cột với giá trị mặc định
ALTER TABLE employees 
ADD status VARCHAR2(20) DEFAULT 'ACTIVE';
```

### Sửa Đổi Cột Hiện Có

```sql
-- Thay đổi kích thước cột
ALTER TABLE employees 
MODIFY first_name VARCHAR2(100);

-- Thay đổi kiểu dữ liệu (cần cẩn thận)
ALTER TABLE employees 
MODIFY salary NUMBER(12,2);

-- Thêm NOT NULL constraint
ALTER TABLE employees 
MODIFY email NOT NULL;

-- Thay đổi giá trị mặc định
ALTER TABLE employees 
MODIFY status DEFAULT 'PENDING';

-- Sửa đổi nhiều cột
ALTER TABLE employees 
MODIFY (
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    email VARCHAR2(150)
);
```

### Đổi Tên Cột

```sql
-- Đổi tên cột
ALTER TABLE employees 
RENAME COLUMN phone_number TO contact_number;

-- Đổi tên bảng
ALTER TABLE employees 
RENAME TO staff;
```

### Xóa Cột

```sql
-- Xóa một cột
ALTER TABLE employees 
DROP COLUMN address;

-- Xóa nhiều cột
ALTER TABLE employees 
DROP (city, postal_code);

-- Đánh dấu cột là unused (không xóa ngay)
ALTER TABLE employees 
SET UNUSED COLUMN contact_number;

-- Xóa tất cả cột unused
ALTER TABLE employees 
DROP UNUSED COLUMNS;
```

## Xóa Bảng và Dữ Liệu

### Xóa Dữ liệu Trong Bảng

```sql
-- Xóa tất cả dữ liệu (có thể rollback)
DELETE FROM employees;

-- Xóa dữ liệu theo điều kiện
DELETE FROM employees WHERE hire_date < DATE '2020-01-01';

-- Xóa nhanh tất cả dữ liệu (không thể rollback)
TRUNCATE TABLE employees;
```

### Xóa Bảng

```sql
-- Xóa bảng hoàn toàn
DROP TABLE employees;

-- Xóa bảng và cascade constraints
DROP TABLE employees CASCADE CONSTRAINTS;

-- Xóa bảng và đưa vào Recycle Bin
DROP TABLE employees;

-- Xóa bảng hoàn toàn không vào Recycle Bin
DROP TABLE employees PURGE;
```

### Khôi Phục Bảng Từ Recycle Bin

```sql
-- Xem các bảng trong Recycle Bin
SELECT object_name, original_name, droptime 
FROM recyclebin WHERE type = 'TABLE';

-- Khôi phục bảng
FLASHBACK TABLE employees TO BEFORE DROP;

-- Khôi phục và đổi tên
FLASHBACK TABLE employees TO BEFORE DROP RENAME TO employees_restored;

-- Xóa vĩnh viễn khỏi Recycle Bin
PURGE TABLE employees;
```

## Thiết Kế Schema Thực Tế

### Xây Dựng Hệ Thống HR Management

Chúng ta sẽ tạo một hệ thống quản lý nhân sự hoàn chình từ đầu:

#### Bước 1: Tạo Bảng Tra Cứu (Lookup Tables)

```sql
-- Bảng quốc gia
CREATE TABLE countries (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(50) NOT NULL UNIQUE,
    region VARCHAR2(50)
);

-- Bảng địa điểm
CREATE TABLE locations (
    location_id NUMBER(10) PRIMARY KEY,
    street_address VARCHAR2(100),
    postal_code VARCHAR2(12),
    city VARCHAR2(50) NOT NULL,
    state_province VARCHAR2(50),
    country_id CHAR(2) NOT NULL,
    CONSTRAINT fk_loc_country 
        FOREIGN KEY (country_id) 
        REFERENCES countries(country_id)
);

-- Bảng chức danh công việc
CREATE TABLE jobs (
    job_id VARCHAR2(10) PRIMARY KEY,
    job_title VARCHAR2(100) NOT NULL,
    min_salary NUMBER(8,2),
    max_salary NUMBER(8,2),
    CONSTRAINT chk_salary_range CHECK (max_salary >= min_salary)
);
```

#### Bước 2: Tạo Bảng Chính (Main Tables)

```sql
-- Bảng phòng ban
CREATE TABLE departments (
    department_id NUMBER(10) PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL UNIQUE,
    manager_id NUMBER(10), -- Sẽ tham chiếu employees sau
    location_id NUMBER(10),
    budget NUMBER(15,2) CHECK (budget > 0),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_dept_location 
        FOREIGN KEY (location_id) 
        REFERENCES locations(location_id)
);

-- Bảng nhân viên
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    salary NUMBER(8,2) CHECK (salary > 0),
    commission_pct NUMBER(3,2) CHECK (commission_pct BETWEEN 0 AND 1),
    manager_id NUMBER(10), -- Self-referencing FK
    department_id NUMBER(10),
    status VARCHAR2(20) DEFAULT 'ACTIVE' 
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'TERMINATED')),
    created_date DATE DEFAULT SYSDATE,
    modified_date DATE DEFAULT SYSDATE,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_emp_job 
        FOREIGN KEY (job_id) 
        REFERENCES jobs(job_id),
    CONSTRAINT fk_emp_manager 
        FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id),
    CONSTRAINT fk_emp_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    
    -- Additional Constraints
    CONSTRAINT chk_hire_date CHECK (hire_date <= SYSDATE),
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- Bây giờ thêm manager constraint cho departments
ALTER TABLE departments 
ADD CONSTRAINT fk_dept_manager 
    FOREIGN KEY (manager_id) 
    REFERENCES employees(employee_id);
```

#### Bước 3: Tạo Bảng Quan Hệ Phức Tạp

```sql
-- Lịch sử công việc của nhân viên
CREATE TABLE job_history (
    employee_id NUMBER(10),
    start_date DATE,
    end_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    department_id NUMBER(10),
    
    -- Composite Primary Key
    CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_jhist_emp 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_jhist_job 
        FOREIGN KEY (job_id) 
        REFERENCES jobs(job_id),
    CONSTRAINT fk_jhist_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    
    -- Business Logic Constraints
    CONSTRAINT chk_jhist_dates CHECK (end_date > start_date)
);

-- Bảng dự án
CREATE TABLE projects (
    project_id NUMBER(10) PRIMARY KEY,
    project_name VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMBER(15,2) CHECK (budget > 0),
    status VARCHAR2(20) DEFAULT 'PLANNING' 
        CHECK (status IN ('PLANNING', 'ACTIVE', 'COMPLETED', 'CANCELLED')),
    department_id NUMBER(10),
    
    CONSTRAINT fk_proj_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT chk_proj_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Bảng gán nhân viên vào dự án (Many-to-Many)
CREATE TABLE project_assignments (
    employee_id NUMBER(10),
    project_id NUMBER(10),
    assignment_date DATE DEFAULT SYSDATE,
    role VARCHAR2(50),
    hours_per_week NUMBER(3,1) CHECK (hours_per_week BETWEEN 0 AND 40),
    hourly_rate NUMBER(8,2),
    
    -- Composite Primary Key
    CONSTRAINT pk_proj_assign PRIMARY KEY (employee_id, project_id),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_assign_emp 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_assign_proj 
        FOREIGN KEY (project_id) 
        REFERENCES projects(project_id)
        ON DELETE CASCADE
);
```

### Tạo Sequences cho Auto-increment

```sql
-- Sequences cho các ID
CREATE SEQUENCE employee_id_seq 
    START WITH 1000 
    INCREMENT BY 1 
    NOCACHE;

CREATE SEQUENCE department_id_seq 
    START WITH 10 
    INCREMENT BY 10 
    NOCACHE;

CREATE SEQUENCE location_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NOCACHE;

CREATE SEQUENCE project_id_seq 
    START WITH 1 
    INCREMENT BY 1 
    NOCACHE;
```

### Tạo Indexes cho Performance

```sql
-- Indexes cho Foreign Keys
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_emp_manager_id ON employees(manager_id);
CREATE INDEX idx_emp_job_id ON employees(job_id);
CREATE INDEX idx_dept_manager_id ON departments(manager_id);
CREATE INDEX idx_dept_location_id ON departments(location_id);
CREATE INDEX idx_loc_country_id ON locations(country_id);

-- Indexes cho các cột thường xuyên query
CREATE INDEX idx_emp_lastname ON employees(last_name);
CREATE INDEX idx_emp_email ON employees(email);
CREATE INDEX idx_emp_hire_date ON employees(hire_date);
CREATE INDEX idx_emp_status ON employees(status);

-- Composite indexes
CREATE INDEX idx_emp_dept_status ON employees(department_id, status);
CREATE INDEX idx_proj_status_dates ON projects(status, start_date, end_date);
```

### Chèn Dữ Liệu Mẫu

```sql
-- Insert Countries
INSERT INTO countries VALUES ('US', 'United States', 'North America');
INSERT INTO countries VALUES ('VN', 'Vietnam', 'Asia');
INSERT INTO countries VALUES ('JP', 'Japan', 'Asia');

-- Insert Locations
INSERT INTO locations VALUES (location_id_seq.NEXTVAL, '123 Main St', '10001', 'New York', 'NY', 'US');
INSERT INTO locations VALUES (location_id_seq.NEXTVAL, '456 Tech Ave', '94105', 'San Francisco', 'CA', 'US');
INSERT INTO locations VALUES (location_id_seq.NEXTVAL, '789 Business Rd', '70000', 'Ho Chi Minh City', 'HCM', 'VN');

-- Insert Jobs
INSERT INTO jobs VALUES ('IT_PROG', 'Programmer', 4000, 10000);
INSERT INTO jobs VALUES ('IT_MGR', 'IT Manager', 8000, 15000);
INSERT INTO jobs VALUES ('HR_REP', 'HR Representative', 3000, 8000);
INSERT INTO jobs VALUES ('FI_ACCOUNT', 'Accountant', 3500, 8500);

-- Insert Departments
INSERT INTO departments VALUES (department_id_seq.NEXTVAL, 'Information Technology', NULL, 1, 500000);
INSERT INTO departments VALUES (department_id_seq.NEXTVAL, 'Human Resources', NULL, 1, 200000);
INSERT INTO departments VALUES (department_id_seq.NEXTVAL, 'Finance', NULL, 2, 300000);

-- Insert Employees
INSERT INTO employees VALUES (
    employee_id_seq.NEXTVAL, 'John', 'Doe', 'john.doe@company.com', 
    '+1-555-0123', DATE '2020-01-15', 'IT_MGR', 12000, NULL, NULL, 10
);

INSERT INTO employees VALUES (
    employee_id_seq.NEXTVAL, 'Jane', 'Smith', 'jane.smith@company.com', 
    '+1-555-0124', DATE '2021-03-10', 'IT_PROG', 7500, NULL, 1000, 10
);

-- Update department managers
UPDATE departments SET manager_id = 1000 WHERE department_id = 10;

COMMIT;
```

## Các Loại Mối Quan Hệ

Sau khi đã biết cách tạo bảng và ràng buộc, chúng ta cần hiểu các loại mối quan hệ để thiết kế database hiệu quả.

### 1. Mối Quan Hệ Một-Nhiều (1:M)

Đây là loại mối quan hệ phổ biến nhất trong thiết kế database.

**Đặc điểm**:
- Một bản ghi ở bảng cha có thể liên quan đến nhiều bản ghi ở bảng con
- Mỗi bản ghi ở bảng con chỉ liên quan đến một bản ghi ở bảng cha
- Khóa ngoại được đặt ở bảng con (phía "nhiều")

**Ví dụ từ schema HR đã tạo**:
```sql
-- Departments (1) -> Employees (Many)
-- Mỗi phòng ban có thể có nhiều nhân viên
-- Mỗi nhân viên thuộc về một phòng ban

SELECT d.department_name, COUNT(e.employee_id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;
```

### 2. Mối Quan Hệ Một-Một (1:1)

Mối quan hệ ít phổ biến, thường dùng để tách biệt dữ liệu nhạy cảm.

**Ví dụ mở rộng schema**:
```sql
-- Tạo bảng thông tin cá nhân riêng tư
CREATE TABLE employee_private_info (
    employee_id NUMBER(10) PRIMARY KEY,
    social_security_number VARCHAR2(20),
    bank_account VARCHAR2(50),
    emergency_contact_name VARCHAR2(100),
    emergency_contact_phone VARCHAR2(20),
    medical_notes VARCHAR2(500),
    
    CONSTRAINT fk_private_emp 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);
```

### 3. Mối Quan Hệ Nhiều-Nhiều (M:M)

**Ví dụ từ schema đã tạo**: Employees và Projects thông qua Project_Assignments

```sql
-- Tìm nhân viên tham gia nhiều dự án nhất
SELECT e.first_name, e.last_name, COUNT(pa.project_id) as project_count
FROM employees e
JOIN project_assignments pa ON e.employee_id = pa.employee_id
JOIN projects p ON pa.project_id = p.project_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY project_count DESC;

-- Tìm dự án có nhiều nhân viên tham gia nhất
SELECT p.project_name, COUNT(pa.employee_id) as employee_count
FROM projects p
JOIN project_assignments pa ON p.project_id = pa.project_id
GROUP BY p.project_id, p.project_name
ORDER BY employee_count DESC;
```

### 4. Mối Quan Hệ Tự Tham Chiếu (Self-Referencing)

**Ví dụ từ schema**: Employee -> Manager (cũng là Employee)

```sql
-- Hierarchical query: Hiển thị cấu trúc tổ chức
SELECT LEVEL, 
       LPAD(' ', (LEVEL-1)*2) || first_name || ' ' || last_name as org_chart,
       job_id
FROM employees
START WITH manager_id IS NULL  -- Bắt đầu từ CEO
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name;

-- Tìm tất cả nhân viên dưới quyền của một manager
SELECT subordinate.first_name, subordinate.last_name, subordinate.job_id
FROM employees manager
JOIN employees subordinate ON manager.employee_id = subordinate.manager_id
WHERE manager.employee_id = 1000;
```

## Khóa Chính và Khóa Ngoại

### Khóa Chính (Primary Key)

Khóa chính là một cột hoặc tổ hợp các cột xác định duy nhất mỗi hàng trong bảng.

#### Đặc Điểm Khóa Chính:
- **Duy nhất**: Không có hai hàng nào có cùng giá trị khóa chính
- **Không NULL**: Không thể chứa giá trị NULL
- **Bất biến**: Không nên thay đổi sau khi được gán
- **Tối giản**: Nên sử dụng ít cột nhất có thể

#### Tạo Khóa Chính

```sql
-- Cách 1: Trong câu lệnh CREATE TABLE (inline)
CREATE TABLE departments (
    department_id NUMBER(10) PRIMARY KEY,
    department_name VARCHAR2(100),
    location VARCHAR2(100)
);

-- Cách 2: Constraint ở cuối bảng
CREATE TABLE employees (
    employee_id NUMBER(10),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    PRIMARY KEY (employee_id)
);

-- Cách 3: Khóa chính có tên
CREATE TABLE projects (
    project_id NUMBER(10),
    project_name VARCHAR2(100),
    start_date DATE,
    CONSTRAINT pk_projects PRIMARY KEY (project_id)
);

-- Cách 4: Khóa chính tổ hợp (composite)
CREATE TABLE order_items (
    order_id NUMBER(10),
    product_id NUMBER(10),
    quantity NUMBER(5),
    unit_price NUMBER(10,2),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id)
);
```

#### Thêm Khóa Chính Sau Khi Tạo Bảng

```sql
-- Thêm khóa chính cho bảng đã tồn tại
ALTER TABLE customers 
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

-- Thêm khóa chính tổ hợp
ALTER TABLE employee_projects 
ADD CONSTRAINT pk_emp_proj PRIMARY KEY (employee_id, project_id);
```

### Khóa Ngoại (Foreign Key)

Khóa ngoại là một cột hoặc tổ hợp các cột tham chiếu đến khóa chính của bảng khác.

#### Đặc Điểm Khóa Ngoại:
- **Tham chiếu hợp lệ**: Phải khớp với giá trị khóa chính hiện có
- **Có thể NULL**: Trừ khi được chỉ định NOT NULL
- **Thực thi toàn vẹn**: Ngăn ngừa dữ liệu không nhất quán
- **Nhiều khóa ngoại**: Một bảng có thể có nhiều khóa ngoại

#### Tạo Khóa Ngoại

```sql
-- Cách 1: Inline trong CREATE TABLE
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    department_id NUMBER(10) REFERENCES departments(department_id),
    manager_id NUMBER(10) REFERENCES employees(employee_id)
);

-- Cách 2: Constraint ở cuối bảng
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    department_id NUMBER(10),
    manager_id NUMBER(10),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Cách 3: Khóa ngoại có tên và tùy chọn
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    department_id NUMBER(10),
    manager_id NUMBER(10),
    CONSTRAINT fk_emp_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT fk_emp_mgr 
        FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id)
);
```

#### Thêm Khóa Ngoại Sau Khi Tạo Bảng

```sql
-- Thêm khóa ngoại cho bảng đã tồn tại
ALTER TABLE employees 
ADD CONSTRAINT fk_emp_dept 
    FOREIGN KEY (department_id) 
    REFERENCES departments(department_id);

-- Khóa ngoại với tùy chọn CASCADE
ALTER TABLE employees 
ADD CONSTRAINT fk_emp_mgr 
    FOREIGN KEY (manager_id) 
    REFERENCES employees(employee_id)
    ON DELETE SET NULL;
```

#### Tùy Chọn ON DELETE

```sql
-- ON DELETE CASCADE: Xóa bản ghi con khi xóa bản ghi cha
CONSTRAINT fk_order_items_order 
    FOREIGN KEY (order_id) 
    REFERENCES orders(order_id)
    ON DELETE CASCADE

-- ON DELETE SET NULL: Đặt khóa ngoại thành NULL
CONSTRAINT fk_emp_mgr 
    FOREIGN KEY (manager_id) 
    REFERENCES employees(employee_id)
    ON DELETE SET NULL

-- RESTRICT (mặc định): Không cho phép xóa bản ghi cha nếu có bản ghi con
CONSTRAINT fk_emp_dept 
    FOREIGN KEY (department_id) 
    REFERENCES departments(department_id)
    -- ON DELETE RESTRICT (mặc định)
```

### Quản Lý Constraints

#### Xem Thông Tin Constraints

```sql
-- Xem tất cả constraints của một bảng
SELECT constraint_name, constraint_type, search_condition, status
FROM user_constraints 
WHERE table_name = 'EMPLOYEES';

-- Xem thông tin chi tiết khóa ngoại
SELECT c.constraint_name, c.table_name, 
       cc.column_name, c.r_constraint_name,
       rc.table_name as referenced_table
FROM user_constraints c
JOIN user_cons_columns cc ON c.constraint_name = cc.constraint_name
JOIN user_constraints rc ON c.r_constraint_name = rc.constraint_name
WHERE c.constraint_type = 'R'
AND c.table_name = 'EMPLOYEES';
```

#### Disable/Enable Constraints

```sql
-- Tắt constraint
ALTER TABLE employees DISABLE CONSTRAINT fk_emp_dept;

-- Bật constraint
ALTER TABLE employees ENABLE CONSTRAINT fk_emp_dept;

-- Bật constraint với kiểm tra dữ liệu hiện có
ALTER TABLE employees ENABLE VALIDATE CONSTRAINT fk_emp_dept;

-- Bật constraint không kiểm tra dữ liệu hiện có
ALTER TABLE employees ENABLE NOVALIDATE CONSTRAINT fk_emp_dept;
```

#### Xóa Constraints

```sql
-- Xóa constraint
ALTER TABLE employees DROP CONSTRAINT fk_emp_dept;

-- Xóa khóa chính (cần CASCADE nếu có khóa ngoại tham chiếu)
ALTER TABLE departments DROP CONSTRAINT pk_departments CASCADE;
```

## Ràng Buộc và Tính Toàn Vẹn

### Các Loại Ràng Buộc (Constraints)

Oracle cung cấp nhiều loại ràng buộc để đảm bảo tính toàn vẹn dữ liệu:

#### 1. NOT NULL Constraint

Đảm bảo cột không chứa giá trị NULL.

```sql
-- Tạo bảng với NOT NULL
CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    phone VARCHAR2(20)
);

-- Thêm NOT NULL cho cột hiện có
ALTER TABLE customers MODIFY email NOT NULL;

-- Xóa NOT NULL constraint
ALTER TABLE customers MODIFY phone NULL;
```

#### 2. UNIQUE Constraint

Đảm bảo giá trị trong cột hoặc tổ hợp cột là duy nhất.

```sql
-- UNIQUE constraint trên một cột
CREATE TABLE users (
    user_id NUMBER(10) PRIMARY KEY,
    username VARCHAR2(50) UNIQUE,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20)
);

-- UNIQUE constraint có tên
CREATE TABLE products (
    product_id NUMBER(10) PRIMARY KEY,
    product_code VARCHAR2(20),
    product_name VARCHAR2(100),
    CONSTRAINT uk_product_code UNIQUE (product_code)
);

-- UNIQUE constraint trên nhiều cột
CREATE TABLE employee_positions (
    emp_id NUMBER(10),
    position_code VARCHAR2(10),
    department_id NUMBER(10),
    start_date DATE,
    CONSTRAINT uk_emp_pos UNIQUE (emp_id, position_code, start_date)
);

-- Thêm UNIQUE constraint sau khi tạo bảng
ALTER TABLE customers 
ADD CONSTRAINT uk_customer_email UNIQUE (email);
```

#### 3. CHECK Constraint

Đảm bảo giá trị trong cột thỏa mãn điều kiện logic.

```sql
-- CHECK constraint đơn giản
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    salary NUMBER(10,2) CHECK (salary > 0),
    age NUMBER(3) CHECK (age BETWEEN 18 AND 100),
    status VARCHAR2(10) CHECK (status IN ('ACTIVE', 'INACTIVE', 'PENDING'))
);

-- CHECK constraint phức tạp
CREATE TABLE orders (
    order_id NUMBER(10) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    total_amount NUMBER(12,2),
    discount_percent NUMBER(5,2),
    CONSTRAINT chk_order_dates CHECK (ship_date >= order_date),
    CONSTRAINT chk_total_positive CHECK (total_amount > 0),
    CONSTRAINT chk_discount_range CHECK (discount_percent BETWEEN 0 AND 100)
);

-- CHECK constraint với biểu thức phức tạp
CREATE TABLE accounts (
    account_id NUMBER(10) PRIMARY KEY,
    account_type VARCHAR2(20),
    balance NUMBER(15,2),
    credit_limit NUMBER(15,2),
    CONSTRAINT chk_account_balance 
        CHECK (
            (account_type = 'SAVINGS' AND balance >= 0) OR
            (account_type = 'CREDIT' AND balance >= -credit_limit)
        )
);

-- Thêm CHECK constraint sau khi tạo bảng
ALTER TABLE employees 
ADD CONSTRAINT chk_emp_email 
    CHECK (email LIKE '%@%.%');
```

#### 4. DEFAULT Values

Đặt giá trị mặc định cho cột khi không có giá trị được cung cấp.

```sql
-- DEFAULT values với các kiểu dữ liệu khác nhau
CREATE TABLE audit_log (
    log_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50),
    operation VARCHAR2(10) DEFAULT 'INSERT',
    log_timestamp DATE DEFAULT SYSDATE,
    user_name VARCHAR2(50) DEFAULT USER,
    is_active CHAR(1) DEFAULT 'Y',
    priority NUMBER(1) DEFAULT 1
);

-- DEFAULT với sequence
CREATE SEQUENCE emp_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE employees (
    employee_id NUMBER(10) DEFAULT emp_id_seq.NEXTVAL PRIMARY KEY,
    first_name VARCHAR2(50),
    hire_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'PENDING'
);

-- Thay đổi DEFAULT value
ALTER TABLE employees MODIFY status DEFAULT 'ACTIVE';
```

### Tính Toàn Vẹn Tham Chiếu

#### Quy Tắc Thực Thi

Tính toàn vẹn tham chiếu đảm bảo mối quan hệ giữa các bảng luôn nhất quán:

```sql
-- Tạo bảng cha (parent table)
CREATE TABLE departments (
    department_id NUMBER(10) PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    location VARCHAR2(100)
);

-- Tạo bảng con (child table) với ràng buộc tham chiếu
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    department_id NUMBER(10),
    CONSTRAINT fk_emp_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
);
```

#### Các Tùy Chọn ON DELETE

```sql
-- ON DELETE CASCADE: Xóa tự động bản ghi con
CREATE TABLE order_items (
    order_id NUMBER(10),
    item_id NUMBER(10),
    quantity NUMBER(5),
    CONSTRAINT fk_items_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- ON DELETE SET NULL: Đặt NULL cho khóa ngoại
CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    manager_id NUMBER(10),
    department_id NUMBER(10),
    CONSTRAINT fk_emp_mgr 
        FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_emp_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        -- Mặc định: ON DELETE RESTRICT
);
```

### Quản Lý Constraints

#### Xem Thông Tin Constraints

```sql
-- Xem tất cả constraints của user
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
ORDER BY table_name, constraint_name;

-- Xem constraints của một bảng cụ thể
SELECT constraint_name, constraint_type, search_condition, status
FROM user_constraints 
WHERE table_name = 'EMPLOYEES';

-- Xem các cột tham gia trong constraint
SELECT c.constraint_name, cc.column_name, cc.position
FROM user_constraints c
JOIN user_cons_columns cc ON c.constraint_name = cc.constraint_name
WHERE c.table_name = 'EMPLOYEES'
ORDER BY c.constraint_name, cc.position;

-- Xem thông tin khóa ngoại chi tiết
SELECT 
    fk.constraint_name,
    fk.table_name as child_table,
    fkc.column_name as child_column,
    pk.table_name as parent_table,
    pkc.column_name as parent_column,
    fk.delete_rule
FROM user_constraints fk
JOIN user_cons_columns fkc ON fk.constraint_name = fkc.constraint_name
JOIN user_constraints pk ON fk.r_constraint_name = pk.constraint_name
JOIN user_cons_columns pkc ON pk.constraint_name = pkc.constraint_name
WHERE fk.constraint_type = 'R'
AND fkc.position = pkc.position
ORDER BY fk.table_name, fk.constraint_name;
```

#### Disable/Enable Constraints

```sql
-- Tắt constraint (dữ liệu mới không được kiểm tra)
ALTER TABLE employees DISABLE CONSTRAINT fk_emp_dept;

-- Tắt constraint cascade (tắt cả các constraint phụ thuộc)
ALTER TABLE departments DISABLE CONSTRAINT pk_departments CASCADE;

-- Bật constraint
ALTER TABLE employees ENABLE CONSTRAINT fk_emp_dept;

-- Bật constraint với validate (kiểm tra dữ liệu hiện có)
ALTER TABLE employees ENABLE VALIDATE CONSTRAINT fk_emp_dept;

-- Bật constraint không validate dữ liệu hiện có
ALTER TABLE employees ENABLE NOVALIDATE CONSTRAINT fk_emp_dept;

-- Tắt tất cả constraints của bảng
ALTER TABLE employees DISABLE ALL TRIGGERS;
```

#### Xóa Constraints

```sql
-- Xóa constraint cụ thể
ALTER TABLE employees DROP CONSTRAINT fk_emp_dept;

-- Xóa khóa chính (cần CASCADE nếu có khóa ngoại tham chiếu)
ALTER TABLE departments DROP CONSTRAINT pk_departments CASCADE;

-- Xóa UNIQUE constraint
ALTER TABLE customers DROP CONSTRAINT uk_customer_email;

-- Xóa CHECK constraint
ALTER TABLE employees DROP CONSTRAINT chk_emp_salary;
```

### Validation và Error Handling

#### Kiểm Tra Constraint Violations

```sql
-- Tìm các constraint bị vi phạm khi enable
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE employees ENABLE CONSTRAINT fk_emp_dept';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        -- Xem dữ liệu vi phạm
        FOR rec IN (
            SELECT e.employee_id, e.department_id
            FROM employees e
            WHERE e.department_id IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 FROM departments d 
                WHERE d.department_id = e.department_id
            )
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Employee ' || rec.employee_id || 
                               ' has invalid department_id: ' || rec.department_id);
        END LOOP;
END;
/
```

#### Deferrable Constraints

```sql
-- Constraint có thể hoãn kiểm tra đến cuối transaction
CREATE TABLE parent_table (
    id NUMBER PRIMARY KEY DEFERRABLE INITIALLY IMMEDIATE,
    name VARCHAR2(50)
);

CREATE TABLE child_table (
    id NUMBER PRIMARY KEY,
    parent_id NUMBER,
    CONSTRAINT fk_child_parent 
        FOREIGN KEY (parent_id) 
        REFERENCES parent_table(id)
        DEFERRABLE INITIALLY IMMEDIATE
);

-- Hoãn kiểm tra constraint trong transaction
SET CONSTRAINT fk_child_parent DEFERRED;
-- Thực hiện các thao tác có thể tạm thời vi phạm constraint
-- Constraint sẽ được kiểm tra khi COMMIT
COMMIT;
```

## Best Practices cho Table Design

### 1. Naming Conventions
```sql
-- Quy ước đặt tên nhất quán
-- Bảng: danh từ số nhiều (employees, departments)
-- Khóa chính: table_name_id (employee_id, department_id)
-- Khóa ngoại: referenced_table_id (department_id trong employees)
-- Constraints: type_abbreviation_table_column (pk_emp_id, fk_emp_dept)
```

### 2. Data Integrity
```sql
-- Luôn định nghĩa NOT NULL cho các cột quan trọng
-- Sử dụng CHECK constraints cho business rules
-- Tạo indexes cho foreign keys
-- Sử dụng meaningful default values
```

### 3. Performance Considerations
```sql
-- Cân nhắc denormalization cho read-heavy workloads
-- Partition lớn tables
-- Sử dụng appropriate data types
-- Monitor và optimize slow queries
```

## Bài Tập Thực Hành

### Bài Tập 1: Mở Rộng HR Schema
Thêm các bảng sau vào schema và thiết lập đúng mối quan hệ:
- `employee_benefits` (1:M với employees)
- `training_courses` và `employee_training` (M:M)
- `performance_reviews` (1:M với employees)
- `salary_history` (1:M với employees)

### Bài Tập 2: Constraints và Validation
Thực hành với các ràng buộc:
1. Thêm CHECK constraint để đảm bảo salary tăng theo thời gian trong salary_history
2. Tạo UNIQUE constraint trên composite key (employee_id, review_date) cho performance_reviews
3. Implement deferrable constraints cho circular references
4. Tạo custom validation functions

### Bài Tập 3: Schema Migration
Thực hành thay đổi cấu trúc database an toàn:
1. Thêm cột mới vào bảng có dữ liệu với 1 triệu records
2. Thay đổi data type từ VARCHAR2 sang NUMBER safely
3. Split bảng employees thành employees và employee_personal_info (1:1)
4. Migrate từ single table inheritance sang table per type

### Bài Tập 4: Performance và Indexing
Tối ưu hóa database:
1. Tạo appropriate indexes cho tất cả foreign keys
2. Implement partitioning strategy cho large tables
3. Analyze query performance với EXPLAIN PLAN
4. Create materialized views cho common queries

## Kết Luận

Trong bài học này, chúng ta đã học:

1. **Tạo bảng**: Từ cơ bản đến advanced với constraints
2. **Chỉnh sửa cấu trúc**: ADD, MODIFY, DROP columns an toàn
3. **Xóa bảng**: DROP, TRUNCATE, và recovery strategies
4. **Thiết lập relationships**: Primary keys, foreign keys, constraints
5. **Schema design**: Thực tế với HR management system
6. **Quản lý constraints**: Enable/disable, validation, troubleshooting

Những kỹ năng này là nền tảng quan trọng cho việc:
- Thiết kế database hiệu quả và scalable
- Maintain data integrity và consistency
- Implement business rules thông qua constraints
- Optimize performance với proper indexing
- Handle schema changes safely

**Bước tiếp theo**: Trong các bài học sau, chúng ta sẽ đi sâu vào các loại JOIN để truy xuất dữ liệu từ nhiều bảng có mối quan hệ.

---

**Ghi chú quan trọng**: Luôn backup dữ liệu trước khi thực hiện thay đổi cấu trúc và test thoroughly trong môi trường development trước khi apply lên production.
