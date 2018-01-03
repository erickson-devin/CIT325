CREATE OR REPLACE

TYPE noldor_t UNDER base_t
	( noldor_elfkind VARCHAR2(30)
	, CONSTRUCTOR FUNCTION noldor_t
	( noldor_elfkind VARCHAR2 ) RETURN SELF AS RESULT
	, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
		INSTANTIABLE NOT FINAL;
	/
CREATE OR REPLACE

TYPE BODY noldor_t IS

/* One argument constructor. */

CONSTRUCTOR FUNCTION noldor_t
	( noldor_elfkind VARCHAR2 ) RETURN SELF AS RESULT IS
	BEGIN
/* Assign a sequence value and string literal
	to the instance. */
	self.obj_id := base_t_s.NEXTVAL;
	self.obj_elfkind := 'NOLDOR_T';

/* Assign a parameter to the subtype only attribute. */

	self.noldor_elfkind := noldor_elfkind;
		RETURN;
	END;

/* An output function. */

OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS

	BEGIN
		RETURN (self AS base_t).to_string||CHR(10)
			|| 'Elfkind: ['||noldor_elfkind||']';
		END;
	END;
	/

QUIT
