-- HR Management System - Views
-- Views for reporting, security, and data abstraction
-- Part of Lesson 6: Practice and Application

-- Set proper line size and page formatting for output
SET LINESIZE 200
SET PAGESIZE 100
SET ECHO ON
SET FEEDBACK ON

-- Clean up existing views
PROMPT Dropping existing views...
BEGIN
    FOR v IN (SELECT view_name FROM user_views WHERE view_name LIKE 'V_HR_%') LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;
END;
/

PROMPT Creating HR Management Views...

-- =============================================================================
-- EMPLOYEE INFORMATION VIEWS
-- =============================================================================

-- Comprehensive employee information view
CREATE OR REPLACE VIEW V_HR_EMPLOYEE_INFO AS
SELECT 
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.phone_number,
    e.hire_date,
    TRUNC((SYSDATE - e.hire_date) / 365.25) AS years_of_service,
    e.job_title,
    e.employment_status,
    e.employment_type,
    d.department_name,
    d.location AS department_location,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    e.salary,
    CASE 
        WHEN e.salary >= 100000 THEN 'Executive'
        WHEN e.salary >= 75000 THEN 'Senior'
        WHEN e.salary >= 50000 THEN 'Mid-Level'
        ELSE 'Entry-Level'
    END AS salary_band,
    e.created_date,
    e.last_updated
FROM hr_employees e
LEFT JOIN hr_departments d ON e.department_id = d.department_id
LEFT JOIN hr_employees mgr ON e.manager_id = mgr.employee_id
WHERE e.employment_status = 'ACTIVE';

COMMENT ON VIEW V_HR_EMPLOYEE_INFO IS 'Comprehensive employee information with calculated fields';

-- Active employees summary
CREATE OR REPLACE VIEW V_HR_ACTIVE_EMPLOYEES AS
SELECT 
    employee_id,
    employee_number,
    full_name,
    email,
    phone_number,
    job_title,
    department_name,
    hire_date,
    years_of_service,
    salary,
    salary_band
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
ORDER BY department_name, last_name, first_name;

COMMENT ON VIEW V_HR_ACTIVE_EMPLOYEES IS 'Summary view of all active employees';

-- Employee directory (public information only)
CREATE OR REPLACE VIEW V_HR_EMPLOYEE_DIRECTORY AS
SELECT 
    employee_number,
    full_name,
    job_title,
    department_name,
    email,
    phone_number
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
ORDER BY department_name, full_name;

COMMENT ON VIEW V_HR_EMPLOYEE_DIRECTORY IS 'Public employee directory with limited information';

-- =============================================================================
-- PAYROLL AND COMPENSATION VIEWS
-- =============================================================================

-- Current payroll summary
CREATE OR REPLACE VIEW V_HR_PAYROLL_SUMMARY AS
SELECT 
    e.employee_id,
    e.full_name,
    e.department_name,
    e.salary AS base_salary,
    p.gross_pay,
    p.net_pay,
    p.federal_tax,
    p.state_tax,
    p.social_security,
    p.medicare,
    p.benefits_deduction,
    p.other_deductions,
    p.pay_period_start,
    p.pay_period_end,
    p.pay_date,
    ROUND((p.gross_pay / NULLIF(e.salary, 0)) * 100, 2) AS salary_percentage
FROM V_HR_EMPLOYEE_INFO e
JOIN hr_payroll p ON e.employee_id = p.employee_id
WHERE p.pay_date >= TRUNC(SYSDATE, 'MM') -- Current month
ORDER BY e.department_name, e.full_name;

COMMENT ON VIEW V_HR_PAYROLL_SUMMARY IS 'Current month payroll summary with calculations';

-- Salary analysis by department
CREATE OR REPLACE VIEW V_HR_SALARY_ANALYSIS AS
SELECT 
    department_name,
    COUNT(*) AS employee_count,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MEDIAN(salary), 2) AS median_salary,
    ROUND(STDDEV(salary), 2) AS salary_stddev,
    SUM(salary) AS total_payroll
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
GROUP BY department_name
ORDER BY avg_salary DESC;

