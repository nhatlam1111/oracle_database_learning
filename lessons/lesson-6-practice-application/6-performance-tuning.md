# Performance Tuning Guide

## 🎯 Overview

This comprehensive guide covers Oracle Database performance tuning techniques, methodologies, and best practices. You'll learn to identify performance bottlenecks, optimize queries, and implement database-level optimizations for maximum system efficiency.

## 📋 Learning Objectives

### **Core Competencies:**
- Master query optimization techniques
- Understand Oracle execution plans
- Implement effective indexing strategies
- Optimize database configuration parameters
- Monitor and diagnose performance issues

### **Advanced Skills:**
- Analyze and resolve complex performance problems
- Design high-performance database architectures
- Implement caching and partitioning strategies
- Optimize PL/SQL code for performance
- Create comprehensive monitoring solutions

## 🔍 Performance Analysis Methodology

### **1. Performance Monitoring Framework**

#### **Key Performance Indicators (KPIs):**
```sql
-- Database Performance Metrics
SELECT 
    metric_name,
    value,
    metric_unit,
    ROUND(value/1000000, 2) as value_mb
FROM v$sysmetric
WHERE metric_name IN (
    'Physical Reads Per Sec',
    'Physical Writes Per Sec', 
    'Logical Reads Per Sec',
    'DB Block Gets Per Sec',
    'Consistent Gets Per Sec',
    'Buffer Cache Hit Ratio',
    'Library Cache Hit Ratio',
    'Parse Count (Total)',
    'Execute Count',
    'User Commits Per Sec',
    'User Rollbacks Per Sec'
)
ORDER BY metric_name;

-- Top SQL by Elapsed Time
SELECT 
    sql_id,
    child_number,
    plan_hash_value,
    executions,
    ROUND(elapsed_time/1000000, 2) as elapsed_seconds,
    ROUND(cpu_time/1000000, 2) as cpu_seconds,
    ROUND(elapsed_time/executions/1000000, 4) as avg_elapsed_seconds,
    disk_reads,
    buffer_gets,
    sql_text
FROM v$sql
WHERE executions > 0
ORDER BY elapsed_time DESC
FETCH FIRST 20 ROWS ONLY;

-- Wait Events Analysis
SELECT 
    event,
    total_waits,
    total_timeouts,
    time_waited,
    average_wait,
    ROUND(time_waited/SUM(time_waited) OVER() * 100, 2) as pct_total_wait_time
FROM v$system_event
WHERE event NOT LIKE 'SQL*Net%'
AND event NOT LIKE '%idle%'
ORDER BY time_waited DESC
FETCH FIRST 15 ROWS ONLY;
```

### **2. Query Performance Analysis**

#### **Execution Plan Analysis:**
```sql
-- Explain Plan for Query Analysis
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name, e.last_name, d.department_name,
       p.position_title, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN positions p ON e.position_id = p.position_id
WHERE e.salary > 50000
AND d.department_name LIKE 'Sales%'
ORDER BY e.salary DESC;

-- Display Execution Plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    format => 'BASIC +PREDICATE +COST +BYTES'
));

-- Real-time SQL Monitoring
SELECT 
    sql_id,
    sql_plan_hash_value,
    status,
    first_refresh_time,
    last_refresh_time,
    elapsed_time,
    cpu_time,
    physical_read_bytes,
    sql_text
FROM v$sql_monitor
WHERE status = 'EXECUTING'
OR (status = 'DONE' AND last_refresh_time > SYSDATE - INTERVAL '1' HOUR)
ORDER BY first_refresh_time DESC;

-- SQL Statistics and Performance
SELECT 
    s.sql_id,
    s.plan_hash_value,
    s.executions,
    ROUND(s.elapsed_time/1000000, 2) as elapsed_seconds,
    ROUND(s.cpu_time/1000000, 2) as cpu_seconds,
    s.disk_reads,
    s.buffer_gets,
    ROUND(s.rows_processed/s.executions, 0) as avg_rows_per_exec,
    ROUND(s.buffer_gets/s.executions, 0) as avg_buffer_gets_per_exec
FROM v$sql s
WHERE s.sql_id = '&sql_id';
```

### **3. Database Configuration Optimization**

