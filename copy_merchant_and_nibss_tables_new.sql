USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[copy_merchant_and_nibss_tables]    Script Date: 08/05/2014 12:39:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[copy_merchant_and_nibss_tables](@target_server VARCHAR (150)) 

AS

BEGIN
--	 DECLARE @Acquiring_bank VARCHAR(50);
--    DECLARE @card_acceptor_id_code  VARCHAR(50);
--     DECLARE    @account_nr  VARCHAR(50);
--    DECLARE @Account_Name VARCHAR(50);
--    DECLARE   @Date_Modified  VARCHAR(50);
--     DECLARE   @Authorized_Person  VARCHAR(50);
	DECLARE @sub_query VARCHAR(8000);
	DECLARE @query VARCHAR(8000);
	DECLARE @num_of_rows BIGINT;
--	DECLARE @Entry_id VARCHAR(10);
--	DECLARE @PDATE	VARCHAR(10);
--	DECLARE @SerNo	VARCHAR(20);
--	DECLARE @SortCode	VARCHAR(20);
--	DECLARE @Mer_Receivable_AMT	VARCHAR(53);
--	DECLARE @Payee	VARCHAR(100);
--	DECLARE @Narration	VARCHAR(50);
--	DECLARE @Payer	VARCHAR(30);
--    DECLARE @Represented	VARCHAR(200);
--	DECLARE @Date_Inserted	VARCHAR(8);
--DECLARE @Reason	VARCHAR(200);
--DECLARE @Report_Status	VARCHAR(200);



	IF  (OBJECT_ID('tempdb.dbo.##tbl_merchant_account') IS NOT NULL)
	BEGIN
		DROP TABLE tempdb.dbo.##tbl_merchant_account
	END

	IF  (OBJECT_ID('tempdb.dbo.##NIBSS_T1_Paid_Table') IS NOT NULL)
	BEGIN
		DROP TABLE tempdb.dbo.##NIBSS_T1_Paid_Table
	END

	IF  (OBJECT_ID('tempdb.dbo.##NIBSS_T1_Returns_Table') IS NOT NULL)
	BEGIN
		DROP TABLE tempdb.dbo.##NIBSS_T1_Returns_Table
	END


