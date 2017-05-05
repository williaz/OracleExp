*CREATE, ALTER, DROP, RENAME, TRUNCATE, GRANT, REVOKE, FLASHBACK, PURGE, COMMENT *

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

### CTAS
- CREATE TABLE AS SELECT
- use the source table's column definitions, keep NOT NULL, but discard other objects

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
- BLOB/CLOB/NCLOB: **cannot be PK, nor used with DISTINCT, GROUP BY, ORDER BY, joins**

### CONSTRAINT creation
- NOT NULL cannot be created "out of line"
- ALTER MODIFY - in-line - focus on column; 
- ALTER ADD - out-of-line - focus on constraint - only way for creating composite constraints
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

#### USING INDEX
- for creating indices can be used to specify an existing index by appending a constraint specification with "USING INDEX idx_name" and nothing else.

#### Function-based index
- any expression will be accepted
```sql
DROP TABLE VENDORS;
CREATE TABLE VENDORS (
VEND_ID NUMBER PRIMARY KEY,
VEND_NAME VARCHAR2(20),
STATUS NUMBER(1) NOT NULL,
VEND_AREA VARCHAR2(10) UNIQUE,
RENT NUMBER NOT NULL
);
CREATE INDEX rent_round ON VENDORS (ROUND(RENT, 2));
SELECT * FROM USER_INDEXES;
```

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

## ALTER

### ALTER TABLE
```sql
ALTER TABLE tab_name clause(ADD/MODIFY)
```
### ADD
- order: datatype, DEFAULT, CONSTRAINT
- require data type
```sql
CREATE TABLE orders (
ORD_ID NUMBER,
SALES_ID NUMBER
);

SELECT * 
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'ORDERS';

ALTER TABLE orders ADD(ORD_PRICE NUMBER);

ALTER TABLE orders ADD(CLIENT_ID NUMBER NOT NULL, ORD_NUM NUMBER DEFAULT 0);
```
### MODIFY
- only one of datatype, DEFAULT, CONSTRAINT is required
```sql
ALTER TABLE orders MODIFY (ORD_ID NOT NULL);
--reverse back
ALTER TABLE orders MODIFY (ORD_ID NULL);
```
- you cannot modify a column to take on properties that conflict with any existing data that is already present in the column

### RENAME COLUMN
```sql
ALTER TABLE orders RENAME COLUMN CLIENT_ID TO CLIENTS_ID;
```
### DROP COLUMN
- any constraints or indices on the column will also be dropped when you drop the column
- a table must have at least one column
```sql
ALTER TABLE orders DROP COLUMN ORD_NUM;

ALTER TABLE orders DROP (SALES_ID, CLIENTS_ID);
```
- if a column is referenced by a FK constraint in anther table, preceding syntax would be fail
- CASCADE CONSTRAINT
```sql
DROP TABLE order_returns;
DROP TABLE orders;
CREATE TABLE orders (
ORD_ID NUMBER PRIMARY KEY,
SALES_ID NUMBER
);
CREATE TABLE order_returns (
ORD_ID NUMBER PRIMARY KEY,
RTN_DATE VARCHAR2(20),
CONSTRAINT ret_fk FOREIGN KEY (ORD_ID) REFERENCES orders (ORD_ID)
);

SELECT * 
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = UPPER('order_returns');

ALTER TABLE orders
DROP COLUMN ORD_ID;
-- ORA-12992: cannot drop parent key column 

ALTER TABLE orders
DROP COLUMN ORD_ID CASCADE CONSTRAINTS;

ALTER TABLE order_returns
DROP COLUMN ORD_ID; 
```
### UNUSED
- once UNUSED, never again available, any constraints or indices on the column will also be dropped, never be recovered(ROLLBACK no effect)
- better performance than DROP
- still be counted as the number of columns(limit: 1000)
- DROP UNUSED COLUMNS
```sql
ALTER TABLE order_returns
SET UNUSED COLUMN RTN_DATE; 

SELECT * FROM USER_UNUSED_COL_TABS; -- just count

ALTER TABLE order_returns DROP UNUSED COLUMNS; -- DROP all unused 
```
### DROP PRIMARY KEY
- CASCADE: def-not cascade
- KEEP INDEX/DROP INDEX: def-DROP INDEX
```sql
ALTER TABLE orders
DROP PRIMARY KEY; 
-- ORA-02273: this unique/primary key is referenced by some foreign keys 

ALTER TABLE orders
DROP PRIMARY KEY CASCADE;
```
### DROP UNIQUE
```sql
ALTER TABLE tab_name DROP UNQIUE (col1, col2, ..) opts;
```
### DROP CONSTRAINT
```sql
ALTER TABLE tab_name DROP CONSTRAINT const_name (CASCADE)
```
### DISABLE CONSTRAINT
- for large data, disable FK
- Child rows can always be deleted without regard fpr the existence of parent rows
```sql
ALTER TABLE tab_name DISABLE/ENABLE (VALIDATE/NOVALIDATE) PRIMARY KEY/UNIQUE/CONSTRAINT const_name;
ALTER TABLE tab_name MODIFY PRIMARY KEY/UNIQUE/CONSTRAINT const_name DISABLE;
```
- ENABLE fail for FK orphans
- DISABLE PRIMARY KEy CASCADE; ENABLE each, no with CASCADE
- ENABLE ensures that all incoming data conforms to the constraint
- DISABLE allows incoming data, regardless of whether it conforms to the  constraint
- VALIDATE ensures that existing data conforms to the constraint
- NOVALIDATE means that some existing data may not conform to the constraint
- DISABLE VALIDATE disables the constraint, drops the index on the constraint, and disallows any modification of the constrained columns.
- ENABLE VALIDATE = ENABLE; DISABLE NOVALIDATE = DISABLE

