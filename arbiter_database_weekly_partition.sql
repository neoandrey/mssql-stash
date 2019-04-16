USE master ;  
GO  
CREATE DATABASE arbiter  
ON   
( NAME = arbiter,  
    FILENAME = 'E:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\arbiter.mdf',  
    SIZE = 10,   
    FILEGROWTH = 512MB )  
LOG ON  
( NAME = arbiter_log,  
    FILENAME = 'H:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\arbiter_log.ldf',  
    SIZE = 5MB,   
    FILEGROWTH = 256MB ) ;  
GO  


DECLARE @start_date DATETIME  = '2013-09-01'
DECLARE @number_of_files INT  = 1200
DECLARE @current_end_date  DATETIME;
DECLARE @span   BIGINT  = 7

DECLARE @end_date  DATETIME = DATEADD(D, (@span *@number_of_files) , @start_date)
DECLARE @dateTable TABLE (DATESTR varchar(750))
SET @current_end_date = @start_date;

 WHILE (@current_end_date<= @end_date)BEGIN
 	SET @current_end_date =  dateadd(d, @span, @current_end_date);
 INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILEGROUP [arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+']' ) ;
 
 end
 INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILEGROUP [arbiter_partition_default]' ) ;
 select * from @dateTable
 
 SET @current_end_date=@start_date;
 
 DELETE FROM @dateTable 
 
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION  arbiter_datetime_partition_function (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (@current_end_date<=@end_date)BEGIN
  SET @current_end_date =  dateadd(d, @span, @current_end_date);
 IF((@current_end_date) < (@end_date+ @span) ) BEGIN
      INSERT INTO @dateTable values(   ''''+CONVERT(VARCHAR(8), @current_end_date,112)+ ''''+',') ;
 END
 ELSE BEGIN
  INSERT INTO @dateTable values(  ''''+  CONVERT(VARCHAR(8), @current_end_date,112)+'''') ;
 END
 END
 insert into @dateTable values(')');
 select * from @dateTable
 

SET @current_end_date= @start_date;
 
 DELETE FROM @dateTable
 
 DECLARE @dateTable2 TABLE (DATESTR varchar(750))
 
 DECLARE @drive_1 VARCHAR(5) = 'F:'
 DECLARE @drive_2 VARCHAR(5) = 'G:'
 DECLARE @drive_3 VARCHAR(5) = 'H:'
 DECLARE @drive_4 VARCHAR(5) = 'I:'
 
 DECLARE @counter  INT   =1
 WHILE (@current_end_date<= @end_date)BEGIN 
 set @current_end_date =  dateadd(d, @span, @current_end_date);
  IF ( @counter %4 =0) BEGIN
     INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILE ( NAME = N''arbiter_partition_'+  CONVERT(VARCHAR(8), @current_end_date,112)+''',
  	 FILENAME = N'''+@drive_1+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\arbiter_partition_file_'+  CONVERT(VARCHAR(8),@current_end_date,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) 
	 TO FILEGROUP [arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+']') ;
	insert into  @dateTable2 values('MKDIR "'+@drive_1+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\"')
  END
  ELSE  IF ( @counter %3 =0) BEGIN
     INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILE ( NAME = N''arbiter_partition_'+  CONVERT(VARCHAR(8), @current_end_date,112)+''',
  	 FILENAME = N'''+@drive_2+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\arbiter_partition_file_'+  CONVERT(VARCHAR(8),@current_end_date,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) 
	 TO FILEGROUP [arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+']') ;
	insert into  @dateTable2 values('MKDIR "'+@drive_2+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\"')
  END  ELSE  IF ( @counter %2 =0) BEGIN
     INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILE ( NAME = N''arbiter_partition_'+  CONVERT(VARCHAR(8) ,@current_end_date,112)+''',
  	 FILENAME = N'''+@drive_3+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\arbiter_partition_file_'+  CONVERT(VARCHAR(8),@current_end_date,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB )
	 TO FILEGROUP [arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+']') ;
	insert into  @dateTable2 values('MKDIR "'+@drive_3+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\"')
  END  ELSE
  BEGIN
  INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILE ( NAME = N''arbiter_partition_'+  CONVERT(VARCHAR(8), @current_end_date,112)+''', FILENAME = N'''+@drive_4+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\arbiter_partition_file_'+ CONVERT(VARCHAR(8),@current_end_date,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+']') ;
  insert into  @dateTable2 values('MKDIR "'+@drive_4+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\"')
  END
  
   set @counter =@counter+1
 end
   INSERT INTO @dateTable values('ALTER DATABASE [arbiter] ADD FILE ( NAME = N''arbiter_partition_default'', FILENAME = N'''+@drive_1+'\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\arbiter\arbiter_partition_file_default.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [arbiter_partition_default]') ;

 select * from @dateTable
 SELECT distinct * FROM @dateTable2

 
 DELETE FROM @dateTable
  SET @current_end_date=@start_date
 
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME arbiter_datetime_partition_scheme AS PARTITION arbiter_datetime_partition_function TO ('
 WHILE (@current_end_date<= @end_date)BEGIN 
  set @current_end_date =  dateadd(d, @span, @current_end_date);
		INSERT INTO @dateTable values('[arbiter_partition_'+ CONVERT(VARCHAR(8),@current_end_date,112)+'],') ;
				
 END
 insert into @dateTable values('[arbiter_partition_default])');
 select * from @dateTable
 
 
 
 USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions_withdrawals]    Script Date: 10/30/2018 4:33:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_postilion_office_transactions_withdrawals](
	[postilion_office_transactions_id] [bigint] IDENTITY(10000000000,1) NOT NULL,
	[issuer_code] [varchar](60) NULL,
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[tran_nr] [bigint] NULL,
	[masked_pan] [varchar](19) NULL,
	[terminal_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [varchar](50) NULL,
	[tran_type_description] [varchar](60) NULL,
	[tran_amount_req] [float] NULL,
	[tran_fee_req] [float] NULL,
	[currency_alpha_code] [varchar](20) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[datetime_req] [datetime] NOT NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	[auth_id_rsp] [varchar](15) NULL,
	[settle_amount_rsp] [float] NULL,
	[settle_amount_impact] [float] NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[settle_currency_code] [char](3) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_currency_alpha_code] [varchar](20) NULL,
	[online_system_id] [int] NULL DEFAULT ((1)),
	[server_id] [int] NULL DEFAULT ((1)),
	[tran_reversed] [char](1) NULL,
	[Logged] [bit] NULL,
	[Type] [char](1) NULL,
	[to_account] [varchar](30) NULL,
	[extended_tran_type] [char](6) NULL,
 CONSTRAINT [PK_tbl_postilion_office_transactions_staging_new_2ab] PRIMARY KEY NONCLUSTERED 
(
	[postilion_office_transactions_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req),
 CONSTRAINT [indx_tran_nr_intermediate_staging_3ab] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
) ON arbiter_datetime_partition_scheme(datetime_req)

GO

ALTER TABLE [dbo].[tbl_postilion_office_transactions_withdrawals]  ADD CHECK(  postilion_office_transactions_id>=10000000000 AND  postilion_office_transactions_id< 40000000000 )
SET ANSI_PADDING OFF
GO

USE [arbiter]
GO

/****** Object:  Index [indx_datetime_req]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_datetime_req] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_datetime_req_in_post_tran_id]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_datetime_req_in_post_tran_id] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[datetime_req] ASC
)
INCLUDE ( 	[post_tran_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 95) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_issuer_code]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_issuer_code] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[issuer_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_post_tran_id]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_id] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[post_tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
 ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_tran_nr]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [indx_tran_nr] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[tran_nr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_tran_nr_intermediate_staging_3ab]    Script Date: 10/30/2018 4:35:46 PM ******/
ALTER TABLE [dbo].[tbl_postilion_office_transactions_withdrawals] ADD  CONSTRAINT [indx_tran_nr_intermediate_staging_3ab] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [ix_fbn_find_transactions]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_fbn_find_transactions] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[masked_pan] ASC,
	[tran_type_description] ASC,
	[datetime_req] ASC,
	[source_node_name] ASC
)
INCLUDE ( 	[postilion_office_transactions_id],
	[issuer_code],
	[post_tran_cust_id],
	[tran_nr],
	[terminal_id],
	[card_acceptor_id_code],
	[card_acceptor_name_loc],
	[tran_amount_req],
	[tran_fee_req],
	[currency_alpha_code],
	[system_trace_audit_nr],
	[retrieval_reference_nr],
	[acquirer_code],
	[rsp_code_rsp],
	[terminal_owner],
	[sink_node_name],
	[merchant_type],
	[from_account_id],
	[tran_tran_fee_req],
	[extended_tran_type]) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [ix_tran_nr_n_date]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_tran_nr_n_date] ON [dbo].[tbl_postilion_office_transactions_withdrawals]