COMMENT ON VIEW V_HR_SALARY_ANALYSIS IS 'Statistical analysis of salaries by department';

-- =============================================================================
-- BENEFITS AND ENROLLMENT VIEWS
-- =============================================================================

-- Employee benefits enrollment
CREATE OR REPLACE VIEW V_HR_BENEFITS_ENROLLMENT AS
SELECT 
    e.employee_id,
    e.full_name,
    e.department_name,
    bp.plan_name,
    bp.plan_type,
    bp.coverage_type,
    be.enrollment_date,
    be.coverage_start_date,
    be.coverage_end_date,
    be.employee_contribution,
    be.employer_contribution,
    be.total_premium,
    CASE 
        WHEN be.coverage_end_date IS NULL OR be.coverage_end_date > SYSDATE THEN 'Active'
        ELSE 'Inactive'
    END AS enrollment_status
FROM V_HR_EMPLOYEE_INFO e
JOIN hr_benefit_enrollments be ON e.employee_id = be.employee_id
JOIN hr_benefit_plans bp ON be.plan_id = bp.plan_id
ORDER BY e.full_name, bp.plan_type;

COMMENT ON VIEW V_HR_BENEFITS_ENROLLMENT IS 'Employee benefits enrollment with status';

-- Benefits cost summary
CREATE OR REPLACE VIEW V_HR_BENEFITS_COSTS AS
SELECT 
    department_name,
    plan_type,
    COUNT(*) AS enrolled_employees,
    SUM(employee_contribution) AS total_employee_contribution,
    SUM(employer_contribution) AS total_employer_contribution,
    SUM(total_premium) AS total_premium_cost,
    ROUND(AVG(employee_contribution), 2) AS avg_employee_contribution,
    ROUND(AVG(employer_contribution), 2) AS avg_employer_contribution
FROM V_HR_BENEFITS_ENROLLMENT
WHERE enrollment_status = 'Active'
GROUP BY department_name, plan_type
ORDER BY department_name, plan_type;

COMMENT ON VIEW V_HR_BENEFITS_COSTS IS 'Benefits cost analysis by department and plan type';

-- =============================================================================
-- PERFORMANCE AND REVIEW VIEWS
-- =============================================================================

-- Latest performance reviews
CREATE OR REPLACE VIEW V_HR_LATEST_REVIEWS AS
SELECT 
    e.employee_id,
    e.full_name,
    e.department_name,
    e.job_title,
    pr.review_period_start,
    pr.review_period_end,
    pr.overall_rating,
    CASE 
        WHEN pr.overall_rating >= 4.5 THEN 'Exceptional'
        WHEN pr.overall_rating >= 3.5 THEN 'Exceeds Expectations'
        WHEN pr.overall_rating >= 2.5 THEN 'Meets Expectations'
        WHEN pr.overall_rating >= 1.5 THEN 'Below Expectations'
        ELSE 'Unsatisfactory'
    END AS performance_category,
    pr.goals_achievement,
    pr.reviewer_comments,
    pr.review_date,
    mgr.full_name AS reviewer_name
FROM V_HR_EMPLOYEE_INFO e
JOIN hr_performance_reviews pr ON e.employee_id = pr.employee_id
JOIN V_HR_EMPLOYEE_INFO mgr ON pr.reviewer_id = mgr.employee_id
WHERE pr.review_id = (
    SELECT MAX(pr2.review_id)
    FROM hr_performance_reviews pr2
    WHERE pr2.employee_id = pr.employee_id
)
ORDER BY pr.overall_rating DESC, e.full_name;

COMMENT ON VIEW V_HR_LATEST_REVIEWS IS 'Latest performance review for each employee';

