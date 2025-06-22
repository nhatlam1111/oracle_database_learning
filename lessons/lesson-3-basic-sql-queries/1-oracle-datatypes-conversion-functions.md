# Oracle Database - Hàm Chuyển Đổi Built-in Functions Chi Tiết

> **File bổ sung cho**: [1-oracle-datatypes.md](./1-oracle-datatypes.md)
>
> Hướng dẫn chi tiết về tất cả các hàm chuyển đổi built-in functions có sẵn trong Oracle Database, bao gồm cách sử dụng, tham số, trường hợp sử dụng và xử lý lỗi.

## 📋 Bảng Tham Khảo Nhanh - Hàm Chuyển Đổi Oracle

> **💡 Tip**: Ctrl+F để tìm kiếm nhanh hàm cần dùng

### Hàm Chuyển Đổi Cơ Bản

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `TO_NUMBER()` | Chuỗi → Số | `TO_NUMBER(char [, format])` | `TO_NUMBER('123.45')` |
| `TO_CHAR()` | Số/Ngày → Chuỗi | `TO_CHAR(value [, format])` | `TO_CHAR(123.45, '999.99')` |
| `TO_DATE()` | Chuỗi → Ngày | `TO_DATE(char, format)` | `TO_DATE('2025-06-22', 'YYYY-MM-DD')` |
| `TO_TIMESTAMP()` | Chuỗi → Timestamp | `TO_TIMESTAMP(char, format)` | `TO_TIMESTAMP('2025-06-22 14:30:25.123', 'YYYY-MM-DD HH24:MI:SS.FF')` |
| `CAST()` | Chuyển đổi chung | `CAST(expr AS datatype)` | `CAST('123' AS NUMBER)` |

### Hàm Timestamp và Múi Giờ

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `TO_TIMESTAMP_TZ()` | Chuỗi → Timestamp có múi giờ | `TO_TIMESTAMP_TZ(char, format)` | `TO_TIMESTAMP_TZ('2025-06-22 14:30:25 +07:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM')` |
| `FROM_TZ()` | Thêm múi giờ vào Timestamp | `FROM_TZ(timestamp, timezone)` | `FROM_TZ(TIMESTAMP '2025-06-22 14:30:25', '+07:00')` |
| `AT TIME ZONE` | Chuyển múi giờ | `timestamp AT TIME ZONE zone` | `SYSTIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh'` |

### Hàm Xử Lý NULL

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `NVL()` | Thay NULL bằng giá trị khác | `NVL(expr1, expr2)` | `NVL(salary, 0)` |
| `NVL2()` | Xử lý cả NULL và NOT NULL | `NVL2(expr1, expr2, expr3)` | `NVL2(commission, 'Có hoa hồng', 'Không có')` |
| `COALESCE()` | Trả về giá trị đầu tiên NOT NULL | `COALESCE(expr1, expr2, ...)` | `COALESCE(phone1, phone2, email)` |
| `NULLIF()` | Trả NULL nếu 2 giá trị bằng nhau | `NULLIF(expr1, expr2)` | `NULLIF(old_value, new_value)` |

### Hàm RAW và HEX

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `HEXTORAW()` | Chuỗi hex → RAW | `HEXTORAW(char)` | `HEXTORAW('48656C6C6F')` |
| `RAWTOHEX()` | RAW → Chuỗi hex | `RAWTOHEX(raw)` | `RAWTOHEX(UTL_RAW.CAST_TO_RAW('Hello'))` |
| `UTL_RAW.CAST_TO_RAW()` | Chuỗi → RAW | `UTL_RAW.CAST_TO_RAW(char)` | `UTL_RAW.CAST_TO_RAW('Hello')` |
| `UTL_RAW.CAST_TO_VARCHAR2()` | RAW → Chuỗi | `UTL_RAW.CAST_TO_VARCHAR2(raw)` | `UTL_RAW.CAST_TO_VARCHAR2(raw_data)` |

### Hàm CLOB/BLOB

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `TO_CLOB()` | VARCHAR2 → CLOB | `TO_CLOB(char)` | `TO_CLOB('Văn bản dài...')` |
| `TO_NCLOB()` | NVARCHAR2 → NCLOB | `TO_NCLOB(nchar)` | `TO_NCLOB(N'Unicode text')` |

