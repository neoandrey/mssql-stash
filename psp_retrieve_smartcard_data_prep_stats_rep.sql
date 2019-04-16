USE [job_history]
GO

/****** Object:  StoredProcedure [dbo].[psp_retrieve_smartcard_Data_preparation_Statistics_report]    Script Date: 3/5/2018 3:19:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[psp_retrieve_smartcard_Data_preparation_Statistics_report](
       @startDate datetime,
       @endDate datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	----
	------
	SET NOCOUNT ON;

declare @data as table(
 Card_Type varchar(50),
 Trans_Date varchar(8),
 Bank varchar(50),
 Record_Count int,
 Prepared_Count int,
 Issuer_Bin varchar(20),
 Card_Program_Name varchar(100)
);

insert into @data
select case
when s.name like '%verve%' then 'Verve'
when s.name like '%MasterCard%' then 'MasterCard'
when s.name like '%Visa%' then 'Visa'
when left(issuer_bin,3) = '506' then 'Verve'
when left(issuer_bin,3) = '519' then 'MasterCard'
Else 'Unknown'
end as Card_Type,
convert(varchar(8), j.created_on, 112) AS 'Trans_Date',
i.issuer_name AS 'Bank',
sum(record_count) AS 'Record_Count',
sum(prepared_count) AS 'Prepared_Count',
issuer_bin As 'Issuer_Bin',
s.name As 'Card_Program_Name'
from [DB7-RO].smartcard.dbo.tbl_jobs j (nolock)
inner join [DB7-RO].smartcard.dbo.tbl_issuer_card_programs s(nolock)
on j.card_program_id=s.card_program_id
inner join [DB7-RO].smartcard.dbo.tbl_issuer i (nolock)
on j.issuer_id = i.issuer_id
inner join [DB7-RO].smartcard.dbo.tbl_cardprofiles c (nolock)
on j.card_profile_id = c.cardprofile_id
where j.completion_time is not null 
and j.created_on >= @startDate
and j.created_on <= @endDate + 1
group by i.issuer_name,convert(varchar(8), j.created_on, 112),issuer_bin,s.name
--order by year(j.created_on) desc,dbo.monthOnly(month(j.created_on))  desc ,i.issuer_name asc
union all 
select case
when p.name like '%verve%' then 'Verve'
when p.name like '%MasterCard%' then 'MasterCard'
when p.name like '%Visa%' then 'Visa'
when left(iin,3) = '506' then 'Verve'
when left(iin,3)  = '519' then 'MasterCard'
else 'Unknown'
end as Card_Type,
convert(varchar(8), j.start_time, 112) AS 'Trans_Date',
i.issuer_name AS 'Bank',
sum(record_count) AS 'Record_Count',
sum(prepared_count) AS 'Prepared_Count',
iin As 'Issuer_Bin',
p.name As 'Card Program Name'
from [DB7-RO].smartcard.dbo.tbl_jobs j (nolock)
inner join [DB7-RO].smartcard.[app_core_private].[job_templates] t(nolock)
on j.job_template_id = t.id
inner join [DB7-RO].smartcard.dbo.tbl_issuer i (nolock)
on t.issuer_code=i.issuer_code
inner join [DB7-RO].smartcard.[app_core_private].[card_products] p(nolock)
on t.card_product_id =p.id
where j.version_no=3 and j.status='COMPLETED'  
and j.start_time >= @startDate
and j.start_time <= @endDate + 1
group by i.issuer_name,convert(varchar(8), j.start_time, 112),iin,p.name


select * from @data
order by Trans_Date, Bank, Card_Type
END

GO

