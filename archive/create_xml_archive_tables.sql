
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @startDate DATETIME='20160101';
DECLARE @endDate DATETIME='20170101';
DECLARE @database_name VARCHAR(255)
DECLARE @serverName VARCHAR(50);
DECLARE @tableName VARCHAR(50);
DECLARE @tableNameTwo VARCHAR(50);
DECLARE @last_tran_date DATETIME;
DECLARE @table_month_suffix_start VARCHAR(50);
DECLARE @table_month_suffix_end VARCHAR(50);
DECLARE @fileGroup VARCHAR(5);
DECLARE @batchSize VARCHAR(50);
DECLARE @archive_day_count INT;
DECLARE @remote_day_count INT;
DECLARE @last_datetime_req DATETIME;
DECLARE @last_post_tran_id BIGINT;
DECLARE @last_post_tran_cust_id BIGINT;
DECLARE @last_tran_nr  BIGINT
DECLARE @last_retrieval_reference_nr VARCHAR(15)
DECLARE @last_system_trace_audit_nr  VARCHAR(15)
DECLARE @last_recon_business_date DATETIME
DECLARE @last_online_system_id  INT
DECLARE @last_tran_postilion_originated INT
DECLARE @session_id INT
DECLARE @month CHAR(2);
DECLARE @archive_id INT;
DECLARE @is_table_created INT

/*
	SELECT TOP 1
		 @archive_id       = id
		,@serverName       = server_name
		,@database_name	   = database_name
		,@startDate        = start_date
		,@endDate		   = end_date
		,@last_tran_date   = ISNULL(last_tran_date, start_date)
		,@batchSize		   = batch_size
		,@is_table_created =is_table_created 
	FROM [postilion_office_old].dbo.post_tran_archive_sources 
	WHERE  
		copy_complete =0
	ORDER BY id;
IF NOT EXISTS (SELECT SRVID FROM sys.sysservers WHERE srvname =@serverName )
BEGIN
DECLARE @errorMessage VARCHAR(MAX)
    SET @errorMessage ='There is no linked server for: '+@serverName+'. Please add a linked server for '+@serverName+' and rerun the job. Setting  server to '+@@servername; 
    print(@errorMessage);
    RAISERROR (@errorMessage, 16,  1 );
END
*/

DECLARE @table_name_table TABLE (tableName VARCHAR(255), table_month VARCHAR(6));

