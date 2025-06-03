# Tạo Sample Database

Hướng dẫn này sẽ giúp bạn tạo các sample databases toàn diện và điền vào chúng dữ liệu thực tế để học các khái niệm Oracle Database. Bạn sẽ tạo nhiều schemas kết nối với nhau đại diện cho các tình huống thực tế trong doanh nghiệp.

## Tổng Quan Về Sample Schemas

Chúng ta sẽ tạo một số schemas kết nối với nhau đại diện cho các tình huống kinh doanh thường gặp:

1. **HR Schema** - Nhân sự (employees, departments, jobs)
2. **SALES Schema** - Quản lý bán hàng và tồn kho
3. **FINANCE Schema** - Giao dịch tài chính và kế toán
4. **CUSTOMER Schema** - Quản lý quan hệ khách hàng

## Điều Kiện Tiên Quyết

- Oracle Database đã được cài đặt và đang chạy
- SQL client đã được cấu hình và kết nối
- Quyền quản trị (truy cập SYSTEM hoặc SYSDBA)

## Schema 1: HR (Nhân Sự)

### Tổng Quan Tables
- **DEPARTMENTS** - Các phòng ban công ty
- **JOBS** - Vị trí công việc và khoảng lương
- **EMPLOYEES** - Thông tin nhân viên
- **JOB_HISTORY** - Lịch sử thay đổi công việc của nhân viên
- **LOCATIONS** - Vị trí văn phòng
- **COUNTRIES** - Thông tin quốc gia
- **REGIONS** - Các khu vực địa lý

### Tạo HR Schema

```sql
-- Tạo HR user/schema
CREATE USER hr IDENTIFIED BY hr123;
GRANT CONNECT, RESOURCE TO hr;
GRANT CREATE VIEW TO hr;
ALTER USER hr QUOTA UNLIMITED ON USERS;

-- Kết nối với HR user để tạo table
CONNECT hr/hr123;
```

### Tạo Tables

#### 1. REGIONS Table
```sql
CREATE TABLE regions (
    region_id    NUMBER(10) PRIMARY KEY,
    region_name  VARCHAR2(25) NOT NULL
);

-- Chèn dữ liệu mẫu
INSERT INTO regions VALUES (1, 'North America');
INSERT INTO regions VALUES (2, 'Europe');
INSERT INTO regions VALUES (3, 'Asia Pacific');
INSERT INTO regions VALUES (4, 'Middle East and Africa');
COMMIT;
```

#### 2. COUNTRIES Table
```sql
CREATE TABLE countries (
    country_id   CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(40) NOT NULL,
    region_id    NUMBER(10),
    CONSTRAINT countries_region_fk 
        FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO countries VALUES ('US', 'United States', 1);
INSERT INTO countries VALUES ('CA', 'Canada', 1);
INSERT INTO countries VALUES ('UK', 'United Kingdom', 2);
INSERT INTO countries VALUES ('DE', 'Germany', 2);
INSERT INTO countries VALUES ('JP', 'Japan', 3);
INSERT INTO countries VALUES ('AU', 'Australia', 3);
COMMIT;
```

#### 3. LOCATIONS Table
```sql
CREATE TABLE locations (
    location_id    NUMBER(4) PRIMARY KEY,
    street_address VARCHAR2(40),
    postal_code    VARCHAR2(12),
    city           VARCHAR2(30) NOT NULL,
    state_province VARCHAR2(25),
    country_id     CHAR(2),
    CONSTRAINT locations_country_fk 
        FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO locations VALUES (1000, '1297 Via Cola di Rie', '00989', 'Roma', NULL, 'US');
INSERT INTO locations VALUES (1100, '93091 Calle della Testa', '10934', 'Venice', NULL, 'US');
INSERT INTO locations VALUES (1200, '2017 Shinjuku-ku', '1689', 'Tokyo', 'Tokyo Prefecture', 'JP');
INSERT INTO locations VALUES (1300, '9450 Kamiya-cho', '6823', 'Hiroshima', NULL, 'JP');
INSERT INTO locations VALUES (1400, '2014 Jabberwocky Rd', '26192', 'Southlake', 'Texas', 'US');
COMMIT;
```

