# Code Review Best Practices Guide

## 🎯 Overview

This guide establishes comprehensive code review standards and best practices for Oracle Database development. Learn to conduct effective code reviews, maintain code quality, and establish professional development standards that ensure maintainable, secure, and performant database solutions.

## 📋 Learning Objectives

### **Core Competencies:**
- Establish code review processes and standards
- Implement quality gates and checkpoints
- Master SQL and PL/SQL coding standards
- Understand security review requirements
- Create automated code quality checks

### **Professional Skills:**
- Lead effective code review sessions
- Provide constructive feedback
- Implement continuous integration practices
- Maintain coding standards documentation
- Foster collaborative development culture

## 📝 Code Review Framework

### **1. Review Process Workflow**

#### **Pre-Review Checklist:**
```sql
-- Developer Self-Review Checklist
/*
Before submitting code for review, ensure:

□ Code compiles without errors or warnings
□ All unit tests pass
□ Code follows naming conventions
□ Comments explain complex logic
□ Security considerations addressed
□ Performance impact assessed
□ Documentation updated
□ Rollback procedures documented
*/

-- Code Review Request Template
/*
## Code Review Request

**Change Description:**
Brief description of what this change does

**Business Justification:**
Why this change is needed

**Files Changed:**
- schema_changes.sql
- new_procedures.sql
- updated_functions.sql

**Testing Performed:**
- Unit tests: ✓
- Integration tests: ✓
- Performance tests: ✓

**Deployment Notes:**
Special considerations for deployment

**Rollback Plan:**
How to rollback if issues occur
*/
```

#### **Review Stages:**
1. **Automated Checks**: Static analysis and syntax validation
2. **Functional Review**: Logic, algorithm, and business rule validation
3. **Security Review**: Security vulnerabilities and data protection
4. **Performance Review**: Query optimization and resource usage
5. **Standards Review**: Coding standards and best practices compliance

### **2. SQL Code Review Standards**

#### **Query Structure and Readability:**
```sql
-- ❌ Poor: Hard to read, no formatting
SELECT e.employee_id,e.first_name,e.last_name,d.department_name,p.position_title,e.salary FROM employees e,departments d,positions p WHERE e.department_id=d.department_id AND e.position_id=p.position_id AND e.salary>50000 ORDER BY e.salary DESC;

-- ✅ Good: Well-formatted, readable
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    p.position_title,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN positions p ON e.position_id = p.position_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- ❌ Poor: Using old-style joins
SELECT e.first_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;

-- ✅ Good: Using ANSI joins
SELECT 
    e.first_name, 
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- ❌ Poor: No table aliases for complex queries
SELECT employees.first_name, departments.department_name, positions.position_title
FROM employees, departments, positions
WHERE employees.department_id = departments.department_id
AND employees.position_id = positions.position_id;

-- ✅ Good: Clear, consistent aliases
SELECT 
    emp.first_name,
    dept.department_name,
    pos.position_title
FROM employees emp
JOIN departments dept ON emp.department_id = dept.department_id
JOIN positions pos ON emp.position_id = pos.position_id;
```

#### **Performance Considerations:**
```sql
-- ❌ Poor: Function in WHERE clause prevents index usage
SELECT employee_id, first_name, last_name
FROM employees
WHERE UPPER(last_name) = 'SMITH';

-- ✅ Good: Function-based index or rewrite query
-- Option 1: Create function-based index
CREATE INDEX idx_emp_lastname_upper ON employees(UPPER(last_name));

-- Option 2: Store data in consistent case
SELECT employee_id, first_name, last_name
FROM employees
WHERE last_name = 'SMITH';  -- Assuming data is stored in uppercase

-- ❌ Poor: Correlated subquery
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    (SELECT d.department_name 
     FROM departments d 
     WHERE d.department_id = e.department_id) as department_name
FROM employees e;

-- ✅ Good: JOIN instead of correlated subquery
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- ❌ Poor: SELECT * in production code
SELECT * FROM employees WHERE department_id = 10;

-- ✅ Good: Explicit column list
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    hire_date,
    salary
FROM employees 
WHERE department_id = 10;
```

