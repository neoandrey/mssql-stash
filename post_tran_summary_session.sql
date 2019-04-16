CREATE TABLE post_tran_summary_session (
session_id INT NOT NULL IDENTITY(1,1),
last_datetime_req DATETIME NOT NULL,
last_post_tran_id BIGINT NOT NULL,
last_post_tran_cust_id BIGINT NOT NULL,
last_tran_nr BIGINT NOT NULL,
last_retrieval_reference_nr VARCHAR(12) NOT NULL,
last_system_trace_audit_nr VARCHAR(6) NOT NULL,
last_recon_business_date VARCHAR(6) NOT NULL,
last_online_system_id VARCHAR(6) NOT NULL,
last_tran_postilion_originated int NOT NULL,
session_completed INT DEFAULT (0)
)

CREATE CLUSTERED INDEX ix_post_tran_summary_session_1 ON post_tran_summary_session(
session_id

)


CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_2 ON post_tran_summary_session(
last_datetime_req

)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_3 ON post_tran_summary_session(
last_post_tran_id

)
CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_4 ON post_tran_summary_session(
last_post_tran_cust_id

)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_5 ON post_tran_summary_session(
last_tran_nr

)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_6 ON post_tran_summary_session(
last_retrieval_reference_nr

)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_7 ON post_tran_summary_session(
last_system_trace_audit_nr

)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_8 ON post_tran_summary_session(
	last_system_trace_audit_nr
)

CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_9 ON post_tran_summary_session(
	last_recon_business_date
)
CREATE NONCLUSTERED INDEX ix_post_tran_summary_session_10 ON post_tran_summary_session(
	session_id,last_online_system_id,last_tran_postilion_originated,session_completed
)