SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


ALTER  PROCEDURE usp_get_monthly_acquirer_data  (
       @start_date DATETIME, 
       @end_date DATETIME,
       @day_interval INT) AS
     BEGIN
        DECLARE @date_diff DATETIME;

        SELECT @start_date = ISNULL(@start_date, (DATEADD(DAY, -1, GETDATE())));
	SELECT @start_date = CONVERT(DATETIME, @start_date, 105);
	SELECT @end_date =  ISNULL(@end_date,  GETDATE());
	SELECT  @day_interval =ISNULL( @day_interval,5);
     
        
        SELECT @date_diff =  DATEADD(DAY, @day_interval,@start_date);
        
      
        
        IF(  DATEDIFF(SECOND,@date_diff, @end_date) >0)
           BEGIN
           
           	SELECT @date_diff =  @end_date;
           
           END
	IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'#TEMP_RESULTS_TABLE'))
	BEGIN
		DROP TABLE #TEMP_RESULTS_TABLE
	END

           
	   		SELECT
	   			    --datepart(mm, datetime_req),
	   			    --datename(month, datetime_req),
	   			    ptc.card_acceptor_id_code,
	   			    tran_type,
	   			    merchant_type,
	   			    acquiring_inst_id_code,
	   			    case
	   					when acquiring_inst_id_code= 589019 then 'FBN'           
	   					when acquiring_inst_id_code= 627480 then 'UBA'
	   					when acquiring_inst_id_code= 627629 then 'ZIB'                        
	   					when acquiring_inst_id_code= 627787 then 'GTB'
	   					when acquiring_inst_id_code= 627805 then 'PRU'
	   					when acquiring_inst_id_code= 603948 then 'OBI'
	   					when acquiring_inst_id_code= 627858 then 'IBTC'
	   					when acquiring_inst_id_code= 627819 then 'AFRI'
	   					when acquiring_inst_id_code= 627821 then 'WEM'
	   					when acquiring_inst_id_code= 627955 then 'PHB'
	   					when acquiring_inst_id_code= 628009 then 'FCMB'
	   					when acquiring_inst_id_code= 627168 then 'DBL'
	   					when acquiring_inst_id_code= 000000 then 'DBL'
	   					when acquiring_inst_id_code= 602980 then 'UBN'
	   					when acquiring_inst_id_code= 639249 then 'ETB'
	   					when acquiring_inst_id_code= 639138 then 'FBP'
	   					when acquiring_inst_id_code= 636088 then 'IBP'
	   					when acquiring_inst_id_code= 639203 then 'FIN'
	   					when acquiring_inst_id_code= 639139 then 'ABP'
	   					when acquiring_inst_id_code= 636092 then 'SBP'
	   					when acquiring_inst_id_code= 903708 then 'EBN'
	   					when acquiring_inst_id_code= 639609 then 'UBP'
	   					when acquiring_inst_id_code= 639563 then 'SPR'
	   					when acquiring_inst_id_code= 023023 then 'CITI'
	   					else 'Not Registered'     
	   			    end as Bank,
	   
	   			    sum (pt.settle_amount_impact) as tran_volume,
	   			    sum (
	   					case
	   						    when pt.settle_amount_impact < 0 then 1
	   						    else 1
	   					end) nr_trans  
	   					
	   		INTO #TEMP_RESULTS_TABLE
	   
	   		FROM post_tran_cust ptc (nolock), post_tran pt (nolock)--, post_terminal_has_client pthc (nolock)
	   
	   		WHERE ptc.post_tran_cust_id = pt.post_tran_cust_id
	   		--and ptc.terminal_id = pthc.terminal_id
	   		and pt.tran_postilion_originated = 1
	   		and 
	   		 pt.datetime_req  BETWEEN @start_date AND @date_diff
	   		--pt.datetime_req > '2013-11-01'and pt.datetime_req < '2013-12-01
	   		and pt.message_type in ('0200','0220')
	   		and tran_type in('00','01')
	   		and pt.tran_reversed in(1,0)
	   		--and ptc.terminal_id like '2%'
	   		--and sink_node_name IN ('POSSWTsnk','FUELSWTsnk','TELCOSWTsnk','TRAVELSWTsnk')
	   		and sink_node_name IN ('WEBSWTsnk','WEBFEESWTsnk','IPDSWTsnk')
	   		and (ptc.terminal_id like ('3IWP%')or ptc.terminal_id like ('3ICP%'))
	   
	   
	   		group by 
	   		--datepart(mm, datetime_req), 
	   		--datename(month, datetime_req),
	   		--participant_client_id,
	   		acquiring_inst_id_code,
	   		card_acceptor_id_code,
	   		merchant_type,
	   		tran_type
	   		
	   		SELECT @start_date = @date_diff;
	   		
		       SELECT @date_diff =  DATEADD(DAY, @day_interval,@start_date);
        
        
        
         WHILE (  DATEDIFF(SECOND,@date_diff, @end_date) >=0) 
         
             BEGIN
             
             INSERT INTO #TEMP_RESULTS_TABLE
             

		SELECT
			    --datepart(mm, datetime_req),
			    --datename(month, datetime_req),
			    ptc.card_acceptor_id_code,
			    tran_type,
			    merchant_type,
			    acquiring_inst_id_code,
			    case
					when acquiring_inst_id_code= 589019 then 'FBN'           
					when acquiring_inst_id_code= 627480 then 'UBA'
					when acquiring_inst_id_code= 627629 then 'ZIB'                        
					when acquiring_inst_id_code= 627787 then 'GTB'
					when acquiring_inst_id_code= 627805 then 'PRU'
					when acquiring_inst_id_code= 603948 then 'OBI'
					when acquiring_inst_id_code= 627858 then 'IBTC'
					when acquiring_inst_id_code= 627819 then 'AFRI'
					when acquiring_inst_id_code= 627821 then 'WEM'
					when acquiring_inst_id_code= 627955 then 'PHB'
					when acquiring_inst_id_code= 628009 then 'FCMB'
					when acquiring_inst_id_code= 627168 then 'DBL'
					when acquiring_inst_id_code= 000000 then 'DBL'
					when acquiring_inst_id_code= 602980 then 'UBN'
					when acquiring_inst_id_code= 639249 then 'ETB'
					when acquiring_inst_id_code= 639138 then 'FBP'
					when acquiring_inst_id_code= 636088 then 'IBP'
					when acquiring_inst_id_code= 639203 then 'FIN'
					when acquiring_inst_id_code= 639139 then 'ABP'
					when acquiring_inst_id_code= 636092 then 'SBP'
					when acquiring_inst_id_code= 903708 then 'EBN'
					when acquiring_inst_id_code= 639609 then 'UBP'
					when acquiring_inst_id_code= 639563 then 'SPR'
					when acquiring_inst_id_code= 023023 then 'CITI'
					else 'Not Registered'     
			    end as Bank,

			    sum (pt.settle_amount_impact) as tran_volume,
			    sum (
					case
						    when pt.settle_amount_impact < 0 then 1
						    else 1
					end) nr_trans                

		FROM post_tran_cust ptc (nolock), post_tran pt (nolock)--, post_terminal_has_client pthc (nolock)

		WHERE ptc.post_tran_cust_id = pt.post_tran_cust_id
		--and ptc.terminal_id = pthc.terminal_id
		and pt.tran_postilion_originated = 1
		and 
		 pt.datetime_req  BETWEEN @start_date AND @date_diff
		--pt.datetime_req > '2013-11-01'and pt.datetime_req < '2013-12-01
		and pt.message_type in ('0200','0220')
		and tran_type in('00','01')
		and pt.tran_reversed in(1,0)
		--and ptc.terminal_id like '2%'
		--and sink_node_name IN ('POSSWTsnk','FUELSWTsnk','TELCOSWTsnk','TRAVELSWTsnk')
		and sink_node_name IN ('WEBSWTsnk','WEBFEESWTsnk','IPDSWTsnk')
		and (ptc.terminal_id like ('3IWP%')or ptc.terminal_id like ('3ICP%'))
		
		SELECT @start_date = @date_diff;
		
		SELECT @date_diff =  DATEADD(DAY, @day_interval,@start_date);
		        
	
	END

	
	SELECT * FROM #TEMP_RESULTS_TABLE  GROUP BY 
		--datepart(mm, datetime_req), 
		--datename(month, datetime_req),
		--participant_client_id,
		acquiring_inst_id_code,
		card_acceptor_id_code,
		merchant_type,
		tran_type
	
	IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'#TEMP_RESULTS_TABLE'))
		BEGIN
			DROP TABLE #TEMP_RESULTS_TABLE
		END

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

