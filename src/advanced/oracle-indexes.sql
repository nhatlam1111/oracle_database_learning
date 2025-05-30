-- ============================================================================
-- Oracle Database Indexes - Practice Examples
-- Lesson 5: Advanced SQL Techniques
-- ============================================================================
-- This file contains practical examples for Oracle Database index creation,
-- optimization, and maintenance techniques.
-- ============================================================================

-- Prerequisites: Ensure you have the HR schema or create sample tables
-- This script uses the standard Oracle HR schema tables

-- ============================================================================
-- SECTION 1: BASIC INDEX CREATION
-- ============================================================================

-- Example 1: Simple B-Tree Index
-- Create index on frequently queried column
CREATE INDEX idx_emp_last_name ON employees(last_name);

-- Verify index creation
SELECT index_name, index_type, status, uniqueness
FROM user_indexes 
WHERE table_name = 'EMPLOYEES'
ORDER BY index_name;

-- Example 2: Unique Index
-- Automatically created with UNIQUE constraints, or manually
CREATE UNIQUE INDEX idx_emp_email_unique ON employees(email);

-- Example 3: Composite Index (Multi-column)
-- Column order is critical for query optimization
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);

-- Test composite index effectiveness
EXPLAIN PLAN FOR
SELECT employee_id, first_name, last_name, salary
FROM employees 
WHERE department_id = 50 
  AND salary > 3000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- SECTION 2: FUNCTION-BASED INDEXES
-- ============================================================================

-- Example 4: Case-insensitive search index
CREATE INDEX idx_emp_upper_last_name ON employees(UPPER(last_name));

-- Test function-based index
SELECT employee_id, first_name, last_name
FROM employees 
WHERE UPPER(last_name) = 'KING';

-- Example 5: Date function index
CREATE INDEX idx_emp_hire_year ON employees(EXTRACT(YEAR FROM hire_date));

-- Query using the function-based index
SELECT COUNT(*) as employees_hired_2005
FROM employees 
WHERE EXTRACT(YEAR FROM hire_date) = 2005;

-- Example 6: Mathematical expression index
CREATE INDEX idx_emp_annual_salary ON employees(salary * 12);

-- Query using expression index
SELECT employee_id, first_name, last_name, salary
FROM employees 
WHERE (salary * 12) > 60000;

-- ============================================================================
-- SECTION 3: SPECIALIZED INDEX TYPES
-- ============================================================================

-- Example 7: Descending Index
CREATE INDEX idx_emp_salary_desc ON employees(salary DESC);

-- Optimal for descending ORDER BY queries
SELECT employee_id, last_name, salary
FROM employees 
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

-- Example 8: Bitmap Index (for low-cardinality data)
-- Note: Use carefully in OLTP environments
CREATE BITMAP INDEX idx_job_bitmap ON employees(job_id);

-- Bitmap indexes excel at complex WHERE clauses
SELECT COUNT(*) 
FROM employees 
WHERE job_id IN ('IT_PROG', 'SA_REP', 'ST_CLERK');

-- Example 9: Compressed Index
CREATE INDEX idx_emp_dept_name_comp ON employees(department_id, last_name) COMPRESS 1;

-- ============================================================================
-- SECTION 4: INDEX MONITORING AND ANALYSIS
-- ============================================================================

-- Example 10: Enable Index Usage Monitoring
ALTER INDEX idx_emp_last_name MONITORING USAGE;

-- Execute some queries to generate usage data
SELECT * FROM employees WHERE last_name = 'Smith';
SELECT * FROM employees WHERE last_name LIKE 'A%';

-- Check index usage statistics
SELECT index_name, table_name, monitoring, used, start_monitoring, end_monitoring
FROM v$object_usage 
WHERE index_name = 'IDX_EMP_LAST_NAME';

-- Example 11: Index Statistics Analysis
-- Gather index statistics
EXEC DBMS_STATS.GATHER_INDEX_STATS('HR', 'IDX_EMP_LAST_NAME');

-- Analyze index efficiency
SELECT 
    index_name,
    blevel,                    -- Index height (should be low)
    leaf_blocks,               -- Number of leaf blocks
    distinct_keys,             -- Number of distinct values
    avg_leaf_blocks_per_key,   -- Average blocks per key
    avg_data_blocks_per_key,   -- Average data blocks per key
    clustering_factor,         -- Table organization metric
    num_rows                   -- Number of rows indexed
FROM user_indexes 
WHERE index_name = 'IDX_EMP_LAST_NAME';

-- ============================================================================
-- SECTION 5: INDEX MAINTENANCE
-- ============================================================================

-- Example 12: Index Rebuild
-- Check if rebuild is needed (high clustering factor relative to num_rows)
SELECT 
    index_name,
    clustering_factor,
    num_rows,
    ROUND(clustering_factor / num_rows * 100, 2) as efficiency_ratio
FROM user_indexes 
WHERE table_name = 'EMPLOYEES'
  AND index_name = 'IDX_EMP_LAST_NAME';

-- Rebuild index online (minimal impact on users)
ALTER INDEX idx_emp_last_name REBUILD ONLINE;

-- Example 13: Index Coalesce (merge adjacent free spaces)
ALTER INDEX idx_emp_last_name COALESCE;

-- Example 14: Index Shrink (Oracle 11g+)
ALTER INDEX idx_emp_last_name SHRINK SPACE;

