USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[opsp_get_settle_entity]    Script Date: 07/01/2016 23:04:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[opsp_get_settle_entity]
	@settle_entity_id INT
AS
BEGIN

DECLARE @permitted_nodes VARCHAR(30)
SELECT @permitted_nodes =permitted_nodes  FROM Realtime.dbo.pp_user_sessions_financial_institutions (NOLOCK) where session_id =@@SPID;

	SELECT
		settle_entity_id,
		node_name,
		acquiring_inst_id_code,
		card_acceptor_id_code,
		terminal_id
	FROM
		post_settle_entity WITH (NOLOCK)
	WHERE
		settle_entity_id = @settle_entity_id
		AND node_name LIKE '%'+@permitted_nodes+'%'
END
 
