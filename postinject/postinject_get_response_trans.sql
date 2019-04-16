USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_get_response_trans]    Script Date: 06/04/2014 13:39:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_get_response_trans                       
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_get_response_trans]
	@interchange_name			VARCHAR(20),
	@msg_injector_class_name	VARCHAR(200),
	@transmission_id			VARCHAR(10),
	@report_rsp_messages		INT,
	@last_tran_id				VARCHAR(10),
	@nr_of_transactions			VARCHAR(10)
AS
BEGIN

	DECLARE	@sql_query				VARCHAR(1000),
		@sql_query2					VARCHAR(1000),
		@last_tran_id_int			INT, 
		@nr_of_transactions_int		INT, 
		@highest_tran_id_int		INT, 
		@highest_tran_id	        VARCHAR(10)
            
        SELECT 	@last_tran_id_int = CONVERT(INT, @last_tran_id),
        @nr_of_transactions_int = 	CONVERT(INT, @nr_of_transactions)
          
	IF (@last_tran_id_int = -1)
	BEGIN
		SELECT  @highest_tran_id_int = MIN(id)
		FROM    inject_trans
		WHERE   inject_trans.interchange_name = @interchange_name
		AND     inject_trans.msg_injector_class_name = @msg_injector_class_name
		AND     inject_trans.transmission_id = @transmission_id
	    
		IF (@highest_tran_id_int IS NOT NULL)
		BEGIN
			SELECT  @highest_tran_id_int = @highest_tran_id_int + @nr_of_transactions
		END
		ELSE
		BEGIN
		    --No records for this transmission id, so set it to 0
			SELECT @highest_tran_id_int = 0
		END	    
	END
	ELSE
	BEGIN
	    SELECT  @highest_tran_id_int =  @last_tran_id_int + @nr_of_transactions_int
	END
		
	SELECT  @highest_tran_id =  CONVERT(VARCHAR(10), @highest_tran_id_int)
		
	SELECT 	@sql_query = 
		'SELECT inject_trans.id,'+
			'inject_trans.msg_type,'+
			'inject_trans.rsp_fields,'+
			'inject_trans.rsp_struct_data,'+
			'inject_trans.rsp_icc '+
		'FROM 	inject_trans '+
		'WHERE 	inject_trans.interchange_name = ''' +  @interchange_name + ''' ' +
		'AND	inject_trans.msg_injector_class_name = ''' + @msg_injector_class_name + ''' ' +
		'AND 	inject_trans.transmission_id = ' +  @transmission_id + ' ' +
		'AND	inject_trans.id > ' + @last_tran_id + ' ' +
		'AND	inject_trans.id < ' + @highest_tran_id	 

	SELECT @sql_query2 = 
		'SELECT inject_trans.id,'+
			'inject_trans.msg_type,'+
			'inject_trans.req_fields,'+
			'inject_trans.req_struct_data,'+
			'inject_trans.req_icc '+
		'FROM 	inject_trans '+
		'WHERE 	inject_trans.interchange_name = ''' +  @interchange_name + ''' ' +
		'AND	inject_trans.msg_injector_class_name = ''' + @msg_injector_class_name + ''' ' +
		'AND 	inject_trans.transmission_id = ' +  @transmission_id + ' ' +
		'AND	inject_trans.id > ' + @last_tran_id + ' ' +
		'AND	inject_trans.id < ' + @highest_tran_id	 
		
	IF (@report_rsp_messages = 2) 
	BEGIN
		--all approved transactions must be returned. 
		--when a not approved response is received with this user param
		--setting, rsp_fields will be set to null, so 
		--the SQL query should check this as well
		SELECT 	@sql_query = @sql_query + ' ' +
		'AND 	inject_trans.state = 1 AND inject_trans.rsp_fields IS NOT NULL'
        END
	ELSE IF (@report_rsp_messages = 4) 
	BEGIN
		--all completed transactions must be returned
		SELECT 	@sql_query = @sql_query + ' ' +
		'AND 	inject_trans.state = 1 '
        END
	ELSE IF (@report_rsp_messages = 1) 
	BEGIN
		--all transactions (also undelivered ones) must be returned
		SELECT 	@sql_query = @sql_query + ' ' +
		'AND inject_trans.state = 1 ' + 'UNION ALL ' + 
		@sql_query2 + ' ' + 
		'AND inject_trans.state = 2 '
	
	END
	ELSE IF (@report_rsp_messages = 3) 
	BEGIN

		--unsuccessfull transactions must be returned (also undelivered ones). 
		--when a not approved response is received with this user param
		--setting, rsp_fields will be set to null, so 
		--the SQL query should check this as well
		SELECT 	@sql_query = @sql_query + ' ' +
		'AND inject_trans.state = 1 AND inject_trans.rsp_fields IS NOT NULL UNION ALL ' + 
		@sql_query2 + ' ' + 
		'AND inject_trans.state = 2 '
	END

	
	EXEC (@sql_query + ' ORDER 	BY inject_trans.id')
END

GO


