DECLARE @query NVARCHAR(4000);
DECLARE @table_name  VARCHAR(50);
DECLARE table_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE CHARINDEX('sstl_journal_', TABLE_NAME)>0 AND TABLE_TYPE ='BASE TABLE' AND TABLE_NAME NOT IN
('sstl_journal_part_info'
,'sstl_journal_fltr_param_w'
,'sstl_journal_fltr_param'
,'sstl_journal_fltr_grp_w'
,'sstl_journal_fltr_grp_elem_w'
,'sstl_journal_fltr_grp_elem'
,'sstl_journal_fltr_grp'
,'sstl_journal_fltr'
,'sstl_journal_entry_insert_fltr'
,'sstl_journal_adj'
)
 ORDER BY TABLE_NAME desc
 OPEN table_cursor;
 
 FETCH NEXT FROM table_cursor INTO @table_name;
 WHILE (@@FETCH_STATUS =0) BEGIN
	PRINT('Running query: '+@query+CHAR(10));
	
	SET @query = 'IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[dbo].['+@table_name+']) AND name = N'''''+@table_name+'_idx''))
	CREATE NONCLUSTERED INDEX ['+@table_name+'_idx] ON [dbo].['+@table_name+'] 
	(
		[post_tran_cust_id] ASC
	)
	INCLUDE ( [config_set_id],
	[post_tran_id],
	[amount],
	[fee],
	[debit_acc_nr_id],
	[credit_acc_nr_id],
	[business_date]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]';
	
	EXEC(@query);
	
	FETCH NEXT FROM table_cursor INTO @table_name;
	
	END
	
	CLOSE table_cursor;
	DEALLOCATE table_cursor;
	
	
	
