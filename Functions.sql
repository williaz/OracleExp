SELECT CHR(67) character FROM DUAL;
SELECT CONCAT('Will ', 'best') FROM dual;
SELECT INITCAP('start page one to re''ad') FROM dual;
SELECT LOWER('McLean is a Last Name') FROM dual;
SELECT LPAD('name: last: first:', 30, '#') FROM dual;
SELECT LTRIM('#$####$$code ss 233#@# ', '#$') FROM dual;
SELECT NCHR(67) AS NC, CHR(67) AS C, CHR(67 USING NCHAR_CS) AS CU FROM dual;
SELECT NLS_INITCAP('start page one to re''ad') AS WO,  NLS_INITCAP('start page one to re''ad', 'NLS_SORT = XDutch') AS W FROM dual;
SELECT * FROM nls_session_parameters;
SELECT * FROM nls_database_parameters;
