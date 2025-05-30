# Database Design Challenge

This comprehensive challenge tests your ability to design, implement, and optimize a complete database system from business requirements to deployment. You'll apply all concepts from Lessons 1-5 in a structured, professional database development process.

## 🎯 Challenge Overview

**Duration**: 1-2 weeks
**Complexity**: Advanced
**Skills Tested**: Complete database development lifecycle
**Deliverable**: Production-ready database system with documentation

## 📋 Business Scenario

You've been hired as a Database Architect for **TechCorp University**, a growing online education institution. They need a comprehensive **Learning Management System (LMS)** database to support their expanding operations.

### **Current Situation**
- 10,000+ students across multiple programs
- 500+ courses with various delivery methods
- 200+ instructors and administrative staff
- Multiple campuses and online delivery
- Complex grading and certification requirements
- Financial aid and payment processing needs

### **Business Pain Points**
1. **Data Silos**: Student information scattered across multiple systems
2. **Manual Processes**: Grade calculations and reporting done manually
3. **Scalability Issues**: Current system can't handle growth
4. **Compliance Requirements**: Need audit trails for accreditation
5. **Performance Problems**: Slow reporting and data retrieval

## 🎓 Challenge Requirements

### **Phase 1: Requirements Analysis and Data Modeling (Days 1-3)**

#### **Day 1: Requirements Gathering**

**Core Functional Requirements:**

1. **Student Management**
   - Student registration and enrollment
   - Academic records and transcripts
   - Financial aid and payment tracking
   - Communication preferences and history

2. **Course Management**
   - Course catalog and scheduling
   - Prerequisites and co-requisites
   - Multiple delivery methods (online, in-person, hybrid)
   - Resource management (textbooks, materials)

3. **Academic Operations**
   - Enrollment management
   - Grade recording and calculations
   - Attendance tracking
   - Assignment and exam management

4. **Faculty and Staff Management**
   - Employee information and roles
   - Course assignments and workload
   - Performance evaluation
   - Payroll integration points

5. **Administrative Functions**
   - Reporting and analytics
   - Compliance and audit trails
   - Financial operations
   - Communication systems

**Non-Functional Requirements:**

1. **Performance**: Support 1000+ concurrent users
2. **Scalability**: Handle 50% annual growth
3. **Security**: Role-based access control, data encryption
4. **Availability**: 99.9% uptime during business hours
5. **Compliance**: FERPA, SOX compliance for financial data

#### **Day 2: Entity Identification and Relationships**

**Your Task**: Identify and document the following:

1. **Core Entities** (minimum 15 entities)
   - Students, Courses, Instructors, Programs, etc.
   - Support entities (Addresses, Payments, Grades, etc.)

2. **Relationship Types**
   - One-to-One: Student ↔ Student Profile
   - One-to-Many: Course ↔ Enrollments
   - Many-to-Many: Students ↔ Courses (through Enrollments)

3. **Business Rules**
   - A student must be enrolled in a program to take courses
   - Prerequisites must be satisfied before enrollment
   - Grades can only be entered by assigned instructors
   - Financial holds prevent new enrollments

**Deliverable**: Complete Entity-Relationship Diagram (ERD)

#### **Day 3: Logical Data Model Design**

**Your Task**: Create a detailed logical data model including:

1. **Normalization**: Ensure 3NF minimum, consider BCNF where appropriate
2. **Primary Keys**: Natural vs. surrogate key decisions
3. **Foreign Keys**: Referential integrity constraints
4. **Attributes**: Complete attribute definitions with data types
5. **Constraints**: Business rule enforcement through database constraints

**Deliverable**: Detailed logical data model with all tables, columns, and relationships

### **Phase 2: Physical Database Implementation (Days 4-7)**

#### **Day 4: Physical Schema Creation**

**Your Task**: Transform the logical model into Oracle physical schema:

