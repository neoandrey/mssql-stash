CREATE FUNCTION [dbo].[fn_rpt_isBillpayment] (@terminal_id CHAR (8),@extended_tran_type CHAR (4),@message_type CHAR (4),@sink_node_name varchar(20),
@payee varchar(100), @card_acceptor_id_code varchar (100),@source_node_name varchar(20),@tran_type varchar (10),@pan VARCHAR (30))
RETURNS INT
AS
BEGIN
DECLARE @r INT
	if ( 
	(@sink_node_name = 'PAYDIRECTsnk' or 
	(
	(
	  @source_node_name = 'BILLSsrc' OR  CHARINDEX( '62805150',  @payee) > 0 )
	AND
	 @sink_node_name <> 'BILLSsnk' and  CHARINDEX('QuickTeller',@card_acceptor_id_code ) > 0   
	 )

	)
	OR 
	(@sink_node_name <> 'BILLSsnk'
	AND
		@terminal_id IN (
			'3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001',
			'2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001',
			'4FMM0001','3EBM0001','4CLT0001','4FDM0001','3HIB0001','4RBX0001'
		)
	)
	OR
	(@terminal_id = '3BOL0001' and @sink_node_name <> 'BILLSsnk' and @tran_type = '50'
	 AND (@extended_tran_type 
	 <> '8502'or @extended_tran_type is NULL) 
	)
	OR
	( LEFT(@terminal_id,1) = '2' AND @extended_tran_type = '8500' AND @message_type = '0200')
	OR
	(@card_acceptor_id_code ='QUICKTELLERBILL' and @tran_type ='00' and   LEFT(@pan,1) =  '4'))

	AND
 	@source_node_name <>'VTUsrc'
	AND
	@sink_node_name <> 'VTUsnk'
	AND
	@tran_type NOT IN ('31', '39', '32')

	SET @r = '1'

	ELSE
	SET @r = 0
	RETURN @r
end