#### 4. DEPARTMENTS Table
```sql
CREATE TABLE departments (
    department_id   NUMBER(4) PRIMARY KEY,
    department_name VARCHAR2(30) NOT NULL,
    manager_id      NUMBER(6),
    location_id     NUMBER(4),
    CONSTRAINT departments_location_fk 
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO departments VALUES (10, 'Administration', 200, 1000);
INSERT INTO departments VALUES (20, 'Marketing', 201, 1100);
INSERT INTO departments VALUES (30, 'Purchasing', 114, 1200);
INSERT INTO departments VALUES (40, 'Human Resources', 203, 1300);
INSERT INTO departments VALUES (50, 'Shipping', 121, 1400);
INSERT INTO departments VALUES (60, 'IT', 103, 1000);
INSERT INTO departments VALUES (70, 'Public Relations', 204, 1100);
INSERT INTO departments VALUES (80, 'Sales', 145, 1200);
INSERT INTO departments VALUES (90, 'Executive', 100, 1000);
COMMIT;
```

#### 5. JOBS Table
```sql
CREATE TABLE jobs (
    job_id     VARCHAR2(10) PRIMARY KEY,
    job_title  VARCHAR2(35) NOT NULL,
    min_salary NUMBER(6),
    max_salary NUMBER(6)
);

-- Chèn dữ liệu mẫu
INSERT INTO jobs VALUES ('AD_PRES', 'President', 20080, 40000);
INSERT INTO jobs VALUES ('AD_VP', 'Vice President', 15000, 30000);
INSERT INTO jobs VALUES ('AD_ASST', 'Administrative Assistant', 3000, 6000);
INSERT INTO jobs VALUES ('FI_MGR', 'Finance Manager', 8200, 16000);
INSERT INTO jobs VALUES ('FI_ACCOUNT', 'Accountant', 4200, 9000);
INSERT INTO jobs VALUES ('AC_MGR', 'Accounting Manager', 8200, 16000);
INSERT INTO jobs VALUES ('AC_ACCOUNT', 'Public Accountant', 4200, 9000);
INSERT INTO jobs VALUES ('SA_MAN', 'Sales Manager', 10000, 20080);
INSERT INTO jobs VALUES ('SA_REP', 'Sales Representative', 6000, 12008);
INSERT INTO jobs VALUES ('PU_MAN', 'Purchasing Manager', 8000, 15000);
INSERT INTO jobs VALUES ('PU_CLERK', 'Purchasing Clerk', 2500, 5500);
INSERT INTO jobs VALUES ('ST_MAN', 'Stock Manager', 5500, 8500);
INSERT INTO jobs VALUES ('ST_CLERK', 'Stock Clerk', 2008, 5000);
INSERT INTO jobs VALUES ('SH_CLERK', 'Shipping Clerk', 2500, 5500);
INSERT INTO jobs VALUES ('IT_PROG', 'Programmer', 4000, 10000);
INSERT INTO jobs VALUES ('MK_MAN', 'Marketing Manager', 9000, 15000);
INSERT INTO jobs VALUES ('MK_REP', 'Marketing Representative', 4000, 9000);
INSERT INTO jobs VALUES ('HR_REP', 'Human Resources Representative', 4000, 9000);
INSERT INTO jobs VALUES ('PR_REP', 'Public Relations Representative', 4500, 10500);
COMMIT;
```