### **3. PL/SQL Code Review Standards**

#### **Procedure and Function Structure:**
```sql
-- ❌ Poor: No comments, poor naming, no error handling
CREATE OR REPLACE PROCEDURE upd_emp_sal(id NUMBER, sal NUMBER) IS
BEGIN
UPDATE employees SET salary = sal WHERE employee_id = id;
COMMIT;
END;
/

-- ✅ Good: Well-documented, proper error handling
/*
 * Purpose: Update employee salary with validation and audit trail
 * Author: [Developer Name]
 * Created: [Date]
 * Modified: [Date] - [Modification Description]
 * 
 * Parameters:
 *   p_employee_id - Employee ID to update
 *   p_new_salary  - New salary amount
 *   p_reason      - Reason for salary change
 *   p_updated_by  - User making the change
 * 
 * Exceptions:
 *   -20001: Employee not found
 *   -20002: Invalid salary amount
 *   -20003: Salary increase exceeds policy limits
 */
CREATE OR REPLACE PROCEDURE update_employee_salary(
    p_employee_id   IN NUMBER,
    p_new_salary    IN NUMBER,
    p_reason        IN VARCHAR2,
    p_updated_by    IN VARCHAR2
) IS
    -- Constants
    c_max_increase_pct CONSTANT NUMBER := 20; -- Maximum 20% increase
    
    -- Variables
    v_current_salary    employees.salary%TYPE;
    v_increase_pct      NUMBER;
    v_employee_exists   NUMBER;
    
    -- Exceptions
    emp_not_found_ex    EXCEPTION;
    PRAGMA EXCEPTION_INIT(emp_not_found_ex, -20001);
    
    invalid_salary_ex   EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_salary_ex, -20002);
    
    excess_increase_ex  EXCEPTION;
    PRAGMA EXCEPTION_INIT(excess_increase_ex, -20003);
    
BEGIN
    -- Input validation
    IF p_employee_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee ID cannot be null');
    END IF;
    
    IF p_new_salary IS NULL OR p_new_salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Salary must be a positive number');
    END IF;
    
    -- Check if employee exists and get current salary
    BEGIN
        SELECT salary 
        INTO v_current_salary
        FROM employees 
        WHERE employee_id = p_employee_id
        AND employment_status = 'ACTIVE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 
                'Active employee not found with ID: ' || p_employee_id);
    END;
    
    -- Calculate increase percentage
    v_increase_pct := ((p_new_salary - v_current_salary) / v_current_salary) * 100;
    
    -- Validate increase doesn't exceed policy
    IF v_increase_pct > c_max_increase_pct THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'Salary increase of ' || ROUND(v_increase_pct, 2) || 
            '% exceeds maximum allowed increase of ' || c_max_increase_pct || '%');
    END IF;
    
    -- Update employee salary
    UPDATE employees 
    SET salary = p_new_salary,
        last_updated = SYSDATE,
        last_updated_by = p_updated_by
    WHERE employee_id = p_employee_id;
    
    -- Create audit trail
    INSERT INTO salary_audit_log (
        employee_id,
        old_salary,
        new_salary,
        change_percentage,
        change_reason,
        changed_by,
        change_date
    ) VALUES (
        p_employee_id,
        v_current_salary,
        p_new_salary,
        v_increase_pct,
        p_reason,
        p_updated_by,
        SYSDATE
    );
    
    COMMIT;
    
    -- Log successful completion
    log_procedure_call(
        'update_employee_salary',
        'SUCCESS',
        'Updated salary for employee ' || p_employee_id || 
        ' from ' || v_current_salary || ' to ' || p_new_salary
    );
    
EXCEPTION
    WHEN emp_not_found_ex OR invalid_salary_ex OR excess_increase_ex THEN
        ROLLBACK;
        log_procedure_call('update_employee_salary', 'ERROR', SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        log_procedure_call('update_employee_salary', 'ERROR', 
            'Unexpected error: ' || SQLERRM);
        RAISE_APPLICATION_ERROR(-20999, 
            'Unexpected error in update_employee_salary: ' || SQLERRM);
END update_employee_salary;
/
```