```sql
-- Example table structure you should create
CREATE TABLE students (
    student_id NUMBER(10) PRIMARY KEY,
    student_number VARCHAR2(20) NOT NULL UNIQUE,
    ssn_encrypted VARCHAR2(64), -- Encrypted sensitive data
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    middle_name VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone VARCHAR2(20),
    birth_date DATE NOT NULL,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F', 'O')),
    citizenship_status VARCHAR2(20),
    emergency_contact_name VARCHAR2(100),
    emergency_contact_phone VARCHAR2(20),
    enrollment_status VARCHAR2(15) DEFAULT 'ACTIVE' 
        CHECK (enrollment_status IN ('ACTIVE', 'INACTIVE', 'GRADUATED', 'WITHDRAWN', 'SUSPENDED')),
    program_id NUMBER(6) NOT NULL,
    advisor_id NUMBER(6),
    admission_date DATE NOT NULL,
    expected_graduation_date DATE,
    graduation_date DATE,
    gpa NUMBER(3,2) CHECK (gpa BETWEEN 0 AND 4.0),
    total_credits_earned NUMBER(5,1) DEFAULT 0,
    financial_hold VARCHAR2(1) DEFAULT 'N' CHECK (financial_hold IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    created_by VARCHAR2(50) DEFAULT USER,
    updated_by VARCHAR2(50) DEFAULT USER,
    CONSTRAINT stud_prog_fk FOREIGN KEY (program_id) REFERENCES programs(program_id),
    CONSTRAINT stud_advisor_fk FOREIGN KEY (advisor_id) REFERENCES faculty(faculty_id)
);
```

**Requirements**:
- Minimum 15 interconnected tables
- All appropriate constraints implemented
- Proper Oracle data types selected
- Audit columns (created_date, updated_date, etc.)
- Strategic use of sequences for primary keys

#### **Day 5: Sample Data Creation**

**Your Task**: Create comprehensive test data:

1. **Volume Requirements**:
   - 1,000+ students across multiple programs
   - 200+ courses with various schedules
   - 50+ faculty members with different roles
   - 5,000+ enrollment records
   - 10,000+ grade records

2. **Data Quality**:
   - Realistic names, addresses, and contact information
   - Proper date relationships (enrollment before grades)
   - Business rule compliance (prerequisites satisfied)
   - Balanced distribution across programs and terms

**Deliverable**: Complete data population scripts with realistic test data

#### **Day 6: Business Logic Implementation**

**Your Task**: Implement core business logic using PL/SQL:

1. **Stored Procedures** (minimum 8 procedures):
   ```sql
   -- Example procedure you should implement
   CREATE OR REPLACE PROCEDURE enroll_student (
       p_student_id IN NUMBER,
       p_course_id IN NUMBER,
       p_term_id IN NUMBER,
       p_enrollment_status OUT VARCHAR2,
       p_error_message OUT VARCHAR2
   ) AS
       v_prereq_count NUMBER;
       v_prereq_satisfied NUMBER;
       v_financial_hold VARCHAR2(1);
       v_course_capacity NUMBER;
       v_current_enrollment NUMBER;
       prereq_not_met EXCEPTION;
       financial_hold_exists EXCEPTION;
       course_full EXCEPTION;
   BEGIN
       -- Check financial hold
       SELECT financial_hold INTO v_financial_hold
       FROM students WHERE student_id = p_student_id;
       
       IF v_financial_hold = 'Y' THEN
           RAISE financial_hold_exists;
       END IF;
       
       -- Check prerequisites
       SELECT COUNT(*) INTO v_prereq_count
       FROM course_prerequisites cp
       WHERE cp.course_id = p_course_id;
       
       IF v_prereq_count > 0 THEN
           SELECT COUNT(*) INTO v_prereq_satisfied
           FROM course_prerequisites cp
           WHERE cp.course_id = p_course_id
           AND EXISTS (
               SELECT 1 FROM enrollments e
               JOIN grades g ON e.enrollment_id = g.enrollment_id
               WHERE e.student_id = p_student_id
               AND e.course_id = cp.prerequisite_course_id
               AND g.letter_grade IN ('A', 'B', 'C', 'D')
           );
           
           IF v_prereq_satisfied < v_prereq_count THEN
               RAISE prereq_not_met;
           END IF;
       END IF;
       
       -- Check course capacity
       SELECT capacity INTO v_course_capacity
       FROM course_sections cs
       WHERE cs.course_id = p_course_id AND cs.term_id = p_term_id;
       
       SELECT COUNT(*) INTO v_current_enrollment
       FROM enrollments e
       WHERE e.course_id = p_course_id 
       AND e.term_id = p_term_id
       AND e.enrollment_status = 'ENROLLED';
       
       IF v_current_enrollment >= v_course_capacity THEN
           RAISE course_full;
       END IF;
       
       -- Create enrollment
       INSERT INTO enrollments (
           enrollment_id, student_id, course_id, term_id,
           enrollment_date, enrollment_status
       ) VALUES (
           enrollment_seq.NEXTVAL, p_student_id, p_course_id, p_term_id,
           SYSDATE, 'ENROLLED'
       );
       
       p_enrollment_status := 'SUCCESS';
       p_error_message := NULL;
       
       COMMIT;
       
   EXCEPTION
       WHEN financial_hold_exists THEN
           p_enrollment_status := 'FAILED';
           p_error_message := 'Student has financial hold';
       WHEN prereq_not_met THEN
           p_enrollment_status := 'FAILED';
           p_error_message := 'Prerequisites not satisfied';
       WHEN course_full THEN
           p_enrollment_status := 'FAILED';
           p_error_message := 'Course is at capacity';
       WHEN OTHERS THEN
           ROLLBACK;
           p_enrollment_status := 'ERROR';
           p_error_message := 'System error: ' || SQLERRM;
   END;
   /
   ```

