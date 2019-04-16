
ALTER DATABASE [DBName]
SET ALLOW_SNAPSHOT_ISOLATION ON
GO
2.	Enable Change Tracking on the Database by running this query
ALTER DATABASE [DBName]
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 5 DAYS, AUTO_CLEANUP = ON)
3.	Enable Change Tracking on the Table by running this query.
ALTER TABLE dbo.table_name
ENABLE CHANGE_TRACKING



ALTER DATABASE [autopay_upgrade] SET ALLOW_SNAPSHOT_ISOLATION ON
ALTER DATABASE [autopay_upgrade] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 1 DAYS, AUTO_CLEANUP = ON)
ALTER TABLE [autopay_upgrade].dbo.tbl_tran  ENABLE CHANGE_TRACKING
ALTER TABLE [autopay_upgrade].dbo.tbl_payment  ENABLE CHANGE_TRACKING 

ALTER TABLE [autopay_upgrade].dbo.tbl_tran DISABLE CHANGE_TRACKING;
ALTER TABLE [autopay_upgrade].dbo.tbl_payments DISABLE CHANGE_TRACKING;
ALTER DATABASE [autopay_upgrade] SET CHANGE_TRACKING = OFF


GRANT VIEW CHANGE TRACKING ON OBJECT::dbo.tbl_tran to isw_bi_user 
GRANT VIEW CHANGE TRACKING ON OBJECT::dbo.tbl_payment to isw_bi_user 