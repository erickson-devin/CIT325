SPOOL Lab2.txt
 
SET SERVEROUTPUT ON SIZE 2000
SET VERIFY OFF
 
BEGIN
  dbms_output.put_line('Hello '||'&1'||'!');
END;
/
 
SPOOL OFF
