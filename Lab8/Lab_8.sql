-- Add your lab here:
-- ----------------------------------------------------------------------
-- Show the output
SET SERVEROUTPUT ON
-- ----------------------------------------------------------------------

-- Run setup code
--@/home/student/Data/cit325/oracle/lab7/apply_plsql_lab7.sql

-- ----------------------------------------------------------------------
/* STEP 1: Create a contact_package package specification that holds 
overloaded insert_contact procedures. One procedure supports batch 
programs with a user’s name and another supports authenticated web forms 
with a user’s ID; where the ID is a value from the system_user_id 
column of the system_user table. */
-- ----------------------------------------------------------------------

-- Begin log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt;

-- Explicitly drop the CONTACT_PACKAGE and then create it.
DROP PACKAGE contact_package;

CREATE OR REPLACE PACKAGE contact_package IS
        PROCEDURE insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_name           VARCHAR2 );
        PROCEDURE insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_id             NUMBER );
        
/*        FUNCTION insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_name           VARCHAR2 );
        FUNCTION insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_id             NUMBER ); */
END contact_package;
/
SPOOL OFF;
-- ----------------------------------------------------------------------
/* Step 2: Create a contact_package package body that implements two 
           insert_contact procedures. */
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
/* Create the CONTACT_PACKAGE package body. */
-- Procedure 1
-- ----------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY contact_package IS
        PROCEDURE insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_name           VARCHAR2 )IS
 
/* Declare local constants. */
        lv_creation_date     DATE := SYSDATE;
 
/* Declare a who-audit ID variable. */
        lv_created_by        NUMBER;
 
/* Declare type variables. */
        lv_member_type       NUMBER;
        lv_credit_card_type  NUMBER;
        lv_contact_type      NUMBER;
        lv_address_type      NUMBER;
        lv_telephone_type    NUMBER;
	lv_user_id           NUMBER;
 
/* Declare a local cursor. */
        CURSOR get_lookup_type
        ( cv_table_name    VARCHAR2
        , cv_column_name   VARCHAR2
        , cv_type_name     VARCHAR2 ) IS
        SELECT common_lookup_id
        FROM   common_lookup
        WHERE  common_lookup_table = cv_table_name
        AND    common_lookup_column = cv_column_name
        AND    common_lookup_type = cv_type_name;

BEGIN
/* Get the member_type ID value. */
        FOR i IN get_lookup_type('MEMBER','MEMBER_TYPE',pv_member_type) LOOP
        lv_member_type := i.common_lookup_id;
        END LOOP;
 
/* Get the credit_card_type ID value. */
        FOR i IN get_lookup_type('MEMBER','CREDIT_CARD_TYPE',pv_credit_card_type) LOOP
        lv_credit_card_type := i.common_lookup_id;
        END LOOP;
 
/* Get the contact_type ID value. */
        FOR i IN get_lookup_type('CONTACT','CONTACT_TYPE',pv_contact_type) LOOP
        lv_contact_type := i.common_lookup_id;
        END LOOP;
 
/* Get the address_type ID value. */
        FOR i IN get_lookup_type('ADDRESS','ADDRESS_TYPE',pv_address_type) LOOP
        lv_address_type := i.common_lookup_id;
        END LOOP;
 
/* Get the telephone_type ID value. */
        FOR i IN get_lookup_type('TELEPHONE','TELEPHONE_TYPE',pv_telephone_type) LOOP
        lv_telephone_type := i.common_lookup_id;
        END LOOP;
 
/* Get the system user ID value. */
        SELECT system_user_id
        INTO   lv_created_by
        FROM   system_user
        WHERE  system_user_name = pv_user_name;
 
/* Set save point. */
        SAVEPOINT start_point;
 
-- Insert into member table.
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
        , lv_member_type
        , pv_account_number
        , pv_credit_card_number
        , lv_credit_card_type
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date);
 
