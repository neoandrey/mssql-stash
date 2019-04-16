USE [postcard]
GO
/****** Object:  StoredProcedure [dbo].[pcsp_card_usage_sum]    Script Date: 05/21/2014 10:14:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







ALTER           PROCEDURE [dbo].[pcsp_card_usage_sum]
 @pan   VARCHAR(50), 
 @start_date VARCHAR (20),
 @end_date   VARCHAR (20)

AS
BEGIN

CREATE TABLE #query_result
 ( account_number      varchar(25),
opening_balance varchar (30),
credits         varchar (30),
debits          varchar (30),
closing_balance	varchar (30)
 )



if @start_date is null
set @start_date = CONVERT(VARCHAR(19),GETDATE(),112)

if @end_date is null
set @end_date = CONVERT(VARCHAR(19),GETDATE(),112)


INSERT  
 into #query_result




SELECT  account_id as account_number, ((select sum (ledger_balance/100) from pc_account_balance_deltas (nolock) where account_id = @pan)- sum (tran_amount/100)) as opening_balance,sum (case when tran_amount > 0 then tran_amount/100 else 0 end) as credits, sum (case when tran_amount < 0 then -tran_amount/100 else 0 end) as debits,(select sum (ledger_balance/100) from pc_account_balance_deltas (nolock) where account_id = @pan) as closing_balance
from pc_statement_deltas s (nolock)
where account_id = @pan
and tran_local_datetime between @start_date and dateadd(dd,1,@end_date)
group by account_id
--and tran_type not in ('21','20','22')


IF @@ROWCOUNT = 0 
INSERT INTO #query_result (account_number) VALUES ('Please Confirm the pan')

select * from #query_result


END

















