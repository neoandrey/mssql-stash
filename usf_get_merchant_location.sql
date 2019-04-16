
CREATE FUNCTION dbo.usf_get_merchant_location (@card_acceptor_name_loc varchar(500))
returns  VARCHAR(500)
AS
begin  

DECLARE @location  VARCHAR(500)
DECLARE  @card_acceptor_table TABLE (index_no INT IDENTITY (1,1), component VARCHAR(255))
insert into @card_acceptor_table
SELECT  * FROM dbo.usf_split_string(@card_acceptor_name_loc, ' ')  WHERE part is not null;

DECLARE @max_id INT
DECLARE @before_max_id INT

SELECT @max_id = MAX(index_no) FROM @card_acceptor_table;
SELECT @before_max_id =@max_id-1;
 SELECT  @location = (SELECT component FROM @card_acceptor_table WHERE index_no = @before_max_id ) +' '+(SELECT component FROM @card_acceptor_table WHERE index_no = @max_id);
return @location   
end