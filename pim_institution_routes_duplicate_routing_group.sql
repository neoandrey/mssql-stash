USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[pim_institution_routes_duplicate_routing_group]    Script Date: 10/28/2014 15:11:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pim_institution_routes_duplicate_routing_group] (  

    @source_routing_group VARCHAR(20)  ,
    @new_routing_group VARCHAR(20)
)

AS 
	BEGIN

	
		DECLARE @current_datetime DATETIME;
		DECLARE @current_user VARCHAR(255);
		DECLARE @backup_table_name VARCHAR(2000)
		DECLARE @report_table_name VARCHAR(1000)
		DECLARE @date_suffix VARCHAR(1000)
		
		SELECT  @current_datetime = GETDATE();
		
	    SELECT  @current_user = SUSER_SNAME();
	    
	    SELECT @date_suffix=REPLACE(REPLACE(REPLACE(REPLACE(GETDATE(), '-', '_'), ' ', '__'),':','_'), '.', '__');
		
		SELECT @backup_table_name ='tm_routes_'+@date_suffix
		
		EXEC('CREATE TABLE '+@backup_table_name+' (
					[institution] [varchar](200) NOT NULL,
					[routing_group] [varchar](20) NULL,
					[draft_capture] [int] NOT NULL,
					[node] [varchar](12) NOT NULL,
					[currency_code] [char](3) NULL
		
		)');
		
		EXEC('INSERT INTO '+@backup_table_name+'
			   (
			   
			   institution
			   ,routing_group
			   ,draft_capture
			   ,node
			   ,currency_code

			   
			   )	
			 SELECT institution
			   ,routing_group
			   ,draft_capture
			   ,node
			   ,currency_code
                              FROM [postilion].[dbo].[tm_routes_by_institution]');
			   
	    SELECT * INTO #temp_tm_routes_by_institution FROM [tm_routes_by_institution] WHERE routing_group = @source_routing_group
	    
	    SELECT * INTO #temp_new_tm_routes_by_institution FROM [tm_routes_by_institution] WHERE routing_group= @source_routing_group
	    
	    UPDATE #temp_new_tm_routes_by_institution SET routing_group = @new_routing_group
	    
	    IF NOT EXISTS (SELECT routing_group FROM tm_routing_groups WHERE routing_group = @new_routing_group)
	    BEGIN
	      INSERT INTO tm_routing_groups (routing_group) SELECT  @new_routing_group
	    END
	    
	    INSERT INTO [tm_routes_by_institution](
	             institution
		   ,routing_group
		   ,draft_capture
		   ,node
		   ,currency_code


		   )	
		 SELECT institution
		   ,routing_group
		   ,draft_capture
		   ,node
		,currency_code
	    FROM #temp_new_tm_routes_by_institution
	      
	    SELECT @report_table_name = 'tm_routes_update_report_'+@date_suffix
	    
	   EXEC('CREATE TABLE '+@report_table_name+' (
					[institution] [varchar](200) NOT NULL,
					[routing_group] [varchar](20) NULL,
					[draft_capture] [int] NOT NULL,
					[node] [varchar](12) NOT NULL,
					[currency_code] [char](3) NULL,
					[user_name] [varchar](255) NULL
		)');
		
		EXEC('INSERT INTO ['+@report_table_name+']
			   (institution
			   ,routing_group
			   ,draft_capture
			   ,node
			   ,currency_code
			   ,[user_name]
			    )	
			 SELECT 
			institution
			,routing_group
			,draft_capture
			,node
			,currency_code
			   ,SUSER_SNAME()
	             FROM tempdb.dbo.#temp_new_tm_routes_by_institution;');
	             
	         	
			   
			   SELECT @backup_table_name AS 'BACKUP_TABLE_NAME';
			   PRINT CHAR(10)+'BACKUP_TABLE_NAME: '+@backup_table_name
			   
			   SELECT @report_table_name AS 'REPORT_TABLE_NAME';
			   PRINT CHAR(10)+'REPORT_TABLE_NAME: '+@report_table_name;
			   
			   SELECT * FROM #temp_tm_routes_by_institution
			   SELECT * FROM #temp_new_tm_routes_by_institution;
			   SELECT * FROM dbo.tm_routes_by_institution;

	END
GO


