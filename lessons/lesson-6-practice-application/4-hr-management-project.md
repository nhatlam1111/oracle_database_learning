# HR Management System Project

## 🎯 Project Overview

The HR Management System project is a comprehensive database application designed to handle all aspects of human resources management in a modern organization. This project will demonstrate your ability to design, implement, and optimize a complex business system using Oracle Database.

## 📋 Project Objectives

### **Primary Goals:**
- Design a complete HR database schema
- Implement employee lifecycle management
- Create payroll and benefits administration
- Build performance management system
- Develop reporting and analytics capabilities

### **Learning Outcomes:**
- Master complex database relationships
- Implement business rules with constraints and triggers
- Create sophisticated stored procedures and functions
- Build comprehensive reporting systems
- Apply security and data privacy principles

## 🏗️ System Requirements

### **Functional Requirements:**

#### **1. Employee Management**
- Employee personal information and contact details
- Job assignments and organizational hierarchy
- Employee status tracking (Active, Inactive, Terminated)
- Emergency contact management
- Document management (contracts, certifications)

#### **2. Position and Department Management**
- Department structure and hierarchy
- Job positions and descriptions
- Salary grades and compensation bands
- Reporting relationships
- Location management

#### **3. Payroll System**
- Salary calculation and adjustments
- Deductions and benefits administration
- Tax calculations and compliance
- Payroll history and reporting
- Time and attendance integration

#### **4. Performance Management**
- Goal setting and tracking
- Performance reviews and evaluations
- Skills assessment and development plans
- Training records and certifications
- Career progression tracking

#### **5. Recruitment and Onboarding**
- Job posting and application management
- Interview scheduling and feedback
- Offer management and acceptance
- Onboarding process tracking
- Background check integration

### **Technical Requirements:**

#### **Database Features:**
- **Multi-schema Design**: Separate schemas for different HR modules
- **Data Security**: Row-level security and data encryption
- **Audit Trail**: Complete change tracking for compliance
- **Performance**: Optimized for large employee datasets
- **Integration**: APIs for external system connectivity

#### **Advanced Features:**
- **Workflow Engine**: Automated approval processes
- **Notification System**: Email and system notifications
- **Reporting Engine**: Dynamic report generation
- **Data Analytics**: Employee insights and trends
- **Mobile Support**: Mobile-responsive design

## 📊 Database Schema Design

### **Core Tables Structure:**

```sql
-- Department hierarchy
CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    parent_department_id NUMBER,
    department_head_id NUMBER,
    budget DECIMAL(15,2),
    location_id NUMBER,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_parent_dept FOREIGN KEY (parent_department_id) 
        REFERENCES departments(department_id)
);

-- Employee master data
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    employee_number VARCHAR2(20) UNIQUE NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    department_id NUMBER NOT NULL,
    position_id NUMBER NOT NULL,
    manager_id NUMBER,
    employment_status VARCHAR2(20) DEFAULT 'ACTIVE',
    salary DECIMAL(10,2),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id)
);

-- Position management
CREATE TABLE positions (
    position_id NUMBER PRIMARY KEY,
    position_title VARCHAR2(100) NOT NULL,
    job_description CLOB,
    department_id NUMBER NOT NULL,
    salary_grade VARCHAR2(10),
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    required_skills CLOB,
    is_active CHAR(1) DEFAULT 'Y',
    CONSTRAINT fk_pos_dept FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
);

-- Payroll processing
CREATE TABLE payroll (
    payroll_id NUMBER PRIMARY KEY,
    employee_id NUMBER NOT NULL,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    gross_salary DECIMAL(10,2) NOT NULL,
    total_deductions DECIMAL(10,2),
    net_pay DECIMAL(10,2) NOT NULL,
    pay_date DATE,
    status VARCHAR2(20) DEFAULT 'PENDING',
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_payroll_emp FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
);

-- Performance evaluations
CREATE TABLE performance_reviews (
    review_id NUMBER PRIMARY KEY,
    employee_id NUMBER NOT NULL,
    reviewer_id NUMBER NOT NULL,
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    overall_rating NUMBER(2,1),
    goals_achieved NUMBER(3,1),
    areas_for_improvement CLOB,
    development_plan CLOB,
    review_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'DRAFT',
    CONSTRAINT fk_review_emp FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id),
    CONSTRAINT fk_reviewer FOREIGN KEY (reviewer_id) 
        REFERENCES employees(employee_id)
);
```

