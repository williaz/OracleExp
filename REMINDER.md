- [ ] TABLE has no OR REPLACE, SYNONYM has no ALTER
- [ ] NOT NULL can only be created 'in line', ALTER TABLE .. MODIFY ..
- [ ] INNER JOIN ON AND = INNER JOIN ON WHERE, but OUTER JOIN different [info](http://stackoverflow.com/questions/13132447/difference-between-on-and-where-clauses-in-sql-table-joins)
- [x] CROSS JOIN: happens when without a join condition, 
- [x] USING for Equijoin only, either INNER or OUTER, must share the same column name
  - JOIN USING: No table name prefix is allowed before the column name in the statement(not in SELECT list)
  - USING can be used with multi-columns
```sql
select count(*) from hr.employees natural join hr.departments;
select count(*) from hr.employees join hr.departments using(DEPARTMENT_ID, MANAGER_ID);
```
- [x] JOIN: using table name
  - JOIN ON before WHERE
```sql
create table emp
as 
select * from hr.employees;

create table dep
as 
select * from hr.departments;

select last_name, department_name 
from emp 
join dep
on emp.department_id = dep.department_id;
```
- [x] GROUP BY and HAVING must after WHERE and hierarchical query, but before ORDER BY
  - Using WHERE to exclude the rows before creating groups
  - Scalar subqueries may not be used in a GROUP BY clause
  - cannot use column alias(HAVING also)
- [x] HAVING can only reference columns defined in GROUP BY or aggregate functions
- [x] GROUPING: 
  - require GROUP BY, syntax err
  - there cannot be any superaggregate roows without ROLLUP or CUBE -> GROUPING always return 0
  - GROUPING assigns 1 to each superaggregate row - meaning a row that shows a subtotal or total of the expression specified in GROUPING
  - only valid in a SELECT statement that uses a GROUP BY 
- [x] GROUPING SET: using UNION ALL
- [x] SQL execution order: FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY
- [x] NATURAL JOIN may suprise you, as you don't control the condition
```sql
select * from hr.employees
where EMPLOYEE_ID = ANY (
select EMPLOYEE_ID from hr.employees
join hr.departments using(MANAGER_ID)
MINUS
select EMPLOYEE_ID from hr.employees
natural join hr.departments
);
```
- [x] UNION/INTERSECT/MINUS query: 
  - Column names returned are determined by the first SELECT
  - ORDER BY can only be placed at the very end of the compound query
  - UNION, INTERSECT and MINUS all will eliminate duplicate rows, except UNION ALL
- [x] INDEX and CONSTRAINT has its own namespace
- [x] ALTER SESSION SET TIME_ZONE = 
  - Default local time zone when the session was started (local)
  - Database time zone (dbtimezone): ALTER DATABASE - The time zone may be set to an absolute offset from UTC or to a named region. 
  - Absolute offset from UTC (for example, '+10:00')
  - Time zone region name (for example, 'Asia/Hong_Kong')
- [x] MERGE: 
  - 'delete clause' only affect rows that are a result of the completed 'update clause'
  - cannot update column in the ON condition
- [x] GRANT: grant object privilege on one object per query.
- [x] VERSIONS BETWEEN must precde the AS OF clause
- [x] SEQENCE: if CYCLE presnets, MINVALUE def = 1
- [ ] INDEX are never used for !=, NOT IN, IS NULL
- [x] UPDATE multi-columns in SET
```sql
create table orders(
order_id number,
total number,
sales_id number
);

insert into orders values(1, 5, 2);
update orders set order_id = 2, (total, sales_id) = (select 4, 3 from dual) where order_id = 1;
```
- [x] INSERT 
  - Multi-table INSERT, 
    - if one of the INTO clauses executed on a table and resulted in a constraint violation, then the entire statement fails, and all inserted rows are rolled back. 
    - No sequence genrator is allowed in the subquery
  - DEFAULT value
```sql
drop table worker;
create table worker(
work_id number,
name varchar2(20) default 'xiaoming',
salary number default on null 5000 
);

insert into worker values (1, default, default);
insert into worker values (2, '', '');
insert into worker values (3, null, null);
select * from worker;
```
- [x] DELETE (FROM)
  - DELETE FROM inline view;
- [x] Date + Interval
```sql
select sysdate + to_yminterval('2-1') from dual;
```
- [x] WITH is a clause of SELECT only.
- [x] SAVEPOINT: once a commit event occurs, all existing savepoints are erased from memory
- [x] Data Type:
  - VARCHAR2(n): n [1, 4000]
  - LONG one column per table
  - NUMBER(m,n): n .5 round up
  - INTERVAL DAY TO SECOND also can store fractional seconds
- [x] naming: first char must be a letter, [1, 30], alphanumeric $ _ #
- [x] namespace: non-schema-(User, ROLE, Public SYNONYM), schema-(TABLE, VIEW, SEQUENCE, private SYNONYM, (INDEX), (CONSTRAINT)) 
- [x] USER_CATALOG = CAT; USER_OBJECTS = OBJ
- [x] DROP TABLE list_customers PURGE;
- [x] a table at least has one column
- [x] each DDL is preceded and followed by an implicit commit
- [x] you cannot use * together with any other column in select list, but you can use table prefix to achieve
```sql
select rownum, em.* from hr.employees em;
```
- [x] NOT is evaluated first, then AND, and then OR
- [x] MONTHS_BETWEEN(d1, d2): = d1 - d2
- [x] NULL: IS NULL, but
```sql
update emp set SALARY = null where employee_id = 101;
```
- [x] CREATE VIEW
  - WITH CHECK OPTION: Specify WITH CHECK OPTION to indicate that Oracle Database prohibits any changes to the table or view that would produce rows that are not included in the subquery. 
- [x] ALTER VIEW VW_EMP COMPILE;
- [x] if drop a table upon which an index is based, the index is automatically dropped.
- [x] UNUSED:
  - once UNUSED, never available again, cannot be recovered
  - any constraint or indices on the column will alos be dropped
  - ROLLBACK not effect
  - once UNUSED, you can add new column with the same name
  - still count as part of the 1000 cols limit
- [x] (NOT) EXISTS: syntax- WHERE EXISTS + subquery. (semijoin)
- [x] WITH: the one place within the WITH that does not recognize the subquery name is within the named subquery itself.
- [x] DROP: 
  - if you drop a column with a constraint, the constraint is also dropped. The same is true for any index objects on the column, they are also dropped.
  - DROP TABLE tab (CASCADE CONSTRAINTS): also drop any constraints and index objects on it
- [x] FLASHBACK TABLE: 
  1. restores the dropped table with either its original name or a new assigned name
  2. recovers any indexes, other than bitmap join indexes
  3. all cinstraints are recovered, except for FK that reference other table
  4. Granted privileges are also recovered
  - FLASHBACK TABLE tab1(, tab2, ...) TO BEFORE DROP/TIMESTAMP/SCN/RESTORE POINT (RENAME TO new, ...) 
- [x] CHECK: cannot use with SYSDATE, as SYSDATE is non-deterministic.
- [x] CTAS: any CONSTRAINT or INDEX or any ohter supporting objects that might exist for the source table are not replicated, with one exception: any explicitly created NOT NULL constraints on the queried table are copied into the new table with a system-generated name as part of the table's definition. 
- [x] COLUMN:
  - ALTER TABLE tab ADD/MODIFY: only more than one column need to be enclosed in parentheses
    - you cannot change a column's datatype if the column contains data already: not support Automatic datatype conversion
  - ALTER TABLE tab RENAME COLUMN old TO new
  - ALTER TABLE tab DROP COLUMN col; ALTER TABLE tab DROP (col1, col2, ..); 
    - at least one column
    - if a column is referenced by a FK in another table, add "CASCADE CONSTRAINTS"
  - ALTER TABLE tab SET UNUSED COLUMN col; ALTER TABLE tab SET UNUSED (col1, col2, ..); still keep the storage
```sql
CREATE TABLE orders (
ORD_ID NUMBER,
SALES_ID NUMBER
);

SELECT * 
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'ORDERS';

ALTER TABLE orders ADD ORD_PRICE NUMBER;
ALTER TABLE orders MODIFY ORD_ID NUMBER NOT NULL;
ALTER TABLE orders DROP COLUMN SALES_ID;
ALTER TABLE orders RENAME COLUMN ORD_ID TO OD_ID;
```
- [x] CONSTRAINT:
  - ALTER TABLE tab DISABLE/ENABLE VALIDATE/NOVALIDATE PRIMARY KEY (CASCADE)/UNIQUE(col1, col2, ..)/CONSTRAINT const_name
  - VALIDATE/NOVALIDATE for validating existing rows
  - ENABLE/DISABLE for incoming rows
  - ENABLE = ENABLE VALIDATE; DISABLE = DISABLE NOVALIDATE
  - you cannot DELETE a row in a table if dependent child rows exist
    - 1. DISABLE FK; 
    - 2. create FK 
      - ON DELETE CASCADE: delete child rows
      - ON DELETE SET NULL: set null for the child rows' column
  - DEFERRABLE: def- NOT DEFERRABLE
    - SET CONSTRAINT name/ALL DEFERRED;
    - once a commit occurs, the constraint auto changes state to IMMEDIATE, and the constraints will be applied, if any violatedm all data is rolled back.
  - ALTER TABLE tab RENAME CONSTRAINT old TO new;
  - USING INDEX: only works for PK and UNIQUE
- [x] USER_CATALOG: contains a summary of info abut TABLE, VIEW, SYNONYM, SEQUENCE objects owned by your user account
- [x] USER_OBJECTS: similiar but much more info
- [x] USER_SYNONYMS: private sysnonym
- [x] USER_TAB_PRIVS: object privileges
- [x] V$_, GV_$: dynamic performace views and global ...
- [x] USER_CONSTRAINTS: 
  - C: CHECK or NOT NULL
  - DELETE_RULE: shows if a FK was created with ON DELETE CASCADE or ON DELETE SET NULL
  - SEARCH_CONDITION: inspecting CHECK 
- [x] SYS is the owner of the data dictionary
- [x] COMMENT
  - table and column suport commnet: ALL_TAB_COMMENTS, ALL_COL_COMMNENTS
```sql
COMMENT ON TABLE/COLUMN tab/tab.col IS c1/'';
```
- [x] Hierarchical Query
  - START WITH: identifies the root node, while PK is an ideal way, but it's not required
  - WHERE: if used, must precede the START WITH and CONNECT BY
  - CONNECT_BY_ROOT: connect the row identified by START WITH 
- [x] REGEXP:
  - character classes must be specified in lowercase letters
  - REGEXP_LIKE: does not use the same wildcard operators as LIKE.(% and * are accepted as string literals)
  - REGEXP_REPLACE: replacement def-NULL
- [x] Privilege:
  - CREATE privs also include ALTER and DROP
  - ANY: 
  - ALL PRIVILEGES
  - PUBLIC
```sql 
GRANT CREATE ANY TABLE TO PUBLIC; 
GRANT ALL PRIVILEGES To user;
GRANT ALL PRIVILEGES ON obj To user;
```
- [x] System Privs VS Object Privs:
  - System: WITH ADMIN OPTION; revoke not cascade
  - Obj: WITH GRANT OPTION; revoke do cascade
- [x] Roles exist in a namespace outside of an individual user account
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  



