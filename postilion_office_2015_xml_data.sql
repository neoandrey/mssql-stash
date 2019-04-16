CREATE DATABASE [postilion_office_2015]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'postilion_office_2015', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015.mdf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [APR] 
( NAME = N'postilion_office_2015_apr', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_apr.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [AUG] 
( NAME = N'postilion_office_2015_aug', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_aug.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [DEC] 
( NAME = N'postilion_office_2015_dec', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_dec.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [FEB] 
( NAME = N'postilion_office_2015_feb', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_feb.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JAN] 
( NAME = N'postilion_office_2015_jan', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_jan.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUL] 
( NAME = N'postilion_office_2015_jul', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_jul.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUN] 
( NAME = N'postilion_office_2015_jun', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_jun.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAR] 
( NAME = N'postilion_office_2015_mar', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_mar.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAY] 
( NAME = N'postilion_office_2015_may', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_may.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [NOV] 
( NAME = N'postilion_office_2015_nov', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_nov.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [OCT] 
( NAME = N'postilion_office_2015_oct', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_oct.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [SEP] 
( NAME = N'postilion_office_2015_sep', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_sep.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'postilion_office_2015_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2015_log.ldf' , SIZE = 1024KB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [postilion_office_2015] SET COMPATIBILITY_LEVEL = 110
GO
ALTER DATABASE [postilion_office_2015] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [postilion_office_2015] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [postilion_office_2015] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [postilion_office_2015] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [postilion_office_2015] SET ARITHABORT OFF 
GO
ALTER DATABASE [postilion_office_2015] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [postilion_office_2015] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2015] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [postilion_office_2015] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2015] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [postilion_office_2015] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [postilion_office_2015] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [postilion_office_2015] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [postilion_office_2015] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [postilion_office_2015] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [postilion_office_2015] SET  DISABLE_BROKER 
GO
ALTER DATABASE [postilion_office_2015] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [postilion_office_2015] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [postilion_office_2015] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [postilion_office_2015] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [postilion_office_2015] SET  READ_WRITE 
GO
ALTER DATABASE [postilion_office_2015] SET RECOVERY FULL 
GO
ALTER DATABASE [postilion_office_2015] SET  MULTI_USER 
GO
ALTER DATABASE [postilion_office_2015] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [postilion_office_2015] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [postilion_office_2015]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [postilion_office_2015] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