### **Supporting Tables:**

#### **Employee Details:**
- `employee_addresses` - Address information
- `employee_contacts` - Emergency contacts
- `employee_documents` - Document management
- `employee_skills` - Skills and certifications
- `employee_training` - Training records

#### **Payroll Details:**
- `salary_adjustments` - Salary change history
- `payroll_deductions` - Individual deductions
- `benefits_enrollment` - Benefits participation
- `time_attendance` - Work hours tracking

#### **Performance Management:**
- `goals` - Individual and team goals
- `performance_metrics` - Key performance indicators
- `training_requirements` - Required training
- `succession_planning` - Career development

## 🔧 Implementation Phases

### **Phase 1: Core Setup (Week 1)**

#### **Day 1-2: Database Foundation**
```sql
-- Create sequences
CREATE SEQUENCE seq_employee_id START WITH 1001;
CREATE SEQUENCE seq_department_id START WITH 101;
CREATE SEQUENCE seq_position_id START WITH 201;

-- Create indexes for performance
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_emp_manager ON employees(manager_id);
CREATE INDEX idx_emp_status ON employees(employment_status);
CREATE INDEX idx_payroll_emp ON payroll(employee_id);
```

#### **Day 3-4: Master Data Setup**
- Department structure creation
- Position definitions
- Initial employee data
- Organizational hierarchy

#### **Day 5-7: Basic CRUD Operations**
- Employee management procedures
- Department administration
- Position management
- Basic reporting queries

### **Phase 2: Business Logic (Week 2)**

#### **Advanced Procedures and Functions**
```sql
-- Employee hiring procedure
CREATE OR REPLACE PROCEDURE hire_employee(
    p_first_name VARCHAR2,
    p_last_name VARCHAR2,
    p_email VARCHAR2,
    p_department_id NUMBER,
    p_position_id NUMBER,
    p_manager_id NUMBER,
    p_salary NUMBER,
    p_hire_date DATE DEFAULT SYSDATE
) IS
    v_employee_id NUMBER;
BEGIN
    -- Validate department and position
    validate_department(p_department_id);
    validate_position(p_position_id);
    
    -- Generate employee ID
    SELECT seq_employee_id.NEXTVAL INTO v_employee_id FROM dual;
    
    -- Insert employee record
    INSERT INTO employees (
        employee_id, employee_number, first_name, last_name, 
        email, hire_date, department_id, position_id, 
        manager_id, salary
    ) VALUES (
        v_employee_id, 
        'EMP' || LPAD(v_employee_id, 6, '0'),
        p_first_name, p_last_name, p_email, p_hire_date,
        p_department_id, p_position_id, p_manager_id, p_salary
    );
    
    -- Initialize employee benefits
    setup_default_benefits(v_employee_id);
    
    -- Create initial performance goals
    create_initial_goals(v_employee_id);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Salary adjustment procedure
CREATE OR REPLACE PROCEDURE adjust_salary(
    p_employee_id NUMBER,
    p_new_salary NUMBER,
    p_effective_date DATE,
    p_reason VARCHAR2
) IS
    v_current_salary NUMBER;
    v_adjustment_pct NUMBER;
BEGIN
    -- Get current salary
    SELECT salary INTO v_current_salary 
    FROM employees 
    WHERE employee_id = p_employee_id;
    
    -- Calculate adjustment percentage
    v_adjustment_pct := ((p_new_salary - v_current_salary) / v_current_salary) * 100;
    
    -- Record salary adjustment
    INSERT INTO salary_adjustments (
        employee_id, old_salary, new_salary, 
        adjustment_percentage, effective_date, reason
    ) VALUES (
        p_employee_id, v_current_salary, p_new_salary,
        v_adjustment_pct, p_effective_date, p_reason
    );
    
    -- Update employee salary
    UPDATE employees 
    SET salary = p_new_salary 
    WHERE employee_id = p_employee_id;
    
    COMMIT;
END;
/
```

### **Phase 3: Advanced Features (Week 3)**

#### **Performance Management System**
- Goal setting and tracking
- Performance review workflows
- Skills assessment matrices
- Development plan creation

#### **Payroll Automation**
- Automated payroll calculation
- Tax calculation integration
- Benefits deduction processing
- Payroll report generation

### **Phase 4: Analytics and Reporting (Week 4)**

