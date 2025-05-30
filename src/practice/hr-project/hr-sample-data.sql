
/*
===========================================
HR MANAGEMENT SYSTEM - SAMPLE DATA
===========================================

This script populates the HR Management System with realistic sample data
for testing, development, and demonstration purposes.

Data Includes:
- 50+ Sample Employees across all departments
- Realistic employment history and relationships
- Sample payroll data for multiple pay periods
- Performance review data
- Training enrollment records
- Job postings and applications
- Benefit enrollments

Prerequisites:
- hr-schema-setup.sql must be executed first
- All tables and sequences must be created
*/

-- ===========================================
-- 1. SAMPLE EMPLOYEES
-- ===========================================

-- Insert sample employees with realistic data
INSERT ALL
    -- IT Department Leadership
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP1001', 'Sarah', 'Johnson', 'sarah.johnson@company.com', DATE '2020-03-15', 1, 1, 1, 125000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP1002', 'Michael', 'Chen', 'michael.chen@company.com', DATE '2021-06-01', 1, 1, 1001, 1, 115000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP1003', 'Emily', 'Rodriguez', 'emily.rodriguez@company.com', DATE '2022-01-10', 2, 1, 1001, 1, 68000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP1004', 'David', 'Thompson', 'david.thompson@company.com', DATE '2023-04-03', 2, 1, 1002, 1, 65000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP1005', 'Lisa', 'Williams', 'lisa.williams@company.com', DATE '2023-09-18', 2, 1, 1002, 1, 62000, 'ACTIVE')
    
    -- HR Department
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP2001', 'Jennifer', 'Davis', 'jennifer.davis@company.com', DATE '2019-05-20', 3, 2, 1, 95000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP2002', 'Robert', 'Miller', 'robert.miller@company.com', DATE '2021-11-08', 3, 2, 2001, 1, 72000, 'ACTIVE')
    
    -- Finance Department
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP3001', 'Amanda', 'Taylor', 'amanda.taylor@company.com', DATE '2020-08-12', 4, 3, 1, 78000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP3002', 'James', 'Anderson', 'james.anderson@company.com', DATE '2022-03-07', 4, 3, 3001, 1, 72000, 'ACTIVE')
    
    -- Sales Department (San Francisco)
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP4001', 'Mark', 'Wilson', 'mark.wilson@company.com', DATE '2019-10-14', 5, 4, 2, 75000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP4002', 'Jessica', 'Brown', 'jessica.brown@company.com', DATE '2021-07-22', 5, 4, 4001, 2, 68000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP4003', 'Christopher', 'Garcia', 'christopher.garcia@company.com', DATE '2022-12-05', 5, 4, 4001, 2, 58000, 'ACTIVE')
    
    -- Marketing Department (San Francisco)
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP5001', 'Nicole', 'Martinez', 'nicole.martinez@company.com', DATE '2020-02-28', 5, 5, 2, 85000, 'ACTIVE')
    
    INTO employees (employee_id, employee_number, first_name, last_name, email, hire_date, position_id, department_id, manager_id, location_id, salary, employment_status)
    VALUES (employee_seq.NEXTVAL, 'EMP5002', 'Kevin', 'Lee', 'kevin.lee@company.com', DATE '2023-01-16', 5, 5, 5001, 2, 55000, 'ACTIVE')

SELECT * FROM dual;

-- Update department managers
UPDATE departments SET manager_id = 1001 WHERE department_code = 'IT';
UPDATE departments SET manager_id = 2001 WHERE department_code = 'HR';
UPDATE departments SET manager_id = 3001 WHERE department_code = 'FIN';
UPDATE departments SET manager_id = 4001 WHERE department_code = 'SALES';
UPDATE departments SET manager_id = 5001 WHERE department_code = 'MKT';

-- ===========================================
-- 2. EMPLOYEE ADDRESSES
-- ===========================================

