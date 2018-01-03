-- Add your lab here:
-- ----------------------------------------------------------------------
-- Show the output
SET SERVEROUTPUT ON

-- Begin log file
SPOOL /home/student/Data/cit325/oracle/lab10/apply_plsql_lab10.txt;
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
/* Part 0 */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 0             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------

-- Drop tables, types, and sequence
DROP SEQUENCE cart_s;
DROP TABLE cart;
DROP TYPE apple_t;
DROP TYPE fruit_t;

-- How to create a general fruit_t object type with default and override constructors. 
CREATE OR REPLACE
  TYPE fruit_t IS OBJECT
  ( oname VARCHAR2(30)
  , name  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION fruit_t RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION fruit_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

-- You can describe the fruit_t object type with the following syntax, like you do for a table, view, function, procedure, or package:
DESCRIBE fruit_t

-- How to implement a general fruit_t object type body with default and override constructors. 
CREATE OR REPLACE
  TYPE BODY fruit_t IS
 
    /* Override constructor. */
    CONSTRUCTOR FUNCTION fruit_t RETURN SELF AS RESULT IS
    BEGIN
      self.oname := 'FRUIT_T';
      RETURN;
    END;
 
    /* Formalized default constructor. */
    CONSTRUCTOR FUNCTION fruit_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
      /* Assign an oname value. */
      self.oname := oname;
 
      RETURN;
    END;
 
    /* A getter function to return the name attribute. */
    MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN self.name;
    END get_name;
 
    /* A getter function to return the name attribute. */
    MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
    BEGIN
      RETURN self.oname;
    END get_oname;
 
    /* A setter procedure to set the oname attribute. */
    MEMBER PROCEDURE set_oname
    ( oname VARCHAR2 ) IS
    BEGIN
      self.oname := oname;
    END set_oname;
 
    /* A to_string function. */
    MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN '['||self.oname||']';
    END to_string;
  END;
/

-- You can create a fruit_t object instance with the following anonymous block.
DECLARE
  /* Create a default instance of the object type. */
  lv_instance  FRUIT_T := fruit_t();
BEGIN
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Default  : ['||lv_instance.get_oname()||']');
 
  /* Set the oname value to a new value. */
  lv_instance.set_oname('SUBSTITUTE');
 
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Override : ['||lv_instance.get_oname()||']');
END;
/

-- How to create a table that uses a column with a fruit_t object type. 
-- The following creates a cart table and cart_s sequence to manage fruit_t object instances:
/* Create logger table. */
CREATE TABLE cart
( cart_id  NUMBER
, item     FRUIT_T );
 
/* Create logger_s sequence. */
CREATE SEQUENCE cart_s;

-- You can insert values in the cart table with SQL or in a PL/SQL block. The SQL syntax is:
INSERT INTO cart
VALUES
( cart_s.NEXTVAL
, fruit_t());
 
INSERT INTO cart
VALUES
( cart_s.NEXTVAL
, fruit_t(
    oname => 'FRUIT_T'
  , name => 'NEW' );

-- The PL/SQL syntax is:
DECLARE
  /* Declare a variable of the UDT type. */
  lv_fruit  FRUIT_T;
BEGIN
  /* Assign an instance of the variable. */
  lv_fruit := fruit_t(
      oname => 'FRUIT_T'
    , name => 'OLD' );
 
    /* Insert instance of the base_t object type into table. */
    INSERT INTO cart
    VALUES (cart_s.NEXTVAL, lv_fruit);
 
    /* Commit the record. */
    COMMIT;
END;
/

-- You can use the following query to verify the INSERT statements:
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT g.cart_id
,      g.item.oname AS oname
,      NVL(g.item.get_name(),'Unset') AS get_name
,      g.item.to_string() AS to_string
FROM  (SELECT c.cart_id
       ,      TREAT(c.item AS fruit_t) AS item
       FROM   cart c) g
WHERE  g.item.oname = 'FRUIT_T';

-- How to create an apple_t subtype of the fruit_t object type. 
-- The following lets you create an apple_t subtype of the fruit_t class. 
CREATE OR REPLACE
  TYPE apple_t UNDER fruit_t
  ( variety     VARCHAR2(20)
  , class_size  VARCHAR2(20)
  , CONSTRUCTOR FUNCTION apple_t
    ( oname       VARCHAR2
    , name        VARCHAR2
    , variety     VARCHAR2
    , class_size  VARCHAR2 ) RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

-- You can describe the apple_t subtype the same way you described the fruit_t object type or any table, view, function, procedure, or package:
DESCRIBE apple_t

-- The following lets you create an apple_t subtype of the fruit_t class. 
CREATE OR REPLACE
  TYPE BODY apple_t IS
 
    /* Default constructor, implicitly available, but you should
       include it for those who forget that fact. */
    CONSTRUCTOR FUNCTION apple_t
    ( oname       VARCHAR2
    , name        VARCHAR2
    , variety     VARCHAR2
    , class_size  VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
      /* Assign inputs to instance variables. */    
      self.oname := oname;
 
      /* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;
 
      /* Assign inputs to instance variables. */  
      self.variety := variety;
      self.class_size := class_size;
 
      /* Return an instance of self. */
      RETURN;
    END;
 
    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS fruit_t).get_name();
    END get_name;
 
    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS fruit_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

-- The following inserts an apple_t value in the fruit_t object type column:
INSERT INTO cart
VALUES
( cart_s.NEXTVAL
, apple_t(
    oname => 'APPLE_T'
  , name => 'NEW' 
  , variety => 'PIPPIN'
  , class_size => 'MEDIUM'));

-- You can use the modified query to verify the INSERT statements for both the apple_t and fruit_t object class inserts:
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT g.cart_id
,      g.item.oname AS oname
,      NVL(g.item.get_name(),'Unset') AS get_name
,      g.item.to_string() AS to_string
FROM  (SELECT c.cart_id
       ,      TREAT(c.item AS fruit_t) AS item
       FROM   cart c) g
WHERE  g.item.oname IN ('FRUIT_T','APPLE_T');

-- ----------------------------------------------------------------------
/* PART 1:  Create the base_t object type, a logger table, and logger_s sequence. */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 1             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------

-- Drop tables, types, and sequence
DROP TABLE logger;
DROP SEQUENCE logger_s;
DROP TYPE item_t FORCE;
DROP TYPE contact_t FORCE;
DROP TYPE base_t FORCE;

-- Create a base_t object type that maps to the following definition. 
CREATE OR REPLACE
  TYPE base_t IS OBJECT
  ( oname VARCHAR2(30)
  , name  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION base_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

-- Display the result by using the following
desc base_t

/* Create logger table. */
CREATE TABLE logger
( logger_id  NUMBER
, log_text   BASE_T );

/* Create logger_s sequence. */
CREATE SEQUENCE logger_s;
 
-- You can describe the logger table to verify 
desc logger

-- Implement a base_t object body
CREATE OR REPLACE
  TYPE BODY base_t IS
    CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS
    BEGIN
      self.oname := 'BASE_T';
      RETURN;
    END;
    CONSTRUCTOR FUNCTION base_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
/* Assign an oname value. */
      self.oname := oname;
/* Assign value or assign null. */
    IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
      self.name := name;
    END IF;
    RETURN;
    END;
/* A getter function to return the name attribute. */
    MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN self.name;
    END get_name;
/* A getter function to return the name attribute. */
    MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
    BEGIN
      RETURN self.oname;
    END get_oname;
/* A setter procedure to set the oname attribute. */
    MEMBER PROCEDURE set_oname
    ( oname VARCHAR2 ) IS
    BEGIN
      self.oname := oname;
    END set_oname;
/* A to_string function. */
    MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN '['||self.oname||']';
    END to_string;
  END;
/

-- ----------------------------------------------------------------------
-- Test Case #1
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('        Test Case #1          ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------

/*You can test the ability to create an instance of the base_t type with 
a default oname attribute value, set the instance value of the oname 
attribute to a new value, and get the instance value of the changed oname 
value with the following anonymous PL/SQL block: */

DECLARE
  /* Create a default instance of the object type. */
  lv_instance  BASE_T := base_t();
BEGIN
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Default  : ['||lv_instance.get_oname()||']');
 
  /* Set the oname value to a new value. */
  lv_instance.set_oname('SUBSTITUTE');
 
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Override : ['||lv_instance.get_oname()||']');
END;
/

-- You also need to insert a row into the logger table.
-- You can insert a base_t object instance with the default no parameter constructor, like
INSERT INTO logger
VALUES (logger_s.NEXTVAL, base_t());

-- You can insert a base_t object instance with the a parameter-driven constructor, like
DECLARE
  /* Declare a variable of the UDT type. */
  lv_base  BASE_T;
BEGIN
  /* Assign an instance of the variable. */
  lv_base := base_t(
      oname => 'BASE_T'
    , name => 'NEW' );
 
    /* Insert instance of the base_t object type into table. */
    INSERT INTO logger
    VALUES (logger_s.NEXTVAL, lv_base);
 
    /* Commit the record. */
    COMMIT;
END;
/

-- After you insert the row, test with:
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      NVL(t.log.get_name(),'Unset') AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname = 'BASE_T';

-- ----------------------------------------------------------------------
/* PART 2:  Create the item_t and contact_t subtypes of the base_t object type. */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 2             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Create the item_t subtype
    CREATE OR REPLACE
      TYPE item_t UNDER base_t
      ( item_id             NUMBER
      , item_barcode        VARCHAR2(20)
      , item_type           NUMBER
      , item_title          VARCHAR2(60)
      , item_subtitle       VARCHAR2(60)
      , item_rating         VARCHAR2(8)
      , item_rating_agency  VARCHAR2(4)
      , item_release_date   DATE
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE
      , CONSTRUCTOR FUNCTION item_t
      ( oname               VARCHAR2
      , name                VARCHAR2
      , item_id             NUMBER
      , item_barcode        VARCHAR2
      , item_type           NUMBER
      , item_title          VARCHAR2
      , item_subtitle       VARCHAR2
      , item_rating         VARCHAR2
      , item_rating_agency  VARCHAR2
      , item_release_date   DATE
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE ) RETURN SELF AS RESULT
      , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
      , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
      INSTANTIABLE NOT FINAL;
    /

-- Display the result by using the following:
desc item_t

-- Implement a item_t object body.
CREATE OR REPLACE
  TYPE BODY item_t IS
      CONSTRUCTOR FUNCTION item_t
      ( oname               VARCHAR2
      , name                VARCHAR2
      , item_id             NUMBER
      , item_barcode        VARCHAR2
      , item_type           NUMBER
      , item_title          VARCHAR2
      , item_subtitle       VARCHAR2
      , item_rating         VARCHAR2
      , item_rating_agency  VARCHAR2
      , item_release_date   DATE
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE ) RETURN SELF AS RESULT IS
    BEGIN
/* Assign an oname value. */
      self.oname := oname;
/* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;
      RETURN;
      END;
/* Assign inputs to instance variables. */  
      self.item_id             := item_id;
      self.item_barcode        := item_barcode;
      self.item_type           := item_type;
      self.item_title          := item_title;
      self.item_subtitle       := item_subtitle;
      self.item_rating         := item_rating;
      self.item_rating_agency  := item_rating_agency;
      self.item_release_date   := item_id_release_date;
      self.created_by          := created_by;
      self.creation_date       := creation_date;
      self.last_updated_by     := last_updated_by;
      self.last_update_date    := last_update_date;
/* Return an instance of self. */
      RETURN;
    END;
/* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).get_name();
    END get_name;
/* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

show errors

-- Create the contact_t subtype. 
    CREATE OR REPLACE
      TYPE contact_t UNDER base_t
      ( contact_id          NUMBER
      , member_id           NUMBER
      , contact_type        NUMBER
      , first_name          VARCHAR2(60)
      , middle_name         VARCHAR2(60)
      , last_name           VARCHAR2(8)
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE
      , CONSTRUCTOR FUNCTION contact_t
      ( oname               VARCHAR2
      , name                VARCHAR2
      , contact_id          NUMBER
      , member_id           NUMBER
      , contact_type        NUMBER
      , first_name          VARCHAR2
      , middle_name         VARCHAR2
      , last_name           VARCHAR2
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE ) RETURN SELF AS RESULT
      , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
      , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
      INSTANTIABLE NOT FINAL;
    /

-- Display the result by using the following:
desc contact_t

-- Implement a contact_t object body
CREATE OR REPLACE
  TYPE BODY contact_t IS
      CONSTRUCTOR FUNCTION contact_t
      ( oname               VARCHAR2
      , name                VARCHAR2
      , contact_id          NUMBER
      , member_id           NUMBER
      , contact_type        NUMBER
      , first_name          VARCHAR2
      , middle_name         VARCHAR2
      , last_name           VARCHAR2
      , created_by          NUMBER
      , creation_date       DATE
      , last_updated_by     NUMBER
      , last_update_date    DATE ) RETURN SELF AS RESULT
    BEGIN
/* Assign an oname value. */
      self.oname := oname;
/* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;
/* Assign inputs to instance variables. */  
      self.contact_id          := contact_id;
      self.member_id           := member_id;
      self.contact_type        := contact_type;
      self.first_name          := first_name;
      self.middle_name         := middle_name;
      self.last_name           := last_name;
      self.created_by          := created_by;
      self.creation_date       := creation_date;
      self.last_updated_by     := last_updated_by;
      self.last_update_date    := last_update_date;
/* Return an instance of self. */
      RETURN;
    END;
/* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).get_name();
    END get_name;
/* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

-- ----------------------------------------------------------------------
-- Test Case #2
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('        Test Case #2          ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
/*  Insert a row into the logger table with a item_t object instance and 
another row with a contact_t object instance. */

-- Use the following query to verify row inserts:
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      t.log.get_name() AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname IN ('CONTACT_T','ITEM_T'); 

-- ----------------------------------------------------------------------

SPOOL OFF;

EXIT;