-- Performance trends
CREATE OR REPLACE VIEW V_HR_PERFORMANCE_TRENDS AS
SELECT 
    e.employee_id,
    e.full_name,
    e.department_name,
    COUNT(pr.review_id) AS total_reviews,
    ROUND(AVG(pr.overall_rating), 2) AS avg_rating,
    MIN(pr.overall_rating) AS min_rating,
    MAX(pr.overall_rating) AS max_rating,
    ROUND(STDDEV(pr.overall_rating), 2) AS rating_variance,
    MIN(pr.review_date) AS first_review_date,
    MAX(pr.review_date) AS latest_review_date
FROM V_HR_EMPLOYEE_INFO e
JOIN hr_performance_reviews pr ON e.employee_id = pr.employee_id
GROUP BY e.employee_id, e.full_name, e.department_name
HAVING COUNT(pr.review_id) > 1
ORDER BY avg_rating DESC, e.full_name;

COMMENT ON VIEW V_HR_PERFORMANCE_TRENDS IS 'Performance rating trends for employees with multiple reviews';

-- =============================================================================
-- TRAINING AND DEVELOPMENT VIEWS
-- =============================================================================

-- Training enrollment and completion
CREATE OR REPLACE VIEW V_HR_TRAINING_STATUS AS
SELECT 
    e.employee_id,
    e.full_name,
    e.department_name,
    tp.program_name,
    tp.program_type,
    tp.duration_hours,
    te.enrollment_date,
    te.completion_date,
    te.completion_status,
    CASE 
        WHEN te.completion_status = 'COMPLETED' THEN 'Completed'
        WHEN te.completion_status = 'IN_PROGRESS' THEN 'In Progress'
        WHEN te.completion_status = 'NOT_STARTED' THEN 'Not Started'
        ELSE 'Cancelled'
    END AS status_description,
    CASE 
        WHEN te.completion_date IS NOT NULL THEN 
            TRUNC(te.completion_date - te.enrollment_date)
        ELSE NULL
    END AS completion_days
FROM V_HR_EMPLOYEE_INFO e
JOIN hr_training_enrollments te ON e.employee_id = te.employee_id
JOIN hr_training_programs tp ON te.program_id = tp.program_id
ORDER BY e.full_name, te.enrollment_date DESC;

COMMENT ON VIEW V_HR_TRAINING_STATUS IS 'Training enrollment and completion tracking';

