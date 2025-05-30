# Lesson 4: Intermediate SQL Concepts

Welcome to Lesson 4! This lesson covers intermediate SQL concepts that will significantly expand your ability to work with relational databases. You'll learn how to combine data from multiple tables using joins and how to write sophisticated queries using subqueries.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand relational database principles and table relationships
- Write INNER JOINs to combine related data from multiple tables
- Use OUTER JOINs (LEFT, RIGHT, FULL) to include unmatched records
- Apply CROSS JOINs and SELF JOINs for special scenarios
- Write and optimize subqueries in SELECT, WHERE, and FROM clauses
- Use correlated subqueries for row-by-row processing
- Apply EXISTS and NOT EXISTS for existence checking
- Combine joins and subqueries in complex queries

## Prerequisites

Before starting this lesson, ensure you have:
- Completed Lessons 1-3 (Database fundamentals and basic SQL)
- Strong understanding of SELECT, WHERE, ORDER BY, and aggregate functions
- Access to Oracle Database with HR and SALES sample schemas
- Familiarity with primary keys and foreign key relationships

## Lesson Structure

### 1. Table Relationships and Join Fundamentals (`1-table-relationships.md`)
- Understanding primary and foreign keys
- One-to-many, many-to-many, and one-to-one relationships
- Referential integrity concepts
- Introduction to JOIN syntax

**Practice File**: `src/intermediate/table-relationships.sql`

### 2. INNER JOINs (`2-inner-joins.md`)
- Basic INNER JOIN syntax and mechanics
- Joining two and multiple tables
- Using table aliases for readability
- Common join conditions and patterns
- Performance considerations

**Practice File**: `src/intermediate/inner-joins.sql`

### 3. OUTER JOINs (`3-outer-joins.md`)
- LEFT OUTER JOIN for including unmatched left table records
- RIGHT OUTER JOIN for including unmatched right table records
- FULL OUTER JOIN for including all unmatched records
- Handling NULL values in outer joins
- Business scenarios for each join type

**Practice File**: `src/intermediate/outer-joins.sql`

### 4. Advanced Join Types (`4-advanced-joins.md`)
- CROSS JOIN for Cartesian products
- SELF JOIN for hierarchical data
- Non-equi joins with different operators
- Multiple join conditions
- Join optimization techniques

**Practice File**: `src/intermediate/advanced-joins.sql`

### 5. Subquery Fundamentals (`5-subqueries.md`)
- Single-row and multi-row subqueries
- Subqueries in SELECT, WHERE, and FROM clauses
- Scalar subqueries for calculations
- Using subqueries with comparison operators
- Common subquery patterns

**Practice File**: `src/intermediate/subqueries.sql`

### 6. Correlated Subqueries and EXISTS (`6-correlated-subqueries.md`)
- Understanding correlated vs non-correlated subqueries
- EXISTS and NOT EXISTS operators
- Performance implications of correlated subqueries
- Converting EXISTS to joins and vice versa
- Advanced correlation techniques

**Practice File**: `src/intermediate/correlated-subqueries.sql`

## Sample Data Reference

This lesson extensively uses relationships between tables in the HR and SALES schemas:

### HR Schema Relationships:
- **EMPLOYEES** ↔ **DEPARTMENTS** (via department_id)
- **EMPLOYEES** ↔ **JOBS** (via job_id)
- **EMPLOYEES** ↔ **EMPLOYEES** (manager_id self-reference)
- **DEPARTMENTS** ↔ **LOCATIONS** (via location_id)
- **LOCATIONS** ↔ **COUNTRIES** (via country_id)

### SALES Schema Relationships:
- **ORDERS** ↔ **CUSTOMERS** (via customer_id)
- **ORDER_ITEMS** ↔ **ORDERS** (via order_id)
- **ORDER_ITEMS** ↔ **PRODUCTS** (via product_id)

## Learning Path

1. **Start with Theory**: Read each markdown file to understand concepts
2. **Practice Step by Step**: Work through practice files in order
3. **Build Complexity**: Start with simple 2-table joins, progress to complex multi-table queries
4. **Real-world Application**: Apply concepts to business scenarios
5. **Performance Awareness**: Learn to write efficient queries

## Key Concepts to Master

### Join Types:
- **INNER JOIN**: Returns only matching records
- **LEFT JOIN**: Returns all left table records + matches
- **RIGHT JOIN**: Returns all right table records + matches
- **FULL JOIN**: Returns all records from both tables
- **CROSS JOIN**: Cartesian product of both tables
- **SELF JOIN**: Table joined with itself

### Subquery Types:
- **Scalar Subqueries**: Return single value
- **Row Subqueries**: Return single row with multiple columns
- **Table Subqueries**: Return multiple rows and columns
- **Correlated Subqueries**: Reference outer query columns
- **EXISTS Subqueries**: Test for existence of rows

## Common Use Cases

### Business Scenarios for Joins:
- Employee and department information reports
- Customer order history analysis
- Product sales performance tracking
- Organizational hierarchy reporting
- Geographic sales analysis

### Business Scenarios for Subqueries:
- Finding above-average performers
- Identifying customers with no recent orders
- Product categories with highest sales
- Employees in departments with specific criteria
- Complex filtering based on aggregated data

## Performance Tips

1. **Use appropriate indexes** on join columns
2. **Filter early** with WHERE clauses before joins
3. **Choose the right join type** for your business logic
4. **Consider query execution plans** for optimization
5. **Use EXISTS instead of IN** for better performance with NULLs
6. **Avoid unnecessary subqueries** that can be converted to joins

## Common Mistakes to Avoid

- Forgetting join conditions (resulting in Cartesian products)
- Using wrong join types for business requirements
- Not handling NULL values in outer joins
- Writing inefficient correlated subqueries
- Mixing join syntax styles (ANSI vs Oracle traditional)
- Not considering performance implications of complex queries

## Tools and Techniques

- **EXPLAIN PLAN** for analyzing query performance
- **Table aliases** for readability and avoiding ambiguity
- **Proper indentation** for complex query readability
- **Comments** to document complex business logic
- **Incremental building** of complex queries

## Estimated Time

4-6 hours total:
- Theory reading: 1.5 hours
- Practice exercises: 2.5 hours
- Complex scenarios: 1-2 hours

## Assessment

After completing this lesson, you should be able to:
- Write joins to combine data from 3+ tables
- Choose appropriate join types for business scenarios
- Use subqueries to solve complex filtering problems
- Optimize queries for better performance
- Handle hierarchical data with self-joins
- Combine joins and subqueries in sophisticated queries

## Next Steps

After mastering this lesson, you'll be ready for:
- **Lesson 5**: Advanced SQL Techniques (Stored Procedures, Functions, Triggers)
- **Lesson 6**: Database Design and Optimization
- **Real-world Projects**: Building complete database applications

---

**Important Note**: This lesson significantly increases in complexity. Take your time with each concept and practice extensively before moving to the next topic. The concepts learned here form the foundation for advanced database development.
