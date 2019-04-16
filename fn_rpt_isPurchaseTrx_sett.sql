USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx_sett]    Script Date: 04/29/2015 20:55:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER                FUNCTION  [dbo].[fn_rpt_isPurchaseTrx_sett] (@tran_type CHAR (2),@source_node_name VARCHAR (10),@sink_node_name VARCHAR (10))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '02' AND '19') OR @tran_type in ('00','01') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk')) 
		SET @r = 1

        ELSE IF @tran_type = '00' 
        and ((@source_node_name = 'VTUsrc') or (@sink_node_name = 'VTUsnk'))
                set @r = 2
    

	ELSE
		SET @r = 0
	RETURN @r
END























