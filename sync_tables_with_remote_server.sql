DECLARE @current_column_name VARCHAR(500)
DECLARE @column_list VARCHAR(5000)
DECLARE @table_list VARCHAR(5000)
DECLARE @current_table_name VARCHAR(200)
DECLARE @remote_server_ip  VARCHAR(255)
DECLARE @sql_text VARCHAR(4000)

set  @table_list	    = 'spst_proc_ent_fltr_grp_w,spst_proc_ent_w,sstl_proc_ent_w,sstl_se_amount_w,sstl_journal_part_info,sstl_se_rule_w,sstl_se_amount_value_w,sstl_session,sstl_acc_w,sstl_se_fee_w,sstl_se_rule_acc_post_w,sstl_se_w,sstl_prop_value_w,sstl_tran_ident_w,sstl_se_fee_value_w,spst_proc_ent,sstl_prop_value_node_w,sstl_tran_ident_def_w,sstl_se_acc_nr_w,sstl_pred_prop_value_w,sstl_se,sstl_se_amount_value,sstl_se_rule_acc_post,sstl_se_fee_value,sstl_se_acc_nr'
SET  @column_list       = ''
SET  @remote_server_ip  = '172.75.75.19'
SET  @sql_text			= ''
 

DECLARE table_cursor CURSOR  LOCAL FORWARD_ONLY STATIC  READ_ONLY  FOR SELECT part FROM  dbo.usf_split_string(@table_list, ',')
OPEN table_cursor
FETCH NEXT  FROM   table_cursor INTO @current_table_name



WHILE (@@FETCH_STATUS = 0)BEGIN

DECLARE column_cursor CURSOR  LOCAL FORWARD_ONLY STATIC  READ_ONLY  FOR SELECT COLUMN_NAME FROM  INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = @current_table_name
OPEN  column_cursor

FETCH NEXT FROM column_cursor INTO @current_column_name
WHILE (@@FETCH_STATUS = 0)BEGIN
   -- PRINT @current_column_name+CHAR(10)
	SET @column_list = @column_list+ @current_column_name+','
	FETCH NEXT FROM column_cursor INTO @current_column_name
END
CLOSE  column_cursor
DEALLOCATE  column_cursor

SET @column_list =  SUBSTRING( @column_list, 1, LEN(@column_list)-1)
IF EXISTS (SELECT object_id FROM sys.identity_columns WHERE object_id = (  SELECT id  FROM sysobjects WHERE name = @current_table_name )) BEGIN 
SET  @sql_text	 = CHAR(10)+'SET IDENTITY_INSERT '+@current_table_name+' ON '+CHAR(10)
END
SET @sql_text =@sql_text+  'INSERT INTO '+@current_table_name+'('+@column_list+') SELECT '+@column_list+' FROM  ['+@remote_server_ip+'].[postilion_office].[dbo].['+@current_table_name+'];'
	IF EXISTS (SELECT object_id FROM sys.identity_columns WHERE object_id = (  SELECT id  FROM sysobjects WHERE name = @current_table_name )) BEGIN 
	SET  @sql_text	 = @sql_text+CHAR(10)+' SET IDENTITY_INSERT '+@current_table_name+' OFF '
	END

PRINT @sql_text
SET  @sql_text			= ''
SET @column_list		= ''
FETCH NEXT  FROM   table_cursor INTO @current_table_name
END
CLOSE  table_cursor
DEALLOCATE  table_cursor


