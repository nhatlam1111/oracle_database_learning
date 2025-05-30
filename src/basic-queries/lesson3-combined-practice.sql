-- Lesson 3: Combined Practice - Basic SQL Queries
-- Oracle Database Learning Project
-- File: lesson3-combined-practice.sql

-- This file combines all concepts from Lesson 3: SELECT, WHERE, ORDER BY, and Aggregates
-- Complete these exercises to test your understanding of basic SQL queries

-- =============================================================================
-- SETUP AND VERIFICATION
-- =============================================================================

-- Verify your sample data is available
SELECT 'HR Employees: ' || COUNT(*) AS hr_data FROM hr.employees;
SELECT 'HR Departments: ' || COUNT(*) AS hr_dept FROM hr.departments;
SELECT 'Sales Customers: ' || COUNT(*) AS sales_customers FROM sales.customers;
SELECT 'Sales Products: ' || COUNT(*) AS sales_products FROM sales.products;
SELECT 'Sales Orders: ' || COUNT(*) AS sales_orders FROM sales.orders;

-- =============================================================================
-- BEGINNER LEVEL EXERCISES
-- =============================================================================

-- Exercise B1: Employee Directory
-- Create a formatted employee directory showing:
-- - Employee ID
-- - Full name (Last, First format)
-- - Email address (lowercase)
-- - Department ID
-- - Hire date formatted as 'DD-MON-YYYY'
-- Sort by department, then by last name

-- Your solution here:


-- Exercise B2: Product Catalog
-- Create a product catalog showing:
-- - Product name (proper case)
-- - Category (uppercase)
-- - Price with currency format ($999.99)
-- - Stock status (In Stock/Low Stock/Out of Stock based on quantity)
-- Filter to show only products with price between $50 and $500
-- Sort by category, then by price descending

-- Your solution here:


-- Exercise B3: Department Statistics
-- Show basic statistics for each department:
-- - Department ID
-- - Number of employees
-- - Average salary (rounded to 2 decimal places)
-- - Total payroll
-- Only include departments with at least 2 employees
-- Sort by average salary descending

-- Your solution here:


-- =============================================================================
-- INTERMEDIATE LEVEL EXERCISES
-- =============================================================================

-- Exercise I1: Comprehensive Employee Analysis
-- Create a detailed employee analysis showing:
-- - Employee ID and full name
-- - Job title and department ID
-- - Years of service (calculated from hire date)
-- - Salary grade (Entry <5000, Mid 5000-10000, Senior 10000-15000, Executive >15000)
-- - Total compensation (salary + commission, handle NULLs)
-- - Performance indicator (Above/Below average based on department average)
-- Filter: Only employees hired after 2005
-- Sort: By department, then by total compensation descending

-- Your solution here:


-- Exercise I2: Sales Performance Dashboard
-- Create a sales dashboard showing:
-- - Month-Year (e.g., 'JAN-2024')
-- - Number of orders
-- - Total revenue
-- - Average order value
-- - Number of unique customers
-- - Percentage of orders completed vs total
-- Filter: Only include data from 2024
-- Sort: By month chronologically

-- Your solution here:


-- Exercise I3: Product Category Performance
-- Analyze product performance by category:
-- - Category name
-- - Total products in category
-- - Price range (min - max format)
-- - Average price
-- - Total inventory value (sum of price * stock_quantity)
-- - Products by price tier counts (Budget/Mid/Premium)
-- - Category ranking by inventory value
-- Sort by inventory value descending

-- Your solution here:


-- =============================================================================
-- ADVANCED LEVEL EXERCISES
-- =============================================================================

-- Exercise A1: Customer Segmentation Analysis
-- Create a comprehensive customer analysis:
-- - Customer segments based on order history:
--   * VIP: >$5000 total orders
--   * Regular: $1000-$5000 total orders  
--   * New: <$1000 total orders
-- - For each segment show:
--   * Number of customers
--   * Total revenue generated
--   * Average revenue per customer
--   * Geographic distribution (top 3 countries)
--   * Average order frequency
-- Sort by total revenue descending

-- Your solution here:


-- Exercise A2: Employee Career Progression Analysis
-- Analyze employee progression patterns:
-- - Job families (group by job prefix: AD, IT, SA, etc.)
-- - For each job family show:
--   * Number of employees
--   * Salary distribution (min, max, avg, median)
--   * Tenure distribution (avg years of service)
--   * Commission structure analysis
--   * Department spread
-- Include year-over-year hiring trends
-- Sort by average salary descending

-- Your solution here:


-- Exercise A3: Business Intelligence Report
-- Create a comprehensive business report combining multiple schemas:
-- - Monthly business metrics:
--   * Employee costs (total salaries by month hired)
--   * Sales revenue (orders by month)
--   * Product performance (units sold vs inventory)
--   * Customer acquisition (new customers by month)
--   * Regional performance (sales by customer country)
-- - Calculate month-over-month growth rates
-- - Identify trends and patterns
-- - Include executive summary statistics

-- Your solution here:


-- =============================================================================
-- REAL-WORLD SCENARIO EXERCISES
-- =============================================================================

