# Lesson 3: Basic SQL Queries and Data Types

This lesson introduces you to Oracle Database data types and fundamental SQL query operations. You'll learn about data types first (essential for creating tables), then move on to retrieving, filtering, sorting, and summarizing data using basic SQL statements.

## Learning Objectives
By the end of this lesson, you will be able to:
- Master Oracle Database's built-in data types and their appropriate usage
- Apply best practices for data type selection in database design
- Write basic SELECT statements to retrieve data from tables
- Filter data using WHERE clauses with various conditions
- Sort query results using ORDER BY
- Use aggregate functions to summarize data
- Apply built-in functions for data manipulation
- Understand data type conversion functions
- Write efficient queries following best practices

## Lesson Structure
1. **Oracle Database Data Types** ⭐ **ESSENTIAL FOUNDATION** - Master data types before creating tables
2. **SELECT Statements** - Master the foundation of data retrieval
3. **WHERE Clause and Filtering** - Learn to filter data with various conditions
4. **Sorting with ORDER BY** - Control the presentation order of results
5. **Aggregate Functions** - Summarize data with COUNT, SUM, AVG, etc.

## Prerequisites
- Completed Lesson 1 (Introduction to Databases)
- Completed Lesson 2 (Environment Setup)
- Sample database created and accessible
- SQL client configured and connected

## Estimated Time
4-5 hours

## Files in This Lesson
- `1-oracle-datatypes.md` ⭐ **NEW & COMPREHENSIVE** - Complete guide to Oracle data types
- `2-select-statements.md` - Complete guide to SELECT statements and basic syntax
- `3-where-clause-filtering.md` - Data filtering techniques and conditions
- `4-sorting-order-by.md` - Sorting and organizing query results
- `5-aggregate-functions.md` - Data summarization and aggregate operations

## Practical Examples
- `../../src/basic-queries/oracle-datatypes-examples.sql` - Comprehensive data type examples
- `../../src/basic-queries/select-statements.sql` - SELECT query examples
- `../../src/basic-queries/where-filtering.sql` - WHERE clause examples
- `../../src/basic-queries/sorting-examples.sql` - ORDER BY examples
- `../../src/basic-queries/aggregate-examples.sql` - Aggregate function examples

## Sample Data Required
This lesson uses the HR and SALES schemas created in Lesson 2. Ensure you have:
- HR schema: employees, departments, jobs, locations tables
- SALES schema: customers, products, orders, order_details tables

## Next Steps
After completing this lesson, you'll have solid foundation in Oracle data types and basic SQL queries, and be ready to proceed to Lesson 4 for intermediate SQL concepts including joins and subqueries.

## Detailed Content Overview

### 1. Oracle Database Data Types ⭐ **START HERE**
**File:** `1-oracle-datatypes.md`

This comprehensive guide covers all Oracle built-in data types:

#### Character Data Types
- **VARCHAR2(size)** - Variable-length character data (most common)
- **CHAR(size)** - Fixed-length character data
- **NVARCHAR2(size)** - Variable-length Unicode character data
- **NCHAR(size)** - Fixed-length Unicode character data

#### Numeric Data Types
- **NUMBER(precision, scale)** - Variable-length numeric data
- **INTEGER** - Whole numbers
- **FLOAT(binary_precision)** - Floating-point numbers
- **BINARY_FLOAT** - 32-bit IEEE 754 floating-point
- **BINARY_DOUBLE** - 64-bit IEEE 754 floating-point

#### Date and Time Data Types
- **DATE** - Date and time (most common)
- **TIMESTAMP(fractional_seconds_precision)** - Date and time with fractional seconds
- **TIMESTAMP WITH TIME ZONE** - TIMESTAMP with time zone information
- **TIMESTAMP WITH LOCAL TIME ZONE** - TIMESTAMP normalized to database time zone
- **INTERVAL YEAR TO MONTH** - Period in years and months
- **INTERVAL DAY TO SECOND** - Period in days, hours, minutes, seconds

#### Binary Data Types
- **RAW(size)** - Variable-length binary data
- **LONG RAW** - Variable-length binary data up to 2GB (deprecated)

#### Large Object (LOB) Data Types
- **CLOB** - Character Large Object for large text data
- **NCLOB** - National Character Large Object for Unicode text
- **BLOB** - Binary Large Object for binary data
- **BFILE** - Binary file locator pointing to external files

#### Specialized Data Types
- **ROWID** - Unique identifier for table rows
- **UROWID** - Universal ROWID for various table types
- **JSON** - Native JSON data type (Oracle 21c+)

#### Key Learning Points
- **Data Type Selection Guidelines** - How to choose the right type
- **Storage Requirements** - Understanding space usage
- **Performance Considerations** - Impact on query performance
- **Best Practices** - Industry standards and recommendations
- **Common Conversions** - Converting between data types

### 2. Practical SQL Examples
**File:** `../../src/basic-queries/oracle-datatypes-examples.sql`

Hands-on examples including:
- Table creation with appropriate data types
- Data insertion examples
- Constraint definitions and validation
- Performance optimization techniques
- Common conversion functions
- Best practices demonstrations