#### **Cursor and Loop Best Practices:**
```sql
-- ❌ Poor: Implicit cursor, no bulk processing
CREATE OR REPLACE PROCEDURE process_employee_bonuses IS
BEGIN
    FOR emp_rec IN (SELECT employee_id, salary FROM employees) LOOP
        UPDATE employee_bonuses 
        SET bonus_amount = emp_rec.salary * 0.1
        WHERE employee_id = emp_rec.employee_id;
    END LOOP;
    COMMIT;
END;
/

-- ✅ Good: Explicit cursor with bulk processing
CREATE OR REPLACE PROCEDURE process_employee_bonuses IS
    -- Cursor declaration
    CURSOR c_employees IS
        SELECT employee_id, salary
        FROM employees
        WHERE employment_status = 'ACTIVE'
        AND hire_date <= ADD_MONTHS(SYSDATE, -12); -- Eligible after 1 year
    
    -- Collection types for bulk processing
    TYPE emp_id_array_t IS TABLE OF employees.employee_id%TYPE;
    TYPE bonus_array_t IS TABLE OF NUMBER;
    
    -- Variables
    v_emp_ids       emp_id_array_t;
    v_bonus_amounts bonus_array_t;
    v_batch_size    CONSTANT PLS_INTEGER := 1000;
    v_processed     PLS_INTEGER := 0;
    
BEGIN
    -- Open cursor and process in batches
    OPEN c_employees;
    LOOP
        -- Bulk collect with limit
        FETCH c_employees BULK COLLECT INTO v_emp_ids LIMIT v_batch_size;
        
        -- Exit if no more data
        EXIT WHEN v_emp_ids.COUNT = 0;
        
        -- Initialize bonus array
        v_bonus_amounts := bonus_array_t();
        v_bonus_amounts.EXTEND(v_emp_ids.COUNT);
        
        -- Calculate bonuses
        FOR i IN 1..v_emp_ids.COUNT LOOP
            -- Get current salary and calculate bonus
            SELECT salary * 0.1
            INTO v_bonus_amounts(i)
            FROM employees
            WHERE employee_id = v_emp_ids(i);
        END LOOP;
        
        -- Bulk update
        FORALL i IN 1..v_emp_ids.COUNT
            UPDATE employee_bonuses 
            SET bonus_amount = v_bonus_amounts(i),
                calculation_date = SYSDATE
            WHERE employee_id = v_emp_ids(i);
        
        -- Track progress
        v_processed := v_processed + v_emp_ids.COUNT;
        
        -- Periodic commit to avoid long transactions
        COMMIT;
        
        -- Log progress
        IF MOD(v_processed, 10000) = 0 THEN
            log_procedure_call('process_employee_bonuses', 'INFO',
                'Processed ' || v_processed || ' employees');
        END IF;
        
    END LOOP;
    
    CLOSE c_employees;
    
    -- Final commit and logging
    COMMIT;
    log_procedure_call('process_employee_bonuses', 'SUCCESS',
        'Completed processing ' || v_processed || ' employees');
        
EXCEPTION
    WHEN OTHERS THEN
        -- Cleanup
        IF c_employees%ISOPEN THEN
            CLOSE c_employees;
        END IF;
        
        ROLLBACK;
        log_procedure_call('process_employee_bonuses', 'ERROR',
            'Error processing at record ' || v_processed || ': ' || SQLERRM);
        RAISE;
END process_employee_bonuses;
/
```

### **4. Security Review Checklist**

