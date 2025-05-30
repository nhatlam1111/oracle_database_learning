
/*
===========================================
HR MANAGEMENT SYSTEM - DATABASE SCHEMA
===========================================

This script creates the complete database schema for the HR Management System
as described in the hr-management-project.md guide.

Components:
1. Core HR Tables (Employees, Departments, Positions)
2. Payroll Management Tables
3. Performance Management Tables
4. Recruitment & Hiring Tables
5. Training & Development Tables
6. Audit and Logging Tables
7. Sequences and Constraints
8. Initial Data Setup

Prerequisites:
- Oracle Database 12c or higher
- Sufficient privileges to create tables, sequences, and constraints
- At least 100MB of available tablespace
*/

-- ===========================================
-- 1. CLEANUP EXISTING OBJECTS (if needed)
-- ===========================================

-- Drop tables in correct order (child tables first)
DROP TABLE performance_goals CASCADE CONSTRAINTS;
DROP TABLE performance_reviews CASCADE CONSTRAINTS;
DROP TABLE training_enrollments CASCADE CONSTRAINTS;
DROP TABLE training_programs CASCADE CONSTRAINTS;
DROP TABLE interview_feedback CASCADE CONSTRAINTS;
DROP TABLE interviews CASCADE CONSTRAINTS;
DROP TABLE job_applications CASCADE CONSTRAINTS;
DROP TABLE job_postings CASCADE CONSTRAINTS;
DROP TABLE payroll_items CASCADE CONSTRAINTS;
DROP TABLE payroll_runs CASCADE CONSTRAINTS;
DROP TABLE employee_benefits CASCADE CONSTRAINTS;
DROP TABLE benefit_plans CASCADE CONSTRAINTS;
DROP TABLE employee_addresses CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE positions CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;
DROP TABLE locations CASCADE CONSTRAINTS;
DROP TABLE audit_log CASCADE CONSTRAINTS;

-- Drop sequences
DROP SEQUENCE dept_seq;
DROP SEQUENCE location_seq;
DROP SEQUENCE position_seq;
DROP SEQUENCE employee_seq;
DROP SEQUENCE payroll_run_seq;
DROP SEQUENCE audit_log_seq;

-- ===========================================
-- 2. CREATE SEQUENCES
-- ===========================================

CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE location_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE position_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE employee_seq START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE payroll_run_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE audit_log_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE job_posting_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE application_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE interview_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE training_program_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE performance_review_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- ===========================================
-- 3. CORE LOOKUP TABLES
-- ===========================================

-- Locations/Offices
CREATE TABLE locations (
    location_id NUMBER(6) PRIMARY KEY,
    location_code VARCHAR2(10) NOT NULL UNIQUE,
    location_name VARCHAR2(100) NOT NULL,
    address_line1 VARCHAR2(100),
    address_line2 VARCHAR2(100),
    city VARCHAR2(50) NOT NULL,
    state_province VARCHAR2(50),
    postal_code VARCHAR2(20),
    country VARCHAR2(50) NOT NULL,
    time_zone VARCHAR2(50),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE
);