#### 6. EMPLOYEES Table
```sql
CREATE TABLE employees (
    employee_id    NUMBER(6) PRIMARY KEY,
    first_name     VARCHAR2(20),
    last_name      VARCHAR2(25) NOT NULL,
    email          VARCHAR2(25) NOT NULL UNIQUE,
    phone_number   VARCHAR2(20),
    hire_date      DATE NOT NULL,
    job_id         VARCHAR2(10) NOT NULL,
    salary         NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id     NUMBER(6),
    department_id  NUMBER(4),
    CONSTRAINT employees_job_fk 
        FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT employees_dept_fk 
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT employees_manager_fk 
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO employees VALUES (100, 'Steven', 'King', 'SKING', '515.123.4567', DATE '1987-06-17', 'AD_PRES', 24000, NULL, NULL, 90);
INSERT INTO employees VALUES (101, 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', DATE '1989-09-21', 'AD_VP', 17000, NULL, 100, 90);
INSERT INTO employees VALUES (102, 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', DATE '1993-01-13', 'AD_VP', 17000, NULL, 100, 90);
INSERT INTO employees VALUES (103, 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', DATE '1990-01-03', 'IT_PROG', 9000, NULL, 102, 60);
INSERT INTO employees VALUES (104, 'Bruce', 'Ernst', 'BERNST', '590.423.4568', DATE '1991-05-21', 'IT_PROG', 6000, NULL, 103, 60);
INSERT INTO employees VALUES (105, 'David', 'Austin', 'DAUSTIN', '590.423.4569', DATE '1997-06-25', 'IT_PROG', 4800, NULL, 103, 60);
INSERT INTO employees VALUES (106, 'Valli', 'Pataballa', 'VPATABAL', '590.423.4560', DATE '1998-02-05', 'IT_PROG', 4800, NULL, 103, 60);
INSERT INTO employees VALUES (107, 'Diana', 'Lorentz', 'DLORENTZ', '590.423.5567', DATE '1999-02-07', 'IT_PROG', 4200, NULL, 103, 60);
INSERT INTO employees VALUES (108, 'Nancy', 'Greenberg', 'NGREENBE', '515.124.4569', DATE '1994-08-17', 'FI_MGR', 12008, NULL, 101, 100);
INSERT INTO employees VALUES (109, 'Daniel', 'Faviet', 'DFAVIET', '515.124.4169', DATE '1994-08-16', 'FI_ACCOUNT', 9000, NULL, 108, 100);
INSERT INTO employees VALUES (110, 'John', 'Chen', 'JCHEN', '515.124.4269', DATE '1997-09-28', 'FI_ACCOUNT', 8200, NULL, 108, 100);
COMMIT;
```

#### 7. JOB_HISTORY Table
```sql
CREATE TABLE job_history (
    employee_id   NUMBER(6) NOT NULL,
    start_date    DATE NOT NULL,
        end_date      DATE NOT NULL,
    job_id        VARCHAR2(10) NOT NULL,
    department_id NUMBER(4),
    CONSTRAINT job_history_pk 
        PRIMARY KEY (employee_id, start_date),
    CONSTRAINT job_history_emp_fk 
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT job_history_job_fk 
        FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT job_history_dept_fk 
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT job_history_date_check 
        CHECK (end_date > start_date)
);

-- Chèn dữ liệu mẫu
INSERT INTO job_history VALUES (102, DATE '1993-01-13', DATE '1998-07-24', 'IT_PROG', 60);
INSERT INTO job_history VALUES (101, DATE '1989-09-21', DATE '1993-10-27', 'AC_ACCOUNT', 110);
INSERT INTO job_history VALUES (101, DATE '1993-10-28', DATE '1997-03-15', 'AC_MGR', 110);
INSERT INTO job_history VALUES (100, DATE '1987-06-17', DATE '1995-07-24', 'AD_ASST', 90);
INSERT INTO job_history VALUES (103, DATE '1990-01-03', DATE '1992-12-31', 'AC_ACCOUNT', 110);
COMMIT;
```

## Schema 2: SALES (Bán Hàng và Tồn Kho)

### Tạo SALES Schema
```sql
-- Kết nối với SYSTEM để tạo user
CONNECT system/password;

CREATE USER sales IDENTIFIED BY sales123;
GRANT CONNECT, RESOURCE TO sales;
GRANT CREATE VIEW TO sales;
ALTER USER sales QUOTA UNLIMITED ON USERS;

-- Kết nối với SALES user
CONNECT sales/sales123;
```

