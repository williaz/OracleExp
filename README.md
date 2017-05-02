[Oracle 12c SQL Language Reference](https://docs.oracle.com/database/121/SQLRF/toc.htm)

## 1. SELECT
- query, subquery
- selection(row), projection(column), joining(tables)
- 2 pseudocolumns exist for all SQL statement: **ROWNUM**(return order), **ROWID**(row address)
- dual
- asterisk excludes pseduo-col
- **prefix the asterisk**
- schema objecrts: table, view, trigger, index, sequence, synonyms, constraints
- non-schema obj: directory, role, users, rollback segments, tablespace

## 2. WHERE
- DISTINCT/UNQIUE: no LOB
- =, <, >, <=, >=, <>, !=, ^=, IN(set), BETWEEN val1 AND val2, LIKE, IS NULL, IS NOT NULL
- BETWEEN: **inclusive**
- % ( >=0 ); _ ( 1 )
- column alias cannot be used in WHERE, but can in ORDER By as the engine parse order
- AND, OR, NOT
- NOT: the only practical way to reverse BETWEEN, IN, IS NULL, LIKE
- ORDER BY: always be last clause; no LONG or LOB; leftmore provide initial sort order; either exp, alias, position number; each need own DESC
- 1Wb
- NULL: inf high value -> NULL LAST/FIRST
- FETCH FIRST: limit the number of rows returned; WITH TIES(include equal ones)
```sql
FETCH FIRST 5 ROWS ONLY
FETCH FIRST 25 PERCENT ROWS ONLY
```
- OFFSET: skip number of rows
- FETCH FIRST/OFFSET take place after ORDER BY
- **PIVOT**: aggregated col cannot appear in the result set, include other col in select list would breek out the result set by it
- PIVOT XML: returns output in XML format, IN clause must contain a subquery or ANY.
- *PIVOT value FOR fieldAsCol IN set*
```sql
SELECT * 
FROM (SELECT depart, id, arrive FROM flight_v)                          -- col need for pivot, or col to break down the result set
PIVOT (COUNT(id) AS num                                                 -- as values
       FOR (depart) IN ('Miami'as m, 'Atlanta' as a, 'Charlotte' as c)  -- col name
      );                                                                -- return 'Miami'_num, ....
```
- **UNPIVOT**: converts column data into seperate rows, values unchanged
```sql
SELECT * FROM view_above
UNPIVOT (nums                         -- new col
         FOR city IN (m_num, a_num, c_num));   -- the pivot cols to values of the new col
```
- **MATCH_RECOGNIZE**
- PARTITION BY: group
- ORDER BY: must
- MEASURES: column output for each match; MATCH_NUMBER()-ROWNUM of matched; CLASSIFIER()- show pattern varible applied(ALL ROW)
- ONE/ALL ROW PER MATCH
- DEFINE: define pattern variables
- PATTERN()
- AFTER MATCH SKIP TO NEXT ROW: search continue after the start of matched
- AFTER MATCH SKIP TO (LAST)/FIRST variable: last/first row related to the variable
- AFTER MATCH SKIP PAST LASTT ROW: def, search continues after the last row in matched
```sql
-- "V" reverse pattern
SELECT *
FROM stock_data_tb
MATCH_RECOGNIZE
(
   ORDER BY market_date
   MEASURES STRT.markeet_date AS start_date,
            FINAL LAST(DOWN.market_date) AS bottom_date,
            FINAL LAST(UP.market_date) AS end_date
   ONE ROW PER MATCH
   AFTER MATCH SKIP TO LAST UP
   PATTERN (STRT DOWN+ UP+)
   DEFINE
       DOWN AS DOWN.close_val < PREV(DOWN.close_val),
       UP AS UP.close_val > PREV(UP.close_val)
)
WHERE end_date -start_date > 10;
```
## 3. Scalar Function
- one result for each table row returned
- can be used in: SELECT(to modify the returned data); WHERE(custom condition); START WITH; CONNECT BY; HAVING
- ABS(n): absolute value
- ROUND(v, n): round v to n places to the right of the decimal place; def n - 0
- TRUNC(v): cut decimal part
- INITCAP(c): delimiter- white space/non alphanumeric
- LOWER(c)
- LPAD(exp1, n, exp2): padding exp1 to n length using exp2
- TRIM(char, set): remove from the left end of char all in the set
- ADD_MONTH(dt, i)
- LAST_DAY(dt)
- MONTHS_BETWEEN(dt1, dt2): float value of (dt1 - dt2)
- TO_DATE(char, fmt, 'nlsparam'): if fmt omitted, char must be in def fmt
- TO_NUMBER(exp, fmt, 'nlsparam')

### Analytic Function
```text
SYNTAX:
analytic_function([argument]) OVER (analytic_clause)
analytic_clause: [query_partition_clause][order_by_clause [window clause]]
```
- SQL engine processes analytic functions immediately prior to the ORDER BY clause
- window clause: ROWS/RANGE; BETWEEN AND; UNBOUNDED PRECEDING; UNBOUNDED FOLLOWING; CURRENT ROW
- PERCENTILE_CONT(): continuous distribution model; PERCENTILE_DISC
- STDDEV()
- LAG(col, n, def_val): access to a row at a given phyical offset prior to the current row; def_val: def-null
- LEAD(col, n, def_val): following

## 4. Aggregate Function
- AVG(DISTINCT/ALL exp)
- MEDIAN(exp)
- MIN(DISTINCT/ALL exp)
- can appear in select list, ORDER BY, and HAVING clause
- commonly used in conjunction with GROUP BY
- many aggregate function take single argument will accept DISTINCT/UNIQUE, def-ALL
- NULL values are ignored by all of agg func except COUNT(\*), GROUPING and GROUPING_ID
- only COUNT() and REGR_COUNT() will never return a NULL
### GROUP BY
- GROUP BY can contain any columns of the tables in the FROM clause, regardless of whether the columns appear in the select list
### HAVING
- retrict the groups

*GROUP BY and HAVING must after WHERE and hierarchical query, but before ORDER BY*

## 5. JOIN
- Equijoin: JOIN contains =
- Non-Equijoin 
- Self-join: table appear multi times in FROM
- Inner join: only return rows meet the join condition
- Full outer join: return all
- Left outer join: return all left-side and condition-met right side
- Right outer join
- Cross join: Cartesian product
- Natural join: names and data types of columns in join condition match

- JOIN ... USING (col): always Equijoin
- JOIN ... ON (exp)
- CROSS APPLY - kinda INNER JOIN, right side of APPLY can reference col in left
- OUTER APPLY - kinda LEFT JOIN, ...
```sql
SELECT a.col1, a.col2, c.col2
FROM table_A a
CROSS APPLY (SELECT * FROM table_B b WHERE a.col1 = b.col1) c
```

## 6.Subquery
- only be used in:
  - SELECT: scalar query act like SQL function to generate new expressions 
  - FROM:  Inline View 
  - WHERE: result set to filter by; Nested Subquery, up to 255 level
  - HAVING
  - INSERT: not use VALUES
  - UPATE: SET
- if subquery's column share the same name with outer query, outer query must use column reference
- Correlated subquery: must run once for each row of the parent
- single row operators: =, >, >=, <, <=, <>, !=
- Multi-row operators: IN, NOT IN, ANY, ALL, EXISTS, NOT EXISTS
- use ANY/ALL with single row operators
- LATERAL(12c): lateral subquery can reference tables appear to the left of it in the FROM

## 7. Set operator
- Compound query
- UNION: removed duplicates
- UNION ALL
- INTERECT
- MINUS: selected by the first query but not the second
- Column names returned by the query are determined by the first SELECT statement
- ORDER BY can only be placed at the very end of the compound query
- if use column name or aliases, must use them from the first SELECT list in the compound query

## 8. DML
- INSERT INTO VALUES
- UPATE SET
- DELETE
- MERGE: to avoid multiple INSERT, UPDATE, and DELETE DML statements.
```sql
MERGE
INTO target_table_view
USING source_table_view_subquery
ON update_insert_condition
WHEN MATCHED THEN
DELETE WHERE --to clean up the target table after a merge operation
WHEN NOT MATCHED THEN 

-----------------------------------

MERGE INTO bonuses D
   USING (SELECT employee_id, salary, department_id FROM employees
   WHERE department_id = 80) S
   ON (D.employee_id = S.employee_id)
   WHEN MATCHED THEN UPDATE SET D.bonus = D.bonus + S.salary*.01
     DELETE WHERE (S.salary > 8000)
   WHEN NOT MATCHED THEN INSERT (D.employee_id, D.bonus)
     VALUES (S.employee_id, S.salary*.01)
     WHERE (S.salary <= 8000);
```
- control transaction
  - COMMIT
  - ROLLBACK
  - SAVEPOINT
  - [SET TRANSACTION](https://docs.oracle.com/cloud/latest/db112/SQLRF/statements_10005.htm#SQLRF01705)
  - [SET CONSTRAINT](https://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_10003.htm#SQLRF01703) 

## 9. DDL

### objects
- TABLE
- INDEX
- VIEW
- SEQUENCE
- SYNONYM
- CONSTRAINT
- USER
### data type
- VARCHAR2(n)
- NVARVHAR2(n)
- NUMBER
- FLOAT
- LONG
- DATE
- BINARY_FLOAT
- BINARY_DOUBLE
- TIMESTAMP
- TIMESTAMP WITH TIME ZONE
- TIMESTAMP WITH LOCAL TIME ZONE
- INTERVAL DAY TO SECOND
- INTERVAL YEAR TO MONTH
- RAW(n)
- LONG RAW
- ROWID
- UROWID
- CHAR(n)
- NCHAR(N)
- CLOB
- NCLOB
- BLOB
- BFILE

- naming: 1-30 bytes long; begin with alphabetic; _, $, \# and alphanumeric

- CREATE TABLE: **the precision and scale of a NUMBER column act as a constraint to limit the value allowed in it**
- object name be prefixed by the schema name
- ALTER TABLE
- DROP TABLE

### constraint
- PRIMARY KEY
- UNIQUE
- NOT NULL
- FOREIGN KEY
- CHECK

**TRUNCATE vs DELETE**
1. TRUNCATE is faster as DELETE has UNDO info overhead
2. TRUNCATE can't use with WHERE
3. TRUNCATE is DDL, can't be reversed

### 12c
- Sequence can be used for Column DEFAULT, both CURRVAL and NEXTVAL
- INVISIBLE column: only show if specifically referenced
- virtual columns: derived from other columns in the same table, not possible directly update
- IDENTITY column: numeric data type

## 10. Creating other Schema objects- view, sequence, synonym

### VIEW
- cannot delete or modify data via a view if it has aggregated data or contains the DISTINCT/UNIQUE 
- cannot insert if not contain NOT NULL col of the base table
- to get invisible column of the base table, must explicitly reference, and get fully visible

### SEQUENCE
- generating number is independent of whether the transaction is committed or rolled back
- START WITH: 1
- INCREMENT BY:1
- MINVALUE: NOMINVALUE
- MAXVALUE: NOMAXVALUE
- CYCLE: NOCYCLE
- CACHE: CACHE 20

### SYNONYM
- dropping a synonym has no effect on teh object it pointed to
- PRIVATE: SYNONYM
- PUBLIC: PUBLIC SYNONYM

## 11. Dictionary view
- DBA\_: across all schemas, Admin
- ALL\_: based on privilege
- USER\_: only exist in the schema
- V$: dynamic performance view for local
- GV$
- DICTIONARY
```sql
SELECT * FROM DICTIONARY;
```
## 12. Privilege, ROLE
- ANY: system privilege with ANY- schema-specific; without-not schema-specific
- PUBLIC: all users share the privilege
- WITH ADMIN OPTION: can grant the system privilege to other users in turn; revoke does not cascade
- WITH GRANT OPTION: grant the object privilege to other user; revoke does cascade
```sql
CREATE ROLE HR_SUPVSR;
GRANT SELECT, UPDATE, DELETE ON HR.EMPLOYEES TO HR_SUPVSR;

SELECT * FROM USER_TAB_PRIVS;
```

## 13. Schema Object
### CONSTRAINT
- def - NOT DEFERABLE; DEFERRABLE
- def - INITIALLY IMMEDIATE; INITAILLY DEFERRED(end of transaction)
- ENABLE, DISABLE, VALIDATE, NOVALIDATE
### INDEX
- Normal index
- Bitmap index: cannot be UNIQUE
- Partitioned index
- Function-based index
- Index are never used for !=, NOT IN, IS NULL
```sql
ALTER INDEX idx_name REBUILD; -- after a lot of data changes
```
- UNIQUE: an index with the same name as the constraint will be auto-created
- Invisible index: Test effection, INVISIBLE/VISIBLE
- when more than a single index exists for a given set of columns, only one can be visible at any given time
### UNUSED
```sql
ALTER TABLE tab DROP COLUMN col;
ALTER TABLE tab SET UNUSED COLUMN col;

ALTER TABLE tab DROP(col);
ALTER TABLE tab SET UNUSED(col);

ALTER TABLE tab DROP UNUSED COLUMNS;
```
### FLASHBACK
#### AS OF TIMESTAMP/SCN
#### VERSIONS BETWEEN TIMESTAMP
#### FROM FLASHBACK_TRANSACTION_QUERY

### External table
- TYPE
- DEFAULT DIRECTORY
- ACCESS PARAMETERS
- LOCATION
- ORACLE must scan every single row in the file for queries.
