(
	[datetime_req] ASC
)
INCLUDE ( 	[tran_nr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO


USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions_transfers]    Script Date: 10/30/2018 4:36:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_postilion_office_transactions_transfers](
	[postilion_office_transactions_id] [bigint] IDENTITY(40000000000,1) NOT NULL,
	[issuer_code] [varchar](60) NULL,					
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[tran_nr] [bigint] NULL,
	[masked_pan] [varchar](19) NULL,
	[terminal_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [varchar](50) NULL,
	[tran_type_description] [varchar](60) NULL,
	[tran_amount_req] [float] NULL,
	[tran_fee_req] [float] NULL,
	[currency_alpha_code] [varchar](20) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[datetime_req] [datetime] NOT NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	[auth_id_rsp] [varchar](15) NULL,
	[settle_amount_rsp] [float] NULL,
	[settle_amount_impact] [float] NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[settle_currency_code] [char](3) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_currency_alpha_code] [varchar](20) NULL,
	[online_system_id] [int] NULL DEFAULT ((1)),
	[server_id] [int] NULL DEFAULT ((1)),
	[tran_reversed] [char](1) NULL,
	[Logged] [bit] NULL,
	[Type] [char](1) NULL,
	[to_account] [varchar](30) NULL,
	[extended_tran_type] [char](6) NULL,
 CONSTRAINT [PK_tbl_postilion_office_transactions_transfers_2a] PRIMARY KEY NONCLUSTERED 
(
	[postilion_office_transactions_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req),
 CONSTRAINT [unk_tran_nr_inline_server_id] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON arbiter_datetime_partition_scheme(datetime_req)
) ON arbiter_datetime_partition_scheme(datetime_req)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_postilion_office_transactions_transfers]  ADD CHECK(  postilion_office_transactions_id>=40000000000 AND  postilion_office_transactions_id< 70000000000 )



