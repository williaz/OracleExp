*SELECT, ~~UPDATE, INSERT, DELETE,~~ MERGE, WHERE, ~~JOIN~~, ~~UNION, UNION ALL, INTERSECT, MINUS,~~ ~~GROUP BY~~, ~~HAVING~~, ORDER BY, CONNECT BY*
## INSERT
- always identify column names in an INSERT statement, but no need in order
- runtime err for violation of a constraint
```sql
INSERT INTO tb/vw VALUES(...cols)
```
## UPATE
- if violating any constraint, entire UPDATE will be rejected
```sql
UPDATE tb/vw SET .. (WHERE ..)
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

















