DECLARE @first_post_tran_id BIGINT
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @max_norm_session_id BIGINT
DECLARE @last_tran_legs_nr BIGINT

SET @last_tran_legs_nr=27670182770;

SELECT  @max_norm_session_id =max(normalization_session_id) FROM post_normalization_session;
SELECT  @first_post_tran_id = MAX(post_tran_id) FROM post_tran (NOLOCK)
SELECT  @first_post_tran_cust_id = MAX(post_tran_cust_id) FROM post_tran (NOLOCK)

SELECT  @max_norm_session_id =  @max_norm_session_id+1 

INSERT INTO  post_normalization_session
(

	online_system_id,
	normalization_session_id,
	datetime_creation,
	first_post_tran_id,
	first_post_tran_cust_id,
	completed


) values (
	1, 
	@max_norm_session_id,
	getdate(),
	@first_post_tran_id,
	@first_post_tran_cust_id,
	1

)


INSERT INTO  post_norm_rtfw_session
(
		session_id,
		last_tran_legs_nr,
		last_datetime,
		copied_batches
)VALUES(
		@max_norm_session_id,
		@last_tran_legs_nr,
		GETDATE(),
		1

)