USE [arbiter]
GO

/****** Object:  Index [indx_datetime_req]    Script Date: 10/30/2018 4:37:41 PM ******/
CREATE NONCLUSTERED INDEX [indx_datetime_req] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[datetime_req] ASC
)
INCLUDE ( 	[issuer_code],
	[masked_pan],
	[card_acceptor_id_code],
	[card_acceptor_name_loc],
	[tran_type_description],
	[tran_amount_req],
	[system_trace_audit_nr],
	[retrieval_reference_nr],
	[acquirer_code],
	[rsp_code_rsp],
	[merchant_type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_post_tran_id]    Script Date: 10/30/2018 4:37:41 PM ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_id] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[post_tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_postilion_office_transactions_id]    Script Date: 10/30/2018 4:37:41 PM ******/
CREATE NONCLUSTERED INDEX [indx_postilion_office_transactions_id] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[postilion_office_transactions_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_postilion_office_transactions_id_2]    Script Date: 10/30/2018 4:37:41 PM ******/
CREATE NONCLUSTERED INDEX [indx_postilion_office_transactions_id_2] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[postilion_office_transactions_id] ASC
)
INCLUDE ( 	[issuer_code],
	[post_tran_id],
	[post_tran_cust_id],
	[tran_nr],
	[masked_pan],
	[terminal_id],
	[card_acceptor_id_code],
	[card_acceptor_name_loc],
	[tran_type_description],
	[tran_amount_req],
	[tran_fee_req],
	[currency_alpha_code],
	[system_trace_audit_nr],
	[datetime_req],
	[retrieval_reference_nr],
	[acquirer_code],
	[rsp_code_rsp],
	[terminal_owner],
	[sink_node_name],
	[merchant_type],
	[source_node_name],
	[from_account_id],
	[tran_tran_fee_req],
	[auth_id_rsp],
	[settle_amount_rsp],
	[settle_amount_impact],
	[pos_terminal_type],
	[settle_currency_code],
	[tran_currency_code],
	[tran_currency_alpha_code],
	[online_system_id],
	[server_id],
	[tran_reversed],
	[Logged],
	[Type],
	[to_account],
	[extended_tran_type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_tran_type_descriptiondatetime_req]    Script Date: 10/30/2018 4:37:42 PM ******/
CREATE NONCLUSTERED INDEX [indx_tran_type_descriptiondatetime_req] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[tran_type_description] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [unk_tran_nr_inline_server_id]    Script Date: 10/30/2018 4:37:42 PM ******/
ALTER TABLE [dbo].[tbl_postilion_office_transactions_transfers] ADD  CONSTRAINT [unk_tran_nr_inline_server_id] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON arbiter_datetime_partition_scheme(datetime_req)
GO


/****** Object:  Index [ix_tran_nr_n_date]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_tran_nr_n_date] ON [dbo].[tbl_postilion_office_transactions_transfers]
(
	[datetime_req] ASC
)
INCLUDE ( 	[tran_nr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO


USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions_paycode]    Script Date: 10/30/2018 4:59:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_postilion_office_transactions_paycode](
	[postilion_office_transactions_id] [bigint] IDENTITY(70000000000,1) NOT NULL,
	[issuer_code] [varchar](60) NULL,
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[tran_nr] [bigint] NULL,
	[masked_pan] [varchar](19) NULL,
	[terminal_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [varchar](50) NULL,
	[tran_type_description] [varchar](60) NULL,
	[tran_amount_req] [float] NULL,
	[tran_fee_req] [float] NULL,
	[currency_alpha_code] [varchar](20) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[datetime_req] [datetime] NOT NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	[auth_id_rsp] [varchar](15) NULL,
	[settle_amount_rsp] [float] NULL,
	[settle_amount_impact] [float] NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[settle_currency_code] [char](3) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_currency_alpha_code] [varchar](20) NULL,
	[online_system_id] [int] NULL DEFAULT ((1)),
	[server_id] [int] NULL DEFAULT ((1)),
	[tran_reversed] [char](1) NULL,
	[Logged] [bit] NULL,
	[Type] [char](1) NULL,
	[to_account] [varchar](30) NULL,
	[extended_tran_type] [char](6) NULL,
 CONSTRAINT [PK_tbl_postilion_office_transactions_paycode] PRIMARY KEY NONCLUSTERED 
(
	[postilion_office_transactions_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON arbiter_datetime_partition_scheme(datetime_req),
 CONSTRAINT [indx_tran_nr_intermediate_staging_3] UNIQUE NONCLUSTERED 
(   [datetime_req],
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON arbiter_datetime_partition_scheme(datetime_req)
) ON arbiter_datetime_partition_scheme(datetime_req)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_postilion_office_transactions_paycode]  ADD CHECK(  postilion_office_transactions_id>=70000000000  AND    postilion_office_transactions_id <100000000000 )

/****** Object:  Index [ix_tran_nr_n_date]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_tran_nr_n_date] ON [dbo].[tbl_postilion_office_transactions_paycode]
(
	[datetime_req] ASC
)
INCLUDE ( 	[tran_nr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO

 USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions_others]    Script Date: 10/30/2018 4:33:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_postilion_office_transactions_others](
	[postilion_office_transactions_id] [bigint] IDENTITY(100000000000,1) NOT NULL,
	[issuer_code] [varchar](60) NULL,
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[tran_nr] [bigint] NULL,
	[masked_pan] [varchar](19) NULL,
	[terminal_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [varchar](50) NULL,
	[tran_type_description] [varchar](60) NULL,
	[tran_amount_req] [float] NULL,
	[tran_fee_req] [float] NULL,
	[currency_alpha_code] [varchar](20) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[datetime_req] [datetime] NOT NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	[auth_id_rsp] [varchar](15) NULL,
	[settle_amount_rsp] [float] NULL,
	[settle_amount_impact] [float] NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[settle_currency_code] [char](3) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_currency_alpha_code] [varchar](20) NULL,
	[online_system_id] [int] NULL DEFAULT ((1)),
	[server_id] [int] NULL DEFAULT ((1)),
	[tran_reversed] [char](1) NULL,
	[Logged] [bit] NULL,
	[Type] [char](1) NULL,
	[to_account] [varchar](30) NULL,
	[extended_tran_type] [char](6) NULL,
 CONSTRAINT [PK_tbl_postilion_office_transactions_staging_new_2ab] PRIMARY KEY NONCLUSTERED 
(
	[postilion_office_transactions_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req),
 CONSTRAINT [indx_tran_nr_intermediate_staging_3ab] UNIQUE NONCLUSTERED 
(    [datetime_req],
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
) ON arbiter_datetime_partition_scheme(datetime_req)

GO

ALTER TABLE [dbo].[tbl_postilion_office_transactions_others]  ADD CHECK(  postilion_office_transactions_id>=10000000000 AND  postilion_office_transactions_id< 40000000000 )
SET ANSI_PADDING OFF
GO

USE [arbiter]
GO

/****** Object:  Index [indx_datetime_req]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_datetime_req] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[datetime_req] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_datetime_req_in_post_tran_id]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_datetime_req_in_post_tran_id] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[datetime_req] ASC
)
INCLUDE ( 	[post_tran_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 95) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_issuer_code]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_issuer_code] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[issuer_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_post_tran_id]    Script Date: 10/30/2018 4:35:45 PM ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_id] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[post_tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
 ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_tran_nr]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [indx_tran_nr] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[tran_nr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 90) 
ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [indx_tran_nr_intermediate_staging_3ab]    Script Date: 10/30/2018 4:35:46 PM ******/
ALTER TABLE [dbo].[tbl_postilion_office_transactions_others] ADD  CONSTRAINT [indx_tran_nr_intermediate_staging_3ab] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [ix_fbn_find_transactions]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_fbn_find_transactions] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[masked_pan] ASC,
	[tran_type_description] ASC,
	[datetime_req] ASC,
	[source_node_name] ASC
)
 WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF, FILLFACTOR = 90) ON arbiter_datetime_partition_scheme(datetime_req)
