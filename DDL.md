*CREATE, ALTER, DROP *

## Naming
- a1$_#
- case-insensitive, while if in "", case-sensitive\
- INDEX and CONSTRAINT have their own namespace

## CREATE
```sql
CREATE objType objName attributes;

CREATE TABLE 
CREATE VIEW
CREATE INDEX
CREATE SEQUENCE
CREATE SYNONYM
CREATE USER
CREATE ROLE
CREATE PUBLIC SYNONYM
```

### built-in Data Type
- CHAR(n): n **fixed-length** alphanumeric, padding unused with blanks
- VARCHAR2(n): max length n, **n [1, 4000] required**
- NUMBER(precision, scale): precision(max num of digits) def=max; scale(max num of decimal point's righside digits) def=0; .5 round up
*ORA-01438: "value larger than specified precision allowed for this column"*

- DATE: Date literals are enclosed in single quotation, ANSI fmt-'YYYY-MM-DD'
```sql
SHOW PARAMETER NLS_DATE_FORMAT; -- 'DD-MON-RR', 00-49:2000; 50-99: 1900
SHOW PARAMETER NLS_TERRITORY;
```
- TIMESTAMP(n): extend DATE by adding fractional sec, n range[1-9], def=6
- TIMESTAMP(n) WITH TIME ZONE
- TIMESTAMP(n) WITH LOCAL TIME ZONE
- INTERVAL YEAR(n) TO MONTH: n- precision- def=2, [0, 9]
- INTERVAL DAY(n1) To SECOND(n2)
```sql
SELECT INTERVAL '123-2' YEAR(3) TO MONTH FROM dual;
SELECT INTERVAL '4' MONTH FROM dual;
SELECT INTERVAL '3000' YEAR FROM dual; --ORA-01873: the leading precision of the interval is too small
SELECT INTERVAL '10:22' MINUTE TO SECOND FROM dual;
SELECT INTERVAL '10 0:12:59' DAY TO SECOND FROM dual; --ORA-01852: seconds must be between 0 and 59
```
- BLOB/CLOB/NCLOB: **cannot be PK, nore used with DISTINCT, GROUP BY, ORDER BY, joins**

### CONSTRAINT creation
- NOT NULL cannot be created "out of line"
```sql
-- CREATE TABLE 
-- 1. in line
CREATE TABLE VENDORS (
VEND_ID NUMBER PRIMARY KEY,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1) NOT NULL
); -- anonymous

CREATE TABLE PORTS (
PT_ID NUMBER CONSTRAINT PT_ID_PK PRIMARY KEY,
PT_NAME VARCHAR2(20),
STATUS NUMBER(1) CONSTRAINT STATUS_NN NOT NULL
);
-- 2. out of line
CREATE TABLE VENDORS1 (
VEND_ID NUMBER,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1),
PRIMARY KEY(VEND_ID)
);

CREATE TABLE PORTS1 (
PT_ID NUMBER,
PT_NAME VARCHAR2(20),
STATUS NUMBER(1),
CONSTRAINT PT_ID_PK1 PRIMARY KEY (PT_ID, PT_NAME)
);


-- ALTER TABLE
-- in line
CREATE TABLE VENDORS2 (
VEND_ID NUMBER,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1)
);
ALTER TABLE VENDORS2
MODIFY VEND_ID PRIMARY KEY;

CREATE TABLE PORTS2 (
PT_ID NUMBER,
PT_NAME VARCHAR2(20),
STATUS NUMBER(1)
);
ALTER TABLE PORTS2 
MODIFY PT_ID CONSTRAINT PT_ID_PK2 PRIMARY KEY;

-- out of line
CREATE TABLE VENDORS3 (
VEND_ID NUMBER,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1)
);
ALTER TABLE VENDORS3
ADD PRIMARY KEY(VEND_ID);

CREATE TABLE PORTS3 (
PT_ID NUMBER,
PT_NAME VARCHAR2(20),
STATUS NUMBER(1)
);
ALTER TABLE PORTS3 
ADD CONSTRAINT PT_ID_PK3 PRIMARY KEY(PT_ID); 
```
### Constraint types
- NOT NULL
- UNIQUE
- PRIMARY KEY := NOT NULL + UNIQUE, one per table
- FOREIGN KEY: require the second table UNIQUE column, prefer ALTER(PK, FK order; cannot create FK using CREATE TABLE as query)
```sql
CREATE TABLE SHIPS (
SHIP_ID NUMBER,
HOME_PORT_ID NUMBER,
CONSTRAINT SHIPS_PORTS_FK FOREIGN KEY(HOME_PORT_ID) REFERENCES PORTS(PT_ID)
);
```
- CHECK
*UNIQUE, PK, FK don't allow BLOB, CLOB, and TIMESTAMP WITH TIME ZONE*

### CREATE VIEW
- must name expressions with a column alias
```sql
CREATE OR REPLACE VIEW EMPLOYEE_VW
AS 
SELECT FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME, PHONE_NUMBER, ROUND(SALARY, -2) AS GROSS_SALARY
FROM HR.EMPLOYEES;
```
- inline view is unlimited nesting, vs typical subqueries limit - 255
```sql
SELECT ROWNUM, FULL_NAME, PHONE_NUMBER
FROM
(
SELECT * FROM EMPLOYEE_VW
WHERE FULL_NAME LIKE 'W_l%'
)
WHERE ROWNUM <=10;
```
### *OR REPLACE* don't work with CREATE TABLE, but do with CREATE VIEW (no warning)

### ALTER VIEW
- recompile after modification on the underlying table
```sql
ALTER VIEW EMPLOYEE_VW COMPILE;
DROP VIEW EMPLOYEE_VW;
```

### CREATE SEQUENCE
- must first invoke NEXTVAL
- NEXTVAL keeps advance even fails
- cannot invoke NEXTAVL, CURRVAL in 
  - DEFAULT clause of CREATE/ALTER TABLE
  - subquery of CREATE VIW, SELECT/UPDATE/DELETE
  - with DISTINCT
  - in WHERE
  - in CHECK
  - with UNION, INTERSET or MINUS
```sql
CREATE SEQUENCE seq_name seq_opts;
CREATE SEQUENCE ORDER_SEQ START WITH 2 INCREMENT BY 2;

SELECT ORDER_SEQ.NEXTVAL FROM dual; 
SELECT ORDER_SEQ.CURRVAL FROM dual;
```

### INDEX
- cannot create an index on columns of LOB or RAW
- increase the workload on future DML
- implicit index creation (UNIQUE INDEX) with PK and UNQIUE
```sql
CREATE TABLE VENDORS (
VEND_ID NUMBER PRIMARY KEY,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1) NOT NULL,
VEND_AREA VARCHAR2(10) UNIQUE
);

SELECT TABLE_NAME, INDEX_NAME
FROM USER_INDEXES
WHERE TABLE_NAME = 'VENDORS';

SELECT INDEX_NAME, COLUMN_NAME
FROM USER_IND_COLUMNS
WHERE TABLE_NAME = 'VENDORS';

- single col
CREATE INDEX IX_VEND_NAME ON VENDORS(VEND_NAME);

- Composite col
CREATE INDEX IX_NAME_AREA ON VENDORS(VEND_AREA, VEND_NAME);
- Unique idx
CREATE UNIQUE INDEX IX_STATUS ON VENDORS(STATUS);
```
- works when:
  - equality
  - greater than
  - not equals will not
  - LIKE '%S' with leading wildcard will not
  - function will prevent, unless it is function-based index
- no more tha 5 index on the aveerage table in a trasaction-based application
- Composite index will be used even be called the first col, Skip Scanning
**UNIQUE vs UNIQUE INDEX**
- A constraint has different meaning to an index. It gives the optimiser more information and allows you to have foreign keys on the column, whereas a unique index doesn't.

### SYNONYM
- when creating SYNONYM for another obj, that obj doesn't hvae to exist already, or having the privilege on that object
- private SYNONYM is own by the user account created it, and def only visible within it
```sql
CREATE OR REPLACE SYNONYM EMP FOR HR.EMPLOYEES;

CREATE SYNONYM IX_ST FOR IX_STATUS;
DROP SYNONYM IX_ST;
```
- PUBLIC SYNONYM: own by PUBLIC, any users can see, need system privilege
- exists independently of the obj in refer to
- no ALTER