--IF(@archive_id  IS NOT NULL ) BEGIN

	SELECT @table_month_suffix_start = REPLACE(CONVERT(VARCHAR(6), @startDate,112),'/', '');
	SELECT @table_month_suffix_end = REPLACE(CONVERT(VARCHAR(6), @endDate,112),'/', '')	

	IF (@table_month_suffix_start = @table_month_suffix_end) BEGIN 
			
			SET   @tableName     = 'post_tran_xml_arch_'+@table_month_suffix_start;			
			SET @month = SUBSTRING(@table_month_suffix_current,5,2)
			SELECT @fileGroup = CASE
									 WHEN @month='01' THEN  'JAN'
									 WHEN @month='02' THEN  'FEB'
									 WHEN @month='03' THEN  'MAR'
									 WHEN @month='04' THEN  'APR'
									 WHEN @month='05' THEN  'MAY'
									 WHEN @month='06' THEN  'JUN'
									 WHEN @month='07' THEN  'JUL'
									 WHEN @month='08' THEN  'AUG'
									 WHEN @month='09' THEN  'SEP'
									 WHEN @month='10' THEN  'OCT'
									 WHEN @month='11' THEN  'NOV'
									 WHEN @month='12' THEN  'DEC'
								 END

        PRINT 'Creating table '+@tableName+char(10);
		
		exec('IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
		DROP TABLE [dbo].['+@tableName+'];
								 CREATE TABLE [dbo].['+@tableName+'](
									[post_tran_id] [bigint] NOT NULL,
									[post_tran_cust_id] [bigint] NOT NULL,
									[tran_nr] [bigint] NOT NULL,
									[system_trace_audit_nr] [char](6) NULL,
									[retrieval_reference_nr] [char](12) NULL,
									[recon_business_date] [datetime2](3) NOT NULL,
									[icc_data_req] VARCHAR(MAX),
									[icc_data_rsp] VARCHAR(MAX),
									[structured_data_req] VARCHAR(MAX),
									[structured_data_rsp] VARCHAR(MAX)
							) ON ['+@fileGroup+']
	
							CREATE  CLUSTERED INDEX pk_'+@tableName+' ON ['+@tableName+'](
								post_tran_id 
							)ON ['+@fileGroup+'];


					/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_14] ON [dbo].['+@tableName+'] 
					(
						[post_tran_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_2] ON [dbo].['+@tableName+'] 
					(
						[post_tran_cust_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					/****** Object:  Index [ix_'+@tableName+'_3]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_3] ON [dbo].['+@tableName+'] 
					(
						[tran_nr] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					
					/****** Object:  Index [ix_'+@tableName+'_4]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
					(
						[retrieval_reference_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[system_trace_audit_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
			
END');
			
	 END
	 ELSE BEGIN
	 
		 DECLARE @table_month_suffix_current VARCHAR(10)
		 DECLARE @table_month_suffix_final VARCHAR(10)
		 SET @table_month_suffix_current = @table_month_suffix_start;
		 SET @table_month_suffix_current=@table_month_suffix_current+'01';
		 SET @table_month_suffix_final = @table_month_suffix_end+'01';



	 WHILE (DATEDIFF(MONTH,@table_month_suffix_current,@table_month_suffix_final ) >=0) BEGIN
	 
			SET   @tableName  = 'post_tran_xml_arch_'+LEFT(@table_month_suffix_current,6);
			INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , LEFT(@table_month_suffix_current,6));
			SET @month = SUBSTRING(@table_month_suffix_current,5,2)
			SELECT @fileGroup = CASE
									 WHEN @month='01' THEN  'JAN'
									 WHEN @month='02' THEN  'FEB'
									 WHEN @month='03' THEN  'MAR'
									 WHEN @month='04' THEN  'APR'
									 WHEN @month='05' THEN  'MAY'
									 WHEN @month='06' THEN  'JUN'
									 WHEN @month='07' THEN  'JUL'
									 WHEN @month='08' THEN  'AUG'
									 WHEN @month='09' THEN  'SEP'
									 WHEN @month='10' THEN  'OCT'
									 WHEN @month='11' THEN  'NOV'
									 WHEN @month='12' THEN  'DEC'
								 END

        PRINT 'Creating table '+@tableName+char(10);
	                    		
								exec('IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
								DROP TABLE [dbo].['+@tableName+'];
								 CREATE TABLE [dbo].['+@tableName+'](
									[post_tran_id] [bigint] NOT NULL,
									[post_tran_cust_id] [bigint] NOT NULL,
									[tran_nr] [bigint] NOT NULL,
									[system_trace_audit_nr] [char](6) NULL,
									[retrieval_reference_nr] [char](12) NULL,
									[recon_business_date] [datetime2](3) NOT NULL,
									[icc_data_req] VARCHAR(MAX),
									[icc_data_rsp] VARCHAR(MAX),
									[structured_data_req] VARCHAR(MAX),
									[structured_data_rsp] VARCHAR(MAX)
							) ON ['+@fileGroup+']
	
							CREATE  CLUSTERED INDEX pk_'+@tableName+' ON ['+@tableName+'](
								post_tran_id 
							)ON ['+@fileGroup+'];


					/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_14] ON [dbo].['+@tableName+'] 
					(
						[post_tran_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_2] ON [dbo].['+@tableName+'] 
					(
						[post_tran_cust_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					/****** Object:  Index [ix_'+@tableName+'_3]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_3] ON [dbo].['+@tableName+'] 
					(
						[tran_nr] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

					
					/****** Object:  Index [ix_'+@tableName+'_4]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
					(
						[retrieval_reference_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[system_trace_audit_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
			
END');
		
			
SET 	@table_month_suffix_current  = REPLACE(CONVERT(varchar(10),DATEADD(MONTH, 1,@table_month_suffix_current ), 111)		,'/', '');
END	
	UPDATE [postilion_office_old].dbo.post_tran_archive_sources SET is_table_created =1;		 
END
--end