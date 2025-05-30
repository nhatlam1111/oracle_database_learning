# Oracle Database Data Types

Understanding Oracle Database data types is fundamental to effective database design and development. Oracle provides a comprehensive set of built-in data types to store different kinds of information efficiently. This guide covers all the major data types available in Oracle Database.

## Character Data Types

### VARCHAR2(size)
- **Description**: Variable-length character data with maximum size specified
- **Storage**: 1 to 4000 bytes (32767 in PL/SQL)
- **Use Cases**: Names, descriptions, addresses, general text data
- **Example**: `VARCHAR2(100)` for storing names up to 100 characters
- **Best Practice**: Always specify size; use for variable-length text

### CHAR(size)
- **Description**: Fixed-length character data, padded with spaces
- **Storage**: 1 to 2000 bytes
- **Use Cases**: Fixed-format codes, status flags, country codes
- **Example**: `CHAR(2)` for storing state abbreviations like 'CA', 'NY'
- **Best Practice**: Use only when all values have the same length

### NVARCHAR2(size)
- **Description**: Variable-length Unicode character data
- **Storage**: 1 to 4000 bytes
- **Use Cases**: Multilingual applications, international text
- **Example**: `NVARCHAR2(200)` for storing names in various languages
- **Best Practice**: Use when supporting multiple character sets

### NCHAR(size)
- **Description**: Fixed-length Unicode character data
- **Storage**: 1 to 2000 bytes
- **Use Cases**: Fixed-length Unicode codes
- **Example**: `NCHAR(10)` for Unicode product codes
- **Best Practice**: Rarely used; prefer NVARCHAR2 for Unicode data

## Numeric Data Types

### NUMBER(precision, scale)
- **Description**: Variable-length numeric data with optional precision and scale
- **Storage**: 1 to 22 bytes
- **Precision**: Total number of significant digits (1-38)
- **Scale**: Number of digits to the right of decimal point (-84 to 127)
- **Use Cases**: Currency, calculations, measurements
- **Examples**: 
  - `NUMBER(10,2)` for currency (max 99,999,999.99)
  - `NUMBER(5)` for integer values up to 99,999
  - `NUMBER` for unlimited precision

### INTEGER
- **Description**: Synonym for NUMBER(38)
- **Storage**: Variable (1 to 22 bytes)
- **Use Cases**: Whole numbers, counters, IDs
- **Example**: `INTEGER` for primary keys
- **Best Practice**: Use for clarity when dealing with whole numbers

### FLOAT(binary_precision)
- **Description**: Floating-point number with binary precision
- **Storage**: 1 to 22 bytes
- **Use Cases**: Scientific calculations requiring floating-point arithmetic
- **Example**: `FLOAT(24)` for single precision, `FLOAT(53)` for double precision
- **Best Practice**: Use NUMBER for most business applications

### BINARY_FLOAT
- **Description**: 32-bit floating-point number (IEEE 754)
- **Storage**: 4 bytes
- **Use Cases**: Scientific computing, performance-critical calculations
- **Range**: ±1.17549E-38 to ±3.40282E+38
- **Best Practice**: Use for compatibility with other systems using IEEE standards

### BINARY_DOUBLE
- **Description**: 64-bit floating-point number (IEEE 754)
- **Storage**: 8 bytes
- **Use Cases**: High-precision scientific calculations
- **Range**: ±2.22507485850720E-308 to ±1.79769313486231E+308
- **Best Practice**: Use for high-precision floating-point calculations

## Date and Time Data Types

### DATE
- **Description**: Date and time from January 1, 4712 BC to December 31, 9999 AD
- **Storage**: 7 bytes
- **Precision**: Seconds
- **Use Cases**: Birthdays, order dates, appointment times
- **Example**: `DATE` stores both date and time components
- **Best Practice**: Default choice for most date/time needs

### TIMESTAMP(fractional_seconds_precision)
- **Description**: Date and time with fractional seconds
- **Storage**: 7 to 11 bytes
- **Precision**: 0 to 9 digits for fractional seconds (default 6)
- **Use Cases**: Audit trails, high-precision timing
- **Example**: `TIMESTAMP(3)` for millisecond precision
- **Best Practice**: Use when you need sub-second precision

### TIMESTAMP WITH TIME ZONE
- **Description**: TIMESTAMP with time zone information
- **Storage**: 13 bytes
- **Use Cases**: Global applications, scheduling across time zones
- **Example**: Stores '2023-05-15 14:30:00.000000 -07:00'
- **Best Practice**: Use for applications spanning multiple time zones

### TIMESTAMP WITH LOCAL TIME ZONE
- **Description**: TIMESTAMP normalized to database time zone
- **Storage**: 7 to 11 bytes
- **Use Cases**: Applications where all times should be in database time zone
- **Best Practice**: Use when you want automatic time zone conversion

