IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_tran_summary_staging_info]') AND type in (N'U')) BEGIN

	CREATE TABLE [dbo].[post_tran_summary_staging_info](
		[info_id]     INT NOT NULL,
		[serverName] [varchar](255) NOT NULL,
		[tableName] [varchar](255) NOT NULL,
		[reportDate] DATETIME
		CONSTRAINT [pk_post_tran_summary_staging_info] PRIMARY KEY CLUSTERED 
(
	[info_id] ASC
)
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 92) ON [PRIMARY]
	) ON [PRIMARY]

END

DECLARE @serverName  VARCHAR(100);
DECLARE @reportDate DATETIME;
DECLARE @tableName  VARCHAR(100);
DECLARE @tableName2  VARCHAR(100);
DECLARE @sqlQuery  VARCHAR(max);
declare @err_message  varchar (500);
DECLARE @tran_date VARCHAR(12);
SET  @tran_date =REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '');

SET  @tableName2 = 'post_tran_summary_'+@tran_date;

SELECT 
     @serverName  = serverName,
     @tableName   =  tableName,
     @reportDate  =  reportDate
FROM   
   [post_tran_summary_staging_info] (NOLOCK)
WHERE info_id = 1;


IF NOT EXISTS (SELECT SRVID FROM sys.sysservers WHERE srvname =@serverName )
BEGIN
   print('There is no linked server for: '+@serverName+'. Please add a linked server for '+@serverName+' and rerun the job. Setting  server to '+@@servername);
   
END

IF(@serverName IS NULL) begin
   SET @serverName = @@SERVERNAME;  
END
IF(@tableName IS NULL) begin
 SET  @tableName = @tableName2;
end

 if (@reportDate IS NULL)BEGIN
 SET  @reportDate = @tran_date;
 end
 
 SET   @sqlQuery = 'IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[get_dates_in_range]'') AND type in (N''FN'', N''IF'', N''TF'', N''FS'', N''FT''))
BEGIN
CREATE FUNCTION [dbo].[get_dates_in_range]
(
     @StartDate    VARCHAR(30)  
    ,@EndDate    VARCHAR(30)   
)
RETURNS
@DateList table
(
    Date datetime
)
AS
BEGIN


IF ISDATE(@StartDate)!=1 OR ISDATE(@EndDate)!=1
BEGIN
    RETURN
END

while (DATEDIFF(D,  @StartDate,@EndDate)>=0) BEGIN 

INSERT INTO @DateList
        (Date)
    SELECT
        @StartDate
SET  @StartDate = DATEADD(D, 1 ,@StartDate);
        END


RETURN
END

END;'

exec sp_executesql   @sqlQuery;

SET   @sqlQuery = '
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT 
                    post_tran_id ,
					t.post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					t.recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
				
				FROM	 
				['+@serverName+'].[postilion_office].[dbo].[post_tran] t (NOLOCK) 
							JOIN
				 ['+@serverName+'].[postilion_office].[dbo].[post_tran_cust] c (NOLOCK) 
				ON t.post_tran_cust_id = c.post_tran_cust_id
				 	JOIN
				  (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('''+CONVERT(VARCHAR(max) , @reportDate, 112)+''','''+CONVERT(varchar(max) , @reportDate, 112)+'''))r
				ON
			    t.recon_business_date = r.recon_business_date
			     OPTION (MAXDOP 8);';
			     
exec sp_executesql   @sqlQuery;