-- Training summary by department
CREATE OR REPLACE VIEW V_HR_TRAINING_SUMMARY AS
SELECT 
    department_name,
    program_type,
    COUNT(*) AS total_enrollments,
    SUM(CASE WHEN completion_status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN completion_status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress,
    SUM(CASE WHEN completion_status = 'NOT_STARTED' THEN 1 ELSE 0 END) AS not_started,
    ROUND(
        (SUM(CASE WHEN completion_status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS completion_rate,
    SUM(duration_hours) AS total_training_hours
FROM V_HR_TRAINING_STATUS
GROUP BY department_name, program_type
ORDER BY department_name, completion_rate DESC;

COMMENT ON VIEW V_HR_TRAINING_SUMMARY IS 'Training completion statistics by department and program type';

-- =============================================================================
-- RECRUITMENT AND HIRING VIEWS
-- =============================================================================

-- Active job postings with applications
CREATE OR REPLACE VIEW V_HR_RECRUITMENT_STATUS AS
SELECT 
    jp.posting_id,
    jp.job_title,
    jp.department_name,
    jp.employment_type,
    jp.salary_range_min,
    jp.salary_range_max,
    jp.posting_date,
    jp.application_deadline,
    jp.status AS posting_status,
    COUNT(ja.application_id) AS total_applications,
    SUM(CASE WHEN ja.application_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_apps,
    SUM(CASE WHEN ja.application_status = 'INTERVIEWED' THEN 1 ELSE 0 END) AS interviewed,
    SUM(CASE WHEN ja.application_status = 'OFFERED' THEN 1 ELSE 0 END) AS offered,
    SUM(CASE WHEN ja.application_status = 'HIRED' THEN 1 ELSE 0 END) AS hired,
    SUM(CASE WHEN ja.application_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected
FROM hr_job_postings jp
LEFT JOIN hr_job_applications ja ON jp.posting_id = ja.posting_id
WHERE jp.status = 'ACTIVE'
GROUP BY jp.posting_id, jp.job_title, jp.department_name, jp.employment_type,
         jp.salary_range_min, jp.salary_range_max, jp.posting_date, 
         jp.application_deadline, jp.status
ORDER BY jp.posting_date DESC;

COMMENT ON VIEW V_HR_RECRUITMENT_STATUS IS 'Active job postings with application statistics';

-- =============================================================================
-- DASHBOARD AND EXECUTIVE VIEWS
-- =============================================================================

-- HR Executive Dashboard
CREATE OR REPLACE VIEW V_HR_EXECUTIVE_DASHBOARD AS
SELECT 
    'Employee Count' AS metric,
    TO_CHAR(COUNT(*)) AS value,
    'Total active employees' AS description
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
UNION ALL
SELECT 
    'Average Salary' AS metric,
    TO_CHAR(ROUND(AVG(salary), 0), 'FM$999,999') AS value,
    'Company-wide average salary' AS description
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
UNION ALL
SELECT 
    'Total Payroll' AS metric,
    TO_CHAR(SUM(salary), 'FM$9,999,999') AS value,
    'Annual payroll expense' AS description
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
UNION ALL
SELECT 
    'Departments' AS metric,
    TO_CHAR(COUNT(DISTINCT department_name)) AS value,
    'Active departments' AS description
FROM V_HR_EMPLOYEE_INFO
WHERE employment_status = 'ACTIVE'
UNION ALL
SELECT 
    'Avg Performance Rating' AS metric,
    TO_CHAR(ROUND(AVG(overall_rating), 2)) AS value,
    'Latest review cycle average' AS description
FROM V_HR_LATEST_REVIEWS
UNION ALL
SELECT 
    'Training Completion Rate' AS metric,
    TO_CHAR(ROUND(AVG(completion_rate), 1)) || '%' AS value,
    'Overall training completion rate' AS description
FROM V_HR_TRAINING_SUMMARY;

COMMENT ON VIEW V_HR_EXECUTIVE_DASHBOARD IS 'Key HR metrics for executive dashboard';

-- Department overview
CREATE OR REPLACE VIEW V_HR_DEPARTMENT_OVERVIEW AS
SELECT 
    d.department_name,
    d.location,
    mgr.full_name AS department_manager,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 0) AS avg_salary,
    SUM(e.salary) AS total_payroll,
    ROUND(AVG(pr.overall_rating), 2) AS avg_performance_rating,
    COUNT(DISTINCT tp.program_type) AS training_programs_used
FROM hr_departments d
LEFT JOIN V_HR_EMPLOYEE_INFO mgr ON d.manager_id = mgr.employee_id
LEFT JOIN V_HR_EMPLOYEE_INFO e ON d.department_id = e.employee_id -- This should reference a department join
LEFT JOIN V_HR_LATEST_REVIEWS pr ON e.employee_id = pr.employee_id
LEFT JOIN V_HR_TRAINING_STATUS ts ON e.employee_id = ts.employee_id
LEFT JOIN hr_training_programs tp ON ts.program_name = tp.program_name
WHERE e.employment_status = 'ACTIVE' OR e.employment_status IS NULL
GROUP BY d.department_name, d.location, mgr.full_name
ORDER BY employee_count DESC;

-- Fix the department overview view with correct joins
CREATE OR REPLACE VIEW V_HR_DEPARTMENT_OVERVIEW AS
SELECT 
    d.department_name,
    d.location,
    mgr.first_name || ' ' || mgr.last_name AS department_manager,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 0) AS avg_salary,
    SUM(e.salary) AS total_payroll,
    ROUND(AVG(pr.overall_rating), 2) AS avg_performance_rating
FROM hr_departments d
LEFT JOIN hr_employees mgr ON d.manager_id = mgr.employee_id
LEFT JOIN hr_employees e ON d.department_id = e.department_id AND e.employment_status = 'ACTIVE'
LEFT JOIN hr_performance_reviews pr ON e.employee_id = pr.employee_id
WHERE pr.review_id = (
    SELECT MAX(pr2.review_id)
    FROM hr_performance_reviews pr2
    WHERE pr2.employee_id = pr.employee_id
) OR pr.review_id IS NULL
GROUP BY d.department_name, d.location, mgr.first_name, mgr.last_name
ORDER BY employee_count DESC;

COMMENT ON VIEW V_HR_DEPARTMENT_OVERVIEW IS 'Comprehensive department statistics and metrics';

-- =============================================================================
-- AUDIT AND COMPLIANCE VIEWS
-- =============================================================================

-- Recent HR activities audit
CREATE OR REPLACE VIEW V_HR_AUDIT_TRAIL AS
SELECT 
    al.log_id,
    al.table_name,
    al.operation_type,
    al.record_id,
    al.changed_by,
    al.change_date,
    al.old_values,
    al.new_values,
    e.first_name || ' ' || e.last_name AS changed_by_name
FROM hr_audit_log al
LEFT JOIN hr_employees e ON al.changed_by = e.employee_number
WHERE al.change_date >= TRUNC(SYSDATE) - 30 -- Last 30 days
ORDER BY al.change_date DESC;

COMMENT ON VIEW V_HR_AUDIT_TRAIL IS 'Recent HR system changes for audit and compliance';

-- Employee data completeness
CREATE OR REPLACE VIEW V_HR_DATA_COMPLETENESS AS
SELECT 
    employee_id,
    full_name,
    department_name,
    CASE WHEN email IS NULL THEN 0 ELSE 1 END AS has_email,
    CASE WHEN phone_number IS NULL THEN 0 ELSE 1 END AS has_phone,
    CASE WHEN salary IS NULL THEN 0 ELSE 1 END AS has_salary,
    CASE WHEN manager_id IS NULL THEN 0 ELSE 1 END AS has_manager,
    CASE WHEN EXISTS (
        SELECT 1 FROM hr_benefit_enrollments be 
        WHERE be.employee_id = V_HR_EMPLOYEE_INFO.employee_id 
        AND (be.coverage_end_date IS NULL OR be.coverage_end_date > SYSDATE)
    ) THEN 1 ELSE 0 END AS has_benefits,
    CASE WHEN EXISTS (
        SELECT 1 FROM hr_performance_reviews pr 
        WHERE pr.employee_id = V_HR_EMPLOYEE_INFO.employee_id
    ) THEN 1 ELSE 0 END AS has_reviews
FROM V_HR_EMPLOYEE_INFO;

COMMENT ON VIEW V_HR_DATA_COMPLETENESS IS 'Employee data completeness for data quality monitoring';

-- =============================================================================
-- GRANTS AND SECURITY
-- =============================================================================

-- Grant appropriate permissions (adjust as needed for your security model)
-- Note: In a real environment, you would grant these to specific roles/users

-- Example role-based access (uncomment and modify as needed):
-- GRANT SELECT ON V_HR_EMPLOYEE_DIRECTORY TO hr_users;
-- GRANT SELECT ON V_HR_PAYROLL_SUMMARY TO hr_payroll_users;
-- GRANT SELECT ON V_HR_EXECUTIVE_DASHBOARD TO hr_managers;

PROMPT HR Views created successfully!
PROMPT =================================

-- Display summary of created views
SELECT 
    view_name,
    SUBSTR(comments, 1, 50) AS description
FROM user_tab_comments 
WHERE table_name LIKE 'V_HR_%' 
AND table_type = 'VIEW'
ORDER BY view_name;

PROMPT
PROMPT HR Management Views Summary:
PROMPT - Employee information and directory views
PROMPT - Payroll and compensation analysis
PROMPT - Benefits enrollment and costs
PROMPT - Performance review tracking
PROMPT - Training and development progress
PROMPT - Recruitment and hiring metrics
PROMPT - Executive dashboard and KPIs
PROMPT - Audit trail and compliance monitoring
PROMPT
PROMPT Total Views Created: 15+
PROMPT Views are ready for use in reporting and applications!