### Hàm Kiểm Tra (Oracle 12c+)

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `VALIDATE_CONVERSION()` | Kiểm tra có thể chuyển đổi | `VALIDATE_CONVERSION(expr AS datatype)` | `VALIDATE_CONVERSION('123' AS NUMBER)` |
| `DEFAULT ... ON CONVERSION ERROR` | Xử lý lỗi chuyển đổi | `TO_NUMBER(char, DEFAULT value ON CONVERSION ERROR)` | `TO_NUMBER('abc', DEFAULT 0 ON CONVERSION ERROR)` |

### Hàm Chuyển Đổi Bộ Ký Tự

| **Hàm** | **Mục Đích** | **Cú Pháp** | **Ví Dụ** |
|----------|-------------|-------------|----------|
| `CONVERT()` | Chuyển đổi bộ ký tự | `CONVERT(char, dest_charset [, src_charset])` | `CONVERT('Hội nghị', 'UTF8', 'AL32UTF8')` |

### Format Models Phổ Biến

#### 🔢 Cho Số (NUMBER):
| **Format** | **Mô Tả** | **Ví Dụ Input** | **Kết Quả** |
|------------|-----------|-----------------|-------------|
| `999.99` | Số với 2 chữ số thập phân | `TO_CHAR(123.45, '999.99')` | `' 123.45'` |
| `9,999.99` | Có dấu phẩy phân cách | `TO_CHAR(1234.56, '9,999.99')` | `' 1,234.56'` |
| `$9,999.99` | Có ký hiệu đô la | `TO_CHAR(1234.56, '$9,999.99')` | `' $1,234.56'` |
| `L9,999.99` | Ký hiệu tiền tệ local | `TO_CHAR(1234.56, 'L9,999.99')` | `' ₫1,234.56'` |
| `999.99PR` | Số âm trong ngoặc | `TO_CHAR(-123.45, '999.99PR')` | `'<123.45>'` |
| `S999.99` | Dấu +/- ở đầu | `TO_CHAR(123.45, 'S999.99')` | `'+123.45'` |
| `9.99EEEE` | Ký pháp khoa học | `TO_CHAR(1234567, '9.99EEEE')` | `' 1.23E+06'` |
| `RN` | Số La Mã (hoa) | `TO_CHAR(1994, 'RN')` | `'MCMXCIV'` |

#### 📅 Cho Ngày (DATE/TIMESTAMP):
| **Format** | **Mô Tả** | **Ví Dụ** | **Kết Quả** |
|------------|-----------|-----------|-------------|
| `DD/MM/YYYY` | Ngày/tháng/năm | `TO_CHAR(SYSDATE, 'DD/MM/YYYY')` | `'22/06/2025'` |
| `DD-MON-YYYY` | Ngày-tháng-năm | `TO_CHAR(SYSDATE, 'DD-MON-YYYY')` | `'22-JUN-2025'` |
| `YYYY-MM-DD` | ISO format | `TO_CHAR(SYSDATE, 'YYYY-MM-DD')` | `'2025-06-22'` |
| `DD/MM/YYYY HH24:MI:SS` | Có giờ 24h | `TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS')` | `'22/06/2025 14:30:25'` |
| `DD-MON-YYYY HH:MI:SS AM` | Có giờ 12h | `TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')` | `'22-JUN-2025 02:30:25 PM'` |
| `Day, DD Month YYYY` | Tên đầy đủ | `TO_CHAR(SYSDATE, 'Day, DD Month YYYY')` | `'Sunday, 22 June 2025'` |
| `Q` | Quý | `TO_CHAR(SYSDATE, 'Q')` | `'2'` |
| `WW` | Tuần trong năm | `TO_CHAR(SYSDATE, 'WW')` | `'25'` |
| `J` | Julian date | `TO_CHAR(SYSDATE, 'J')` | `'2461631'` |
| `YYYY-DDD` | Ngày thứ trong năm | `TO_CHAR(SYSDATE, 'YYYY-DDD')` | `'2025-173'` |

### ⚡ Lỗi Thường Gặp & Giải Pháp Nhanh