#### **HR Analytics Dashboard**
```sql
-- Employee turnover analysis
CREATE OR REPLACE VIEW employee_turnover_analysis AS
SELECT 
    d.department_name,
    COUNT(CASE WHEN e.employment_status = 'ACTIVE' THEN 1 END) as active_employees,
    COUNT(CASE WHEN e.employment_status = 'TERMINATED' 
          AND e.termination_date >= ADD_MONTHS(SYSDATE, -12) THEN 1 END) as terminated_last_year,
    ROUND(
        (COUNT(CASE WHEN e.employment_status = 'TERMINATED' 
               AND e.termination_date >= ADD_MONTHS(SYSDATE, -12) THEN 1 END) /
         NULLIF(COUNT(*), 0)) * 100, 2
    ) as turnover_rate_pct
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY turnover_rate_pct DESC;

-- Salary analysis by department
CREATE OR REPLACE VIEW salary_analysis_by_dept AS
SELECT 
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    AVG(e.salary) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    STDDEV(e.salary) as salary_std_dev,
    SUM(e.salary) as total_dept_cost
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.employment_status = 'ACTIVE'
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- Performance trending
CREATE OR REPLACE VIEW performance_trends AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    d.department_name,
    AVG(pr.overall_rating) as avg_rating,
    COUNT(pr.review_id) as review_count,
    LAG(AVG(pr.overall_rating)) OVER (
        PARTITION BY e.employee_id 
        ORDER BY EXTRACT(YEAR FROM pr.review_date)
    ) as previous_year_rating,
    AVG(pr.overall_rating) - LAG(AVG(pr.overall_rating)) OVER (
        PARTITION BY e.employee_id 
        ORDER BY EXTRACT(YEAR FROM pr.review_date)
    ) as rating_trend
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN performance_reviews pr ON e.employee_id = pr.employee_id
WHERE pr.status = 'APPROVED'
GROUP BY e.employee_id, e.first_name, e.last_name, d.department_name,
         EXTRACT(YEAR FROM pr.review_date)
ORDER BY rating_trend DESC;
```

## 🎯 Deliverables Checklist

### **Database Implementation:**
- [ ] Complete schema creation scripts
- [ ] Sample data insertion scripts
- [ ] All constraints and indexes implemented
- [ ] Stored procedures and functions created
- [ ] Views and materialized views defined

### **Business Logic:**
- [ ] Employee lifecycle management
- [ ] Payroll calculation procedures
- [ ] Performance review workflows
- [ ] Reporting and analytics queries
- [ ] Data validation and error handling

### **Documentation:**
- [ ] Database design document
- [ ] Entity-relationship diagrams
- [ ] API documentation for procedures
- [ ] User manual for HR operations
- [ ] Deployment and maintenance guide

### **Testing and Quality:**
- [ ] Unit tests for all procedures
- [ ] Data integrity validation
- [ ] Performance testing results
- [ ] Security testing documentation
- [ ] User acceptance testing

## 📈 Success Metrics

### **Technical Metrics:**
- **Database Performance**: Query response time < 2 seconds
- **Data Integrity**: Zero data inconsistencies
- **Code Quality**: 100% procedure documentation
- **Test Coverage**: 90% of functionality tested

### **Business Metrics:**
- **Functionality**: All HR processes automated
- **Usability**: Intuitive user interface
- **Compliance**: Meets regulatory requirements
- **Scalability**: Supports 10,000+ employees

## 🔍 Advanced Challenges

### **Optional Enhancements:**
1. **Multi-tenant Architecture**: Support multiple companies
2. **Real-time Notifications**: WebSocket-based alerts
3. **Machine Learning Integration**: Predictive analytics
4. **Mobile Application**: Native mobile app development
5. **API Development**: RESTful services for integration

### **Integration Projects:**
- **ERP Integration**: Connect with financial systems
- **Time Tracking**: Integration with attendance systems
- **Learning Management**: Connect with training platforms
- **Recruitment Tools**: Integration with job boards

## 📚 Learning Resources

### **Oracle Documentation:**
- Oracle Database Security Guide
- Oracle Application Express User Guide
- Oracle PL/SQL Programming Best Practices
- Oracle Database Performance Tuning Guide

### **Industry Best Practices:**
- HR Data Privacy Regulations (GDPR, CCPA)
- Database Design Patterns for HR Systems
- Payroll System Security Requirements
- Performance Management Database Design

This HR Management System project will provide comprehensive experience in building enterprise-level database applications while demonstrating mastery of Oracle Database technologies and HR domain knowledge.