#### **SQL Injection Prevention:**
```sql
-- ❌ Poor: Dynamic SQL vulnerable to injection
CREATE OR REPLACE PROCEDURE get_employee_data(
    p_search_criteria VARCHAR2
) IS
    v_sql VARCHAR2(4000);
    v_cursor SYS_REFCURSOR;
BEGIN
    v_sql := 'SELECT * FROM employees WHERE ' || p_search_criteria;
    OPEN v_cursor FOR v_sql;
    -- Process cursor...
END;
/

-- ✅ Good: Using bind variables
CREATE OR REPLACE PROCEDURE get_employee_data(
    p_department_id IN NUMBER,
    p_min_salary    IN NUMBER DEFAULT NULL,
    p_status        IN VARCHAR2 DEFAULT 'ACTIVE'
) IS
    v_sql VARCHAR2(4000);
    v_cursor SYS_REFCURSOR;
BEGIN
    v_sql := 'SELECT employee_id, first_name, last_name, salary, hire_date
              FROM employees 
              WHERE department_id = :dept_id
              AND employment_status = :status';
    
    IF p_min_salary IS NOT NULL THEN
        v_sql := v_sql || ' AND salary >= :min_sal';
        OPEN v_cursor FOR v_sql USING p_department_id, p_status, p_min_salary;
    ELSE
        OPEN v_cursor FOR v_sql USING p_department_id, p_status;
    END IF;
    
    -- Process cursor...
END;
/
```

#### **Data Access Controls:**
```sql
-- ✅ Good: Row Level Security Implementation
CREATE OR REPLACE FUNCTION employee_security_policy(
    schema_var IN VARCHAR2,
    table_var  IN VARCHAR2
) RETURN VARCHAR2 IS
    v_user_dept NUMBER;
    v_predicate VARCHAR2(4000);
BEGIN
    -- Get user's department from context
    v_user_dept := SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER');
    
    -- Different access levels based on role
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'HR_MANAGER' THEN
        -- HR Manager can see all employees
        v_predicate := '1=1';
    ELSIF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'DEPT_MANAGER' THEN
        -- Department manager can only see their department
        v_predicate := 'department_id = ' || v_user_dept;
    ELSE
        -- Regular users can only see their own record
        v_predicate := 'employee_id = SYS_CONTEXT(''USERENV'', ''CLIENT_IDENTIFIER'')';
    END IF;
    
    RETURN v_predicate;
END;
/

-- Apply the policy
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'HR',
        object_name     => 'EMPLOYEES',
        policy_name     => 'EMPLOYEE_ACCESS_POLICY',
        function_schema => 'HR',
        policy_function => 'EMPLOYEE_SECURITY_POLICY',
        statement_types => 'SELECT, UPDATE, DELETE'
    );
END;
/
```

#### **Sensitive Data Handling:**
```sql
-- ✅ Good: Data masking for sensitive information
CREATE OR REPLACE VIEW employees_masked AS
SELECT 
    employee_id,
    first_name,
    last_name,
    -- Mask email for non-privileged users
    CASE 
        WHEN SYS_CONTEXT('USERENV', 'SESSION_USER') IN ('HR_ADMIN', 'PAYROLL_ADMIN')
        THEN email
        ELSE REGEXP_REPLACE(email, '(.{3}).*(@.*)', '\1***\2')
    END as email,
    department_id,
    position_id,
    hire_date,
    -- Mask salary for non-privileged users
    CASE 
        WHEN SYS_CONTEXT('USERENV', 'SESSION_USER') IN ('HR_ADMIN', 'PAYROLL_ADMIN')
        THEN salary
        ELSE NULL
    END as salary,
    employment_status
FROM employees;

-- Encrypted storage for sensitive data
CREATE TABLE employee_sensitive_data (
    employee_id NUMBER PRIMARY KEY,
    encrypted_ssn RAW(128),  -- Encrypted Social Security Number
    encrypted_salary RAW(128), -- Encrypted salary information
    CONSTRAINT fk_emp_sensitive FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
);
```

### **5. Code Quality Metrics**