### Tạo Sales Tables

#### 1. CUSTOMERS Table
```sql
CREATE TABLE customers (
    customer_id   NUMBER(10) PRIMARY KEY,
    company_name  VARCHAR2(50) NOT NULL,
    contact_name  VARCHAR2(50),
    contact_title VARCHAR2(30),
    address       VARCHAR2(100),
    city          VARCHAR2(30),
    region        VARCHAR2(15),
    postal_code   VARCHAR2(10),
    country       VARCHAR2(15),
    phone         VARCHAR2(24),
    email         VARCHAR2(50)
);

-- Chèn dữ liệu mẫu
INSERT INTO customers VALUES (1, 'Alfreds Futterkiste', 'Maria Anders', 'Sales Representative', 
    'Obere Str. 57', 'Berlin', NULL, '12209', 'Germany', '030-0074321', 'maria@alfreds.com');
INSERT INTO customers VALUES (2, 'Ana Trujillo Emparedados', 'Ana Trujillo', 'Owner', 
    'Avda. de la Constitución 2222', 'México D.F.', NULL, '05021', 'Mexico', '(5) 555-4729', 'ana@trujillo.com');
INSERT INTO customers VALUES (3, 'Antonio Moreno Taquería', 'Antonio Moreno', 'Owner', 
    'Mataderos 2312', 'México D.F.', NULL, '05023', 'Mexico', '(5) 555-3932', 'antonio@moreno.com');
COMMIT;
```

#### 2. CATEGORIES Table
```sql
CREATE TABLE categories (
    category_id   NUMBER(10) PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL,
    description   VARCHAR2(200)
);

-- Chèn dữ liệu mẫu
INSERT INTO categories VALUES (1, 'Beverages', 'Soft drinks, coffees, teas, beers, and ales');
INSERT INTO categories VALUES (2, 'Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings');
INSERT INTO categories VALUES (3, 'Dairy Products', 'Cheeses');
INSERT INTO categories VALUES (4, 'Grains/Cereals', 'Breads, crackers, pasta, and cereal');
INSERT INTO categories VALUES (5, 'Meat/Poultry', 'Prepared meats');
INSERT INTO categories VALUES (6, 'Produce', 'Dried fruit and bean curd');
INSERT INTO categories VALUES (7, 'Seafood', 'Seaweed and fish');
COMMIT;
```

#### 3. PRODUCTS Table
```sql
CREATE TABLE products (
    product_id       NUMBER(10) PRIMARY KEY,
    product_name     VARCHAR2(50) NOT NULL,
    category_id      NUMBER(10),
    unit_price       NUMBER(10,2),
    units_in_stock   NUMBER(5),
    units_on_order   NUMBER(5),
    reorder_level    NUMBER(5),
    discontinued     NUMBER(1) DEFAULT 0,
    CONSTRAINT products_category_fk 
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO products VALUES (1, 'Chai', 1, 18.00, 39, 0, 10, 0);
INSERT INTO products VALUES (2, 'Chang', 1, 19.00, 17, 40, 25, 0);
INSERT INTO products VALUES (3, 'Aniseed Syrup', 2, 10.00, 13, 70, 25, 0);
INSERT INTO products VALUES (4, 'Chef Antons Cajun Seasoning', 2, 22.00, 53, 0, 0, 0);
INSERT INTO products VALUES (5, 'Chef Antons Gumbo Mix', 2, 21.35, 0, 0, 0, 1);
COMMIT;
```

