ALTER              FUNCTION  [dbo].[fn_rpt_isBillpayment] (@terminal_id CHAR (8),@extended_tran_type CHAR (4),@message_type CHAR (4),@sink_node_name varchar(20),
                                                        @payee varchar(100), @card_acceptor_id_code varchar (100),@source_node_name varchar(20),@tran_type varchar (10))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	if ( 
	    (@sink_node_name = 'PAYDIRECTsnk' or (( CHARINDEX ( '62805150', @payee ) >0  or @source_node_name = 'BILLSsrc')and @sink_node_name <> 'BILLSsnk' and  CHARINDEX('QuickTeller', @card_acceptor_id_code) > 0 ))
				OR 
				(@terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4CLT0001','4FDM0001','3HIB0001','4RBX0001')and @sink_node_name <> 'BILLSsnk')
				OR
                                (@terminal_id = '3BOL0001' and (@extended_tran_type <> '8502'or @extended_tran_type is NULL) and @sink_node_name <> 'BILLSsnk' and @tran_type = '50')
                                OR
				( LEFT(@terminal_id,1)='2' AND @extended_tran_type = '8500' AND @message_type = '0200')
				)
				                                
                                AND
				@source_node_name NOT IN ( 'VTUsrc')
				AND
				@sink_node_name NOT IN ( 'VTUsnk')
                                AND
			        @tran_type NOT IN ('31', '39', '32')

				
				
		SET @r = '1'
        
	ELSE
		SET @r = 0
	RETURN @r

END
--
-- Returns 1 if the transaction type is a non-deposit credit transaction type
--

ALTER  FUNCTION  [dbo].[fn_rpt_isCreditTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((CONVERT(INT, @tran_type) = 20) OR (CONVERT(INT, @tran_type) >= 25 AND CONVERT(INT, @tran_type) <=29))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isInquiryTrx]    Script Date: 04/29/2015 20:42:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER    FUNCTION  [dbo].[fn_rpt_isInquiryTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (CONVERT(INT, @tran_type) >= 30 AND CONVERT(INT, @tran_type)<=39)
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END



ALTER    FUNCTION  [dbo].[fn_rpt_isOtherTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (CONVERT(INT, @tran_type) >= 60 AND CONVERT(INT, @tran_type) <='99')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END


ALTER      FUNCTION  [dbo].[fn_rpt_isPurchaseTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((CONVERT(INT, @tran_type) >= 2 AND CONVERT(INT, @tran_type)<=19) OR @tran_type = '00')-- OR @tran_type = '50' OR (@tran_type BETWEEN '52' AND '59'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END


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
	IF (CONVERT(INT, @tran_type) >= 2 AND CONVERT(INT, @tran_type) <= 19) OR @tran_type in ('00','01') 
        and (@source_node_name not in ('VTUsrc','CCLOADsrc') and @sink_node_name not in ('VTUsnk','CCLOADsnk')) 
		SET @r = 1

        ELSE IF @tran_type = '00' 
        and ((@source_node_name = 'VTUsrc') or (@sink_node_name = 'VTUsnk'))
                set @r = 2
    

	ELSE
		SET @r = 0
	RETURN @r
END




USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isTransferTrx]    Script Date: 04/29/2015 21:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER    FUNCTION  [dbo].[fn_rpt_isTransferTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (CONVERT(INT, @tran_type) >= 40 AND  CONVERT(INT, @tran_type)<= 49)
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END






alter  FUNCTION  dbo.fn_rpt_isPurchaseTrx (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((CONVERT( INT, @tran_type)  >= 2 AND CONVERT( INT, @tran_type) <=19 ) OR @tran_type = '00' OR @tran_type = '50'  OR (CONVERT( INT, @tran_type)  >= 52 AND CONVERT( INT, @tran_type) <=59 ))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END























