/*** Switched_Out Processing ***/
SELECT CONVERT(VARCHAR(6), datetime_req, 112) as Month,
            CONVERT(VARCHAR(8),datetime_req, 112) as Date,
            source_bank as Acquirer,
            source_node_name,
            sum(dbo.fn_rpt_islocalfinancial0100AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))                 as  Dom_Fin_100,
            sum(dbo.fn_rpt_islocal_non_financial0100AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))     as  Dom_NonFin_100,            
            sum(dbo.fn_rpt_islocal_0100_AcqTrx_Failed  (message_type,tran_amount_req,rsp_code_rsp,pan))                                                     as         Dom_Failed_100,
            sum(dbo.fn_rpt_islocalfinancial0200AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))                 as  Dom_Fin_200,
            sum(dbo.fn_rpt_islocal_non_financial0200AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))     as  Dom_NonFin_200,
            sum(dbo.fn_rpt_islocal_0200_AcqTrx_Failed (message_type,tran_amount_req,rsp_code_rsp,pan))                                                     as         Dom_Failed_200,
            sum(dbo.fn_rpt_islocalfinancial0220AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))                 as  Dom_Fin_220,
            sum(dbo.fn_rpt_islocal_non_financial0220AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))     as  Dom_NonFin_220,
            sum(dbo.fn_rpt_islocal_0220_AcqTrx_Failed (message_type,tran_amount_req,rsp_code_rsp,pan))                                                     as         Dom_Failed_220,
            sum(dbo.fn_rpt_isforeignfinancial0100AcqTrx_Successful            (message_type,tran_amount_req,rsp_code_rsp,pan))     as  For_Fin_100,
sum(dbo.fn_rpt_isforeign_non_financial0100AcqTrx_Successful(message_type,tran_amount_req,rsp_code_rsp,pan))            as  For_NonFin_100,
            sum(dbo.fn_rpt_isforeign_0100_AcqTrx_Failed            (message_type,tran_amount_req,rsp_code_rsp,pan))                                         as         For_Failed_100,
            sum(dbo.fn_rpt_isforeignfinancial0200AcqTrx_Successful            (message_type,tran_amount_req,rsp_code_rsp,pan))     as  For_Fin_200,
            sum(dbo.fn_rpt_isforeign_non_financial0200AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))as  For_NonFin_200,
            sum(dbo.fn_rpt_isforeign_0200_AcqTrx_Failed (message_type,tran_amount_req,rsp_code_rsp,pan))                                         as         For_Failed_200,
            sum(dbo.fn_rpt_isforeignfinancial0220AcqTrx_Successful (message_type,tran_amount_req,rsp_code_rsp,pan))     as  For_Fin_220,
            sum(dbo.fn_rpt_isforeign_non_financial0220AcqTrx_Successful            (message_type,tran_amount_req,rsp_code_rsp,pan))as  For_NonFin_220,
            sum(dbo.fn_rpt_isforeign_0220_AcqTrx_Failed (message_type,tran_amount_req,rsp_code_rsp,pan))                                         as         For_Failed_220 
FROM  

        ( 
        SELECT * FROM post_tran pt  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date
        AND
        pt.tran_completed = 1
        AND     pt.message_type IN ('0100','0200','0220')
        
        JOIN post_tran_cust c   WITH(NOLOCK, index(pk_post_tran_cust) )ON
        pt.post_tran_cust_id = c.post_tran_cust_id
        )  t

    left outer join isw_source_nodes isn (nolock)
                        on t.source_node_name = isn.source_node
                        
group by CONVERT(VARCHAR(6), datetime_req, 112),CONVERT(VARCHAR(8),datetime_req, 112), source_bank, source_node_name
OPTION (RECOMPILE)         
            
            
            
            
            
            
            /*** Switched_In Processing ***/ 
select CONVERT(VARCHAR(6), datetime_req, 112) as Month,
            CONVERT(VARCHAR(8),datetime_req, 112) as Date,
            sink_bank as Issuer,
            sink_node_name,
