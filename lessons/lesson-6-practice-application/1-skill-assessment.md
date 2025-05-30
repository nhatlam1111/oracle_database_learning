# Skill Assessment and Gap Analysis

This comprehensive assessment evaluates your Oracle Database knowledge across all areas covered in Lessons 1-5. Use this to identify strengths and areas for improvement.

## 🎯 Assessment Overview

**Time Required**: 3-4 hours
**Format**: Hands-on practical exercises
**Scoring**: Each section weighted by complexity
**Goal**: Identify learning gaps and create improvement plan

## 📊 Assessment Structure

### **Section 1: Basic SQL Operations (20 points)**
**Skills Tested**: SELECT, INSERT, UPDATE, DELETE, basic filtering

### **Section 2: Advanced Queries (25 points)**  
**Skills Tested**: JOINs, subqueries, aggregate functions, window functions

### **Section 3: Database Design (20 points)**
**Skills Tested**: Table design, relationships, normalization, constraints

### **Section 4: PL/SQL Programming (25 points)**
**Skills Tested**: Procedures, functions, triggers, error handling

### **Section 5: Performance & Optimization (10 points)**
**Skills Tested**: Query optimization, indexing, performance analysis

## 🔍 Detailed Assessment Questions

### **Section 1: Basic SQL Operations (20 points)**

#### **Question 1.1 (5 points)**
Write a query to find all employees hired in the last 6 months with salary greater than 50,000, ordered by hire date.

**Expected Skills**:
- DATE functions and arithmetic
- WHERE clause with multiple conditions
- ORDER BY clause

#### **Question 1.2 (5 points)**
Update all employees in the 'IT' department to increase their salary by 15%.

**Expected Skills**:
- UPDATE with JOIN or subquery
- Percentage calculations
- Department filtering

#### **Question 1.3 (5 points)**
Insert a new customer record with proper validation for required fields.

**Expected Skills**:
- INSERT statements
- Data validation concepts
- Understanding of constraints

#### **Question 1.4 (5 points)**
Delete all orders older than 2 years while maintaining referential integrity.

**Expected Skills**:
- DELETE with date conditions
- Understanding of foreign key constraints
- Cascading delete concepts

### **Section 2: Advanced Queries (25 points)**

#### **Question 2.1 (8 points)**
Create a query showing monthly sales totals with year-over-year comparison.

**Expected Skills**:
- Aggregate functions (SUM, GROUP BY)
- Date functions (EXTRACT, TO_CHAR)
- Window functions (LAG, LEAD)
- Self-joins or CTEs

#### **Question 2.2 (7 points)**
Find customers who have placed orders in every month of the current year.

**Expected Skills**:
- Correlated subqueries
- COUNT and DISTINCT
- Date range filtering
- HAVING clause

#### **Question 2.3 (5 points)**
List products that have never been ordered.

**Expected Skills**:
- LEFT JOIN with NULL filtering
- NOT EXISTS subquery
- Alternative approaches comparison

#### **Question 2.4 (5 points)**
Create a ranking of employees by department based on performance metrics.

**Expected Skills**:
- Window functions (RANK, ROW_NUMBER)
- PARTITION BY clause
- Complex ordering

### **Section 3: Database Design (20 points)**

#### **Question 3.1 (10 points)**
Design a normalized database schema for a library management system.

**Requirements**:
- Books, Authors, Publishers, Members, Loans
- Many-to-many relationships
- Proper normalization (3NF minimum)
- Appropriate constraints

**Expected Skills**:
- Entity-relationship modeling
- Normalization principles
- Primary and foreign key design
- Constraint implementation

#### **Question 3.2 (10 points)**
Analyze and improve a poorly designed table structure.

**Given**: Denormalized table with redundancy and anomalies
**Task**: Redesign with proper normalization

**Expected Skills**:
- Identifying design problems
- Normalization techniques
- Data migration strategies
- Constraint definition

### **Section 4: PL/SQL Programming (25 points)**

#### **Question 4.1 (8 points)**
Create a stored procedure to process monthly payroll.

**Requirements**:
- Calculate salary, taxes, and deductions
- Update employee records
- Log all transactions
- Handle errors appropriately

**Expected Skills**:
- Procedure creation with parameters
- Complex business logic
- Transaction management
- Error handling

#### **Question 4.2 (7 points)**
Write a function to calculate customer lifetime value.

**Requirements**:
- Sum all customer purchases
- Apply business rules and discounts
- Return calculated value
- Handle edge cases

**Expected Skills**:
- Function creation and return values
- Complex calculations
- Data aggregation
- Exception handling

#### **Question 4.3 (5 points)**
Create a trigger to maintain audit trail for sensitive data changes.

