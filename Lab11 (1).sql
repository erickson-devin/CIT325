-- Add your lab here:
-- ----------------------------------------------------------------------
-- Show the output
SET SERVEROUTPUT ON

-- Put the following two lines at the beginning of your script:
@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Begin log file
SPOOL /home/student/Data/cit325/oracle/lab11/Lab11.txt;
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

-- Add a text_file_name column to the item table
ALTER TABLE item
ADD text_file_name VARCHAR2(30); 


-- Verification script
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

-- ----------------------------------------------------------------------
/* Part 1 */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 1             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Verify the item table definition looks like the example
desc item

--Create the logger table and logger_s sequence

-- Display the result 
desc logger

-- ----------------------------------------------------------------------
/* Part 1 Test Case*/
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('       Test Case 1            ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Test 1
DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'Brave Heart';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
 
    ... insert the data into the logger table ...
 
  END LOOP;
END;
/

-- Test 2
/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- ----------------------------------------------------------------------
/* Part 2 */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 2             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Create overloaded item_insert autonomous procedures inside a manage_item package.


-- Display the result
desc manage_item

-- Implement a manage_item package body

-- ----------------------------------------------------------------------
/* Part 2 Test Case*/
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('       Test Case 2            ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Call the overloaded item_insert procedure that includes the old_ and new_ column...
  	   , pv_new_item_title => i.item_title || '-Changed'
-- Call the overloaded item_insert procedure
  	   , pv_new_item_title => i.item_title || '-Inserted'
-- Call the overloaded item_insert procedure
  	   , pv_new_item_title => i.item_title || '-Deleted'

-- The following test query returns the rows from all three test scenarios
/* Query the logger table. */
/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- ----------------------------------------------------------------------
/* Part 3 */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 03             ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Create an item_trig trigger

-- Create an item_delete_trig trigger

-- ----------------------------------------------------------------------
/* Part 3 Test Case*/
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('       Test Case 3            ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------
-- Include the following diagnostic query inside your script file: 
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_type      FORMAT 9999 HEADING "Item|Type"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_type
,      i.item_rating
FROM   item i
WHERE  i.item_title = 'Star Wars';

-- Include the following diagnostic query
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_type      FORMAT 9999 HEADING "Item|Type"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_type
,      i.item_rating
FROM   item i
WHERE  i.item_title = 'Star Wars';

-- You can verify the addition to the common_lookup table with the following query:
COL common_lookup_table   FORMAT A14 HEADING "Common Lookup|Table"
COL common_lookup_column  FORMAT A14 HEADING "Common Lookup|Column"
COL common_lookup_type    FORMAT A14 HEADING "Common Lookup|Type"
SELECT common_lookup_table
,      common_lookup_column
,      common_lookup_type
FROM   common_lookup
WHERE  common_lookup_table = 'ITEM'
AND    common_lookup_column = 'ITEM_TYPE'
AND    common_lookup_type = 'BLU-RAY';

-- Verify that your item_trig trigger’s insert event works.
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
COL item_type      FORMAT A18   HEADING "Item|Type"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_rating
,      cl.common_lookup_meaning AS item_type
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  cl.common_lookup_type = 'BLU-RAY';

-- You verify the results from the logger table with the following query
/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- Update the Star Wars row that you previously inserted into the item table

-- The query against the item table should display 
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
COL item_type      FORMAT A18   HEADING "Item|Type"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_rating
,      cl.common_lookup_meaning AS item_type
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  cl.common_lookup_type = 'BLU-RAY';

-- query the logger table to see what transactions have occurred
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- ----------------------------------------------------------------------

SPOOL OFF;

EXIT;