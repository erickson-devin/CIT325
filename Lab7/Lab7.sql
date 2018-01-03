-- Add your lab here:
-- ----------------------------------------------------------------------
-- Show the output
SET SERVEROUTPUT ON
-- ----------------------------------------------------------------------

-- STEP O: The nested instructions let you make your test cases automatic because you can run the create_video_store.sql script at the beginning of your lab solution.
-- Run setup code
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Begin log file
SPOOL /home/student/Data/cit325/oracle/lab7/lab7.txt;

-- You can fix the table by first validating it’s state with this query:
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name = 'DBA';

-- The next UPDATE statement should be inserted to ensure your iterative test cases all start at the same point, or common data state.
UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

-- A small anonymous block PL/SQL program lets you fix this mistake:
DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER := 2;
 
  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;
 
  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);
 
BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
 
    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;
/

-- It should update four rows, and you can verify the update with the following query:
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

-- You need this at the beginning to create the initial procedure during iterative testing.
BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/

SPOOL OFF;

-- ----------------------------------------------------------------------
-- STEP 1: Create an insert_contact procedure that writes an all or nothing procedure.
--DROP PROCEDURE insert_contact;
CREATE OR REPLACE PROCEDURE insert_contact
( PV_FIRST_NAME VARCHAR2
, PV_MIDDLE_NAME VARCHAR2
, PV_LAST_NAME VARCHAR2
, PV_CONTACT_TYPE VARCHAR2
, PV_ACCOUNT_NUMBER VARCHAR2
, PV_MEMBER_TYPE VARCHAR2
, PV_CREDIT_CARD_NUMBER VARCHAR2
, PV_CREDIT_CARD_TYPE VARCHAR2
, PV_STATE_PROVINCE VARCHAR2
, PV_CITY VARCHAR2
, PV_POSTAL_CODE VARCHAR2
, PV_ADDRESS_TYPE VARCHAR2
, PV_COUNTRY_CODE VARCHAR2
, PV_AREA_CODE VARCHAR2
, PV_TELEPHONE_NUMBER VARCHAR2
, PV_TELEPHONE_TYPE VARCHAR2
, PV_USER_NAME VARCHAR2


  -- Local variables
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);
  
BEGIN
  -- Assign parameter values to local variables for nested assignments to DML subqueries.
  lv_address_type := PV_ADDRESS_TYPE;
  lv_contact_type := PV_CONTACT_TYPE;
  lv_credit_card_type := PV_CREDIT_CARD_TYPE;
  lv_member_type := PV_MEMBER_TYPE;
  lv_telephone_type := PV_TELEPHONE_TYPE;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'MEMBER_TYPE'
    AND      common_lookup_type = lv_member_type)
  , PV_ACCOUNT_NUMBER
  , PV_CREDIT_CARD_NUMBER
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'CREDIT_CARD_TYPE'
    AND      common_lookup_type = lv_credit_card_type)
 );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'CONTACT'
    AND      common_lookup_column = 'CONTACT_TYPE'
    AND      common_lookup_type = lv_contact_type)
  , PV_LAST_NAME
  , PV_FIRST_NAME
  , PV_MIDDLE_NAME );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'ADDRESS'
    AND      common_lookup_column = 'ADDRESS_TYPE'
    AND      common_lookup_type = lv_address_type)
  , PV_CITY
  , PV_STATE_PROVINCE
  , PV_POSTAL_CODE
 );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , address_s1.CURRVAL
  , 1
  , PV_ADDRESS
 );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'TELEPHONE'
    AND      common_lookup_column = 'TELEPHONE_TYPE'
    AND      common_lookup_type = lv_telephone_type)
  , PV_COUNTRY_CODE                                   -- COUNTRY_CODE
  , PV_AREA_CODE                                      -- AREA_CODE
  , PV_TELEPHONE_NUMBER                              -- TELEPHONE_NUMBER
);                        

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END insert_contact;
/

/* Call the insert_contact procedure. */
BEGIN
  insert_contact
  ( PV_FIRST_NAME => 'Charles'
  , PV_MIDDLE_NAME => 'Francis'
  , PV_LAST_NAME => 'Xavier'
  , PV_CONTACT_TYPE => 'CUSTOMER'
  , PV_ACCOUNT_NUMBER => 'SLC-000008'
  , PV_MEMBER_TYPE => 'INDIVIDUAL'
  , PV_CREDIT_CARD_NUMBER => '7777-6666-5555-4444'
  , PV_CREDIT_CARD_TYPE => 'DISCOVER_CARD'
  , PV_STATE_PROVINCE => 'Maine'
  , PV_CITY => 'Milbridge'
  , PV_POSTAL_CODE => '04658'
  , PV_ADDRESS_TYPE => 'HOME'
  , PV_COUNTRY_CODE => '001'
  , PV_AREA_CODE => '207'
  , PV_TELEPHONE_NUMBER => '111-1234'
  , PV_TELEPHONE_TYPE => 'HOME'
  , PV_USER_NAME => 'DBA 2');
END;
/

