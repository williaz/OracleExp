
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
