
## OSE Basic Scalar
- DUAL: one row, one column DUMMY
- UPPER(s1), LOWER(s2), INITCAP(s1), LPAD(s1, n, s2), RPAD(s1, n, s2), LTRIM(s1, s2), RTRIM(s1, s2), LENGTH(s)
- TRIM(trim_keyword char FROM source): keyword- LEADING, TRAILING, BOTH(def); 
- CONCAT(s1, s2), s1 || s2
- INSTR(str, substr, start_pos, occurrence)
- SUBSTR(s, pos, len)
- SOUNDEX(s)

- ROUND(n, i), TRUNC(n, i)
- REMAINDER(n1, n2) (may negative), MOD(n1, n2) (FLOOR)

- SYSDATE
- ROUND(dt, fmt_str), TRUNC(d, fmt)
- NEXT_DAY(dt, weekdt_str), LAST_DAY(dt)
- ADD_MONTHS(dt, int), MONTHS_BETWEEN(d1, d2)
- NUMTOYMINTERVAL(n, unit): return INTERVAL YEAR TO MONTH, unit- 'YEAR'/'MONTH'
- NUMTODSINTERVAL(n, unit): unit- 'DAY', 'HOUR', 'MINUTE', 'SECOND'

- NVL(e1, e2): if e1 is NULL, return e2
- DECODE(e,)
- CASE
```sql
CASE exp 
WHEN condition1 THEN action 
WHEN .. THEN .. 
ELSE def_action 
END (AS col)
```
- NULLIF(e1, e2): return NULL, if same; comparing versions

## OSE Basic Aggregated
- can be called from 4 place in SELECT statement: SELECT list, ORDER BY, GROUP BY, HAVING
- COUNT: count non-Null values; but COUNT(*) will count rows with all NULL
```sql
SELECT COUNT(*) AS Manager_num
FROM HR.EMPLOYEES
WHERE MANAGER_ID = 100;

SELECT COUNT (DISTINCT MANAGER_ID) AS Manager_num
FROM HR.EMPLOYEES;
```
- SUM(), MIN(), MAX(), AVG(), MEDIAN()
```sql
SELECT SUM(SALARY), MIN(SALARY), MAX(SALARY), ROUND(AVG(SALARY), 2), MEDIAN(SALARY)
FROM HR.EMPLOYEES;
```
- RANK
```sql
SELECT RANK(10000) WITHIN GROUP (ORDER BY SALARY DESC)
FROM HR.EMPLOYEES;

SELECT RANK(10000, .3) WITHIN GROUP (ORDER BY SALARY DESC, COMMISSION_PCT)
FROM HR.EMPLOYEES
WHERE COMMISSION_PCT IS NOT NULL;
```

- FIRST/LAST: include NULL, performace improvement over self-join/view
```sql
SELECT MIN(SALARY) KEEP (DENSE_RANK FIRST ORDER BY COMMISSION_PCT), MAX(SALARY) KEEP (DENSE_RANK LAST ORDER BY COMMISSION_PCT)
FROM HR.EMPLOYEES
WHERE COMMISSION_PCT IS NOT NULL;
```
- GROUPING

### [Regular Expression Function](https://docs.oracle.com/cd/B12037_01/appdev.101/b10795/adfns_re.htm)
- REGEXP_SUBSTR(source_str, pattern, pos_start, n, match_param): return the substring, def: pos-1, n-1
- REGEXP_INSTR(source_str, pattern, start, n, opt, match_param): def-opt=0, return the location of the pattern, if opt=1, return first position after the pattern
- REGEXP_REPLACE(source_str, pattern, replace_str, start, n, match): 
- REGEXP_LIKE(source_str, pattern, match)
- Match Param value: last char take precedence
  1. 'c': Case-sensitive, def
  2. 'i': Case-insensitive
  3. 'n': enable . to match newline
  4. 'm': treat the source as multi-lines. 
  5. 'x': ignore whitespace
  ```sql
SELECT REGEXP_SUBSTR('123 Maple Avenue', '[[:alpha:] ]+', 1, 1) ADDRESS
FROM dual; --' Maple Avenue'

SELECT REGEXP_SUBSTR('Please call the IT support team: (212)555-1234', '\([[:digit:]]+\)') AREA
FROM dual;
  ```