-- After you call the insert_contact procedure, you should be able to run the following verification query:
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab7/lab7.txt append;

  COL full_name      FORMAT A24
  COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
  COL address        FORMAT A22
  COL telephone      FORMAT A14
 
  SELECT c.first_name
  ||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
         END
  ||     c.last_name AS full_name
  ,      m.account_number
  ,      a.city || ', ' || a.state_province AS address
  ,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
  FROM   member m INNER JOIN contact c
  ON     m.member_id = c.member_id INNER JOIN address a
  ON     c.contact_id = a.contact_id INNER JOIN telephone t
  ON     c.contact_id = t.contact_id
  AND    a.address_id = t.address_id
  WHERE  c.last_name = 'Xavier';

SPOOL OFF;

-- ----------------------------------------------------------------------
-- STEP 2: Modify the insert_contact definer rights procedure into an autonomous insert_contact invoker rights procedure.

CREATE OR REPLACE PROCEDURE insert_contact
( PV_FIRST_NAME VARCHAR2
, PV_MIDDLE_NAME VARCHAR2
, PV_LAST_NAME VARCHAR2
, PV_CONTACT_TYPE VARCHAR2
, PV_ACCOUNT_NUMBER VARCHAR2
, PV_MEMBER_TYPE VARCHAR2
, PV_CREDIT_CARD_NUMBER VARCHAR2
, PV_CREDIT_CARD_TYPE VARCHAR2
, PV_STATE_PROVINCE VARCHAR2
, PV_CITY VARCHAR2
, PV_POSTAL_CODE VARCHAR2
, PV_ADDRESS_TYPE VARCHAR2
, PV_COUNTRY_CODE VARCHAR2
, PV_AREA_CODE VARCHAR2
, PV_TELEPHONE_NUMBER VARCHAR2
, PV_TELEPHONE_TYPE VARCHAR2
, PV_USER_NAME VARCHAR2


  -- Local variables
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);

/*Designate as an autononmous program. */
PRAGMA AUTONOMOUS_TRANSACTION;
  
BEGIN
  -- Assign parameter values to local variables for nested assignments to DML subqueries.
  lv_address_type := PV_ADDRESS_TYPE;
  lv_contact_type := PV_CONTACT_TYPE;
  lv_credit_card_type := PV_CREDIT_CARD_TYPE;
  lv_member_type := PV_MEMBER_TYPE;
  lv_telephone_type := PV_TELEPHONE_TYPE;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'MEMBER_TYPE'
    AND      common_lookup_type = lv_member_type)
  , PV_ACCOUNT_NUMBER
  , PV_CREDIT_CARD_NUMBER
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'CREDIT_CARD_TYPE'
    AND      common_lookup_type = lv_credit_card_type)
 );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'CONTACT'
    AND      common_lookup_column = 'CONTACT_TYPE'
    AND      common_lookup_type = lv_contact_type)
  , PV_LAST_NAME
  , PV_FIRST_NAME
  , PV_MIDDLE_NAME );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'ADDRESS'
    AND      common_lookup_column = 'ADDRESS_TYPE'
    AND      common_lookup_type = lv_address_type)
  , PV_CITY
  , PV_STATE_PROVINCE
  , PV_POSTAL_CODE
 );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , address_s1.CURRVAL
  , 1
  , PV_ADDRESS
 );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID

  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'TELEPHONE'
    AND      common_lookup_column = 'TELEPHONE_TYPE'
    AND      common_lookup_type = lv_telephone_type)
  , PV_COUNTRY_CODE                                   -- COUNTRY_CODE
  , PV_AREA_CODE                                      -- AREA_CODE
  , PV_TELEPHONE_NUMBER                              -- TELEPHONE_NUMBER
);                        

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END insert_contact;
/

/* Call the insert_contact procedure. */
BEGIN
  insert_contact( PV_FIRST_NAME => 'Maura'
  , PV_MIDDLE_NAME => 'Jane'
  , PV_LAST_NAME => 'Haggerty'
  , PV_CONTACT_TYPE => 'CUSTOMER'
  , PV_ACCOUNT_NUMBER => 'SLC-000009'
  , PV_MEMBER_TYPE => 'INDIVIDUAL'
  , PV_CREDIT_CARD_NUMBER => '8888-7777-6666-5555'
  , PV_CREDIT_CARD_TYPE => 'MASTER_CARD'
  , PV_STATE_PROVINCE => 'Maine'
  , PV_CITY => 'Bangor'
  , PV_POSTAL_CODE => '04401'
  , PV_ADDRESS_TYPE => 'HOME'
  , PV_COUNTRY_CODE => '001'
  , PV_AREA_CODE => '207'
  , PV_TELEPHONE_NUMBER => '111-1234'
  , PV_TELEPHONE_TYPE => 'HOME'
  , PV_USER_NAME => 'DBA 2');
END;
/

-- After you call the insert_contact procedure, you should be able to run the following verification query:
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab7/lab7.txt append;

COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14
 
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Haggerty';

SPOOL OFF;