### INTERVAL YEAR TO MONTH
- **Description**: Period of time in years and months
- **Storage**: 5 bytes
- **Use Cases**: Age calculations, subscription periods
- **Example**: `INTERVAL YEAR(4) TO MONTH` for up to 9999 years
- **Best Practice**: Use for business periods (contracts, warranties)

### INTERVAL DAY TO SECOND
- **Description**: Period of time in days, hours, minutes, seconds
- **Storage**: 11 bytes
- **Use Cases**: Duration calculations, elapsed time
- **Example**: `INTERVAL DAY(2) TO SECOND(6)` for up to 99 days with microsecond precision
- **Best Practice**: Use for precise duration measurements

## Binary Data Types

### RAW(size)
- **Description**: Variable-length binary data
- **Storage**: 1 to 2000 bytes
- **Use Cases**: Small binary objects, checksums, encrypted data
- **Example**: `RAW(16)` for storing MD5 hashes
- **Best Practice**: Use for small binary data; prefer BLOB for larger data

### LONG RAW
- **Description**: Variable-length binary data up to 2GB
- **Storage**: Up to 2GB
- **Use Cases**: Legacy binary data storage
- **Best Practice**: **Deprecated** - use BLOB instead for new applications

## Large Object (LOB) Data Types

### CLOB
- **Description**: Character Large Object for large text data
- **Storage**: Up to 128TB
- **Use Cases**: Documents, articles, large text fields
- **Example**: Storing full article content, user comments
- **Best Practice**: Use for text data larger than VARCHAR2 limits

### NCLOB
- **Description**: National Character Large Object for Unicode text
- **Storage**: Up to 128TB
- **Use Cases**: Large multilingual text documents
- **Best Practice**: Use for large Unicode text data

### BLOB
- **Description**: Binary Large Object for binary data
- **Storage**: Up to 128TB
- **Use Cases**: Images, videos, documents, audio files
- **Example**: Storing PDF files, images, multimedia content
- **Best Practice**: Primary choice for binary file storage

### BFILE
- **Description**: Binary file locator pointing to external files
- **Storage**: Directory name and filename
- **Use Cases**: Large files stored in operating system
- **Best Practice**: Use when files are managed outside the database

## Specialized Data Types

### ROWID
- **Description**: Unique identifier for table rows
- **Storage**: 10 bytes
- **Use Cases**: Fast row access, debugging
- **Example**: System-generated unique row identifier
- **Best Practice**: Rarely used directly; automatically managed by Oracle

### UROWID
- **Description**: Universal ROWID for various table types
- **Storage**: Variable
- **Use Cases**: Index-organized tables, foreign tables
- **Best Practice**: Use ROWID unless working with special table types

## JSON Data Type (Oracle 21c+)

### JSON
- **Description**: Native JSON data type with validation and optimization
- **Storage**: Variable
- **Use Cases**: JSON documents, REST APIs, modern web applications
- **Example**: Storing user preferences, configuration data
- **Best Practice**: Use for structured JSON data requiring validation

## Data Type Selection Guidelines

### For Text Data:
- **Short, variable text**: VARCHAR2
- **Fixed-length codes**: CHAR
- **Large text documents**: CLOB
- **Multilingual content**: NVARCHAR2 or NCLOB

### For Numbers:
- **Currency/Business**: NUMBER with appropriate precision
- **Counters/IDs**: INTEGER or NUMBER
- **Scientific calculations**: BINARY_FLOAT or BINARY_DOUBLE

### For Dates:
- **General date/time**: DATE
- **High precision timing**: TIMESTAMP
- **Global applications**: TIMESTAMP WITH TIME ZONE
- **Duration calculations**: INTERVAL types

### For Binary Data:
- **Small binary**: RAW
- **Large files**: BLOB
- **External files**: BFILE

## Common Data Type Conversions

Oracle provides implicit and explicit conversion between compatible data types:

```sql
-- Implicit conversions (automatic)
NUMBER ↔ VARCHAR2 (when numeric)
DATE ↔ VARCHAR2 (using default format)

-- Explicit conversions (using functions)
TO_NUMBER('123.45')
TO_DATE('2023-05-15', 'YYYY-MM-DD')
TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
```

## Best Practices Summary

1. **Choose the right size**: Don't over-allocate (e.g., VARCHAR2(4000) for a 10-character field)
2. **Use appropriate precision**: NUMBER(10,2) for currency, not NUMBER
3. **Consider Unicode needs**: Use NVARCHAR2 for international applications
4. **Prefer standard types**: Use DATE over VARCHAR2 for dates
5. **Plan for growth**: Consider future data volume when choosing LOB types
6. **Validate constraints**: Use CHECK constraints to enforce data rules
7. **Document choices**: Comment on why specific data types were chosen

Understanding these data types and their appropriate usage is crucial for designing efficient, scalable Oracle databases that accurately represent your business data.