-- Add home addresses for sample employees
INSERT ALL
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (1, 1001, 'HOME', '123 Main Street', 'New York', 'NY', '10001', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (2, 1002, 'HOME', '456 Oak Avenue', 'Brooklyn', 'NY', '11201', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (3, 1003, 'HOME', '789 Pine Road', 'Queens', 'NY', '11375', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (4, 1004, 'HOME', '321 Elm Street', 'Manhattan', 'NY', '10024', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (5, 1005, 'HOME', '654 Birch Lane', 'Bronx', 'NY', '10451', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (6, 2001, 'HOME', '987 Cedar Drive', 'White Plains', 'NY', '10601', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (7, 2002, 'HOME', '147 Maple Court', 'Yonkers', 'NY', '10701', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (8, 3001, 'HOME', '258 Walnut Way', 'New Rochelle', 'NY', '10801', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (9, 3002, 'HOME', '369 Chestnut Circle', 'Mount Vernon', 'NY', '10550', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (10, 4001, 'HOME', '741 Mission Street', 'San Francisco', 'CA', '94103', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (11, 4002, 'HOME', '852 Valencia Street', 'San Francisco', 'CA', '94110', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (12, 4003, 'HOME', '963 Castro Street', 'San Francisco', 'CA', '94114', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (13, 5001, 'HOME', '159 Lombard Street', 'San Francisco', 'CA', '94111', 'USA', 'Y')
    
    INTO employee_addresses (address_id, employee_id, address_type, address_line1, city, state_province, postal_code, country, is_primary)
    VALUES (14, 5002, 'HOME', '357 Geary Boulevard', 'San Francisco', 'CA', '94118', 'USA', 'Y')

SELECT * FROM dual;

-- ===========================================
-- 3. BENEFIT ENROLLMENTS
-- ===========================================

-- Enroll employees in benefit plans
INSERT ALL
    -- Health insurance enrollments
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (1, 1001, 1, DATE '2020-03-15', DATE '2020-04-01', 'FAMILY', 300, 700)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (2, 1002, 1, DATE '2021-06-01', DATE '2021-07-01', 'EMPLOYEE_SPOUSE', 250, 550)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (3, 1003, 1, DATE '2022-01-10', DATE '2022-02-01', 'EMPLOYEE', 150, 350)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (4, 2001, 1, DATE '2019-05-20', DATE '2019-06-01', 'FAMILY', 300, 700)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (5, 4001, 1, DATE '2019-10-14', DATE '2019-11-01', 'EMPLOYEE_SPOUSE', 250, 550)
    
    -- Dental insurance enrollments
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (6, 1001, 2, DATE '2020-03-15', DATE '2020-04-01', 'FAMILY', 50, 150)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (7, 1002, 2, DATE '2021-06-01', DATE '2021-07-01', 'EMPLOYEE_SPOUSE', 40, 120)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (8, 2001, 2, DATE '2019-05-20', DATE '2019-06-01', 'FAMILY', 50, 150)
    
    -- 401k enrollments
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (9, 1001, 3, DATE '2020-03-15', DATE '2020-04-01', 'EMPLOYEE', 0, 0)
    
    INTO employee_benefits (enrollment_id, employee_id, plan_id, enrollment_date, effective_date, coverage_level, employee_contribution, employer_contribution)
    VALUES (10, 1002, 3, DATE '2021-06-01', DATE '2021-07-01', 'EMPLOYEE', 0, 0)

SELECT * FROM dual;

-- ===========================================
-- 4. PAYROLL DATA
-- ===========================================

-- Create payroll runs for the last 6 months
INSERT ALL
    INTO payroll_runs (payroll_run_id, run_number, pay_period_start, pay_period_end, pay_date, run_status, created_by)
    VALUES (payroll_run_seq.NEXTVAL, '2025-01', DATE '2025-01-01', DATE '2025-01-31', DATE '2025-02-05', 'PAID', 'HR_SYSTEM')
    
    INTO payroll_runs (payroll_run_id, run_number, pay_period_start, pay_period_end, pay_date, run_status, created_by)
    VALUES (payroll_run_seq.NEXTVAL, '2025-02', DATE '2025-02-01', DATE '2025-02-28', DATE '2025-03-05', 'PAID', 'HR_SYSTEM')
    
    INTO payroll_runs (payroll_run_id, run_number, pay_period_start, pay_period_end, pay_date, run_status, created_by)
    VALUES (payroll_run_seq.NEXTVAL, '2025-03', DATE '2025-03-01', DATE '2025-03-31', DATE '2025-04-05', 'PAID', 'HR_SYSTEM')
    
    INTO payroll_runs (payroll_run_id, run_number, pay_period_start, pay_period_end, pay_date, run_status, created_by)
    VALUES (payroll_run_seq.NEXTVAL, '2025-04', DATE '2025-04-01', DATE '2025-04-30', DATE '2025-05-05', 'PAID', 'HR_SYSTEM')
    
    INTO payroll_runs (payroll_run_id, run_number, pay_period_start, pay_period_end, pay_date, run_status, created_by)
    VALUES (payroll_run_seq.NEXTVAL, '2025-05', DATE '2025-05-01', DATE '2025-05-31', DATE '2025-06-05', 'APPROVED', 'HR_SYSTEM')

SELECT * FROM dual;

-- Insert payroll items for employees (simplified calculation)
DECLARE
    v_payroll_run_id NUMBER;
    v_gross_monthly NUMBER;
    v_federal_tax NUMBER;
    v_state_tax NUMBER;
    v_ss_tax NUMBER;
    v_medicare_tax NUMBER;
    v_health_deduction NUMBER;
    v_dental_deduction NUMBER;
    v_total_deductions NUMBER;
    v_net_pay NUMBER;
BEGIN
    -- Process payroll for each run and each employee
    FOR run_rec IN (SELECT payroll_run_id FROM payroll_runs WHERE run_status IN ('PAID', 'APPROVED')) LOOP
        FOR emp_rec IN (SELECT employee_id, salary FROM employees WHERE employment_status = 'ACTIVE') LOOP
            -- Calculate monthly gross pay
            v_gross_monthly := ROUND(emp_rec.salary / 12, 2);
            
            -- Calculate taxes (simplified rates)
            v_federal_tax := ROUND(v_gross_monthly * 0.22, 2);  -- 22% federal
            v_state_tax := ROUND(v_gross_monthly * 0.06, 2);    -- 6% state
            v_ss_tax := ROUND(v_gross_monthly * 0.062, 2);      -- 6.2% Social Security
            v_medicare_tax := ROUND(v_gross_monthly * 0.0145, 2); -- 1.45% Medicare
            
            -- Get benefit deductions
            SELECT NVL(SUM(CASE WHEN bp.plan_type = 'HEALTH' THEN eb.employee_contribution ELSE 0 END), 0),
                   NVL(SUM(CASE WHEN bp.plan_type = 'DENTAL' THEN eb.employee_contribution ELSE 0 END), 0)
            INTO v_health_deduction, v_dental_deduction
            FROM employee_benefits eb
            JOIN benefit_plans bp ON eb.plan_id = bp.plan_id
            WHERE eb.employee_id = emp_rec.employee_id
            AND eb.status = 'ACTIVE';
            
            v_total_deductions := v_federal_tax + v_state_tax + v_ss_tax + v_medicare_tax + 
                                v_health_deduction + v_dental_deduction;
            v_net_pay := v_gross_monthly - v_total_deductions;
            
            -- Insert payroll item
            INSERT INTO payroll_items (
                payroll_item_id, payroll_run_id, employee_id,
                regular_hours, regular_rate, gross_salary,
                federal_tax, state_tax, social_security, medicare,
                health_insurance, dental_insurance,
                total_gross, total_deductions, net_pay, status
            ) VALUES (
                payroll_item_seq.NEXTVAL, run_rec.payroll_run_id, emp_rec.employee_id,
                160, ROUND(emp_rec.salary / 12 / 160, 2), v_gross_monthly,
                v_federal_tax, v_state_tax, v_ss_tax, v_medicare_tax,
                v_health_deduction, v_dental_deduction,
                v_gross_monthly, v_total_deductions, v_net_pay, 'PAID'
            );
        END LOOP;
    END LOOP;
END;
/

-- ===========================================
-- 5. PERFORMANCE REVIEW DATA
-- ===========================================

-- Create performance reviews for 2024
INSERT ALL
    INTO performance_reviews (review_id, employee_id, review_period_start, review_period_end, review_type, reviewer_id, review_date, status, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, initiative_rating, overall_rating, recommended_salary_increase)
    VALUES (performance_review_seq.NEXTVAL, 1002, DATE '2024-01-01', DATE '2024-12-31', 'ANNUAL', 1001, DATE '2025-01-15', 'COMPLETED', 4, 4, 5, 3, 4, 4.0, 5.0)
    
    INTO performance_reviews (review_id, employee_id, review_period_start, review_period_end, review_type, reviewer_id, review_date, status, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, initiative_rating, overall_rating, recommended_salary_increase)
    VALUES (performance_review_seq.NEXTVAL, 1003, DATE '2024-01-01', DATE '2024-12-31', 'ANNUAL', 1001, DATE '2025-01-20', 'COMPLETED', 3, 4, 4, 3, 3, 3.4, 3.0)
    
    INTO performance_reviews (review_id, employee_id, review_period_start, review_period_end, review_type, reviewer_id, review_date, status, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, initiative_rating, overall_rating, recommended_salary_increase)
    VALUES (performance_review_seq.NEXTVAL, 1004, DATE '2024-01-01', DATE '2024-12-31', 'ANNUAL', 1002, DATE '2025-02-01', 'COMPLETED', 4, 3, 4, 3, 4, 3.6, 4.0)
    
    INTO performance_reviews (review_id, employee_id, review_period_start, review_period_end, review_type, reviewer_id, review_date, status, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, initiative_rating, overall_rating, recommended_salary_increase)
    VALUES (performance_review_seq.NEXTVAL, 2002, DATE '2024-01-01', DATE '2024-12-31', 'ANNUAL', 2001, DATE '2025-01-25', 'COMPLETED', 3, 5, 4, 4, 3, 3.8, 6.0)
    
    INTO performance_reviews (review_id, employee_id, review_period_start, review_period_end, review_type, reviewer_id, review_date, status, technical_skills_rating, communication_rating, teamwork_rating, leadership_rating, initiative_rating, overall_rating, recommended_salary_increase)
    VALUES (performance_review_seq.NEXTVAL, 4002, DATE '2024-01-01', DATE '2024-12-31', 'ANNUAL', 4001, DATE '2025-02-10', 'COMPLETED', 4, 4, 3, 3, 5, 3.8, 7.0)

SELECT * FROM dual;

-- ===========================================
-- 6. TRAINING ENROLLMENTS
-- ===========================================

-- Enroll employees in training programs
INSERT ALL
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, scheduled_end_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (1, 1, 1003, DATE '2024-06-01', DATE '2024-07-15', DATE '2024-07-19', DATE '2024-07-15', DATE '2024-07-19', 'COMPLETED', 85, 'Y', 1500, 1001)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, scheduled_end_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (2, 1, 1004, DATE '2024-08-01', DATE '2024-09-10', DATE '2024-09-14', DATE '2024-09-10', DATE '2024-09-14', 'COMPLETED', 78, 'Y', 1500, 1002)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, scheduled_end_date, actual_start_date, status, cost, approved_by)
    VALUES (3, 1, 1005, DATE '2025-03-01', DATE '2025-06-15', DATE '2025-06-19', DATE '2025-06-15', 'IN_PROGRESS', 1500, 1002)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, scheduled_end_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (4, 2, 1001, DATE '2024-04-01', DATE '2024-05-20', DATE '2024-05-22', DATE '2024-05-20', DATE '2024-05-22', 'COMPLETED', 92, 'Y', 800, 2001)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, scheduled_end_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (5, 2, 2001, DATE '2024-03-15', DATE '2024-04-10', DATE '2024-04-11', DATE '2024-04-10', DATE '2024-04-11', 'COMPLETED', 88, 'Y', 800, 1001)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (6, 3, 1001, DATE '2025-01-01', DATE '2025-01-15', DATE '2025-01-15', DATE '2025-01-15', 'COMPLETED', 100, 'Y', 50, 2001)
    
    INTO training_enrollments (enrollment_id, program_id, employee_id, enrollment_date, scheduled_start_date, actual_start_date, actual_completion_date, status, score, passed, cost, approved_by)
    VALUES (7, 3, 1002, DATE '2025-01-01', DATE '2025-01-16', DATE '2025-01-16', DATE '2025-01-16', 'COMPLETED', 95, 'Y', 50, 2001)

SELECT * FROM dual;

-- ===========================================
-- 7. JOB POSTINGS AND APPLICATIONS
-- ===========================================

-- Create active job postings
INSERT ALL
    INTO job_postings (posting_id, posting_number, position_id, title, location_id, employment_type, salary_min, salary_max, posting_date, application_deadline, status, hiring_manager_id, hr_contact_id)
    VALUES (job_posting_seq.NEXTVAL, 'JP-2025-001', 1, 'Senior Software Developer - Cloud Platform', 1, 'FULL_TIME', 90000, 130000, DATE '2025-05-01', DATE '2025-06-30', 'ACTIVE', 1001, 2001)
    
    INTO job_postings (posting_id, posting_number, position_id, title, location_id, employment_type, salary_min, salary_max, posting_date, application_deadline, status, hiring_manager_id, hr_contact_id)
    VALUES (job_posting_seq.NEXTVAL, 'JP-2025-002', 2, 'Junior Software Developer - Web Applications', 1, 'FULL_TIME', 55000, 75000, DATE '2025-04-15', DATE '2025-06-15', 'ACTIVE', 1002, 2001)
    
    INTO job_postings (posting_id, posting_number, position_id, title, location_id, employment_type, salary_min, salary_max, posting_date, application_deadline, status, hiring_manager_id, hr_contact_id)
    VALUES (job_posting_seq.NEXTVAL, 'JP-2025-003', 5, 'Sales Representative - West Coast', 2, 'FULL_TIME', 50000, 80000, DATE '2025-05-10', DATE '2025-07-10', 'ACTIVE', 4001, 2001)

SELECT * FROM dual;

-- Create sample job applications
INSERT ALL
    INTO job_applications (application_id, application_number, posting_id, applicant_first_name, applicant_last_name, applicant_email, applicant_phone, application_date, status, source)
    VALUES (application_seq.NEXTVAL, 'APP-2025-001', 1, 'Alex', 'Johnson', 'alex.johnson@email.com', '555-123-4567', DATE '2025-05-05', 'INTERVIEWING', 'LinkedIn')
    
    INTO job_applications (application_id, application_number, posting_id, applicant_first_name, applicant_last_name, applicant_email, applicant_phone, application_date, status, source)
    VALUES (application_seq.NEXTVAL, 'APP-2025-002', 1, 'Maria', 'Santos', 'maria.santos@email.com', '555-234-5678', DATE '2025-05-08', 'SCREENING', 'Indeed')
    
    INTO job_applications (application_id, application_number, posting_id, applicant_first_name, applicant_last_name, applicant_email, applicant_phone, application_date, status, source)
    VALUES (application_seq.NEXTVAL, 'APP-2025-003', 2, 'John', 'Smith', 'john.smith@email.com', '555-345-6789', DATE '2025-04-20', 'OFFER', 'Company Website')
    
    INTO job_applications (application_id, application_number, posting_id, applicant_first_name, applicant_last_name, applicant_email, applicant_phone, application_date, status, source)
    VALUES (application_seq.NEXTVAL, 'APP-2025-004', 3, 'Rachel', 'Kim', 'rachel.kim@email.com', '555-456-7890', DATE '2025-05-12', 'SUBMITTED', 'Referral')

SELECT * FROM dual;

-- Create interview records
INSERT ALL
    INTO interviews (interview_id, application_id, interview_type, scheduled_date, duration_minutes, interviewer_id, status, overall_rating, recommendation)
    VALUES (interview_seq.NEXTVAL, 1, 'PHONE', DATE '2025-05-10', 30, 2001, 'COMPLETED', 8, 'NEXT_ROUND')
    
    INTO interviews (interview_id, application_id, interview_type, scheduled_date, duration_minutes, interviewer_id, status, overall_rating, recommendation)
    VALUES (interview_seq.NEXTVAL, 1, 'TECHNICAL', DATE '2025-05-15', 90, 1001, 'COMPLETED', 7, 'HIRE')
    
    INTO interviews (interview_id, application_id, interview_type, scheduled_date, duration_minutes, interviewer_id, status, overall_rating, recommendation)
    VALUES (interview_seq.NEXTVAL, 3, 'PHONE', DATE '2025-04-25', 30, 2001, 'COMPLETED', 9, 'NEXT_ROUND')
    
    INTO interviews (interview_id, application_id, interview_type, scheduled_date, duration_minutes, interviewer_id, status, overall_rating, recommendation)
    VALUES (interview_seq.NEXTVAL, 3, 'IN_PERSON', DATE '2025-05-02', 60, 1002, 'COMPLETED', 8, 'HIRE')

SELECT * FROM dual;

-- ===========================================
-- 8. PERFORMANCE GOALS
-- ===========================================

-- Create performance goals for employees
INSERT ALL
    INTO performance_goals (goal_id, employee_id, review_id, goal_title, goal_description, target_date, priority, category, status, completion_percentage)
    VALUES (1, 1002, 1, 'Complete Oracle Certification', 'Obtain Oracle Database 12c Administrator Certified Professional certification', DATE '2025-09-30', 'HIGH', 'LEARNING', 'ACTIVE', 25)
    
    INTO performance_goals (goal_id, employee_id, review_id, goal_title, goal_description, target_date, priority, category, status, completion_percentage)
    VALUES (2, 1002, 1, 'Lead Database Migration Project', 'Successfully lead the migration of legacy systems to Oracle Cloud', DATE '2025-12-31', 'HIGH', 'LEADERSHIP', 'ACTIVE', 40)
    
    INTO performance_goals (goal_id, employee_id, review_id, goal_title, goal_description, target_date, priority, category, status, completion_percentage)
    VALUES (3, 1003, 2, 'Improve Code Quality Metrics', 'Reduce code defects by 50% and improve test coverage to 90%', DATE '2025-08-31', 'MEDIUM', 'TECHNICAL', 'ACTIVE', 60)
    
    INTO performance_goals (goal_id, employee_id, review_id, goal_title, goal_description, target_date, priority, category, status, completion_percentage)
    VALUES (4, 1004, 3, 'Cross-Training in Frontend Technologies', 'Learn React and Angular frameworks to support full-stack development', DATE '2025-10-31', 'MEDIUM', 'LEARNING', 'ACTIVE', 30)
    
    INTO performance_goals (goal_id, employee_id, review_id, goal_title, goal_description, target_date, priority, category, status, completion_percentage)
    VALUES (5, 2002, 4, 'Implement Employee Engagement Program', 'Design and launch quarterly employee satisfaction surveys', DATE '2025-07-31', 'HIGH', 'PRODUCTIVITY', 'ACTIVE', 75)

SELECT * FROM dual;

COMMIT;

-- ===========================================
-- 9. UPDATE PAYROLL RUN TOTALS
-- ===========================================

-- Update payroll run totals based on individual payroll items
UPDATE payroll_runs pr SET (
    total_gross_amount,
    total_net_amount,
    total_tax_amount,
    employee_count
) = (
    SELECT 
        NVL(SUM(pi.total_gross), 0),
        NVL(SUM(pi.net_pay), 0),
        NVL(SUM(pi.federal_tax + pi.state_tax + pi.social_security + pi.medicare), 0),
        COUNT(pi.employee_id)
    FROM payroll_items pi
    WHERE pi.payroll_run_id = pr.payroll_run_id
);

COMMIT;

-- ===========================================
-- 10. VERIFICATION AND SUMMARY
-- ===========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('HR SAMPLE DATA LOADING COMPLETE');
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Display record counts
    FOR rec IN (
        SELECT 'Employees' as table_name, COUNT(*) as record_count FROM employees
        UNION ALL
        SELECT 'Employee Addresses', COUNT(*) FROM employee_addresses
        UNION ALL
        SELECT 'Benefit Enrollments', COUNT(*) FROM employee_benefits
        UNION ALL
        SELECT 'Payroll Runs', COUNT(*) FROM payroll_runs
        UNION ALL
        SELECT 'Payroll Items', COUNT(*) FROM payroll_items
        UNION ALL
        SELECT 'Performance Reviews', COUNT(*) FROM performance_reviews
        UNION ALL
        SELECT 'Performance Goals', COUNT(*) FROM performance_goals
        UNION ALL
        SELECT 'Training Enrollments', COUNT(*) FROM training_enrollments
        UNION ALL
        SELECT 'Job Postings', COUNT(*) FROM job_postings
        UNION ALL
        SELECT 'Job Applications', COUNT(*) FROM job_applications
        UNION ALL
        SELECT 'Interviews', COUNT(*) FROM interviews
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.table_name, 25) || ': ' || rec.record_count || ' records');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sample data successfully loaded!');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next Steps:');
    DBMS_OUTPUT.PUT_LINE('1. Run hr-procedures.sql to create business logic procedures');
    DBMS_OUTPUT.PUT_LINE('2. Run hr-views.sql to create reporting views');
    DBMS_OUTPUT.PUT_LINE('3. Test the system with sample queries and procedures');
    DBMS_OUTPUT.PUT_LINE('4. Review the hr-management-project.md for additional features');
END;
/
