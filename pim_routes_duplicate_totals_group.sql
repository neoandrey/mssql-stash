
ALTER PROCEDURE dbo.pim_routes_duplicate_totals_group (  
    @source_totals_group VARCHAR(12)  ,
    @new_totals_group VARCHAR(12)
)

AS 
	BEGIN

		DECLARE	@routing_group VARCHAR(20);
		DECLARE @current_datetime DATETIME;
		DECLARE @current_user VARCHAR(255);
		DECLARE @backup_table_name VARCHAR(2000)
		DECLARE @report_table_name VARCHAR(1000)
		DECLARE @date_suffix VARCHAR(1000)
		
		SELECT  @current_datetime = SYSUTCDATETIME();
		
	    SELECT  @current_user = SUSER_SNAME();
	    
	    SELECT @date_suffix=REPLACE(REPLACE(REPLACE(REPLACE(SYSUTCDATETIME(), '-', '_'), ' ', '__'),':','_'), '.', '__');
		
		SELECT @backup_table_name ='tm_routes_'+@date_suffix
		
		EXEC('CREATE TABLE '+@backup_table_name+' (
					[totals_group] [varchar](12) NOT NULL,
					[routing_group] [varchar](20) NULL,
					[draft_capture] [int] NOT NULL,
					[node] [varchar](12) NOT NULL,
					[currency_code] [char](3) NULL,
					[tran_group] [varchar](30) NULL
		
		)');
		
		EXEC('INSERT INTO '+@backup_table_name+'
			   ([totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group])	
			 SELECT [totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group] FROM [TESTDB].[dbo].[tm_routes]');
			   
	    SELECT * INTO #temp_tm_routes FROM [tm_routes] WHERE totals_group= @source_totals_group
	    
	    SELECT * INTO #temp_new_tm_routes FROM [tm_routes] WHERE totals_group= @source_totals_group
	    
	    UPDATE #temp_new_tm_routes SET totals_group = @new_totals_group
	    
	    IF NOT EXISTS (SELECT totals_group FROM [cp_totals_groups] WHERE totals_group = @new_totals_group)
	    BEGIN
	      INSERT INTO cp_totals_groups (totals_group) SELECT  @new_totals_group
	    END
	    
	    INSERT INTO [tm_routes](
	            [totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group] )
	    
	     SELECT [totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group] 
	    FROM #temp_new_tm_routes
	      
	    SELECT @report_table_name = 'tm_routes_update_report_'+@date_suffix
	    
	   EXEC('CREATE TABLE '+@report_table_name+' (
					[totals_group] [varchar](12) NOT NULL,
					[routing_group] [varchar](20) NULL,
					[draft_capture] [int] NOT NULL,
					[node] [varchar](12) NOT NULL,
					[currency_code] [char](3) NULL,
					[tran_group] [varchar](30) NULL,
					[user_name] [varchar](255) NULL,
					[modification_date] [varchar](255) NULL
		)');
		
		EXEC('INSERT INTO ['+@report_table_name+']
			   ([totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group]
			    )	
			 SELECT [totals_group]
			   ,[routing_group]
			   ,[draft_capture]
			   ,[node]
			   ,[currency_code]
			   ,[tran_group]
	             FROM tm_routes WHERE totals_group='+@new_totals_group+';');
	             
	         	EXEC('UPDATE ['+@report_table_name+'] SET user_name = '+@current_user+',modification_date='+@current_datetime );
			   
			   SELECT @backup_table_name AS 'BACKUP_TABLE_NAME';
			   PRINT CHAR(10)+'BACKUP_TABLE_NAME: '+@backup_table_name
			   
			   SELECT @report_table_name AS 'REPORT_TABLE_NAME';
			   PRINT CHAR(10)+'REPORT_TABLE_NAME: '+@report_table_name;
			   
			   SELECT * FROM #temp_tm_routes
			   SELECT * FROM #temp_new_tm_routes;
			   SELECT * FROM dbo.tm_routes;

	END