#### **Memory Configuration:**
```sql
-- SGA Component Analysis
SELECT 
    component,
    current_size/1024/1024 as current_size_mb,
    min_size/1024/1024 as min_size_mb,
    max_size/1024/1024 as max_size_mb,
    user_specified_size/1024/1024 as user_specified_mb
FROM v$sga_dynamic_components
ORDER BY current_size DESC;

-- Buffer Cache Hit Ratio
SELECT 
    name,
    physical_reads,
    db_block_gets,
    consistent_gets,
    1 - (physical_reads / (db_block_gets + consistent_gets)) as buffer_cache_hit_ratio
FROM v$buffer_pool_statistics;

-- Library Cache Performance
SELECT 
    namespace,
    gets,
    gethits,
    pins,
    pinhits,
    ROUND(gethits/gets * 100, 2) as get_hit_ratio,
    ROUND(pinhits/pins * 100, 2) as pin_hit_ratio
FROM v$librarycache;

-- PGA Usage Analysis
SELECT 
    name,
    value/1024/1024 as value_mb,
    unit
FROM v$pgastat
WHERE name IN (
    'aggregate PGA target parameter',
    'aggregate PGA auto target',
    'total PGA inuse',
    'total PGA allocated',
    'maximum PGA allocated'
);
```

## 🚀 Query Optimization Techniques

### **1. Index Optimization Strategies**

#### **Index Analysis and Recommendations:**
```sql
-- Index Usage Statistics
SELECT 
    i.table_name,
    i.index_name,
    i.index_type,
    i.uniqueness,
    i.status,
    s.num_rows as table_rows,
    NVL(u.monitoring, 'NO') as monitoring,
    NVL(u.used, 'NO') as used
FROM user_indexes i
LEFT JOIN user_tables s ON i.table_name = s.table_name
LEFT JOIN v$object_usage u ON i.index_name = u.index_name
ORDER BY s.num_rows DESC;

-- Missing Index Recommendations
WITH table_scans AS (
    SELECT 
        object_name,
        object_type,
        COUNT(*) as scan_count
    FROM v$sql_plan
    WHERE operation = 'TABLE ACCESS'
    AND options = 'FULL'
    AND object_owner = USER
    GROUP BY object_name, object_type
)
SELECT 
    t.table_name,
    t.num_rows,
    ts.scan_count,
    'Consider adding indexes on frequently queried columns' as recommendation
FROM user_tables t
JOIN table_scans ts ON t.table_name = ts.object_name
WHERE t.num_rows > 10000
AND ts.scan_count > 10
ORDER BY ts.scan_count DESC;

-- Index Maintenance and Rebuild Recommendations
SELECT 
    index_name,
    table_name,
    blevel,
    leaf_blocks,
    distinct_keys,
    clustering_factor,
    CASE 
        WHEN blevel > 4 THEN 'Consider rebuilding - high blevel'
        WHEN clustering_factor > num_rows THEN 'Consider rebuilding - poor clustering'
        ELSE 'Index appears healthy'
    END as recommendation
FROM user_indexes i
JOIN user_tables t ON i.table_name = t.table_name
WHERE i.index_type = 'NORMAL'
ORDER BY blevel DESC, clustering_factor DESC;
```

#### **Composite Index Design:**
```sql
-- Optimal Composite Index Creation
-- Example: Optimizing employee queries

-- Before: Separate indexes
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_emp_salary ON employees(salary);

-- After: Composite index for common query patterns
CREATE INDEX idx_emp_dept_salary_name ON employees(
    department_id,     -- Most selective first
    salary,           -- Range condition
    last_name,        -- Order by column
    first_name        -- Additional filter
);

-- Function-based index for case-insensitive searches
CREATE INDEX idx_emp_name_upper ON employees(
    UPPER(last_name), 
    UPPER(first_name)
);

-- Partial index for active employees only
CREATE INDEX idx_emp_active_dept ON employees(department_id, salary)
WHERE employment_status = 'ACTIVE';
```

### **2. SQL Statement Optimization**

#### **Query Rewriting Techniques:**
```sql
-- Inefficient Query (Full Table Scan)
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.salary > (SELECT AVG(salary) FROM employees);

-- Optimized Version (Avoiding Correlated Subquery)
WITH avg_salary AS (
    SELECT AVG(salary) as avg_sal FROM employees
)
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
CROSS JOIN avg_salary a
WHERE e.salary > a.avg_sal;

-- Using EXISTS instead of IN for better performance
-- Inefficient
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id 
    FROM departments 
    WHERE department_name LIKE 'Sales%'
);

-- Optimized
SELECT employee_id, first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 
    FROM departments d 
    WHERE d.department_id = e.department_id
    AND d.department_name LIKE 'Sales%'
);
```