IF EXISTS (SELECT * FROM master.dbo.sysservers WHERE srvname = @target_server) BEGIN

	CREATE TABLE ##tbl_merchant_account(
		[Acquiring_bank] [varchar](50) NOT NULL,
		[card_acceptor_id_code] [varchar](50) NOT NULL,
		[account_nr] [varchar](50) NOT NULL,
		[Account_Name] [varchar](50) NULL,
		[Date_Modified] [varchar](50) NULL,
		[Authorized_Person] [varchar](50) NULL,
	) 


	CREATE TABLE ##NIBSS_T1_Paid_Table(
		[Entry_id] [varchar](10) NOT NULL,
		[PDATE] [varchar](10) NOT NULL,
		[SerNo] [varchar](20) NULL,
		[Account_nr] [varchar](30) NULL,
		[SortCode] [char](9) NOT NULL,
		[Mer_Receivable_AMT] [varchar](53) NOT NULL,
		[Payee] [varchar](100) NULL,
		[Narration] [varchar](50) NULL,
		[Payer] [varchar](30) NULL,
		[Card_Acceptor_id_Code] [varchar](15) NOT NULL,
		[Report_Status] [varchar](50) NULL,
		[Date_Inserted] [datetime] NULL
	) 

	 CREATE TABLE ##NIBSS_T1_Returns_Table(
		[Entry_id] [varchar](10) NOT NULL,
		[PDATE] [varchar](10) NOT NULL,
		[SerNo] [varchar](20) NULL,
		[Account_nr] [varchar](30) NULL,
		[SortCode] [char](9) NOT NULL,
		[Mer_Receivable_AMT] [varchar](53) NOT NULL,
		[Payee] [varchar](100) NULL,
		[Narration] [varchar](50) NULL,
		[Payer] [varchar](30) NULL,
		[Card_Acceptor_id_Code] [varchar](15) NOT NULL,
		[Reason] [varchar](30) NOT NULL,
		[Represented] [varchar](200) NOT NULL,
		[Date_Inserted] [datetime] NULL,

	) 

	INSERT INTO ##NIBSS_T1_Paid_Table
			   ([Entry_id]
			   ,[PDATE]
			   ,[SerNo]
			   ,[Account_nr]
			   ,[SortCode]
			   ,[Mer_Receivable_AMT]
			   ,[Payee]
			   ,[Narration]
			   ,[Payer]
			   ,[Card_Acceptor_id_Code]
			   ,[Report_Status]
			   ,[Date_Inserted])
	SELECT [Entry_id]
			   ,[PDATE]
			   ,[SerNo]
			   ,[Account_nr]
			   ,[SortCode]
			   ,[Mer_Receivable_AMT]
			   ,[Payee]
			   ,[Narration]
			   ,[Payer]
			   ,[Card_Acceptor_id_Code]
			   ,[Report_Status]
			   ,[Date_Inserted]
	FROM [postilion_office].dbo.[NIBSS_T1_Paid_Table]
	  
	INSERT INTO ##NIBSS_T1_Returns_Table
			   ([Entry_id]
			   ,[PDATE]
			   ,[SerNo]
			   ,[Account_nr]
			   ,[SortCode]
			   ,[Mer_Receivable_AMT]
			   ,[Payee]
			   ,[Narration]
			   ,[Payer]
			   ,[Card_Acceptor_id_Code]
			   ,[Reason]
			   ,[Represented]
			   ,[Date_Inserted])
	SELECT 
			   [Entry_id]
			   ,[PDATE]
			   ,[SerNo]
			   ,[Account_nr]
			   ,[SortCode]
			   ,[Mer_Receivable_AMT]
			   ,[Payee]
			   ,[Narration]
			   ,[Payer]
			   ,[Card_Acceptor_id_Code]
			   ,[Reason]
			   ,[Represented]
			   ,[Date_Inserted]
	FROM [postilion_office].dbo.[NIBSS_T1_Returns_Table]
	  
	 INSERT INTO ##tbl_merchant_account
			   ([Acquiring_bank]
			   ,[card_acceptor_id_code]
			   ,[account_nr]
			   ,[Account_Name]
			   ,[Date_Modified]
			   ,[Authorized_Person])
	 SELECT
				[Acquiring_bank]
			   ,[card_acceptor_id_code]
			   ,[account_nr]
			   ,[Account_Name]
			   ,[Date_Modified]
			   ,[Authorized_Person]
	 FROM [postilion_office].[dbo].[tbl_merchant_account]
	 
	PRINT 'Truncating tables in target server: '+@target_server+CHAR(10)
	 
		 PRINT 'Truncating tbl_merchant_account table'+CHAR(10)

		 IF(@target_server<>'172.25.10.68' AND @target_server<>'OFFICE380D' AND @target_server<> '.' AND  @target_server NOT LIKE 'LOCAL%')

		 BEGIN

				SET @query = 'DELETE FROM ['+@target_server+'].[postilion_office].dbo.[tbl_merchant_account];';
				PRINT 'Executing query: '''+@query+''''
				EXEC(@query);
				PRINT 'Truncating NIBSS_T1_Paid_Table table'+CHAR(10)
				SET @query = 'DELETE FROM ['+@target_server+'].[postilion_office].dbo.[NIBSS_T1_Paid_Table];';
					PRINT 'Executing query: '''+@query+''''			 
				EXEC(@query);
				PRINT 'Truncating NIBSS_T1_Returns_Table table'+CHAR(10)
				SET @query = 'DELETE FROM ['+@target_server+'].[postilion_office].dbo.[NIBSS_T1_Returns_Table];';
					PRINT 'Executing query: '''+@query+''''
				EXEC(@query);
				PRINT 'Finished truncating tables in target server: '+@target_server+CHAR(10)
		 
        END
		 
		         PRINT 'Updating tables to target server: '+@target_server+CHAR(10);

			SET @query = 'INSERT INTO ['+@target_server+'].[postilion_office].dbo.[tbl_merchant_account] ([Acquiring_bank] ,[card_acceptor_id_code],[account_nr],[Account_Name],[Date_Modified] ,[Authorized_Person]) SELECT [Acquiring_bank] ,[card_acceptor_id_code],[account_nr],[Account_Name],[Date_Modified] ,[Authorized_Person] FROM ##tbl_merchant_account';
				PRINT 'Executing query: '''+@query+''''
			EXEC (@query)

		 PRINT 'Done updating  tbl_merchant_account table on '+@target_server+CHAR(10);

		 PRINT 'Updating NIBSS_T1_Paid_Table table on '+@target_server+CHAR(10);

			SET @query= 'INSERT INTO ['+@target_server+'].[postilion_office].dbo.[NIBSS_T1_Paid_Table]([Entry_id] ,[PDATE] ,[SerNo] ,[Account_nr] ,[SortCode] ,[Mer_Receivable_AMT] ,[Payee]  ,[Narration]  ,[Payer] ,[Card_Acceptor_id_Code] ,[Report_Status],[Date_Inserted]) SELECT  [Entry_id]  ,[PDATE] ,[SerNo] ,[Account_nr] ,[SortCode] ,[Mer_Receivable_AMT] ,[Payee]  ,[Narration]  ,[Payer] ,[Card_Acceptor_id_Code] ,[Report_Status] ,[Date_Inserted] FROM ##NIBSS_T1_Paid_Table';
			PRINT 'Executing query: '''+@query+''''
			EXEC(@query);

	     PRINT 'Done updating  [NIBSS_T1_Paid_Table] table on '+@target_server+CHAR(10);

		 PRINT 'Updating NIBSS_T1_Returns_Table table on '+@target_server+CHAR(10);
				
						SET @query= 'INSERT INTO ['+@target_server+'].[postilion_office].dbo.[NIBSS_T1_Returns_Table]([Entry_id] ,[PDATE] ,[SerNo] ,[Account_nr] ,[SortCode] ,[Mer_Receivable_AMT] ,[Payee]  ,[Narration]  ,[Payer] ,[Card_Acceptor_id_Code] ,[Reason] ,[Represented] ,[Date_Inserted]) SELECT  [Entry_id]  ,[PDATE] ,[SerNo] ,[Account_nr] ,[SortCode] ,[Mer_Receivable_AMT] ,[Payee]  ,[Narration]  ,[Payer] ,[Card_Acceptor_id_Code] ,[Reason] ,[Represented] ,[Date_Inserted] FROM ##NIBSS_T1_Returns_Table;';
							PRINT 'Executing query: '''+@query+''''
						EXEC(@query);

                PRINT 'Done updating  [NIBSS_T1_Returns_Table] table on '+@target_server+CHAR(10);
	        END
               
	ELSE 
		BEGIN
				SELECT @target_server+ ' has not been added as a linked server';
				PRINT @target_server+ ' has not been added as a linked server (See list below)'+CHAR(10);
				SELECT srvname FROM master.dbo.sysservers;  
				SELECT 'Please run the two commands to add a server (IP_ADDRESS):';
                SELECT 'Exec sp_addlinkedserver ''IP_ADDRESS'';'+CHAR(10)
                SELECT 'Exec sp_addlinkedsrvlogin ''IP_ADDRESS'' , ''FALSE'', NULL, ''USER_NAME'', ''USER_PASSWORD'';'
				PRINT  'Please run the commands to a server (IP_ADDRESS): exec sp_addlinkedserver ''IP_ADDRESS'';'+CHAR(10)+'exec sp_addlinkedsrvlogin ''IP_ADDRESS'' , ''FALSE'', NULL, ''USER_NAME'', ''USER_PASSWORD'';'+CHAR(10)
		END  
  
  END