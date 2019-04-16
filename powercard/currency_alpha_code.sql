create or replace
FUNCTION CURRENCY_ALPHA_CODE(c_code in varchar2)

RETURN char AS
cc char(3) := '???';
BEGIN

select currency_code_alpha into cc
from currency_table
where currency_code = c_code;
  RETURN cc;
END CURRENCY_ALPHA_CODE;

I also found another function, maybe it might be useful (Currency Description)

create or replace
FUNCTION CURRENCY_ALPHA_DESCRIPTION(c_code in varchar2) 
RETURN VARCHAR2 AS 
cd VARCHAR2(100) := '???';
BEGIN
select currency_name into cd
from currency_table
where currency_code = c_code;
  RETURN cd;
END CURRENCY_ALPHA_DESCRIPTION;


CREATE FUNCTION  currency_alpha_code  (@c_code VARCHAR(5) )
RETURNS VARCHAR(5)
AS BEGIN
	DECLARE @cc VARCHAR(5);
	
SELECT @cc= currency_code_alpha  FROM currency_table (NOLOCK) 	 WHERE currency_code = @c_code;
RETURN @cc
END


CREATE FUNCTION  currency_alpha_description  (@c_code VARCHAR(5) )
RETURNS VARCHAR(250)
AS BEGIN
	DECLARE @cName VARCHAR(250);
	
SELECT @cName= currency_name  FROM currency_table (NOLOCK) 	 WHERE currency_code = @c_code;
RETURN @cName
END