/* Insert into contact table. */
        INSERT INTO contact
        ( contact_id
        , member_id
        , contact_type
        , first_name
        , middle_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( contact_s1.NEXTVAL
        , member_s1.CURRVAL
        , lv_contact_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Insert into ADDRESS table. */
        INSERT INTO address
        ( address_id
        , contact_id
        , address_type
         , city
         , state_province
         , postal_code
         , created_by
         , creation_date
         , last_updated_by
         , last_update_date )
         VALUES
         ( address_s1.NEXTVAL
         , contact_s1.CURRVAL
         , lv_address_type
         , pv_city
         , pv_state_province
         , pv_postal_code
         , lv_created_by
         , lv_creation_date
         , lv_created_by
         , lv_creation_date); 
 
/* Insert into telephone table. */
        INSERT INTO telephone
        ( telephone_id
        , contact_id
        , address_id
        , telephone_type
        , country_code
        , area_code
        , telephone_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( telephone_s1.NEXTVAL
        , contact_s1.CURRVAL
        , address_s1.CURRVAL
        , lv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Commit the writes to all four tables. */
COMMIT;
 
EXCEPTION
/* Catch all errors. */
        WHEN OTHERS THEN
                dbms_output.put_line('['||lv_debug||']['||lv_debug_id||']');
                dbms_output.put_line('ERROR IN PROCEDURE 1: '||SQLERRM);
                ROLLBACK TO start_place;
END;

-- ----------------------------------------------------------------------
-- Procedure 2
-- ----------------------------------------------------------------------
        PROCEDURE insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_id             VARCHAR2 )IS
 
/* Declare local constants. */
        lv_creation_date     DATE := SYSDATE;
 
/* Declare a who-audit ID variable. */
        lv_created_by        NUMBER;
 
/* Declare type variables. */
        lv_member_type       NUMBER;
        lv_credit_card_type  NUMBER;
        lv_contact_type      NUMBER;
        lv_address_type      NUMBER;
        lv_telephone_type    NUMBER;
	lv_user_id           NUMBER;
 
/* Declare a local cursor. */
--        CURSOR get_lookup_type
--        ( cv_table_name    VARCHAR2
--        , cv_column_name   VARCHAR2
--        , cv_type_name     VARCHAR2 ) IS
--        SELECT common_lookup_id
--        FROM   common_lookup
--        WHERE  common_lookup_table = cv_table_name
--        AND    common_lookup_column = cv_column_name
--        AND    common_lookup_type = cv_type_name;

--Get Member Cursor
        CURSOR get_member (cv_account_number VARCHAR2) IS
        SELECT m.member_id
        FROM member m
        WHERE m.account_number = cv_account_number;
 
BEGIN
/* Assign a value when provided for pv_user_id. */
--	lv_user_id := NVL(pv_user_id,-1);

/* Get the member_type ID value. */
        FOR i IN get_lookup_type('MEMBER','MEMBER_TYPE',pv_member_type) LOOP
        lv_member_type := i.common_lookup_id;
        END LOOP;
 
/* Get the credit_card_type ID value. */
        FOR i IN get_lookup_type('MEMBER','CREDIT_CARD_TYPE',pv_credit_card_type) LOOP
        lv_credit_card_type := i.common_lookup_id;
        END LOOP;
 
/* Get the contact_type ID value. */
        FOR i IN get_lookup_type('CONTACT','CONTACT_TYPE',pv_contact_type) LOOP
        lv_contact_type := i.common_lookup_id;
        END LOOP;
 
/* Get the address_type ID value. */
        FOR i IN get_lookup_type('ADDRESS','ADDRESS_TYPE',pv_address_type) LOOP
        lv_address_type := i.common_lookup_id;
        END LOOP;
 
/* Get the telephone_type ID value. */
        FOR i IN get_lookup_type('TELEPHONE','TELEPHONE_TYPE',pv_telephone_type) LOOP
        lv_telephone_type := i.common_lookup_id;
        END LOOP;
 
/* Set save point. */
        SAVEPOINT start_point;

-- Open get Member Cursor
        OPEN get_member cursor);
        FETCH get_member INTO lv_member_id;

-- Insert row when one does not exist
        IF get_member%NOTFOUND THEN
 
/* Insert into member table. */
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
        , lv_member_type
        , pv_account_number
        , pv_credit_card_number
        , lv_credit_card_type
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date);
 
/* Insert into contact table. */
        INSERT INTO contact
        ( contact_id
        , member_id
        , contact_type
        , first_name
        , middle_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( contact_s1.NEXTVAL
        , member_s1.CURRVAL
        , lv_contact_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Insert into ADDRESS table. */
        INSERT INTO address
        ( address_id
        , contact_id
        , address_type
         , city
         , state_province
         , postal_code
         , created_by
         , creation_date
         , last_updated_by
         , last_update_date )
         VALUES
         ( address_s1.NEXTVAL
         , contact_s1.CURRVAL
         , lv_address_type
         , pv_city
         , pv_state_province
         , pv_postal_code
         , lv_created_by
         , lv_creation_date
         , lv_created_by
         , lv_creation_date); 
 
/* Insert into telephone table. */
        INSERT INTO telephone
        ( telephone_id
        , contact_id
        , address_id
        , telephone_type
        , country_code
        , area_code
        , telephone_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( telephone_s1.NEXTVAL
        , contact_s1.CURRVAL
        , address_s1.CURRVAL
        , lv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Commit the writes to all four tables. */
COMMIT;
 
EXCEPTION
/* Catch all errors. */
        WHEN OTHERS THEN
                dbms_output.put_line('ERROR IN PROCEDURE 2: '||SQLERRM);
		ROLLBACK TO start_place;
END contact_package;
/
LIST
SHOW ERRORS

-- ----------------------------------------------------------------------
/*Insert System Users*/
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

/* Update the system_user table. */
        INSERT INTO system_user
        ( system_user_id
        , system_user_name 
        , system_user_group_id
        , system_user_type
        , first_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date)
        VALUES
        ( '6'
        , 'BONDSB'
        , '1'
        , '2'
        , 'Barry'
        , 'Bonds'
        , '1'
        , SYSDATE
        , '1'
        , SYSDATE);

        INSERT INTO system_user
        ( system_user_id
        , system_user_name 
        , system_user_group_id
        , system_user_type
        , first_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date)
        VALUES
        ( '7'
        , 'OWENSR'
        , '1'
        , '2'
        , 'Wardell'
        , 'Curry'
        , '1'
        , SYSDATE
        , '1'
        , SYSDATE);

        INSERT INTO system_user
        ( system_user_id
        , system_user_name 
        , system_user_group_id
        , system_user_type
        , first_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date)
        VALUES
        ( '-1'
        , 'ANONYMOUS'
        , '1'
        , '2'
        , ''
        , ''
        , '1'
        , SYSDATE
        , '1'
        , SYSDATE);

SPOOL OFF;

-- ----------------------------------------------------------------------
/* You can confirm the inserts with the following query: */
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

COL system_user_id  FORMAT 9999  HEADING "System|User ID"
COL system_user_name FORMAT A12  HEADING "System|User Name"
COL first_name       FORMAT A10  HEADING "First|Name"
COL middle_initial   FORMAT A2   HEADING "MI"
COL last_name        FORMAT A10  HeADING "Last|Name"
SELECT system_user_id
,      system_user_name
,      first_name
,      middle_initial
,      last_name
FROM   system_user
WHERE  last_name IN ('Bonds','Curry')
OR     system_user_name = 'ANONYMOUS';

SPOOL OFF;

-- ----------------------------------------------------------------------
/*Insert Contacts*/
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

BEGIN
        insert_contact
        ( pv_first_name => 'Charlie'
        , pv_middle_name => ''
        , pv_last_name => 'Brown'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000011'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => 'DBA 3')
        , pv_user_id => '');        
END;
/
BEGIN
        contact_package.insert_contact
        ( pv_first_name => 'Peppermint'
        , pv_middle_name => ''
        , pv_last_name => 'Patty'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000011'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => '')
        , pv_user_id => '');        
END;
/
BEGIN
        contact_package.insert_contact
        ( pv_first_name => 'Sally'
        , pv_middle_name => ''
        , pv_last_name => 'Brown'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000011'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => ''
        , pv_user_id => '6');        
END;
/
SPOOL OFF;

-- ----------------------------------------------------------------------
/* You can confirm the inserts with the following query: */
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

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
WHERE  c.last_name IN ('Brown','Patty');

SPOOL OFF;

-- ----------------------------------------------------------------------
/* Step 3: Recreate the contact_package package body by converting the 
insert_contact procedures into overloaded functions. The overloaded 
functions should produce the same results as the overloaded procedures. */
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
/* Create the insert_contact overloaded functions. */
-- Funtion 1
-- ----------------------------------------------------------------------

DROP PROCEDURE insert_contact;
CREATE OR REPLACE PACKAGE BODY contact_package IS
        FUNCTION insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_name           VARCHAR2 )IS
 
/* Declare local constants. */
        lv_creation_date     DATE := SYSDATE;
 
/* Declare a who-audit ID variable. */
        lv_created_by        NUMBER;
 
/* Declare type variables. */
        lv_member_type       NUMBER;
        lv_credit_card_type  NUMBER;
        lv_contact_type      NUMBER;
        lv_address_type      NUMBER;
        lv_telephone_type    NUMBER;
	lv_user_id           NUMBER;
 
/* Declare a local cursor. */
        CURSOR get_lookup_type
        ( cv_table_name    VARCHAR2
        , cv_column_name   VARCHAR2
        , cv_type_name     VARCHAR2 ) IS
        SELECT common_lookup_id
        FROM   common_lookup
        WHERE  common_lookup_table = cv_table_name
        AND    common_lookup_column = cv_column_name
        AND    common_lookup_type = cv_type_name;

BEGIN
/* Get the member_type ID value. */
        FOR i IN get_lookup_type('MEMBER','MEMBER_TYPE',pv_member_type) LOOP
        lv_member_type := i.common_lookup_id;
        END LOOP;
 
/* Get the credit_card_type ID value. */
        FOR i IN get_lookup_type('MEMBER','CREDIT_CARD_TYPE',pv_credit_card_type) LOOP
        lv_credit_card_type := i.common_lookup_id;
        END LOOP;
 
/* Get the contact_type ID value. */
        FOR i IN get_lookup_type('CONTACT','CONTACT_TYPE',pv_contact_type) LOOP
        lv_contact_type := i.common_lookup_id;
        END LOOP;
 
/* Get the address_type ID value. */
        FOR i IN get_lookup_type('ADDRESS','ADDRESS_TYPE',pv_address_type) LOOP
        lv_address_type := i.common_lookup_id;
        END LOOP;
 
/* Get the telephone_type ID value. */
        FOR i IN get_lookup_type('TELEPHONE','TELEPHONE_TYPE',pv_telephone_type) LOOP
        lv_telephone_type := i.common_lookup_id;
        END LOOP;
 
/* Get the system user ID value. */
        SELECT system_user_id
        INTO   lv_created_by
        FROM   system_user
        WHERE  system_user_name = pv_user_name;
 
/* Set save point. */
        SAVEPOINT start_point;
 
-- Insert into member table.
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
        , lv_member_type
        , pv_account_number
        , pv_credit_card_number
        , lv_credit_card_type
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date);
 
/* Insert into contact table. */
        INSERT INTO contact
        ( contact_id
        , member_id
        , contact_type
        , first_name
        , middle_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( contact_s1.NEXTVAL
        , member_s1.CURRVAL
        , lv_contact_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Insert into ADDRESS table. */
        INSERT INTO address
        ( address_id
        , contact_id
        , address_type
         , city
         , state_province
         , postal_code
         , created_by
         , creation_date
         , last_updated_by
         , last_update_date )
         VALUES
         ( address_s1.NEXTVAL
         , contact_s1.CURRVAL
         , lv_address_type
         , pv_city
         , pv_state_province
         , pv_postal_code
         , lv_created_by
         , lv_creation_date
         , lv_created_by
         , lv_creation_date); 
 
/* Insert into telephone table. */
        INSERT INTO telephone
        ( telephone_id
        , contact_id
        , address_id
        , telephone_type
        , country_code
        , area_code
        , telephone_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( telephone_s1.NEXTVAL
        , contact_s1.CURRVAL
        , address_s1.CURRVAL
        , lv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Commit the writes to all four tables. */
COMMIT;
 
EXCEPTION
/* Catch all errors. */
        WHEN OTHERS THEN
                dbms_output.put_line('['||lv_debug||']['||lv_debug_id||']');
                dbms_output.put_line('ERROR IN PROCEDURE 1: '||SQLERRM);
                ROLLBACK TO start_place;
END;

-- ----------------------------------------------------------------------
-- Function 2
-- ----------------------------------------------------------------------
CREATE PACKAGE BODY contact_package IS
        FUNCTION insert_contact
        ( pv_first_name          VARCHAR2
        , pv_middle_name         VARCHAR2
        , pv_last_name           VARCHAR2
        , pv_contact_type        VARCHAR2
        , pv_account_number      VARCHAR2
        , pv_member_type         VARCHAR2
        , pv_credit_card_number  VARCHAR2
        , pv_credit_card_type    VARCHAR2
        , pv_city                VARCHAR2
        , pv_state_province      VARCHAR2
        , pv_postal_code         VARCHAR2
        , pv_address_type        VARCHAR2
        , pv_country_code        VARCHAR2
        , pv_area_code           VARCHAR2
        , pv_telephone_number    VARCHAR2
        , pv_telephone_type      VARCHAR2
        , pv_user_id             VARCHAR2 )IS
 
/* Declare local constants. */
        lv_creation_date     DATE := SYSDATE;
 
/* Declare a who-audit ID variable. */
        lv_created_by        NUMBER;
 
/* Declare type variables. */
        lv_member_type       NUMBER;
        lv_credit_card_type  NUMBER;
        lv_contact_type      NUMBER;
        lv_address_type      NUMBER;
        lv_telephone_type    NUMBER;
	lv_user_id           NUMBER;
 
/* Declare a local cursor. */
--        CURSOR get_lookup_type
--        ( cv_table_name    VARCHAR2
--        , cv_column_name   VARCHAR2
--        , cv_type_name     VARCHAR2 ) IS
--        SELECT common_lookup_id
--        FROM   common_lookup
--        WHERE  common_lookup_table = cv_table_name
--        AND    common_lookup_column = cv_column_name
--        AND    common_lookup_type = cv_type_name;

--Get Member Cursor
        CURSOR get_member (cv_account_number VARCHAR2) IS
        SELECT m.member_id
        FROM member m
        WHERE m.account_number = cv_account_number;
 
BEGIN
/* Assign a value when provided for pv_user_id. */
--	lv_user_id := NVL(pv_user_id,-1);

/* Get the member_type ID value. */
        FOR i IN get_lookup_type('MEMBER','MEMBER_TYPE',pv_member_type) LOOP
        lv_member_type := i.common_lookup_id;
        END LOOP;
 
/* Get the credit_card_type ID value. */
        FOR i IN get_lookup_type('MEMBER','CREDIT_CARD_TYPE',pv_credit_card_type) LOOP
        lv_credit_card_type := i.common_lookup_id;
        END LOOP;
 
/* Get the contact_type ID value. */
        FOR i IN get_lookup_type('CONTACT','CONTACT_TYPE',pv_contact_type) LOOP
        lv_contact_type := i.common_lookup_id;
        END LOOP;
 
/* Get the address_type ID value. */
        FOR i IN get_lookup_type('ADDRESS','ADDRESS_TYPE',pv_address_type) LOOP
        lv_address_type := i.common_lookup_id;
        END LOOP;
 
/* Get the telephone_type ID value. */
        FOR i IN get_lookup_type('TELEPHONE','TELEPHONE_TYPE',pv_telephone_type) LOOP
        lv_telephone_type := i.common_lookup_id;
        END LOOP;
 
/* Set save point. */
        SAVEPOINT start_point;

-- Open get Member Cursor
        OPEN get_member cursor);
        FETCH get_member INTO lv_member_id;

-- Insert row when one does not exist
        IF get_member%NOTFOUND THEN
 
/* Insert into member table. */
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
        , lv_member_type
        , pv_account_number
        , pv_credit_card_number
        , lv_credit_card_type
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date);
 
/* Insert into contact table. */
        INSERT INTO contact
        ( contact_id
        , member_id
        , contact_type
        , first_name
        , middle_name
        , last_name
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( contact_s1.NEXTVAL
        , member_s1.CURRVAL
        , lv_contact_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Insert into ADDRESS table. */
        INSERT INTO address
        ( address_id
        , contact_id
        , address_type
         , city
         , state_province
         , postal_code
         , created_by
         , creation_date
         , last_updated_by
         , last_update_date )
         VALUES
         ( address_s1.NEXTVAL
         , contact_s1.CURRVAL
         , lv_address_type
         , pv_city
         , pv_state_province
         , pv_postal_code
         , lv_created_by
         , lv_creation_date
         , lv_created_by
         , lv_creation_date); 
 
/* Insert into telephone table. */
        INSERT INTO telephone
        ( telephone_id
        , contact_id
        , address_id
        , telephone_type
        , country_code
        , area_code
        , telephone_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date )
        VALUES
         ( telephone_s1.NEXTVAL
        , contact_s1.CURRVAL
        , address_s1.CURRVAL
        , lv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , lv_created_by
        , lv_creation_date
        , lv_created_by
        , lv_creation_date); 
 
/* Commit the writes to all four tables. */
COMMIT;
 
EXCEPTION
/* Catch all errors. */
        WHEN OTHERS THEN
                dbms_output.put_line('ERROR IN PROCEDURE 2: '||SQLERRM);
		ROLLBACK TO start_place;
END contact_package;
/
LIST
SHOW ERRORS

-- ----------------------------------------------------------------------
/*Insert Contacts*/
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

BEGIN
        contact_package.insert_contact
        ( pv_first_name => 'Shirley'
        , pv_middle_name => ''
        , pv_last_name => 'Partridge'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000012'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => 'DBA 3')
        , pv_user_id => '');        
END;
/
BEGIN
        contact_package.insert_contact
        ( pv_first_name => 'Keith'
        , pv_middle_name => ''
        , pv_last_name => 'Partridge'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000012'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => ''
        , pv_user_id => '6');        
END;
/
BEGIN
        contact_package.insert_contact
        ( pv_first_name => 'Laurie'
        , pv_middle_name => ''
        , pv_last_name => 'Partridge'
        , pv_contact_type => 'CUSTOMER'
        , pv_account_number => 'SLC-000012'
        , pv_member_type => 'GROUP'
        , pv_credit_card_number => '8888-6666-8888-4444'
        , pv_credit_card_type => 'VISA_CARD'
        , pv_city => 'Lehi'
        , pv_state_province => 'Utah'
        , pv_postal_code => '84043'
        , pv_address_type => 'HOME'
        , pv_country_code => '001'
        , pv_area_code => '207'
        , pv_telephone_number => '877-4321'
        , pv_telephone_type => 'HOME'
        , pv_user_name => ''
        , pv_user_id => '-1');        
END;
/
SPOOL OFF;

-- ----------------------------------------------------------------------
/* You can confirm the inserts with the following query: */
-- ----------------------------------------------------------------------
-- Append log file
SPOOL /home/student/Data/cit325/oracle/lab8/apply_plsql_lab8.txt append;

COL full_name      FORMAT A18   HEADING "Full Name"
COL created_by     FORMAT 9999  HEADING "System|User ID"
COL account_number FORMAT A12   HEADING "Account|Number"
COL address        FORMAT A16   HEADING "Address"
COL telephone      FORMAT A16   HEADING "Telephone"
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      c.created_by 
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Partridge';
-- ----------------------------------------------------------------------

EXIT;