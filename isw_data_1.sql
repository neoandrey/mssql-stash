USE [master]
GO


/****** Object:  Database [isw_data]    Script Date: 11/21/2014 8:56:14 AM ******/
CREATE DATABASE [isw_data]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'isw_data', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data.mdf' , SIZE = 8064KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [APR] 
( NAME = N'isw_data_apr', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_apr.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [AUG] 
( NAME = N'isw_data_aug', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_aug.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [DEC] 
( NAME = N'isw_data_dec', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_dec.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [FEB] 
( NAME = N'isw_data_feb', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_feb.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JAN] 
( NAME = N'isw_data_jan', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_jan.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 1024KB ), 
 FILEGROUP [JUL] 
( NAME = N'isw_data_jul', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_jul.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUN] 
( NAME = N'isw_data_june', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_june.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAR] 
( NAME = N'isw_data_mar', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_mar.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAY] 
( NAME = N'isw_data_may', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_may.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [NOV] 
( NAME = N'isw_data_nov', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_nov.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [OCT] 
( NAME = N'isw_data_oct', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_oct.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [SEP] 
( NAME = N'isw_data_sep', FILENAME = N'F:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_sep.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'isw_data_log', FILENAME = N'E:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\isw_data_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 393216KB )
GO

ALTER DATABASE [isw_data] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [isw_data].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [isw_data] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [isw_data] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [isw_data] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [isw_data] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [isw_data] SET ARITHABORT OFF 
GO

ALTER DATABASE [isw_data] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [isw_data] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [isw_data] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [isw_data] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [isw_data] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [isw_data] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [isw_data] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [isw_data] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [isw_data] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [isw_data] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [isw_data] SET  DISABLE_BROKER 
GO

ALTER DATABASE [isw_data] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [isw_data] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [isw_data] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [isw_data] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [isw_data] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [isw_data] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [isw_data] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [isw_data] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [isw_data] SET  MULTI_USER 
GO

ALTER DATABASE [isw_data] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [isw_data] SET DB_CHAINING OFF 
GO

ALTER DATABASE [isw_data] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [isw_data] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [isw_data] SET  READ_WRITE 
GO

use [isw_data]

CREATE PARTITION FUNCTION [partition_by_month] (datetime)
AS RANGE RIGHT FOR VALUES ('20140101','20140201', '20140301', '20140401',
               '20140501', '20140601', '20140701', '20140801', 
               '20140901', '20141001', '20141101', '20141201');




CREATE PARTITION SCHEME MontlyPartitionScheme AS PARTITION
	partition_by_month TO
	(
	[JAN], 
	[FEB],
	[MAR],
	[APR],
	[MAY],
    [JUN],
	[JUL],
	[AUG],
	[SEP],
	[OCT],
	[NOV],
	[DEC],
	[PRIMARY]
	)
	use [isw_data]
/****** Object:  Table [dbo].[isw_data_aspcmsoffice]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_aspcmsoffice](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
) ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_additional]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_additional](
	[post_tran_cust_id] [bigint] NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_atm_card]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_atm_card](
	[YYYYMM] [varchar](6) NULL,
	[pan_encrypted] [varchar](18) NULL,
	[vol] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_acquirer_ids]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_acquirer_ids](
	[acquirer_id] [varchar](50) NULL,
	[acquirer_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[gtb_selfridges]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[gtb_selfridges](
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GTB_Pending]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GTB_Pending](
	[dispute_log_code] [varchar](12) NULL,
	[pan] [varchar](19) NULL,
	[stan] [varchar](6) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_type] [varchar](40) NULL,
	[tran_datetime] [datetime] NULL,
	[tran_type] [varchar](20) NULL,
	[tran_amt] [float] NULL,
	[created_by] [varchar](32) NULL,
	[created_on] [datetime] NULL,
	[status] [varchar](20) NULL,
	[remote_tran_id] [int] NULL,
	[is_old_claim] [varchar](3) NULL,
	[merchant_type] [varchar](4) NULL,
	[from_account_no] [varchar](40) NULL
)  ON MontlyPartitionScheme (tran_datetime) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GTB_Accepted_Declined]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GTB_Accepted_Declined](
	[dispute_log_code] [varchar](12) NULL,
	[pan] [varchar](19) NULL,
	[stan] [varchar](6) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_type] [varchar](40) NULL,
	[tran_datetime] [datetime] NULL,
	[tran_type] [varchar](20) NULL,
	[tran_amt] [float] NULL,
	[created_by] [varchar](32) NULL,
	[created_on] [datetime] NULL,
	[status] [varchar](20) NULL,
	[remote_tran_id] [int] NULL,
	[is_old_claim] [varchar](3) NULL,
	[merchant_type] [varchar](4) NULL,
	[from_account_no] [varchar](40) NULL
) ON MontlyPartitionScheme (tran_datetime) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[all_channels_data]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[all_channels_data](
	[Month] [varchar](6) NULL,
	[Day] [varchar](8) NULL,
	[Source_Node] [varchar](30) NULL,
	[Acquirer_Bank] [varchar](50) NULL,
	[Terminal_Acquirer] [varchar](50) NULL,
	[Issuer] [varchar](50) NULL,
	[Channel] [varchar](15) NULL,
	[Transaction_Type] [varchar](18) NULL,
	[totals_group] [varchar](12) NULL,
	[Bin] [varchar](6) NULL,
	[total_users] [int] NULL,
	[tran_count] [int] NULL,
	[volume] [numeric](38, 6) NULL,
	[Card_Brand] [varchar](20) NULL,
	[data_source] [varchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[adjustment_countries]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[adjustment_countries](
	[name] [varchar](50) NOT NULL,
	[code_numeric] [int] NOT NULL,
	[code_alpha_2] [varchar](2) NOT NULL,
	[code_alpha_3] [varchar](3) NOT NULL,
 CONSTRAINT [PK_adjustment_countries] PRIMARY KEY CLUSTERED 
(
	[code_alpha_2] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[add_structure]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[add_structure](
	[post_tran_cust_id] [bigint] NULL,
	[structured_data_req] [text] NULL
) ON [PRIMARY] 
GO
/****** Object:  Table [dbo].[channels_table]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[channels_table](
	[YYYYMMDD] [varchar](50) NULL,
	[Acquirer] [varchar](50) NULL,
	[totals_group] [varchar](50) NULL,
	[Bin] [varchar](50) NULL,
	[tran_type] [varchar](50) NULL,
	[t] [varchar](2) NULL,
	[acquiring_inst_id_code] [varchar](50) NULL,
	[total_users] [bigint] NULL,
	[tran_count] [real] NULL,
	[volume] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[bins_temp]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bins_temp](
	[bin] [varchar](50) NULL,
	[Region] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[atm_trns_card]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[atm_trns_card](
	[pan_encrypted] [varchar](18) NULL,
	[volume] [int] NULL,
	[YYYYMM] [varchar](6) NULL,
	[source] [varchar](6) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[atm_trn_card]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[atm_trn_card](
	[pan_encrypted] [varchar](18) NULL,
	[volume] [int] NULL,
	[YYYYMM] [varchar](6) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[arbiter_sb]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[arbiter_sb](
	[retrieval_ref_nr] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice](
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[tran_reversed] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_encrypted] [varchar](18) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switch_add]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switch_add](
	[post_tran_cust_id] [int] NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice2]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice2](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice1](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice_supp_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice_supp_fail](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice_supp]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice_supp](
	[tran_nr] [int] NOT NULL,
	[post_tran_id] [int] NOT NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NOT NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[post_tran_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  ON MontlyPartitionScheme (datetime_req) 
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice_old]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice_old](
	[tran_nr] [int] NOT NULL,
	[post_tran_id] [int] NOT NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice_fail](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_megaoffice]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_megaoffice](
	[tran_nr] [int] NOT NULL,
	[post_tran_id] [int] NOT NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_local_processing_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_local_processing_fail](
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[sink_node_name] [varchar](30) NULL,
	[source_node_name] [varchar](30) NULL,
	[tran_type] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[message_type] [varchar](4) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_tran_local] [datetime] NULL,
	[settle_currency_code] [varchar](3) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_local_processing]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_local_processing](
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[sink_node_name] [varchar](30) NULL,
	[source_node_name] [varchar](30) NULL,
	[tran_type] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[message_type] [varchar](4) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_tran_local] [datetime] NULL,
	[settle_currency_code] [varchar](3) NULL
) ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[web_pay_data_201314]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[web_pay_data_201314](
	[pan] [varchar](19) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[message_type] [varchar](4) NULL,
	[datetime_req] [datetime] UNIQUE  NOT NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[tran_amount] [numeric](22, 6) NULL,
	[tran_currency] [varchar](3) NULL,
	[tran_type_description] [varchar](60) NULL,
	[Response_Code_description] [varchar](70) NULL,
	[settle_amount] [numeric](22, 6) NULL,
	[settle_amount_Impact] [numeric](22, 6) NULL,
	[settle_currency] [varchar](3) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[source_node_name] [varchar](30) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[merchant_type] [varchar](4) NULL,
	[merchant_disc] [numeric](7, 6) NULL,
	[fee_cap] [numeric](18, 2) NULL,
	[Card_Brand] [varchar](25) NULL,
	[msc] [numeric](18, 2) NULL,
	[isw_revenue] [numeric](18, 2) NULL,
	[platform_provider] [numeric](18, 2) NULL,
	[switch_fee] [numeric](18, 2) NULL,
	[Card_Brand_new] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
	,[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  ON MontlyPartitionScheme (datetime_req) 
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[top_gtb_atm_cards]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[top_gtb_atm_cards](
	[from_account_id] [varchar](28) NULL,
	[pan] [varchar](19) NULL,
	[volume] [int] NULL,
	[value] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tm_currencies]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tm_currencies](
	[currency_code] [varchar](3) NULL,
	[alpha_code] [varchar](3) NULL,
	[name] [varchar](20) NULL,
	[nr_decimals] [int] NULL,
	[rate] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tm_cardacceptor_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tm_cardacceptor_fail](
	[card_acceptor] [varchar](15) NULL,
	[name_location] [varchar](40) NULL,
	[currency_code] [varchar](3) NULL,
	[default_language] [int] NULL,
	[card_set] [varchar](20) NULL,
	[limits_class] [varchar](20) NULL,
	[routing_group] [varchar](20) NULL,
	[support_team] [int] NULL,
	[condition] [int] NULL,
	[status] [varchar](100) NULL,
	[merchant_type] [varchar](4) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tm_card_acceptor2]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tm_card_acceptor2](
	[card_acceptor] [varchar](15) NULL,
	[name_location] [varchar](40) NULL,
	[currency_code] [varchar](3) NULL,
	[default_language] [int] NULL,
	[card_set] [varchar](20) NULL,
	[limits_class] [varchar](20) NULL,
	[routing_group] [varchar](20) NULL,
	[support_team] [int] NULL,
	[condition] [int] NULL,
	[status] [varchar](100) NULL,
	[merchant_type] [varchar](4) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tm_card_acceptor1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tm_card_acceptor1](
	[card_acceptor] [varchar](15) NULL,
	[name_location] [varchar](40) NULL,
	[currency_code] [varchar](3) NULL,
	[default_language] [int] NULL,
	[card_set] [varchar](20) NULL,
	[limits_class] [varchar](20) NULL,
	[routing_group] [varchar](20) NULL,
	[support_team] [int] NULL,
	[condition] [int] NULL,
	[status] [varchar](100) NULL,
	[merchant_type] [varchar](4) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tm_card_acceptor]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tm_card_acceptor](
	[card_acceptor] [varchar](15) NOT NULL,
	[name_location] [varchar](40) NULL,
	[currency_code] [varchar](3) NULL,
	[default_language] [int] NULL,
	[card_set] [varchar](20) NULL,
	[limits_class] [varchar](20) NULL,
	[routing_group] [varchar](20) NULL,
	[support_team] [int] NULL,
	[condition] [int] NULL,
	[status] [varchar](100) NULL,
	[merchant_type] [varchar](4) NULL,
PRIMARY KEY CLUSTERED 
(
	[card_acceptor] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tipping_point]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tipping_point](
	[sequence_number] [bigint] IDENTITY(1,1) NOT NULL,
	[pan] [varchar](50) NULL,
	[terminal_id] [varchar](50) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[tran_amount_req] [numeric](18, 2) NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_terminal_owner]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_terminal_owner](
	[terminal_id] [varchar](15) NOT NULL,
	[Terminal_code] [varchar](4) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_prepaid_account_link]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_prepaid_account_link](
	[bank] [varchar](10) NULL,
	[customer_id] [varchar](50) NULL,
	[shadow_account] [varchar](25) NULL,
	[billing_account] [varchar](25) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_merchant_category_web]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_merchant_category_web](
	[Category_Code] [varchar](4) NOT NULL,
	[Category_name] [varchar](50) NULL,
	[Fee_type] [varchar](1) NULL,
	[Merchant_Disc] [numeric](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NULL,
	[Bearer] [varchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[Category_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_merchant_category_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_merchant_category_fail](
	[Category_Code] [varchar](4) NULL,
	[Category_name] [varchar](50) NULL,
	[Fee_type] [varchar](1) NULL,
	[Merchant_Disc] [numeric](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NULL,
	[Bearer] [varchar](1) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_merchant_category]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_merchant_category](
	[Category_Code] [varchar](4) NULL,
	[Category_name] [varchar](50) NULL,
	[Fee_type] [varchar](1) NULL,
	[Merchant_Disc] [numeric](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NULL,
	[Bearer] [varchar](1) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_merchant_account]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_merchant_account](
	[Acquiring_bank] [varchar](50) NOT NULL,
	[card_acceptor_id_code] [varchar](50) NOT NULL,
	[account_nr] [varchar](50) NOT NULL,
	[Account_Name] [varchar](50) NULL,
	[Date_Modified] DATETIME UNIQUE NOT NULL,
	[Authorized_Person] [varchar](50) NULL
)  ON MontlyPartitionScheme (Date_Modified) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_biller_details]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_biller_details](
	[Payee_ID] [varchar](50) NULL,
	[BillerShortName] [varchar](50) NULL,
	[BillerFullName] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[swtrpt_interbank_issuing_performance]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[swtrpt_interbank_issuing_performance](
	[Bank] [varchar](25) NULL,
	[Volum_June] [numeric](18, 2) NULL,
	[Value_June] [numeric](18, 2) NULL,
	[Volume_July] [numeric](18, 2) NULL,
	[Value_July] [numeric](18, 2) NULL,
	[Volume_August] [numeric](18, 2) NULL,
	[Value_August] [numeric](18, 2) NULL,
	[Volume_September] [numeric](18, 2) NULL,
	[Value_September] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[sink_nodes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sink_nodes](
	[sink_node] [varchar](50) NULL,
	[sink_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[selfridges12]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[selfridges12](
	[pan] [varchar](19) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[message_type] [varchar](4) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[tran_amount] [numeric](22, 6) NULL,
	[tran_currency] [varchar](3) NULL,
	[tran_type_description] [varchar](60) NULL,
	[Response_Code_description] [varchar](30) NULL,
	[settle_amount] [numeric](22, 6) NULL,
	[settle_amount_Impact] [numeric](22, 6) NULL,
	[settle_currency] [varchar](3) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[source_node_name] [varchar](30) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[totals_group] [varchar](12) NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[selfridge1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[selfridge1](
	[Column 0] [varchar](50) NULL,
	[Column 1] [varchar](50) NULL,
	[Column 2] [varchar](50) NULL,
	[Column 3] [varchar](50) NULL,
	[Column 4] [varchar](50) NULL,
	[Column 5] [varchar](50) NULL,
	[Column 6] [varchar](50) NULL,
	[Column 7] [varchar](50) NULL,
	[Column 8] [varchar](50) NULL,
	[Column 9] [varchar](50) NULL,
	[Column 10] [varchar](50) NULL,
	[Column 11] [varchar](50) NULL,
	[Column 12] [varchar](50) NULL,
	[Column 13] [varchar](50) NULL,
	[Column 14] [varchar](50) NULL,
	[Column 15] [varchar](50) NULL,
	[Column 16] [varchar](50) NULL,
	[Column 17] [varchar](50) NULL,
	[Column 18] [varchar](50) NULL,
	[Column 19] [varchar](50) NULL,
	[Column 20] [varchar](50) NULL,
	[Column 21] [varchar](50) NULL,
	[Column 22] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rpt_account_types]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rpt_account_types](
	[account_type] [char](4) NOT NULL,
	[account_type_string] [varchar](128) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rm_merchants2]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rm_merchants2](
	[MERCHANT_NAME] [varbinary](100) NULL,
	[TERMID] [varchar](10) NOT NULL,
 CONSTRAINT [PK_rm_merchants2] PRIMARY KEY CLUSTERED 
(
	[TERMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rm_merchants1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rm_merchants1](
	[MERCHANT_NAME] [varchar](100) NULL,
	[TERMID] [varchar](10) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rm_merchants_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rm_merchants_fail](
	[MERCHANT_NAME] [varchar](50) NULL,
	[TERMID] [varchar](50) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rm_merchants]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rm_merchants](
	[MERCHANT_NAME] [varchar](100) NULL,
	[TERMID] [varchar](10) NOT NULL,
 CONSTRAINT [PK_rm_merchants3] PRIMARY KEY CLUSTERED 
(
	[TERMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reward_money_table]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reward_money_table](
	[card_acceptor_name_loc] [varchar](50) NULL,
	[card_acceptor_id_code] [varchar](50) NULL,
	[bin] [varchar](50) NULL,
	[volume] [varchar](50) NULL,
	[value] [numeric](18, 0) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reward_money_data]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reward_money_data](
	[card_acceptor_name_loc] [varchar](40) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[Bin] [varchar](6) NULL,
	[Volume] [int] NULL,
	[Value] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[post_tran_types]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[post_tran_types](
	[category] [varchar](30) NOT NULL,
	[code] [varchar](4) NOT NULL,
	[description] [varchar](60) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[post_currencies]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[post_currencies](
	[currency_code] [char](3) NOT NULL,
	[alpha_code] [char](3) NULL,
	[name] [varchar](20) NOT NULL,
	[nr_decimals] [int] NOT NULL,
	[rate] [float] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ng_states]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ng_states](
	[Code] [varchar](50) NULL,
	[State] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ng_bins_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ng_bins_fail](
	[Bin] [varchar](6) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ng_bins]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ng_bins](
	[Bin] [varchar](6) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Bin] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mcipm_ip0072t1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mcipm_ip0072t1](
	[member_id] [char](11) NOT NULL,
	[supermarket_ind] [char](1) NULL,
	[warehouse_ind] [char](1) NULL,
	[interchange_region] [char](1) NULL,
	[iei_qualifier] [char](2) NULL,
	[internal_member_id_ind] [char](1) NULL,
	[acquirer_switch] [char](1) NULL,
	[atm_ind] [char](1) NULL,
	[rcl_region] [char](1) NULL,
	[endpoint] [char](7) NULL,
	[world_member_id_chargeback_switch] [char](1) NULL,
	[mcc_group_cd_1] [char](1) NULL,
	[mcc_group_cd_2] [char](1) NULL,
	[mcc_group_cd_3] [char](1) NULL,
	[mcc_group_cd_4] [char](1) NULL,
	[mcc_group_cd_5] [char](1) NULL,
	[service_industry] [char](1) NULL,
	[member_name] [char](30) NULL,
	[country_code] [char](3) NULL,
	[country_code_iso] [char](3) NULL,
	[filler_fields] [char](21) NULL,
	[outbound_format_ind] [char](1) NULL,
	[mc_electronic_ind] [char](1) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mcipm_ip0040t1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mcipm_ip0040t1](
	[issuer_acct_range_low] [char](19) NOT NULL,
	[gcms_product_id] [char](3) NOT NULL,
	[issuer_acct_range_high] [char](19) NULL,
	[card_program_id] [char](3) NULL,
	[issuer_card_program_id_priority] [char](2) NULL,
	[member_id] [char](11) NULL,
	[product_type] [char](1) NULL,
	[endpoint] [char](7) NULL,
	[country_alpha] [char](3) NULL,
	[country_numeric] [char](3) NULL,
	[region] [char](1) NULL,
	[product_class] [char](3) NULL,
	[txn_routing_ind] [char](1) NULL,
	[first_presentment_reassign_switch] [char](1) NULL,
	[product_reassign_switch] [char](1) NULL,
	[pcwb_opt_in_switch] [char](1) NULL,
	[licensed_product_id] [char](3) NULL,
	[paypass_mapping_service_ind] [char](1) NULL,
	[account_level_participation_ind] [char](1) NULL,
	[account_level_activation_date] [char](6) NULL,
	[cardholder_bill_currency_default] [char](3) NULL,
	[cardholder_bill_currency_exponent_default] [char](1) NULL,
	[cardholder_bill_primary_currency] [char](28) NULL,
	[chip_to_magstripe_conversion_service_indicator] [char](1) NULL,
	[floor_exp_date] [char](6) NULL,
	[co_brand_participation_switch] [char](1) NULL,
	[spend_control_switch] [char](1) NULL,
	[merchant_cleansing_service_participation] [char](3) NULL,
	[merchant_cleansing_activation_date] [char](6) NULL,
	[paypass_enabled_indicator] [char](1) NULL,
	[rate_type_indicator] [char](1) NULL,
	[psn_route_indicator] [char](1) NULL,
	[cash_back_wo_purchase_ind] [char](1) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mcc_codes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mcc_codes](
	[Category_Code] [varchar](6) NULL,
	[Category_Name] [varchar](50) NULL,
	[Fee_Type] [varchar](5) NULL,
	[Merchant_Discount] [float] NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [bigint] NULL,
	[Bearer] [varchar](5) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_totals_groups]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_totals_groups](
	[totals_group] [varchar](50) NULL,
	[totals_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_source_nodes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_source_nodes](
	[source_node] [varchar](50) NULL,
	[source_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_sink_nodes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_sink_nodes](
	[sink_node] [varchar](50) NULL,
	[sink_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_mega_totals_groups]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_mega_totals_groups](
	[totals_group] [varchar](50) NULL,
	[totals_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_mega_source_nodes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_mega_source_nodes](
	[source_node] [varchar](50) NOT NULL,
	[source_bank] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[source_node] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_mega_mds_source_nodes]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_mega_mds_source_nodes](
	[source_node] [varchar](50) NOT NULL,
	[Source_Bank] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[source_node] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ISW_Inst]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ISW_Inst](
	[Sink_Node] [varchar](50) NULL,
	[Inst_Name] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_dataswitchoffice_dup]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_dataswitchoffice_dup](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_mirror]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_mirror](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NOT NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL,
 CONSTRAINT [pk_post_tran_id1] UNIQUE NONCLUSTERED 
(
	[post_tran_id] ASC
		,[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  ON MontlyPartitionScheme (datetime_req) 
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_fail5]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_fail5](
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[tran_reversed] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_encrypted] [varchar](18) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req) 
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_fail4]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_fail4](
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[tran_reversed] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_encrypted] [varchar](18) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL,
	[structured_data_req] [text] NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[tran_nr] [int] NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[message_reason_code] [varchar](4) NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_owner] [varchar](25) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pan_search] [int] NULL,
	[pan_reference] [varchar](42) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_fail3]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_fail3](
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[tran_reversed] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[terminal_id] [varchar](8) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_encrypted] [varchar](18) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [numeric](1, 0) NULL,
	[structured_data_req] [text] NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[auth_id_rsp] [varchar](10) NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_fail2]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_fail2](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_fail]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_fail](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NULL,
	[post_tran_cust_id] [int] NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_data_switchoffice_archive]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_data_switchoffice_archive](
	[tran_nr] [int] NULL,
	[post_tran_id] [int] NOT NULL,
	[post_tran_cust_id] [int] NOT NULL,
	[sink_node_name] [varchar](30) NULL,
	[message_type] [varchar](4) NULL,
	[tran_type] [varchar](2) NULL,
	[system_trace_audit_nr] [varchar](6) NULL,
	[rsp_code_req] [varchar](2) NULL,
	[rsp_code_rsp] [varchar](2) NULL,
	[abort_rsp_code] [varchar](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [varchar](4) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[datetime_req] [datetime] UNIQUE NULL,
	[datetime_tran_local] [datetime] NULL,
	[from_account_type] [varchar](2) NULL,
	[to_account_type] [varchar](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [varchar](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [varchar](3) NULL,
	[pos_entry_mode] [varchar](3) NULL,
	[pos_condition_code] [varchar](2) NULL,
	[tran_reversed] [varchar](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[card_verification_result] [varchar](1) NULL,
	[pt_pos_operating_environment] [varchar](1) NULL,
	[pt_pos_card_input_mode] [varchar](1) NULL,
	[pt_pos_cardholder_auth_method] [varchar](1) NULL,
	[pt_pos_pin_capture_ability] [varchar](1) NULL,
	[pt_pos_terminal_operator] [varchar](1) NULL,
	[source_node_name] [varchar](30) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [varchar](4) NULL,
	[service_restriction_code] [varchar](3) NULL,
	[terminal_id] [varchar](8) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[merchant_type] [varchar](4) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [varchar](1) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [varchar](1) NULL,
	[pos_cardholder_auth_ability] [varchar](1) NULL,
	[pos_card_capture_ability] [varchar](1) NULL,
	[pos_operating_environment] [varchar](1) NULL,
	[pos_cardholder_present] [varchar](1) NULL,
	[pos_card_present] [varchar](1) NULL,
	[pos_card_data_input_mode] [varchar](1) NULL,
	[pos_cardholder_auth_method] [varchar](1) NULL,
	[pos_cardholder_auth_entity] [varchar](1) NULL,
	[pos_card_data_output_ability] [varchar](1) NULL,
	[pos_terminal_output_ability] [varchar](1) NULL,
	[pos_pin_capture_ability] [varchar](1) NULL,
	[pos_terminal_operator] [varchar](1) NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [varchar](18) NULL,
	[pan_reference] [varchar](42) NULL,
	[payee] [varchar](25) NULL,
	[extended_tran_type] [varchar](4) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_completed] [varchar](1) NULL,
	[structured_data_req] [text] NULL
)  ON MontlyPartitionScheme (datetime_req)  
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Destination for 172 25 10 70 isw_data]    Script Date: 11/14/2014 12:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Destination for 172 25 10 70 isw_data](
	[YYYYMMDD] [numeric](18, 0) NULL,
	[Acquirer] [varchar](50) NULL,
	[totals_group] [varchar](50) NULL,
	[Bin] [varchar](50) NULL,
	[tran_type] [varchar](50) NULL,
	[t] [varchar](50) NULL,
	[acquiring_inst_id_code] [varchar](50) NULL,
	[total_users] [varchar](50) NULL,
	[tran_count] [varchar](50) NULL,
	[volume] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_source_nodes2]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_source_nodes2](
	[source_node] [varchar](50) NOT NULL,
	[source_bank] [varbinary](50) NULL,
 CONSTRAINT [PK_isw_source_nodes] PRIMARY KEY CLUSTERED 
(
	[source_node] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[isw_source_nodes1]    Script Date: 11/14/2014 12:31:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[isw_source_nodes1](
	[source_node] [varchar](50) NULL,
	[source_bank] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[isw_source_nodes_global]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[isw_source_nodes_global] AS 

SELECT * FROM isw_source_nodes UNION ALL 

SELECT *  FROM isw_mega_source_nodes
GO
/****** Object:  View [dbo].[isw_data_switchoffice_all]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[isw_data_switchoffice_all] 

AS SELECT 

post_tran_id,post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,
acquiring_inst_id_code,retrieval_reference_nr,datetime_req,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,
settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,
pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,
pos_terminal_type,pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,structured_data_req


FROM isw_data_switchoffice_archive UNION ALL 

SELECT 

post_tran_id,post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,
acquiring_inst_id_code,retrieval_reference_nr,datetime_req,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,
settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,
pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,
pos_terminal_type,pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,structured_data_req


 FROM isw_data_switchoffice
GO
/****** Object:  View [dbo].[isw_totals_group_global]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[isw_totals_group_global] AS 

SELECT * FROM isw_totals_groups UNION ALL 

SELECT *  FROM isw_mega_totals_groups
GO
/****** Object:  View [dbo].[isw_data_global]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[isw_data_global] AS SELECT 

post_tran_id,post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,
acquiring_inst_id_code,retrieval_reference_nr,datetime_req,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,
settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,
pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,
pos_terminal_type,pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,structured_data_req



FROM isw_data_switchoffice UNION ALL SELECT 

post_tran_id,post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,
acquiring_inst_id_code,retrieval_reference_nr,datetime_req,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,
settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,
pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,
pos_terminal_type,pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,structured_data_req


 FROM isw_data_switchoffice_archive WHERE datetime_req < '20140801' UNION ALL 
 
 SELECT 
 
 post_tran_id,post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,
acquiring_inst_id_code,retrieval_reference_nr,datetime_req,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,
settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,
pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,
pos_terminal_type,pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,structured_data_req
 
 FROM isw_data_megaoffice
GO