## DROP
### DROP TABLE
```sql
DROP TABLE tab_name; -- will fail, even FK is disabled
DROP TABLE tab_name CASCADE CONSTRAINTS; -- FK
```
### ON DELETE
- ON DELETE CASCADE
- ON DELETE SET NULL
```sql
SELECT * FROM USER_CONSTRAINTS;

ALTER TABLE order_returns 
DROP CONSTRAINT RET_FK;

ALTER TABLE order_returns
ADD CONSTRAINT RET_FK_D FOREIGN KEY(ORD_ID) REFERENCES orders (ORD_ID) ON DELETE CASCADE;

```
### DEFERRABLE
- constraint default- NOT DEFERRABLE
- DEFFERED: check after COMMIT
- once commit, auto change back from DEFERRED to IMMEDIATE
```sql
SET CONSTRAINT const_name/ALL DEFERRED/IMMEDIATE;
```
### RENAME CONSTRAINT
```sql
ALTER TABLE ORDERS
RENAME CONSTRAINT SYS_C002540550 TO ORD_ID_PK;
```
## FLASHBACK
- recover complete table still retained in the "recycle bin"
- recover the corresponding indexes(no bitmap join indexes???) and constraints(no FK)  with system assigned names
- same name, retrieve last dropped first
- BEFORE DROP
- RENAME TO
```sql
FLASHBACK TABLE tab_name TO..
FLASHBACK TABLE tab1, tab2, tab3 TO.. -- as a whole, fail together

CREATE TABLE orders (
ORD_ID NUMBER PRIMARY KEY,
SALES_ID NUMBER
);

CREATE SEQUENCE ord_id_seq;
INSERT INTO orders VALUES(ord_id_seq.NEXTVAL, ord_id_seq.CURRVAL);
SELECT * FROM orders;

ALTER SESSION SET recyclebin = ON; -- OFF
DROP TABLE orders;

FLASHBACK TABLE orders TO BEFORE DROP;
SELECT * FROM USER_RECYCLEBIN; -- RECYCLEBIN

FLASHBACK TABLE tab TO SCN scn_exp;
FLASHBACK TABLE tab TO TIMESTAMP tsp_exp;
FLASHBACK TABLE tab TO RESTORE POINT pt_exp;
```
- SCN: system change number(recommended)
### ENABLE ROW MOVEMENT
- def- not row movement
- to perform FLASHBACK, must ENABLE ROW MOVEMENT
- cannot use FLASHBACK TABLE to restore older data to an existing table if its structure alted
```sql
CREATE/ALTER TABLE .... ENABLE ROW MOVEMENT;
```
### AS OF (Flashback Query)
```sql
SELECT * FROM tab
AS OF TIMESTAMP/SCN exp; - exp cannot be a subquery

CREATE TABLE orders (
ORD_ID NUMBER PRIMARY KEY,
SALES_ID NUMBER
);

CREATE SEQUENCE ord_id_seq;
INSERT INTO orders VALUES(ord_id_seq.NEXTVAL, ord_id_seq.CURRVAL);
SELECT * FROM orders;
commit;

SELECT ORA_ROWSCN, ORD_ID,Sales_ID FROM orders; 

SELECT * FROM orders
AS OF SCN 1262810129 
MINUS 
SELECT * FROM orders 
AS OF SCN 1262801047;

CREATE VIEW yesterday_orders 
AS
SELECT * FROM orders
AS OF TIMESTAMP (SYSTIMESTAMP -1);
```
### VERSIONS BETWEEN AND (Flashback Version Query)
- display rows from mulitple committed versions of the database over a range of time
- cannot use VERSIONS to query view, but can CREATE VIEW with it
- VERSIONS BETWEEN must precedes AS OF, as it's defined from the perspective of AS OF
```sql
VERSIONS BETWEEN TIMESTAMP/SCN

UPDATE orders SET SALES_ID = ord_id_seq.NEXTVAL
WHERE ORD_ID < 5;

COMMIT;

SELECT ORD_ID, SALES_ID, VERSIONS_STARTSCN, VERSIONS_ ENDSCN, VERSIONS_OPERATION FROM orders
VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
ORDER BY ORD_ID, VERSIONS_STARTSCN;

SELECT ORD_ID, SALES_ID FROM orders
VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
AS OF TIMESTAMP SYSTIMESTAMP - INTERVAL '0 00:05:00' DAY TO SECOND
ORDER BY ORD_ID;
```
- Pseudo-column
  - VERSIONS_STARTTINE; VERSION_STARTSCN
  - VERSIONS_ENDTIME; VERSIONS_ENDSCN
  - VERSIONS_XID
  - VERSIONS_OPERATION
  
