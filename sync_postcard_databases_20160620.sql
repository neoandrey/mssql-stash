CREATE PROCEDURE sync_postcard_test AS
begin

		SET QUOTED_IDENTIFIER ON 
		DECLARE @source_server VARCHAR(255);
		DECLARE @source_user VARCHAR(255);
		DECLARE @source_password VARCHAR(255);
		DECLARE @source_db VARCHAR(255);

		DECLARE @destination_server VARCHAR(255);
		DECLARE @destination_user VARCHAR(255);
		DECLARE @destination_password VARCHAR(255);
		DECLARE @destination_db VARCHAR(255);


		SET @source_server ='172.25.15.213';
		SET @source_user = 'office_norm_account';
		SET @source_password = 'Password123'
		SET @source_db = 'postcard'

		SET @destination_server ='172.25.15.15';
		SET @destination_user = 'reportadmin'
		SET @destination_password = 'report.admin12'
		SET @destination_db = 'postcard'

		DECLARE @TableNames as table (
			id int identity(1,1),
			TABLE_NAME varchar(100))

		DECLARE @sTableDiff nvarchar(1000)
		DECLARE @tableName varchar(100)
		DECLARE @counter int
		DECLARE @maxCount int
		--declare  @sqlStr VARCHAR(MAX);
		DECLARE @logDate DATETIME
		select @logDate =REPLACE(REPLACE(CONVERT(VARCHAR(10),GETDATE(),111),' ', '_'),':','_');


		INSERT INTO @TableNames  
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_account_balances_%'
		 UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_account_%'
		  UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_card_override_lim_%'
		   UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_cards%'
		  UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_customers%'
		   UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_statements%'
		   UNION ALL 
		 SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME like 'pc_temp_cards%'
		 

		SET @counter = 1
		SELECT @maxCount = COUNT(TABLE_NAME)  FROM @TableNames;

		WHILE (@counter < @maxCount) BEGIN
				SELECT @tableName = TABLE_NAME  FROM @TableNames  WHERE id = @counter

				SET @sTableDiff= ' "C:\Progra~1\Micros~1\100\COM\tablediff.exe" -sourceserver '+@source_server+ 
					' -sourceuser '+@source_user+' -sourcepassword '+@source_password +' -sourcedatabase '+@source_db +' -sourcetable ' + @tableName +
					' -destinationserver '+@destination_server+' -destinationuser '+@destination_user+' -destinationpassword '+@destination_password+
					' -destinationdatabase '+@destination_db+' -destinationtable ' + @tableName + '  -f C:\tabdiff\postcard\'+@tableName	

				EXEC XP_CMDSHELL @sTableDiff

				Set @counter = @counter + 1
			End

  declare @sqlCommand VARChAR(MAX) ='for %f in (C:\tabdiff\postcard\*.sql) do sqlcmd /S ASPOFFICE64 /d postcard /E /i "%f" -o postcard_log_'+@logDate;
		exec  master.dbo.xp_cmdshell	@sqlCommand;


		exec  master.dbo.xp_cmdshell	'del -f C:\tabdiff\postcard\*.sql'

end