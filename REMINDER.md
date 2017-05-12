- [ ] TABLE has no OR REPLACE, SYNONYM has no ALTER
- [ ] NOT NULL can only be created 'in line', ALTER TABLE .. MODIFY ..
- [ ] INNER JOIN ON AND = INNER JOIN ON WHERE, but OUTER JOIN different [info](http://stackoverflow.com/questions/13132447/difference-between-on-and-where-clauses-in-sql-table-joins)
- [x] USING for Equijoin only, either INNER or OUTER, must share the same column name
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