-- Departments
CREATE TABLE departments (
    department_id NUMBER(6) PRIMARY KEY,
    department_code VARCHAR2(10) NOT NULL UNIQUE,
    department_name VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    location_id NUMBER(6),
    manager_id NUMBER(8),  -- Will reference employees table
    budget_amount NUMBER(12,2),
    cost_center VARCHAR2(20),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT dept_location_fk FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Job Positions/Titles
CREATE TABLE positions (
    position_id NUMBER(6) PRIMARY KEY,
    position_code VARCHAR2(20) NOT NULL UNIQUE,
    position_title VARCHAR2(100) NOT NULL,
    department_id NUMBER(6) NOT NULL,
    job_level NUMBER(2) CHECK (job_level BETWEEN 1 AND 10),
    min_salary NUMBER(8,2),
    max_salary NUMBER(8,2),
    job_description CLOB,
    required_skills VARCHAR2(1000),
    education_requirements VARCHAR2(500),
    experience_years NUMBER(2),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT pos_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT pos_salary_check CHECK (max_salary >= min_salary)
);

-- ===========================================
-- 4. CORE EMPLOYEE MANAGEMENT
-- ===========================================

-- Main Employees Table
CREATE TABLE employees (
    employee_id NUMBER(8) PRIMARY KEY,
    employee_number VARCHAR2(20) NOT NULL UNIQUE,
    ssn_encrypted VARCHAR2(64),  -- Encrypted SSN
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    middle_name VARCHAR2(50),
    preferred_name VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone_work VARCHAR2(20),
    phone_mobile VARCHAR2(20),
    birth_date DATE,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F', 'O')),
    marital_status VARCHAR2(15) CHECK (marital_status IN ('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED', 'OTHER')),
    
    -- Employment Information
    hire_date DATE NOT NULL,
    termination_date DATE,
    employment_status VARCHAR2(15) DEFAULT 'ACTIVE' 
        CHECK (employment_status IN ('ACTIVE', 'INACTIVE', 'TERMINATED', 'RETIRED', 'LOA')),
    employment_type VARCHAR2(15) DEFAULT 'FULL_TIME'
        CHECK (employment_type IN ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN', 'TEMPORARY')),
    
    -- Position and Reporting
    position_id NUMBER(6) NOT NULL,
    department_id NUMBER(6) NOT NULL,
    manager_id NUMBER(8),
    location_id NUMBER(6),
    
    -- Compensation
    salary NUMBER(8,2) NOT NULL,
    pay_frequency VARCHAR2(10) DEFAULT 'MONTHLY' 
        CHECK (pay_frequency IN ('WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY')),
    currency_code VARCHAR2(3) DEFAULT 'USD',
    
    -- Emergency Contact
    emergency_contact_name VARCHAR2(100),
    emergency_contact_phone VARCHAR2(20),
    emergency_contact_relationship VARCHAR2(50),
    
    -- System Fields
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    created_by VARCHAR2(50) DEFAULT USER,
    updated_by VARCHAR2(50) DEFAULT USER,
    
    -- Constraints
    CONSTRAINT emp_position_fk FOREIGN KEY (position_id) REFERENCES positions(position_id),
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    CONSTRAINT emp_location_fk FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT emp_term_date_check CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- Add the department manager foreign key after employees table is created
ALTER TABLE departments ADD CONSTRAINT dept_manager_fk 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Employee Addresses (supports multiple addresses per employee)
CREATE TABLE employee_addresses (
    address_id NUMBER(10) PRIMARY KEY,
    employee_id NUMBER(8) NOT NULL,
    address_type VARCHAR2(20) DEFAULT 'HOME' 
        CHECK (address_type IN ('HOME', 'WORK', 'MAILING', 'EMERGENCY')),
    address_line1 VARCHAR2(100) NOT NULL,
    address_line2 VARCHAR2(100),
    city VARCHAR2(50) NOT NULL,
    state_province VARCHAR2(50),
    postal_code VARCHAR2(20),
    country VARCHAR2(50) NOT NULL,
    is_primary VARCHAR2(1) DEFAULT 'N' CHECK (is_primary IN ('Y', 'N')),
    effective_date DATE DEFAULT SYSDATE,
    end_date DATE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT addr_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT addr_date_check CHECK (end_date IS NULL OR end_date >= effective_date)
);

-- ===========================================
-- 5. BENEFITS MANAGEMENT
-- ===========================================

-- Benefit Plans
CREATE TABLE benefit_plans (
    plan_id NUMBER(6) PRIMARY KEY,
    plan_code VARCHAR2(20) NOT NULL UNIQUE,
    plan_name VARCHAR2(100) NOT NULL,
    plan_type VARCHAR2(30) NOT NULL 
        CHECK (plan_type IN ('HEALTH', 'DENTAL', 'VISION', 'LIFE', 'DISABILITY', 'RETIREMENT', 'OTHER')),
    description VARCHAR2(1000),
    provider_name VARCHAR2(100),
    employee_cost NUMBER(8,2) DEFAULT 0,
    employer_cost NUMBER(8,2) DEFAULT 0,
    coverage_details CLOB,
    eligibility_rules VARCHAR2(1000),
    effective_date DATE NOT NULL,
    end_date DATE,
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE
);

-- Employee Benefit Enrollments
CREATE TABLE employee_benefits (
    enrollment_id NUMBER(10) PRIMARY KEY,
    employee_id NUMBER(8) NOT NULL,
    plan_id NUMBER(6) NOT NULL,
    enrollment_date DATE NOT NULL,
    effective_date DATE NOT NULL,
    termination_date DATE,
    coverage_level VARCHAR2(20) DEFAULT 'EMPLOYEE' 
        CHECK (coverage_level IN ('EMPLOYEE', 'EMPLOYEE_SPOUSE', 'EMPLOYEE_CHILDREN', 'FAMILY')),
    employee_contribution NUMBER(8,2) DEFAULT 0,
    employer_contribution NUMBER(8,2) DEFAULT 0,
    status VARCHAR2(15) DEFAULT 'ACTIVE' 
        CHECK (status IN ('ACTIVE', 'TERMINATED', 'SUSPENDED')),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT ben_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT ben_plan_fk FOREIGN KEY (plan_id) REFERENCES benefit_plans(plan_id),
    CONSTRAINT ben_date_check CHECK (termination_date IS NULL OR termination_date >= effective_date)
);

-- ===========================================
-- 6. PAYROLL MANAGEMENT
-- ===========================================

-- Payroll Runs (pay periods)
CREATE TABLE payroll_runs (
    payroll_run_id NUMBER(8) PRIMARY KEY,
    run_number VARCHAR2(20) NOT NULL UNIQUE,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    pay_date DATE NOT NULL,
    run_status VARCHAR2(15) DEFAULT 'DRAFT' 
        CHECK (run_status IN ('DRAFT', 'CALCULATED', 'APPROVED', 'PAID', 'CANCELLED')),
    total_gross_amount NUMBER(12,2) DEFAULT 0,
    total_net_amount NUMBER(12,2) DEFAULT 0,
    total_tax_amount NUMBER(12,2) DEFAULT 0,
    employee_count NUMBER(6) DEFAULT 0,
    created_by VARCHAR2(50) DEFAULT USER,
    approved_by VARCHAR2(50),
    approved_date DATE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT payroll_dates_check CHECK (pay_period_end >= pay_period_start)
);

-- Payroll Items (individual employee pay records)
CREATE TABLE payroll_items (
    payroll_item_id NUMBER(10) PRIMARY KEY,
    payroll_run_id NUMBER(8) NOT NULL,
    employee_id NUMBER(8) NOT NULL,
    
    -- Earnings
    regular_hours NUMBER(5,2) DEFAULT 0,
    overtime_hours NUMBER(5,2) DEFAULT 0,
    regular_rate NUMBER(8,2) DEFAULT 0,
    overtime_rate NUMBER(8,2) DEFAULT 0,
    gross_salary NUMBER(8,2) DEFAULT 0,
    bonus_amount NUMBER(8,2) DEFAULT 0,
    commission_amount NUMBER(8,2) DEFAULT 0,
    other_earnings NUMBER(8,2) DEFAULT 0,
    total_gross NUMBER(8,2) DEFAULT 0,
    
    -- Deductions
    federal_tax NUMBER(8,2) DEFAULT 0,
    state_tax NUMBER(8,2) DEFAULT 0,
    social_security NUMBER(8,2) DEFAULT 0,
    medicare NUMBER(8,2) DEFAULT 0,
    health_insurance NUMBER(8,2) DEFAULT 0,
    dental_insurance NUMBER(8,2) DEFAULT 0,
    retirement_401k NUMBER(8,2) DEFAULT 0,
    other_deductions NUMBER(8,2) DEFAULT 0,
    total_deductions NUMBER(8,2) DEFAULT 0,
    
    -- Net Pay
    net_pay NUMBER(8,2) DEFAULT 0,
    
    -- Status
    status VARCHAR2(15) DEFAULT 'CALCULATED' 
        CHECK (status IN ('CALCULATED', 'APPROVED', 'PAID', 'CANCELLED')),
    
    created_date DATE DEFAULT SYSDATE,
    
    CONSTRAINT pay_item_run_fk FOREIGN KEY (payroll_run_id) REFERENCES payroll_runs(payroll_run_id),
    CONSTRAINT pay_item_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT pay_calc_check CHECK (total_gross = gross_salary + bonus_amount + commission_amount + other_earnings),
    CONSTRAINT pay_net_check CHECK (net_pay = total_gross - total_deductions)
);

-- ===========================================
-- 7. RECRUITMENT MANAGEMENT
-- ===========================================

-- Job Postings
CREATE TABLE job_postings (
    posting_id NUMBER(8) PRIMARY KEY,
    posting_number VARCHAR2(20) NOT NULL UNIQUE,
    position_id NUMBER(6) NOT NULL,
    title VARCHAR2(200) NOT NULL,
    description CLOB,
    requirements CLOB,
    location_id NUMBER(6),
    employment_type VARCHAR2(15) DEFAULT 'FULL_TIME',
    salary_min NUMBER(8,2),
    salary_max NUMBER(8,2),
    posting_date DATE DEFAULT SYSDATE,
    application_deadline DATE,
    status VARCHAR2(15) DEFAULT 'DRAFT' 
        CHECK (status IN ('DRAFT', 'ACTIVE', 'CLOSED', 'CANCELLED')),
    hiring_manager_id NUMBER(8),
    hr_contact_id NUMBER(8),
    external_posting_sites VARCHAR2(500),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT posting_pos_fk FOREIGN KEY (position_id) REFERENCES positions(position_id),
    CONSTRAINT posting_loc_fk FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT posting_mgr_fk FOREIGN KEY (hiring_manager_id) REFERENCES employees(employee_id),
    CONSTRAINT posting_hr_fk FOREIGN KEY (hr_contact_id) REFERENCES employees(employee_id)
);

-- Job Applications
CREATE TABLE job_applications (
    application_id NUMBER(10) PRIMARY KEY,
    application_number VARCHAR2(20) NOT NULL UNIQUE,
    posting_id NUMBER(8) NOT NULL,
    applicant_first_name VARCHAR2(50) NOT NULL,
    applicant_last_name VARCHAR2(50) NOT NULL,
    applicant_email VARCHAR2(100) NOT NULL,
    applicant_phone VARCHAR2(20),
    resume_file_path VARCHAR2(500),
    cover_letter CLOB,
    application_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'SUBMITTED' 
        CHECK (status IN ('SUBMITTED', 'SCREENING', 'INTERVIEWING', 'OFFER', 'HIRED', 'REJECTED', 'WITHDRAWN')),
    source VARCHAR2(50),  -- How they found the job
    notes CLOB,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT app_posting_fk FOREIGN KEY (posting_id) REFERENCES job_postings(posting_id)
);

-- Interview Scheduling and Results
CREATE TABLE interviews (
    interview_id NUMBER(10) PRIMARY KEY,
    application_id NUMBER(10) NOT NULL,
    interview_type VARCHAR2(30) DEFAULT 'PHONE' 
        CHECK (interview_type IN ('PHONE', 'VIDEO', 'IN_PERSON', 'PANEL', 'TECHNICAL', 'BEHAVIORAL')),
    scheduled_date DATE NOT NULL,
    scheduled_time VARCHAR2(10),
    duration_minutes NUMBER(3) DEFAULT 60,
    interviewer_id NUMBER(8),
    location VARCHAR2(200),
    status VARCHAR2(15) DEFAULT 'SCHEDULED' 
        CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    overall_rating NUMBER(2) CHECK (overall_rating BETWEEN 1 AND 10),
    recommendation VARCHAR2(20) 
        CHECK (recommendation IN ('HIRE', 'NO_HIRE', 'MAYBE', 'NEXT_ROUND')),
    notes CLOB,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT int_app_fk FOREIGN KEY (application_id) REFERENCES job_applications(application_id),
    CONSTRAINT int_interviewer_fk FOREIGN KEY (interviewer_id) REFERENCES employees(employee_id)
);

-- ===========================================
-- 8. PERFORMANCE MANAGEMENT
-- ===========================================

-- Performance Review Cycles
CREATE TABLE performance_reviews (
    review_id NUMBER(10) PRIMARY KEY,
    employee_id NUMBER(8) NOT NULL,
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    review_type VARCHAR2(20) DEFAULT 'ANNUAL' 
        CHECK (review_type IN ('ANNUAL', 'QUARTERLY', 'PROBATIONARY', 'PROJECT', 'SPECIAL')),
    reviewer_id NUMBER(8) NOT NULL,
    review_date DATE,
    status VARCHAR2(15) DEFAULT 'DRAFT' 
        CHECK (status IN ('DRAFT', 'IN_PROGRESS', 'COMPLETED', 'APPROVED')),
    
    -- Rating Categories (1-5 scale)
    technical_skills_rating NUMBER(2) CHECK (technical_skills_rating BETWEEN 1 AND 5),
    communication_rating NUMBER(2) CHECK (communication_rating BETWEEN 1 AND 5),
    teamwork_rating NUMBER(2) CHECK (teamwork_rating BETWEEN 1 AND 5),
    leadership_rating NUMBER(2) CHECK (leadership_rating BETWEEN 1 AND 5),
    initiative_rating NUMBER(2) CHECK (initiative_rating BETWEEN 1 AND 5),
    overall_rating NUMBER(3,1) CHECK (overall_rating BETWEEN 1.0 AND 5.0),
    
    -- Comments
    strengths CLOB,
    areas_for_improvement CLOB,
    goals_next_period CLOB,
    development_plan CLOB,
    employee_comments CLOB,
    
    -- Actions
    recommended_salary_increase NUMBER(5,2),  -- Percentage
    recommended_promotion VARCHAR2(1) CHECK (recommended_promotion IN ('Y', 'N')),
    
    created_date DATE DEFAULT SYSDATE,
    
    CONSTRAINT perf_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT perf_reviewer_fk FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id),
    CONSTRAINT perf_dates_check CHECK (review_period_end >= review_period_start)
);

-- Performance Goals
CREATE TABLE performance_goals (
    goal_id NUMBER(10) PRIMARY KEY,
    employee_id NUMBER(8) NOT NULL,
    review_id NUMBER(10),
    goal_title VARCHAR2(200) NOT NULL,
    goal_description CLOB,
    target_date DATE,
    priority VARCHAR2(10) DEFAULT 'MEDIUM' 
        CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    category VARCHAR2(30) 
        CHECK (category IN ('TECHNICAL', 'LEADERSHIP', 'COMMUNICATION', 'PRODUCTIVITY', 'LEARNING', 'OTHER')),
    status VARCHAR2(15) DEFAULT 'ACTIVE' 
        CHECK (status IN ('ACTIVE', 'COMPLETED', 'CANCELLED', 'DEFERRED')),
    completion_percentage NUMBER(3) DEFAULT 0 CHECK (completion_percentage BETWEEN 0 AND 100),
    notes CLOB,
    created_date DATE DEFAULT SYSDATE,
    completed_date DATE,
    CONSTRAINT goal_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT goal_review_fk FOREIGN KEY (review_id) REFERENCES performance_reviews(review_id)
);

-- ===========================================
-- 9. TRAINING AND DEVELOPMENT
-- ===========================================

-- Training Programs
CREATE TABLE training_programs (
    program_id NUMBER(8) PRIMARY KEY,
    program_code VARCHAR2(20) NOT NULL UNIQUE,
    program_name VARCHAR2(200) NOT NULL,
    description CLOB,
    category VARCHAR2(50) 
        CHECK (category IN ('TECHNICAL', 'LEADERSHIP', 'COMPLIANCE', 'SAFETY', 'COMMUNICATION', 'OTHER')),
    delivery_method VARCHAR2(30) 
        CHECK (delivery_method IN ('CLASSROOM', 'ONLINE', 'WEBINAR', 'CONFERENCE', 'WORKSHOP', 'MENTORING')),
    duration_hours NUMBER(5,1),
    capacity NUMBER(4),
    cost_per_person NUMBER(8,2),
    provider VARCHAR2(100),
    certification_available VARCHAR2(1) CHECK (certification_available IN ('Y', 'N')),
    mandatory VARCHAR2(1) DEFAULT 'N' CHECK (mandatory IN ('Y', 'N')),
    prerequisites VARCHAR2(1000),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE
);

-- Training Enrollments
CREATE TABLE training_enrollments (
    enrollment_id NUMBER(10) PRIMARY KEY,
    program_id NUMBER(8) NOT NULL,
    employee_id NUMBER(8) NOT NULL,
    enrollment_date DATE DEFAULT SYSDATE,
    scheduled_start_date DATE,
    scheduled_end_date DATE,
    actual_start_date DATE,
    actual_completion_date DATE,
    status VARCHAR2(15) DEFAULT 'ENROLLED' 
        CHECK (status IN ('ENROLLED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    score NUMBER(3) CHECK (score BETWEEN 0 AND 100),
    passed VARCHAR2(1) CHECK (passed IN ('Y', 'N')),
    certification_earned VARCHAR2(1) CHECK (certification_earned IN ('Y', 'N')),
    cost NUMBER(8,2),
    feedback CLOB,
    approved_by NUMBER(8),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT train_prog_fk FOREIGN KEY (program_id) REFERENCES training_programs(program_id),
    CONSTRAINT train_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT train_approved_fk FOREIGN KEY (approved_by) REFERENCES employees(employee_id)
);

-- ===========================================
-- 10. AUDIT AND LOGGING
-- ===========================================

-- Comprehensive Audit Log
CREATE TABLE audit_log (
    log_id NUMBER(12) PRIMARY KEY,
    table_name VARCHAR2(30) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id VARCHAR2(50) NOT NULL,
    field_name VARCHAR2(30),
    old_value VARCHAR2(4000),
    new_value VARCHAR2(4000),
    changed_by VARCHAR2(50) NOT NULL,
    change_date DATE DEFAULT SYSDATE,
    session_id VARCHAR2(50),
    ip_address VARCHAR2(45),
    application_name VARCHAR2(100)
);

-- ===========================================
-- 11. INDEXES FOR PERFORMANCE
-- ===========================================

-- Primary lookup indexes
CREATE INDEX idx_emp_number ON employees(employee_number);
CREATE INDEX idx_emp_email ON employees(email);
CREATE INDEX idx_emp_name ON employees(last_name, first_name);
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_emp_manager ON employees(manager_id);
CREATE INDEX idx_emp_position ON employees(position_id);
CREATE INDEX idx_emp_status ON employees(employment_status);

-- Payroll indexes
CREATE INDEX idx_payroll_run_dates ON payroll_runs(pay_period_start, pay_period_end);
CREATE INDEX idx_payroll_items_emp ON payroll_items(employee_id, payroll_run_id);

-- Performance review indexes
CREATE INDEX idx_perf_emp_date ON performance_reviews(employee_id, review_period_start);
CREATE INDEX idx_perf_reviewer ON performance_reviews(reviewer_id);

-- Recruitment indexes
CREATE INDEX idx_app_posting ON job_applications(posting_id);
CREATE INDEX idx_app_email ON job_applications(applicant_email);
CREATE INDEX idx_app_status ON job_applications(status);

-- Training indexes
CREATE INDEX idx_training_emp ON training_enrollments(employee_id);
CREATE INDEX idx_training_prog ON training_enrollments(program_id);

-- Audit indexes
CREATE INDEX idx_audit_table_id ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_date ON audit_log(change_date);
CREATE INDEX idx_audit_user ON audit_log(changed_by);

-- ===========================================
-- 12. INITIAL REFERENCE DATA
-- ===========================================

-- Insert default locations
INSERT INTO locations (location_id, location_code, location_name, city, state_province, country, time_zone)
VALUES (location_seq.NEXTVAL, 'HQ', 'Corporate Headquarters', 'New York', 'NY', 'USA', 'EST');

INSERT INTO locations (location_id, location_code, location_name, city, state_province, country, time_zone)
VALUES (location_seq.NEXTVAL, 'SF', 'San Francisco Office', 'San Francisco', 'CA', 'USA', 'PST');

INSERT INTO locations (location_id, location_code, location_name, city, state_province, country, time_zone)
VALUES (location_seq.NEXTVAL, 'LON', 'London Office', 'London', '', 'UK', 'GMT');

-- Insert default departments
INSERT INTO departments (department_id, department_code, department_name, location_id, budget_amount)
VALUES (dept_seq.NEXTVAL, 'IT', 'Information Technology', 1, 2500000);

INSERT INTO departments (department_id, department_code, department_name, location_id, budget_amount)
VALUES (dept_seq.NEXTVAL, 'HR', 'Human Resources', 1, 1200000);

INSERT INTO departments (department_id, department_code, department_name, location_id, budget_amount)
VALUES (dept_seq.NEXTVAL, 'FIN', 'Finance', 1, 1800000);

INSERT INTO departments (department_id, department_code, department_name, location_id, budget_amount)
VALUES (dept_seq.NEXTVAL, 'SALES', 'Sales', 2, 3200000);

INSERT INTO departments (department_id, department_code, department_name, location_id, budget_amount)
VALUES (dept_seq.NEXTVAL, 'MKT', 'Marketing', 2, 1500000);

-- Insert sample positions
INSERT INTO positions (position_id, position_code, position_title, department_id, job_level, min_salary, max_salary)
VALUES (position_seq.NEXTVAL, 'DEV-SR', 'Senior Software Developer', 1, 6, 90000, 130000);

INSERT INTO positions (position_id, position_code, position_title, department_id, job_level, min_salary, max_salary)
VALUES (position_seq.NEXTVAL, 'DEV-JR', 'Junior Software Developer', 1, 3, 55000, 75000);

INSERT INTO positions (position_id, position_code, position_title, department_id, job_level, min_salary, max_salary)
VALUES (position_seq.NEXTVAL, 'HR-MGR', 'HR Manager', 2, 7, 85000, 110000);

INSERT INTO positions (position_id, position_code, position_title, department_id, job_level, min_salary, max_salary)
VALUES (position_seq.NEXTVAL, 'FIN-AN', 'Financial Analyst', 3, 4, 65000, 85000);

INSERT INTO positions (position_id, position_code, position_title, department_id, job_level, min_salary, max_salary)
VALUES (position_seq.NEXTVAL, 'SALES-REP', 'Sales Representative', 4, 4, 50000, 80000);

-- Insert sample benefit plans
INSERT INTO benefit_plans (plan_id, plan_code, plan_name, plan_type, employee_cost, employer_cost, effective_date)
VALUES (1, 'HEALTH-PPO', 'PPO Health Insurance', 'HEALTH', 150.00, 350.00, DATE '2025-01-01');

INSERT INTO benefit_plans (plan_id, plan_code, plan_name, plan_type, employee_cost, employer_cost, effective_date)
VALUES (2, 'DENTAL-BASIC', 'Basic Dental Coverage', 'DENTAL', 25.00, 75.00, DATE '2025-01-01');

INSERT INTO benefit_plans (plan_id, plan_code, plan_name, plan_type, employee_cost, employer_cost, effective_date)
VALUES (3, '401K-MATCH', '401(k) with Company Match', 'RETIREMENT', 0.00, 0.00, DATE '2025-01-01');

-- Insert sample training programs
INSERT INTO training_programs (program_id, program_code, program_name, category, delivery_method, duration_hours, cost_per_person)
VALUES (training_program_seq.NEXTVAL, 'ORCL-DB', 'Oracle Database Fundamentals', 'TECHNICAL', 'CLASSROOM', 40, 1500);

INSERT INTO training_programs (program_id, program_code, program_name, category, delivery_method, duration_hours, cost_per_person)
VALUES (training_program_seq.NEXTVAL, 'LEAD-101', 'Leadership Essentials', 'LEADERSHIP', 'WORKSHOP', 16, 800);

INSERT INTO training_programs (program_id, program_code, program_name, category, delivery_method, duration_hours, cost_per_person)
VALUES (training_program_seq.NEXTVAL, 'SAFE-TRAIN', 'Workplace Safety Training', 'SAFETY', 'ONLINE', 4, 50);

COMMIT;

-- ===========================================
-- 13. SUCCESS MESSAGE
-- ===========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('HR MANAGEMENT SYSTEM SCHEMA SETUP COMPLETE');
    DBMS_OUTPUT.PUT_LINE('===========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Tables Created: 20');
    DBMS_OUTPUT.PUT_LINE('Sequences Created: 11');
    DBMS_OUTPUT.PUT_LINE('Indexes Created: 15');
    DBMS_OUTPUT.PUT_LINE('Reference Data Loaded: Yes');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next Steps:');
    DBMS_OUTPUT.PUT_LINE('1. Run hr-sample-data.sql to load test data');
    DBMS_OUTPUT.PUT_LINE('2. Run hr-procedures.sql to create business logic');
    DBMS_OUTPUT.PUT_LINE('3. Run hr-views.sql to create reporting views');
    DBMS_OUTPUT.PUT_LINE('4. Review hr-management-project.md for implementation guide');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Schema is ready for HR Management System development!');
END;
/
