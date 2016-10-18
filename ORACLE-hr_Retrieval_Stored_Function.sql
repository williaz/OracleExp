CREATE OR REPLACE function emp_count(dept_id in Number)
return Number is cnt Number(3):=0;
BEGIN
SELECT count(*) INTO cnt
FROM employees e
WHERE e.department_id = dept_id;
RETURN cnt;
END;
/

SELECT department_name AS deptname, emp_count(department_id)
FROM departments;

CREATE OR REPLACE function member_count(emp_id in NUMBER)
RETURN Number is cnt Number(3) := 0;
BEGIN
SELECT count(*) INTO cnt
FROM employees e
WHERE e.manager_id = emp_id;
RETURN cnt;
END;
/

SELECT * 
FROM (SELECT employee_id AS em_id, first_name, last_name, member_count(employee_id)AS m_cnt FROM employees)
WHERE m_cnt!=0; 
