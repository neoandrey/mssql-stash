USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[norm_post_tran_summary]    Script Date: 05/24/2016 15:09:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[norm_post_tran_summary]
			@date	char(8)
as
begin

	createtable:
	declare @date_specified BIT
	set @date_specified = 1

	if(@date is null)
	begin
		set @date_specified  = 0
		set @date = CONVERT(varchar(10),dateadd(dd,-1,getdate()),112)
	end
	if not exists (select top 1 name from sys.objects where name like 'post_tran_summary_'+@date  and type = 'U' )
	begin
		print 'creating new post_tran_summary partition'
		
		declare @sql_statement varchar(8000)
		set @sql_statement = '
		
		declare @completed_table varchar (50)
		set @completed_table = (select top 1 name from sys.objects where name like ''post_tran_summary_%'' and type = ''U'' order by name desc)
		declare @view_created BIT
		set @view_created = 0
		declare @action VARCHAR(10)
		
		if @completed_table is not null
		begin
			print ''previous completed table: ''+@completed_table
			print ''updating view.....''
			set @view_created = 1
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action = ''CREATE''
			end
			else
			begin
				set @action = ''ALTER''
			end
			
				exec(@action+'' VIEW dbo.post_tran_summary
				as
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM ''+@completed_table+'' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end
		else
		begin
			set @view_created = 0
		end
		
		print ''creating table post_tran_summary_'+@date+'''
		CREATE TABLE dbo.post_tran_summary_'+@date+'
		(
			post_tran_id bigint NOT NULL,
			post_tran_cust_id bigint NOT NULL,
			prev_post_tran_id bigint NULL,
			sink_node_name dbo.POST_NAME NULL,
			tran_postilion_originated dbo.POST_BOOL NOT NULL,
			tran_completed dbo.POST_BOOL NOT NULL,
			message_type char(4) NOT NULL,
			tran_type char(2) NULL,
			tran_nr bigint NOT NULL,
			system_trace_audit_nr char(6) NULL,
			rsp_code_req char(2) NULL,
			rsp_code_rsp char(2) NULL,
			abort_rsp_code char(2) NULL,
			auth_id_rsp char(6) NULL,
			retention_data varchar(999) NULL,
			acquiring_inst_id_code varchar(11) NULL,
			message_reason_code char(4) NULL,
			retrieval_reference_nr char(12) NULL,
			datetime_tran_gmt datetime NULL,
			datetime_tran_local datetime NOT NULL,
			datetime_req datetime NOT NULL,
			datetime_rsp datetime NULL,
			realtime_business_date datetime NOT NULL,
			recon_business_date datetime NOT NULL,
			from_account_type char(2) NULL,
			to_account_type char(2) NULL,
			from_account_id varchar(28) NULL,
			to_account_id varchar(28) NULL,
			tran_amount_req dbo.POST_MONEY NULL,
			tran_amount_rsp dbo.POST_MONEY NULL,
			settle_amount_impact dbo.POST_MONEY NULL,
			tran_cash_req dbo.POST_MONEY NULL,
			tran_cash_rsp dbo.POST_MONEY NULL,
			tran_currency_code dbo.POST_CURRENCY NULL,
			tran_tran_fee_req dbo.POST_MONEY NULL,
			tran_tran_fee_rsp dbo.POST_MONEY NULL,
			tran_tran_fee_currency_code dbo.POST_CURRENCY NULL,
			settle_amount_req dbo.POST_MONEY NULL,
			settle_amount_rsp dbo.POST_MONEY NULL,
			settle_tran_fee_req dbo.POST_MONEY NULL,
			settle_tran_fee_rsp dbo.POST_MONEY NULL,
			settle_currency_code dbo.POST_CURRENCY NULL,
			tran_reversed char(1) NULL,
			prev_tran_approved dbo.POST_BOOL NULL,
			extended_tran_type char(4) NULL,
			payee char(25) NULL,
			online_system_id int NULL,
			receiving_inst_id_code varchar(11) NULL,
			routing_type int NULL,
			source_node_name dbo.POST_NAME NOT NULL,
			pan varchar(19) NULL,
			card_seq_nr varchar(3) NULL,
			expiry_date char(4) NULL,
			terminal_id dbo.POST_TERMINAL_ID NULL,
			terminal_owner varchar(25) NULL,
			card_acceptor_id_code char(15) NULL,
			merchant_type char(4) NULL,
			card_acceptor_name_loc char(40) NULL,
			address_verification_data varchar(29) NULL,
			totals_group varchar(12) NULL,
			pan_encrypted char(18) NULL
		)
		
		if(@view_created = 0)
		begin
			print ''setting view to new post_tran_summary partition''
			declare @action_2 varchar(10)
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action_2 = ''CREATE''
			end
			else
			begin
				set @action_2 = ''ALTER''
			end
				exec(@action_2+'' VIEW dbo.post_tran_summary
				AS
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM post_tran_summary_'+@date+' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end'
		
		print @sql_statement
		exec (@sql_statement)
		
		exec('		
		if not exists (select top 1 * from sys.objects where name = ''post_tran_summary_shadow'' and type =''V'')
		begin
			exec(''CREATE VIEW dbo.post_tran_summary_shadow
			AS
				select  * from post_tran_summary_'+@date+''')
		end
		else
		begin
			exec(''ALTER VIEW dbo.post_tran_summary_shadow
			as
				select  * from post_tran_summary_'+@date+''')
		end
		')
		
		--print @sql_statement
		--exec (@sql_statement)
	end
	declare @current_table varchar(50)
	declare @table_date char(8)
	if(@date_specified = 1)
	begin
		set @current_table = 'post_tran_summary_'+@date
	end
	else
	begin
		set @current_table = (select top 1 name from sys.objects where name like 'post_tran_summary_%' and type = 'U' order by name desc)
	end
		
	set @table_date = SUBSTRING(@current_table,19,8)
	
	declare @last_post_tran_id bigint
	if exists (select top 1 post_tran_id from post_tran_summary_shadow (nolock))
	begin
		select @last_post_tran_id = (select MAX(post_tran_id) from post_tran_summary_shadow (nolock))
	end
	else
	begin
		set @last_post_tran_id =0
	end
	
	--if(@last_post_tran_id =0)
	--begin
		--select @last_post_tran_id = min(post_tran_id) from post_tran (nolock) where CONVERT(char(8),recon_business_date,112) = @table_date
	--end
	
	declare @closed_norm_session_post_tran_id bigint
	set @closed_norm_session_post_tran_id = (select top 1 first_post_tran_id from post_normalization_session (nolock) where completed =1 order by normalization_session_id desc)
	
	print 'copying data ' ---+ cast(@last_post_tran_id as varchar(16))
	INSERT INTO post_tran_summary_shadow
				SELECT post_tran_id ,
				post_tran.post_tran_cust_id ,
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
				recon_business_date ,
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
				--structured_data_req,
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
			
			FROM	post_tran (NOLOCK) 
						INNER JOIN
					post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) 
			ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
			where
				post_tran_id >@last_post_tran_id
				and post_tran_id < @closed_norm_session_post_tran_id
				--and convert(varchar(8),recon_business_date,112) = @table_date
			 	 and REPLACE(CONVERT(VARCHAR(10), recon_business_date,111),'/', '') = @table_date
			order by post_tran_id
			OPTION (MAXDOP 6)
				--and post_tran_id not in (select post_tran_id from post_tran_summary_shadow (nolock))
	
	if @@ROWCOUNT =0 -- nothing copied
	BEGIN
		print 'Nothing copied'
		if(@table_date  =  REPLACE(CONVERT(VARCHAR(10), getdate(),111),'/', '')  OR @date_specified = 1) -- today
		begin
			print 'Either a date was specified for which there is no data or no additional data has been normalized'
			RETURN
		end
		DECLARE @norm_cutover INT;
		EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		
		if(CAST((CONVERT(varchar(8),getdate(),112)) as int) > cast (@table_date as int)) -- today > last table date & cant copy any more data
		begin
			print 'Its next day...'
			if(@norm_cutover=0) begin print '...but normalization has not caught up' RETURN end  -- wait for normalization to cut-over
			else -- normalization has cut-over to a new date, create new table and start copying again...
			begin
				-- check that the last closed batch is greater than the max post_tran_id from that recon_biz_date
				declare @max_tran_id bigint
				set @max_tran_id = (select MAX(post_tran_id) from post_tran (nolock) where recon_business_date = CONVERT(DATE,@table_date))
				if(@closed_norm_session_post_tran_id < @max_tran_id)
				begin
					-- CHECK AGAIN
					RETURN
				end
				print 'Lets check to see if we missed out any other transactions before cutting over. Querying...'
					INSERT INTO post_tran_summary_shadow
					SELECT post_tran_id ,
					post_tran.post_tran_cust_id ,
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
					recon_business_date ,
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
					--structured_data_req,
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
				
				FROM	post_tran (NOLOCK) 
							INNER JOIN
						post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) 
				ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
				where convert(varchar(8),recon_business_date,112) = @table_date
				and post_tran_id < @closed_norm_session_post_tran_id
				and post_tran_id not in (select post_tran_id from dbo.post_tran_summary_shadow (nolock))
				
				print 'Done!'
				print 'Cutting over to next business day then...'
				--create indexes on current table with @table_date 
				
				declare @old_data datetime
				set @old_data = DATEADD(dd,-2,CONVERT(DATE,@table_date))
				declare @old_data_timestamp  char(8)
				set @old_data_timestamp = CONVERT(char(8),@old_data,112)
				
				print 'Housekeeping: deleting old table post_tran_summary_'+@old_data_timestamp
				exec ('
					if exists (select top 1 * from sys.objects where name = ''post_tran_summary_'+@old_data_timestamp+''' and type =''U'')
					begin
						drop table post_tran_summary_'+@old_data_timestamp+'
					end
				')
				print 'Creating indexes on last table...post_tran_summary_'+@table_date
				exec (
				' 
					CREATE CLUSTERED INDEX [ix_post_tran_'+@date+'_summary_2] ON [dbo].[post_tran_summary_'+@date+'] 
					(
						[post_tran_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
							
					CREATE NONCLUSTERED INDEX [is_post_tran_'+@table_date+'_summary_3] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[sink_node_name] ASC,
						[tran_postilion_originated] ASC,
						[tran_completed] ASC,
						[message_type] ASC,
						[tran_type] ASC,
						[rsp_code_rsp] ASC,
						[message_reason_code] ASC,
						[datetime_req] ASC,
						[recon_business_date] ASC,
						[tran_reversed] ASC,
						[extended_tran_type] ASC,
						[source_node_name] ASC,
						[terminal_id] ASC,
						[terminal_owner] ASC,
						[merchant_type] ASC,
						[totals_group] ASC
					)
					INCLUDE ( [post_tran_cust_id],
					[system_trace_audit_nr],
					[auth_id_rsp],
					[from_account_type],
					[to_account_type],
					[from_account_id],
					[to_account_id],
					[tran_amount_req],
					[tran_amount_rsp],
					[settle_amount_impact],
					[tran_cash_req],
					[tran_cash_rsp],
					[tran_currency_code],
					[tran_tran_fee_req],
					[tran_tran_fee_rsp],
					[tran_tran_fee_currency_code],
					[settle_amount_req],
					[settle_amount_rsp],
					[settle_tran_fee_req],
					[settle_tran_fee_rsp],
					[settle_currency_code],
					[online_system_id],
					[card_seq_nr],
					[expiry_date],
					[card_acceptor_id_code],
					[card_acceptor_name_loc],
					[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
                    ');
                    

					declare  @table_name VARCHAR(255)
declare  @sqlquery   VARCHAR(max)
SET @table_name= 'post_tran_summary_'+@table_date;
set @sqlquery ='
CREATE NONCLUSTERED INDEX [indx_recon_bus_1] ON [dbo].['+@table_name+'] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_recon_bus_2]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_recon_bus_2] ON [dbo].['+@table_name+'] 
(
	[recon_business_date] ASC,
	[source_node_name] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_10]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_10] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[acquiring_inst_id_code] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_11]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_11] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_15]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_15] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_rsp],
