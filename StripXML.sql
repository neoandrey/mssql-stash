USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[StripXML]    Script Date: 08/04/2016 15:14:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[StripXML]( @text varchar(max) ) returns varchar(max) as 
begin 
    declare @textXML xml 
    declare @result varchar(max) 
    set @textXML = @text; 
    with doc(contents) as 
    ( 
        select chunks.chunk.query('.') from @textXML.nodes('/') as chunks(chunk) 
    ) 
    select @result = contents.value('.', 'varchar(max)') from doc 
    return @result 
end 
GO


