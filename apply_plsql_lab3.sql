/*
Devin Erickson
CIT 325
Lab 3
*/

SPOOL lab3.txt

SET SERVEROUTPUT ON
SET VERIFY OFF;


DECLARE
        TYPE list IS RECORD
        (xnum NUMBER
        , xstring  VARCHAR2(20)
        , xdate DATE);
        r LIST;
        lv_input1  VARCHAR2(100);
        lv_input2  VARCHAR2(100);
        lv_input3  VARCHAR2(100);
        v_length NUMBER := 10;
BEGIN
        lv_input1 := '&1';
        lv_input2 := '&2';
        lv_input3 := '&3';

        IF LENGTH(lv_input2) > v_length
        THEN
          lv_input2 := substr(lv_input2, 1, 10);
        END IF;

        r.xnum := lv_input1;
        r.xstring := lv_input2;
        r.xdate := to_date(lv_input3, 'mm/dd/yyyy');

        dbms_output.put_line('Record  [' || r.xnum || ']' || '[' || r.xstring || ']' || '[' || to_char(r.xdate) || ']');

        EXCEPTION
          WHEN others THEN
                dbms_output.put_line('Error!' || SQLERRM);
END;
/

SPOOL OFF

