SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

ALTER  PROCEDURE get_monthly_card_details (@start_date DATETIME, @end_date DATETIME)

AS

 BEGIN
 

        SELECT @start_date = ISNULL(@start_date, (DATEADD(MONTH, -1, GETDATE())));
	SELECT @start_date = CONVERT(DATETIME, @start_date, 105);
	SELECT @end_date =  ISNULL(@end_date,  GETDATE());

	SELECT
                         card_acceptor_id_code, 
                         card_acceptor_name_loc, 
                         sink_node_name,
                        category_name, 
                         merchant_type,
                        CASE
                                    WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                                    WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
                                    WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                       ELSE 0
                                    END AS no_above_limit,
                        CASE
                                    WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1
                                    WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
                                    WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        ELSE 0
                                    END AS amount_above_limit,
                        settle_amount_impact * -1  as amount,
                        settle_tran_fee_rsp *-1 as fee


            
            FROM 
                                                post_tran t (NOLOCK)
                                                INNER JOIN post_tran_cust c (NOLOCK)
                                                ON  t.post_tran_cust_id = c.post_tran_cust_id
                                                left JOIN tbl_merchant_category m (NOLOCK)
                                                ON c.merchant_type = m.category_code 
                                                
                                                
            WHERE                                    
                                                
                                    t.tran_completed = 1
                                                AND
                                                t.tran_postilion_originated = 0 
                                                AND
                                                (
                                                (t.message_type IN ('0100','0200', '0400', '0420')) 
                                                )
                                                AND                                         
                                                t.tran_completed = 1
                                                AND
                                                tran_type NOT IN ('31','39','50')
                                                AND
                                                            (
                                                            (c.terminal_id like '3IWP%') OR
                                                            (c.terminal_id like '3ICP%') --OR
                                                            )
                                                AND
                                                sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')
	     AND datetime_req > @start_date and datetime_req < @end_date


END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

