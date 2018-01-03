CREATE OR REPLACE

TYPE orc_t UNDER base_t
	( orc_name VARCHAR2(30)
	, CONSTRUCTOR FUNCTION orc_t
	( orc_name VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY orc_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION orc_t
	( orc_name VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_name := 'ORC_T';

/* Assign a parameter to the subtype only attribute. */

	self.orc_name := orc_name;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Name: ['||orc_name||']';
		END;
	END;
	/

QUIT
