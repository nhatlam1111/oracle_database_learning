# Sequences và Synonyms

Sequences và synonyms là những đối tượng cơ sở dữ liệu Oracle thiết yếu cung cấp khả năng tự động hóa và trừu tượng hóa. Sequences tạo ra các số duy nhất tự động, trong khi synonyms tạo bí danh cho các đối tượng cơ sở dữ liệu, cải thiện khả năng bảo trì code và bảo mật.

## 🎯 Mục Tiêu Học Tập

Sau khi hoàn thành phần này, bạn sẽ hiểu được:

1. **Cơ bản về Sequence**: Tạo số tự động tăng
2. **Tạo và Quản lý Sequence**: Cấu hình và bảo trì sequences
3. **Mẫu Sử dụng Sequence**: Thực hành tốt cho primary keys và đánh số
4. **Các loại Synonym**: Public vs private synonyms
5. **Lợi ích Synonym**: Tính di động code và bảo mật
6. **Quản lý Đối tượng**: Tổ chức các đối tượng cơ sở dữ liệu hiệu quả

## 📖 Mục Lục

1. [Hiểu về Sequences](#understanding-sequences)
2. [Tạo và Quản lý Sequences](#creating-and-managing-sequences)
3. [Mẫu Sử dụng Sequence](#sequence-usage-patterns)
4. [Hiểu về Synonyms](#understanding-synonyms)
5. [Tạo và Quản lý Synonyms](#creating-and-managing-synonyms)
6. [Quản lý Đối tượng Nâng cao](#advanced-object-management)
7. [Thực hành Tốt](#best-practices)

---

## Hiểu về Sequences

### Sequence là gì?

**Sequence** là một đối tượng cơ sở dữ liệu tạo ra các số duy nhất tự động. Sequences thường được sử dụng cho:

- **Giá trị Primary Key**: ID tự động tăng
- **Số giao dịch**: Định danh giao dịch duy nhất
- **Số phiên bản**: Phiên bản tài liệu hoặc bản ghi
- **Số lô**: Định danh lô xử lý

### Đặc điểm Chính của Sequences

#### **Đảm bảo Tính Duy nhất**
```sql
-- Mỗi lần gọi NEXTVAL trả về một số duy nhất
SELECT employee_seq.NEXTVAL FROM dual;  -- Trả về 1
SELECT employee_seq.NEXTVAL FROM dual;  -- Trả về 2
SELECT employee_seq.NEXTVAL FROM dual;  -- Trả về 3
```

#### **Tối ưu hóa Hiệu suất**
- Các số được phân bổ trước trong bộ nhớ
- Không cần khóa để tạo số
- Hỗ trợ đồng thời cao

#### **Tính Linh hoạt**
- Giá trị increment có thể cấu hình
- Giá trị bắt đầu và giá trị tối đa
- Tùy chọn cycling và caching

### Sequence vs Các Phương pháp Thay thế

| Phương pháp | Ưu điểm | Nhược điểm |
|--------|------|------|
| **Sequences** | Nhanh, đồng thời, đảm bảo duy nhất | Chỉ Oracle, có thể có khoảng trống |
| **MAX(ID)+1** | Đơn giản, không có khoảng trống | Chậm, vấn đề khóa, không đồng thời |
| **Application Logic** | Di động | Phức tạp, dễ bị lỗi |
| **UUID/GUID** | Duy nhất toàn cầu | Lưu trữ lớn, không tuần tự |

---

## Tạo và Quản lý Sequences

### Tạo Sequence Cơ bản

#### Sequence Đơn giản
```sql
-- Tạo sequence cơ bản bắt đầu từ 1
CREATE SEQUENCE employee_seq
START WITH 1
INCREMENT BY 1;

-- Sử dụng sequence
SELECT employee_seq.NEXTVAL FROM dual;  -- Lấy giá trị tiếp theo
SELECT employee_seq.CURRVAL FROM dual;  -- Lấy giá trị hiện tại (sau NEXTVAL)
```

#### Sequence với Tất cả Tùy chọn
```sql
CREATE SEQUENCE order_seq
    START WITH 1000          -- Bắt đầu từ 1000
    INCREMENT BY 1           -- Tăng thêm 1
    MAXVALUE 999999         -- Giá trị tối đa
    MINVALUE 1              -- Giá trị tối thiểu (cho cycling)
    NOCYCLE                 -- Không cycle khi đạt max
    CACHE 20                -- Cache 20 giá trị trong bộ nhớ
    NOORDER;                -- Không đảm bảo thứ tự trong RAC
```

### Giải thích Tham số Sequence

#### **START WITH**
```sql
-- Bắt đầu sequence từ giá trị cụ thể
CREATE SEQUENCE invoice_seq START WITH 10000;
-- Giá trị đầu tiên sẽ là 10000
```

#### **INCREMENT BY**
```sql
-- Tăng theo số lượng khác nhau
CREATE SEQUENCE even_seq INCREMENT BY 2;        -- 2, 4, 6, 8...
CREATE SEQUENCE negative_seq INCREMENT BY -1;   -- Sequence đếm ngược
```

#### **MAXVALUE và MINVALUE**
```sql
-- Đặt giới hạn
CREATE SEQUENCE bounded_seq
    START WITH 1
    MAXVALUE 1000
    MINVALUE 1;
```

#### **CYCLE vs NOCYCLE**
```sql
-- Cycling sequence (trở về điểm bắt đầu sau khi đạt max)
CREATE SEQUENCE cycling_seq
    START WITH 1
    MAXVALUE 100
    CYCLE;

-- Sau khi đạt 100, giá trị tiếp theo sẽ là 1
```

#### **CACHE**
```sql
-- Cache để cải thiện hiệu suất
CREATE SEQUENCE high_volume_seq
    CACHE 100;              -- Phân bổ trước 100 số

CREATE SEQUENCE low_volume_seq
    NOCACHE;                -- Tạo từng cái một
```

#### **ORDER vs NOORDER**
```sql
-- Quan trọng cho Oracle RAC (Real Application Clusters)
CREATE SEQUENCE rac_seq ORDER;      -- Đảm bảo thứ tự trên các nodes (chậm hơn)
CREATE SEQUENCE rac_seq NOORDER;    -- Không đảm bảo thứ tự (nhanh hơn)
```

### Sửa đổi Sequences

```sql
-- Thay đổi tham số sequence
ALTER SEQUENCE employee_seq
    INCREMENT BY 5
    MAXVALUE 100000
    CACHE 50;

-- Không thể sửa đổi giá trị START WITH
-- Phải drop và tạo lại để thay đổi START WITH
```

### Thông tin Sequence

```sql
-- Xem chi tiết sequence
SELECT sequence_name, min_value, max_value, increment_by, 
       last_number, cache_size, cycle_flag
FROM user_sequences
WHERE sequence_name = 'EMPLOYEE_SEQ';

-- Kiểm tra tất cả sequences
SELECT sequence_name, last_number, cache_size
FROM user_sequences
ORDER BY sequence_name;
```

---

## Mẫu Sử dụng Sequence

### Tạo Primary Key

#### **Phương pháp 1: Trực tiếp trong INSERT**
```sql
-- Tạo bảng với primary key được tạo bởi sequence
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE
);

-- Tạo sequence cho primary key
CREATE SEQUENCE customer_seq START WITH 1;

-- Insert sử dụng sequence
INSERT INTO customers (customer_id, customer_name, email)
VALUES (customer_seq.NEXTVAL, 'John Doe', 'john@email.com');

INSERT INTO customers (customer_id, customer_name, email)
VALUES (customer_seq.NEXTVAL, 'Jane Smith', 'jane@email.com');
```

#### **Phương pháp 2: Sử dụng Triggers (Oracle 11g và trước đó)**
```sql
-- Tạo trigger để gán ID tự động
CREATE OR REPLACE TRIGGER customers_pk_trigger
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        :NEW.customer_id := customer_seq.NEXTVAL;
    END IF;
END;

-- Bây giờ bạn có thể insert mà không cần chỉ định ID
INSERT INTO customers (customer_name, email)
VALUES ('Bob Johnson', 'bob@email.com');
```

#### **Phương pháp 3: Identity Columns (Oracle 12c+)**
```sql
-- Cách tiếp cận hiện đại với identity columns
CREATE TABLE modern_customers (
    customer_id NUMBER GENERATED ALWAYS AS IDENTITY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE
);

-- Insert mà không cần chỉ định ID
INSERT INTO modern_customers (customer_name, email)
VALUES ('Alice Brown', 'alice@email.com');
```

### Sequences Nhiều Bảng

```sql
-- Sequence chia sẻ giữa các bảng liên quan
CREATE SEQUENCE transaction_seq START WITH 1;

-- Bảng Orders
INSERT INTO sales.orders (order_id, customer_id, order_date)
VALUES (transaction_seq.NEXTVAL, 1, SYSDATE);

-- Bảng Payments (sử dụng cùng sequence để đảm bảo tính nhất quán)
INSERT INTO payments (payment_id, order_id, amount)
VALUES (transaction_seq.NEXTVAL, 1, 150.00);
```

### Reset và Bảo trì Sequence

```sql
-- Function để reset sequence về giá trị cụ thể
CREATE OR REPLACE FUNCTION reset_sequence(
    seq_name VARCHAR2,
    new_value NUMBER
) RETURN NUMBER IS
    current_val NUMBER;
    increment_val NUMBER;
BEGIN
    -- Lấy giá trị hiện tại
    EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL FROM dual' INTO current_val;
    
    -- Tính increment cần thiết
    increment_val := new_value - current_val - 1;
    
    -- Thay đổi sequence
    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || seq_name || ' INCREMENT BY ' || increment_val;
    
    -- Lấy giá trị tiếp theo (sẽ là giá trị mong muốn)
    EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL FROM dual' INTO current_val;
    
    -- Reset increment về 1
    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || seq_name || ' INCREMENT BY 1';
    
    RETURN current_val;
END;

-- Cách sử dụng
SELECT reset_sequence('customer_seq', 5000) FROM dual;
```

### Xử lý Khoảng trống Sequence

```sql
-- Sequences có thể có khoảng trống do:
-- 1. Rollbacks
-- 2. System crashes  
-- 3. Cached values không được sử dụng

-- Ví dụ về tạo khoảng trống
BEGIN
    INSERT INTO customers (customer_id, customer_name)
    VALUES (customer_seq.NEXTVAL, 'Test Customer');
    
    -- Rollback này tạo ra khoảng trống
    ROLLBACK;
END;

-- Insert tiếp theo sẽ bỏ qua số đã rollback
INSERT INTO customers (customer_id, customer_name)
VALUES (customer_seq.NEXTVAL, 'Real Customer');

-- Kiểm tra khoảng trống
SELECT customer_id, 
       LAG(customer_id) OVER (ORDER BY customer_id) as prev_id,
       customer_id - LAG(customer_id) OVER (ORDER BY customer_id) as gap
FROM customers
WHERE customer_id - LAG(customer_id) OVER (ORDER BY customer_id) > 1
ORDER BY customer_id;
```

---

## Hiểu về Synonyms

### Synonym là gì?

**Synonym** là bí danh cho một đối tượng cơ sở dữ liệu (table, view, sequence, procedure, v.v.). Synonyms cung cấp:

- **Tính Minh bạch Vị trí**: Ẩn vị trí đối tượng khỏi người dùng
- **Bảo mật**: Kiểm soát truy cập thông qua quyền synonym
- **Tính Di động**: Thay đổi đối tượng cơ sở mà không thay đổi code
- **Đơn giản hóa**: Tên ngắn hơn cho các đường dẫn đối tượng phức tạp

### Các loại Synonyms

#### **Private Synonyms**
- Thuộc sở hữu của user cụ thể
- Chỉ user đó mới truy cập được (trừ khi được cấp quyền)
- Tạo trong schema của user

#### **Public Synonyms**
- Có sẵn cho tất cả database users
- Tạo bởi privileged users (DBA)
- Không cần schema qualification

### Lợi ích của Synonyms

#### **Tính Di động Code**
```sql
-- Không có synonyms - code tùy thuộc môi trường
SELECT * FROM prod_schema.employees;      -- Production
SELECT * FROM test_schema.employees;      -- Test
SELECT * FROM dev_schema.employees;       -- Development

-- Với synonyms - code độc lập môi trường
CREATE SYNONYM employees FOR prod_schema.employees;  -- Production
CREATE SYNONYM employees FOR test_schema.employees;  -- Test  
CREATE SYNONYM employees FOR dev_schema.employees;   -- Development

-- Cùng code hoạt động trên tất cả môi trường
SELECT * FROM employees;
```

#### **Truy cập Đơn giản**
```sql
-- Tên đối tượng phức tạp
SELECT * FROM hr_application.employee_management.current_employees_view;

-- Tạo synonym để đơn giản hóa
CREATE SYNONYM emp FOR hr_application.employee_management.current_employees_view;

-- Truy cập đơn giản
SELECT * FROM emp;
```

---

## Tạo và Quản lý Synonyms

### Tạo Private Synonyms

```sql
-- Private synonym cơ bản
CREATE SYNONYM emp FOR employees;

-- Synonym cho đối tượng trong schema khác
CREATE SYNONYM sales_data FOR sales_schema.orders;

-- Synonym cho đối tượng phức tạp
CREATE SYNONYM monthly_sales FOR reporting.monthly_sales_materialized_view;
```

### Tạo Public Synonyms

```sql
-- Tạo public synonym (cần DBA privileges)
CREATE PUBLIC SYNONYM global_employees FOR hr.employees;

-- Bây giờ tất cả users có thể truy cập mà không cần schema qualification
SELECT * FROM global_employees;
```

### Synonym cho Các loại Đối tượng Khác nhau

#### **Table Synonyms**
```sql
CREATE SYNONYM cust FOR customers;
CREATE SYNONYM prod FOR sales.products;
```

#### **View Synonyms**
```sql
CREATE SYNONYM emp_summary FOR employee_department_summary;
CREATE SYNONYM sales_rpt FOR monthly_sales_report_view;
```

#### **Sequence Synonyms**
```sql
CREATE SYNONYM next_id FOR customer_seq;

-- Cách sử dụng
INSERT INTO customers (customer_id, customer_name)
VALUES (next_id.NEXTVAL, 'New Customer');
```

#### **Procedure/Function Synonyms**
```sql
CREATE SYNONYM calc_bonus FOR hr.calculate_employee_bonus;

-- Cách sử dụng
EXEC calc_bonus(employee_id => 100);
```

### Quản lý Synonyms

#### **Xem Thông tin Synonym**
```sql
-- Kiểm tra private synonyms của user
SELECT synonym_name, table_owner, table_name
FROM user_synonyms
ORDER BY synonym_name;

-- Kiểm tra tất cả synonyms mà user có thể truy cập
SELECT owner, synonym_name, table_owner, table_name
FROM all_synonyms
WHERE synonym_name LIKE 'EMP%'
ORDER BY owner, synonym_name;

-- Kiểm tra public synonyms
SELECT synonym_name, table_owner, table_name
FROM dba_synonyms
WHERE owner = 'PUBLIC'
ORDER BY synonym_name;
```

#### **Xóa Synonyms**
```sql
-- Xóa private synonym
DROP SYNONYM emp;

-- Xóa public synonym (cần DBA privileges)
DROP PUBLIC SYNONYM global_employees;
```

#### **Thay thế Synonyms**
```sql
-- Thay thế synonym với OR REPLACE
CREATE OR REPLACE SYNONYM emp FOR new_employees_table;

-- Synonyms không hỗ trợ OR REPLACE, nên phải drop trước
DROP SYNONYM emp;
CREATE SYNONYM emp FOR new_employees_table;
```

---

## Quản lý Đối tượng Nâng cao

### Database Links với Synonyms

```sql
-- Tạo database link đến remote database
CREATE DATABASE LINK remote_db
CONNECT TO hr_user IDENTIFIED BY password
USING 'remote_server';

-- Tạo synonym cho remote table
CREATE SYNONYM remote_employees FOR employees@remote_db;

-- Truy cập remote data một cách minh bạch
SELECT * FROM remote_employees WHERE department_id = 20;
```

### Schema Migration với Synonyms

```sql
-- Ứng dụng gốc trỏ đến old schema
-- CREATE SYNONYM app_employees FOR old_schema.employees;

-- Giai đoạn 1: Tạo synonyms trỏ đến old schema
CREATE SYNONYM app_employees FOR old_schema.employees;
CREATE SYNONYM app_departments FOR old_schema.departments;

-- Giai đoạn 2: Migrate data đến new schema
-- (Quá trình migration dữ liệu)

-- Giai đoạn 3: Chuyển synonyms đến new schema
DROP SYNONYM app_employees;
CREATE SYNONYM app_employees FOR new_schema.employees;

DROP SYNONYM app_departments;
CREATE SYNONYM app_departments FOR new_schema.departments;

-- Application code vẫn không thay đổi!
```

### Thiết lập Nhiều Môi trường

```sql
-- Thiết lập môi trường Development
CREATE SYNONYM config_table FOR dev_config.application_config;
CREATE SYNONYM log_table FOR dev_logs.application_logs;

-- Thiết lập môi trường Production
-- CREATE SYNONYM config_table FOR prod_config.application_config;
-- CREATE SYNONYM log_table FOR prod_logs.application_logs;

-- Cùng application code hoạt động trong cả hai môi trường
SELECT config_value FROM config_table WHERE config_name = 'MAX_USERS';
INSERT INTO log_table (log_message, log_date) VALUES ('User login', SYSDATE);
```

### Tích hợp Sequence và Synonym

```sql
-- Tạo sequence trong schema cụ thể
CREATE SEQUENCE hr.employee_id_seq START WITH 1000;

-- Tạo public synonym cho sequence
CREATE PUBLIC SYNONYM emp_id_seq FOR hr.employee_id_seq;

-- Application sử dụng synonym
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (emp_id_seq.NEXTVAL, 'John', 'Doe');

-- Dễ dàng thay đổi vị trí sequence sau này
DROP PUBLIC SYNONYM emp_id_seq;
CREATE PUBLIC SYNONYM emp_id_seq FOR new_hr.employee_id_seq;
```

---

## Thực hành Tốt

### Thực hành Tốt cho Sequence

#### **1. Quy ước Đặt tên**
```sql
-- Quy ước đặt tên tốt
CREATE SEQUENCE customer_seq;          -- Mục đích rõ ràng
CREATE SEQUENCE order_id_seq;          -- Cụ thể cho trường hợp sử dụng
CREATE SEQUENCE transaction_number_seq; -- Mô tả rõ ràng

-- Đặt tên kém
CREATE SEQUENCE seq1;                  -- Không rõ ràng
CREATE SEQUENCE s_cust;               -- Quá viết tắt
```

#### **2. Kích thước Cache Phù hợp**
```sql
-- Sequences khối lượng cao
CREATE SEQUENCE order_seq CACHE 100;   -- Insert thường xuyên

-- Sequences khối lượng thấp  
CREATE SEQUENCE config_seq CACHE 5;    -- Insert không thường xuyên

-- Single-user sequences
CREATE SEQUENCE user_pref_seq NOCACHE; -- Một user, không cần caching
```

#### **3. Giám sát và Bảo trì**
```sql
-- Giám sát việc sử dụng sequence
SELECT 
    sequence_name,
    last_number,
    cache_size,
    CASE WHEN max_value - last_number < cache_size * 10 
         THEN 'WARNING: Approaching max value'
         ELSE 'OK'
    END as status
FROM user_sequences;

-- Kiểm tra sức khỏe sequence thường xuyên
CREATE OR REPLACE PROCEDURE check_sequence_health IS
    v_warning_threshold NUMBER := 1000;
BEGIN
    FOR seq_rec IN (
        SELECT sequence_name, max_value, last_number
        FROM user_sequences
        WHERE max_value - last_number < v_warning_threshold
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('WARNING: Sequence ' || seq_rec.sequence_name || 
                           ' is approaching maximum value');
    END LOOP;
END;
```

### Thực hành Tốt cho Synonym

#### **1. Chiến lược Đặt tên Rõ ràng**
```sql
-- Tên synonym tốt
CREATE SYNONYM emp FOR employees;              -- Viết tắt rõ ràng
CREATE SYNONYM monthly_rpt FOR monthly_report_view; -- Mô tả rõ ràng

-- Tránh tên gây nhầm lẫn
-- CREATE SYNONYM data FOR employees;          -- Quá chung chung
-- CREATE SYNONYM e FOR employees;             -- Quá ngắn
```

#### **2. Tài liệu hóa**
```sql
-- Tài liệu hóa mục đích synonym
-- Synonym: emp_data
-- Mục đích: Trỏ đến bảng employee hiện tại, có thể thay đổi trong migrations
-- Tạo: 2025-01-15
-- Chủ sở hữu: HR Application Team
CREATE SYNONYM emp_data FOR current_schema.employees;
```

#### **3. Mẫu Sử dụng Nhất quán**
```sql
-- Thiết lập mẫu cho tổ chức của bạn
-- Mẫu 1: Synonyms cho cross-schema access
CREATE SYNONYM hr_employees FOR hr_schema.employees;
CREATE SYNONYM sales_orders FOR sales_schema.orders;

-- Mẫu 2: Synonyms cho sự độc lập môi trường
CREATE SYNONYM app_config FOR current_env.application_config;
CREATE SYNONYM app_logs FOR current_env.application_logs;
```

#### **4. Quản lý Quyền**
```sql
-- Cấp quyền trên underlying objects, không phải synonyms
GRANT SELECT ON employees TO app_user;
CREATE SYNONYM emp FOR employees;

-- App_user bây giờ có thể sử dụng synonym
-- GRANT SELECT ON emp TO another_user;  -- Điều này sẽ không hoạt động
-- GRANT SELECT ON employees TO another_user;  -- Điều này hoạt động
```

### Thực hành Tích hợp Tốt

#### **1. Mẫu Sequence + Trigger + Synonym**
```sql
-- Mẫu hoàn chính cho auto-incrementing IDs
-- 1. Tạo sequence
CREATE SEQUENCE customer_id_seq START WITH 1;

-- 2. Tạo synonym cho sequence
CREATE SYNONYM next_cust_id FOR customer_id_seq;

-- 3. Tạo trigger cho automatic assignment
CREATE OR REPLACE TRIGGER customers_auto_id
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        :NEW.customer_id := next_cust_id.NEXTVAL;
    END IF;
END;

-- 4. Application code gọn gàng
INSERT INTO customers (customer_name) VALUES ('New Customer');
```

#### **2. Xử lý Lỗi**
```sql
-- Xử lý lỗi synonym resolution
CREATE OR REPLACE FUNCTION safe_synonym_access(
    synonym_name VARCHAR2
) RETURN NUMBER IS
    result NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || synonym_name INTO result;
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error accessing synonym: ' || synonym_name);
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN -1;
END;
```

#### **3. Lập kế hoạch Migration**
```sql
-- Lập kế hoạch cho việc thay đổi synonym trong migrations
-- Bước 1: Tạo synonyms mới trỏ đến objects cũ
CREATE SYNONYM old_employees FOR legacy_schema.employees;

-- Bước 2: Cập nhật application để sử dụng synonyms
-- (Triển khai ứng dụng)

-- Bước 3: Tạo schema mới và migrate dữ liệu
-- (Quá trình migration dữ liệu)

-- Bước 4: Chuyển synonyms đến objects mới
DROP SYNONYM old_employees;
CREATE SYNONYM old_employees FOR new_schema.employees;

-- Bước 5: Đổi tên synonyms để loại bỏ tiền tố "old"
DROP SYNONYM old_employees;
CREATE SYNONYM employees FOR new_schema.employees;
```

---

## Tóm Tắt

Sequences và synonyms là những đối tượng Oracle cơ bản cung cấp:

### **Sequences:**
- **Tạo Số Tự động**: Đáng tin cậy, duy nhất, hiệu suất cao
- **Hỗ trợ Đồng thời**: Nhiều users có thể tạo số đồng thời
- **Tính Linh hoạt**: Có thể cấu hình increment, start, max values và caching
- **Chấp nhận Khoảng trống**: Hiểu rằng khoảng trống là bình thường và chấp nhận được

### **Synonyms:**
- **Tính Minh bạch Vị trí**: Ẩn vị trí vật lý của objects
- **Tính Di động Code**: Cùng code hoạt động trên các môi trường
- **Bảo mật**: Kiểm soát truy cập thông qua quyền synonym  
- **Đơn giản hóa**: Tên dễ dàng hơn cho các đường dẫn object phức tạp

### Điểm Chính:

1. **Sử dụng sequences cho primary keys** - Hiệu quả hơn nhiều so với MAX(ID)+1
2. **Cache sequences một cách phù hợp** - Cân bằng hiệu suất vs gap tolerance
3. **Synonyms cho phép kiến trúc linh hoạt** - Dễ dàng thay đổi underlying objects
4. **Lập kế hoạch cho migrations** - Synonyms làm cho việc thay đổi schema minh bạch
5. **Tuân theo quy ước đặt tên** - Tên rõ ràng, nhất quán cải thiện khả năng bảo trì

### Bước Tiếp Theo:

- Triển khai sequences cho tất cả các cột auto-incrementing
- Tạo synonyms cho cross-schema object access
- Thiết kế chiến lược migration sử dụng synonyms
- Giám sát hiệu suất và cách sử dụng sequence

**Tệp Thực hành**: Làm việc thông qua `src/advanced/sequences-synonyms.sql` để có ví dụ và bài tập thực hành.