-- ----------------------------------------------------------------------
-- STEP 3: Modify the insert_contact invoker rights procedure into an autonomous insert_contact definer rights function that returns a number.

DROP PROCEDURE insert_contact;
CREATE OR REPLACE FUNCTION insert_contact IS
( PV_FIRST_NAME VARCHAR2
, PV_MIDDLE_NAME VARCHAR2
, PV_LAST_NAME VARCHAR2
, PV_CONTACT_TYPE VARCHAR2
, PV_ACCOUNT_NUMBER VARCHAR2
, PV_MEMBER_TYPE VARCHAR2
, PV_CREDIT_CARD_NUMBER VARCHAR2
, PV_CREDIT_CARD_TYPE VARCHAR2
, PV_STATE_PROVINCE VARCHAR2
, PV_CITY VARCHAR2
, PV_POSTAL_CODE VARCHAR2
, PV_ADDRESS_TYPE VARCHAR2
, PV_COUNTRY_CODE VARCHAR2
, PV_AREA_CODE VARCHAR2
, PV_TELEPHONE_NUMBER VARCHAR2
, PV_TELEPHONE_TYPE VARCHAR2
, PV_USER_NAME VARCHAR2


  -- Local variables
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);

/*Designate as an autononmous program. */
PRAGMA AUTONOMOUS_TRANSACTION;
  
BEGIN
  -- Assign parameter values to local variables for nested assignments to DML subqueries.
  lv_address_type := PV_ADDRESS_TYPE;
  lv_contact_type := PV_CONTACT_TYPE;
  lv_credit_card_type := PV_CREDIT_CARD_TYPE;
  lv_member_type := PV_MEMBER_TYPE;
  lv_telephone_type := PV_TELEPHONE_TYPE;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'MEMBER_TYPE'
    AND      common_lookup_type = lv_member_type)
  , PV_ACCOUNT_NUMBER
  , PV_CREDIT_CARD_NUMBER
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'CREDIT_CARD_TYPE'
    AND      common_lookup_type = lv_credit_card_type)
 );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'CONTACT'
    AND      common_lookup_column = 'CONTACT_TYPE'
    AND      common_lookup_type = lv_contact_type)
  , PV_LAST_NAME
  , PV_FIRST_NAME
  , PV_MIDDLE_NAME );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'ADDRESS'
    AND      common_lookup_column = 'ADDRESS_TYPE'
    AND      common_lookup_type = lv_address_type)
  , PV_CITY
  , PV_STATE_PROVINCE
  , PV_POSTAL_CODE
 );  

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , address_s1.CURRVAL
  , 1
  , PV_ADDRESS
 );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'TELEPHONE'
    AND      common_lookup_column = 'TELEPHONE_TYPE'
    AND      common_lookup_type = lv_telephone_type)
  , PV_COUNTRY_CODE                                   -- COUNTRY_CODE
  , PV_AREA_CODE                                      -- AREA_CODE
  , PV_TELEPHONE_NUMBER                              -- TELEPHONE_NUMBER
);                        

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END insert_contact;
/

/* Call the insert_contact funtion. */
BEGIN
  insert_function( PV_FIRST_NAME => 'Harriet'
  , PV_MIDDLE_NAME => 'Mary'
  , PV_LAST_NAME => ' 	McDonnell'
  , PV_CONTACT_TYPE => 'CUSTOMER'
  , PV_ACCOUNT_NUMBER => 'SLC-000010'
  , PV_MEMBER_TYPE => 'INDIVIDUAL'
  , PV_CREDIT_CARD_NUMBER => '9999-8888-7777-6666'
  , PV_CREDIT_CARD_TYPE => 'VISA_CARD'
  , PV_STATE_PROVINCE => 'Maine'
  , PV_CITY => 'Orono'
  , PV_POSTAL_CODE => '04469'
  , PV_ADDRESS_TYPE => 'HOME'
  , PV_COUNTRY_CODE => '001'
  , PV_AREA_CODE => '207'
  , PV_TELEPHONE_NUMBER => '111-1234'
  , PV_TELEPHONE_TYPE => 'HOME'
  , PV_USER_NAME => 'DBA 2');
END;
/

-- After running the anonymous block, you can run the following query to verify that you’ve inserted the values from the anonymous block.
SPOOL /home/student/Data/cit325/oracle/lab7/lab7.txt append;

COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14
 
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'McDonnell';

SPOOL OFF;

-- ----------------------------------------------------------------------
-- STEP 4: This step requires that you create a get_contact object table function, which requires a contact_obj SQL object type and a contact_tab SQL collection type (page 318).

-- You should be able to test the function with the following query (like the example on page 319, or explanation in Appendix C on pages 958-960):
SPOOL /home/student/Data/cit325/oracle/lab7/lab7.txt append;

SET PAGESIZE 999
COL full_name FORMAT A24
SELECT first_name || CASE
                       WHEN middle_name IS NOT NULL
                       THEN ' ' || middle_name || ' '
                       ELSE ' '
                     END || last_name AS full_name
FROM   TABLE(get_contact);

SPOOL OFF;

EXIT;