#### **Advanced Join Optimization:**
```sql
-- Hint-based optimization for complex queries
SELECT /*+ USE_HASH(e d p) PARALLEL(4) */
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    p.position_title,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN positions p ON e.position_id = p.position_id
WHERE e.hire_date > ADD_MONTHS(SYSDATE, -12);

-- Partition-wise joins for large tables
SELECT /*+ USE_HASH(s o) PQ_DISTRIBUTE(s HASH HASH) */
    s.sale_id,
    s.sale_date,
    o.order_number,
    s.amount
FROM sales_partitioned s
JOIN orders_partitioned o ON s.order_id = o.order_id
WHERE s.sale_date >= DATE '2024-01-01';
```

### **3. PL/SQL Performance Optimization**

#### **Bulk Operations:**
```sql
-- Inefficient Row-by-Row Processing
DECLARE
    CURSOR emp_cursor IS 
        SELECT employee_id, salary FROM employees;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        UPDATE employee_bonuses 
        SET bonus_amount = emp_rec.salary * 0.1
        WHERE employee_id = emp_rec.employee_id;
    END LOOP;
    COMMIT;
END;
/

-- Optimized Bulk Processing
DECLARE
    TYPE emp_array_t IS TABLE OF employees%ROWTYPE;
    l_employees emp_array_t;
    
    CURSOR emp_cursor IS 
        SELECT employee_id, salary FROM employees;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor BULK COLLECT INTO l_employees LIMIT 1000;
        
        FORALL i IN l_employees.FIRST..l_employees.LAST
            UPDATE employee_bonuses 
            SET bonus_amount = l_employees(i).salary * 0.1
            WHERE employee_id = l_employees(i).employee_id;
        
        EXIT WHEN l_employees.COUNT < 1000;
    END LOOP;
    CLOSE emp_cursor;
    COMMIT;
END;
/

-- Using MERGE for Upsert Operations
MERGE INTO employee_performance_summary eps
USING (
    SELECT 
        employee_id,
        COUNT(*) as total_reviews,
        AVG(overall_rating) as avg_rating,
        MAX(review_date) as last_review_date
    FROM performance_reviews
    WHERE review_date >= ADD_MONTHS(SYSDATE, -12)
    GROUP BY employee_id
) pr ON (eps.employee_id = pr.employee_id)
WHEN MATCHED THEN
    UPDATE SET 
        total_reviews = pr.total_reviews,
        avg_rating = pr.avg_rating,
        last_review_date = pr.last_review_date,
        updated_date = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (employee_id, total_reviews, avg_rating, last_review_date, created_date)
    VALUES (pr.employee_id, pr.total_reviews, pr.avg_rating, pr.last_review_date, SYSDATE);
```

## 📊 Advanced Performance Techniques

### **1. Partitioning Strategies**

#### **Table Partitioning Implementation:**
```sql
-- Range Partitioning for Time-based Data
CREATE TABLE sales_data_partitioned (
    sale_id NUMBER,
    sale_date DATE,
    customer_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (sale_date) (
    PARTITION sales_2023_q1 VALUES LESS THAN (DATE '2023-04-01'),
    PARTITION sales_2023_q2 VALUES LESS THAN (DATE '2023-07-01'),
    PARTITION sales_2023_q3 VALUES LESS THAN (DATE '2023-10-01'),
    PARTITION sales_2023_q4 VALUES LESS THAN (DATE '2024-01-01'),
    PARTITION sales_2024_q1 VALUES LESS THAN (DATE '2024-04-01'),
    PARTITION sales_future VALUES LESS THAN (MAXVALUE)
);

-- Hash Partitioning for Even Distribution
CREATE TABLE customer_data_partitioned (
    customer_id NUMBER,
    customer_name VARCHAR2(100),
    registration_date DATE,
    status VARCHAR2(20)
)
PARTITION BY HASH (customer_id)
PARTITIONS 8;

-- Composite Partitioning (Range-Hash)
CREATE TABLE transaction_log_partitioned (
    transaction_id NUMBER,
    transaction_date DATE,
    account_id NUMBER,
    amount DECIMAL(15,2),
    transaction_type VARCHAR2(20)
)
PARTITION BY RANGE (transaction_date)
SUBPARTITION BY HASH (account_id) SUBPARTITIONS 4 (
    PARTITION txn_2023 VALUES LESS THAN (DATE '2024-01-01'),
    PARTITION txn_2024 VALUES LESS THAN (DATE '2025-01-01'),
    PARTITION txn_future VALUES LESS THAN (MAXVALUE)
);
```

### **2. Materialized Views for Performance**

