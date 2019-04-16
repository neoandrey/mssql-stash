/*
    Splits string into parts delimited with specified character.
*/
CREATE FUNCTION [dbo].[usf_split_string]
(
    @source_string varchar(8000),
    @split_delimiter char(1)
)
RETURNS @tParts TABLE ( part nvarchar(2048) )
AS
BEGIN
    if @source_string is null return
    declare	@iStart int,
    		@iPos int
    if substring( @source_string, 1, 1 ) = @split_delimiter 
    begin
    	set	@iStart = 2
    	insert into @tParts
    	values( null )
    end
    else 
    	set	@iStart = 1
    while 1=1
    begin
    	set	@iPos = charindex( @split_delimiter, @source_string, @iStart )
    	if @iPos = 0
    		set	@iPos = len( @source_string )+1
    	if @iPos - @iStart > 0			
    		insert into @tParts
    		values	( LTRIM(RTRIM(substring( @source_string, @iStart, @iPos-@iStart)) ))
    	else
    		insert into @tParts
    		values( null )
    	set	@iStart = @iPos+1
    	if @iStart > len( @source_string ) 
    		break
    end
    RETURN

END