
cREATE FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett_cashback_3] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10),
                                                              @terminal_id VARCHAR (15),@totals_group VARCHAR (50),@pan VARCHAR (50) )
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	set @r =0;
	
	IF(@tran_type in ('09','01')) BEGIN

        IF (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk'))  and  NOT  (left(@terminal_id,1) in ('2','5','6') and (@source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND (@sink_node_name <> 'ASPPOSLMCsnk'  and  LEFT(@totals_group,3)
            not in ('AFR','CIT','ABP','DBL')) AND  substring(@pan,1,1) = '4'))BEGIN
                               
                               	IF  (@tran_type  =  '09' ) BEGIN
		SET @r = 1
END
else IF  (@tran_type = '01'  ) begin
      
		SET @r = 2
		END
 END
	
	END
	return @r
END

