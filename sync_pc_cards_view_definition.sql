
declare @sql nVARCHAR(MAX);
SELECT  @sql =  REPLACE(REPLACE(REPLACE(definition, 'WHERE ', '(NOLOCK)  WHERE '), 'CREATE VIEW [dbo].[pc_cards] AS ', ''), 'pc_cards', 'postcard.dbo.pc_cards' )from [172.25.15.213].POSTCARD.sys.objects     o
join [172.25.15.213].[POSTCARD].sys.sql_modules m on m.object_id = o.object_id
where
   o.type      = 'V' and  name = 'pc_cards'
   
INSERT INTO pc_cards_all 
exec( 'SELECT  * FROM OPENQUERY([172.25.15.213], '''+@sql+''')')
      
       
       
      
      ======
       select definition
       from sys.objects     o
       join sys.sql_modules m on m.object_id = o.object_id
       where o.object_id = object_id( 'dbo.MyView')
  and o.type      = 'V'