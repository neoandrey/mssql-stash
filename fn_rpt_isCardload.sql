USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCardload]    Script Date: 04/29/2015 17:15:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER            FUNCTION  [dbo].[fn_rpt_isCardload] (@source_node_name varchar(20),@pan char(7), @tran_type char(2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	if (@source_node_name = 'CCLOADsrc')
				 OR
				(LEFT(@pan,7)= '6280512' and @tran_type =21)
				
		SET @r = '1'
        
	ELSE
		SET @r = 0
	RETURN @r
END