#### 4. ORDERS Table
```sql
CREATE TABLE orders (
    order_id        NUMBER(10) PRIMARY KEY,
    customer_id     NUMBER(10),
    order_date      DATE,
    required_date   DATE,
    shipped_date    DATE,
    freight         NUMBER(10,2),
    ship_name       VARCHAR2(50),
    ship_address    VARCHAR2(100),
    ship_city       VARCHAR2(30),
    ship_region     VARCHAR2(15),
    ship_postal_code VARCHAR2(10),
    ship_country    VARCHAR2(15),
    CONSTRAINT orders_customer_fk 
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO orders VALUES (10248, 1, DATE '2023-07-04', DATE '2023-08-01', DATE '2023-07-16', 32.38,
    'Vins et alcools Chevalier', '59 rue de lAbbaye', 'Reims', NULL, '51100', 'France');
INSERT INTO orders VALUES (10249, 2, DATE '2023-07-05', DATE '2023-08-16', DATE '2023-07-10', 11.61,
    'Toms Spezialitäten', 'Luisenstr. 48', 'Münster', NULL, '44087', 'Germany');
COMMIT;
```

#### 5. ORDER_DETAILS Table
```sql
CREATE TABLE order_details (
    order_id   NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    unit_price NUMBER(10,2) NOT NULL,
    quantity   NUMBER(5) NOT NULL,
    discount   NUMBER(4,2) DEFAULT 0,
    CONSTRAINT order_details_pk 
        PRIMARY KEY (order_id, product_id),
    CONSTRAINT order_details_order_fk 
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT order_details_product_fk 
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO order_details VALUES (10248, 1, 18.00, 12, 0);
INSERT INTO order_details VALUES (10248, 2, 19.00, 10, 0);
INSERT INTO order_details VALUES (10249, 3, 10.00, 5, 0);
COMMIT;
```

## Tạo Views và Indexes

### Views Hữu Ích
```sql
-- Chi tiết nhân viên với thông tin phòng ban và công việc
CREATE OR REPLACE VIEW emp_details_view AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.phone_number,
    e.hire_date,
    j.job_title,
    e.salary,
    d.department_name,
    l.city,
    c.country_name
FROM hr.employees e
JOIN hr.jobs j ON e.job_id = j.job_id
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.locations l ON d.location_id = l.location_id
JOIN hr.countries c ON l.country_id = c.country_id;

-- View tóm tắt bán hàng
CREATE OR REPLACE VIEW sales_summary_view AS
SELECT 
    o.order_id,
    c.company_name,
    o.order_date,
    COUNT(od.product_id) AS total_items,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_amount
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN sales.order_details od ON o.order_id = od.order_id
GROUP BY o.order_id, c.company_name, o.order_date;
```

### Performance Indexes
```sql
-- HR Schema indexes
CREATE INDEX emp_name_idx ON hr.employees(last_name, first_name);
CREATE INDEX emp_dept_idx ON hr.employees(department_id);
CREATE INDEX emp_job_idx ON hr.employees(job_id);

-- Sales Schema indexes
CREATE INDEX orders_date_idx ON sales.orders(order_date);
CREATE INDEX orders_customer_idx ON sales.orders(customer_id);
CREATE INDEX products_category_idx ON sales.products(category_id);
```

## Sample Queries Để Testing

### HR Schema Queries
```sql
-- Thông tin nhân viên cơ bản
SELECT employee_id, first_name, last_name, email, salary
FROM hr.employees
WHERE department_id = 60;

-- Số lượng nhân viên theo phòng ban
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;

-- Phân tích lương theo công việc
SELECT j.job_title, 
       COUNT(e.employee_id) AS employee_count,
       AVG(e.salary) AS avg_salary,
       MIN(e.salary) AS min_salary,
       MAX(e.salary) AS max_salary
FROM hr.jobs j
JOIN hr.employees e ON j.job_id = e.job_id
GROUP BY j.job_title
ORDER BY avg_salary DESC;
```

### Sales Schema Queries
```sql
-- Phân tích bán hàng sản phẩm
SELECT p.product_name,
       SUM(od.quantity) AS total_quantity_sold,
       SUM(od.unit_price * od.quantity) AS total_revenue
FROM sales.products p
JOIN sales.order_details od ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Tóm tắt đơn hàng khách hàng
SELECT c.company_name,
       COUNT(o.order_id) AS total_orders,
       SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_details od ON o.order_id = od.order_id
GROUP BY c.company_name
ORDER BY total_spent DESC;
```

