DECLARE @last_settlement_date DATETIME;
DECLARE @config_version INT;
DECLARE @config_set_id INT;
DECLARE @post_tran_id INT;
DECLARE @num_of_days_ago INT;

SET @num_of_days_ago =ISNULL(@num_of_days_ago,1);

SET @num_of_days_ago = -1 *  @num_of_days_ago;

SELECT @last_settlement_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,@num_of_days_ago, GETDATE()),111),'/', '-');

SELECT  @config_version = MAX(config_version) , @config_set_id = MAX(config_set_id) FROM sstl_config_version

EXEC  dbo.osp_sstl_jrnl_man_reset

DELETE FROM sstl_session

SET @post_tran_id =(SELECT TOP 1 post_tran_id, datetime_req FROM post_tran (NOLOCK) WHERE datetime_req<@last_settlement_date  ORDER BY datetime_req DESC)

INSERT INTO sstl_session (session_id, entity_id, config_set_id,config_version,datetime_started, last_post_tran_id,last_sdi_tran_id, completed)
values
(1,	1,	@config_set_id,	@config_version, GETDATE(), @post_tran_id,	0	,1)

=================================


DECLARE @last_settlement_date DATETIME;
DECLARE @config_version INT;
DECLARE @config_set_id INT;
DECLARE @post_tran_id INT;
DECLARE @num_of_days_ago INT;

SET @num_of_days_ago =ISNULL(@num_of_days_ago,1);

SET @num_of_days_ago = -1 *  @num_of_days_ago;

SELECT @last_settlement_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,@num_of_days_ago, GETDATE()),111),'/', '-');

SELECT  @config_version = MAX(config_version) , @config_set_id = MAX(config_set_id) FROM sstl_config_version

EXEC  dbo.osp_sstl_jrnl_man_reset

SELECT * FROM sstl_session

SET @post_tran_id =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK) WHERE datetime_req<@last_settlement_date  ORDER BY datetime_req DESC);

INSERT INTO sstl_session (session_id, entity_id, config_set_id,config_version,datetime_started, last_post_tran_id,last_sdi_tran_id, completed)
values(1,	1,	@config_set_id,	@config_version, GETDATE(), @post_tran_id,	0	,1)
