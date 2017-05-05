*SELECT, ~~UPDATE, INSERT, DELETE,~~ MERGE, WHERE, ~~JOIN~~, ~~UNION, UNION ALL, INTERSECT, MINUS,~~ ~~GROUP BY~~, ~~HAVING~~, ORDER BY, CONNECT BY*
## INSERT
- always identify column names in an INSERT statement, but no need in order
- runtime err for violation of a constraint
```sql
INSERT INTO tb/vw VALUES(...cols)
```
### INSERT with subquery
```sql
DROP TABLE workers;
CREATE TABLE workers
AS
SELECT EMPLOYEE_ID, LAST_NAME, SALARY 
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID < 150;


SELECT * FROM workers;

CREATE SEQUENCE seq_wk START WITH 500;

INSERT INTO workers
(EMPLOYEE_ID, LAST_NAME, SALARY)
SELECT seq_wk.NEXTVAL, LAST_NAME, SALARY
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID BETWEEN 200 AND 250;
```
### multitable INSERT
- only use with a table
- error for sequence generator in subquery
- ALL is required for unconditional
- ALL is def for conditional, ALL/FIRST
- if there is no column ist in the INTO clause, the subquery's select list must match the columns in the table of the INTO clause
- Table aliases in the subquery of a multitable INSERT are not recognized outside in the rest of the INSERT-> use column alias
```sql
DROP TABLE phone_book;
CREATE TABLE phone_book
AS
SELECT LAST_NAME, PHONE_NUMBER FROM HR.EMPLOYEES
WHERE ROWNUM < 2;

TRUNCATE TABLE phone_book;

DROP TABLE email_book;
CREATE TABLE email_book
AS
SELECT LAST_NAME, EMAIL FROM HR.EMPLOYEES
WHERE ROWNUM < 2;

DELETE FROM email_book;

INSERT ALL
    INTO phone_book VALUES(LAST_NAME, PHONE_NUMBER)
    INTO email_book VALUES(LAST_NAME, EMAIL ||'@HR.COM')
  SELECT * FROM HR.EMPLOYEES;
  
SELECT * FROM phone_book;
SELECT * FROM email_book;

```
### Pivot INSERT

## UPATE
- if violating any constraint, entire UPDATE will be rejected
```sql
UPDATE tb/vw SET .. (WHERE ..)
```

### UPDATE with correlated subquery
```sql
UPDATE workers wk
SET wk.SALARY =  0.5 + NVL( 1.1*(
SELECT em.SALARY FROM HR.EMPLOYEES em
WHERE em.EMPLOYEE_ID = wk.EMPLOYEE_ID
), wk.SALARY);
```
## DELETE
```sql
DELETE FROM tb (WHERE ..)
```
### _DML in VIEW_
- INSERT, UPDATE, DELETE can't be used in VIEW if the view:
  - Omission of any required columns
  - GROUP BY or agg or hierarchical
  - DISTINCT
  - involved in more than one tables like join, subsquery
- sum: if the view provides row level (not aggregateed) access to one and only one tbale and includes the ability to access the required columns in that table, then you can use INSERT, UPDATE, and/or DELETE on the view to effect changes to the underlying table.

## MERGE
- cannot update column in the ON condition
- DELETE only affect rows that are a result of the completed "update clause"
```sql
MERGE INTO workers wk
  USING HR.EMPLOYEES em
  ON (em.EMPLOYEE_ID = wk.EMPLOYEE_ID)
  WHEN MATCHED THEN 
     UPDATE SET wk.SALARY = em.SALARY
  WHEN NOT MATCHED THEN INSERT
     VALUES (em.EMPLOYEE_ID, em.LAST_NAME, em.SALARY)
     WHERE em.EMPLOYEE_ID BETWEEN 200 AND 400
;

MERGE INTO workers wk
  USING HR.EMPLOYEES em
  ON (em.EMPLOYEE_ID = wk.EMPLOYEE_ID)
  WHEN MATCHED THEN 
     UPDATE SET wk.SALARY = em.SALARY
     DELETE WHERE wk.EMPLOYEE_ID < 150
  WHEN NOT MATCHED THEN INSERT
     VALUES (em.EMPLOYEE_ID, em.LAST_NAME, em.SALARY)
     WHERE em.EMPLOYEE_ID BETWEEN 200 AND 400
;
```

