USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[sync_pc_cards]    Script Date: 07/27/2016 13:44:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sync_pc_cards] AS
BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
TRUNCATE TABLE pc_cards_all;

declare @sql nVARCHAR(MAX);
SELECT  @sql =  REPLACE(REPLACE(REPLACE(definition, 'WHERE ', '(NOLOCK)  WHERE '), 'CREATE VIEW [dbo].[pc_cards] AS ', ''), 'pc_cards', 'postcard.dbo.pc_cards' )from [172.25.15.213].POSTCARD.sys.objects     o
join [172.25.15.213].[POSTCARD].sys.sql_modules m on m.object_id = o.object_id
where
   o.type      = 'V' and  name = 'pc_cards'
   
INSERT INTO pc_cards_all 
exec( 'SELECT  * FROM OPENQUERY([172.25.15.213], '''+@sql+''')')
      
       

END
