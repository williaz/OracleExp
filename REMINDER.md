- [ ] TABLE has no OR REPLACE, SYNONYM has no ALTER
- [ ] NOT NULL can only be created 'in line', ALTER TABLE .. MODIFY ..
- [ ] INNER JOIN ON AND = INNER JOIN ON WHERE, but OUTER JOIN different [info](http://stackoverflow.com/questions/13132447/difference-between-on-and-where-clauses-in-sql-table-joins)
- [x] USING for Equijoin only, either INNER or OUTER, must share the same column name
- [x] JOIN USING: No table name prefix is allowed before the column name in the statement(not in SELECT list)
- [ ] GROUP BY and HAVING must after WHERE and hierarchical query, but before ORDER BY
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
- [x] MERGE: 'delete clause' only affect rows that are a result of the completed 'update clause'
- [x] GRANT: grant object privilege on one object per query.
- [x] VERSIONS BETWEEN must precde the AS OF clause
- [x] SEQENCE: if CYCLE presnets, MINVALUE def = 1
- [ ] GROUPING assigns 1 to each superaggregate row - meaning a row that shows a subtotal or total of the expression specified in GROUPING
