CREATE DATABASE [postilion_office] ON  PRIMARY 

( NAME = N'postilion_office', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office.mdf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [APR] 
( NAME = N'postilion_office_apr', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_apr.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [AUG] 
( NAME = N'postilion_office_aug', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_aug.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [DEC] 
( NAME = N'postilion_office_dec', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_dec.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [FEB] 
( NAME = N'postilion_office_feb', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_feb.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JAN] 
( NAME = N'postilion_office_jan', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_jan.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 1024KB ), 
 FILEGROUP [JUL] 
( NAME = N'postilion_office_jul', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_jul.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUNE] 
( NAME = N'postilion_office_june', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_june.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAR] 
( NAME = N'postilion_office_mar', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_mar.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAY] 
( NAME = N'postilion_office_may', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_may.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [NOV] 
( NAME = N'postilion_office_nov', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_nov.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [SEP] 
( NAME = N'postilion_office_oct', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_oct.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB ), 
( NAME = N'postilion_office_sep', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_sep.ndf' , SIZE = 2048KB , MAXSIZE = 40960000KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'postilion_office_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\postilion_office_log.ldf' , SIZE = 1024KB , FILEGROWTH = 393216KB )
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [OCT]
GO
ALTER DATABASE [postilion_office] SET COMPATIBILITY_LEVEL = 100
GO
ALTER DATABASE [postilion_office] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [postilion_office] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [postilion_office] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [postilion_office] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [postilion_office] SET ARITHABORT OFF 
GO
ALTER DATABASE [postilion_office] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [postilion_office] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [postilion_office] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [postilion_office] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [postilion_office] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [postilion_office] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [postilion_office] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [postilion_office] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [postilion_office] SET  DISABLE_BROKER 
GO
ALTER DATABASE [postilion_office] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [postilion_office] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [postilion_office] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [postilion_office] SET  READ_WRITE 
GO
ALTER DATABASE [postilion_office] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [postilion_office] SET  MULTI_USER 
GO
ALTER DATABASE [postilion_office] SET PAGE_VERIFY CHECKSUM  
GO
USE [postilion_office]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [postilion_office] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
