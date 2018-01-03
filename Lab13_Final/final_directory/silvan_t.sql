CREATE OR REPLACE

TYPE silvan_t UNDER base_t
	( silvan_elfkind VARCHAR2(30)
	, CONSTRUCTOR FUNCTION silvan_t
	( silvan_elfkind VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY silvan_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION silvan_t
	( silvan_elfkind VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_elfkind := 'SILVAN_T';

/* Assign a parameter to the subtype only attribute. */

	self.silvan_elfkind := silvan_elfkind;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Elfkind: ['||silvan_elfkind||']';
		END;
	END;
	/

QUIT
