

CREATE PROCEDURE [dbo].[osp_rpt_crystal_template_insert]

	@template_name VARCHAR(255),

	@category VARCHAR(30),

	@template VARCHAR(255),

	@user_params_defs VARCHAR(MAX),

	@template_id INT OUTPUT,

	@template_id_in INT = NULL

AS

BEGIN
/*
	IF @template_id_in IS NULL

	BEGIN

		SET @template_id = dbo.ofn_checksum('Crystal:' + @template)

	END

	ELSE

	BEGIN

		SET @template_id = @template_id_in

	END

 

	BEGIN TRANSACTION

 

	IF EXISTS (

		SELECT *

		FROM reports_template

		WHERE template_id = @template_id

	)

	BEGIN

		UPDATE reports_template

		SET template_name = @template_name, category = @category

		WHERE template_id = @template_id

	END

	ELSE

	BEGIN

		INSERT INTO reports_template (template_id, plugin_id, template_name, category)

		VALUES(@template_id, 'Crystal', @template_name, @category)

	END

 

	IF EXISTS (

		SELECT *

		FROM reports_crystal_template

		WHERE template_id = @template_id

	)

	BEGIN

		UPDATE reports_crystal_template

		SET user_params_defs = @user_params_defs, template = @template

		WHERE template_id = @template_id

	END

	ELSE

	BEGIN

		INSERT INTO reports_crystal_template (template_id, template, user_params_defs)

		VALUES (@template_id, @template, @user_params_defs)

	END
*/
 

	COMMIT TRANSACTION

END