#### **Automated Quality Checks:**
```sql
-- Code Complexity Analysis
WITH procedure_complexity AS (
    SELECT 
        object_name,
        object_type,
        COUNT(*) as line_count,
        -- Count decision points (IF, CASE, LOOP, etc.)
        (LENGTH(source) - LENGTH(REPLACE(UPPER(source), 'IF ', ''))) / 3 +
        (LENGTH(source) - LENGTH(REPLACE(UPPER(source), 'CASE ', ''))) / 5 +
        (LENGTH(source) - LENGTH(REPLACE(UPPER(source), 'LOOP', ''))) / 4 +
        (LENGTH(source) - LENGTH(REPLACE(UPPER(source), 'WHILE', ''))) / 5 as complexity_score
    FROM user_source
    WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE BODY')
    GROUP BY object_name, object_type
)
SELECT 
    object_name,
    object_type,
    line_count,
    complexity_score,
    CASE 
        WHEN complexity_score > 20 THEN 'HIGH COMPLEXITY - REVIEW NEEDED'
        WHEN complexity_score > 10 THEN 'MEDIUM COMPLEXITY'
        ELSE 'LOW COMPLEXITY'
    END as complexity_rating
FROM procedure_complexity
ORDER BY complexity_score DESC;

-- Naming Convention Compliance
SELECT 
    object_name,
    object_type,
    CASE 
        WHEN object_type = 'TABLE' AND object_name NOT LIKE '%S' 
        THEN 'Table should be plural'
        WHEN object_type = 'PROCEDURE' AND object_name NOT LIKE 'SP_%' 
        THEN 'Procedure should start with SP_'
        WHEN object_type = 'FUNCTION' AND object_name NOT LIKE 'FN_%' 
        THEN 'Function should start with FN_'
        WHEN object_type = 'VIEW' AND object_name NOT LIKE 'VW_%' 
        THEN 'View should start with VW_'
        ELSE 'COMPLIANT'
    END as naming_compliance
FROM user_objects
WHERE object_type IN ('TABLE', 'PROCEDURE', 'FUNCTION', 'VIEW')
AND naming_compliance != 'COMPLIANT';

-- Code Documentation Assessment
SELECT 
    object_name,
    object_type,
    COUNT(*) as total_lines,
    SUM(CASE WHEN LTRIM(text) LIKE '--%' OR LTRIM(text) LIKE '/*%' 
        THEN 1 ELSE 0 END) as comment_lines,
    ROUND(SUM(CASE WHEN LTRIM(text) LIKE '--%' OR LTRIM(text) LIKE '/*%' 
        THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as comment_percentage
FROM user_source
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE BODY')
GROUP BY object_name, object_type
HAVING comment_percentage < 20  -- Flag objects with < 20% comments
ORDER BY comment_percentage;
```

## 🔍 Review Process Implementation

### **1. Automated Pre-Commit Checks**

#### **Git Pre-Commit Hook Script:**
```bash
#!/bin/bash
# Oracle Database Pre-Commit Hook

echo "Running Oracle Database code quality checks..."

# Check for SQL compilation errors
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sql|pks|pkb)$'); do
    echo "Checking syntax for $file..."
    
    # Simple syntax check using SQLPlus
    sqlplus -s /nolog <<EOF > /tmp/syntax_check.log
connect $DB_USER/$DB_PASSWORD@$DB_CONNECTION
set echo off
set feedback off
set heading off
set pagesize 0
@$file
exit;
EOF

    if grep -i "error\|invalid" /tmp/syntax_check.log; then
        echo "Syntax errors found in $file"
        cat /tmp/syntax_check.log
        exit 1
    fi
done

# Check naming conventions
python3 scripts/check_naming_conventions.py

# Check for SQL injection vulnerabilities
python3 scripts/check_sql_injection.py

echo "All checks passed!"
```

### **2. Code Review Templates**

#### **Review Checklist Template:**
```markdown
## Code Review Checklist

### Functionality
- [ ] Code implements required functionality correctly
- [ ] Business logic is accurate and complete
- [ ] Edge cases are handled appropriately
- [ ] Error conditions are properly managed

### Code Quality
- [ ] Code follows established naming conventions
- [ ] Code is properly formatted and readable
- [ ] Complex logic is well-commented
- [ ] No code duplication or redundancy

### Performance
- [ ] Queries are optimized for performance
- [ ] Appropriate indexes are used
- [ ] Bulk operations used where applicable
- [ ] Resource usage is reasonable

### Security
- [ ] No SQL injection vulnerabilities
- [ ] Appropriate access controls implemented
- [ ] Sensitive data properly protected
- [ ] Input validation implemented

### Testing
- [ ] Unit tests provided and passing
- [ ] Integration tests included
- [ ] Test coverage is adequate
- [ ] Test data is appropriate

### Documentation
- [ ] Code is properly documented
- [ ] API documentation updated
- [ ] Deployment notes provided
- [ ] Rollback procedures documented

### Standards Compliance
- [ ] Follows coding standards
- [ ] Meets security requirements
- [ ] Complies with regulatory requirements
- [ ] Follows change management process
```