2. **Functions** (minimum 5 functions):
   - GPA calculation
   - Credit hour validation
   - Tuition calculation
   - Course prerequisite checking
   - Academic standing determination

3. **Triggers** (minimum 5 triggers):
   - Audit trail maintenance
   - Business rule enforcement
   - Data validation
   - Automatic calculations
   - Status updates

#### **Day 7: Views and Security Implementation**

**Your Task**: Create comprehensive views and security:

1. **Views** (minimum 8 views):
   ```sql
   -- Example view you should create
   CREATE OR REPLACE VIEW vw_student_transcript AS
   SELECT 
       s.student_number,
       s.first_name || ' ' || s.last_name AS student_name,
       p.program_name,
       c.course_code,
       c.course_title,
       c.credit_hours,
       t.term_name,
       g.letter_grade,
       g.grade_points,
       g.quality_points,
       cs.instructor_name,
       e.enrollment_date,
       g.grade_date
   FROM students s
   JOIN programs p ON s.program_id = p.program_id
   JOIN enrollments e ON s.student_id = e.student_id
   JOIN courses c ON e.course_id = c.course_id
   JOIN terms t ON e.term_id = t.term_id
   JOIN course_sections cs ON e.course_section_id = cs.section_id
   LEFT JOIN grades g ON e.enrollment_id = g.enrollment_id
   WHERE s.enrollment_status = 'ACTIVE'
   ORDER BY s.student_number, t.term_start_date, c.course_code;
   ```

2. **Security Implementation**:
   - Role-based access control
   - Data masking for sensitive information
   - Audit trail implementation
   - User privilege management

### **Phase 3: Performance Optimization and Testing (Days 8-10)**

#### **Day 8: Performance Optimization**

**Your Task**: Implement comprehensive performance optimization:

1. **Indexing Strategy**:
   ```sql
   -- Example indexes you should create
   CREATE INDEX idx_students_email ON students(email);
   CREATE INDEX idx_enrollments_student_term ON enrollments(student_id, term_id);
   CREATE INDEX idx_grades_student_course ON grades(student_id, course_id);
   CREATE UNIQUE INDEX idx_student_number ON students(student_number);
   CREATE INDEX idx_courses_subject_code ON courses(subject_code, course_number);
   ```

2. **Query Optimization**:
   - Analyze execution plans
   - Optimize slow-running queries
   - Implement query hints where appropriate
   - Create materialized views for reporting

3. **Statistics Gathering**:
   ```sql
   -- Gather statistics for cost-based optimizer
   EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'STUDENTS');
   EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'ENROLLMENTS');
   EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'GRADES');
   ```

#### **Day 9: Comprehensive Testing**

**Your Task**: Execute thorough testing scenarios:

