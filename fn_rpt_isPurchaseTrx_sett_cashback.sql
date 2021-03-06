USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx_sett_cashback]    Script Date: 05/03/2016 13:02:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






CREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett_cashback] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10),
                                                              @terminal_id VARCHAR (15),@totals_group VARCHAR (50),@pan VARCHAR (50) )
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF  @tran_type in ('09') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and    (left(@terminal_id,1)  NOT in ('2','5','6') 
		and (@source_node_name in (SELECT part FROM usf_split_string('SWTNCS2src,SWTSHOPRTsrc,SWTNCSKIMsrc', ',')) 
		 AND  NOT (@sink_node_name ='ASPPOSLMCsnk'  AND LEFT(@totals_group,3)  in ( SELECT part FROM usf_split_string('AFR,CIT,ABP,DBL', ','))) 
		AND  LEFT(@pan,1) != '4'))
		SET @r = 1

else IF  @tran_type in ('01') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and    (left(@terminal_id,1) NOT in ('2','5','6') and (@source_node_name in (SELECT part FROM usf_split_string('SWTNCS2src,SWTSHOPRTsrc,SWTNCSKIMsrc',','))
		AND  NOT (@sink_node_name ='ASPPOSLMCsnk' AND LEFT(@totals_group,3) in (SELECT part FROM usf_split_string('AFR,CIT,ABP,DBL',',' ))) AND  LEFT(@pan,1) != '4'))
		SET @r = 2

	ELSE
		SET @r = 0
	RETURN @r
END

=========================old====================================================


BEGIN
	DECLARE @r INT
	IF  @tran_type in ('09') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and  NOT  (left(@terminal_id,1) in ('2','5','6') and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') 
		AND @sink_node_name+LEFT(@totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(@pan,1) = '4'))
		SET @r = 1

else IF  @tran_type in ('01') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))

        and  NOT  (left(@terminal_id,1) in ('2','5','6') 
		and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND @sink_node_name+LEFT(@totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(@pan,1) !='4'))
		SET @r = 2

	ELSE
		SET @r = 0
	RETURN @r
END






















