
/*
===========================================
HR MANAGEMENT SYSTEM - BUSINESS LOGIC PROCEDURES
===========================================

This script creates comprehensive stored procedures and functions
for the HR Management System business logic implementation.

Procedures Include:
1. Employee Management (Hire, Terminate, Update)
2. Payroll Processing (Calculate Pay, Generate Reports)
3. Performance Management (Reviews, Goals)
4. Recruitment Management (Job Postings, Applications)
5. Training Management (Enrollments, Tracking)
6. Benefits Administration
7. Reporting Functions
8. Audit and Compliance Procedures

Prerequisites:
- hr-schema-setup.sql must be executed first
- hr-sample-data.sql recommended for testing
*/

-- ===========================================
-- 1. EMPLOYEE MANAGEMENT PROCEDURES
-- ===========================================

-- Procedure to hire a new employee
CREATE OR REPLACE PROCEDURE hire_employee (
    p_employee_number IN VARCHAR2,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_hire_date IN DATE DEFAULT SYSDATE,
    p_position_id IN NUMBER,
    p_department_id IN NUMBER,
    p_manager_id IN NUMBER DEFAULT NULL,
    p_location_id IN NUMBER DEFAULT NULL,
    p_salary IN NUMBER,
    p_employee_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_position_exists NUMBER;
    v_dept_exists NUMBER;
    v_manager_exists NUMBER;
    v_email_exists NUMBER;
    v_emp_number_exists NUMBER;
    
    -- Custom exceptions
    invalid_position EXCEPTION;
    invalid_department EXCEPTION;
    invalid_manager EXCEPTION;
    duplicate_email EXCEPTION;
    duplicate_emp_number EXCEPTION;
    
BEGIN
    -- Input validation
    IF p_employee_number IS NULL OR LENGTH(p_employee_number) < 3 THEN
        p_status := 'ERROR';
        p_message := 'Employee number is required and must be at least 3 characters';
        RETURN;
    END IF;
    
    IF p_first_name IS NULL OR p_last_name IS NULL THEN
        p_status := 'ERROR';
        p_message := 'First name and last name are required';
        RETURN;
    END IF;
    
    IF p_email IS NULL OR NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        p_status := 'ERROR';
        p_message := 'Valid email address is required';
        RETURN;
    END IF;
    
    -- Check for duplicate employee number
    SELECT COUNT(*) INTO v_emp_number_exists
    FROM employees WHERE employee_number = p_employee_number;
    
    IF v_emp_number_exists > 0 THEN
        RAISE duplicate_emp_number;
    END IF;
    
    -- Check for duplicate email
    SELECT COUNT(*) INTO v_email_exists
    FROM employees WHERE email = p_email;
    
    IF v_email_exists > 0 THEN
        RAISE duplicate_email;
    END IF;
    
    -- Validate position exists and is active
    SELECT COUNT(*) INTO v_position_exists
    FROM positions WHERE position_id = p_position_id AND is_active = 'Y';
    
    IF v_position_exists = 0 THEN
        RAISE invalid_position;
    END IF;
    
    -- Validate department exists and is active
    SELECT COUNT(*) INTO v_dept_exists
    FROM departments WHERE department_id = p_department_id AND is_active = 'Y';
    
    IF v_dept_exists = 0 THEN
        RAISE invalid_department;
    END IF;
    
    -- Validate manager exists (if provided)
    IF p_manager_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_manager_exists
        FROM employees WHERE employee_id = p_manager_id AND employment_status = 'ACTIVE';
        
        IF v_manager_exists = 0 THEN
            RAISE invalid_manager;
        END IF;
    END IF;
    
    -- Generate new employee ID
    p_employee_id := employee_seq.NEXTVAL;
    
    -- Insert new employee record
    INSERT INTO employees (
        employee_id, employee_number, first_name, last_name, email,
        hire_date, position_id, department_id, manager_id, location_id,
        salary, employment_status, employment_type,
        created_by, updated_by
    ) VALUES (
        p_employee_id, p_employee_number, p_first_name, p_last_name, p_email,
        p_hire_date, p_position_id, p_department_id, p_manager_id, p_location_id,
        p_salary, 'ACTIVE', 'FULL_TIME',
        USER, USER
    );
    
    -- Log the hiring in audit trail
    INSERT INTO audit_log (
        log_id, table_name, operation_type, record_id,
        new_value, changed_by, change_date
    ) VALUES (
        audit_log_seq.NEXTVAL, 'EMPLOYEES', 'INSERT', p_employee_id,
        'New employee hired: ' || p_first_name || ' ' || p_last_name,
        USER, SYSDATE
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Employee ' || p_first_name || ' ' || p_last_name || ' hired successfully with ID: ' || p_employee_id;
    
EXCEPTION
    WHEN duplicate_emp_number THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Employee number already exists';
    WHEN duplicate_email THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Email address already exists';
    WHEN invalid_position THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Invalid or inactive position ID';
    WHEN invalid_department THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Invalid or inactive department ID';
    WHEN invalid_manager THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Invalid or inactive manager ID';
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END hire_employee;
/

-- Procedure to terminate an employee
CREATE OR REPLACE PROCEDURE terminate_employee (
    p_employee_id IN NUMBER,
    p_termination_date IN DATE DEFAULT SYSDATE,
    p_reason IN VARCHAR2 DEFAULT NULL,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_employee_exists NUMBER;
    v_current_status VARCHAR2(15);
    v_employee_name VARCHAR2(100);
    
    employee_not_found EXCEPTION;
    already_terminated EXCEPTION;
    
BEGIN
    -- Validate employee exists and get current status
    BEGIN
        SELECT employment_status, first_name || ' ' || last_name
        INTO v_current_status, v_employee_name
        FROM employees
        WHERE employee_id = p_employee_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE employee_not_found;
    END;
    
    -- Check if already terminated
    IF v_current_status IN ('TERMINATED', 'RETIRED') THEN
        RAISE already_terminated;
    END IF;
    
    -- Update employee record
    UPDATE employees
    SET employment_status = 'TERMINATED',
        termination_date = p_termination_date,
        updated_date = SYSDATE,
        updated_by = USER
    WHERE employee_id = p_employee_id;
    
    -- Terminate active benefits
    UPDATE employee_benefits
    SET status = 'TERMINATED',
        termination_date = p_termination_date
    WHERE employee_id = p_employee_id
    AND status = 'ACTIVE';
    
    -- Cancel future training enrollments
    UPDATE training_enrollments
    SET status = 'CANCELLED'
    WHERE employee_id = p_employee_id
    AND status IN ('ENROLLED', 'IN_PROGRESS')
    AND scheduled_start_date > SYSDATE;
    
    -- Log the termination
    INSERT INTO audit_log (
        log_id, table_name, operation_type, record_id,
        field_name, old_value, new_value, changed_by, change_date
    ) VALUES (
        audit_log_seq.NEXTVAL, 'EMPLOYEES', 'UPDATE', p_employee_id,
        'TERMINATION', 'ACTIVE', 'TERMINATED - ' || NVL(p_reason, 'No reason provided'),
        USER, SYSDATE
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Employee ' || v_employee_name || ' terminated successfully on ' || TO_CHAR(p_termination_date, 'DD-MON-YYYY');
    
EXCEPTION
    WHEN employee_not_found THEN
        p_status := 'ERROR';
        p_message := 'Employee not found';
    WHEN already_terminated THEN
        p_status := 'ERROR';
        p_message := 'Employee is already terminated';
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END terminate_employee;
/

-- ===========================================
-- 2. PAYROLL PROCESSING PROCEDURES
-- ===========================================

-- Function to calculate gross pay for an employee
CREATE OR REPLACE FUNCTION calculate_gross_pay (
    p_employee_id IN NUMBER,
    p_pay_period_start IN DATE,
    p_pay_period_end IN DATE
) RETURN NUMBER AS
    v_salary NUMBER;
    v_employment_type VARCHAR2(15);
    v_days_in_period NUMBER;
    v_working_days NUMBER;
    v_gross_pay NUMBER;
    
BEGIN
    -- Get employee salary and employment type
    SELECT salary, employment_type
    INTO v_salary, v_employment_type
    FROM employees
    WHERE employee_id = p_employee_id
    AND employment_status = 'ACTIVE';
    
    -- Calculate days in pay period
    v_days_in_period := p_pay_period_end - p_pay_period_start + 1;
    
    -- Calculate based on employment type
    IF v_employment_type = 'FULL_TIME' THEN
        -- Monthly salary calculation
        v_gross_pay := v_salary / 12;
    ELSIF v_employment_type = 'PART_TIME' THEN
        -- Pro-rated based on days worked (assuming 22 working days per month)
        v_working_days := LEAST(v_days_in_period, 22);
        v_gross_pay := (v_salary / 12) * (v_working_days / 22);
    ELSE
        -- Contract or temporary - daily rate
        v_gross_pay := (v_salary / 365) * v_days_in_period;
    END IF;
    
    RETURN ROUND(v_gross_pay, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;  -- Error indicator
END calculate_gross_pay;
/

-- Procedure to process payroll for a pay period
CREATE OR REPLACE PROCEDURE process_payroll (
    p_pay_period_start IN DATE,
    p_pay_period_end IN DATE,
    p_pay_date IN DATE,
    p_payroll_run_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_run_number VARCHAR2(20);
    v_employee_count NUMBER := 0;
    v_total_gross NUMBER := 0;
    v_total_net NUMBER := 0;
    v_total_tax NUMBER := 0;
    
    -- Variables for individual employee calculations
    v_gross_pay NUMBER;
    v_federal_tax NUMBER;
    v_state_tax NUMBER;
    v_ss_tax NUMBER;
    v_medicare_tax NUMBER;
    v_health_deduction NUMBER;
    v_dental_deduction NUMBER;
    v_retirement_deduction NUMBER;
    v_total_deductions NUMBER;
    v_net_pay NUMBER;
    
    -- Cursor for active employees
    CURSOR emp_cursor IS
        SELECT employee_id, salary, employment_type
        FROM employees
        WHERE employment_status = 'ACTIVE'
        AND hire_date <= p_pay_period_end;
        
BEGIN
    -- Generate run number
    v_run_number := 'PR-' || TO_CHAR(p_pay_period_start, 'YYYY-MM');
    
    -- Create payroll run record
    p_payroll_run_id := payroll_run_seq.NEXTVAL;
    
    INSERT INTO payroll_runs (
        payroll_run_id, run_number, pay_period_start, pay_period_end,
        pay_date, run_status, created_by
    ) VALUES (
        p_payroll_run_id, v_run_number, p_pay_period_start, p_pay_period_end,
        p_pay_date, 'CALCULATED', USER
    );
    
    -- Process each employee
    FOR emp_rec IN emp_cursor LOOP
        -- Calculate gross pay
        v_gross_pay := calculate_gross_pay(emp_rec.employee_id, p_pay_period_start, p_pay_period_end);
        
        IF v_gross_pay > 0 THEN
            -- Calculate taxes (simplified rates)
            v_federal_tax := ROUND(v_gross_pay * 0.22, 2);
            v_state_tax := ROUND(v_gross_pay * 0.06, 2);
            v_ss_tax := ROUND(v_gross_pay * 0.062, 2);
            v_medicare_tax := ROUND(v_gross_pay * 0.0145, 2);
            
            -- Get benefit deductions
            SELECT 
                NVL(SUM(CASE WHEN bp.plan_type = 'HEALTH' THEN eb.employee_contribution ELSE 0 END), 0),
                NVL(SUM(CASE WHEN bp.plan_type = 'DENTAL' THEN eb.employee_contribution ELSE 0 END), 0),
                NVL(SUM(CASE WHEN bp.plan_type = 'RETIREMENT' THEN (v_gross_pay * 0.05) ELSE 0 END), 0)
            INTO v_health_deduction, v_dental_deduction, v_retirement_deduction
            FROM employee_benefits eb
            LEFT JOIN benefit_plans bp ON eb.plan_id = bp.plan_id
            WHERE eb.employee_id = emp_rec.employee_id
            AND eb.status = 'ACTIVE'
            AND p_pay_period_end BETWEEN eb.effective_date AND NVL(eb.termination_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY'));
            
            -- Calculate totals
            v_total_deductions := v_federal_tax + v_state_tax + v_ss_tax + v_medicare_tax + 
                                v_health_deduction + v_dental_deduction + v_retirement_deduction;
            v_net_pay := v_gross_pay - v_total_deductions;
            
            -- Insert payroll item
            INSERT INTO payroll_items (
                payroll_item_id, payroll_run_id, employee_id,
                regular_hours, regular_rate, gross_salary,
                federal_tax, state_tax, social_security, medicare,
                health_insurance, dental_insurance, retirement_401k,
                total_gross, total_deductions, net_pay, status
            ) VALUES (
                payroll_item_seq.NEXTVAL, p_payroll_run_id, emp_rec.employee_id,
                160, ROUND(v_gross_pay / 160, 2), v_gross_pay,
                v_federal_tax, v_state_tax, v_ss_tax, v_medicare_tax,
                v_health_deduction, v_dental_deduction, v_retirement_deduction,
                v_gross_pay, v_total_deductions, v_net_pay, 'CALCULATED'
            );
            
            -- Update running totals
            v_employee_count := v_employee_count + 1;
            v_total_gross := v_total_gross + v_gross_pay;
            v_total_net := v_total_net + v_net_pay;
            v_total_tax := v_total_tax + v_federal_tax + v_state_tax + v_ss_tax + v_medicare_tax;
        END IF;
    END LOOP;
    
    -- Update payroll run totals
    UPDATE payroll_runs
    SET total_gross_amount = v_total_gross,
        total_net_amount = v_total_net,
        total_tax_amount = v_total_tax,
        employee_count = v_employee_count
    WHERE payroll_run_id = p_payroll_run_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Payroll processed successfully. Run ID: ' || p_payroll_run_id || 
                ', Employees: ' || v_employee_count || 
                ', Total Gross: $' || ROUND(v_total_gross, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Payroll processing failed: ' || SQLERRM;
END process_payroll;
/

-- ===========================================
-- 3. PERFORMANCE MANAGEMENT PROCEDURES
-- ===========================================

-- Procedure to create performance review
CREATE OR REPLACE PROCEDURE create_performance_review (
    p_employee_id IN NUMBER,
    p_review_period_start IN DATE,
    p_review_period_end IN DATE,
    p_review_type IN VARCHAR2 DEFAULT 'ANNUAL',
    p_reviewer_id IN NUMBER,
    p_review_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_employee_exists NUMBER;
    v_reviewer_exists NUMBER;
    v_existing_review NUMBER;
    
    employee_not_found EXCEPTION;
    reviewer_not_found EXCEPTION;
    review_exists EXCEPTION;
    
BEGIN
    -- Validate employee exists
    SELECT COUNT(*) INTO v_employee_exists
    FROM employees WHERE employee_id = p_employee_id AND employment_status = 'ACTIVE';
    
    IF v_employee_exists = 0 THEN
        RAISE employee_not_found;
    END IF;
    
    -- Validate reviewer exists
    SELECT COUNT(*) INTO v_reviewer_exists
    FROM employees WHERE employee_id = p_reviewer_id AND employment_status = 'ACTIVE';
    
    IF v_reviewer_exists = 0 THEN
        RAISE reviewer_not_found;
    END IF;
    
    -- Check for existing review in the same period
    SELECT COUNT(*) INTO v_existing_review
    FROM performance_reviews
    WHERE employee_id = p_employee_id
    AND review_period_start = p_review_period_start
    AND review_period_end = p_review_period_end;
    
    IF v_existing_review > 0 THEN
        RAISE review_exists;
    END IF;
    
    -- Create performance review
    p_review_id := performance_review_seq.NEXTVAL;
    
    INSERT INTO performance_reviews (
        review_id, employee_id, review_period_start, review_period_end,
        review_type, reviewer_id, status
    ) VALUES (
        p_review_id, p_employee_id, p_review_period_start, p_review_period_end,
        p_review_type, p_reviewer_id, 'DRAFT'
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Performance review created successfully with ID: ' || p_review_id;
    
EXCEPTION
    WHEN employee_not_found THEN
        p_status := 'ERROR';
        p_message := 'Employee not found or inactive';
    WHEN reviewer_not_found THEN
        p_status := 'ERROR';
        p_message := 'Reviewer not found or inactive';
    WHEN review_exists THEN
        p_status := 'ERROR';
        p_message := 'Performance review already exists for this period';
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END create_performance_review;
/

-- ===========================================
-- 4. RECRUITMENT MANAGEMENT PROCEDURES
-- ===========================================

-- Procedure to create job posting
CREATE OR REPLACE PROCEDURE create_job_posting (
    p_position_id IN NUMBER,
    p_title IN VARCHAR2,
    p_description IN CLOB,
    p_location_id IN NUMBER DEFAULT NULL,
    p_salary_min IN NUMBER DEFAULT NULL,
    p_salary_max IN NUMBER DEFAULT NULL,
    p_application_deadline IN DATE,
    p_hiring_manager_id IN NUMBER,
    p_hr_contact_id IN NUMBER,
    p_posting_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_posting_number VARCHAR2(20);
    v_position_exists NUMBER;
    v_manager_exists NUMBER;
    v_hr_exists NUMBER;
    
    invalid_position EXCEPTION;
    invalid_manager EXCEPTION;
    invalid_hr_contact EXCEPTION;
    
BEGIN
    -- Validate position exists
    SELECT COUNT(*) INTO v_position_exists
    FROM positions WHERE position_id = p_position_id AND is_active = 'Y';
    
    IF v_position_exists = 0 THEN
        RAISE invalid_position;
    END IF;
    
    -- Validate hiring manager
    SELECT COUNT(*) INTO v_manager_exists
    FROM employees WHERE employee_id = p_hiring_manager_id AND employment_status = 'ACTIVE';
    
    IF v_manager_exists = 0 THEN
        RAISE invalid_manager;
    END IF;
    
    -- Validate HR contact
    SELECT COUNT(*) INTO v_hr_exists
    FROM employees WHERE employee_id = p_hr_contact_id AND employment_status = 'ACTIVE';
    
    IF v_hr_exists = 0 THEN
        RAISE invalid_hr_contact;
    END IF;
    
    -- Generate posting number
    p_posting_id := job_posting_seq.NEXTVAL;
    v_posting_number := 'JP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(p_posting_id, 3, '0');
    
    -- Create job posting
    INSERT INTO job_postings (
        posting_id, posting_number, position_id, title, description,
        location_id, salary_min, salary_max, application_deadline,
        hiring_manager_id, hr_contact_id, status
    ) VALUES (
        p_posting_id, v_posting_number, p_position_id, p_title, p_description,
        p_location_id, p_salary_min, p_salary_max, p_application_deadline,
        p_hiring_manager_id, p_hr_contact_id, 'DRAFT'
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Job posting created successfully with ID: ' || p_posting_id || ' and number: ' || v_posting_number;
    
EXCEPTION
    WHEN invalid_position THEN
        p_status := 'ERROR';
        p_message := 'Invalid or inactive position';
    WHEN invalid_manager THEN
        p_status := 'ERROR';
        p_message := 'Invalid or inactive hiring manager';
    WHEN invalid_hr_contact THEN
        p_status := 'ERROR';
        p_message := 'Invalid or inactive HR contact';
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END create_job_posting;
/

-- ===========================================
-- 5. TRAINING MANAGEMENT PROCEDURES
-- ===========================================

-- Procedure to enroll employee in training
CREATE OR REPLACE PROCEDURE enroll_in_training (
    p_employee_id IN NUMBER,
    p_program_id IN NUMBER,
    p_scheduled_start_date IN DATE DEFAULT NULL,
    p_approved_by IN NUMBER DEFAULT NULL,
    p_enrollment_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_employee_exists NUMBER;
    v_program_exists NUMBER;
    v_program_active NUMBER;
    v_already_enrolled NUMBER;
    v_program_capacity NUMBER;
    v_current_enrollment NUMBER;
    v_cost NUMBER;
    
    employee_not_found EXCEPTION;
    program_not_found EXCEPTION;
    program_inactive EXCEPTION;
    already_enrolled EXCEPTION;
    program_full EXCEPTION;
    
BEGIN
    -- Validate employee
    SELECT COUNT(*) INTO v_employee_exists
    FROM employees WHERE employee_id = p_employee_id AND employment_status = 'ACTIVE';
    
    IF v_employee_exists = 0 THEN
        RAISE employee_not_found;
    END IF;
    
    -- Validate training program
    SELECT COUNT(*), MAX(capacity), MAX(cost_per_person), MAX(CASE WHEN is_active = 'Y' THEN 1 ELSE 0 END)
    INTO v_program_exists, v_program_capacity, v_cost, v_program_active
    FROM training_programs WHERE program_id = p_program_id
    GROUP BY program_id;
    
    IF v_program_exists = 0 THEN
        RAISE program_not_found;
    END IF;
    
    IF v_program_active = 0 THEN
        RAISE program_inactive;
    END IF;
    
    -- Check if already enrolled
    SELECT COUNT(*) INTO v_already_enrolled
    FROM training_enrollments
    WHERE employee_id = p_employee_id
    AND program_id = p_program_id
    AND status IN ('ENROLLED', 'IN_PROGRESS');
    
    IF v_already_enrolled > 0 THEN
        RAISE already_enrolled;
    END IF;
    
    -- Check program capacity
    IF v_program_capacity IS NOT NULL THEN
        SELECT COUNT(*) INTO v_current_enrollment
        FROM training_enrollments
        WHERE program_id = p_program_id
        AND status IN ('ENROLLED', 'IN_PROGRESS');
        
        IF v_current_enrollment >= v_program_capacity THEN
            RAISE program_full;
        END IF;
    END IF;
    
    -- Create enrollment
    p_enrollment_id := training_enrollment_seq.NEXTVAL;
    
    INSERT INTO training_enrollments (
        enrollment_id, program_id, employee_id, enrollment_date,
        scheduled_start_date, cost, approved_by, status
    ) VALUES (
        p_enrollment_id, p_program_id, p_employee_id, SYSDATE,
        p_scheduled_start_date, v_cost, p_approved_by, 'ENROLLED'
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Employee enrolled in training successfully. Enrollment ID: ' || p_enrollment_id;
    
EXCEPTION
    WHEN employee_not_found THEN
        p_status := 'ERROR';
        p_message := 'Employee not found or inactive';
    WHEN program_not_found THEN
        p_status := 'ERROR';
        p_message := 'Training program not found';
    WHEN program_inactive THEN
        p_status := 'ERROR';
        p_message := 'Training program is inactive';
    WHEN already_enrolled THEN
        p_status := 'ERROR';
        p_message := 'Employee is already enrolled in this program';
    WHEN program_full THEN
        p_status := 'ERROR';
        p_message := 'Training program is at capacity';
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END enroll_in_training;
/

-- ===========================================
-- 6. REPORTING FUNCTIONS
-- ===========================================

-- Function to get employee count by department
CREATE OR REPLACE FUNCTION get_dept_employee_count (
    p_department_id IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR;
BEGIN
    IF p_department_id IS NOT NULL THEN
        OPEN v_cursor FOR
            SELECT 
                d.department_name,
                COUNT(e.employee_id) as employee_count,
                COUNT(CASE WHEN e.employment_status = 'ACTIVE' THEN 1 END) as active_count,
                AVG(e.salary) as avg_salary,
                MIN(e.hire_date) as earliest_hire_date,
                MAX(e.hire_date) as latest_hire_date
            FROM departments d
            LEFT JOIN employees e ON d.department_id = e.department_id
            WHERE d.department_id = p_department_id
            GROUP BY d.department_id, d.department_name;
    ELSE
        OPEN v_cursor FOR
            SELECT 
                d.department_name,
                COUNT(e.employee_id) as employee_count,
                COUNT(CASE WHEN e.employment_status = 'ACTIVE' THEN 1 END) as active_count,
                ROUND(AVG(e.salary), 2) as avg_salary,
                MIN(e.hire_date) as earliest_hire_date,
                MAX(e.hire_date) as latest_hire_date
            FROM departments d
            LEFT JOIN employees e ON d.department_id = e.department_id
            GROUP BY d.department_id, d.department_name
            ORDER BY d.department_name;
    END IF;
    
    RETURN v_cursor;
END get_dept_employee_count;
/

-- Function to calculate employee tenure
CREATE OR REPLACE FUNCTION calculate_tenure (
    p_hire_date IN DATE,
    p_termination_date IN DATE DEFAULT NULL
) RETURN VARCHAR2 AS
    v_end_date DATE;
    v_years NUMBER;
    v_months NUMBER;
    v_days NUMBER;
    v_result VARCHAR2(100);
BEGIN
    v_end_date := NVL(p_termination_date, SYSDATE);
    
    v_years := FLOOR(MONTHS_BETWEEN(v_end_date, p_hire_date) / 12);
    v_months := FLOOR(MOD(MONTHS_BETWEEN(v_end_date, p_hire_date), 12));
    v_days := FLOOR(v_end_date - ADD_MONTHS(p_hire_date, v_years * 12 + v_months));
    
    v_result := v_years || ' years';
    IF v_months > 0 THEN
        v_result := v_result || ', ' || v_months || ' months';
    END IF;
    IF v_days > 0 AND v_years = 0 AND v_months = 0 THEN
        v_result := v_days || ' days';
    END IF;
    
    RETURN v_result;
END calculate_tenure;
/

-- ===========================================
-- 7. AUDIT TRIGGER PROCEDURE
-- ===========================================

-- Generic audit procedure for employee changes
CREATE OR REPLACE PROCEDURE audit_employee_change (
    p_employee_id IN NUMBER,
    p_field_name IN VARCHAR2,
    p_old_value IN VARCHAR2,
    p_new_value IN VARCHAR2
) AS
BEGIN
    INSERT INTO audit_log (
        log_id, table_name, operation_type, record_id,
        field_name, old_value, new_value, changed_by, change_date
    ) VALUES (
        audit_log_seq.NEXTVAL, 'EMPLOYEES', 'UPDATE', p_employee_id,
        p_field_name, p_old_value, p_new_value, USER, SYSDATE
    );
END audit_employee_change;
/

-- ===========================================
-- 8. UTILITY PROCEDURES
-- ===========================================

-- Procedure to update employee salary with approval workflow
CREATE OR REPLACE PROCEDURE update_employee_salary (
    p_employee_id IN NUMBER,
    p_new_salary IN NUMBER,
    p_effective_date IN DATE DEFAULT SYSDATE,
    p_reason IN VARCHAR2 DEFAULT NULL,
    p_approved_by IN NUMBER DEFAULT NULL,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) AS
    v_employee_exists NUMBER;
    v_current_salary NUMBER;
    v_position_min NUMBER;
    v_position_max NUMBER;
    v_employee_name VARCHAR2(100);
    
    employee_not_found EXCEPTION;
    salary_out_of_range EXCEPTION;
    
BEGIN
    -- Validate employee and get current salary
    BEGIN
        SELECT salary, first_name || ' ' || last_name
        INTO v_current_salary, v_employee_name
        FROM employees
        WHERE employee_id = p_employee_id
        AND employment_status = 'ACTIVE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE employee_not_found;
    END;
    
    -- Get position salary range
    SELECT p.min_salary, p.max_salary
    INTO v_position_min, v_position_max
    FROM employees e
    JOIN positions p ON e.position_id = p.position_id
    WHERE e.employee_id = p_employee_id;
    
    -- Validate salary is within position range
    IF p_new_salary < v_position_min OR p_new_salary > v_position_max THEN
        RAISE salary_out_of_range;
    END IF;
    
    -- Update employee salary
    UPDATE employees
    SET salary = p_new_salary,
        updated_date = SYSDATE,
        updated_by = USER
    WHERE employee_id = p_employee_id;
    
    -- Log the salary change
    CALL audit_employee_change(
        p_employee_id, 'SALARY',
        TO_CHAR(v_current_salary), TO_CHAR(p_new_salary)
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Salary updated for ' || v_employee_name || 
                ' from $' || v_current_salary || ' to $' || p_new_salary ||
                ' effective ' || TO_CHAR(p_effective_date, 'DD-MON-YYYY');
    
EXCEPTION
    WHEN employee_not_found THEN
        p_status := 'ERROR';
        p_message := 'Employee not found or inactive';
    WHEN salary_out_of_range THEN
        p_status := 'ERROR';
        p_message := 'Salary must be between $' || v_position_min || ' and $' || v_position_max;
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
END update_employee_salary;
/

-- ===========================================
-- 9. SUCCESS MESSAGE
-- ===========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('HR MANAGEMENT PROCEDURES CREATED SUCCESSFULLY');
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Procedures Created:');
    DBMS_OUTPUT.PUT_LINE('1. hire_employee - Hire new employees with validation');
    DBMS_OUTPUT.PUT_LINE('2. terminate_employee - Terminate employees and cleanup');
    DBMS_OUTPUT.PUT_LINE('3. process_payroll - Calculate and process payroll');
    DBMS_OUTPUT.PUT_LINE('4. create_performance_review - Create performance reviews');
    DBMS_OUTPUT.PUT_LINE('5. create_job_posting - Create job postings');
    DBMS_OUTPUT.PUT_LINE('6. enroll_in_training - Enroll employees in training');
    DBMS_OUTPUT.PUT_LINE('7. update_employee_salary - Update salaries with validation');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Functions Created:');
    DBMS_OUTPUT.PUT_LINE('1. calculate_gross_pay - Calculate employee gross pay');
    DBMS_OUTPUT.PUT_LINE('2. get_dept_employee_count - Department reporting');
    DBMS_OUTPUT.PUT_LINE('3. calculate_tenure - Employee tenure calculation');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Utility Procedures:');
    DBMS_OUTPUT.PUT_LINE('1. audit_employee_change - Audit trail management');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next Steps:');
    DBMS_OUTPUT.PUT_LINE('1. Run hr-views.sql to create reporting views');
    DBMS_OUTPUT.PUT_LINE('2. Test procedures with sample data');
    DBMS_OUTPUT.PUT_LINE('3. Review hr-management-project.md for usage examples');
END;
/