**Requirements**:
- Track all changes to employee salary
- Store old and new values
- Include timestamp and user information
- Ensure data integrity

**Expected Skills**:
- Trigger creation (BEFORE/AFTER)
- OLD and NEW value references
- Audit table design
- System function usage

#### **Question 4.4 (5 points)**
Implement error handling for a complex business process.

**Requirements**:
- Custom exception definitions
- Proper exception propagation
- Logging and notification
- Rollback strategies

**Expected Skills**:
- Exception handling blocks
- Custom exception creation
- RAISE and RAISE_APPLICATION_ERROR
- Transaction control

### **Section 5: Performance & Optimization (10 points)**

#### **Question 5.1 (5 points)**
Optimize a slow-running query by analyzing execution plan.

**Given**: Poorly performing query
**Task**: Identify bottlenecks and optimize

**Expected Skills**:
- EXPLAIN PLAN analysis
- Index strategy
- Query rewriting techniques
- Performance measurement

#### **Question 5.2 (5 points)**
Design an indexing strategy for a high-volume transaction table.

**Requirements**:
- Consider different query patterns
- Balance read vs. write performance
- Include composite indexes
- Document strategy rationale

**Expected Skills**:
- Index types and usage
- Performance trade-offs
- Query pattern analysis
- Index maintenance considerations

## 📈 Scoring Guidelines

### **Scoring Levels**:
- **Excellent (90-100%)**: Professional-level competency
- **Good (80-89%)**: Strong foundation with minor gaps
- **Adequate (70-79%)**: Basic competency with some weak areas
- **Needs Improvement (60-69%)**: Significant gaps requiring focused study
- **Inadequate (<60%)**: Major revision of previous lessons needed

### **Score Interpretation**:

#### **90-100% (Excellent)**
- Ready for advanced Oracle topics
- Consider Oracle certification
- Excellent foundation for professional work

#### **80-89% (Good)**
- Strong overall knowledge
- Focus on identified weak areas
- Good preparation for real-world projects

#### **70-79% (Adequate)**
- Solid foundation but needs reinforcement
- Review specific topics identified as weak
- Practice more complex scenarios

#### **60-69% (Needs Improvement)**
- Review previous lessons thoroughly
- Focus on fundamental concepts
- Additional practice exercises needed

#### **<60% (Inadequate)**
- Restart from appropriate lesson level
- Consider additional learning resources
- May need instructor-led training

## 🎯 Gap Analysis and Improvement Plan

### **Step 1: Identify Weak Areas**
For each section where you scored below 80%:
1. List specific concepts you struggled with
2. Identify related topics that need review
3. Find relevant practice exercises

### **Step 2: Create Study Plan**
Based on your weak areas:
1. Prioritize topics by importance and difficulty
2. Allocate study time for each topic
3. Set measurable improvement goals
4. Schedule reassessment dates

### **Step 3: Focused Practice**
For each weak area:
1. Review relevant lesson materials
2. Complete additional practice exercises
3. Seek help from community or mentors
4. Practice until confident

### **Step 4: Reassessment**
After focused study:
1. Retake relevant assessment sections
2. Measure improvement
3. Adjust study plan as needed
4. Continue until all areas are strong

## 📚 Recommended Resources by Weak Area

### **Basic SQL Operations**
- Review Lesson 3: Basic SQL Queries
- Practice with `src/basic-queries/` exercises
- Oracle SQL Developer tutorials
- Online SQL practice platforms

### **Advanced Queries**
- Review Lesson 4: Intermediate SQL
- Focus on JOIN and subquery exercises
- Practice with complex datasets
- Study execution plans

### **Database Design**
- Review normalization principles
- Practice with ER diagrams
- Study real-world database schemas
- Learn design pattern best practices

### **PL/SQL Programming**
- Review Lesson 5: Advanced SQL
- Practice with stored procedures
- Study Oracle PL/SQL documentation
- Work through error handling scenarios

### **Performance & Optimization**
- Study Oracle performance tuning guides
- Practice with EXPLAIN PLAN
- Learn about Oracle optimizer
- Experiment with indexing strategies

## ✅ Next Steps After Assessment

1. **Complete Gap Analysis**: Document all areas needing improvement
2. **Create Study Schedule**: Plan focused learning time
3. **Begin Improvement Work**: Start with highest priority gaps
4. **Track Progress**: Regular mini-assessments
5. **Proceed to Projects**: Once assessment shows 80%+ overall

Remember: This assessment is designed to help you succeed in real-world Oracle Database work. Take time to thoroughly understand any concepts you struggle with—it will pay dividends in your professional development!