| **Lỗi** | **Nguyên Nhân** | **Giải Pháp Nhanh** |
|----------|-----------------|---------------------|
| `ORA-01722` | Invalid Number | `TO_NUMBER('abc', DEFAULT 0 ON CONVERSION ERROR)` |
| `ORA-01843` | Not valid month | `TO_DATE('2025-13-01', DEFAULT DATE '1900-01-01' ON CONVERSION ERROR)` |
| `ORA-01847` | Invalid day | Kiểm tra logic ngày trước: `VALIDATE_CONVERSION()` |
| `ORA-06502` | Buffer too small | `SUBSTR(long_string, 1, max_length)` |

---

## Mục Lục

1. [Hàm Chuyển Đổi Số](#hàm-chuyển-đổi-số)
2. [Hàm Chuyển Đổi Ngày/Giờ](#hàm-chuyển-đổi-ngàygiờ)
3. [Hàm Chuyển Đổi Ký Tự](#hàm-chuyển-đổi-ký-tự)
4. [Hàm CAST và CONVERT](#hàm-cast-và-convert)
5. [Hàm Chuyển Đổi RAW/HEX](#hàm-chuyển-đổi-rawhex)
6. [Hàm Xử Lý NULL](#hàm-xử-lý-null)
7. [Hàm Kiểm Tra và Validate](#hàm-kiểm-tra-và-validate)
8. [Xử Lý Lỗi Thường Gặp](#xử-lý-lỗi-thường-gặp)

---

## Hàm Chuyển Đổi Số

### 1. TO_NUMBER()

**Cú pháp:**
```sql
TO_NUMBER(char [, format_model [, nls_language]])
```

**Mô tả:** Chuyển đổi chuỗi ký tự hoặc số thành kiểu NUMBER.

**Tham số:**
- `char`: Chuỗi cần chuyển đổi
- `format_model`: Mẫu định dạng (tùy chọn)
- `nls_language`: Ngôn ngữ cho định dạng số (tùy chọn)

**Trường hợp sử dụng:**

#### A. Chuyển đổi cơ bản
```sql
-- Chuyển chuỗi số đơn giản
SELECT TO_NUMBER('123') FROM dual;          -- 123
SELECT TO_NUMBER('123.45') FROM dual;       -- 123.45
SELECT TO_NUMBER('-999.99') FROM dual;      -- -999.99

-- Chuyển đổi với khoảng trắng
SELECT TO_NUMBER('  123  ') FROM dual;      -- 123 (tự động trim)
```

#### B. Sử dụng format model
```sql
-- Số có dấu phẩy phân cách hàng nghìn
SELECT TO_NUMBER('1,234,567.89', '9,999,999.99') FROM dual;  -- 1234567.89

-- Số âm với dấu ngoặc
SELECT TO_NUMBER('(123.45)', '(999.99)') FROM dual;         -- -123.45

-- Số với ký hiệu tiền tệ
SELECT TO_NUMBER('$1,234.56', '$9,999.99') FROM dual;       -- 1234.56
SELECT TO_NUMBER('€1.234,56', 'L9G999D99', 
    'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''€''') FROM dual;

-- Số với ký hiệu dương/âm
SELECT TO_NUMBER('+123.45', 'S999.99') FROM dual;          -- 123.45
SELECT TO_NUMBER('123.45-', '999.99MI') FROM dual;         -- -123.45
```

#### C. Format model phổ biến
```sql
-- Các format model thường dùng:
'999.99'        -- Số với 2 chữ số thập phân
'9,999.99'      -- Có dấu phẩy phân cách
'$9,999.99'     -- Có ký hiệu đô la
'999.99PR'      -- Số âm hiển thị trong ngoặc <>
'S999.99'       -- Dấu + hoặc - ở đầu
'999.99MI'      -- Dấu - ở cuối cho số âm
'L999.99'       -- Ký hiệu tiền tệ local
'9.999EEEE'     -- Ký pháp khoa học
```

#### D. Xử lý lỗi với DEFAULT ON CONVERSION ERROR (12c+)
```sql
-- Trả về giá trị mặc định khi có lỗi
SELECT TO_NUMBER('abc', DEFAULT 0 ON CONVERSION ERROR) FROM dual;     -- 0
SELECT TO_NUMBER('123x', DEFAULT -1 ON CONVERSION ERROR) FROM dual;   -- -1
SELECT TO_NUMBER('', DEFAULT NULL ON CONVERSION ERROR) FROM dual;     -- NULL

-- Sử dụng trong UPDATE
UPDATE products 
SET price = TO_NUMBER(price_text, DEFAULT 0 ON CONVERSION ERROR);
```

---

## Hàm Chuyển Đổi Ngày/Giờ

### 1. TO_DATE()

**Cú pháp:**
```sql
TO_DATE(char [, format_model [, nls_language]])
```

**Mô tả:** Chuyển đổi chuỗi ký tự thành kiểu DATE.

#### A. Chuyển đổi cơ bản
```sql
-- Định dạng mặc định (phụ thuộc NLS_DATE_FORMAT)
SELECT TO_DATE('22-JUN-25') FROM dual;

-- Định dạng ISO
SELECT TO_DATE('2025-06-22', 'YYYY-MM-DD') FROM dual;
SELECT TO_DATE('2025/06/22', 'YYYY/MM/DD') FROM dual;

-- Có thời gian
SELECT TO_DATE('2025-06-22 14:30:25', 'YYYY-MM-DD HH24:MI:SS') FROM dual;
SELECT TO_DATE('22/06/2025 2:30:25 PM', 'DD/MM/YYYY HH:MI:SS AM') FROM dual;
```

#### B. Format model cho ngày
```sql
-- Các format model phổ biến:
'DD-MON-YYYY'           -- 22-JUN-2025
'DD/MM/YYYY'            -- 22/06/2025
'YYYY-MM-DD'            -- 2025-06-22
'DD-MM-YYYY HH24:MI:SS' -- 22-06-2025 14:30:25
'DD-MON-YY'             -- 22-JUN-25
'J'                     -- Julian date
'YYYY-DDD'              -- Year + day of year
'YYYY-"W"WW-D'          -- Year + week + day
```

#### C. Xử lý ngôn ngữ
```sql
-- Tháng bằng tiếng Việt
SELECT TO_DATE('22-Tháng Sáu-2025', 'DD-"Tháng" MON-YYYY', 
    'NLS_DATE_LANGUAGE = VIETNAMESE') FROM dual;

-- Tháng bằng tiếng Anh
SELECT TO_DATE('22-June-2025', 'DD-MONTH-YYYY', 
    'NLS_DATE_LANGUAGE = AMERICAN') FROM dual;

-- Thứ trong tuần
SELECT TO_DATE('Chủ nhật, 22-06-2025', 'DAY, DD-MM-YYYY',
    'NLS_DATE_LANGUAGE = VIETNAMESE') FROM dual;
```

#### D. Xử lý lỗi ngày
```sql
-- Ngày không hợp lệ với DEFAULT (12c+)
SELECT TO_DATE('32-12-2025', 'DD-MM-YYYY', 
    DEFAULT DATE '1900-01-01' ON CONVERSION ERROR) FROM dual;

-- Kiểm tra ngày hợp lệ trước khi chuyển đổi
SELECT CASE 
    WHEN REGEXP_LIKE('29-02-2025', '^\d{2}-\d{2}-\d{4}$') 
    THEN TO_DATE('29-02-2025', 'DD-MM-YYYY')
    ELSE NULL 
END FROM dual;
```

### 2. TO_TIMESTAMP()

**Cú pháp:**
```sql
TO_TIMESTAMP(char [, format_model [, nls_language]])
```

**Mô tả:** Chuyển đổi chuỗi thành TIMESTAMP với độ chính xác giây phân số.

```sql
-- Timestamp cơ bản
SELECT TO_TIMESTAMP('2025-06-22 14:30:25.123456', 
    'YYYY-MM-DD HH24:MI:SS.FF') FROM dual;

-- Với múi giờ
SELECT TO_TIMESTAMP_TZ('2025-06-22 14:30:25.123 +07:00', 
    'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM') FROM dual;

-- Chỉ định độ chính xác
SELECT TO_TIMESTAMP('2025-06-22 14:30:25.123', 
    'YYYY-MM-DD HH24:MI:SS.FF3') FROM dual;
```

### 3. Hàm FROM_TZ()

**Cú pháp:**
```sql
FROM_TZ(timestamp_value, time_zone)
```

**Mô tả:** Chuyển TIMESTAMP thành TIMESTAMP WITH TIME ZONE.

```sql
-- Thêm múi giờ vào timestamp
SELECT FROM_TZ(TIMESTAMP '2025-06-22 14:30:25', '+07:00') FROM dual;
SELECT FROM_TZ(SYSTIMESTAMP, 'Asia/Ho_Chi_Minh') FROM dual;

-- Chuyển đổi múi giờ
SELECT FROM_TZ(TIMESTAMP '2025-06-22 14:30:25', 'UTC') 
    AT TIME ZONE 'Asia/Tokyo' FROM dual;
```

---

## Hàm Chuyển Đổi Ký Tự

### 1. TO_CHAR()

**Cú pháp:**
```sql
TO_CHAR(number | date [, format_model [, nls_language]])
```

**Mô tả:** Chuyển đổi số hoặc ngày thành chuỗi ký tự.

#### A. Chuyển đổi số thành chuỗi
```sql
-- Số cơ bản
SELECT TO_CHAR(1234.56) FROM dual;                    -- '1234.56'
SELECT TO_CHAR(1234567.89) FROM dual;                 -- '1234567.89'

-- Định dạng số
SELECT TO_CHAR(1234.56, '9,999.99') FROM dual;        -- ' 1,234.56'
SELECT TO_CHAR(1234.56, '0,000.00') FROM dual;        -- ' 1,234.56'
SELECT TO_CHAR(1234.56, '$9,999.99') FROM dual;       -- ' $1,234.56'
SELECT TO_CHAR(-1234.56, '9,999.99PR') FROM dual;     -- '<1,234.56>'

-- Loại bỏ khoảng trắng đầu
SELECT TRIM(TO_CHAR(1234.56, '9,999.99')) FROM dual;  -- '1,234.56'

-- Định dạng khoa học
SELECT TO_CHAR(1234567, '9.99EEEE') FROM dual;        -- ' 1.23E+06'

-- Định dạng La Mã
SELECT TO_CHAR(1994, 'RN') FROM dual;                 -- 'MCMXCIV'
SELECT TO_CHAR(1994, 'rn') FROM dual;                 -- 'mcmxciv'
```

#### B. Format model cho số
```sql
-- Các ký hiệu format:
'9'     -- Hiển thị chữ số, khoảng trắng nếu không có
'0'     -- Hiển thị chữ số, 0 nếu không có
','     -- Dấu phẩy phân cách hàng nghìn
'.'     -- Dấu chấm thập phân
'$'     -- Ký hiệu đô la
'L'     -- Ký hiệu tiền tệ local
'S'     -- Dấu +/- ở đầu
'PR'    -- Số âm trong ngoặc <>
'MI'    -- Dấu - ở cuối cho số âm
'EEEE'  -- Ký pháp khoa học
'RN'    -- Số La Mã (chữ hoa)
'rn'    -- Số La Mã (chữ thường)
```

#### C. Chuyển đổi ngày thành chuỗi
```sql
-- Định dạng ngày cơ bản
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM dual;
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY') FROM dual;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') FROM dual;

-- Với thời gian
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') FROM dual;
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM') FROM dual;

-- Định dạng đặc biệt
SELECT TO_CHAR(SYSDATE, 'Day, DD Month YYYY') FROM dual;
SELECT TO_CHAR(SYSDATE, 'Q') FROM dual;           -- Quý
SELECT TO_CHAR(SYSDATE, 'WW') FROM dual;          -- Tuần trong năm
SELECT TO_CHAR(SYSDATE, 'J') FROM dual;           -- Julian date
SELECT TO_CHAR(SYSDATE, 'YYYY-DDD') FROM dual;    -- Ngày thứ trong năm
```

#### D. Ngôn ngữ và địa phương
```sql
-- Tiếng Việt
SELECT TO_CHAR(SYSDATE, 'Day, DD Month YYYY', 
    'NLS_DATE_LANGUAGE = VIETNAMESE') FROM dual;

-- Tiếng Anh
SELECT TO_CHAR(SYSDATE, 'Day, DD Month YYYY', 
    'NLS_DATE_LANGUAGE = AMERICAN') FROM dual;

-- Định dạng số theo địa phương
SELECT TO_CHAR(1234.56, 'L9G999D99', 
    'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''€''') FROM dual;
```

### 2. TO_CLOB() và TO_NCLOB()

```sql
-- Chuyển VARCHAR2 thành CLOB
SELECT TO_CLOB('Đây là một văn bản dài...') FROM dual;

-- Chuyển NVARCHAR2 thành NCLOB
SELECT TO_NCLOB(N'Unicode text with émojis 🎉') FROM dual;

-- Nối nhiều CLOB
SELECT TO_CLOB('Part 1 ') || TO_CLOB('Part 2') FROM dual;
```

---

## Hàm CAST và CONVERT

### 1. CAST()

**Cú pháp:**
```sql
CAST(expression AS target_datatype)
```

**Mô tả:** Chuyển đổi kiểu dữ liệu theo chuẩn SQL ANSI.

```sql
-- Chuyển đổi cơ bản
SELECT CAST('123' AS NUMBER) FROM dual;
SELECT CAST(123 AS VARCHAR2(10)) FROM dual;
SELECT CAST(SYSDATE AS TIMESTAMP) FROM dual;

-- Chuyển đổi với kích thước
SELECT CAST('Hello World' AS VARCHAR2(5)) FROM dual;     -- 'Hello' (cắt ngắn)
SELECT CAST(123.456 AS NUMBER(5,2)) FROM dual;           -- 123.46 (làm tròn)

-- Chuyển đổi INTERVAL
SELECT CAST('2-3' AS INTERVAL YEAR TO MONTH) FROM dual;  -- 2 năm 3 tháng

-- MULTISET (cho collection)
SELECT CAST(MULTISET(SELECT column_name FROM table_name) 
    AS varchar2_array_type) FROM dual;
```

### 2. CONVERT()

**Cú pháp:**
```sql
CONVERT(char, dest_char_set [, source_char_set])
```

**Mô tả:** Chuyển đổi giữa các bộ ký tự.

```sql
-- Chuyển đổi bộ ký tự
SELECT CONVERT('Hội nghị ABC', 'UTF8', 'AL32UTF8') FROM dual;
SELECT CONVERT('résumé', 'US7ASCII', 'UTF8') FROM dual;

-- Xem bộ ký tự hiện tại
SELECT VALUE FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET';

-- Chuyển đổi với xử lý lỗi
SELECT CONVERT('Special chars: àáạảã', 'US7ASCII') FROM dual;  -- Có thể mất ký tự
```

---

## Hàm Chuyển Đổi RAW/HEX

### 1. HEXTORAW() và RAWTOHEX()

```sql
-- Chuyển hex string thành RAW
SELECT HEXTORAW('48656C6C6F') FROM dual;        -- RAW equivalent of 'Hello'

-- Chuyển RAW thành hex string
SELECT RAWTOHEX(UTL_RAW.CAST_TO_RAW('Hello')) FROM dual;  -- '48656C6C6F'

-- Ứng dụng thực tế: lưu trữ hash
SELECT RAWTOHEX(STANDARD_HASH('password123', 'MD5')) FROM dual;
```

### 2. UTL_RAW Package

```sql
-- Chuyển chuỗi thành RAW
SELECT UTL_RAW.CAST_TO_RAW('Hello World') FROM dual;

-- Chuyển RAW thành chuỗi
SELECT UTL_RAW.CAST_TO_VARCHAR2(HEXTORAW('48656C6C6F')) FROM dual;

-- Nối RAW
SELECT UTL_RAW.CONCAT(
    UTL_RAW.CAST_TO_RAW('Hello '),
    UTL_RAW.CAST_TO_RAW('World')
) FROM dual;

-- Lấy substring từ RAW
SELECT UTL_RAW.SUBSTR(UTL_RAW.CAST_TO_RAW('Hello World'), 1, 5) FROM dual;
```

---

## Hàm Xử Lý NULL

### 1. NVL() và NVL2()

```sql
-- NVL: Thay thế NULL bằng giá trị khác
SELECT NVL(NULL, 'No value') FROM dual;               -- 'No value'
SELECT NVL('Hello', 'Default') FROM dual;             -- 'Hello'
SELECT NVL(commission_pct, 0) FROM employees;         -- 0 nếu NULL

-- NVL2: Xử lý cả NULL và NOT NULL
SELECT NVL2(commission_pct, 'Has commission', 'No commission') 
FROM employees;
```

### 2. NULLIF() và COALESCE()

```sql
-- NULLIF: Trả về NULL nếu 2 giá trị bằng nhau
SELECT NULLIF('ABC', 'ABC') FROM dual;                -- NULL
SELECT NULLIF('ABC', 'XYZ') FROM dual;                -- 'ABC'

-- COALESCE: Trả về giá trị đầu tiên không NULL
SELECT COALESCE(NULL, NULL, 'Third', 'Fourth') FROM dual;  -- 'Third'
SELECT COALESCE(phone1, phone2, email, 'No contact') FROM customers;
```

---

## Hàm Kiểm Tra và Validate

### 1. VALIDATE_CONVERSION() (12c+)

```sql
-- Kiểm tra có thể chuyển đổi thành NUMBER không
SELECT VALIDATE_CONVERSION('123.45' AS NUMBER) FROM dual;      -- 1
SELECT VALIDATE_CONVERSION('123abc' AS NUMBER) FROM dual;      -- 0

-- Kiểm tra chuyển đổi DATE
SELECT VALIDATE_CONVERSION('2025-06-22' AS DATE, 'YYYY-MM-DD') FROM dual;  -- 1
SELECT VALIDATE_CONVERSION('2025-13-45' AS DATE, 'YYYY-MM-DD') FROM dual;  -- 0

-- Sử dụng trong WHERE clause
SELECT * FROM temp_data 
WHERE VALIDATE_CONVERSION(text_column AS NUMBER) = 1;
```

### 2. Hàm Kiểm Tra Kiểu Dữ Liệu

```sql
-- Kiểm tra số
SELECT CASE 
    WHEN REGEXP_LIKE('123.45', '^[+-]?[0-9]*\.?[0-9]+$') THEN 'Valid Number'
    ELSE 'Invalid Number'
END FROM dual;

-- Kiểm tra ngày (định dạng cơ bản)
SELECT CASE 
    WHEN REGEXP_LIKE('2025-06-22', '^\d{4}-\d{2}-\d{2}$') THEN 'Valid Date Format'
    ELSE 'Invalid Date Format'
END FROM dual;

-- Kiểm tra email
SELECT CASE 
    WHEN REGEXP_LIKE('user@domain.com', '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
    THEN 'Valid Email'
    ELSE 'Invalid Email'
END FROM dual;
```

---

## Xử Lý Lỗi Thường Gặp

### 1. ORA-01722: Invalid Number

**Nguyên nhân:** Chuỗi không thể chuyển thành số.

```sql
-- ❌ Lỗi
SELECT TO_NUMBER('123abc') FROM dual;  -- ORA-01722

-- ✅ Giải pháp 1: Dùng DEFAULT (12c+)
SELECT TO_NUMBER('123abc', DEFAULT 0 ON CONVERSION ERROR) FROM dual;

-- ✅ Giải pháp 2: Kiểm tra trước
SELECT CASE 
    WHEN REGEXP_LIKE('123abc', '^[+-]?[0-9]*\.?[0-9]+$') 
    THEN TO_NUMBER('123abc')
    ELSE 0
END FROM dual;

-- ✅ Giải pháp 3: Dùng VALIDATE_CONVERSION (12c+)
SELECT CASE 
    WHEN VALIDATE_CONVERSION('123abc' AS NUMBER) = 1 
    THEN TO_NUMBER('123abc')
    ELSE 0
END FROM dual;
```

### 2. ORA-01843: Not a valid month

**Nguyên nhân:** Định dạng tháng không đúng.

```sql
-- ❌ Lỗi
SELECT TO_DATE('22-13-2025', 'DD-MM-YYYY') FROM dual;  -- Tháng 13 không tồn tại

-- ✅ Giải pháp
SELECT TO_DATE('22-13-2025', 'DD-MM-YYYY', 
    DEFAULT DATE '1900-01-01' ON CONVERSION ERROR) FROM dual;
```

### 3. ORA-01847: Day of month must be between 1 and last day of month

```sql
-- ❌ Lỗi
SELECT TO_DATE('31-02-2025', 'DD-MM-YYYY') FROM dual;  -- 31/2 không tồn tại

-- ✅ Giải pháp: Kiểm tra logic ngày
CREATE OR REPLACE FUNCTION safe_to_date(
    p_date_str VARCHAR2,
    p_format VARCHAR2
) RETURN DATE IS
BEGIN
    RETURN TO_DATE(p_date_str, p_format);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
```

### 4. ORA-06502: Character string buffer too small

```sql
-- ❌ Lỗi
SELECT CAST('Very long string that exceeds limit' AS VARCHAR2(5)) FROM dual;

-- ✅ Giải pháp: Dùng SUBSTR
SELECT SUBSTR('Very long string that exceeds limit', 1, 5) FROM dual;
```

### 5. Lỗi Múi Giờ

```sql
-- ❌ Lỗi
SELECT TO_TIMESTAMP_TZ('2025-06-22 14:30:25 InvalidTZ', 
    'YYYY-MM-DD HH24:MI:SS TZR') FROM dual;

-- ✅ Kiểm tra múi giờ hợp lệ
SELECT tzname FROM v$timezone_names WHERE tzname LIKE '%Ho_Chi_Minh%';

-- ✅ Sử dụng múi giờ chuẩn
SELECT TO_TIMESTAMP_TZ('2025-06-22 14:30:25 +07:00', 
    'YYYY-MM-DD HH24:MI:SS TZH:TZM') FROM dual;
```

### 6. Pattern Xử Lý Lỗi Chung

```sql
-- Function xử lý lỗi chuyển đổi
CREATE OR REPLACE FUNCTION safe_convert(
    p_value VARCHAR2,
    p_type VARCHAR2,
    p_default VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000);
BEGIN
    CASE UPPER(p_type)
        WHEN 'NUMBER' THEN
            IF VALIDATE_CONVERSION(p_value AS NUMBER) = 1 THEN
                v_result := TO_CHAR(TO_NUMBER(p_value));
            ELSE
                v_result := p_default;
            END IF;
        WHEN 'DATE' THEN
            BEGIN
                v_result := TO_CHAR(TO_DATE(p_value, 'YYYY-MM-DD'), 'YYYY-MM-DD');
            EXCEPTION
                WHEN OTHERS THEN
                    v_result := p_default;
            END;
        ELSE
            v_result := p_value;
    END CASE;
    
    RETURN v_result;
END;

-- Sử dụng function
SELECT safe_convert('123abc', 'NUMBER', '0') FROM dual;      -- '0'
SELECT safe_convert('123.45', 'NUMBER', '0') FROM dual;     -- '123.45'
SELECT safe_convert('2025-13-45', 'DATE', '1900-01-01') FROM dual;  -- '1900-01-01'
```

---

## Tổng Kết và Best Practices

### ✅ Nên Làm:

1. **Luôn kiểm tra dữ liệu** trước khi chuyển đổi
2. **Sử dụng DEFAULT ON CONVERSION ERROR** (Oracle 12c+) để xử lý lỗi
3. **Chỉ định format model** rõ ràng khi cần thiết
4. **Sử dụng VALIDATE_CONVERSION** để kiểm tra trước
5. **Test với dữ liệu edge case** (NULL, empty, invalid)

### ❌ Tránh:

1. **Không kiểm tra dữ liệu** trước khi chuyển đổi
2. **Dựa vào implicit conversion** cho logic quan trọng
3. **Bỏ qua xử lý lỗi** trong production code
4. **Sử dụng format model phức tạp** không cần thiết

### 🔧 Tools Hữu Ích:

```sql
-- Kiểm tra tất cả conversion function có sẵn
SELECT object_name, object_type 
FROM all_objects 
WHERE object_name LIKE '%TO_%' 
  AND object_type = 'FUNCTION'
  AND owner = 'SYS';

-- Xem NLS settings hiện tại
SELECT * FROM nls_session_parameters;
SELECT * FROM nls_database_parameters;
```

Hy vọng hướng dẫn chi tiết này sẽ giúp bạn làm chủ các hàm chuyển đổi trong Oracle Database và xử lý hiệu quả các tình huống thực tế!