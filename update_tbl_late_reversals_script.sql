USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_populate_late_reversal_table]    Script Date: 07/10/2017 12:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

exec sp_rename  'usp_populate_late_reversal_table', 'usp_populate_late_reversal_table_old';
GO


exec sp_rename  'usp_populate_late_reversal_table', 'usp_populate_late_reversal_table_old';
GO


CREATE  PROCEDURE [dbo].[usp_populate_late_reversal_table]  @start_date varchar(10) , @end_date varchar(10)

AS

BEGIN

		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
		 END
		 
		  IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
		 BEGIN
				  DROP TABLE #late_rev_details
				  
			
		 END
		SET @start_date  = ISNULL (@start_date,CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),112))
		
		SET @end_date    = ISNULL (@end_date,CONVERT(VARCHAR(10), GETDATE(),112))
		 
		SELECT   post_tran_id, trans.post_tran_cust_id,datetime_req, tran_nr, prev_post_tran_id, rsp_code_rsp, message_type,settle_amount_impact ,settle_amount_req ,settle_amount_rsp  ,settle_currency_code, sink_node_name,system_trace_audit_nr,tran_amount_req ,tran_amount_rsp  ,tran_currency_code, terminal_id,retrieval_reference_nr,recon_business_date,online_system_id,tran_type INTO #reversals FROM 
		POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
		ON 
		trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE
		datetime_req>=@start_date  and datetime_req <@end_date AND message_type ='0420'
		AND tran_postilion_originated = 0
		DECLARE @min_post_tran_id BIGINT
		
		SELECT @min_post_tran_id = MIN(prev_post_tran_id) FROM  #reversals
		 
		select 
	post_tran_id,post_tran_cust_id rev_post_tran_cust_id, post_tran_cust_id  trans_post_tran_cust_id,  '1970-01-01' trans_datetime_req , datetime_req  rev_datetime_req, prev_post_tran_id,message_type rev_message_type, rsp_code_rsp rev_rsp_code_rsp,  '0200' post_tran_message_type,'xx' trans_rsp_code_rsp, tran_nr,settle_amount_impact ,settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, tran_type,'LATE' reversal_type
		  into #late_rev_details from  #reversals  rev WHERE prev_post_tran_id NOT IN (SELECT post_tran_id FROM  post_tran (NOLOCK) WHERE post_tran_id>=@min_post_tran_id )
 
		select rev.post_tran_id,rev.post_tran_cust_id rev_post_tran_cust_id,trans.post_tran_cust_id trans_post_tran_cust_id, trans.datetime_req trans_datetime_req, rev.datetime_req  rev_datetime_req, rev.prev_post_tran_id, rev.message_type rev_message_type, rev.rsp_code_rsp rev_rsp_code_rsp,  trans.message_type post_tran_message_type,trans.rsp_code_rsp trans_rsp_code_rsp, rev.tran_nr,rev.settle_amount_impact ,rev.settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, rev.tran_type,
		 case
             
                  when (rev.datetime_req is not  null  and  trans.datetime_req is NULL)  THEN 'LATE'
             when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )>0  THEN 'LATE'
                 when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )=0 then  'TIMELY'
		END as reversal_type
		INTO #reversal_categories
		from #reversals rev 
		LEFT JOIN post_tran trans (NOLOCK) 
		on trans.post_tran_id = rev.prev_post_tran_id
		where trans.tran_postilion_originated = 0  and trans.post_tran_id>=@min_post_tran_id
		

	   -- INSERT INTO  tbl_late_reversals_archive SELECT * FROM tbl_late_reversals WITH (NOLOCK)
		
		EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_late_reversals_'+@start_date+']'') AND type in (N''U'')) BEGIN  DROP TABLE [tbl_late_reversals_'+@start_date+'] END CREATE TABLE [tbl_late_reversals_'+@start_date+']  ([post_tran_id] [bigint] NOT NULL,	[rev_post_tran_cust_id] [bigint] NOT NULL,	[trans_post_tran_cust_id] [bigint] NULL,	[trans_datetime_req] [datetime] NOT NULL,	[rev_datetime_req] [datetime] NOT NULL,	[prev_post_tran_id] [bigint] NOT NULL,	[rev_message_type] [char](4) NOT NULL,	[rev_rsp_code_rsp] [char](2) NULL,	[post_tran_message_type] [char](4) NULL,	[trans_rsp_code_rsp] [char](2) NULL,	[tran_nr] [bigint] NOT NULL,	[settle_amount_impact] [numeric](16, 0) NULL,	[settle_amount_req] [numeric](16, 0) NULL,	[settle_amount_rsp] [numeric](16, 0) NULL,	[settle_currency_code] [char](3) NULL,	[sink_node_name] [varchar](30) NULL,	[system_trace_audit_nr] [char](6) NULL,	[tran_amount_req] [numeric](16, 0) NULL,	[tran_amount_rsp] [numeric](16, 0) NULL,	[tran_currency_code] [char](3) NULL,	[reversal_type] [varchar](6) NULL,	[terminal_id] [varchar](10) NULL,	[retrieval_reference_nr] [varchar](20) NULL,	[online_system_id] [varchar](20) NULL,	[recon_business_date] [datetime] NOT NULL,	[tran_type] [varchar](5) NULL, CONSTRAINT [pk_tbl_late_reversals_3_'+@start_date+'] PRIMARY KEY CLUSTERED (	[post_tran_id] ASC,	[prev_post_tran_id] ASC)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]) ON [PRIMARY]')
		  EXEC('INSERT  INTO   [tbl_late_reversals_'+@start_date+'] ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],  [recon_business_date],[online_system_id], [tran_type]) 
	  SELECT  [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type]  
		FROM (
		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
		 FROM  #reversal_categories WHERE reversal_type = ''LATE''
		 UNION ALL 
		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
		 FROM #late_rev_details
		 ) L')
				EXEC('
		CREATE NONCLUSTERED INDEX [indx_recon_business_date] ON [dbo].[tbl_late_reversals_'+@start_date+'] (	[recon_business_date] ASC )
		INCLUDE ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],[online_system_id],[tran_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 70) ON [PRIMARY]

		CREATE NONCLUSTERED INDEX [ix_tran_rrrn] ON [dbo].[tbl_late_reversals_'+@start_date+']( [tran_nr] ASC, [retrieval_reference_nr] ASC)INCLUDE ( [post_tran_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
		')
	   


		IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[tbl_late_reversals]')) BEGIN				
					 
					EXEC('ALTER VIEW  dbo.tbl_late_reversals  AS SELECT * FROM  [tbl_late_reversals_'+@start_date+'] WITH (NOLOCK)')
		END
		ELSE  BEGIN
					
					EXEC('CREATE VIEW dbo.tbl_late_reversals AS SELECT * FROM [tbl_late_reversals_'+@start_date+'] WITH (NOLOCK)')
		END
						
	
		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
			
		 END
		 
		 IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
		 BEGIN
				  DROP TABLE #late_rev_details
				  
			
		 END
		 

END

GO

 exec [usp_populate_late_reversal_table] null, null
 
 GO
 
 
 USE [postilion_office]
 GO
 /****** Object:  StoredProcedure [dbo].[usp_populate_late_reversal_table]    Script Date: 07/10/2017 12:41:00 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 
 
  ALTER  PROCEDURE [dbo].[usp_populate_late_reversal_table]  @start_date varchar(10) , @end_date varchar(10)
  
  AS
  
  BEGIN
  
  		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #reversals
  		 END
  		 
  				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #reversal_categories
  		 END
  		 
  		  IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #late_rev_details
  				  
  			
  		 END
  		 DECLARE @delete_date VARCHAR(10)
  		 SET @delete_date  = CONVERT(VARCHAR(10), DATEADD(D,-2,GETDATE()),112)
  		 
  		SET @start_date  = ISNULL (@start_date,CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),112))
  		
  		SET @end_date    = ISNULL (@end_date,CONVERT(VARCHAR(10), GETDATE(),112))
  		 
  		SELECT   post_tran_id, trans.post_tran_cust_id,datetime_req, tran_nr, prev_post_tran_id, rsp_code_rsp, message_type,settle_amount_impact ,settle_amount_req ,settle_amount_rsp  ,settle_currency_code, sink_node_name,system_trace_audit_nr,tran_amount_req ,tran_amount_rsp  ,tran_currency_code, terminal_id,retrieval_reference_nr,recon_business_date,online_system_id,tran_type INTO #reversals FROM 
  		POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
  		ON 
  		trans.post_tran_cust_id = cust.post_tran_cust_id
  		WHERE
  		datetime_req>=@start_date  and datetime_req <@end_date AND message_type ='0420'
  		AND tran_postilion_originated = 0
  		DECLARE @min_post_tran_id BIGINT
  		
  		SELECT @min_post_tran_id = MIN(prev_post_tran_id) FROM  #reversals
  		 
  		SELECT  post_tran_id,post_tran_cust_id rev_post_tran_cust_id, post_tran_cust_id  trans_post_tran_cust_id,  '1970-01-01' trans_datetime_req , datetime_req  rev_datetime_req, prev_post_tran_id,message_type rev_message_type, rsp_code_rsp rev_rsp_code_rsp,  '0200' post_tran_message_type,'xx' trans_rsp_code_rsp, tran_nr,settle_amount_impact ,settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, tran_type,'LATE' reversal_type
  		  into #late_rev_details from  #reversals  rev WHERE prev_post_tran_id NOT IN (SELECT post_tran_id FROM  post_tran (NOLOCK) WHERE post_tran_id>=@min_post_tran_id )
   
  		select rev.post_tran_id,rev.post_tran_cust_id rev_post_tran_cust_id,trans.post_tran_cust_id trans_post_tran_cust_id, trans.datetime_req trans_datetime_req, rev.datetime_req  rev_datetime_req, rev.prev_post_tran_id, rev.message_type rev_message_type, rev.rsp_code_rsp rev_rsp_code_rsp,  trans.message_type post_tran_message_type,trans.rsp_code_rsp trans_rsp_code_rsp, rev.tran_nr,rev.settle_amount_impact ,rev.settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, rev.tran_type,
  		 case
               
                    when (rev.datetime_req is not  null  and  trans.datetime_req is NULL)  THEN 'LATE'
               when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )>0  THEN 'LATE'
                   when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )=0 then  'TIMELY'
  		END as reversal_type
  		INTO #reversal_categories
  		from #reversals rev 
  		LEFT JOIN post_tran trans (NOLOCK) 
  		on trans.post_tran_id = rev.prev_post_tran_id
  		where trans.tran_postilion_originated = 0  and trans.post_tran_id>=@min_post_tran_id
  		
  
  	    INSERT INTO  tbl_late_reversals_archive SELECT * FROM tbl_late_reversals WITH (NOLOCK)
  		
  		EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_late_reversals_'+@delete_date+']'') AND type in (N''U'')) BEGIN  DROP TABLE [tbl_late_reversals_'+@delete_date+'] END ')
  		
  		EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_late_reversals_'+@start_date+']'') AND type in (N''U'')) BEGIN  DROP TABLE [tbl_late_reversals_'+@start_date+'] END CREATE TABLE [tbl_late_reversals_'+@start_date+']  ([post_tran_id] [bigint] NOT NULL,	[rev_post_tran_cust_id] [bigint] NOT NULL,	[trans_post_tran_cust_id] [bigint] NULL,	[trans_datetime_req] [datetime] NOT NULL,	[rev_datetime_req] [datetime] NOT NULL,	[prev_post_tran_id] [bigint] NOT NULL,	[rev_message_type] [char](4) NOT NULL,	[rev_rsp_code_rsp] [char](2) NULL,	[post_tran_message_type] [char](4) NULL,	[trans_rsp_code_rsp] [char](2) NULL,	[tran_nr] [bigint] NOT NULL,	[settle_amount_impact] [numeric](16, 0) NULL,	[settle_amount_req] [numeric](16, 0) NULL,	[settle_amount_rsp] [numeric](16, 0) NULL,	[settle_currency_code] [char](3) NULL,	[sink_node_name] [varchar](30) NULL,	[system_trace_audit_nr] [char](6) NULL,	[tran_amount_req] [numeric](16, 0) NULL,	[tran_amount_rsp] [numeric](16, 0) NULL,	[tran_currency_code] [char](3) NULL,	[reversal_type] [varchar](6) NULL,	[terminal_id] [varchar](10) NULL,	[retrieval_reference_nr] [varchar](20) NULL,	[online_system_id] [varchar](20) NULL,	[recon_business_date] [datetime] NOT NULL,	[tran_type] [varchar](5) NULL, CONSTRAINT [pk_tbl_late_reversals_3_'+@start_date+'] PRIMARY KEY CLUSTERED (	[post_tran_id] ASC,	[prev_post_tran_id] ASC)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]) ON [PRIMARY]')
  		  EXEC('INSERT  INTO   [tbl_late_reversals_'+@start_date+'] ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],  [recon_business_date],[online_system_id], [tran_type]) 
  	  SELECT  [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type]  
  		FROM (
  		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
  		 FROM  #reversal_categories WHERE reversal_type = ''LATE''
  		 UNION ALL 
  		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
  		 FROM #late_rev_details
  		 ) L')
  				EXEC('
  		CREATE NONCLUSTERED INDEX [indx_recon_business_date] ON [dbo].[tbl_late_reversals_'+@start_date+'] (	[recon_business_date] ASC )
  		INCLUDE ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],[online_system_id],[tran_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 70) ON [PRIMARY]
  
  		CREATE NONCLUSTERED INDEX [ix_tran_rrrn] ON [dbo].[tbl_late_reversals_'+@start_date+']( [tran_nr] ASC, [retrieval_reference_nr] ASC)INCLUDE ( [post_tran_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
  		')
  	   
  
  
  		IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[tbl_late_reversals]')) BEGIN				
  					 
  					EXEC('ALTER VIEW  dbo.tbl_late_reversals  AS SELECT * FROM  [tbl_late_reversals_'+@start_date+'] WITH (NOLOCK)')
  		END
  		ELSE  BEGIN
  					
  					EXEC('CREATE VIEW dbo.tbl_late_reversals AS SELECT * FROM [tbl_late_reversals_'+@start_date+'] WITH (NOLOCK)')
  		END
  						
  	
  		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #reversals
  		 END
  		 
  				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #reversal_categories
  			
  		 END
  		 
  		 IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
  		 BEGIN
  				  DROP TABLE #late_rev_details
  				  
  			
  		 END
  		 
  
  END
  
 GO
 
 
 ALTER FUNCTION  [dbo].[fn_rpt_late_reversal] 
 
   (@tran_nr bigint,@message_type char (4),@retrieval_reference_nr varchar(20))
 	RETURNS varchar
 AS
 BEGIN
 	DECLARE @r varchar
 		SET @r  ='0';
     IF(@message_type= '0420') BEGIN
 		IF  EXISTS(select  1 from tbl_late_reversals(NOLOCK)  WHERE  tran_nr =@tran_nr  AND  retrieval_reference_nr =@retrieval_reference_nr )
 			BEGIN
 			SET @r = '1'
 		END
 		end
 	ELSE
 	 BEGIN
 		SET @r = '0'
    end
 	RETURN @r
 	
 END

