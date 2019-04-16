USE [postilion_settlement]
GO
/****** Object:  StoredProcedure [dbo].[usp_settlement_main_body]    Script Date: 12/18/2017 12:38:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[usp_settlement_main_body] @TRANSACTION_TABLE_MARKER varchar(255), @JOURNAL_TABLE_MARKER varchar(255),  @CURRENT_THREAD_NUMBER VARCHAR(5) 

 as  begin
 
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

exec('
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			 SELECT    
						bank_code = CASE 

                          
WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and  (DebitAccNr_acc_nr LIKE ''%FEE_PAYABLE'' or CreditAccNr_acc_nr LIKE ''%FEE_PAYABLE'')) THEN ''ISW'' 

WHEN                      
			           (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
                        AND  
			           (DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                         THEN ''UBA''     
                             
                          
                          
WHEN                      [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                          AND ((PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code <> ''627787'') 
                                OR (PT.PTC_source_node_name = ''SWTFBPsrc'' AND PT.PT_sink_node_name = ''ASPPOSVISsnk'' 
                                 AND PT.PTC_totals_group = ''VISAGroup'')
                               )
                          THEN ''UBA''
                          
                          
WHEN                      [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                          AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code = ''627787'')
                          THEN ''UNK''
                          
                          --AND (PT.PT_acquiring_inst_id_code <> ''627480'' or 
                          --(PT.PT_acquiring_inst_id_code = ''627480''
                          --and dbo.fn_rpt_terminal_type(PT.PTC_terminal_id) =''3''))
                          
WHEN                      
			(PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  
                        AND  
			(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
                         OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                         THEN ''UBA''                             
                          
WHEN                      
			(PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  
                        AND  
			(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
                         OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312'' and PT.PT_tran_type = ''50'')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                         THEN ''UBA''   
                          
                          
  WHEN                     [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                        AND  PT.PT_acquiring_inst_id_code  NOT IN (''627787'',''639139'')
                              AND PT.PT_sink_node_name = ''ASPPOSVISsnk''    
                          THEN ''UBA''     
                          
                                                    
 WHEN                       [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                        AND  PT.PT_acquiring_inst_id_code = ''627787''  
                        AND PT.PT_sink_node_name = ''ASPPOSVISsnk''   
                          THEN ''GTB''       
                          
WHEN                       [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                        AND  PT.PT_acquiring_inst_id_code = ''639139''  
                        AND PT.PT_sink_node_name = ''ASPPOSVISsnk''   
                          THEN ''ABP''    
                          
                           
                                                      
 WHEN                      
						(PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  
                           AND  
					 [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1                      
                          THEN ''ABP''   
                          
    WHEN                     
					 (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
					  [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                                   
                          THEN ''GTB''                                                                        
                           
   WHEN                     
						 (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
					 [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                                  
                          THEN ''EBN''  
                          
   WHEN                   
						(PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
						 [dbo].[fn_rpt_sttl_brkdwn_1] (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT_tran_type ,PTC_source_node_name ,PT_sink_node_name,PT_payee, PTC_card_acceptor_id_code ,PTC_totals_group,PTC_pan, PTC_terminal_id  ,PT_extended_tran_type  ,PT_message_type) =1
                                   
                          THEN ''UBA''                                             
                           


WHEN PTT.PT_Retention_data = ''1046'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 THEN ''UBN''
WHEN PTT.PT_Retention_data in (''9130'',''8130'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''ABS''
WHEN PTT.PT_Retention_data in (''9044'',''8044'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''ABP''
WHEN PTT.PT_Retention_data in (''9023'',''8023'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''CITI''
WHEN PTT.PT_Retention_data in (''9050'',''8050'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''EBN''
WHEN PTT.PT_Retention_data in (''9214'',''8214'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''FCMB''
WHEN PTT.PT_Retention_data in (''9070'',''8070'',''1100'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1   then ''FBP''
WHEN PTT.PT_Retention_data in (''9011'',''8011'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''FBN''
WHEN PTT.PT_Retention_data in (''9058'',''8058'')  and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''GTB''
WHEN PTT.PT_Retention_data in (''9082'',''8082'') and  [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''KSB''
WHEN PTT.PT_Retention_data in (''9076'',''8076'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1   then ''SKYE''
WHEN PTT.PT_Retention_data in (''9084'',''8084'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''ENT''
WHEN PTT.PT_Retention_data in (''9039'',''8039'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1   then ''IBTC''
WHEN PTT.PT_Retention_data in (''9068'',''8068'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''SCB''
WHEN PTT.PT_Retention_data in (''9232'',''8232'',''1105'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''SBP''
WHEN PTT.PT_Retention_data in (''9032'',''8032'')  and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''UBN''
WHEN PTT.PT_Retention_data in (''9033'',''8033'')  and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 then ''UBA''
WHEN PTT.PT_Retention_data in (''9215'',''8215'')  and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''UBP''
WHEN PTT.PT_Retention_data in (''9035'',''8035'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''WEMA''
WHEN PTT.PT_Retention_data in (''9057'',''8057'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''ZIB''
WHEN PTT.PT_Retention_data in (''9301'',''8301'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''JBP''
WHEN PTT.PT_Retention_data in (''9030'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  then ''HBC''
						  
WHEN PTT.PT_Retention_data = ''1411'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 THEN ''HBC''
                          						                     	                                       
			
			
			WHEN PTT.PT_Retention_data = ''1131'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''WEMA''
                         WHEN PTT.PT_Retention_data in (''1061'',''1006'',''7004'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 THEN ''GTB''
                         WHEN PTT.PT_Retention_data = ''1708'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''FBN''
                         WHEN PTT.PT_Retention_data in (''1027'',''1045'',''1081'',''1015'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 THEN ''SKYE''
                         WHEN PTT.PT_Retention_data in (''1037'',''7002'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 THEN ''IBTC''
                         WHEN PTT.PT_Retention_data = ''1034'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''EBN''
                          WHEN PTT.PT_Retention_data in (''1585'',''7001'') and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''ABP''
                          WHEN PTT.PT_Retention_data = ''7003'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1 ''WEMA''
                          WHEN PTT.PT_Retention_data = ''1260'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''ISW''
                       -- WHEN PTT.Retention_data = ''1006'' and [dbo].[fn_rpt_sttl_brkdwn_2] (DebitAccNr_acc_nr,CreditAccNr_acc_nr ) =1  THEN ''DBL''
                         WHEN (DebitAccNr_acc_nr LIKE ''UBA%'' OR CreditAccNr_acc_nr LIKE ''UBA%'') THEN ''UBA''
			 WHEN (DebitAccNr_acc_nr LIKE ''FBN%'' OR CreditAccNr_acc_nr LIKE ''FBN%'') THEN ''FBN''
                         WHEN (DebitAccNr_acc_nr LIKE ''ZIB%'' OR CreditAccNr_acc_nr LIKE ''ZIB%'') THEN ''ZIB'' 
                         WHEN (DebitAccNr_acc_nr LIKE ''SPR%'' OR CreditAccNr_acc_nr LIKE ''SPR%'') THEN ''ENT''
                         WHEN (DebitAccNr_acc_nr LIKE ''GTB%'' OR CreditAccNr_acc_nr LIKE ''GTB%'') THEN ''GTB''
                         WHEN (DebitAccNr_acc_nr LIKE ''PRU%'' OR CreditAccNr_acc_nr LIKE ''PRU%'') THEN ''SKYE''
                         WHEN (DebitAccNr_acc_nr LIKE ''OBI%'' OR CreditAccNr_acc_nr LIKE ''OBI%'') THEN ''EBN''
                         WHEN (DebitAccNr_acc_nr LIKE ''WEM%'' OR CreditAccNr_acc_nr LIKE ''WEM%'') THEN ''WEMA''
                         WHEN (DebitAccNr_acc_nr LIKE ''AFR%'' OR CreditAccNr_acc_nr LIKE ''AFR%'') THEN ''MSB''
                         WHEN (DebitAccNr_acc_nr LIKE ''IBTC%'' OR CreditAccNr_acc_nr LIKE ''IBTC%'') THEN ''IBTC''
                         WHEN (DebitAccNr_acc_nr LIKE ''PLAT%'' OR CreditAccNr_acc_nr LIKE ''PLAT%'') THEN ''KSB''
                         WHEN (DebitAccNr_acc_nr LIKE ''UBP%'' OR CreditAccNr_acc_nr LIKE ''UBP%'') THEN ''UBP''
                         WHEN (DebitAccNr_acc_nr LIKE ''DBL%'' OR CreditAccNr_acc_nr LIKE ''DBL%'') THEN ''DBL''

                         WHEN (DebitAccNr_acc_nr LIKE ''FCMB%'' OR CreditAccNr_acc_nr LIKE ''FCMB%'') THEN ''FCMB''
                         WHEN (DebitAccNr_acc_nr LIKE ''IBP%'' OR CreditAccNr_acc_nr LIKE ''IBP%'') THEN ''ABP''
                         WHEN (DebitAccNr_acc_nr LIKE ''UBN%'' OR CreditAccNr_acc_nr LIKE ''UBN%'') THEN ''UBN''
                         WHEN (DebitAccNr_acc_nr LIKE ''ETB%'' OR CreditAccNr_acc_nr LIKE ''ETB%'') THEN ''ETB''
                         WHEN (DebitAccNr_acc_nr LIKE ''FBP%'' OR CreditAccNr_acc_nr LIKE ''FBP%'') THEN ''FBP''
                         WHEN (DebitAccNr_acc_nr LIKE ''SBP%'' OR CreditAccNr_acc_nr LIKE ''SBP%'') THEN ''SBP''
                         WHEN (DebitAccNr_acc_nr LIKE ''ABP%'' OR CreditAccNr_acc_nr LIKE ''ABP%'') THEN ''ABP''
                         WHEN (DebitAccNr_acc_nr LIKE ''EBN%'' OR CreditAccNr_acc_nr LIKE ''EBN%'') THEN ''EBN''

                         WHEN (DebitAccNr_acc_nr LIKE ''CITI%'' OR CreditAccNr_acc_nr LIKE ''CITI%'') THEN ''CITI''
                         WHEN (DebitAccNr_acc_nr LIKE ''FIN%'' OR CreditAccNr_acc_nr LIKE ''FIN%'') THEN ''FCMB''
                         WHEN (DebitAccNr_acc_nr LIKE ''ASO%'' OR CreditAccNr_acc_nr LIKE ''ASO%'') THEN ''ASO''
                         WHEN (DebitAccNr_acc_nr LIKE ''OLI%'' OR CreditAccNr_acc_nr LIKE ''OLI%'') THEN ''OLI''
                         WHEN (DebitAccNr_acc_nr LIKE ''HSL%'' OR CreditAccNr_acc_nr LIKE ''HSL%'') THEN ''HSL''
                         WHEN (DebitAccNr_acc_nr LIKE ''ABS%'' OR CreditAccNr_acc_nr LIKE ''ABS%'') THEN ''ABS''
                         WHEN (DebitAccNr_acc_nr LIKE ''PAY%'' OR CreditAccNr_acc_nr LIKE ''PAY%'') THEN ''PAY''
                         WHEN (DebitAccNr_acc_nr LIKE ''SAT%'' OR CreditAccNr_acc_nr LIKE ''SAT%'') THEN ''SAT''
                         WHEN (DebitAccNr_acc_nr LIKE ''3LCM%'' OR CreditAccNr_acc_nr LIKE ''3LCM%'') THEN ''3LCM''
                         WHEN (DebitAccNr_acc_nr LIKE ''SCB%'' OR CreditAccNr_acc_nr LIKE ''SCB%'') THEN ''SCB''
                         WHEN (DebitAccNr_acc_nr LIKE ''JBP%'' OR CreditAccNr_acc_nr LIKE ''JBP%'') THEN ''JBP''
                         WHEN (DebitAccNr_acc_nr LIKE ''RSL%'' OR CreditAccNr_acc_nr LIKE ''RSL%'') THEN ''RSL''
                         WHEN (DebitAccNr_acc_nr LIKE ''PSH%'' OR CreditAccNr_acc_nr LIKE ''PSH%'') THEN ''PSH''
                         WHEN (DebitAccNr_acc_nr LIKE ''INF%'' OR CreditAccNr_acc_nr LIKE ''INF%'') THEN ''INF''
                         WHEN (DebitAccNr_acc_nr LIKE ''UML%'' OR CreditAccNr_acc_nr LIKE ''UML%'') THEN ''UML''

                         WHEN (DebitAccNr_acc_nr LIKE ''ACCI%'' OR CreditAccNr_acc_nr LIKE ''ACCI%'') THEN ''ACCI''
                         WHEN (DebitAccNr_acc_nr LIKE ''EKON%'' OR CreditAccNr_acc_nr LIKE ''EKON%'') THEN ''EKON''
                         WHEN (DebitAccNr_acc_nr LIKE ''ATMC%'' OR CreditAccNr_acc_nr LIKE ''ATMC%'') THEN ''ATMC''
                         WHEN (DebitAccNr_acc_nr LIKE ''HBC%'' OR CreditAccNr_acc_nr LIKE ''HBC%'') THEN ''HBC''
			 WHEN (DebitAccNr_acc_nr LIKE ''UNI%'' OR CreditAccNr_acc_nr LIKE ''UNI%'') THEN ''UNI''
                         WHEN (DebitAccNr_acc_nr LIKE ''UNC%'' OR CreditAccNr_acc_nr LIKE ''UNC%'') THEN ''UNC''
                         WHEN (DebitAccNr_acc_nr LIKE ''NCS%'' OR CreditAccNr_acc_nr LIKE ''NCS%'') THEN ''NCS'' 
			 WHEN (DebitAccNr_acc_nr LIKE ''HAG%'' OR CreditAccNr_acc_nr LIKE ''HAG%'') THEN ''HAG''
			 WHEN (DebitAccNr_acc_nr LIKE ''EXP%'' OR CreditAccNr_acc_nr LIKE ''EXP%'') THEN ''DBL''
			 WHEN (DebitAccNr_acc_nr LIKE ''FGMB%'' OR CreditAccNr_acc_nr LIKE ''FGMB%'') THEN ''FGMB''
                         WHEN (DebitAccNr_acc_nr LIKE ''CEL%'' OR CreditAccNr_acc_nr LIKE ''CEL%'') THEN ''CEL''
			 WHEN (DebitAccNr_acc_nr LIKE ''RDY%'' OR CreditAccNr_acc_nr LIKE ''RDY%'') THEN ''RDY''
			 WHEN (DebitAccNr_acc_nr LIKE ''AMJ%'' OR CreditAccNr_acc_nr LIKE ''AMJ%'') THEN ''AMJU''
			 WHEN (DebitAccNr_acc_nr LIKE ''CAP%'' OR CreditAccNr_acc_nr LIKE ''CAP%'') THEN ''O3CAP''
			 WHEN (DebitAccNr_acc_nr LIKE ''VER%'' OR CreditAccNr_acc_nr LIKE ''VER%'') THEN ''VER_GLOBAL''

			 WHEN (DebitAccNr_acc_nr LIKE ''SMF%'' OR CreditAccNr_acc_nr LIKE ''SMF%'') THEN ''SMFB''
			 WHEN (DebitAccNr_acc_nr LIKE ''SLT%'' OR CreditAccNr_acc_nr LIKE ''SLT%'') THEN ''SLTD''
			 WHEN (DebitAccNr_acc_nr LIKE ''JES%'' OR CreditAccNr_acc_nr LIKE ''JES%'') THEN ''JES''
                         WHEN (DebitAccNr_acc_nr LIKE ''MOU%'' OR CreditAccNr_acc_nr LIKE ''MOU%'') THEN ''MOUA''
                         WHEN (DebitAccNr_acc_nr LIKE ''MUT%'' OR CreditAccNr_acc_nr LIKE ''MUT%'') THEN ''MUT''
                         WHEN (DebitAccNr_acc_nr LIKE ''LAV%'' OR CreditAccNr_acc_nr LIKE ''LAV%'') THEN ''LAV''
                         WHEN (DebitAccNr_acc_nr LIKE ''JUB%'' OR CreditAccNr_acc_nr LIKE ''JUB%'') THEN ''JUB''
						 WHEN (DebitAccNr_acc_nr LIKE ''WET%'' OR CreditAccNr_acc_nr LIKE ''WET%'') THEN ''WET''
                         WHEN (DebitAccNr_acc_nr LIKE ''AGH%'' OR CreditAccNr_acc_nr LIKE ''AGH%'') THEN ''AGH''
                         WHEN (DebitAccNr_acc_nr LIKE ''TRU%'' OR CreditAccNr_acc_nr LIKE ''TRU%'') THEN ''TRU''
						 WHEN (DebitAccNr_acc_nr LIKE ''CON%'' OR CreditAccNr_acc_nr LIKE ''CON%'') THEN ''CON''
                         WHEN (DebitAccNr_acc_nr LIKE ''CRU%'' OR CreditAccNr_acc_nr LIKE ''CRU%'') THEN ''CRU''
						WHEN (DebitAccNr_acc_nr LIKE ''NPR%'' OR CreditAccNr_acc_nr LIKE ''NPR%'') THEN ''NPR''
						WHEN (DebitAccNr_acc_nr LIKE ''OMO%'' OR CreditAccNr_acc_nr LIKE ''OMO%'') THEN ''OMO''
						WHEN (DebitAccNr_acc_nr LIKE ''SUN%'' OR CreditAccNr_acc_nr LIKE ''SUN%'') THEN ''SUN''
						WHEN (DebitAccNr_acc_nr LIKE ''NGB%'' OR CreditAccNr_acc_nr LIKE ''NGB%'') THEN ''NGB''
						WHEN (DebitAccNr_acc_nr LIKE ''OSC%'' OR CreditAccNr_acc_nr LIKE ''OSC%'') THEN ''OSC''
						WHEN (DebitAccNr_acc_nr LIKE ''OSP%'' OR CreditAccNr_acc_nr LIKE ''OSP%'') THEN ''OSP''
						WHEN (DebitAccNr_acc_nr LIKE ''IFIS%'' OR CreditAccNr_acc_nr LIKE ''IFIS%'') THEN ''IFIS''
						WHEN (DebitAccNr_acc_nr LIKE ''NPM%'' OR CreditAccNr_acc_nr LIKE ''NPM%'') THEN ''NPM''
						WHEN (DebitAccNr_acc_nr LIKE ''POL%'' OR CreditAccNr_acc_nr LIKE ''POL%'') THEN ''POL''
						WHEN (DebitAccNr_acc_nr LIKE ''ALV%'' OR CreditAccNr_acc_nr LIKE ''ALV%'') THEN ''ALV''
						WHEN (DebitAccNr_acc_nr LIKE ''MAY%'' OR CreditAccNr_acc_nr LIKE ''MAY%'') THEN ''MAY''
						WHEN (DebitAccNr_acc_nr LIKE ''PRO%'' OR CreditAccNr_acc_nr LIKE ''PRO%'') THEN ''PRO''
						WHEN (DebitAccNr_acc_nr LIKE ''UNIL%'' OR CreditAccNr_acc_nr LIKE ''UNIL%'') THEN ''UNIL''
						WHEN (DebitAccNr_acc_nr LIKE ''PAR%'' OR CreditAccNr_acc_nr LIKE ''PAR%'') THEN ''PAR''
						WHEN (DebitAccNr_acc_nr LIKE ''FOR%'' OR CreditAccNr_acc_nr LIKE ''FOR%'') THEN ''FOR''
							WHEN (DebitAccNr_acc_nr LIKE ''MON%'' OR CreditAccNr_acc_nr LIKE ''MON%'') THEN ''MON''
							WHEN (DebitAccNr_acc_nr LIKE ''NDI%'' OR CreditAccNr_acc_nr LIKE ''NDI%'') THEN ''NDI''
							WHEN (DebitAccNr_acc_nr LIKE ''ARM%'' OR CreditAccNr_acc_nr LIKE ''ARM%'') THEN ''ARM''	
							WHEN (DebitAccNr_acc_nr LIKE ''OKW%'' OR CreditAccNr_acc_nr LIKE ''OKW%'') THEN ''OKW''
						WHEN (DebitAccNr_acc_nr LIKE ''COR%'' OR CreditAccNr_acc_nr LIKE ''COR%'') THEN ''COR''
							WHEN (DebitAccNr_acc_nr LIKE ''PAG%'' OR CreditAccNr_acc_nr LIKE ''PAG%'') THEN ''PAG''	
							WHEN (DebitAccNr_acc_nr LIKE ''LAP%'' OR CreditAccNr_acc_nr LIKE ''LAP%'') THEN ''LAPO''	
							WHEN (DebitAccNr_acc_nr LIKE ''TCF%'' OR CreditAccNr_acc_nr LIKE ''TCF%'') THEN ''TCF''	
							WHEN (DebitAccNr_acc_nr LIKE ''MID%'' OR CreditAccNr_acc_nr LIKE ''MID%'') THEN ''MID''
							WHEN (DebitAccNr_acc_nr LIKE ''RIM%'' OR CreditAccNr_acc_nr LIKE ''RIM%'') THEN ''RIMA''
							WHEN (DebitAccNr_acc_nr LIKE ''SAF%'' OR CreditAccNr_acc_nr LIKE ''SAF%'') THEN ''SAF''						
                    WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'' OR CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'') THEN ''SCB''
			 WHEN ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) THEN ''ISW''
			
			 ELSE ''UNK''	
		
END,
	trxn_category=CASE WHEN (PT.PT_tran_type =''01'')  
							AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in (''1'',''4'')
                           AND PT.PTC_source_node_name = ''SWTMEGAsrc''
                           THEN ''ATM WITHDRAWAL (VERVE INTERNATIONAL)''
                           
                           WHEN ([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)
                           and PT.PT_tran_type =''50''  then ''MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)''

                           WHEN ([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)
                           and PT.PT_tran_type =''00'' and PT.PTC_source_node_name = ''VTUsrc''  then ''MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)''
                
                           WHEN ([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)
                           and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in (''2'',''5'',''6'')
                           then ''MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)''

                           WHEN ([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)
                           and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in (''3'')
                           then ''MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)''

                            WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and ( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, CreditAccNr_acc_nr ) =1)
                           AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN ''ATM WITHDRAWAL (Cardless:Paycode Verve Token)''
                           
                           WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and ( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, CreditAccNr_acc_nr ) =1)
                           AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN ''ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)''
                           
                           WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and ( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, CreditAccNr_acc_nr ) =1)
                           AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
                           THEN ''ATM WITHDRAWAL (Cardless:Non-Card Generated)''

						   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and (DebitAccNr_acc_nr  LIKE ''%ATM%ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%'')
                            AND PT.PTC_source_node_name NOT IN( ''SWTMEGAsrc'', ''ASPSPNOUsrc'')                           
                           THEN ''ATM WITHDRAWAL (MASTERCARD ISO)''


                           WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and ( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, CreditAccNr_acc_nr ) =1)
                           AND PT.PTC_source_node_name NOT IN( ''SWTMEGAsrc'', ''ASPSPNOUsrc'')
                           THEN ''ATM WITHDRAWAL (REGULAR)''
                           
                                                                     
                           WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 

                           and (( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, CreditAccNr_acc_nr)) !=1)
                           AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
                           THEN ''ATM WITHDRAWAL (VERVE BILLING)''

                           WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'')) 
                           and ( [dbo].[fn_rpt_sttl_brkdwn_4] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)
                           AND PT.PTC_source_node_name = ''ASPSPNOUsrc''
                           THEN ''ATM WITHDRAWAL (SMARTPOINT)''
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
                           (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) then ''BILLPAYMENT MASTERCARD BILLING''

                           WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' 
                           and (DebitAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'' or CreditAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'') ) 
                           AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then ''BILLPAYMENT IFIS REMITTANCE''
                          
			               WHEN ( dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'')  then ''BILLPAYMENT''
			   
			
                           WHEN (PT.PT_tran_type =''40''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' 

                           or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''4'')) THEN ''CARD HOLDER ACCOUNT TRANSFER''

                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN ''POS PURCHASE (Cardless:Paycode Verve Token)''
                           
                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN ''POS PURCHASE (Cardless:Paycode Non-Verve Token)''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''1''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                              or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, CreditAccNr_acc_nr ) =1)) THEN ''POS(GENERAL MERCHANT)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''2''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(CHURCHES, FASTFOODS & NGOS)''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''3''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(CONCESSION)PURCHASE''

                           WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''4''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(TRAVEL AGENCIES)PURCHASE''
                           

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''5''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(HOTELS)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''6''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(WHOLESALE)PURCHASE''
                    
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''14''
                            and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                            and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                            or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE''


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''7''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(FUEL STATION)PURCHASE''
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''8''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(EASYFUEL)PURCHASE''
                           
                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''1''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(TRAVEL AGENCIES-VISA)PURCHASE''
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''2''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(WHOLESALE CLUBS-VISA)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''3''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(GENERAL MERCHANT-VISA)PURCHASE''
                           

                           --WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''1''
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           --or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(GENERAL MERCHANT-VISA)PURCHASE''
                     
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''2''
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           --or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(2% CATEGORY-VISA)PURCHASE''
                           
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''3''
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           --or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(3% CATEGORY-VISA)PURCHASE''
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                              or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
                              
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = ''50'')
                            and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                              or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
                              
                              
                              WHEN (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name IN (''SWTWEBEBNsnk'',''SWTWEBUBAsnk'',''SWTWEBGTBsnk'',''SWTWEBABPsnk''))
                              and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                              and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                              AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
                              THEN ''WEB(GENERIC)PURCHASE''
                              
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''9''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) 
                           THEN ''WEB(GENERIC)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''10''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N200)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''11''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N300)PURCHASE''


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''12''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N150)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''13''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1.5% CAPPED AT N300)PURCHASE''
                       
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''15''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB COLLEGES ( 1.5% capped specially at 250)''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''16''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (PROFESSIONAL SERVICES)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''17''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (SECURITY BROKERS/DEALERS)PURCHASE''
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''18''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (COMMUNICATION)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''19''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N400)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''20''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N250)PURCHASE''
                  
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''21''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N265)PURCHASE''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''22''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N550)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''23''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''Verify card ? Ecash load''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''24''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''25''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''26''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_0.9%)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''27''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_1.25%)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''28''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Add_Card)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''30''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE''
                            
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''31''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT N50 CATEGORY)PURCHASE''        
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''32''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(2.5% CATEGORY)PURCHASE''
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''33''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(3.5% CATEGORY)PURCHASE''                 
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''34''
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1.2% CAPPED AT N2,000 CATEGORY)PURCHASE''                 
                            
                                                      
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_isNull_MCC_Visa (PT.PTC_merchant_type ,PT.PTC_terminal_id , PT.PT_tran_type ,PT.PTC_PAN ) =1
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)THEN ''POS(GENERAL MERCHANT)PURCHASE'' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)THEN ''POS PURCHASE WITH CASHBACK''

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and not ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1
                           or [dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1) THEN ''POS CASHWITHDRAWAL''

                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''


                           WHEN (PT.PT_tran_type = ''50'' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''
                           
                           WHEN (PT.PT_tran_type = ''50'' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all PTSPs''


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''



                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1)= ''3'' THEN ''WEB(GENERIC)PURCHASE''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
                                 and (DebitAccNr_acc_nr LIKE ''%fee%'' OR CreditAccNr_acc_nr LIKE ''%fee%'')
                                 and (PT.PT_tran_type in (''50'') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
                                 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'')) THEN ''AUTOPAY TRANSFER FEES''
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
                                 and (DebitAccNr_acc_nr NOT LIKE ''%fee%'' OR CreditAccNr_acc_nr NOT LIKE ''%fee%'')

                                 and PT.PT_tran_type in (''50'')
                                 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'')) THEN ''AUTOPAY TRANSFERS''
                                 
                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                           PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'' and PT.PT_extended_tran_type = ''6011'') THEN ''ATM CARDLESS-TRANSFERS''     

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'') THEN ''ATM TRANSFERS''

  WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''316'' and PT.PT_tran_type = ''50'')
                                   and (DebitAccNr_acc_nr LIKE ''%fee%'' OR CreditAccNr_acc_nr LIKE ''%fee%'') THEN ''AGENCY BANKING CASHOUT FEEs''
                                   
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''2'' and PT.PT_tran_type = ''50'') THEN ''POS TRANSFERS''
                           
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''4'' and PT.PT_tran_type = ''50'') THEN ''MOBILE TRANSFERS''

                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''35'' and PT.PT_tran_type = ''50'') then ''REMITA TRANSFERS''

       
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''31'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS''
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''32'' and PT.PT_tran_type = ''50'') then ''RELATIONAL TRANSFERS''
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''33'' and PT.PT_tran_type = ''50'') then ''SEAMFIX TRANSFERS''
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''34'' and PT.PT_tran_type = ''50'') then ''VERVE INTL TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''36'' and PT.PT_tran_type = ''50'') then ''PREPAID CARD UNLOAD''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''37'' and PT.PT_tran_type = ''50'' ) then ''QUICKTELLER TRANSFERS(BANK BRANCH)''
 
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''38'' and PT.PT_tran_type = ''50'') then ''QUICKTELLER TRANSFERS(SVA)''
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''39'' and PT.PT_tran_type = ''50'') then ''SOFTPAY TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''310'' and PT.PT_tran_type = ''50'') then ''OANDO S&T TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''311'' and PT.PT_tran_type = ''50'') then ''UPPERLINK TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER WEB TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''314''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER MOBILE TRANSFERS''
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''315'' and PT.PT_tran_type = ''50'') then ''WESTERN UNION MONEY TRANSFERS''

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''316'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(NON GENERIC PLATFORM)''
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''317'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(ACCESSBANK PORTAL)''
                                  
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'' AND CreditAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE''
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'' or CreditAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE DUE ISW''--the unk% is excempted from the bank''s net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= ''1'') then ''PREPAID CARDLOAD''

                          when PT.PT_tran_type = ''21'' then ''DEPOSIT''

                           /*WHEN (SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_6](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''Fees collected for all Terminal_owners''

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and ([dbo].[fn_rpt_sttl_brkdwn_7](DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1)) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                           and (DebitAccNr_acc_nr LIKE ''%ISO_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%ISO_FEE_RECEIVABLE'')) 
                           THEN ''FEES COLLECTED FOR ALL PTSPs''*/
                           
                          ELSE ''UNK''		