### **3. Continuous Integration Integration**

#### **Database CI/CD Pipeline:**
```yaml
# .github/workflows/database-ci.yml
name: Database CI/CD Pipeline

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main ]

jobs:
  code-quality:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Oracle Client
      run: |
        # Install Oracle Instant Client
        wget https://download.oracle.com/otn_software/linux/instantclient/oracle-instantclient-basic-linuxx64.rpm
        sudo rpm -Uvh oracle-instantclient-basic-linuxx64.rpm
    
    - name: SQL Syntax Check
      run: |
        for file in $(find . -name "*.sql"); do
          sqlplus -s /nolog @scripts/syntax_check.sql $file
        done
    
    - name: Code Quality Analysis
      run: |
        python scripts/code_quality_check.py
    
    - name: Security Scan
      run: |
        python scripts/security_scan.py
    
    - name: Generate Review Report
      run: |
        python scripts/generate_review_report.py
        
    - name: Upload Review Artifacts
      uses: actions/upload-artifact@v2
      with:
        name: review-report
        path: reports/
```

## 📊 Code Review Metrics and Reporting

### **Review Effectiveness Metrics:**
```sql
-- Code Review Metrics Dashboard
CREATE OR REPLACE VIEW code_review_metrics AS
SELECT 
    cr.review_id,
    cr.object_name,
    cr.object_type,
    cr.review_date,
    cr.reviewer,
    cr.status,
    cr.defects_found,
    cr.review_effort_hours,
    CASE 
        WHEN cr.defects_found = 0 THEN 'CLEAN'
        WHEN cr.defects_found <= 3 THEN 'MINOR_ISSUES'
        WHEN cr.defects_found <= 7 THEN 'MAJOR_ISSUES'
        ELSE 'SIGNIFICANT_ISSUES'
    END as review_category,
    cr.lines_of_code,
    ROUND(cr.defects_found / cr.lines_of_code * 100, 2) as defect_density
FROM code_reviews cr
WHERE cr.review_date >= SYSDATE - 90  -- Last 90 days
ORDER BY cr.review_date DESC;

-- Reviewer Performance Analysis
SELECT 
    reviewer,
    COUNT(*) as reviews_completed,
    AVG(review_effort_hours) as avg_review_time,
    AVG(defects_found) as avg_defects_found,
    SUM(lines_of_code) as total_loc_reviewed,
    ROUND(AVG(defects_found / lines_of_code * 100), 2) as avg_defect_density
FROM code_reviews
WHERE review_date >= SYSDATE - 90
GROUP BY reviewer
ORDER BY reviews_completed DESC;

-- Code Quality Trends
SELECT 
    TO_CHAR(review_date, 'YYYY-MM') as review_month,
    COUNT(*) as total_reviews,
    AVG(defects_found) as avg_defects,
    AVG(lines_of_code) as avg_loc,
    ROUND(AVG(defects_found / lines_of_code * 100), 2) as avg_defect_density,
    COUNT(CASE WHEN defects_found = 0 THEN 1 END) as clean_reviews,
    ROUND(COUNT(CASE WHEN defects_found = 0 THEN 1 END) / COUNT(*) * 100, 1) as clean_review_pct
FROM code_reviews
WHERE review_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TO_CHAR(review_date, 'YYYY-MM')
ORDER BY review_month;
```

This comprehensive code review guide establishes the foundation for maintaining high-quality Oracle Database code through systematic review processes, automated quality checks, and continuous improvement practices.
