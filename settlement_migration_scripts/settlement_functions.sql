USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_CardType]    Script Date: 05/09/2016 11:04:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE                  FUNCTION  [dbo].[fn_rpt_CardType] (@PAN VARCHAR (30),@SINK_NODE_NAME VARCHAR (30),@TRAN_TYPE CHAR (2),@TERMINAL_ID CHAR(8))
	
RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ( LEFT(@pan,3) = '506'  or  LEFT(@pan,6) IN ( '539945',  '521090', '519615' ,'528668','519909','559453','528649','551609')) AND @TRAN_TYPE = '01'
	  BEGIN
        IF  @SINK_NODE_NAME NOT IN( 'SWTEBNsnk','SWTEBNCCsnk', 'SWTFBNsnk','SWTFBNCCsnk','SWTOBIsnk','SWTOBICCsnk','SWTPRUsnk','SWTPRUCCsnk') 
           SET @r = 1

        ELSE IF  @SINK_NODE_NAME IN( 'SWTEBNsnk','SWTEBNCCsnk','SWTOBIsnk','SWTOBICCsnk') 
           SET @r = 2
        
        ELSE IF  @SINK_NODE_NAME IN( 'SWTFBNsnk','SWTFBNCCsnk') 
           SET @r = 3
    END 
        ELSE  IF  NOT (( LEFT(@pan,3) = '506'  or  LEFT(@pan,6) IN ( '539945',  '521090', '519615' ,'528668','519909','559453','528649','551609')) AND @TRAN_TYPE = '01')--or @pan like '63958%' and @terminal_id not like '1ATM%' and @terminal_id not like '1085%')
            BEGIN
 			 IF  (@SINK_NODE_NAME NOT IN( 'SWTGTBsnk','SWTGTBCCsnk','SWTFBNsnk','SWTFBNCCsnk','SWTUBAsnk','SWTUBACCsnk','SWT3LCMsnk')) 
       
                SET @r = 4

      ELSE IF @SINK_NODE_NAME IN( 'SWT3LCMsnk') 
               AND @TRAN_TYPE = 01
		SET @r = 5

       ELSE IF  @SINK_NODE_NAME IN( 'SWTFBNsnk','SWTFBNCCsnk') 
              
		SET @r = 6

       ELSE IF @SINK_NODE_NAME IN( 'SWTGTBsnk','SWTGTBCCsnk') 
               AND @TRAN_TYPE = 01
		SET @r = 7

       ELSE IF  @SINK_NODE_NAME IN( 'SWTUBAsnk','SWTUBACCsnk') 
               AND @TRAN_TYPE = 01
		SET @r = 8

       ELSE IF
         @SINK_NODE_NAME IN( 'SWTPRUsnk','SWTPRUCCsnk') 
           SET @r = 10
END
                
	ELSE BEGIN
		SET @r = 9
		END
	RETURN @r
END


GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx_sett_cashback]    Script Date: 05/09/2016 11:04:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett_cashback] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10),
                                                              @terminal_id VARCHAR (15),@totals_group VARCHAR (50),@pan VARCHAR (50) )
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	set @r = 0;
	
	IF  @tran_type in ('09') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and    (left(@terminal_id,1)  NOT in ('2','5','6') 
		and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc')) 
		 AND  NOT (@sink_node_name ='ASPPOSLMCsnk'  AND LEFT(@totals_group,3)  in ( 'AFR','CIT','ABP','DBL') 
		AND  LEFT(@pan,1) != '4'))
		SET @r = 1

else IF  @tran_type in ('01') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and    (left(@terminal_id,1) NOT in ('2','5','6') and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc')
		AND  NOT (@sink_node_name ='ASPPOSLMCsnk' AND LEFT(@totals_group,3) in ('AFR','CIT','ABP','DBL') AND  LEFT(@pan,1) != '4'))
		SET @r = 2

	ELSE
		SET @r = 0
	RETURN @r
END

 



GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_late_reversal]    Script Date: 05/09/2016 11:04:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION  [dbo].[fn_rpt_late_reversal] 

  (@tran_nr bigint,@message_type char (4),@retrieval_reference_nr varchar(20))
	RETURNS varchar
AS
BEGIN
	DECLARE @r varchar
		SET @r  ='0';
    IF(@message_type= '0420') BEGIN
		IF  EXISTS(select  post_tran_id from tbl_late_reversals(NOLOCK)  WHERE  tran_nr =@tran_nr  AND  retrieval_reference_nr =@retrieval_reference_nr )
			BEGIN
			SET @r = '1'
		END
		end
	ELSE
	 BEGIN
		SET @r = '0'
   end
	RETURN @r
	
END
GO



/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx_sett_2]    Script Date: 05/09/2016 11:04:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett_2] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '10' AND '19')OR @tran_type in ( SELECT part FROM usf_split_string('00,02,03,04,05,06,07,08', ',')) 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk')) )

        --and  NOT  (left(@terminal_id,1) in ('2','5','6') and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND @sink_node_name+LEFT(@totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(@pan,1) = '4'))
		SET @r = 1

        ELSE IF @tran_type = '00' 
        and ((@source_node_name = 'VTUsrc') or (@sink_node_name = 'VTUsnk'))
                set @r = 2
    

	ELSE
		SET @r = 0
	RETURN @r
END





GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx_sett]    Script Date: 05/09/2016 11:04:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











CREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10),
                                                              @terminal_id VARCHAR (15),@totals_group VARCHAR (50),@pan VARCHAR (50) )
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '10' AND '19') OR @tran_type in ( SELECT part FROM usf_split_string('00,02,03,04,05,06,07,08', ',')) 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk')) )
        and substring(@terminal_id,1,4) <> '3IAP'

        --and  NOT  (left(@terminal_id,1) in ('2','5','6') and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND @sink_node_name+LEFT(@totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(@pan,1) = '4'))
		SET @r = 1

        ELSE IF @tran_type = '00' 
        and ((@source_node_name = 'VTUsrc') or (@sink_node_name = 'VTUsnk'))
                set @r = 2
    

	ELSE
		SET @r = 0
	RETURN @r
END




























GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx]    Script Date: 05/09/2016 11:04:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





CREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '02' AND '19') OR @tran_type = '00' OR @tran_type = '50' OR (@tran_type BETWEEN '52' AND '59'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END




GO


