CREATE DATABASE [postilion_office_2016_xml_data]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'postilion_office_2016_xml_data', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data.mdf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [APR] 
( NAME = N'postilion_office_2016_xml_data_apr', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_apr.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [AUG] 
( NAME = N'postilion_office_2016_xml_data_aug', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_aug.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [DEC] 
( NAME = N'postilion_office_2016_xml_data_dec', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_dec.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [FEB] 
( NAME = N'postilion_office_2016_xml_data_feb', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_feb.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JAN] 
( NAME = N'postilion_office_2016_xml_data_jan', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_jan.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUL] 
( NAME = N'postilion_office_2016_xml_data_jul', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_jul.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUN] 
( NAME = N'postilion_office_2016_xml_data_jun', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_jun.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAR] 
( NAME = N'postilion_office_2016_xml_data_mar', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_mar.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAY] 
( NAME = N'postilion_office_2016_xml_data_may', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_may.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [NOV] 
( NAME = N'postilion_office_2016_xml_data_nov', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_nov.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [OCT] 
( NAME = N'postilion_office_2016_xml_data_oct', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_oct.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [SEP] 
( NAME = N'postilion_office_2016_xml_data_sep', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_sep.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'postilion_office_2016_xml_data_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_xml_data_log.ldf' , SIZE = 1024KB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET COMPATIBILITY_LEVEL = 110
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET ARITHABORT OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET  DISABLE_BROKER 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET  READ_WRITE 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET RECOVERY FULL 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET  MULTI_USER 
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [postilion_office_2016_xml_data] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [postilion_office_2016_xml_data]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [postilion_office_2016_xml_data] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