- Meta Character Operators
  1 () Subexpression
  2 [] reg expression
  3 [^ ] not equal
  4 [. .]: [[.ch.]] as a whole
  5 [: :] character class
  6 [= =] equivalence class
  7 . match any char
  8 ? 0/1 occurrence
  9 * >=0
  10 + >=1
  11 {n1} n1 occurrence
  12 {n1,} >= n1 occurence
  13 {n1, n2} [n1, n2]
  14 \ escape
  15 \n1 Backreference , repeat the 'n1th' subexpression
  16 | or
  17 ^ match only if in beginning
  18 $ match only if at end of 
- Character Class
  1 [:alnum:], [:alpha:], [:digit:], [:xdigit:] hex
  2 [:punct:]
  3 [:blank:], [:space:] -[difference](http://stackoverflow.com/questions/15767863/whats-the-difference-between-space-and-blank)
  4 [:cntrl:] non-printing chars, [:print:]
  5 [:upper:], [:lower:]
  6 [:graph:] = [:punct:] + [:upper:] + [:lower:] + [:digit:]
```sql
DROP TABLE email_list;
CREATE TABLE email_list
(
EMAIL_ID NUMBER(7) PRIMARY KEY,
EMAIL VARCHAR2(120) CHECK (REGEXP_LIKE(EMAIL, '^([[:alnum:]]+)@[[:alnum:]]+.(com|net|org|edu|gov|mil)$'))
);

INSERT INTO email_list VALUES(1, 'will123@gmail.com');
```



## Character Functions Returning Character Values
### CHR
```CHR(n USING NCHAR_CS)```
- ~ (char)
- returns the character having the binary equivalent to n as a VARCHAR2 value
- ASCII
- For single-byte character sets, if n > 256, Oracle returns ```n mod 256```
- USING NCHAR_CS (the national character set)
```sql
SELECT CHR(67)||CHR(65)||CHR(84) "Dog"
  FROM DUAL;

Dog
---
CAT
```
### NCHR
```NCHR(number)```
- equivalent to using the CHR function with the USING NCHAR_CS clause.

### CONCAT
```CONCAT(char1, char2)```
-  returns char1 concatenated with char2
-  Both char1 and char2 can be any of the data types CHAR, VARCHAR2, NCHAR, NVARCHAR2, CLOB, or NCLOB
- The string returned is in the same *character set* as char1.
- eturns the *data type* that results in a lossless conversion

### INITCAP
```INITCAP(char)```
-  returns char, with the first letter of each word in uppercase, all other letters in lowercase.
- delimited by **white space** or characters that are **not alphanumeric**

### LOWER
```LOWER(char)```
-  returns char, with all letters lowercase.
- char can be any of the data types CHAR, VARCHAR2, NCHAR, NVARCHAR2, CLOB, or NCLOB. 
- The return value is the same data type as char

### LPAD
```LDAP(exp1, n, exp2)```
- returns expr1, left-padded **to length** n characters with the sequence of characters in expr2.
- n is the total length of the return value
- def-exp2: blank

### LTRIM
```LTRIM(char, set)```
- removes from the left end of char all of the characters contained in set
- def-set: blank



### NLS_INITCAP, NLS_LOWER, NLS_UPPER
```NLS_INITCAP(char, 'nlsparam')```
- [NLS (National Language Support) is used to define national date, number, currency and language settings.](http://www.orafaq.com/wiki/NLS)

NLSSORT
REGEXP_REPLACE
REGEXP_SUBSTR
REPLACE
RPAD
RTRIM
SOUNDEX
SUBSTR
TRANSLATE
TRANSLATE ... USING
TRIM
UPPER
