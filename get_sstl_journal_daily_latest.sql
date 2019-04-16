
USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[get_sstl_journal_daily]    Script Date: 10/06/2016 22:57:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_get_sstl_journal_daily] AS
BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @sqll nVARCHAR(MAX);
DECLARE @sql2 nVARCHAR(MAX);

DECLARE @sql2_ending nVARCHAR(48);

SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily]'')) DROP VIEW [dbo].[sstl_journal_daily];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily_1]'')) DROP VIEW [dbo].[sstl_journal_daily_1];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily_2]'')) DROP VIEW [dbo].[sstl_journal_daily_2];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily_3]'')) DROP VIEW [dbo].[sstl_journal_daily_3];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily_4]'')) DROP VIEW [dbo].[sstl_journal_daily_4];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_daily_5]'')) DROP VIEW [dbo].[sstl_journal_daily_5];'
EXEC(@sqll)
SET @sqll  ='IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[sstl_journal_temp]'')) DROP VIEW [dbo].[sstl_journal_temp];'
EXEC(@sqll)
  DECLARE @definition VARCHAR(MAX)
   
    select @definition = REPLACE(definition, ' UNION ALL ', '|') from postilion_office.sys.objects   o
join  [postilion_office].sys.sql_modules m on m.object_id = o.object_id
where
   o.type      = 'V' and  name = 'sstl_journal';
   
    DECLARE @temp_settlement_table  TABLE (table_create_string VARCHAR(MAX))
    
    INSERT INTO @temp_settlement_table SELECT * FROM  usf_split_string(@definition ,'|')
   
DECLARE @sstl_sql_1 NVARCHAR(MAX)='';
DECLARE @sstl_sql_2 NVARCHAR(MAX)='';
DECLARE @sstl_sql_3 NVARCHAR(MAX)='';
DECLARE @sstl_sql_4 NVARCHAR(MAX)='';
DECLARE @sstl_sql_5 NVARCHAR(MAX)='';
DECLARE @sstl_sql_temp NVARCHAR(MAX);

DECLARE @counter  INT  = 1

DECLARE sstl_cursor CURSOR  LOCAL FORWARD_ONLY  STATIC READ_ONLY FOR SELECT table_create_string FROM @temp_settlement_table WHERE CHARINDEX('CREATE',table_create_string)<1 AND RIGHT(LTRIM(RTRIM(table_create_string)), 7)!='journal';
OPEN sstl_cursor
FETCH NEXT FROM sstl_cursor INTO @sstl_sql_temp
WHILE (@@FETCH_STATUS=0) BEGIN

IF(@counter <=50) BEGIN
SET @sstl_sql_1 +=REPLACE(@sstl_sql_temp,'SELECT','SELECT NULL adj_id, ')+'(NOLOCK) UNION ALL  ';
END 
ELSE IF (@counter >50 AND @counter <=100  ) BEGIN
SET @sstl_sql_2 +=REPLACE(@sstl_sql_temp,'SELECT','SELECT NULL adj_id, ')+'(NOLOCK) UNION ALL  ';
END
ELSE IF (@counter >100 AND @counter <=150  ) BEGIN
SET @sstl_sql_3 +=REPLACE(@sstl_sql_temp,'SELECT','SELECT NULL adj_id, ')+'(NOLOCK) UNION ALL  ';
END
ELSE IF (@counter >150 AND @counter <=200  ) BEGIN
SET @sstl_sql_4 +=REPLACE(@sstl_sql_temp,'SELECT','SELECT NULL adj_id, ')+'(NOLOCK) UNION ALL  ';
END
ELSE IF (@counter >200 AND @counter <=250  ) BEGIN
SET @sstl_sql_5 +=REPLACE(@sstl_sql_temp,'SELECT','SELECT NULL adj_id, ')+'(NOLOCK) UNION ALL  ';
END
SET @counter  =@counter+1;
FETCH NEXT FROM sstl_cursor INTO @sstl_sql_temp
END
CLOSE sstl_cursor
DEALLOCATE sstl_cursor

set @sstl_sql_1 ='CREATE VIEW [dbo].[sstl_journal_daily_1] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_1)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_1))) -10);
EXEC   ( @sstl_sql_1)
 IF(len(@sstl_sql_2)>1) BEGIN 
 set @sstl_sql_2  = 'CREATE VIEW [dbo].[sstl_journal_daily_2] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_2)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_2))) -10)
 EXEC  (@sstl_sql_2 )
    EXEC ('CREATE VIEW sstl_journal_daily AS SELECT * FROM sstl_journal_daily_1 UNION SELECT * FROM sstl_journal_daily_2 ')

 END

ELSE IF(len(@sstl_sql_3)>1)begin
 set @sstl_sql_3 ='CREATE VIEW [dbo].[sstl_journal_daily_3] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_3)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_3))) -10)
 EXEC  ( @sstl_sql_3  )
  EXEC ('CREATE VIEW sstl_journal_daily AS SELECT * FROM sstl_journal_daily_1 UNION SELECT * FROM sstl_journal_daily_2 UNION SELECT * FROM sstl_journal_daily_3')
 
END
ELSE IF(len(@sstl_sql_4)>1)BEGIN 
SET @sstl_sql_4 =  'CREATE VIEW [dbo].[sstl_journal_daily_4] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_4)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_4))) -10)
EXEC  ( @sstl_sql_4)
 EXEC ('CREATE VIEW sstl_journal_daily AS SELECT * FROM sstl_journal_daily_1 UNION SELECT * FROM sstl_journal_daily_2 UNION SELECT * FROM sstl_journal_daily_3 UNION SELECT * FROM sstl_journal_daily_4 ')
 
END
ELSE IF(len(@sstl_sql_5)>1) BEGIN
set @sstl_sql_5 =  'CREATE VIEW [dbo].[sstl_journal_daily_5] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_1)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_5))) -10)
 EXEC  (@sstl_sql_5 )
set @sstl_sql_5 =  'CREATE VIEW [dbo].[sstl_journal_daily_5] AS  '+SUBSTRING (LTRIM(RTRIM(@sstl_sql_1)), 1,  LEN(LTRIM(RTRIM(@sstl_sql_5))) -10)
 
END

EXEC ( 'CREATE VIEW   sstl_journal_temp AS
SELECT
				adj_id,
				entry_id,
				config_set_id,
				session_id,
				post_tran_id,
				post_tran_cust_id,
				sdi_tran_id,
				acc_post_id,
				nt_fee_acc_post_id,
				coa_id,
				coa_se_id,
				se_id,
				amount,
				amount_id,
				amount_value_id,
				fee,
				fee_id,
				fee_value_id,
				nt_fee,
				nt_fee_id,
				nt_fee_value_id,
				debit_acc_nr_id,
				debit_acc_id,
				debit_cardholder_acc_id,
				debit_cardholder_acc_type,
				credit_acc_nr_id,
				credit_acc_id,
				credit_cardholder_acc_id,
				credit_cardholder_acc_type,
				business_date,
				granularity_element,
				tag,
				spay_session_id,
				spst_session_id
			FROM
				sstl_journal_adj (nolock) 
				UNION
				SELECT * FROM sstl_journal_daily')
				
          
END

GO