-- Exercise RW1: HR Audit Report
-- Your company needs an HR audit report. Create queries to show:
-- 
-- 1. Salary equity analysis:
--    - Average salary by job title and gender (if available)
--    - Identify potential pay gaps
--    - Show salary distribution percentiles
--
-- 2. Retention analysis:
--    - Employee tenure by department
--    - Turnover risk indicators (long tenure, low pay)
--    - Hiring trends by year and quarter
--
-- 3. Commission effectiveness:
--    - Performance of commission vs non-commission roles
--    - Commission structure analysis
--    - Revenue impact assessment

-- Your solution here:


-- Exercise RW2: Sales Performance Review
-- Create a quarterly sales review including:
--
-- 1. Revenue analysis:
--    - Quarterly revenue trends
--    - Product category performance
--    - Geographic revenue distribution
--    - Seasonal patterns identification
--
-- 2. Customer analysis:
--    - Customer lifetime value segments
--    - Purchase frequency patterns
--    - Customer acquisition costs
--    - Retention rates by segment
--
-- 3. Product analysis:
--    - Best and worst performing products
--    - Inventory turnover rates
--    - Pricing optimization opportunities
--    - Category profitability analysis

-- Your solution here:


-- Exercise RW3: Operational Dashboard
-- Design an operational dashboard with key metrics:
--
-- 1. Daily operational metrics:
--    - Orders processed vs capacity
--    - Revenue per employee
--    - Customer service load
--    - Inventory status alerts
--
-- 2. Weekly trends:
--    - Sales velocity
--    - Employee productivity
--    - Customer satisfaction proxies
--    - Supply chain efficiency
--
-- 3. Exception reporting:
--    - Unusual patterns detection
--    - Performance outliers
--    - Risk indicators
--    - Opportunity identification

-- Your solution here:


-- =============================================================================
-- CHALLENGE EXERCISES
-- =============================================================================

-- Challenge C1: Dynamic Business Rules
-- Create queries that implement complex business rules:
-- - Employee bonus calculation based on performance, tenure, and department
-- - Customer pricing tiers with volume discounts
-- - Product recommendation engine based on purchase patterns
-- - Territory assignment optimization

-- Your solution here:


-- Challenge C2: Advanced Analytics
-- Implement advanced analytical queries:
-- - Moving averages for sales trends
-- - Cohort analysis for customer retention
-- - Statistical analysis for salary equity
-- - Forecasting models using historical data

-- Your solution here:


-- Challenge C3: Data Quality Assessment
-- Create comprehensive data quality checks:
-- - Identify missing or inconsistent data
-- - Find duplicate records
-- - Validate business rule compliance
-- - Generate data quality scorecards

-- Your solution here:


-- =============================================================================
-- VALIDATION QUERIES
-- =============================================================================

-- Use these queries to validate your exercise results

-- Check basic statistics
SELECT 
    'Total Employees' AS metric,
    COUNT(*) AS value
FROM hr.employees
UNION ALL
SELECT 
    'Departments with Employees',
    COUNT(DISTINCT department_id)
FROM hr.employees
UNION ALL
SELECT 
    'Total Products',
    COUNT(*)
FROM sales.products
UNION ALL
SELECT 
    'Total Customers',
    COUNT(*)
FROM sales.customers
UNION ALL
SELECT 
    'Total Orders',
    COUNT(*)
FROM sales.orders;

-- Check data ranges
SELECT 
    'Salary Range' AS metric,
    MIN(salary) || ' - ' || MAX(salary) AS value
FROM hr.employees
UNION ALL
SELECT 
    'Price Range',
    MIN(price) || ' - ' || MAX(price)
FROM sales.products
UNION ALL
SELECT 
    'Order Date Range',
    MIN(order_date) || ' - ' || MAX(order_date)
FROM sales.orders;

-- =============================================================================
-- PERFORMANCE TESTING
-- =============================================================================

-- Test query performance with EXPLAIN PLAN
-- Uncomment and run these to analyze query execution plans

-- EXPLAIN PLAN FOR
-- SELECT * FROM hr.employees WHERE department_id = 60;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- =============================================================================
-- LEARNING REFLECTION
-- =============================================================================

-- After completing these exercises, you should be able to:
-- ✓ Write complex SELECT statements with multiple columns and calculations
-- ✓ Filter data using various WHERE clause conditions
-- ✓ Sort results using single and multiple column ORDER BY
-- ✓ Use aggregate functions to summarize data
-- ✓ Group data and filter groups with HAVING
-- ✓ Combine multiple concepts in complex business queries
-- ✓ Handle NULL values appropriately
-- ✓ Format output for business presentation
-- ✓ Optimize queries for performance

-- Next steps:
-- - Proceed to Lesson 4: Intermediate SQL Concepts (Joins and Subqueries)
-- - Practice with larger datasets
-- - Learn about query optimization techniques
-- - Explore Oracle-specific features and functions

-- =============================================================================
-- ADDITIONAL RESOURCES
-- =============================================================================

-- Oracle SQL Reference for functions:
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/

-- SQL Best Practices:
-- - Always specify column names instead of SELECT *
-- - Use appropriate data types in comparisons
-- - Handle NULL values explicitly
-- - Use indexes on frequently filtered/sorted columns
-- - Test queries with sample data before production use

-- =============================================================================
-- END OF LESSON 3 COMBINED PRACTICE
-- =============================================================================
