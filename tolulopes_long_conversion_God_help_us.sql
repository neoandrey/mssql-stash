
 DECLARE  @totalsgroups varchar(MAX)
 
 DECLARE  @CBNCodes varchar(MAX)
 
 
 DECLARE  @ALLBINs varchar(MAX)
 
 

 
 
SELECT  CASE   WHEN(
 not( LEFT(pan,6) in   (SELECT part FROM dbo.usf_split_string(@ALLBINs,',')))
and not (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')))
and not ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) 
and len(to_cashcard_account_id)=25)   
and not((LEFT(totals_group,16) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')))
or (LEFT(totals_group,3) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,','))))
)
then 'Not Our Initiating Cards, Not Our Prepaid Cards'

 

 

 

WHEN (LEFT(totals_group,16) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,','))
      or LEFT(totals_group,3) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')))

and (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))

     or ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25) )

and LEFT(from_account_id,7) = '6280512'

then 'Our Prepaid Cards Loading Our Prepaid Cards'

 

WHEN ((LEFT(pan,6) = '628051' and LEFT(totals_group,16) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,','))) or (LEFT(pan,6) = '628051' and LEFT(totals_group,3) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,','))))

and (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')) or ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25) )

and LEFT(from_account_id,7) <> '628051'

then 'Others'

 

WHEN (LEFT(totals_group,16) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')) or LEFT(totals_group,3) in (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')) )

and not(SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')))

and not((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25)

and LEFT(from_account_id,7) = '6280512'

then 'Our Prepaid Cards Loading Other Prepaid Cards'

 

WHEN (LEFT(totals_group,16) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')) or LEFT(totals_group,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')  ))

and not(SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')))

and not((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25)

and LEFT(from_account_id,7) <> '6280512'

then 'Our Debit Cards Loading Other Prepaid Cards'

 

WHEN LEFT(pan,6) in  (SELECT part FROM dbo.usf_split_string(@ALLBINs,','))

and (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')) or ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25) )

then 'Our Debit Cards loading Our Prepaid Cards'

 

WHEN (LEFT(totals_group,16) in  (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')) or LEFT(totals_group,3) in  (SELECT part FROM dbo.usf_split_string(@totalsgroups,',') ))

and  not(SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')))

and not((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25)

then 'Our Debit Cards loading Other Prepaid Cards'

 

WHEN not( LEFT(totals_group,16) in  (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')) or LEFT(totals_group,3) in  (SELECT part FROM dbo.usf_split_string(@totalsgroups,',')))

and (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')) or ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) and len(to_cashcard_account_id)=25) )

then 'Other Debit Cards loading Our Prepaid Cards'

 

WHEN (LEFT(totals_group,16) in  (SELECT part FROM dbo.usf_split_string(@ALLBINs,','))

and (SUBSTRING(to_cashcard_account_id,9,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,','))) or ((SUBSTRING(to_cashcard_account_id,15,3) in (SELECT part FROM dbo.usf_split_string(@CBNCodes,',')) and len(to_cashcard_account_id)=25))

and LEFT(from_account_id,7) <> '6280512'

)
then 'Others'

END