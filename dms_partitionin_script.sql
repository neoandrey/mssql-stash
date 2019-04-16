DECLARE  @start_id BIGINT =0
DECLARE @number_of_files INT  = 20
DECLARE @current_end_id BIGINT;
DECLARE @span   BIGINT  = 5000000
DECLARE  @end_id  BIGINT = @span* @number_of_files
DECLARE @dateTable TABLE (DATESTR varchar(750))

SET @current_end_id = 0;

 WHILE (@current_end_id<= @end_id)BEGIN
  set @current_end_id = @current_end_id + @span ;
 INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(100),@current_end_id)+']' ) ;
 
 end
 INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILEGROUP [dms_partition_default]' ) ;
 select * from @dateTable
 
 SET @current_end_id=0;
 
 DELETE FROM @dateTable 
 
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION retailpay_partition_transactions_by_id (BIGINT)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (@current_end_id<=@end_id)BEGIN
  set @current_end_id = @current_end_id + @span ;
 IF((@current_end_id) < (@end_id+ @span) ) BEGIN
      INSERT INTO @dateTable values(  CONVERT(VARCHAR(100), @current_end_id)+',') ;
 END
 ELSE BEGIN
  INSERT INTO @dateTable values(  @current_end_id) ;
 END
 END
 insert into @dateTable values(')');
 select * from @dateTable
 
  
 SET @current_end_id=0;
 
 DELETE FROM @dateTable
 
 DECLARE @dateTable2 TABLE (DATESTR varchar(750))
 
 DECLARE @drive_1 VARCHAR(5) = 'F:'
 DECLARE @drive_2 VARCHAR(5) = 'G:'
 DECLARE @counter  INT   =1
 WHILE (@current_end_id<= @end_id)BEGIN 
 set @current_end_id = @current_end_id + @span ;
  IF ( @counter %2 =0) BEGIN
     INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_'+  CONVERT(VARCHAR(100), @current_end_id)+''', FILENAME = N'''+@drive_1+'\SQLSERVER\DATA\dms_partition_file_'+  CONVERT(VARCHAR(20),@current_end_id)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(20),@current_end_id)+']') ;
	insert into  @dateTable2 values('MKDIR "'+@drive_1+'\SQLSERVER\DATA\"')
  END
  ELSE BEGIN
  INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_'+  CONVERT(VARCHAR(100), @current_end_id)+''', FILENAME = N'''+@drive_2+'\SQLSERVER\DATA\dms_partition_file_'+ CONVERT(VARCHAR(20),@current_end_id)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(20),@current_end_id)+']') ;
  insert into  @dateTable2 values('MKDIR "'+@drive_2+'\SQLSERVER\DATA\"')
  END
  
   set @counter =@counter+1
 end
   INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_default'', FILENAME = N'''+@drive_2+'\SQLSERVER\DATA\dms_partition_file_default.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_default]') ;

 select * from @dateTable
 SELECT * FROM @dateTable2
 
 
 DELETE FROM @dateTable
  SET @current_end_id=0;
 
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME retailpay_partition_transactions_by_id_scheme AS PARTITION retailpay_partition_transactions_by_id TO ('
 WHILE (@current_end_id<= @end_id)BEGIN 
   SET @current_end_id = @current_end_id + @span ;
		INSERT INTO @dateTable values('[dms_partition_'+ CONVERT(VARCHAR(100),@current_end_id)+'],') ;
				
 END
 insert into @dateTable values('[dms_partition_default])');
 select * from @dateTable



Table                      Partition_column
tbl_order				   order_id 
tbl_order_product_data     order_id
tbl_order_product          order_id
tbl_payment_credit         order_id
tbl_unique_vend_ref	       order_id
tbl_payment_credit_hh      order_id ?????
tbl_settlement             order_id
tbl_settlement_detail      order_id
tbl_payment_cash           order_id


DECLARE @table_list VARCHAR(500)

SET  @table_list =   'tbl_order,tbl_order_product_data,tbl_order_product,tbl_payment_credit,tbl_unique_vend_ref,tbl_payment_credit_hh,tbl_settlement,tbl_settlement_detail,tbl_payment_cash'

DECLARE @rename_command_list TABLE (rename_command VARCHAR(4000))
DECLARE @current_table VARCHAR(255)

SET @current_table = 'tbl_payment_cash'

DECLARE @all_tables  TABLE (table_name VARCHAR(2000))

INSERT INTO  @all_tables  VALUES ( 'tbl_order'),('tbl_order_product_data'),('tbl_order_product'),('tbl_payment_credit'),('tbl_unique_vend_ref'),('tbl_payment_credit_hh'),('tbl_settlement'),('tbl_settlement_detail'),('tbl_payment_cash')


DECLARE table_cursor CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT table_name FROM @all_tables
OPEN table_cursor
FETCH NEXT FROM   table_cursor INTO  @current_table 

WHILE (@@FETCH_STATUS = 0) BEGIN
insert into @rename_command_list
SELECT  'EXEC  sp_rename '''+@current_table +'.'+OBJECT_NAME(object_id)+''','' '+OBJECT_NAME(object_id)+'_'+CONVERT(VARCHAR(8),getdate(),112)+'''' AS rename_command
FROM sys.objects

WHERE type_desc LIKE '%CONSTRAINT' AND OBJECT_NAME(parent_object_id)=@current_table 
UNION ALL
SELECT   'EXEC  sp_rename '''+@current_table+''','''+@current_table+'_'+CONVERT(VARCHAR(8),getdate(),112)+'''' AS rename_command
FETCH NEXT FROM   table_cursor INTO  @current_table 
END

CLOSE  table_cursor
DEALLOCATE table_cursor


SELECT * FROM @rename_command_list




USE [dms]
GO

/****** Object:  Table [dbo].[tbl_order]    Script Date: 2/15/2018 3:55:41 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

drop table [tbl_order]

CREATE TABLE [dbo].[tbl_order](
	[order_id] BIGINT IDENTITY(1,1) NOT NULL,
	[order_code] [varchar](255) NULL,
	[payment_method] [varchar](255) NULL,
	 CONSTRAINT [pk_order] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
-- ,CONSTRAINT [unique_order_code] UNIQUE NONCLUSTERED
--(
--	[order_code] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

) ON retailpay_partition_transactions_by_id_scheme(order_id)
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[tbl_order] ADD [username] [varchar](255) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [station_id] [int] NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [business_unit_id] [int] NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [date_purchased] [datetime] NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_subtotal] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_tax] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_total] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [amt_paid] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [amt_due] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_service_charge] [decimal](14, 2) NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [customer_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [tax_waived] [bit] NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_delivered] [bit] NOT NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_status] [int] NULL CONSTRAINT [DF_default_order_status]  DEFAULT (0)
ALTER TABLE [dbo].[tbl_order] ADD [payment_status] [int] NOT NULL DEFAULT (0)
ALTER TABLE [dbo].[tbl_order] ADD [invoice_number] [varchar](255) NULL
ALTER TABLE [dbo].[tbl_order] ADD [sync_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [shift_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [pump_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [hose_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [initial_totalizer] [decimal](14, 2) NULL
ALTER TABLE [dbo].[tbl_order] ADD [final_totalizer] [decimal](14, 2) NULL
ALTER TABLE [dbo].[tbl_order] ADD [client_shift_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [shift_identifier] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_order] ADD [settlement_status] [bit] NULL DEFAULT (0)
ALTER TABLE [dbo].[tbl_order] ADD [fulfilling_location_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [fulfilling_station_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [order_type] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [requesting_business_unit_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_updated_by] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_completion_time] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [currency_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [rate] [decimal](14, 2) NULL
ALTER TABLE [dbo].[tbl_order] ADD [order_total_in_sales_currency] [decimal](14, 2) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[tbl_order] ADD [trxn_ref] [varchar](64) NULL
ALTER TABLE [dbo].[tbl_order] ADD [dealer_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [dealer_station_id] [int] NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[tbl_order] ADD [remote_host_resp_code] [varchar](10) NULL
ALTER TABLE [dbo].[tbl_order] ADD [remote_host_resp_msg] [varchar](256) NULL
ALTER TABLE [dbo].[tbl_order] ADD [service_type] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [nr_tries] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order] ADD [host_response_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [due_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [consumption_tax] [decimal](14, 2) NULL DEFAULT ((0))
SET ANSI_PADDING ON
ALTER TABLE [dbo].[tbl_order] ADD [comments] [varchar](800) NULL
ALTER TABLE [dbo].[tbl_order] ADD [delivery_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [settlement_info] [varchar](224) NULL
ALTER TABLE [dbo].[tbl_order] ADD [settlement_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [location_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [region_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [merchant_id] [int] NULL
ALTER TABLE [dbo].[tbl_order] ADD [last_updated_on] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [expiry_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_order] ADD [virtual_order_code] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_order] ADD [remote_customer_reference] [varchar](255) NULL
ALTER TABLE [dbo].[tbl_order] ADD [pushed_status] [varchar](255) NULL DEFAULT ('Pending')
ALTER TABLE [dbo].[tbl_order] ADD [notification_nr_tries] [int] NULL DEFAULT ((0))


SET ANSI_PADDING OFF
GO




CREATE TRIGGER   [trg_unique_order_code]  ON [tbl_order]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_order] t WITH  (nolock) JOIN  inserted i  ON  t.order_code = i.order_code))
   SET IDENTITY_INSERT  [tbl_order] ON
   INSERT INTO [tbl_order] (
	   [order_id]
	  ,[order_code]
      ,[payment_method]
      ,[username]
      ,[station_id]
      ,[business_unit_id]
      ,[date_purchased]
      ,[order_subtotal]
      ,[order_tax]
      ,[order_total]
      ,[amt_paid]
      ,[amt_due]
      ,[order_service_charge]
      ,[customer_id]
      ,[tax_waived]
      ,[order_delivered]
      ,[order_status]
      ,[payment_status]
      ,[invoice_number]
      ,[sync_date]
      ,[shift_id]
      ,[pump_id]
      ,[hose_id]
      ,[initial_totalizer]
      ,[final_totalizer]
      ,[client_shift_id]
      ,[shift_identifier]
      ,[settlement_status]
      ,[fulfilling_location_id]
      ,[fulfilling_station_id]
      ,[order_type]
      ,[requesting_business_unit_id]
      ,[order_updated_by]
      ,[order_completion_time]
      ,[currency_id]
      ,[rate]
      ,[order_total_in_sales_currency]
      ,[trxn_ref]
      ,[dealer_id]
      ,[dealer_station_id]
      ,[remote_host_resp_code]
      ,[remote_host_resp_msg]
      ,[service_type]
      ,[nr_tries]
      ,[host_response_date]
      ,[due_date]
      ,[consumption_tax]
      ,[comments]
      ,[delivery_date]
      ,[settlement_info]
      ,[settlement_date]
      ,[location_id]
      ,[region_id]
      ,[merchant_id]
      ,[last_updated_on]
      ,[expiry_date]
      ,[virtual_order_code]
      ,[remote_customer_reference]
      ,[pushed_status]
      ,[notification_nr_tries]
	  )
      SELECT  [order_id]
	  ,[order_code]
      ,[payment_method]
      ,[username]
      ,[station_id]
      ,[business_unit_id]
      ,[date_purchased]
      ,[order_subtotal]
      ,[order_tax]
      ,[order_total]
      ,[amt_paid]
      ,[amt_due]
      ,[order_service_charge]
      ,[customer_id]
      ,[tax_waived]
      ,[order_delivered]
      ,[order_status]
      ,[payment_status]
      ,[invoice_number]
      ,[sync_date]
      ,[shift_id]
      ,[pump_id]
      ,[hose_id]
      ,[initial_totalizer]
      ,[final_totalizer]
      ,[client_shift_id]
      ,[shift_identifier]
      ,[settlement_status]
      ,[fulfilling_location_id]
      ,[fulfilling_station_id]
      ,[order_type]
      ,[requesting_business_unit_id]
      ,[order_updated_by]
      ,[order_completion_time]
      ,[currency_id]
      ,[rate]
      ,[order_total_in_sales_currency]
      ,[trxn_ref]
      ,[dealer_id]
      ,[dealer_station_id]
      ,[remote_host_resp_code]
      ,[remote_host_resp_msg]
      ,[service_type]
      ,[nr_tries]
      ,[host_response_date]
      ,[due_date]
      ,[consumption_tax]
      ,[comments]
      ,[delivery_date]
      ,[settlement_info]
      ,[settlement_date]
      ,[location_id]
      ,[region_id]
      ,[merchant_id]
      ,[last_updated_on]
      ,[expiry_date]
      ,[virtual_order_code]
      ,[remote_customer_reference]
      ,[pushed_status]
      ,[notification_nr_tries]
      FROM inserted
	  SET IDENTITY_INSERT [tbl_order] OFF 

END



/****** Object:  Index [idx_business_unit_id]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_business_unit_id] ON [dbo].[tbl_order]
(
	[business_unit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_date_purchased]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_date_purchased] ON [dbo].[tbl_order]
(
	[date_purchased] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_ordercode]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_ordercode] ON [dbo].[tbl_order]
(
	[order_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_settlement_id]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_settlement_id] ON [dbo].[tbl_order]
(
	[settlement_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_stationid]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_stationid] ON [dbo].[tbl_order]
(
	[station_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_token_data]    Script Date: 2/15/2018 3:57:59 PM ******/
CREATE NONCLUSTERED INDEX [idx_token_data] ON [dbo].[tbl_order]
(
	[trxn_ref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

USE [dms]
GO

/****** Object:  Table [dbo].[tbl_order_product_data]    Script Date: 2/19/2018 12:30:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

DROP TABLE [tbl_order_product_data] 

CREATE TABLE [dbo].[tbl_order_product_data](
	[order_product_data_id] [BIGINT] IDENTITY(1,1) NOT NULL,
	[order_id] [BIGINT] NOT NULL,
	[product_data] [text] NULL,
	[last_trxn_ref] [varchar](64) NULL,
 CONSTRAINT [ unique_order_id] UNIQUE NONCLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON retailpay_partition_transactions_by_id_scheme(order_id),
 CONSTRAINT [ unique_order_product_id] UNIQUE NONCLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON retailpay_partition_transactions_by_id_scheme(order_id)
) ON retailpay_partition_transactions_by_id_scheme(order_id) 
GO

SET ANSI_PADDING OFF
GO


CREATE TRIGGER   [trg_order_product_data_id]  ON [tbl_order_product_data]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_order_product_data] t WITH  (nolock) JOIN  inserted i  ON  t.[order_product_data_id] = i.[order_product_data_id]))
SET IDENTITY_INSERT tbl_order_product_data ON  
 INSERT INTO [tbl_order_product_data] (
       [order_product_data_id]
      ,[order_id]
      ,[product_data]
      ,[last_trxn_ref]
	  )
      SELECT [order_product_data_id]
      ,[order_id]
      ,[product_data]
      ,[last_trxn_ref]
      FROM inserted
SET IDENTITY_INSERT  tbl_order_product_data OFF
END

go


USE [dms]
GO

/****** Object:  Index [ pk_order_product_data]    Script Date: 2/19/2018 12:32:02 PM ******/
ALTER TABLE [dbo].[tbl_order_product_data] ADD  CONSTRAINT [ pk_order_product_data] PRIMARY KEY CLUSTERED 
(
	[order_id],[order_product_data_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO


USE [dms]
GO

/****** Object:  Table [dbo].[tbl_order_product]    Script Date: 2/19/2018 12:47:30 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[tbl_order_product](
	[order_product_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [bigint] NOT NULL,
	[product_code] [varchar](32) NOT NULL,
	[product_barcode] [varchar](32) NOT NULL,
	[product_description] [varchar](255) NOT NULL,
	[order_quantity] [decimal](14, 2) NOT NULL,
	[order_price] [decimal](14, 2) NOT NULL,
	[order_discount] [decimal](14, 2) NOT NULL,
	[order_tax] [decimal](14, 2) NOT NULL,
	[order_service_charge] [decimal](14, 2) NOT NULL,
	[order_delievered] [bit] NOT NULL,
	[order_product_unit] [int] NULL
) ON retailpay_partition_transactions_by_id_scheme(order_id)

SET ANSI_PADDING ON
ALTER TABLE [dbo].[tbl_order_product] ADD [customer_service_no] [varchar](64) NULL
ALTER TABLE [dbo].[tbl_order_product] ADD [batch_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_order_product] ADD [order_quantity_delivered] [decimal](14, 2) NULL DEFAULT ((0))
 CONSTRAINT [ pk_order_product] PRIMARY KEY CLUSTERED 
(
	[order_id],[order_product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON retailpay_partition_transactions_by_id_scheme(order_id)

GO

SET ANSI_PADDING OFF
GO

CREATE TRIGGER   [trg_order_product_id]  ON [tbl_order_product]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_order_product] t WITH  (nolock) JOIN  inserted i  ON  t.[order_product_id] = i.[order_product_id]))
  SET IDENTITY_INSERT  tbl_order_product  ON 
   INSERT INTO [tbl_order_product] (
      [order_product_id]
      ,[order_id]
      ,[product_code]
      ,[product_barcode]
      ,[product_description]
      ,[order_quantity]
      ,[order_price]
      ,[order_discount]
      ,[order_tax]
      ,[order_service_charge]
      ,[order_delievered]
      ,[order_product_unit]
      ,[customer_service_no]
      ,[batch_id]
      ,[order_quantity_delivered]
	  )
      SELECT [order_product_id]
      ,[order_id]
      ,[product_code]
      ,[product_barcode]
      ,[product_description]
      ,[order_quantity]
      ,[order_price]
      ,[order_discount]
      ,[order_tax]
      ,[order_service_charge]
      ,[order_delievered]
      ,[order_product_unit]
      ,[customer_service_no]
      ,[batch_id]
      ,[order_quantity_delivered]
      FROM inserted
 SET IDENTITY_INSERT  tbl_order_product  OFF
END

go





USE [dms]

GO

/****** Object:  Index [idx_order_id]    Script Date: 2/19/2018 12:48:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_order_id] ON [dbo].[tbl_order_product]
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_product_code]    Script Date: 2/19/2018 12:48:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_product_code] ON [dbo].[tbl_order_product]
(
	[product_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO



USE [dms]
GO

/****** Object:  Table [dbo].[tbl_payment_credit]    Script Date: 2/19/2018 1:54:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_payment_credit](
	[payment_credit_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [BIGINT] NOT NULL,
	[credit_id] [int] NOT NULL,
	[credit_amount] [decimal](14, 2) NULL,
	[credit_reference] [varchar](64) NULL,
	[is_credit_reversed] [bit] NULL,
	[merchant_id] [int] NULL,
	[payment_date] [datetime] NULL,
	[payment_status] [smallint] NULL,
	[debit_status] [int] NULL DEFAULT ((0)),
 CONSTRAINT [ pk_payment_credit_id] PRIMARY KEY CLUSTERED 
(
	[order_id],[payment_credit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON retailpay_partition_transactions_by_id_scheme(order_id)
) ON retailpay_partition_transactions_by_id_scheme(order_id)

GO


USE [dms]
GO

/****** Object:  Index [UX_single_debit_per_order]    Script Date: 2/19/2018 1:54:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_single_debit_per_order] ON [dbo].[tbl_payment_credit]
(
	[order_id] ASC
)
WHERE ([is_credit_reversed]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO



USE [dms]
GO

/****** Object:  Table [dbo].[tbl_unique_vend_ref]    Script Date: 2/20/2018 10:00:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_unique_vend_ref](
	[order_id] [BIGINT] NOT NULL,
	[station_id] [int] NOT NULL,
	[trxn_ref] [varchar](32) NOT NULL
)
ON retailpay_partition_transactions_by_id_scheme(order_id)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_unique_vend_ref]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[tbl_order] ([order_id])
GO

CREATE INDEX  unique_trxn_constraint ON [tbl_unique_vend_ref]  (

[station_id]  ,
[trxn_ref] 

)
ON retailpay_partition_transactions_by_id_scheme(order_id)

go

CREATE INDEX  unique_trxn_constraint_2 ON [tbl_unique_vend_ref]  (
[order_id]

)ON retailpay_partition_transactions_by_id_scheme(order_id)

go

CREATE TRIGGER   [trg_unique_trxn_constraint]  ON [tbl_unique_vend_ref]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_unique_vend_ref] t WITH  (nolock) JOIN  inserted i  ON  t.[station_id] = i.[station_id] AND  t.[trxn_ref] = i.[trxn_ref]))
   INSERT INTO [tbl_unique_vend_ref] (
			[order_id]
			,[station_id]
			,[trxn_ref]
      
	  )
      SELECT [order_id]
			,[station_id]
			,[trxn_ref]
      FROM inserted

END

go



USE [dms]
GO

/****** Object:  Table [dbo].[tbl_settlement]    Script Date: 2/20/2018 10:18:10 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_settlement](
	[settlement_id] [BIGINT] IDENTITY(1,1) NOT NULL,
	[settlement_entity_id] [int] NOT NULL,
	[settlement_date] [datetime] NOT NULL,
	[settlement_amount] [decimal](22, 9) NOT NULL,
	[order_id] [bigint] NOT NULL,
	[domain_id] [int] NOT NULL,
	[tendertype_id] [int] NOT NULL DEFAULT (0),
 CONSTRAINT [ pk_settlement] PRIMARY KEY CLUSTERED 
(
[order_id], 
	[settlement_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON retailpay_partition_transactions_by_id_scheme(order_id)
) ON retailpay_partition_transactions_by_id_scheme(order_id)

GO


CREATE INDEX ix_tbl_settlement_1  ON tbl_settlement (
[settlement_id]
)ON retailpay_partition_transactions_by_id_scheme(order_id)
go


CREATE INDEX ix_tbl_settlement_2  ON tbl_settlement (
[order_id]
)ON retailpay_partition_transactions_by_id_scheme(order_id)
go


CREATE TRIGGER   [trg_unique_settlement_id_constraint]  ON [tbl_settlement]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_settlement] t WITH  (nolock) JOIN  inserted i  ON  t.settlement_id = i.settlement_id))
   SET IDENTITY_INSERT  tbl_settlement  ON 
  INSERT INTO [tbl_settlement] (
	[settlement_id]
      ,[settlement_entity_id]
      ,[settlement_date]
      ,[settlement_amount]
      ,[order_id]
      ,[domain_id]
      ,[tendertype_id]
	  )
      SELECT [settlement_id]
      ,[settlement_entity_id]
      ,[settlement_date]
      ,[settlement_amount]
      ,[order_id]
      ,[domain_id]
      ,[tendertype_id]
      FROM inserted
SET IDENTITY_INSERT  tbl_settlement  ON
END

go


USE [dms]
GO

/****** Object:  Table [dbo].[tbl_settlement_detail]    Script Date: 2/20/2018 10:28:36 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[tbl_settlement_detail](
	[settlement_detail_id] [BIGINT] IDENTITY(1,1) NOT NULL,
	[settle_domain_id] [int] NOT NULL,
	[entity_domain_id] [int] NOT NULL,
	[amount] [decimal](22, 9) NOT NULL,
	[narration] [varchar](256) NULL,
	[settle_date] [datetime] NOT NULL,
	[order_id] [BIGINT] NOT NULL
) ON retailpay_partition_transactions_by_id_scheme(order_id)

GO
SET ANSI_PADDING OFF
GO

CREATE INDEX  [ pk_settlement_detail] ON  [tbl_settlement_detail]
(
[order_id],	[settlement_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  ON retailpay_partition_transactions_by_id_scheme(order_id)


CREATE INDEX  [ ix_settlement_detail_1] ON  [tbl_settlement_detail]
(
[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  ON retailpay_partition_transactions_by_id_scheme(order_id)


CREATE INDEX  [ ix_settlement_detail_2] ON  [tbl_settlement_detail]
(
[settlement_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  ON retailpay_partition_transactions_by_id_scheme(order_id)






CREATE INDEX ix_tbl_settlement_details_1  ON [tbl_settlement_detail] (
[settlement_detail_id]
)ON retailpay_partition_transactions_by_id_scheme(order_id)
go


CREATE INDEX ix_tbl_settlement_details_2  ON [tbl_settlement_detail] (
[order_id]
)ON retailpay_partition_transactions_by_id_scheme(order_id)
go


CREATE TRIGGER   [trg_unique_settlement_details_id_constraint]  ON [tbl_settlement_detail]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_settlement_detail] t WITH  (nolock) JOIN  inserted i  ON  t.[settlement_detail_id] = i.[settlement_detail_id]))
   SET IDENTITY_INSERT [tbl_settlement_detail] ON
   INSERT INTO [tbl_settlement_detail] (
		 [settlement_detail_id]
      ,[settle_domain_id]
      ,[entity_domain_id]
      ,[amount]
      ,[narration]
      ,[settle_date]
      ,[order_id]
	  )
      SELECT  [settlement_detail_id]
      ,[settle_domain_id]
      ,[entity_domain_id]
      ,[amount]
      ,[narration]
      ,[settle_date]
      ,[order_id]
      FROM inserted
	   SET IDENTITY_INSERT [tbl_settlement_detail] OFF
END

go

USE [dms]
GO

/****** Object:  Table [dbo].[tbl_payment_cash]    Script Date: 2/20/2018 11:05:41 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[tbl_payment_cash](
	[payment_cash_id] [BIGINT] IDENTITY(1,1) NOT NULL,
	[order_id] [BIGINT] NOT NULL,
	[payment_cash_paid] [decimal](14, 2) NOT NULL,
	[payment_cash_change] [decimal](14, 2) NOT NULL,
	[payment_cash_status] [int] NOT NULL,
	[reference_id] [varchar](64) NULL,
	[payment_date] [datetime] NULL,
	[settlement_status] [int] NULL,
	[settlement_date] [datetime] NULL
) ON retailpay_partition_transactions_by_id_scheme(order_id)
SET ANSI_PADDING ON
ALTER TABLE [dbo].[tbl_payment_cash] ADD [channel] [varchar](32) NULL


 CREATE INDEX pk_payment_cash ON [tbl_payment_cash]
(
	[payment_cash_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
 ON retailpay_partition_transactions_by_id_scheme(order_id)

GO

SET ANSI_PADDING OFF
GO


USE [dms]
GO

/****** Object:  Index [idx_order_id]    Script Date: 2/20/2018 11:06:04 AM ******/
CREATE NONCLUSTERED INDEX [idx_order_id] ON [dbo].[tbl_payment_cash]
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO

/****** Object:  Index [idx_reference_id]    Script Date: 2/20/2018 11:06:04 AM ******/
CREATE NONCLUSTERED INDEX [idx_reference_id] ON [dbo].[tbl_payment_cash]
(
	[reference_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON retailpay_partition_transactions_by_id_scheme(order_id)
GO





CREATE TRIGGER   [trg_unique_payment_cash_id_constraint]  ON [tbl_payment_cash]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS ( SELECT 1 FROM  [tbl_payment_cash] t WITH  (nolock) JOIN  inserted i  ON  t.[payment_cash_id] = i.[payment_cash_id]))
   SET IDENTITY_INSERT [tbl_payment_cash] ON
   INSERT INTO [tbl_payment_cash] (
		[payment_cash_id]
      ,[order_id]
      ,[payment_cash_paid]
      ,[payment_cash_change]
      ,[payment_cash_status]
      ,[reference_id]
      ,[payment_date]
      ,[settlement_status]
      ,[settlement_date]
      ,[channel]
	  )
      SELECT  [payment_cash_id]
      ,[order_id]
      ,[payment_cash_paid]
      ,[payment_cash_change]
      ,[payment_cash_status]
      ,[reference_id]
      ,[payment_date]
      ,[settlement_status]
      ,[settlement_date]
      ,[channel]
      FROM inserted
	   SET IDENTITY_INSERT [tbl_payment_cash] OFF
END

go