GO

/****** Object:  Index [ix_tran_nr_n_date]    Script Date: 10/30/2018 4:35:46 PM ******/
CREATE NONCLUSTERED INDEX [ix_tran_nr_n_date] ON [dbo].[tbl_postilion_office_transactions_others]
(
	[datetime_req] ASC
)
INCLUDE ( 	[tran_nr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON arbiter_datetime_partition_scheme(datetime_req)
GO


ALTER TABLE [dbo].[tbl_postilion_office_transactions_others]  ADD CHECK(  postilion_office_transactions_id>=100000000000 )



CREATE INDEX indx_terminal_id_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([terminal_id], [system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_idmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([terminal_id], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_post_tran_id
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([post_tran_id]) INCLUDE(datetime_req)
  ON arbiter_datetime_partition_scheme(datetime_req)
  
  USE [arbiter];
CREATE INDEX indx_datetime_req_post_tran_id
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  (datetime_req) INCLUDE([post_tran_id])
  ON arbiter_datetime_partition_scheme(datetime_req)
  CREATE INDEX indx_datetime_req_post_tran_id_2
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([datetime_req], [post_tran_id])
   ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_issuer_codemasked_pan_datetime_req
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([issuer_code], [masked_pan], [datetime_req])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_issuer_codemasked_pan_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([issuer_code], [masked_pan], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_system_trace_audit_nr_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [system_trace_audit_nr], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_tran_type_descriptionmasked_pan_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([tran_type_description], [masked_pan], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_system_trace_audit_nr_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pantran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_paycode]
  ([masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
	
	
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_retrieval_reference_nr
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ( datetime_req)INCLUDE
  ([masked_pan], [terminal_id], [retrieval_reference_nr]) 
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ( datetime_req)INCLUDE ([terminal_id])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_idretrieval_reference_nr
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ( datetime_req)INCLUDE([masked_pan], [terminal_id], [retrieval_reference_nr])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];

USE [arbiter];
CREATE INDEX indx_masked_pantran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
	WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ( datetime_req)INCLUDE ([terminal_id], [system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_idmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ( datetime_req)INCLUDE ([terminal_id], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_issuer_code
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ( datetime_req)INCLUDE ([issuer_code])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_issuer_codemasked_pan_datetime_req
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([issuer_code], [masked_pan], [datetime_req])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_issuer_codemasked_pan_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([issuer_code], [masked_pan], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_tran_type_description_extended_tran_typedatetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([tran_type_description], [extended_tran_type], [datetime_req], [source_node_name])
   ON arbiter_datetime_partition_scheme(datetime_req) 
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_system_trace_audit_nr_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [system_trace_audit_nr], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_term_sys_from_tran_type_desc
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pantran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([terminal_id], [datetime_req], [source_node_name])
    INCLUDE ([card_acceptor_name_loc], [acquirer_code])
	ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pansource_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals_transfers]
  ([masked_pan], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([datetime_req], [source_node_name])
    INCLUDE ([terminal_id], [card_acceptor_name_loc], [acquirer_code])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_sink_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([sink_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_tran_type_description_extended_tran_typedatetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([tran_type_description], [extended_tran_type], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_post_tran_cust_id
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([post_tran_cust_id])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([terminal_id])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_tran_type_descriptionmasked_pan_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([tran_type_description], [masked_pan], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_system_trace_audit_nr_from_account_idtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [from_account_id], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pantran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([terminal_id])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_terminal_id_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([terminal_id], [datetime_req], [source_node_name])
    INCLUDE ([card_acceptor_name_loc], [acquirer_code])
	ON arbiter_datetime_partition_scheme(datetime_req)
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pantran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [tran_type_description], [datetime_req], [source_node_name])
  ON arbiter_datetime_partition_scheme(datetime_req)
     WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_terminal_id_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [terminal_id], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
  ON arbiter_datetime_partition_scheme(datetime_req)
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_masked_pan_system_trace_audit_nrtran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([masked_pan], [system_trace_audit_nr], [tran_type_description], [datetime_req], [source_node_name])
  ON arbiter_datetime_partition_scheme(datetime_req)
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [arbiter];
CREATE INDEX indx_system_trace_audit_nrmasked_pan_tran_type_description_datetime_req_source_node_name
  ON [dbo]
  .[tbl_postilion_office_transactions_withdrawals]
  ([system_trace_audit_nr], [masked_pan], [tran_type_description], [datetime_req], [source_node_name])
  ON arbiter_datetime_partition_scheme(datetime_req)
    
    WITH (FILLFACTOR=90, ONLINE=ON)
	









 