[retention_data],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[source_node_name],
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_16]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_16] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_9]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_9] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postmessage_t_4]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postmessage_t_4] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[message_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postrecon_bus_3]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postrecon_bus_3] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_6]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_6] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[sink_node_name] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_7]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_7] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_8]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_8] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[sink_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsource_no_20]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsource_no_20] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_posttran_type_18]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_posttran_type_18] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_posttran_type_19]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [indx_tran_posttran_type_19] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_3]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_3] ON [dbo].['+@table_name+'] 
(
	[sink_node_name] ASC,
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[rsp_code_rsp] ASC,
	[message_reason_code] ASC,
	[datetime_req] ASC,
	[recon_business_date] ASC,
	[tran_reversed] ASC,
	[extended_tran_type] ASC,
	[source_node_name] ASC,
	[terminal_id] ASC,
	[terminal_owner] ASC,
	[merchant_type] ASC,
	[totals_group] ASC
)
INCLUDE ( [post_tran_cust_id],
[system_trace_audit_nr],
[auth_id_rsp],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[tran_amount_req],
[tran_amount_rsp],
[settle_amount_impact],
[tran_cash_req],
[tran_cash_rsp],
[tran_currency_code],
[tran_tran_fee_req],
[tran_tran_fee_rsp],
[tran_tran_fee_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_req],
[settle_tran_fee_rsp],
[settle_currency_code],
[online_system_id],
[card_seq_nr],
[expiry_date],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_10]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_10] ON [dbo].['+@table_name+'] 
(
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_2]    Script Date: 05/24/2016 15:33:08 ******/
CREATE CLUSTERED INDEX [ix_'+@table_name+'_summary_2] ON [dbo].['+@table_name+'] 
(
	[post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_4]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_4] ON [dbo].['+@table_name+'] 
(
	[tran_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_5]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_5] ON [dbo].['+@table_name+'] 
(
	[retrieval_reference_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_6]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_6] ON [dbo].['+@table_name+'] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_7]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_7] ON [dbo].['+@table_name+'] 
(
	[receiving_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_8]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_8] ON [dbo].['+@table_name+'] 
(
	[message_reason_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_'+@table_name+'_summary_9]    Script Date: 05/24/2016 15:33:08 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_summary_9] ON [dbo].['+@table_name+'] 
(
	[payee] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO';
exec sp_executesql @sqlquery;



				set @date = CONVERT(varchar(8),getdate(),112)
				goto createtable
			end
		END
	END

end
