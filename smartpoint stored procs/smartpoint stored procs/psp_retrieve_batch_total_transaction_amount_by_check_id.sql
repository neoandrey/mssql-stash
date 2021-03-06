USE [smartvu_staging]
GO
/****** Object:  StoredProcedure [dbo].[psp_retrieve_batch_total_transaction_amount_by_check_id]    Script Date: 01/17/2014 09:09:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/** @psPinData [VARCHAR] (512) , */

ALTER PROCEDURE [dbo].[psp_retrieve_batch_total_transaction_amount_by_check_id]
(
      @startCheckId INT,
      @endCheckId INT,
      --@batchPos INT,
     @terminalId VARCHAR(8)
      --@batchStartDate DATETIME,
      --@batchEndDate DATETIME
)
AS

SET NOCOUNT ON

BEGIN 


declare @start_check_id_str varchar(20)
declare @end_check_id_str varchar(20)

declare @post_database_ip varchar(50)
declare @post_office_database_ip varchar(50)
declare @post_database varchar(50)
declare @post_office_database varchar(50)

DECLARE @media_check_point_query varchar(6114)
DECLARE @media_check_point_query2 varchar(6114)
DECLARE @connection_query varchar(1000)
DECLARE @connectionList CURSOR

declare @batch_begin_time DATETIME
declare @batch_end_time DATETIME
declare @batch_begin_time_str VARCHAR(20)
declare @batch_end_time_str VARCHAR(20)
DECLARE @transaction_vol_query varchar(1000)


create table #mediacheckpointtemp
(
       date_time DATETIME
)

create table #mediacheckpointtemp2
(
       date_time DATETIME
)



/*
SET @connectionList = CURSOR FOR SELECT database_ip FROM tbl_office_connections where connection_id = 14  FOR read only
OPEN @connectionList
FETCH NEXT FROM @connectionList INTO @post_database_ip
CLOSE @connectionList
DEALLOCATE @connectionList
*/

--SET @batchStartDateStr =  CONVERT(VARCHAR, @batchStartDate)
--SET @batchEndDateStr =  CONVERT(VARCHAR, @batchEndDate)

SET @post_database_ip = 'TESTASPFEP'
--SET @post_database_ip = 'TQSWITCH'

SET @start_check_id_str =  CONVERT(VARCHAR, @startCheckId)
SET @end_check_id_str =  CONVERT(VARCHAR, @endCheckId)

SET @media_check_point_query = 'SELECT date_time
                  FROM [postilion].[dbo].ssf_media_checkpoint (nolock) 
            WHERE  (checkpoint_id = ''''' + @start_check_id_str + ''''')'

--SELECT @media_check_point_query

set @media_check_point_query = 'select * from OPENQUERY ('+@post_database_ip+','''+@media_check_point_query +''')'

--SELECT @media_check_point_query

INSERT #mediacheckpointtemp exec (@media_check_point_query)

select @batch_begin_time = date_time from #mediacheckpointtemp

--SELECT * FROM #mediacheckpointtemp

SET @batch_begin_time_str = CONVERT(VARCHAR, @batch_begin_time)

SET @media_check_point_query2 = 'SELECT date_time
                  FROM [postilion].[dbo].ssf_media_checkpoint (nolock) 
            WHERE  (checkpoint_id = ''''' + @start_check_id_str + ''''')'

--SELECT @media_check_point_query

set @media_check_point_query2 = 'select * from OPENQUERY ('+@post_database_ip+','''+@media_check_point_query2 +''')'

--SELECT @media_check_point_query

INSERT #mediacheckpointtemp2 exec (@media_check_point_query2)

select @batch_end_time = date_time from #mediacheckpointtemp2

--SELECT * FROM #mediacheckpointtemp

SET @batch_end_time_str = CONVERT(VARCHAR, @batch_end_time)

SET @transaction_vol_query = '(select sum(tran_amount_req) as transaction_vol
      from [postilion_office].[dbo].[post_tran] pt
      inner join [postilion_office].[dbo].[post_tran_cust] ptc
      on ptc.post_tran_cust_id  = pt.post_tran_cust_id
      where 
      pt.message_type = ''''0200''''
      and pt.tran_type = ''''01''''
      and pt.rsp_code_rsp = ''''00'''' 
      and pt.tran_reversed = ''''0''''
      and terminal_id = ''''' + @terminalId + '''''
      and pt.datetime_req >= ''''' + @batch_begin_time_str + '''''
      and pt.datetime_req <= ''''' + @batch_end_time_str + ''''')'
      --and pt.datetime_req >= ''''2011/08/01''''' + --+ @startDate +
    --' and pt.datetime_req < ''''2013/08/31''''' -- + @endDate +
    
--SELECT @transaction_vol_query

SET @transaction_vol_query = 'select * from OPENQUERY ('+@post_database_ip+','''+@transaction_vol_query +''')'

exec (@transaction_vol_query)

--SELECT * FROM @transaction_vol_query

END

drop table #mediacheckpointtemp
drop table #mediacheckpointtemp2