#### **Aggregation and Join Optimization:**
```sql
-- Create Materialized View for Complex Aggregations
CREATE MATERIALIZED VIEW mv_department_summary
REFRESH FAST ON COMMIT
AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    AVG(e.salary) as avg_salary,
    SUM(e.salary) as total_salary_cost,
    MIN(e.hire_date) as earliest_hire_date,
    MAX(e.hire_date) as latest_hire_date
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employment_status = 'ACTIVE'
GROUP BY d.department_id, d.department_name;

-- Create Materialized View Log for Fast Refresh
CREATE MATERIALIZED VIEW LOG ON employees
WITH ROWID, SEQUENCE (employee_id, department_id, salary, employment_status)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON departments
WITH ROWID, SEQUENCE (department_id, department_name)
INCLUDING NEW VALUES;

-- Query Rewrite Using Materialized Views
-- Original expensive query
SELECT 
    department_name,
    employee_count,
    avg_salary
FROM mv_department_summary
WHERE employee_count > 10
ORDER BY avg_salary DESC;
```

### **3. Caching and Session Optimization**

#### **Result Cache Implementation:**
```sql
-- Function Result Cache
CREATE OR REPLACE FUNCTION get_department_budget(
    p_department_id NUMBER
) RETURN NUMBER
RESULT_CACHE RELIES_ON (departments, budget_allocations)
IS
    v_budget NUMBER;
BEGIN
    SELECT total_budget 
    INTO v_budget
    FROM budget_allocations 
    WHERE department_id = p_department_id
    AND fiscal_year = EXTRACT(YEAR FROM SYSDATE);
    
    RETURN v_budget;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Query Result Cache
SELECT /*+ RESULT_CACHE */
    department_name,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE employment_status = 'ACTIVE'
GROUP BY department_name;

-- Session-level Optimizations
ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS_10;
ALTER SESSION SET HASH_AREA_SIZE = 104857600;  -- 100MB
ALTER SESSION SET SORT_AREA_SIZE = 104857600;  -- 100MB
ALTER SESSION SET DB_FILE_MULTIBLOCK_READ_COUNT = 16;
```

## 🔧 Performance Monitoring and Alerts

### **Automated Performance Monitoring:**
```sql
-- Create Performance Monitoring Table
CREATE TABLE performance_alerts (
    alert_id NUMBER PRIMARY KEY,
    alert_time DATE DEFAULT SYSDATE,
    alert_type VARCHAR2(50),
    metric_name VARCHAR2(100),
    current_value NUMBER,
    threshold_value NUMBER,
    severity VARCHAR2(20),
    alert_message CLOB,
    resolved_time DATE,
    resolved_by VARCHAR2(50)
);

-- Performance Alert Procedure
CREATE OR REPLACE PROCEDURE check_performance_thresholds IS
    v_buffer_cache_hit_ratio NUMBER;
    v_library_cache_hit_ratio NUMBER;
    v_parse_count NUMBER;
    v_physical_reads NUMBER;
BEGIN
    -- Check Buffer Cache Hit Ratio
    SELECT 1 - (physical_reads / (db_block_gets + consistent_gets))
    INTO v_buffer_cache_hit_ratio
    FROM v$buffer_pool_statistics
    WHERE name = 'DEFAULT';
    
    IF v_buffer_cache_hit_ratio < 0.90 THEN
        INSERT INTO performance_alerts (
            alert_id, alert_type, metric_name, current_value,
            threshold_value, severity, alert_message
        ) VALUES (
            seq_alert_id.NEXTVAL, 'DATABASE_PERFORMANCE',
            'Buffer Cache Hit Ratio', v_buffer_cache_hit_ratio,
            0.90, 'WARNING',
            'Buffer cache hit ratio is below 90%: ' || 
            ROUND(v_buffer_cache_hit_ratio * 100, 2) || '%'
        );
    END IF;
    
    -- Check for Long Running Queries
    INSERT INTO performance_alerts (
        alert_id, alert_type, metric_name, current_value,
        threshold_value, severity, alert_message
    )
    SELECT 
        seq_alert_id.NEXTVAL, 'LONG_RUNNING_QUERY',
        'Query Execution Time', 
        ROUND(elapsed_time/1000000, 2),
        300, 'CRITICAL',
        'Query ' || sql_id || ' has been running for ' || 
        ROUND(elapsed_time/1000000, 2) || ' seconds'
    FROM v$sql_monitor
    WHERE status = 'EXECUTING'
    AND elapsed_time > 300000000; -- 5 minutes
    
    COMMIT;
END;
/

-- Schedule Performance Monitoring Job
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'PERFORMANCE_MONITOR_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN check_performance_thresholds; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=5',
        enabled         => TRUE,
        comments        => 'Monitor database performance every 5 minutes'
    );
END;
/
```

