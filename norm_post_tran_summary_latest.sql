USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[norm_post_tran_summary]    Script Date: 04/11/2016 14:35:37 ******/
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
	if not exists (select top 1 name from sys.objects where name like 'post_tran_summary_%'  and type = 'U' )
	begin
		
		declare @sql_statement varchar(8000)
		set @sql_statement = '
		
		declare @completed_table varchar (50)
		set @completed_table = (select top 1 name from sys.objects where name like ''post_tran_summary_%'' and type = ''U'' order by name desc)
		declare @view_created BIT
		set @view_created = 0
		
		if @completed_table is not null
		begin
			set @view_created = 1
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				exec(''CREATE VIEW dbo.post_tran_summary
				AS
					select  * from @completed_table'')
			end
			else
			begin
				exec(''ALTER VIEW dbo.post_tran_summary
				as
					select  * from @completed_table'')
			end
		end
		else
		begin
			set @view_created = 0
		end
		
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
			structured_data_req text NULL,
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
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				exec(''CREATE VIEW dbo.post_tran_summary
				AS
					select  * from post_tran_summary_'+@date+''')
			end
			else
			begin
				exec(''ALTER VIEW dbo.post_tran_summary
				as
					select  * from post_tran_summary_'+@date+''')
			end
		end
		'
		
		print @sql_statement
		exec (@sql_statement)
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
	if exists (select top 1 post_tran_id from post_tran_summary (nolock))
	begin
		select @last_post_tran_id = (select MAX(post_tran_id) from post_tran_summary (nolock))
	end
	else
	begin
		set @last_post_tran_id =0
	end
	
	print 'copying data from....posttranId ' + cast(@last_post_tran_id as varchar(16))
	
	INSERT INTO post_tran_summary
		SELECT top 50000 post_tran_id ,
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
		structured_data_req,
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
			post_tran_cust (NOLOCK) 
	ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
	where 
		post_tran_id >@last_post_tran_id
		and convert(varchar(8),datetime_req,112) = @table_date
	
	if @@ROWCOUNT =0 -- nothing copied
	BEGIN
		print 'Nothing copied'
		if(@table_date = CONVERT(varchar(8),getdate(),112) OR @date_specified = 1) -- today
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
				print 'Cutting over to next business day then...'
				--create indexes on current table with @table_date 
				--exec ('
				--if exists (select top 1 * from sys.objects where name = ''
				--')
				exec (
				'
					CREATE CLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 2] ON [dbo].[post_tran_summary'+@table_date+'] 
					(
						[post_tran_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 4] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[datetime_tran_local] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 5] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[system_trace_audit_nr] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 7] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[datetime_req] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 8] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[tran_nr] ASC,
						[message_type] ASC,
						[tran_postilion_originated] ASC,
						[online_system_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary 9] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[recon_business_date] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary _c_1] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[pan] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary _c_2] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[terminal_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary _c_5] ON [dbo].[post_tran_summary'+@table_date+']  
					(
						[card_acceptor_id_code_cs] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
					GO
				'
				)
				set @date = CONVERT(varchar(8),getdate(),112)
				goto createtable
			end
		END
	END
	else
	begin
		print cast(@@ROWCOUNT  as varchar(50)) + ' records copied'
	end
end

