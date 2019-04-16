USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_get_trans]    Script Date: 06/04/2014 13:39:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_get_trans.                          
-------------------------------------------------------------------------------- 

CREATE PROCEDURE [dbo].[postinject_get_trans]
	@interchange_name	VARCHAR(20),
	@nr_of_transactions	VARCHAR(10),
	@forward_date_messages	INT,
	@unsent_only		BIT = NULL
AS
BEGIN

	DECLARE	@sql_query		VARCHAR(1000),
		@top_sql_query		VARCHAR(500),
		@top_unsent_filter	VARCHAR(50)
		
	IF(@unsent_only=1)
	BEGIN
		SELECT @top_unsent_filter=' AND inject_trans.time_sent IS NULL '
	END
	ELSE
	BEGIN
		SELECT @top_unsent_filter=''
	END
	
	SELECT	@top_sql_query = 
		'SELECT TOP ' + @nr_of_transactions + ' id ' +
		'FROM 	inject_trans ' +
		'WHERE inject_trans.interchange_name = ''' +  + @interchange_name + ''' ' +
		'AND inject_trans.state = 0 ' +
		@top_unsent_filter
		
		
	IF @forward_date_messages = 1 
	
	BEGIN
		SELECT @top_sql_query = @top_sql_query +
		'AND ((transmission_date_time IS NULL) OR ' +
		     '(datediff(dayofyear, inject_trans.transmission_date_time, GETDATE()) > 0) OR ' +
		     '(datediff(dayofyear, inject_trans.transmission_date_time, GETDATE()) = 0 AND ' +
		      		'datediff(hour, inject_trans.transmission_date_time, GETDATE()) >= 0))'
	
	END
	
	SELECT 	@sql_query = 
		'SELECT inject_trans.msg_injector_class_name,'+
			'inject_trans.id,'+
			'inject_trans.nr_sent,'+
			'inject_trans.msg_type,'+
			'inject_trans.req_fields,'+
			'inject_trans.req_struct_data,'+
			'inject_trans.req_icc '+
		'FROM 	inject_trans '+
		'WHERE 	inject_trans.id IN (' + @top_sql_query	+') '+
		'ORDER 	BY inject_trans.id'

	EXEC (@sql_query)

END

GO


