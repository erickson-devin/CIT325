CREATE OR REPLACE

TYPE base_t IS OBJECT
( oname  VARCHAR2(30)
, oid NUMBER
, CONSTRUCTOR FUNCTION base_t
 RETURN SELF AS RESULT
, MEMBER FUNCTION get_oname RETURN VARCHAR2
, MEMBER PROCEDURE set_oname (oname VARCHAR2)
, MEMBER FUNCTION oid RETURN NUMBER)
 INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE
	TYPE BODY base_t IS

/* A default constructor w/o formal parameters. */

CONSTRUCTOR FUNCTION base_t
	RETURN SELF AS RESULT IS
	BEGIN
		self.oname := 'BASE_T';
		RETURN;
	END;

/* An accessor, or getter, method. */

MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
	BEGIN
		RETURN self.oname;
	END get_oname;

/* A mutator, or setter, method. */

MEMBER PROCEDURE set_oname
	( oname  VARCHAR2 ) IS
	
	BEGIN
		self.oname := oname;
	END set_oname;
/* A to_string conversion method. */
	
	MEMBER FUNCTION to_string RETURN VARCHAR2 IS
	BEGIN
		RETURN self.oname;

	END to_string;
END;
/

QUIT