## Scripts Tạo Dữ Liệu

### Tạo Thêm Sample Data
```sql
-- Tạo thêm nhân viên (chạy với HR user)
INSERT INTO hr.employees 
SELECT 
    employee_id + 1000,
    'Test' || (employee_id + 1000),
    'User' || (employee_id + 1000),
    'TEST' || (employee_id + 1000),
    '555.123.' || LPAD(employee_id + 1000, 4, '0'),
    hire_date + (employee_id * 10),
    job_id,
    salary + (employee_id * 100),
    commission_pct,
    manager_id,
    department_id
FROM hr.employees
WHERE employee_id BETWEEN 100 AND 110;

-- Tạo thêm đơn hàng (chạy với SALES user)
INSERT INTO sales.orders
SELECT 
    order_id + 1000,
    customer_id,
    order_date + (order_id * 5),
    required_date + (order_id * 5),
    shipped_date + (order_id * 5),
    freight * 1.5,
    ship_name,
    ship_address,
    ship_city,
    ship_region,
    ship_postal_code,
    ship_country
FROM sales.orders
WHERE order_id BETWEEN 10248 AND 10249;

COMMIT;
```

## Scripts Bảo Trì Database

### Scripts Dọn Dẹp
```sql
-- Xóa dữ liệu test
DELETE FROM hr.employees WHERE employee_id > 1000;
DELETE FROM sales.orders WHERE order_id > 1000;
COMMIT;

-- Reset sequences (nếu sử dụng sequences)
-- ALTER SEQUENCE employee_seq RESTART START WITH 200;
```

### Lệnh Backup
```sql
-- Export schema data
-- expdp system/password schemas=HR,SALES directory=DATA_PUMP_DIR dumpfile=sample_schemas.dmp

-- Import schema data
-- impdp system/password schemas=HR,SALES directory=DATA_PUMP_DIR dumpfile=sample_schemas.dmp
```

## Xác Minh và Testing

### Kiểm Tra Tính Toàn Vẹn Dữ Liệu
```sql
-- Kiểm tra referential integrity
SELECT 'Orphaned employees' AS check_type, COUNT(*) AS count
FROM hr.employees e
WHERE e.department_id IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM hr.departments d WHERE d.department_id = e.department_id)
UNION ALL
SELECT 'Orphaned orders', COUNT(*)
FROM sales.orders o
WHERE NOT EXISTS (SELECT 1 FROM sales.customers c WHERE c.customer_id = o.customer_id);

-- Kiểm tra tính nhất quán dữ liệu
SELECT 'Employees without managers' AS check_type, COUNT(*) AS count
FROM hr.employees 
WHERE manager_id IS NOT NULL 
  AND manager_id NOT IN (SELECT employee_id FROM hr.employees)
UNION ALL
SELECT 'Products with negative stock', COUNT(*)
FROM sales.products 
WHERE units_in_stock < 0;
```

### Performance Testing
```sql
-- Test hiệu suất truy vấn
SET TIMING ON;
SELECT * FROM emp_details_view WHERE salary > 10000;
SELECT * FROM sales_summary_view WHERE total_amount > 1000;
SET TIMING OFF;
```

## Các Bước Tiếp Theo

Môi trường sample database của bạn giờ đã sẵn sàng! Bạn có thể:

1. **Khám Phá Dữ Liệu**: Sử dụng câu lệnh SELECT để duyệt các tables
2. **Thực Hành Truy Vấn**: Thử các sample queries được cung cấp
3. **Học Relationships**: Nghiên cứu các foreign key relationships
4. **Thử Nghiệm**: Sửa đổi và mở rộng sample data
5. **Bắt Đầu Học**: Tiến hành Bài 3 cho các truy vấn SQL cơ bản

Sample database cung cấp các tình huống thực tế để học các khái niệm Oracle Database và kỹ thuật lập trình SQL.
