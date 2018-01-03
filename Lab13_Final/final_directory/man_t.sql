CREATE OR REPLACE

TYPE man_t UNDER base_t
	( man_name VARCHAR2(30)
	, CONSTRUCTOR FUNCTION man_t
	( man_name VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY man_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION man_t
	( man_name VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_name := 'MAN_T';

/* Assign a parameter to the subtype only attribute. */

	self.man_name := man_name;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Name: ['||man_name||']';
		END;
	END;
	/

QUIT