## 🎯 Performance Tuning Exercises

### **Exercise 1: Query Optimization Challenge**
```sql
-- Slow Query to Optimize
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    p.position_title,
    (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id) as dept_avg_salary,
    (SELECT COUNT(*) FROM performance_reviews WHERE employee_id = e.employee_id) as review_count
FROM employees e, departments d, positions p
WHERE e.department_id = d.department_id
AND e.position_id = p.position_id
AND e.salary > 50000
ORDER BY e.last_name, e.first_name;

-- Your Optimized Version Here:
-- TODO: Rewrite this query for better performance
-- Consider: JOINs vs comma joins, subquery elimination, indexing
```

### **Exercise 2: Index Design Challenge**
```sql
-- Given these common query patterns, design optimal indexes:

-- Query Pattern 1: Employee search by department and salary range
SELECT employee_id, first_name, last_name
FROM employees 
WHERE department_id = ? 
AND salary BETWEEN ? AND ?
ORDER BY last_name, first_name;

-- Query Pattern 2: Performance review lookup
SELECT * FROM performance_reviews 
WHERE employee_id = ? 
AND review_date >= ?
ORDER BY review_date DESC;

-- Query Pattern 3: Department summary with active employees
SELECT d.department_name, COUNT(e.employee_id)
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employment_status = 'ACTIVE'
GROUP BY d.department_name;

-- Design your indexes here:
-- TODO: Create indexes to optimize these queries
```

### **Exercise 3: PL/SQL Performance Improvement**
```sql
-- Inefficient PL/SQL Code to Optimize
CREATE OR REPLACE PROCEDURE update_employee_bonuses IS
    CURSOR emp_cursor IS 
        SELECT employee_id, salary, performance_rating 
        FROM employees e
        JOIN performance_reviews p ON e.employee_id = p.employee_id
        WHERE p.review_year = EXTRACT(YEAR FROM SYSDATE);
    
    v_bonus_pct NUMBER;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        -- Calculate bonus percentage based on rating
        CASE emp_rec.performance_rating
            WHEN 5 THEN v_bonus_pct := 0.15;
            WHEN 4 THEN v_bonus_pct := 0.10;
            WHEN 3 THEN v_bonus_pct := 0.05;
            ELSE v_bonus_pct := 0;
        END CASE;
        
        -- Update employee bonus (row-by-row)
        UPDATE employee_bonuses 
        SET bonus_amount = emp_rec.salary * v_bonus_pct,
            bonus_year = EXTRACT(YEAR FROM SYSDATE)
        WHERE employee_id = emp_rec.employee_id;
        
        -- Log the bonus calculation
        INSERT INTO bonus_calculation_log (
            employee_id, bonus_amount, calculation_date
        ) VALUES (
            emp_rec.employee_id, 
            emp_rec.salary * v_bonus_pct, 
            SYSDATE
        );
    END LOOP;
    
    COMMIT;
END;
/

-- Your Optimized Version Here:
-- TODO: Optimize this procedure using bulk operations
-- Consider: BULK COLLECT, FORALL, set-based operations
```

## 📈 Performance Tuning Best Practices

### **Development Best Practices:**
1. **Design for Performance**: Consider performance during database design
2. **Index Strategy**: Create indexes based on actual query patterns
3. **Query Patterns**: Write efficient SQL from the start
4. **Bulk Operations**: Use bulk processing for large data operations
5. **Resource Management**: Monitor and manage database resources

### **Maintenance Best Practices:**
1. **Regular Monitoring**: Implement continuous performance monitoring
2. **Statistics Management**: Keep optimizer statistics current
3. **Index Maintenance**: Regular index analysis and rebuilding
4. **Archive Strategy**: Implement data archiving for large tables
5. **Capacity Planning**: Plan for growth and scalability

### **Testing Best Practices:**
1. **Performance Testing**: Include performance tests in development
2. **Load Testing**: Test with realistic data volumes
3. **Stress Testing**: Identify breaking points and bottlenecks
4. **Regression Testing**: Ensure changes don't degrade performance
5. **Production Monitoring**: Continuous monitoring in production

This performance tuning guide provides a comprehensive framework for optimizing Oracle Database systems, from basic query optimization to advanced performance management techniques.