## JOIN
- PK and FK exist for join, but join don't requires them
- Multi-Join
```sql
SELECT FIRST_NAME || LAST_NAME AS FULL_NAME, DEPARTMENT_NAME,  CITY, COUNTRY_NAME, REGION_NAME
FROM HR.EMPLOYEES emp JOIN HR.DEPARTMENTS dp ON emp.DEPARTMENT_ID = dp.DEPARTMENT_ID
JOIN HR.LOCATIONS lc ON dp.LOCATION_ID = lc.LOCATION_ID
JOIN HR.COUNTRIES ct ON lc.COUNTRY_ID = ct.COUNTRY_ID
JOIN HR.REGIONS rg ON ct.REGION_ID = rg.REGION_ID;
```

- LEFT/RIGHT/FULL (OUTER) JOIN
```sql
SELECT COUNTRY_NAME, REGION_NAME
FROM HR.COUNTRIES ct 
LEFT JOIN HR.REGIONS rg ON ct.REGION_ID = rg.REGION_ID;

SELECT COUNTRY_NAME, REGION_NAME
FROM HR.REGIONS  ct 
RIGHT JOIN HR.COUNTRIES rg ON ct.REGION_ID = rg.REGION_ID;

SELECT REGION_NAME, COUNTRY_NAME
FROM HR.REGIONS  ct 
LEFT JOIN HR.COUNTRIES rg ON ct.REGION_ID = rg.REGION_ID;

SELECT REGION_NAME, COUNTRY_NAME
FROM HR.COUNTRIES   ct 
RIGHT JOIN HR.REGIONS rg ON ct.REGION_ID = rg.REGION_ID;

SELECT FIRST_NAME || LAST_NAME AS FULL_NAME, JOB_TITLE
FROM HR.EMPLOYEES emp
FULL JOIN HR.JOBS jb ON emp.JOB_ID = jb.JOB_ID;
```
- NATURAL JOIN: only INNER JOIN, forbid table prefix
```sql
SELECT FIRST_NAME || LAST_NAME AS FULL_NAME, JOB_TITLE
FROM HR.EMPLOYEES NATURAL JOIN HR.JOBS;
```
- USING: allow both INNER and OUTER JOIN, forbid table prefix
```sql
SELECT a.FIRST_NAME || a.LAST_NAME AS EMP_NAME, b.FIRST_NAME || b.LAST_NAME AS MNG_NAME
FROM HR.EMPLOYEES a LEFT JOIN HR.EMPLOYEES b
USING (MANAGER_ID);
```
- Non-Equijoin
```sql
CREATE TABLE SALARY_LEVEL 
(
LEVEL_ID NUMBER ,
LEVEL_VAl VARCHAR2(5),
SALARY_MIN NUMBER,
SALARY_MAX NUMBER
);

INSERT INTO SALARY_LEVEL
VALUES (1, 'Low', 0, 6000);

INSERT INTO SALARY_LEVEL
VALUES (2, 'Med', 6001, 10000);

INSERT INTO SALARY_LEVEL
VALUES (3, 'High', 10000, 100000);

SELECT FIRST_NAME || LAST_NAME AS EMP_NAME, LEVEL_VAL
FROM HR.EMPLOYEES JOIN SALARY_LEVEL
ON SALARY BETWEEN SALARY_MIN AND SALARY_MAX;
```

## GROUP BY
- within SELECT creating 'mini-select' statement
- only allow 1. expression specified in GROUP BY; 2. Aggregate function in select list
- ORDER BY restricted to use only: 1. exp in GROUP BY; 2. exp in select list(pos, nam, alias); 3. any Agg func; 4. USER/SYSDATE/UID
- **Two levels deep** is the furthest you can go with nested aggregate functions. no restriction for scalar
```sql
SELECT JOB_ID, ROUND (AVG(SALARY), 2), MAX(SALARY), MIN(SALARY)
FROM HR.EMPLOYEES
GROUP BY JOB_ID
ORDER BY 2 DESC;
```
## ROLLUP
- used after GROUP BY
- used to compute a subtotal/total for each group
```sql
SELECT DEPARTMENT_ID, MANAGER_ID, JOB_ID, SUM(SALARY)
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID, MANAGER_ID, JOB_ID
ORDER BY DEPARTMENT_ID, MANAGER_ID, JOB_ID;

SELECT DEPARTMENT_ID, MANAGER_ID, JOB_ID, SUM(SALARY)
FROM HR.EMPLOYEES
GROUP BY ROLLUP(DEPARTMENT_ID, MANAGER_ID, JOB_ID)
ORDER BY DEPARTMENT_ID, MANAGER_ID, JOB_ID;
```

