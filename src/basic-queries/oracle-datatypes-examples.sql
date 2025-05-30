-- Oracle Database Data Types - Practical Examples
-- This file demonstrates the usage of various Oracle data types

-- =====================================================
-- CHARACTER DATA TYPES EXAMPLES
-- =====================================================

-- Example table demonstrating character data types
CREATE TABLE character_data_examples (
    id NUMBER PRIMARY KEY,
    -- VARCHAR2 - variable length, most common for text
    employee_name VARCHAR2(100),
    description VARCHAR2(4000),
    
    -- CHAR - fixed length, padded with spaces
    country_code CHAR(2),
    status_flag CHAR(1),
    
    -- NVARCHAR2 - Unicode variable length
    multilingual_name NVARCHAR2(100),
    
    -- NCHAR - Unicode fixed length
    unicode_code NCHAR(10)
);

-- Insert examples
INSERT INTO character_data_examples VALUES (
    1, 
    'John Smith',
    'Senior Software Engineer with 5+ years experience',
    'US',
    'A',
    N'José María González',
    N'CODE123   '
);

-- =====================================================
-- NUMERIC DATA TYPES EXAMPLES
-- =====================================================

CREATE TABLE numeric_data_examples (
    id NUMBER PRIMARY KEY,
    
    -- NUMBER - most versatile numeric type
    salary NUMBER(10,2),        -- Max 99,999,999.99
    employee_id NUMBER(6),      -- Integer up to 999,999
    percentage NUMBER(5,2),     -- Max 999.99
    scientific_value NUMBER,    -- Unlimited precision
    
    -- INTEGER - whole numbers
    counter INTEGER,
    
    -- FLOAT - floating point
    measurement FLOAT(24),
    
    -- IEEE floating point types
    temperature BINARY_FLOAT,
    precise_calculation BINARY_DOUBLE
);

INSERT INTO numeric_data_examples VALUES (
    1,
    75000.50,
    123456,
    98.75,
    3.141592653589793238462643383279,
    42,
    123.456789,
    98.6,
    3.141592653589793
);

-- =====================================================
-- DATE AND TIME DATA TYPES EXAMPLES
-- =====================================================

CREATE TABLE datetime_examples (
    id NUMBER PRIMARY KEY,
    
    -- DATE - most common for date/time
    birth_date DATE,
    created_date DATE,
    
    -- TIMESTAMP - with fractional seconds
    event_timestamp TIMESTAMP(6),
    
    -- TIMESTAMP WITH TIME ZONE
    global_event TIMESTAMP WITH TIME ZONE,
    
    -- TIMESTAMP WITH LOCAL TIME ZONE
    local_event TIMESTAMP WITH LOCAL TIME ZONE,
    
    -- INTERVAL types for durations
    project_duration INTERVAL YEAR TO MONTH,
    task_duration INTERVAL DAY TO SECOND
);

INSERT INTO datetime_examples VALUES (
    1,
    DATE '1990-05-15',
    SYSDATE,
    SYSTIMESTAMP,
    TIMESTAMP '2023-05-15 14:30:00.123456 -07:00',
    SYSTIMESTAMP,
    INTERVAL '2-3' YEAR TO MONTH,    -- 2 years, 3 months
    INTERVAL '5 10:30:25.123' DAY TO SECOND  -- 5 days, 10:30:25.123
);

-- =====================================================
-- BINARY AND LOB DATA TYPES EXAMPLES
-- =====================================================

CREATE TABLE binary_lob_examples (
    id NUMBER PRIMARY KEY,
    
    -- RAW - small binary data
    checksum RAW(16),
    
    -- Large Object types
    document CLOB,              -- Large text
    multilingual_doc NCLOB,     -- Large Unicode text
    image_data BLOB,            -- Binary files
    external_file BFILE         -- External file reference
);

-- Insert examples (simplified for demonstration)
INSERT INTO binary_lob_examples (id, checksum, document) VALUES (
    1,
    HEXTORAW('A1B2C3D4E5F67890FEDCBA0987654321'),
    'This is a large text document that could contain thousands of characters...'
);

-- =====================================================
-- DATA TYPE CONVERSION EXAMPLES
-- =====================================================

-- Implicit conversions
SELECT 
    '123' + 45 AS implicit_number_conversion,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS date_to_string
FROM dual;

-- Explicit conversions
SELECT 
    TO_NUMBER('123.45') AS string_to_number,
    TO_DATE('2023-05-15', 'YYYY-MM-DD') AS string_to_date,
    TO_CHAR(12345.67, '999,999.99') AS number_to_formatted_string,
    TO_TIMESTAMP('2023-05-15 14:30:25.123', 'YYYY-MM-DD HH24:MI:SS.FF3') AS string_to_timestamp
FROM dual;

-- =====================================================
-- DATA TYPE CONSTRAINTS AND VALIDATION
-- =====================================================

CREATE TABLE employee_master (
    employee_id NUMBER(6) PRIMARY KEY,
    
    -- Character constraints
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    
    -- Numeric constraints
    salary NUMBER(10,2) CHECK (salary > 0),
    department_id NUMBER(3) CHECK (department_id BETWEEN 1 AND 999),
    
    -- Date constraints
    hire_date DATE NOT NULL,
    birth_date DATE CHECK (birth_date < hire_date),
    
    -- Status with specific values
    status CHAR(1) DEFAULT 'A' CHECK (status IN ('A', 'I', 'T')),
    
    -- Percentage constraint
    commission_pct NUMBER(3,2) CHECK (commission_pct BETWEEN 0 AND 1)
);

-- =====================================================
-- PERFORMANCE CONSIDERATIONS
-- =====================================================

-- Index on different data types
CREATE INDEX idx_employee_email ON employee_master(email);
CREATE INDEX idx_employee_hire_date ON employee_master(hire_date);
CREATE INDEX idx_employee_dept_salary ON employee_master(department_id, salary);

-- =====================================================
-- COMMON DATA TYPE QUERIES
-- =====================================================

-- Check data types of table columns
SELECT 
    column_name,
    data_type,
    data_length,
    data_precision,
    data_scale,
    nullable
FROM user_tab_columns 
WHERE table_name = 'EMPLOYEE_MASTER'
ORDER BY column_id;

-- Demonstrate data type functions
SELECT 
    DUMP(employee_id) AS number_dump,
    DUMP(first_name) AS varchar2_dump,
    DUMP(hire_date) AS date_dump,
    DUMP(status) AS char_dump
FROM employee_master
WHERE ROWNUM = 1;

-- =====================================================
-- DATA TYPE BEST PRACTICES EXAMPLES
-- =====================================================

-- Good: Appropriate sizing
CREATE TABLE good_example (
    product_code VARCHAR2(20),      -- Right-sized for product codes
    price NUMBER(8,2),              -- Appropriate for currency
    created_date DATE               -- Standard date type
);

-- Avoid: Over-allocation and wrong types
-- CREATE TABLE bad_example (
--     product_code VARCHAR2(4000),   -- Wasteful for short codes
--     price VARCHAR2(50),            -- Wrong type for numbers
--     created_date VARCHAR2(50)      -- Wrong type for dates
-- );

-- =====================================================
-- CLEANUP (uncomment to run)
-- =====================================================

/*
DROP TABLE character_data_examples;
DROP TABLE numeric_data_examples;
DROP TABLE datetime_examples;
DROP TABLE binary_lob_examples;
DROP TABLE employee_master;
DROP TABLE good_example;
*/

-- End of file
