USE [smartvu_staging]
GO
/****** Object:  StoredProcedure [dbo].[psp_retrieve_batch_loaded_amount_by_date]    Script Date: 01/17/2014 09:09:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/** @psPinData [VARCHAR] (512) , */

ALTER PROCEDURE [dbo].[psp_retrieve_batch_loaded_amount_by_date]
(
      @batchPos INT,
      @terminalId VARCHAR(8),
      @batchStartDate DATETIME,
      @batchEndDate DATETIME
)
AS

SET NOCOUNT ON

BEGIN 

declare @batchStartDateStr VARCHAR(25)
declare @batchEndDateStr VARCHAR(25)

declare @check_id int
declare @check_id_str varchar(20)
declare @term_id char(8)
declare @date_time datetime
declare @checkpoint_type char(2)
declare @desc varchar(50)
declare @cash_value float
declare @cash_value_str varchar(20)

DECLARE @batch_id INT
declare @unique_term_id char(8)
declare @batch_nr int
declare @amount_loaded float
declare @vault_out float

declare @post_database_ip varchar(50)
declare @post_office_database_ip varchar(50)
declare @post_database varchar(50)
declare @post_office_database varchar(50)

DECLARE @media_check_point_query varchar(6114)
DECLARE @cash_value_query varchar(1000)
DECLARE @connection_query varchar(1000)
DECLARE @connectionList CURSOR



create table #temp
(
         batch_id INT,
       batch_begin_check_id INT,
       batch_begin_time DATETIME,
       batch_begin_amt FLOAT,
       batch_end_check_id INT,
       batch_end_time DATETIME,
       batch_end_amt FLOAT,
       retract_amt FLOAT,
       term_id VARCHAR(8)
)

create table #mediacheckpointtemp
(
       checkpoint_id INT,
       term_id CHAR(8),
       date_time DATETIME,
       checkpoint_type INT,
       [desc] VARCHAR(20)
)

create table #cashvaluetemp
(
       cash_value FLOAT
)



/*
SET @connectionList = CURSOR FOR SELECT database_ip FROM tbl_office_connections where connection_id = 14  FOR read only
OPEN @connectionList
FETCH NEXT FROM @connectionList INTO @post_database_ip
CLOSE @connectionList
DEALLOCATE @connectionList
*/

SET @batchStartDateStr =  CONVERT(VARCHAR, @batchStartDate)
SET @batchEndDateStr =  CONVERT(VARCHAR, @batchEndDate)

SET @post_database_ip = 'TESTASPFEP'
--SET @post_database_ip = 'TQSWITCH'

      SET @media_check_point_query = 'SELECT checkpoint_id, 
            term_id, 
            date_time, 
            checkpoint_type,
            CASE checkpoint_type WHEN 20 THEN ''''BATCH_END'''' ELSE ''''BATCH_BEGIN'''' END AS ''''desc''''
            FROM [postilion].[dbo].ssf_media_checkpoint (nolock) 
            WHERE  (((checkpoint_type) = (10)) OR ((checkpoint_type) = (20)))
            AND (term_id = ''''' + @terminalId + ''''')
            AND date_time >= ''''' + @batchStartDateStr + ''''' and date_time < ''''' + @batchEndDateStr + ''''' ORDER BY checkpoint_id'
            --and date_time >= ''''2011/08/01''''' + --+ @startDate +
            --' and date_time < ''''2013/08/31''''' + -- + @endDate +

set @media_check_point_query = 'select * from OPENQUERY ('+@post_database_ip+','''+@media_check_point_query +''')'

--SELECT @media_check_point_query

INSERT #mediacheckpointtemp exec (@media_check_point_query)

--SELECT * FROM #mediacheckpointtemp

SET @batch_id = 0;

declare cr cursor for 
      select * from #mediacheckpointtemp
open cr
fetch next from cr into @check_id, @term_id, @date_time, @checkpoint_type, @desc
while @@fetch_status = 0
begin
            
            SET @check_id_str = CONVERT(VARCHAR, @check_id)
            
            SET @cash_value_query = 'select sum(item_value) as cash_value 
            from [postilion].[dbo].ssf_media_cassette_history (nolock) 
            WHERE checkpoint_id = ' + @check_id_str + ' and cassette_id in (''''1'''',''''2'''', ''''3'''',''''4'''')'
            
            --SELECT @cash_value_query
            
            SET @cash_value_query = 'select * from OPENQUERY ('+@post_database_ip+','''+@cash_value_query +''')'
            INSERT #cashvaluetemp exec (@cash_value_query)
            select @cash_value = cash_value from #cashvaluetemp
            
            IF(@desc = 'BATCH_BEGIN')
            BEGIN
                  SET @batch_id = @batch_id + 1
                  insert into #temp (batch_id, batch_begin_check_id, batch_begin_time, batch_begin_amt, term_id) 
                  values(@batch_id, @check_id, @date_time, @cash_value, @term_id)
                  
            END
            ELSE IF(@desc = 'BATCH_END')
            BEGIN
                  IF(@batch_id = 0)
                  BEGIN
                        SET @batch_id = @batch_id + 1
                        insert into #temp (batch_id, batch_end_check_id, batch_end_time, batch_end_amt, term_id) 
                        values(@batch_id, @check_id, @date_time, @cash_value, @term_id)
                  END
                  ELSE
                  BEGIN
                        UPDATE #temp SET batch_end_check_id = @check_id, 
                        batch_end_time = @date_time, batch_end_amt = @cash_value
                        WHERE batch_id = @batch_id
                  END
            END
            
            fetch next from cr 
        into @check_id, @term_id, @date_time, @checkpoint_type, @desc
end
close cr
deallocate cr


--SELECT batch_begin_amt FROM #temp 
--order by batch_begin_time ASC

SELECT TOP 1 batch_begin_amt, batch_begin_check_id
FROM #temp
WHERE batch_begin_amt in (select top(@batchPos) batch_begin_amt from #temp 
WHERE batch_begin_time IS NOT NULL order by batch_begin_time ASC)
ORDER BY batch_begin_time DESC


drop table #cashvaluetemp
drop table #mediacheckpointtemp
drop table #temp


END