## CUBE
- three-dimentional version of ROLLUP
```sql
SELECT DEPARTMENT_ID, MANAGER_ID, JOB_ID, SUM(SALARY)
FROM HR.EMPLOYEES
GROUP BY CUBE(DEPARTMENT_ID, MANAGER_ID, JOB_ID)
ORDER BY DEPARTMENT_ID, MANAGER_ID, JOB_ID;
```

## GROUPING
- only valid in a SELECT that uses a GROUP BY
- to differenitate between superaggregate row and regular rows, key for providing customized behavior(DECODE)
- 1 for subtotal/total

## GROUPING SETS
- to selectively choose particular group of data, ignoring anu unwanted groups
- each set() specifies GROUP BY clause groups
- as if running several GROUP BY at once and combine the results with UNION ALL
- NULL for a Grand Total
```sql
SELECT DEPARTMENT_ID, MANAGER_ID, JOB_ID, SUM(SALARY)
FROM HR.EMPLOYEES
WHERE MANAGER_ID IS NOT NULL
GROUP BY GROUPING SETS((DEPARTMENT_ID, JOB_ID), MANAGER_ID, NULL)
ORDER BY DEPARTMENT_ID, MANAGER_ID, JOB_ID;
```
## HAVING
- must together with GROUP BY, either order
- only compare exp in GROUP BY or Agg func
```
SELECT JOB_ID, ROUND (AVG(SALARY), 2), MAX(SALARY), MIN(SALARY)
FROM HR.EMPLOYEES
GROUP BY JOB_ID
HAVING MIN(SALARY) > 5000
--HAVING JOB_ID NOT IN ('AD_PRES', 'AD_VP')
ORDER BY 2 DESC;
```

## UNION/ UNION ALL/ INTERSECT/ MINUS
- same number of exp in select lists
- datatypes match
- not use BLOB/CLOB
- only use ORDER BY in the final SELECT statement, By position or By **first** SELECT list
- equal precedence
```sql
CREATE OR REPLACE VIEW manager
AS (
SELECT DISTINCT ae. EMPLOYEE_ID, ae.FIRST_NAME, ae.LAST_NAME, ae.EMAIL
FROM HR.EMPLOYEES ae
JOIN HR.EMPLOYEES be ON ae.EMPLOYEE_ID = be.MANAGER_ID
);

SELECT * FROM manager;
-- 18 rows

SELECT EMPLOYEE_ID, EMAIL FROM HR.EMPLOYEES
UNION
SELECT EMPLOYEE_ID, EMAIL FROM manager; 
--107 rows

SELECT EMPLOYEE_ID, EMAIL FROM HR.EMPLOYEES
UNION ALL
SELECT EMPLOYEE_ID, EMAIL FROM manager
ORDER BY 1;
-- 125 rows

SELECT EMPLOYEE_ID, EMAIL FROM HR.EMPLOYEES
INTERSECT
SELECT EMPLOYEE_ID, EMAIL FROM manager; 
-- 18

SELECT EMPLOYEE_ID, EMAIL FROM HR.EMPLOYEES
MINUS
SELECT EMPLOYEE_ID, EMAIL FROM manager; 
-- 89

SELECT EMPLOYEE_ID, EMAIL FROM manager
MINUS
SELECT EMPLOYEE_ID, EMAIL FROM HR.EMPLOYEES; 
-- 0
```

## Subquery
- a SELECT statement
- to Solve:
  - Complex multistage queries
  - Creating populated tables: in CREATE TABLE
  - Large data set manipulation: UPDATE, INSERT
  - Creating named views: CREATE VIEW .. AS
  - Dynamic view definition: inline view
  - Dynamic expression definition with scalar subqueries: single value as expression
- ensure a "single-row" query
  - WHERE
  - return an aggregate function
  - AND ROWNUM < 2
- LIKE(\_ %),
- IN, NOT IN, = ANY/SOME, > ALL 
```sql
SELECT * FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID =
(
SELECT MANAGER_ID FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID = 116
);
```
- Scalar subquery must always be enclosed in parentheses. 
- Scalar CANNOT be used in
  1. CHECK
  2. GROUP BY
  3. HAVING
  4. function-based index
  5. DEFAULT
  6. RETURNING of any DML
  7. WHEN condition of CASE
  8. START WITH and CONNECT BY
