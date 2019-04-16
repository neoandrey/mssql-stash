 DECLARE @current_table VARCHAR(255)

SET @current_table = 'tbl_order_product_data'

SELECT   'EXEC  sp_rename '''+@current_table+''','''+@current_table+'_'+CONVERT(VARCHAR(8),getdate(),112)+'''' AS rename_command
UNION ALL
SELECT  'EXEC  sp_rename '''+@current_table +'.'+OBJECT_NAME(object_id)+''','' '+OBJECT_NAME(object_id)+'_'+CONVERT(VARCHAR(8),getdate(),112)+'  ''' AS rename_command

FROM sys.objects

WHERE type_desc LIKE '%CONSTRAINT' AND OBJECT_NAME(parent_object_id)=@current_table 
