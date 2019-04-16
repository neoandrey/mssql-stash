CREATE TRIGGER [datetime_req_sync_trig] 
ON mdynamix_post_office.dbo.post_tran_cust 
AFTER INSERT  AS BEGIN

DECLARE @post_tran_cust_id BIGINT ;

SELECT @post_tran_cust_id = post_tran_cust_id FROM inserted;

UPDATE mdynamix_post_office.dbo.post_tran_cust SET datetime_req = (SELECT  top 1 datetime_req FROM mdynamix_post_office.dbo.post_tran(NOLOCK) WHERE post_tran_cust_id = 
@post_tran_cust_id) WHERE post_tran_cust_id = @post_tran_cust_id;

END