sum(dbo.fn_rpt_islocalfinancial0100Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  Dom_Fin_100,
sum(dbo.fn_rpt_islocal_non_financial0100Trx_Successful       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))            as  Dom_NonFin_100,
sum(dbo.fn_rpt_islocal_0100Trx_Failed (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         Dom_Failed_100,

sum(dbo.fn_rpt_islocalfinancial0200Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  Dom_Fin_200,
sum(dbo.fn_rpt_islocalfinancial0200TrxCashWdrl_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc,tran_type))              as  Dom_Fin_UBA_200, 
sum(dbo.fn_rpt_islocal_non_financial0200Trx_Successful       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))            as  Dom_NonFin_200,
sum(dbo.fn_rpt_islocal_0200Trx_Failed (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         Dom_Failed_200,

sum(dbo.fn_rpt_islocalfinancial0220Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  Dom_Fin_220,
sum(dbo.fn_rpt_islocal_non_financial0220Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))            as  Dom_Failed_220,
sum(dbo.fn_rpt_islocal_0220Trx_Failed (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         Dom_Failed_220,


sum(dbo.fn_rpt_isforeignfinancial0100Trx_Successful       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  For_Fin_100,
sum(dbo.fn_rpt_isforeign_non_financial0100Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))as  For_NonFin_100,
sum(dbo.fn_rpt_isforeign_0100Trx_Failed       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         For_Failed_100,
            
sum(dbo.fn_rpt_isforeignfinancial0200Trx_Successful(message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  For_Fin_200,
sum(dbo.fn_rpt_isforeign_non_financial0200Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))as  For_NonFin_200,
sum(dbo.fn_rpt_isforeignfinancial0200TrxCashWdrl_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc,tran_type))   as  For_Fin_UBA_200,
sum(dbo.fn_rpt_isforeign_0200Trx_Failed       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         For_Failed_200,            


sum(dbo.fn_rpt_isforeignfinancial0220Trx_Successful       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                        as  For_Fin_220,
sum(dbo.fn_rpt_isforeign_non_financial0220Trx_Successful (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))as  For_NonFin_220,
sum(dbo.fn_rpt_isforeign_0220Trx_Failed       (message_type,tran_amount_req,rsp_code_rsp,card_acceptor_name_loc))                                                            as         For_Failed_220
FROM   (
        SELECT * FROM post_tran t  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date 
        AND
        pt.tran_completed = 1
                  AND 
          pt.message_type IN ('0100','0200','0220')
          
        JOIN post_tran_cust c   WITH(NOLOCK, index(pk_post_tran_cust) )ON
        t.post_tran_cust_id = c.post_tran_cust_id
        )pt
left outer join isw_sink_nodes isn (nolock)
on pt.sink_node_name = isn.sink_node
group by CONVERT(VARCHAR(6), datetime_req, 112), CONVERT(VARCHAR(8),datetime_req, 112), sink_bank,sink_node_name
OPTION(RECOMPILE)

/*** Local Processing ***/
SELECT
            CONVERT(VARCHAR(6), datetime_req, 112) as Month,
            CONVERT(VARCHAR(8),datetime_req, 112) as Date,
            sink_bank as Issuer,
            COUNT(*) as Volume
            FROM isw_data_switchoffice_201608 t (NOLOCK) join isw_sink_nodes isn (nolock)
                        on t.sink_node_name = isn.sink_node                
            WHERE            (t.datetime_req >= '20160801')
                                    AND (t.datetime_req < '20160901')
                                    AND t.message_type NOT IN ('0100','0420')
                                    AND (t.pan like '5%' and t.pan not like '506%')
                                    AND dbo.fn_rpt_get_brand (pan) = 'MASTERCARD'
                                    AND t.tran_type in ('00', '50')
                                    AND t.rsp_code_rsp = '00'
                                    AND sink_node_name like 'SWT%'
            
group by CONVERT(VARCHAR(6), datetime_req, 112), CONVERT(VARCHAR(8),datetime_req, 112), sink_bank


/*** POS_WEB ***/
SELECT CONVERT(VARCHAR(6), datetime_req, 112) as Month,
            CONVERT(VARCHAR(8),datetime_req, 112) as Date,
            source_bank as Acquirer,
            source_node_name,
            count(*) as volume,
            sum (tran_amount_req/100) as value,
            dbo.currencyAlphaCode(t.tran_currency_code) as tran_currency
FROM   ( SELECT * FROM post_tran pt  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date
        AND
        t.tran_completed = 1
        AND t.message_type IN ('0200','0220')--oremeyi removed the 0120
		AND tran_type in ('00','20')
		AND tran_reversed = '0'

        )t
        
        left outer join isw_source_nodes isn (nolock)
                        on t.source_node_name = isn.source_node
            group by CONVERT(VARCHAR(6), datetime_req, 112), CONVERT(VARCHAR(8),datetime_req, 112), source_bank,source_node_name,tran_currency_code
OPTION (RECOMPILE)
/*** Voice Authorization ***/

SELECT
            CONVERT(CHAR(8), datetime_req, 112) as Month,
            CONVERT(VARCHAR(8),datetime_req, 112) as Date,
            source_bank as Acquirer,
            count(*) as volume                                
FROM  ( SELECT * FROM post_tran pt  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date
        
                                    AND pt.message_type = '0220'---eseosa
                                    AND pt.tran_completed = 1
                                    AND pt.rsp_code_rsp = '00'  ---eseosa
                                    AND pt.pos_entry_mode in ('010','000')--eseosa
                                    AND pt.tran_reversed = '0' --eseosa

        
        )  t (NOLOCK) join isw_source_nodes isn (nolock)
                        on t.source_node_name = isn.source_node
                        group by CONVERT(CHAR(8), datetime_req, 112), CONVERT(VARCHAR(8),datetime_req, 112), source_bank
OPTION (RECOMPILE)

/*** PurePlay Switching ***/

select (CONVERT(varchar(6), datetime_req, 112)) as Month, (CONVERT(varchar(8), datetime_req, 112)) as Day, source_node_name as Source_Node, 
source_bank as Acquirer_Bank,totals_bank as Issuer,dbo.fn_rpt_isw_channel(terminal_id) as Channel, dbo.fn_rpt_getTranType(tran_type) as Transaction_type,
idg.totals_group as totals_group,left (pan,6) as Bin,
Count(*) as tran_count,
sum (tran_amount_rsp/100) as volume,
'SuperSwitch' as data_source,
dbo.fn_rpt_get_brand(pan) as Card_Brand
from ( SELECT * FROM post_tran pt  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date
        JOIN 
        post_tran_cust c  with (NOLOCK, INDEX(pk_post_tran_cust))
        ON
        pt.post_tran_cust = c.post_tran_cust
        AND
        LEFT(sink_node_name,3) = 'SWT'
and dbo.fn_rpt_get_brand(pan) in ('Verve', 'Mastercard_Verve')
and pt.message_type in ('0200','0220')
and pt.rsp_code_rsp = '00'
and tran_currency_code = '566'
and settle_amount_impact ! = 0
and (pt.tran_completed=1)
and (pt.tran_reversed = 0)
        
                                ) idg
join isw_source_nodes isc (nolock)
on idg.source_node_name = isc.source_node
join isw_totals_groups itg (nolock)
on idg.totals_group = itg.totals_group
join isw_sink_nodes isn (nolock)
on idg.sink_node_name = isn.sink_node
group by (CONVERT(char(6), datetime_req, 112)),
(CONVERT(char(8), datetime_req, 112)),
source_node_name,
source_bank,
totals_bank,
left(pan,6),
idg.totals_group,
tran_type,
dbo.fn_rpt_isw_channel(terminal_id),
acquiring_inst_id_code,
dbo.fn_rpt_get_brand(pan)

OPTION (RECOMPILE)

/*** ISO Revenue ***/
select (CONVERT(varchar(6), datetime_req, 112)) as Month, (CONVERT(varchar(8), datetime_req, 112)) as Day, source_node_name as Source_Node, 
source_bank as Acquirer_Bank,totals_bank as Issuer,dbo.fn_rpt_isw_channel(terminal_id) as Channel, dbo.fn_rpt_getTranType(tran_type) as Transaction_type,
idg.totals_group as totals_group,left (pan,6) as Bin,
Count(*) as tran_count,
sum (tran_amount_rsp/100) as volume,
'SuperSwitch' as data_source,
dbo.fn_rpt_get_brand(pan) as Card_Brand
from  ( SELECT * FROM post_tran pt  with (NOLOCK, INDEX(ix_post_tran_9)) 
        JOIN  (SELECT [date] rec_bus_date FROM dbo.get_dates_in_range('20160801','20160901'))r
        ON 
        r.rec_bus_date = pt.recon_business_date
        JOIN 
        post_tran_cust c  with (NOLOCK, INDEX(pk_post_tran_cust))
        ON
        pt.post_tran_cust = c.post_tran_cust
         LEFT(sink_node_name,3) = 'SWT'
and dbo.fn_rpt_get_brand(pan) in ('Mastercard','Visa') --- or (‘Verve', ‘Mastercard_Verve’)
and pt.message_type in ('0200','0220')
and pt.rsp_code_rsp = '00'
and tran_currency_code = '566'
and settle_amount_impact ! = 0
and (pt.tran_completed=1)
and (pt.tran_reversed = 0)
        ) idg(nolock)
join isw_source_nodes isc (nolock)
on idg.source_node_name = isc.source_node
join isw_totals_groups itg (nolock)
on idg.totals_group = itg.totals_group
join isw_sink_nodes isn (nolock)
on idg.sink_node_name = isn.sink_node
group by (CONVERT(char(6), datetime_req, 112)),
(CONVERT(char(8), datetime_req, 112)),
source_node_name,
source_bank,
totals_bank,
left(pan,6),
idg.totals_group,
tran_type,
dbo.fn_rpt_isw_channel(terminal_id),
acquiring_inst_id_code,
dbo.fn_rpt_get_brand(pan)
option(recompile)