1. **Functional Testing**:
   - Student enrollment workflows
   - Grade entry and calculation
   - Report generation
   - Data integrity validation

2. **Performance Testing**:
   - Concurrent user simulation
   - Large dataset queries
   - Stress testing with high loads
   - Response time measurement

3. **Security Testing**:
   - Access control validation
   - SQL injection prevention
   - Data encryption verification
   - Audit trail completeness

#### **Day 10: Documentation and Deployment**

**Your Task**: Create professional documentation:

1. **Technical Documentation**:
   - Database schema documentation
   - API reference for procedures/functions
   - Performance tuning guide
   - Security implementation guide

2. **User Documentation**:
   - System user guide
   - Administrative procedures
   - Troubleshooting guide
   - Backup and recovery procedures

## 📊 Evaluation Criteria

### **Technical Excellence (60%)**

#### **Database Design (20%)**
- **Normalization**: Proper 3NF implementation with justified exceptions
- **Relationships**: Complete and accurate relationship modeling
- **Constraints**: Comprehensive business rule enforcement
- **Data Types**: Appropriate Oracle data type selection

#### **Implementation Quality (20%)**
- **PL/SQL Code**: Professional, efficient, well-documented code
- **Error Handling**: Comprehensive exception management
- **Performance**: Optimized queries and proper indexing
- **Security**: Role-based access and data protection

#### **Business Logic (20%)**
- **Completeness**: All requirements implemented
- **Accuracy**: Correct business rule implementation
- **Maintainability**: Clean, modular code structure
- **Scalability**: Design supports future growth

### **Professional Standards (40%)**

#### **Documentation (20%)**
- **Completeness**: All aspects thoroughly documented
- **Clarity**: Clear, professional writing
- **Technical Accuracy**: Correct technical details
- **Usability**: Easy to follow and implement

#### **Testing and Validation (10%)**
- **Test Coverage**: Comprehensive testing scenarios
- **Results Documentation**: Clear test results and analysis
- **Issue Resolution**: Proper handling of discovered issues
- **Performance Metrics**: Quantified performance results

#### **Project Management (10%)**
- **Timeline Adherence**: Meeting project milestones
- **Scope Management**: Appropriate feature prioritization
- **Problem Solving**: Effective issue resolution
- **Communication**: Clear progress reporting

## 🏆 Success Indicators

### **Exceptional Performance Includes**:
- **Innovation**: Creative solutions to complex problems
- **Optimization**: Superior performance characteristics
- **Scalability**: Design handles significant growth
- **Security**: Enterprise-grade security implementation
- **Documentation**: Publication-quality deliverables

### **Professional Portfolio Quality**:
- Complete, working system demonstrating all Oracle concepts
- Professional documentation suitable for enterprise use
- Demonstrated best practices throughout implementation
- Real-world complexity and business value

## 💡 Tips for Success

### **Design Phase**:
- Spend adequate time on requirements analysis
- Create detailed ERDs before implementing
- Consider future scalability in your design
- Document all design decisions and trade-offs

### **Implementation Phase**:
- Build incrementally and test frequently
- Focus on code quality and maintainability
- Implement comprehensive error handling
- Use meaningful naming conventions

### **Optimization Phase**:
- Measure performance before and after optimization
- Focus on the most impactful improvements
- Document all optimization decisions
- Test thoroughly after performance changes

### **Documentation Phase**:
- Write for your audience (technical vs. business users)
- Include practical examples and use cases
- Document installation and configuration procedures
- Create troubleshooting guides for common issues

## 🎉 Challenge Completion

Upon successful completion, you will have:

- **Complete LMS Database**: Production-ready learning management system
- **Professional Portfolio Project**: Demonstrable enterprise-level skills
- **Comprehensive Documentation**: Industry-standard deliverables
- **Advanced Oracle Expertise**: Mastery of all database development concepts
- **Problem-Solving Experience**: Real-world complexity and challenges

This challenge represents the culmination of your Oracle Database learning journey and demonstrates your readiness for senior database development roles!

---

**Ready to take on the ultimate database design challenge?** This comprehensive project will test every skill you've learned and create a portfolio piece that showcases your expertise to potential employers!