```sql
SELECT FIRST_NAME, LAST_NAME, (SELECT COUNTRY_NAME FROM HR.COUNTRIES WHERE COUNTRY_ID = 'CA') AS hometown 
FROM HR.EMPLOYEES WHERE ROWNUM < 5;

CREATE TABLE workers
AS 
(
SELECT * FROM HR.EMPLOYEES
WHERE ROWNUM < 30
);
```
### Correlated subquery
- Correlated subquery is executing once for each value that the parent query finds for each row
- Correlated subquery can exist in SELECT, UPDATE, and DELETE.
```sql
SELECT * FROM HR.EMPLOYEES em
WHERE SALARY = 
(
SELECT MAX(SALARY) FROM HR.EMPLOYEES
GROUP BY MANAGER_ID
HAVING MANAGER_ID = em.MANAGER_ID
);
```
#### UPDATE
- in SET or WHERE
```sql
UPDATE workers w
SET SALARY = SALARY + (
SELECT SALARY FROM workers WHERE EMPLOYEE_ID = w.MANAGER_ID
)/10 + 0.4
WHERE (
SELECT SALARY FROM workers WHERE EMPLOYEE_ID = w.MANAGER_ID
) - SALARY < 5000;
```
#### DELETE
```sql
DELETE FROM workers w1
WHERE w1.SALARY = (
SELECT MIN(w2.SALARY) FROM workers w2 WHERE w1.MANAGER_ID = w2.MANAGER_ID
);
```
### EXISTS
- EXISTS, NOT EXISTS
- Semijoin, a SELECT statement that uses the EXISTS to compare rows in atbale with rows in another table
```sql
-- boss has workers
SELECT * FROM workers w1
WHERE EXISTS (
SELECT * FROM workers w2
WHERE w2.MANAGER_ID = w1.EMPLOYEE_ID
);
```
### WITH
- subquery factoring clause
- must before SELECT
- name isn't recognized within the subquery itself
- not database objects
```sql
WITH
  managers AS(
  SELECT DISTINCT * FROM HR.EMPLOYEES
  WHERE EMPLOYEE_ID = 100
  ),
  members AS(
  SELECT DISTINCT * FROM HR.EMPLOYEES
  WHERE EMPLOYEE_ID != 100
  )
SELECT * FROM members
WHERE MANAGER_ID = (
SELECT EMPLOYEE_ID FROM members 
WHERE ROWNUM <2
);
```

## Hierarchical Query
- forks(father), node(leaf)
- START WITH, CONNECT BY
- PRIOR must be placed column reference, to decide traverse up or down the tree
- LEVEL (pseudo-col) available to START WITH & CONNECT BY
- ORDER SIBLINGS BY: sorts rows within each given level
- SYS_CONNECT_BY_PATH: show full path
- CONNECT_BY_ROOT: access root node row's columns
```sql
-- down, manager is the prior data
SELECT LEVEL, LAST_NAME, LPAD(' ', LEVEL*2, '-') || JOB_ID title
FROM HR.EMPLOYEES
START WITH EMPLOYEE_ID = 100
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID;

-- find his boss
SELECT LEVEL, LAST_NAME, LPAD(' ', LEVEL*2, '-') || JOB_ID title
FROM HR.EMPLOYEES
START WITH EMPLOYEE_ID = 206
CONNECT BY PRIOR MANAGER_ID =  EMPLOYEE_ID;

-- also show boss id using PRIOR in select list
SELECT LEVEL, EMPLOYEE_ID, LAST_NAME, LPAD(' ', LEVEL*2, '-') || JOB_ID title, PRIOR EMPLOYEE_ID BOSS_ID
FROM HR.EMPLOYEES
START WITH EMPLOYEE_ID = 100
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
ORDER SIBLINGS BY JOB_ID;

SELECT LEVEL, EMPLOYEE_ID, LAST_NAME, SYS_CONNECT_BY_PATH(JOB_ID, '/') title, PRIOR EMPLOYEE_ID BOSS_ID
FROM HR.EMPLOYEES
START WITH EMPLOYEE_ID = 100
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
ORDER SIBLINGS BY JOB_ID;

SELECT LEVEL, EMPLOYEE_ID, LAST_NAME, LPAD(' ', LEVEL*2, '-') || JOB_ID title, CONNECT_BY_ROOT EMPLOYEE_ID  BIG_BOSS_ID
FROM HR.EMPLOYEES
START WITH EMPLOYEE_ID = 101
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
ORDER SIBLINGS BY JOB_ID;
```
- selectviely restrict entire branches
- WHERE should be place before the START WITH
```sql
SELECT EMPLOYEE_ID, LAST_NAME, LPAD(' ', LEVEL*2, '-') || JOB_ID title
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID < 200 
START WITH EMPLOYEE_ID = 100
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
           AND EMPLOYEE_ID != 102;
```