### FLASHBACK_TRANSACTION_QUERY (Flashback Transaction Query)
- XID
- RAWTOHEX(VERSIONS_XID)
#### Undo Retention Period
```sql
-- in sec
SELECT NAME, VALUE
FROM V$SYSTEM_PARAMETER
WHERE NAME LIKE('undo%'); 
```

### Marking time
- SCN: increment for every committed transaction
- **ORA_ROWSCN**
```sql
-- DBA privilege
SELECT DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER FROM dual; 
SELECT CURRENT_SCN FROM V$DATABASE;

SELECT ORA_ROWSCN, ORD_ID,Sales_ID FROM orders; -- SCN for given rows
SELECT TO_TIMESTAMP('2017-04-30 14:30:03.1213','RRRR-MM-DD HH24:MI:SS:FF') FROM dual; --timestamp

-- roughly conversion
SELECT SCN_TO_TIMESTAMP(1244405951) FROM dual;
SELECT TIMESTAMP_TO_SCN(SYSTIMESTAMP) NOW FROM dual;--1244481418

- Moment
CREATE RESTORE POINT order_01;
DROP RESTORE POINT order_01;

SELECT * FROM V$RESTORE_POINT;
```

## PURGE
- permanenetly removes from Recycle Bin
```sql
PURGE TABLE orders;
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
## External table
- its metadata is stored inside the database, and the data it contains is outside of the database
- only SELECT
- no INDEX, CONSTRAINT, UNUSED
```sql
CREATE (OR REPLACE) DIRECTORY dir_name AS dir_ref; -- looks to the OS host the Oracle server
GRANT READ/WRITE ON DIRECTORY dir_name TO usr;
```






