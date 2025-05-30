# Oracle Database Indexes - Comprehensive Guide

Indexes are critical database objects that improve query performance by providing faster data access paths. This comprehensive guide covers all aspects of Oracle Database indexes, from basic concepts to advanced optimization techniques.

## Table of Contents
1. [Index Fundamentals](#index-fundamentals)
2. [B-Tree Indexes](#b-tree-indexes)
3. [Bitmap Indexes](#bitmap-indexes)
4. [Specialized Index Types](#specialized-index-types)
5. [Partitioned Indexes](#partitioned-indexes)
6. [Index Design Principles](#index-design-principles)
7. [Index Maintenance](#index-maintenance)
8. [Performance Monitoring](#performance-monitoring)
9. [Best Practices](#best-practices)

## Index Fundamentals

### What is an Index?
An index is a database object that provides a fast access path to table data. Think of it like an index in a book - it points to the location of specific information without having to scan through every page.

### How Indexes Work
```sql
-- Without index: Full table scan
SELECT * FROM employees WHERE employee_id = 100;
-- Scans every row in the table

-- With index on employee_id: Index lookup
CREATE INDEX idx_emp_id ON employees(employee_id);
-- Direct navigation to the specific row
```

### Index Structure Overview
```
Index Structure Tree
├── Index Root Block
│   ├── Branch Blocks (Internal Nodes)
│   │   ├── Contains key ranges and pointers
│   │   └── Directs search to appropriate leaf blocks
│   └── Leaf Blocks (Data Level)
│       ├── Contains actual key values
│       ├── Contains ROWIDs pointing to table rows
│       └── Linked list for range scans
```

## B-Tree Indexes

B-Tree (Balanced Tree) indexes are the most common type of Oracle indexes, suitable for most query patterns.

### 1. Standard B-Tree Index
```sql
-- Basic B-Tree index creation
CREATE INDEX idx_emp_last_name ON employees(last_name);

-- Verify index creation
SELECT index_name, index_type, status 
FROM user_indexes 
WHERE table_name = 'EMPLOYEES';
```

### 2. Unique Index
```sql
-- Unique index (automatically created with PRIMARY KEY/UNIQUE constraints)
CREATE UNIQUE INDEX idx_emp_email ON employees(email);

-- Explicit unique index
ALTER TABLE employees ADD CONSTRAINT uk_emp_email UNIQUE (email);
```

### 3. Composite Index
```sql
-- Multi-column index (column order matters!)
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);

-- Good for queries like:
SELECT * FROM employees WHERE department_id = 10 AND salary > 50000;
SELECT * FROM employees WHERE department_id = 10; -- Leading column

-- Not optimal for:
SELECT * FROM employees WHERE salary > 50000; -- Non-leading column
```

### 4. Function-Based Index
```sql
-- Index on expression
CREATE INDEX idx_emp_upper_last_name ON employees(UPPER(last_name));

-- Enables efficient case-insensitive searches
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';

-- Date function-based index
CREATE INDEX idx_emp_hire_year ON employees(EXTRACT(YEAR FROM hire_date));

-- Efficient year-based queries
SELECT * FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2023;
```

### 5. Descending Index
```sql
-- Descending order index
CREATE INDEX idx_emp_salary_desc ON employees(salary DESC);

-- Optimal for ORDER BY DESC queries
SELECT * FROM employees ORDER BY salary DESC;
```

## Bitmap Indexes

Bitmap indexes are ideal for low-cardinality data (few distinct values) and data warehouse environments.

### When to Use Bitmap Indexes
- Low-cardinality columns (gender, status, region)
- Data warehouse/OLAP environments
- Complex WHERE clauses with multiple conditions
- Read-heavy workloads

```sql
-- Bitmap index creation
CREATE BITMAP INDEX idx_emp_gender ON employees(gender);
CREATE BITMAP INDEX idx_emp_department ON employees(department_id);
CREATE BITMAP INDEX idx_emp_status ON employees(status);

-- Efficient for complex queries
SELECT COUNT(*) 
FROM employees 
WHERE gender = 'F' 
  AND department_id IN (10, 20) 
  AND status = 'ACTIVE';
```

### Bitmap Index Advantages
- Very efficient for AND, OR, NOT operations
- Significant space savings for low-cardinality data
- Fast COUNT(*) operations

### Bitmap Index Limitations
- Not suitable for OLTP (high DML activity)
- Lock contention issues
- Oracle may convert to B-Tree for certain operations

## Specialized Index Types

### 1. Reverse Key Index
```sql
-- Useful for reducing hot blocks in RAC environments
CREATE INDEX idx_emp_id_reverse ON employees(employee_id) REVERSE;

-- Example: employee_id 12345 stored as 54321
```

### 2. Key-Compressed Index
```sql
-- Compress repeated key values
CREATE INDEX idx_emp_dept_name_comp ON employees(department_id, last_name) COMPRESS 1;

-- Saves space when first column has many repeated values
```

### 3. Invisible Index
```sql
-- Index exists but optimizer ignores it by default
CREATE INDEX idx_emp_phone INVISIBLE ON employees(phone_number);

-- Test index effectiveness without affecting production
ALTER SESSION SET optimizer_use_invisible_indexes = TRUE;
```

### 4. Virtual Column Index
```sql
-- Create virtual column
ALTER TABLE employees ADD (full_name GENERATED ALWAYS AS (first_name || ' ' || last_name));

-- Index on virtual column
CREATE INDEX idx_emp_full_name ON employees(full_name);
```

## Partitioned Indexes

### Global Partitioned Index
```sql
-- Global index across all partitions
CREATE INDEX idx_emp_global_salary 
ON employees_partitioned(salary)
GLOBAL PARTITION BY RANGE (salary)
(
    PARTITION p1 VALUES LESS THAN (30000),
    PARTITION p2 VALUES LESS THAN (60000),
    PARTITION p3 VALUES LESS THAN (MAXVALUE)
);
```

### Local Partitioned Index
```sql
-- Local index: one index segment per table partition
CREATE INDEX idx_emp_local_hire_date 
ON employees_partitioned(hire_date) LOCAL;
```

## Index Design Principles

### 1. Selectivity Analysis
```sql
-- Check column selectivity
SELECT 
    column_name,
    COUNT(DISTINCT column_name) as distinct_values,
    COUNT(*) as total_rows,
    ROUND(COUNT(DISTINCT column_name) / COUNT(*) * 100, 2) as selectivity_percent
FROM employees
GROUP BY column_name;

-- High selectivity (>5%) = Good for B-Tree
-- Low selectivity (<5%) = Consider Bitmap
```

### 2. Query Pattern Analysis
```sql
-- Identify frequently accessed columns
SELECT 
    operation,
    object_name,
    COUNT(*) as access_count
FROM v$sql_plan 
WHERE object_owner = USER 
  AND object_name = 'EMPLOYEES'
GROUP BY operation, object_name
ORDER BY access_count DESC;
```

### 3. Composite Index Column Order
```sql
-- Order by: Equality → Range → Sort
-- Example query: WHERE dept_id = 10 AND salary > 50000 ORDER BY hire_date

-- Optimal index:
CREATE INDEX idx_optimal ON employees(department_id, salary, hire_date);
--                                   equality    range     sort
```

## Index Maintenance

### 1. Index Statistics
```sql
-- Gather index statistics
EXEC DBMS_STATS.GATHER_INDEX_STATS('HR', 'IDX_EMP_LAST_NAME');

-- Gather table and all related index stats
EXEC DBMS_STATS.GATHER_TABLE_STATS('HR', 'EMPLOYEES', CASCADE => TRUE);
```

### 2. Index Rebuild
```sql
-- Check if rebuild is needed
SELECT 
    index_name,
    blevel,
    leaf_blocks,
    distinct_keys,
    clustering_factor
FROM user_indexes 
WHERE table_name = 'EMPLOYEES';

-- Rebuild index (online rebuild for minimal downtime)
ALTER INDEX idx_emp_last_name REBUILD ONLINE;

-- Rebuild with new tablespace
ALTER INDEX idx_emp_last_name REBUILD TABLESPACE new_index_ts;
```

### 3. Index Reorganization
```sql
-- Coalesce to merge adjacent free spaces
ALTER INDEX idx_emp_last_name COALESCE;

-- Shrink index (11g+)
ALTER INDEX idx_emp_last_name SHRINK SPACE;
```

## Performance Monitoring

### 1. Index Usage Monitoring
```sql
-- Enable index monitoring
ALTER INDEX idx_emp_last_name MONITORING USAGE;

-- Check usage statistics
SELECT * FROM v$object_usage WHERE index_name = 'IDX_EMP_LAST_NAME';

-- Disable monitoring
ALTER INDEX idx_emp_last_name NOMONITORING USAGE;
```

### 2. Index Performance Metrics
```sql
-- Index efficiency query
SELECT 
    i.index_name,
    i.clustering_factor,
    t.num_rows,
    ROUND(i.clustering_factor / t.num_rows * 100, 2) as efficiency_ratio
FROM user_indexes i
JOIN user_tables t ON i.table_name = t.table_name
WHERE t.table_name = 'EMPLOYEES';

-- Lower clustering_factor = more efficient
```

### 3. Execution Plan Analysis
```sql
-- Check index usage in execution plans
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ADVANCED'));

-- Look for:
-- INDEX RANGE SCAN (good)
-- INDEX FAST FULL SCAN (acceptable)
-- TABLE ACCESS FULL (potential problem)
```

## Best Practices

### 1. Index Creation Guidelines
```sql
-- DO: Create indexes on frequently queried columns
CREATE INDEX idx_emp_dept_id ON employees(department_id);

-- DO: Create composite indexes for multi-column WHERE clauses
CREATE INDEX idx_emp_dept_status ON employees(department_id, status);

-- DON'T: Over-index (every index adds DML overhead)
-- DON'T: Create indexes on frequently updated columns in OLTP
```

### 2. Maintenance Best Practices
```sql
-- Regular statistics collection
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        ownname => 'HR',
        cascade => TRUE,
        degree => 4
    );
END;
/

-- Automated index maintenance (12c+)
-- Enable automatic index creation
ALTER DATABASE SET "_automatic_index_creation" = TRUE;
```

### 3. Index Naming Conventions
```sql
-- Descriptive naming convention
-- Format: idx_[table]_[columns]_[type]
CREATE INDEX idx_emp_lastname_btree ON employees(last_name);
CREATE INDEX idx_emp_gender_bitmap ON employees(gender);
CREATE INDEX idx_emp_salary_desc ON employees(salary DESC);
```

## Advanced Index Scenarios

### 1. Conditional Indexing
```sql
-- Partial index (only active employees)
CREATE INDEX idx_emp_active_salary 
ON employees(salary) 
WHERE status = 'ACTIVE';
```

### 2. Index for JSON Data
```sql
-- JSON functional index
CREATE INDEX idx_emp_json_skills 
ON employees (JSON_VALUE(skills, '$.programming'));

-- Efficient JSON queries
SELECT * FROM employees 
WHERE JSON_VALUE(skills, '$.programming') = 'Oracle';
```

### 3. Text Indexing
```sql
-- Full-text search index
CREATE INDEX idx_emp_resume_text 
ON employees(resume) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- Text search queries
SELECT * FROM employees 
WHERE CONTAINS(resume, 'Oracle AND Database') > 0;
```

## Troubleshooting Common Issues

### 1. Unused Indexes
```sql
-- Find unused indexes
SELECT 
    index_name,
    table_name,
    last_used
FROM v$object_usage 
WHERE used = 'NO' 
  AND monitoring = 'YES';
```

### 2. Duplicate Indexes
```sql
-- Find potentially duplicate indexes
SELECT 
    index_name,
    table_name,
    column_name,
    column_position
FROM user_ind_columns 
WHERE table_name = 'EMPLOYEES'
ORDER BY table_name, column_name, column_position;
```

### 3. Index Contention
```sql
-- Monitor index block contention
SELECT 
    object_name,
    statistic_name,
    value
FROM v$segment_statistics 
WHERE object_name LIKE 'IDX_%'
  AND statistic_name LIKE '%waits%'
ORDER BY value DESC;
```

## Exercises

### Exercise 1: Basic Index Creation
1. Create a B-Tree index on the `employees.salary` column
2. Create a composite index on `department_id` and `hire_date`
3. Verify both indexes were created successfully

### Exercise 2: Function-Based Index
1. Create a function-based index for case-insensitive last name searches
2. Test the index with an appropriate query
3. Check the execution plan to confirm index usage

### Exercise 3: Index Performance Analysis
1. Monitor the usage of an existing index
2. Gather statistics for the index
3. Analyze the clustering factor and efficiency

### Exercise 4: Index Maintenance
1. Create an index and populate the table with data
2. Perform a rebuild operation
3. Compare before and after statistics

## Summary

Indexes are powerful tools for improving Oracle Database performance, but they require careful design and maintenance. Key takeaways:

- **Choose the right index type** for your data and query patterns
- **Design composite indexes** with proper column ordering
- **Monitor index usage** and performance regularly
- **Maintain indexes** through statistics and rebuilds
- **Balance performance gains** against maintenance overhead

Proper index management is crucial for optimal database performance and should be an integral part of your database administration strategy.
