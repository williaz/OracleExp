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









