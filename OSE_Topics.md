### Restricting and Sorting Data

- Limit the rows that are retrieved by a query
- Sort the rows that are retrieved by a query
- Use substitution variables
- Use the SQL row limiting clause
- Create queries using the PIVOT and UNPIVOT clause
- Use pattern matching to recognize patterns across multiple rows in a table


### Using Single-Row Functions to Customize Output

- Describe various types of functions that are available in SQL
- Use character, number, and date and analytical (PERCENTILE_CONT, STDDEV, LAG, LEAD) functions in SELECT statements
- Use conversion functions


### Reporting Aggregated Data Using the Group Functions

- Identify the available group functions
- Use group functions
- Group data by using the GROUP BY clause
- Include or exclude grouped rows by using the HAVING clause


### Displaying Data from Multiple Tables

- Use equijoins and nonequijoins
- Use a self-join
- Use outer joins
- Generate a Cartesian product of all rows from two or more tables
- Use the cross_outer_apply_clause


### Using Subqueries to Solve Queries

- Use subqueries
- List the types of subqueries
- Use single-row and multiple-row subqueries
- Create a lateral inline view in a query


### Using the Set Operators(UNION, MINUS, INTERECT, UNION ALL)

- Explain set operators
- Use a set operator to combine multiple queries into a single query
- Control the order of rows returned


### Manipulating Data

- Describe the DML statements
- Insert rows into a table
- Update rows in a table
- Delete rows from a table
- Control transactions


### Using DDL Statements to Create and Manage Tables

- Categorize the main database objects
- Review the table structure
- Describe the data types that are available for columns
- Create tables
- Create constraints for tables
- Describe how schema objects work
- Truncate tables, and recursively truncate child tables
- Use 12c enhancements to the DEFAULT clause, invisible columns, virtual columns and identity columns in table creation/alteration


### Creating Other Schema Objects

- Create simple and complex views with visible/invisible columns
- Retrieve data from views
- Create, maintain and use sequences
- Create private and public synonyms


### Managing Objects with Data Dictionary Views

- Query various data dictionary views


### Controlling User Access

- Differentiate system privileges from object privileges
- Grant privileges on tables and on a user
- View privileges in the data dictionary
- Grant roles
- Distinguish between privileges and roles


### Managing Schema Objects

= Manage constraints
- Create and maintain indexes including invisible indexes and multiple indexes on the same columns
- Create indexes using the CREATE TABLE statement
- Create function-based indexes
- Drop columns and set column UNUSED
- Perform flashback operations
- Create and use external tables


### Manipulating Large Data Sets

- Manipulate data using subqueries
- Describe the features of multitable INSERTs
- Use multitable inserts
- Unconditional INSERT
- Pivoting INSERT
- Conditional ALL INSERT
- Conditional FIRST INSERT
- Merge rows in a table
- Track the changes to data over a period of time
- Use explicit default values in INSERT and UPDATE statements


### Generating Reports by Grouping Related Data

- Use the ROLLUP operation to produce subtotal values
- Use the CUBE operation to produce crosstabulation values
- Use the GROUPING function to identify the row values created by ROLLUP or CUBE
- Use GROUPING SETS to produce a single result set

### Managing Data in Different Time Zones

- Use various datetime functions
  - TZ_OFFSET
  - FROM_TZ
  - TO_TIMESTAMP
  - TO_TIMESTAMP_TZ
  - TO_YMINTERVAL
  - TO_DSINTERVAL
  - CURRENT_DATE
  - CURRENT_TIMESTAMP
  - LOCALTIMESTAMP
  - DBTIMEZONE
  - SESSIONTIMEZONE
  - EXTRACT
  
  
###Retrieving Data Using Subqueries

- Use multiple-column subqueries
- Use scalar subqueries
- Use correlated subqueries
- Update and delete rows using correlated subqueries
- Use the EXISTS and NOT EXISTS operators
- Use the WITH clause


### Hierarchical Retrieval

- Interpret the concept of a hierarchical query
- Create a tree-structured report
- Format hierarchical data
- Exclude branches from the tree structure


### Regular Expression Support

- Use meta Characters
- Use regular expression functions to search, match and replace
- Use replacing patterns
- Use regular expressions and check constraints
