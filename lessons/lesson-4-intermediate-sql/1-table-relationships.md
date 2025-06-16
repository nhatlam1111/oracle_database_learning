# Mối Quan Hệ Bảng và Kiến Thức Cơ Bản về Join

Hiểu cách các bảng liên quan với nhau là rất quan trọng để viết các truy vấn SQL hiệu quả kết hợp dữ liệu từ nhiều nguồn. Hướng dẫn này bao gồm các khái niệm cơ bản về thiết kế cơ sở dữ liệu quan hệ và giới thiệu bạn với các thao tác JOIN.

## Mục Lục
1. [Nguyên Tắc Cơ Sở Dữ Liệu Quan Hệ](#nguyên-tắc-cơ-sở-dữ-liệu-quan-hệ)
2. [Các Loại Mối Quan Hệ](#các-loại-mối-quan-hệ)
3. [Khóa Chính và Khóa Ngoại](#khóa-chính-và-khóa-ngoại)
4. [Tính Toàn Vẹn Tham Chiếu](#tính-toàn-vẹn-tham-chiếu)
5. [Giới Thiệu về JOINs](#giới-thiệu-về-joins)
6. [Mối Quan Hệ Schema Mẫu](#mối-quan-hệ-schema-mẫu)

## Nguyên Tắc Cơ Sở Dữ Liệu Quan Hệ

### Điều Gì Làm Cho Cơ Sở Dữ Liệu "Quan Hệ"?

Cơ sở dữ liệu quan hệ dựa trên mô hình quan hệ, tổ chức dữ liệu thành các bảng (quan hệ) có thể được liên kết—hoặc liên quan—dựa trên dữ liệu chung cho mỗi bảng. Các nguyên tắc chính bao gồm:

1. **Bảng**: Dữ liệu được lưu trữ trong các bảng với các hàng (bản ghi) và cột (thuộc tính)
2. **Mối Quan Hệ**: Các bảng được kết nối thông qua các phần tử dữ liệu chung
3. **Chuẩn Hóa**: Dữ liệu được tổ chức để giảm sự dư thừa và phụ thuộc
4. **Toàn Vẹn**: Các quy tắc đảm bảo tính chính xác và nhất quán của dữ liệu

### Lợi Ích Của Thiết Kế Quan Hệ

- **Toàn Vẹn Dữ Liệu**: Ngăn ngừa dữ liệu không nhất quán hoặc không hợp lệ
- **Giảm Sự Dư Thừa**: Thông tin được lưu trữ một lần, tham chiếu ở mọi nơi
- **Tính Linh Hoạt**: Dễ dàng sửa đổi cấu trúc mà không ảnh hưởng đến ứng dụng
- **Khả Năng Mở Rộng**: Lưu trữ và truy xuất hiệu quả các tập dữ liệu lớn
- **Bảo Mật**: Kiểm soát truy cập chi tiết ở cấp độ bảng và cột

## Các Loại Mối Quan Hệ

### 1. Mối Quan Hệ Một-Nhiều (1:M)

Loại mối quan hệ phổ biến nhất trong đó một bản ghi ở Bảng A có thể liên quan đến nhiều bản ghi ở Bảng B.

**Ví dụ**: Một phòng ban có thể có nhiều nhân viên
```
DEPARTMENTS (1) ←→ (Nhiều) EMPLOYEES
```

**Logic Nghiệp Vụ**:
- Mỗi nhân viên thuộc về đúng một phòng ban
- Mỗi phòng ban có thể có không hoặc nhiều nhân viên
- Khóa ngoại được lưu trữ ở phía "nhiều" (bảng EMPLOYEES)

### 2. Mối Quan Hệ Nhiều-Nhiều (M:M)

Mối quan hệ trong đó nhiều bản ghi ở Bảng A có thể liên quan đến nhiều bản ghi ở Bảng B.

**Ví dụ**: Sản phẩm và Đơn hàng
```
PRODUCTS (Nhiều) ←→ (Nhiều) ORDERS
```

**Triển khai**: Yêu cầu bảng nối/cầu nối
```
PRODUCTS (1) ←→ (Nhiều) ORDER_ITEMS (Nhiều) ←→ (1) ORDERS
```

**Logic Nghiệp Vụ**:
- Mỗi đơn hàng có thể chứa nhiều sản phẩm
- Mỗi sản phẩm có thể xuất hiện trong nhiều đơn hàng
- Bảng ORDER_ITEMS lưu trữ mối quan hệ cộng thêm dữ liệu bổ sung (số lượng, giá)

### 3. Mối Quan Hệ Một-Một (1:1)

Mối quan hệ trong đó một bản ghi ở Bảng A liên quan đến đúng một bản ghi ở Bảng B.

**Ví dụ**: Employee và Employee_Details
```
EMPLOYEES (1) ←→ (1) EMPLOYEE_DETAILS
```

**Logic Nghiệp Vụ**:
- Mỗi nhân viên có đúng một hồ sơ chi tiết
- Mỗi hồ sơ thuộc về đúng một nhân viên
- Thường được sử dụng vì lý do bảo mật hoặc hiệu suất (tách biệt dữ liệu nhạy cảm)

### 4. Mối Quan Hệ Tự Tham Chiếu

Bảng liên quan đến chính nó, thường được sử dụng cho dữ liệu phân cấp.

**Ví dụ**: Cấu trúc quản lý nhân viên
```
EMPLOYEES (Quản lý) ←→ (Nhân viên) EMPLOYEES
```

**Logic Nghiệp Vụ**:
- Mỗi nhân viên có thể có một người quản lý (cũng là nhân viên)
- Mỗi người quản lý có thể giám sát nhiều nhân viên

## Khóa Chính và Khóa Ngoại

### Khóa Chính

Khóa chính là một cột (hoặc tổ hợp các cột) xác định duy nhất mỗi hàng trong bảng.

**Đặc điểm**:
- Phải là duy nhất cho mỗi hàng
- Không thể chứa giá trị NULL
- Không nên thay đổi sau khi được gán
- Nên đơn giản nhất có thể

**Ví dụ**:
```sql
-- Khóa chính một cột
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);

-- Khóa chính tổ hợp
CREATE TABLE order_items (
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    PRIMARY KEY (order_id, product_id)
);
```

### Khóa Ngoại

Khóa ngoại là một cột (hoặc tổ hợp các cột) tham chiếu đến khóa chính của bảng khác.

**Đặc điểm**:
- Phải khớp với giá trị khóa chính hiện có trong bảng được tham chiếu
- Có thể là NULL (trừ khi được chỉ định khác)
- Thực thi tính toàn vẹn tham chiếu
- Có thể có nhiều khóa ngoại trong một bảng

**Ví dụ**:
```sql
-- Ràng buộc khóa ngoại
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    department_id NUMBER,
    CONSTRAINT fk_emp_dept 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
);
```

## Tính Toàn Vẹn Tham Chiếu

Tính toàn vẹn tham chiếu đảm bảo rằng mối quan hệ giữa các bảng luôn nhất quán.

### Các Quy Tắc Được Thực Thi:

1. **Quy Tắc Chèn**: Không thể chèn giá trị khóa ngoại không tồn tại trong bảng cha
2. **Quy Tắc Cập Nhật**: Không thể cập nhật khóa ngoại thành giá trị không tồn tại trong bảng cha
3. **Quy Tắc Xóa**: Không thể xóa bản ghi cha nếu các bản ghi con tồn tại (mặc định)

### Tùy Chọn Cascade:

```sql
-- Cascade delete: Xóa bản ghi con khi bản ghi cha bị xóa
CONSTRAINT fk_emp_dept 
    FOREIGN KEY (department_id) 
    REFERENCES departments(department_id)
    ON DELETE CASCADE

-- Set null: Đặt khóa ngoại thành NULL khi bản ghi cha bị xóa
CONSTRAINT fk_emp_dept 
    FOREIGN KEY (department_id) 
    REFERENCES departments(department_id)
    ON DELETE SET NULL
```

## Giới Thiệu về JOINs

### JOIN là gì?

JOIN là một thao tác SQL kết hợp các hàng từ hai hoặc nhiều bảng dựa trên cột liên quan giữa chúng.

### Cú Pháp JOIN Cơ Bản

```sql
-- Cú pháp chuẩn ANSI (Khuyến nghị)
SELECT columns
FROM table1
JOIN table2 ON table1.column = table2.column;

-- Cú pháp truyền thống Oracle (Cũ)
SELECT columns
FROM table1, table2
WHERE table1.column = table2.column;
```

### Tại Sao Sử Dụng JOINs?

1. **Kết Hợp Dữ Liệu Liên Quan**: Lấy thông tin đầy đủ từ các bảng được chuẩn hóa
2. **Tránh Trùng Lặp Dữ Liệu**: Giữ dữ liệu trong các bảng phù hợp
3. **Duy Trì Toàn Vẹn Dữ Liệu**: Tận dụng mối quan hệ khóa ngoại
4. **Báo Cáo Linh Hoạt**: Tạo views kết hợp nhiều nguồn dữ liệu

### Tổng Quan Các Loại JOIN

| Loại Join | Mô Tả | Khi Nào Sử Dụng |
|-----------|-------|------------------|
| INNER JOIN | Chỉ trả về các bản ghi khớp | Khi bạn cần dữ liệu tồn tại ở cả hai bảng |
| LEFT OUTER JOIN | Trả về tất cả bản ghi bảng trái + các bản ghi khớp | Khi bạn cần tất cả bản ghi từ bảng trái |
| RIGHT OUTER JOIN | Trả về tất cả bản ghi bảng phải + các bản ghi khớp | Khi bạn cần tất cả bản ghi từ bảng phải |
| FULL OUTER JOIN | Trả về tất cả bản ghi từ cả hai bảng | Khi bạn cần tất cả bản ghi bất kể có khớp hay không |
| CROSS JOIN | Tích Cartesian của cả hai bảng | Để tạo tổ hợp hoặc dữ liệu thử nghiệm |
| SELF JOIN | Bảng được nối với chính nó | Cho các truy vấn phân cấp hoặc so sánh |

## Mối Quan Hệ Schema Mẫu

### Sơ Đồ Thực Thể Quan Hệ HR Schema

```
COUNTRIES
    ↓ (1:M)
LOCATIONS
    ↓ (1:M)
DEPARTMENTS
    ↓ (1:M)
EMPLOYEES → JOBS (M:1)
    ↓ (tự tham chiếu)
EMPLOYEES (manager_id)
```

### Mối Quan Hệ HR Chi Tiết:

1. **EMPLOYEES ↔ DEPARTMENTS**: Mỗi nhân viên thuộc về một phòng ban
2. **EMPLOYEES ↔ JOBS**: Mỗi nhân viên có một chức danh công việc
3. **EMPLOYEES ↔ EMPLOYEES**: Mỗi nhân viên có thể có một người quản lý
4. **DEPARTMENTS ↔ LOCATIONS**: Mỗi phòng ban ở một địa điểm
5. **LOCATIONS ↔ COUNTRIES**: Mỗi địa điểm ở một quốc gia

### Sơ Đồ Thực Thể Quan Hệ SALES Schema

```
CUSTOMERS
    ↓ (1:M)
ORDERS
    ↓ (1:M)
ORDER_ITEMS → PRODUCTS (M:1)
```

### Mối Quan Hệ SALES Chi Tiết:

1. **CUSTOMERS ↔ ORDERS**: Mỗi khách hàng có thể có nhiều đơn hàng
2. **ORDERS ↔ ORDER_ITEMS**: Mỗi đơn hàng có thể có nhiều mục hàng
3. **PRODUCTS ↔ ORDER_ITEMS**: Mỗi sản phẩm có thể xuất hiện trong nhiều đơn hàng

## Các Mẫu Mối Quan Hệ Phổ Biến

### 1. Bảng Tra Cứu

Bảng lưu trữ dữ liệu tham chiếu được sử dụng bởi các bảng khác.

```sql
-- Bảng countries (tra cứu)
CREATE TABLE countries (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(40)
);

-- Bảng locations (sử dụng tra cứu country)
CREATE TABLE locations (
    location_id NUMBER PRIMARY KEY,
    street_address VARCHAR2(40),
    city VARCHAR2(30),
    country_id CHAR(2),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);
```

### 2. Bảng Cầu Nối/Nối

Bảng giải quyết mối quan hệ nhiều-nhiều.

```sql
-- Nhiều-nhiều giữa orders và products
CREATE TABLE order_items (
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### 3. Bảng Phân Cấp

Bảng tự tham chiếu cho cấu trúc cây.

```sql
-- Cấu trúc phân cấp nhân viên
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(20),
    last_name VARCHAR2(25),
    manager_id NUMBER,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);
```

## Thực Hành Tốt Nhất Cho Mối Quan Hệ

### 1. Quy Ước Đặt Tên

- Sử dụng quy ước đặt tên nhất quán cho khóa chính và khóa ngoại
- Tên khóa ngoại nên chỉ ra bảng được tham chiếu
- Sử dụng tên ràng buộc có ý nghĩa

```sql
-- Đặt tên tốt
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    department_id NUMBER,
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
);
```

### 2. Tạo Index cho Khóa Ngoại

Luôn tạo index trên các cột khóa ngoại để có hiệu suất JOIN tốt hơn.

```sql
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_emp_manager_id ON employees(manager_id);
```

### 3. Tránh Tham Chiếu Vòng Tròn

Thiết kế mối quan hệ để ngăn ngừa phụ thuộc vòng tròn.

```sql
-- Tránh: A tham chiếu B, B tham chiếu C, C tham chiếu A
-- Thay vào đó: Sử dụng mối quan hệ phân cấp hoặc một chiều
```

### 4. Xem Xét Cardinality Mối Quan Hệ

Thiết kế bảng dựa trên yêu cầu nghiệp vụ thực tế.

```sql
-- Nếu khách hàng có thể có nhiều địa chỉ
CREATE TABLE customer_addresses (
    customer_id NUMBER,
    address_type VARCHAR2(10), -- 'HOME', 'WORK', 'BILLING'
    street_address VARCHAR2(100),
    -- ...
    PRIMARY KEY (customer_id, address_type)
);
```

## Hiểu Về Thực Thi Truy Vấn

### Cách JOINs Hoạt Động Bên Trong

1. **Truy Cập Bảng**: Cơ sở dữ liệu truy cập các bảng cần thiết
2. **Đánh Giá Điều Kiện Join**: So sánh giá trị dựa trên điều kiện join
3. **Xây Dựng Tập Kết Quả**: Kết hợp các hàng khớp
4. **Lọc**: Áp dụng điều kiện mệnh đề WHERE
5. **Sắp Xếp**: Áp dụng ORDER BY nếu được chỉ định

### Thuật Toán Join

- **Nested Loop Join**: Tốt cho bảng nhỏ hoặc khi một bảng nhỏ hơn nhiều
- **Hash Join**: Hiệu quả cho bảng lớn với điều kiện bằng nhau
- **Sort-Merge Join**: Tốt cho dữ liệu đã sắp xếp hoặc điều kiện không bằng

## Khắc Phục Các Vấn Đề Phổ Biến

### 1. Tích Cartesian

```sql
-- Vấn đề: Thiếu điều kiện join
SELECT * FROM employees, departments;

-- Giải pháp: Thêm điều kiện join phù hợp
SELECT * FROM employees e
JOIN departments d ON e.department_id = d.department_id;
```

### 2. Số Lượng Kết Quả Không Mong Đợi

```sql
-- Vấn đề: Hàng trùng lặp do mối quan hệ một-nhiều
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Nếu bạn cần nhân viên duy nhất, hãy xem xét bạn thực sự muốn đạt được gì
```

### 3. Xử Lý NULL trong Mối Quan Hệ

```sql
-- Nhân viên không có phòng ban sẽ không xuất hiện trong INNER JOIN
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

## Bước Tiếp Theo

Bây giờ bạn đã hiểu về mối quan hệ bảng và kiến thức cơ bản về JOIN, bạn đã sẵn sàng để:

1. **Thực Hành INNER JOINs**: Bắt đầu với joins hai bảng đơn giản
2. **Khám Phá OUTER JOINs**: Học khi nào bao gồm các bản ghi không khớp
3. **Thành Thạo JOINs Phức Tạp**: Làm việc với nhiều bảng và điều kiện
4. **Tối Ưu Hiệu Suất**: Học về indexes và kế hoạch thực thi

Các bài học tiếp theo sẽ đi sâu vào từng loại JOIN với các ví dụ thực tế và tình huống thực tế.

---

**Điểm Chính**: Hiểu về mối quan hệ là nền tảng của việc truy vấn SQL hiệu quả. Hãy dành thời gian phân tích mô hình dữ liệu của bạn trước khi viết JOINs, và luôn xem xét logic nghiệp vụ đằng sau các mối quan hệ.
