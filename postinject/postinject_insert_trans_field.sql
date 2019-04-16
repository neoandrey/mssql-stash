USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_insert_trans_field]    Script Date: 06/04/2014 13:41:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_insert_trans_field]
	@id				BIGINT,
	@bitmap_field_nr		INT,
	@private_bitmap_field_nr	INT,
	@value				VARCHAR(255),
	@struct_value			TEXT,
	@response_value			INT

AS
BEGIN

	IF @bitmap_field_nr > 0 
	
	BEGIN
	
		INSERT INTO inject_trans_field
		(
			id,			
			bitmap_field_nr,
			value, 
			response_value
		)
		VALUES 
		(
			@id,			
			@bitmap_field_nr,
			@value				,
			@response_value	
		)
	
	END
	
	ELSE IF @private_bitmap_field_nr = 22 OR @private_bitmap_field_nr = 25
	
	BEGIN
	
		INSERT INTO inject_trans_field
		(
			id,			
			private_bitmap_field_nr,
			struct_value,
			response_value
		)
		VALUES 
		(
			@id,			
			@private_bitmap_field_nr,
			@struct_value,
			@response_value	
		)	
	
	END
	
	ELSE
	
	BEGIN
	
		INSERT INTO inject_trans_field
		(
			id,			
			private_bitmap_field_nr,
			value,
			response_value
		)
		VALUES 
		(
			@id,			
			@private_bitmap_field_nr,
			@value,
			@response_value	
		)
		
	END

END

GO


