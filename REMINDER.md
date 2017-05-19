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
- [x] HAVING can only reference columns defined in GROUP BY or aggregate functions
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
- [ ] GROUPING assigns 1 to each superaggregate row - meaning a row that shows a subtotal or total of the expression specified in GROUPING
  - only valid in a SELECT statement that uses a GROUP BY 
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
- [x] INSERT DEFAULT value
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
- [x] UNUSED:
  - once UNUSED, never available again, cannot be recovered
  - any constraint or indices on the column will alos be dropped
  - ROLLBACK not effect
  - once UNUSED, you can add new column with the same name
  - still count as part of the 1000 cols limit


