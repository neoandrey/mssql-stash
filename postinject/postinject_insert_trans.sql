USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_insert_trans]    Script Date: 06/04/2014 13:41:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_insert_trans                       
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_insert_trans]
	@interchange_name			VARCHAR(20),
	@msg_injector_class_name	VARCHAR(200),
	@transmission_id			BIGINT,
	@msg_type					INT,
	@switch_key					VARCHAR(32),
	@original_key				VARCHAR(32),
	@local_date					CHAR(4),
	@local_time					CHAR(6),
	@pan						VARCHAR(19),
	@card_seq_nr				CHAR(2),
	@tran_type					CHAR(2),
	@from_account				CHAR(2),
	@to_account					CHAR(2),
	@tran_amount				FLOAT,
	@card_acceptor_id_code		CHAR(15),
	@card_acceptor_terminal_id	CHAR(8),
	@transmission_date_time		DATETIME,
    @req_fields                 VARCHAR(3500),
    @req_struct_data            TEXT,
    @req_icc                    TEXT
	
AS
BEGIN

	IF @switch_key IS NOT NULL
	
	BEGIN

		INSERT INTO inject_trans 
		(
			interchange_name,		
			msg_injector_class_name,
			transmission_id,
			msg_type,
			switch_key,	
			original_key,	
			local_date,		
			local_time,			
			pan,				
			card_seq_nr,			
			tran_type,		
			from_account,			
			to_account,		
			tran_amount,		
			card_acceptor_id_code,	
			card_acceptor_terminal_id,
			transmission_date_time,
       		req_fields,
        	req_struct_data,
        	req_icc,
        	rsp_fields,
        	rsp_struct_data,
        	rsp_icc
		)
		VALUES 
		(
			@interchange_name,	
			@msg_injector_class_name,
			@transmission_id,
			@msg_type,		
			@switch_key,	
			@original_key,	
			@local_date,		
			@local_time,			
			@pan,				
			@card_seq_nr,				
			@tran_type,		
			@from_account,			
			@to_account,		
			@tran_amount,		
			@card_acceptor_id_code,	
			@card_acceptor_terminal_id,
			@transmission_date_time,
		    @req_fields,                     
		    @req_struct_data,
		    @req_icc,
			NULL,
			NULL,
			NULL         
		)
	
	END
	
	ELSE
	
	BEGIN
	
		INSERT INTO inject_trans 
		(
			interchange_name,
			msg_injector_class_name,
			transmission_id,
			msg_type,
			switch_key,	
			original_key,	
			local_date,		
			local_time,			
			pan,				
			card_seq_nr,			
			tran_type,		
			from_account,			
			to_account,		
			tran_amount,		
			card_acceptor_id_code,	
			card_acceptor_terminal_id,
			transmission_date_time,
       		req_fields,
        	req_struct_data,
        	req_icc,
        	rsp_fields,
        	rsp_struct_data,
        	rsp_icc	
		)
		VALUES 
		(
			@interchange_name,	
			@msg_injector_class_name,
			@transmission_id,
			@msg_type,		
			NULL,	
			@original_key,	
			@local_date,		
			@local_time,			
			@pan,				
			@card_seq_nr,				
			@tran_type,		
			@from_account,			
			@to_account,		
			@tran_amount,		
			@card_acceptor_id_code,	
			@card_acceptor_terminal_id,
			@transmission_date_time,
		    @req_fields,                     
		    @req_struct_data,
		    @req_icc,
			NULL,
			NULL,
			NULL   
		)		
	END
	
	DECLARE @l_tran_id AS BIGINT
	SET @l_tran_id = SCOPE_IDENTITY()

	SELECT @l_tran_id
END

GO


