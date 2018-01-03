CREATE OR REPLACE

TYPE hobbit_t UNDER base_t
	( hobbit_name VARCHAR2(30)
	, CONSTRUCTOR FUNCTION hobbit_t
	( hobbit_name VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY hobbit_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION hobbit_t
	( hobbit_name VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_name := 'HOBBIT_T';

/* Assign a parameter to the subtype only attribute. */

	self.hobbit_name := hobbit_name;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Name: ['||hobbit_name||']';
		END;
	END;
	/

QUIT
