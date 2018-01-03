CREATE OR REPLACE

TYPE teleri_t UNDER base_t
	( teleri_elfkind VARCHAR2(30)
	, CONSTRUCTOR FUNCTION teleri_t
	( teleri_elfkind VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY teleri_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION teleri_t
	( teleri_elfkind VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_elfkind := 'TELERI_T';

/* Assign a parameter to the subtype only attribute. */

	self.teleri_elfkind := teleri_elfkind;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Elfkind: ['||teleri_elfkind||']';
		END;
	END;
	/

QUIT
