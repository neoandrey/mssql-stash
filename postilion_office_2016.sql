CREATE DATABASE [postilion_office_2016]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'postilion_office_2016', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016.mdf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [APR] 
( NAME = N'postilion_office_2016_apr', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_apr.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [AUG] 
( NAME = N'postilion_office_2016_aug', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_aug.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [DEC] 
( NAME = N'postilion_office_2016_dec', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_dec.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [FEB] 
( NAME = N'postilion_office_2016_feb', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_feb.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JAN] 
( NAME = N'postilion_office_2016_jan', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_jan.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUL] 
( NAME = N'postilion_office_2016_jul', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_jul.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [JUN] 
( NAME = N'postilion_office_2016_jun', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_jun.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAR] 
( NAME = N'postilion_office_2016_mar', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_mar.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [MAY] 
( NAME = N'postilion_office_2016_may', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_may.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [NOV] 
( NAME = N'postilion_office_2016_nov', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_nov.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [OCT] 
( NAME = N'postilion_office_2016_oct', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_oct.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB ), 
 FILEGROUP [SEP] 
( NAME = N'postilion_office_2016_sep', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_sep.ndf' , SIZE = 4096KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'postilion_office_2016_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data\postilion_office_2016_log.ldf' , SIZE = 1024KB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [postilion_office_2016] SET COMPATIBILITY_LEVEL = 110
GO
ALTER DATABASE [postilion_office_2016] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [postilion_office_2016] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [postilion_office_2016] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [postilion_office_2016] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [postilion_office_2016] SET ARITHABORT OFF 
GO
ALTER DATABASE [postilion_office_2016] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [postilion_office_2016] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2016] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [postilion_office_2016] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [postilion_office_2016] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [postilion_office_2016] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [postilion_office_2016] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [postilion_office_2016] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [postilion_office_2016] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [postilion_office_2016] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [postilion_office_2016] SET  DISABLE_BROKER 
GO
ALTER DATABASE [postilion_office_2016] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [postilion_office_2016] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [postilion_office_2016] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [postilion_office_2016] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [postilion_office_2016] SET  READ_WRITE 
GO
ALTER DATABASE [postilion_office_2016] SET RECOVERY FULL 
GO
ALTER DATABASE [postilion_office_2016] SET  MULTI_USER 
GO
ALTER DATABASE [postilion_office_2016] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [postilion_office_2016] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [postilion_office_2016]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [postilion_office_2016] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