END,
  Debit_account_type=CASE 
                     /* WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTASPUBAsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
                      
                      WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTASPUBAsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''*/
                      
                     
                      
                      WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
                      
                      WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and   [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                          
                       WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1 
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''
                          
                     WHEN 
                      PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
                     (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and   [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                       THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
                      
                      WHEN 
                       PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                       
 [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                        
                        THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                          
                       WHEN 
                       PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      AND
                      [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                       THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''    
                        
                    WHEN                      
			        (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
                        AND  
			        (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                         THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''     
                        
                      WHEN 
                     PT.PT_sink_node_name = ''SWTWEBUBAsnk''  AND
                    (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
		             and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                     THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''

					WHEN 
                     PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
                     (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
					 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
		             THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''    
                           
                          
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  
 [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1 
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
                        
                      WHEN 
                     (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
                     (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and   [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''     
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
                        
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                     
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
                        
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and   [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1 
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
                        
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
                      (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and   [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''  
                      
                       
                      
                      WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Debit_Nr)''
	                  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Debit_Nr)''  
                          WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Debit_Nr)'' 
                          WHEN (DebitAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)''   
                          WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Debit_Nr)''  
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)'' 
                          WHEN (DebitAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'')THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''


                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''
                           
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)''
               
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)''

                          WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
                          AND NOT ((DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')OR (DebitAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Debit_Nr)''  
                          WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Debit_Nr)''  
                          WHEN (DebitAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Debit_Nr)''  
                          WHEN (DebitAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Debit_Nr)'' 
                          WHEN (DebitAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Debit_Nr)'' 
                          WHEN (DebitAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Debit_Nr)'' 
                          WHEN (DebitAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Debit_Nr)''

                         
                          WHEN (DebitAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Debit_Nr)''
                          WHEN (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Debit_Nr)''
                            
                          WHEN (DebitAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Debit_Nr)''  
			  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Debit_Nr)''
			  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Debit_Nr)''                      

                          ELSE ''UNK''			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTASPUBAsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTASPUBAsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTASPUBAsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''*/
                      
                       /* WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'' */
                         
                         
                      WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                          PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                      PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  
 [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
                           PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
                           
                     WHEN 
                      PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
                     (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  
 [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                       
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
                      
                      WHEN                      
			       (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
                        AND  
			        (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
                         THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      
                      WHEN 
                      PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
                      (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
		              and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
		            THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''

        
 
				WHEN 
                   PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
		          (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
 		           and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
                   AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
		           THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                     WHEN 
                     (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
                     (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      
                          THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                          
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                     
                     THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                        WHEN 
                      (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                     
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                       
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''    
                      
                      WHEN 
                     (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                      
                      THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
                      
                      WHEN 
                      (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
                      (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
                      and  [dbo].[fn_rpt_sttl_brkdwn_8] (PT_tran_type ,PTC_source_node_name ,PT_sink_node_name ,PT_payee, PTC_card_acceptor_id_code,PTC_totals_group,PTC_pan, PTC_terminal_id,PT_extended_tran_type,PT_message_type) =1
                     
                      THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
                                               
                          WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Credit_Nr)''
	                  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Credit_Nr)''  
                          WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)''   
                          WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Credit_Nr)''  
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)'' 

                          WHEN (CreditAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Credit_Nr)''
                           WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''


                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''


                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''
                           
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)''

                          WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
                          AND NOT ((CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Credit_Nr)''  
                          WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Credit_Nr)''  
                          WHEN (CreditAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Credit_Nr)''  
                          WHEN (CreditAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Credit_Nr)'' 
                          WHEN (CreditAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Credit_Nr)'' 
                          WHEN (CreditAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Credit_Nr)'' 

                          WHEN (CreditAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Credit_Nr)''
                         
                          WHEN (CreditAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Credit_Nr)''
                          WHEN (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Credit_Nr)''
                          
                          WHEN (CreditAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Credit_Nr)'' 
			  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Credit_Nr)''
			  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Credit_Nr)''

                          ELSE ''UNK''			
END,

       trxn_amount=ISNULL(J.amount,0),
	trxn_fee=ISNULL(J.fee,0),
	trxn_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
                           (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) THEN ''840''
                        WHEN (([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1) and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTUBAsnk'',''SWTJBPsnk'',''SWTJAIZsnk'',''SWTFCMBsnk'',''SWTUBNsnk'',''SWTUBNCCsnk''))) THEN ''840''
						WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'') ) THEN ''840''
						WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'') ) THEN ''840''
						WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk'',''SWTGTBSNK''))) THEN ''840''
						WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk'',''SWTGTBSNK''))) THEN ''840''
					    ELSE PT.PT_settle_currency_code END,
        late_reversal = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
                               and PT.PTC_merchant_type in (''5371'',''2501'',''2504'',''2505'',''2506'',''2507'',''2508'',''2509'',''2510'',''2511'') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
        terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
        source_node_name =   PT.PTC_source_node_name,
        Unique_key = PT.PT_retrieval_reference_nr+''_''+PT.PT_system_trace_audit_nr+''_''+PT.PTC_terminal_id+''_''+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(20))+''_''+PT.PT_message_type,
Acquirer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
                      when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) AND 
                      ( pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock))) then  (SELECT  TOP 1 bank_code  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock))) 
                      else PT.PT_acquiring_inst_id_code END),
        Issuer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
                      when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) and (substring(PT.PTC_totals_group,1,3) = (SELECT  TOP 1 bank_code1  FROM  aid_cbn_code (nolock) 
                      WHERE pt.PT_acquiring_inst_id_code  
                      IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5)
                       from aid_cbn_code (nolock))))
                     then (SELECT  TOP 1 bank_code  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock))
                                           )
                         else substring(PT.PTC_totals_group,1,3) END),
       Volume = (case when PT.PT_message_type in (''0200'',''0220'') then 1
	                   else 0 end),  
           Value_RequestedAmount = PT.PT_settle_amount_req,
           Value_SettleAmount = PT.PT_settle_amount_impact,
		   	PT.pt_post_tran_id,
					source_node_name =   PT.PTC_source_node_name,
					sink_node_name =   PT.PT_sink_node_name,	
           Miscellaneous = (case when PT.PTC_totals_group = ''FBPVRVCCGrp'' then ''Gift_Card'' else ''1'' end),
		   index_no =  Row_Number() OVER (ORDER BY (SELECT 1))
		   
			
				FROM 
				(select  [adj_id]
				,[entry_id]
				,[config_set_id]
				,[session_id]
				,j1.[post_tran_id]
				,[post_tran_cust_id]
				,[sdi_tran_id]
				,[acc_post_id]
				,[nt_fee_acc_post_id]
				,[coa_id]
				,[coa_se_id]
				,[se_id]
				,[amount]
				,[amount_id]
				,[amount_value_id]
				,[fee]
				,[fee_id]
				,[fee_value_id]
				,[nt_fee]
				,[nt_fee_id]
				,[nt_fee_value_id]
				,[debit_acc_nr_id]
				,[debit_acc_id]
				,[debit_cardholder_acc_id]
				,[debit_cardholder_acc_type]
				,[credit_acc_nr_id]
				,[credit_acc_id]
				,[credit_cardholder_acc_id]
				,[credit_cardholder_acc_type]
				,[business_date]
				,[granularity_element]
				,[tag]
				,[spay_session_id]
				,[spst_session_id]
				,[DebitAccNr_config_set_id]
				,[DebitAccNr_acc_nr_id]
				,[DebitAccNr_se_id]
				,[DebitAccNr_acc_id]
				,[DebitAccNr_acc_nr]
				,[DebitAccNr_aggregation_id]
				,[DebitAccNr_state]
				,[DebitAccNr_config_state]
				,[CreditAccNr_config_set_id]
				,[CreditAccNr_acc_nr_id]
				,[CreditAccNr_se_id]
				,[CreditAccNr_acc_id]
				,[CreditAccNr_acc_nr]
				,[CreditAccNr_aggregation_id]
				,[CreditAccNr_state]
				,[CreditAccNr_config_state]
				,[Amount_config_set_id]
				,[Amount_amount_id]
				,[Amount_se_id]
				,[Amount_name]
				,[Amount_description]
				,[Amount_config_state]
				,[Fee_config_set_id]
				,[Fee_fee_id]
				,[Fee_se_id]
				,[Fee_name]
				,[Fee_description]
				,[Fee_type]
				,[Fee_amount_id]
				,[Fee_config_state]
				,[coa_config_set_id]
				,[coa_coa_id]
				,[coa_name]
				,[coa_description]
				,[coa_type]
				,[coa_config_state]

 FROM ['+@JOURNAL_TABLE_MARKER+'] J1 WITH (NOLOCK) 
				WHERE post_tran_id  IN ( SELECT  post_tran_id FROM  temp_post_tran_id_range_table  t1 WITH (NOLOCK)  where  THREAD_ID  = '+@CURRENT_THREAD_NUMBER+' ))J
				JOIN 
				
				(SELECT * FROM   ['+@TRANSACTION_TABLE_MARKER+'] tm WITH (NOLOCK) 
					WHERE pt_post_tran_id  IN ( SELECT  post_tran_id FROM  temp_post_tran_id_range_table  t1 WITH (NOLOCK)  where  THREAD_ID  = '+@CURRENT_THREAD_NUMBER+' )    AND tm.PT_tran_postilion_originated =0
				 )   PT 
				ON (J.post_tran_id = PT.PT_post_tran_id )
				LEFT   JOIN 
				(SELECT  PT_post_tran_id,PT_post_tran_cust_id,ptc_terminal_id,PT_tran_nr, PT_retention_data FROM ['+@TRANSACTION_TABLE_MARKER+']  WITH (NOLOCK) WHERE PT_tran_postilion_originated =1  and  pt_post_tran_cust_id  IN ( SELECT  post_tran_cust_id FROM  temp_post_tran_id_range_table  t1 WITH (NOLOCK)  where  THREAD_ID  = '+@CURRENT_THREAD_NUMBER+' )   )PTT 
				ON
				(PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id  and PT.PT_tran_nr = PTT.PT_tran_nr)  

					WHERE

					  (
          (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in (''0200'',''0220''))

       or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1 and PT.PT_tran_reversed <> 2)
       or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))

       or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in (''0200'',''0220'') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN (''0'',''1'') ))
       or (PT.PT_message_type = ''0420'' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( ''0'',''1'' ))))
     

      AND not (pt.PTC_merchant_type in (''4004'',''4722'') and PT.PT_tran_type = ''00'' and pt.PTC_source_node_name not in (''VTUsrc'',''CCLOADsrc'') and  abs(PT.PT_settle_amount_impact/100)< 200
       and not ([dbo].[fn_rpt_sttl_brkdwn_3] (DebitAccNr_acc_nr, @CreditAccNr_acc_nr ) =1))

      AND pt.PTC_totals_group <>''CUPGroup''
      and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_acquiring_inst_id_code = ''627787'')
	  and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_sink_node_name not in (''ASPPOSVINsnk'')
	            and not (pt.ptc_source_node_name in (''SWTFBPsrc'',''SWTUBAsrc'',''SWTZIBsrc'',''SWTPLATsrc'') and PT.PT_sink_node_name = ''ASPPOSVISsnk'') 
	           )
     and not (PT.ptc_source_node_name  = ''MEGATPPsrc'' and PT.PT_tran_type = ''00'')
      
 OPTION (RECOMPILE, optimize for unknown,maxdop 4)
														')
														
end						
														