-- ============================================================================
-- SECTION 6: INDEX PERFORMANCE TESTING
-- ============================================================================

-- Example 15: Before and After Performance Comparison

-- Drop index temporarily for comparison
DROP INDEX idx_emp_dept_salary;

-- Test query performance without index
SET TIMING ON;
SELECT employee_id, first_name, last_name, salary
FROM employees 
WHERE department_id = 50 
  AND salary BETWEEN 2500 AND 4000;

-- Recreate index
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);

-- Test same query with index
SELECT employee_id, first_name, last_name, salary
FROM employees 
WHERE department_id = 50 
  AND salary BETWEEN 2500 AND 4000;
SET TIMING OFF;

-- ============================================================================
-- SECTION 7: ADVANCED INDEX SCENARIOS
-- ============================================================================

-- Example 16: Invisible Index (Oracle 11g+)
-- Create index but make it invisible to optimizer
CREATE INDEX idx_emp_phone INVISIBLE ON employees(phone_number);

-- Test index without affecting production
ALTER SESSION SET optimizer_use_invisible_indexes = TRUE;

SELECT employee_id, first_name, phone_number
FROM employees 
WHERE phone_number IS NOT NULL;

-- Make index visible when ready
ALTER INDEX idx_emp_phone VISIBLE;

-- Example 17: Virtual Column Index
-- First, add a virtual column
ALTER TABLE employees ADD (
    full_name VARCHAR2(100) GENERATED ALWAYS AS (first_name || ' ' || last_name)
);

-- Create index on virtual column
CREATE INDEX idx_emp_full_name ON employees(full_name);

-- Query using virtual column index
SELECT employee_id, full_name, salary
FROM employees 
WHERE full_name = 'Steven King';

-- ============================================================================
-- SECTION 8: INDEX TROUBLESHOOTING
-- ============================================================================

-- Example 18: Find Unused Indexes
-- First enable monitoring on all indexes
DECLARE
    CURSOR idx_cursor IS
        SELECT index_name 
        FROM user_indexes 
        WHERE table_name = 'EMPLOYEES';
BEGIN
    FOR idx IN idx_cursor LOOP
        EXECUTE IMMEDIATE 'ALTER INDEX ' || idx.index_name || ' MONITORING USAGE';
    END LOOP;
END;
/

-- After running workload for some time, check usage
SELECT 
    index_name,
    table_name,
    monitoring,
    used,
    start_monitoring
FROM v$object_usage 
WHERE table_name = 'EMPLOYEES'
ORDER BY used, index_name;

-- Example 19: Find Duplicate Indexes
-- Query to identify potentially duplicate indexes
SELECT 
    i1.index_name as index1,
    i2.index_name as index2,
    i1.column_name,
    i1.column_position
FROM user_ind_columns i1
JOIN user_ind_columns i2 ON (
    i1.table_name = i2.table_name 
    AND i1.column_name = i2.column_name
    AND i1.column_position = i2.column_position
    AND i1.index_name < i2.index_name
)
WHERE i1.table_name = 'EMPLOYEES'
ORDER BY i1.index_name, i1.column_position;

-- Example 20: Index Space Usage Analysis
SELECT 
    segment_name as index_name,
    segment_type,
    tablespace_name,
    bytes / 1024 / 1024 as size_mb,
    blocks,
    extents
FROM user_segments 
WHERE segment_type = 'INDEX'
  AND segment_name LIKE 'IDX_EMP%'
ORDER BY bytes DESC;

-- ============================================================================
-- SECTION 9: CLEANUP
-- ============================================================================

-- Clean up example indexes (uncomment to execute)
/*
DROP INDEX idx_emp_last_name;
DROP INDEX idx_emp_email_unique;
DROP INDEX idx_emp_dept_salary;
DROP INDEX idx_emp_upper_last_name;
DROP INDEX idx_emp_hire_year;
DROP INDEX idx_emp_annual_salary;
DROP INDEX idx_emp_salary_desc;
DROP INDEX idx_job_bitmap;
DROP INDEX idx_emp_dept_name_comp;
DROP INDEX idx_emp_phone;
DROP INDEX idx_emp_full_name;

-- Remove virtual column
ALTER TABLE employees DROP COLUMN full_name;
*/

-- ============================================================================
-- BEST PRACTICES SUMMARY
-- ============================================================================
/*
INDEX DESIGN BEST PRACTICES:

1. CREATE INDEXES ON:
   - Primary key columns (automatic)
   - Foreign key columns
   - Frequently queried columns
   - WHERE clause columns
   - ORDER BY columns
   - JOIN condition columns

2. COMPOSITE INDEX GUIDELINES:
   - Order columns by selectivity (most selective first)
   - Consider query patterns
   - Equality before range conditions
   - Include ORDER BY columns last

3. AVOID OVER-INDEXING:
   - Each index adds DML overhead
   - Monitor index usage regularly
   - Drop unused indexes
   - Consider covering indexes for read-heavy workloads

4. MAINTENANCE TASKS:
   - Gather statistics regularly
   - Monitor clustering factor
   - Rebuild when necessary
   - Use online operations when possible

5. PERFORMANCE MONITORING:
   - Enable index usage monitoring
   - Analyze execution plans
   - Check wait events
   - Monitor space usage

Remember: The best index strategy depends on your specific workload patterns!
*/
