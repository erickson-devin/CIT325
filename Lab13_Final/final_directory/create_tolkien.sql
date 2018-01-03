/* Set environment variables. */
SET PAGESIZE 999
 
/* Write to log file. */
SPOOL create_tolkien.txt
 
/* Drop the tolkien table. */
DROP TABLE tolkien;
 
/* Create the tolkien table. */
CREATE TABLE tolkien
( tolkien_id NUMBER
, tolkien_character base_t);
 
/* Drop and create a tolkien_s sequence. */
DROP SEQUENCE tolkien_s;
CREATE SEQUENCE tolkien_s START WITH 1001;
 
/* Close log file. */
SPOOL OFF
 
/* Exit the connection. */
QUIT