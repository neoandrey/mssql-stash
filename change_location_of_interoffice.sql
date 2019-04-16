USE [postilion_office]
GO


DECLARE @first_post_tran_id BIGINT
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @max_norm_session_id BIGINT
DECLARE @last_tran_legs_nr BIGINT
DECLARE @online_system_id INT

SELECT  @max_norm_session_id =max(normalization_session_id) FROM post_normalization_session;
SELECT  @first_post_tran_id = MAX(post_tran_id) FROM post_tran (NOLOCK)
SELECT  @first_post_tran_cust_id = MAX(post_tran_cust_id) FROM post_tran (NOLOCK)

SET @max_norm_session_id = ISNULL(@max_norm_session_id,0);
SET @first_post_tran_id = ISNULL(@first_post_tran_id,1);
SET @first_post_tran_cust_id = ISNULL(@first_post_tran_cust_id,1);

SELECT  @max_norm_session_id =  @max_norm_session_id+1 

INSERT INTO SELECT * FROM  post_normalization_session
(

	online_system_id,
	normalization_session_id,
	datetime_creation,
	first_post_tran_id,
	first_post_tran_cust_id,
	completed
	

) values (
	2, 
	 @max_norm_session_id, --14667,
	getdate(),
	@first_post_tran_id,
	@first_post_tran_cust_id,
	1

)





INSERT INTO [dbo].[post_norm_inter_office_session]
           ([local_online_system_id]
           ,[session_id]
           ,[remote_online_system_id]
           ,[first_remote_session_id]
           ,[last_remote_session_id]
           ,[first_post_tran_id]
           ,[max_post_tran_id]
           ,[nr_tran_legs]
           ,[copied_batches])
     VALUES
           (2
		             ,14667-- must be inserted into post_norm_session
           ,1
           ,13915 -- from remote Office server
           ,13915	-- from remote Office server
           ,152939744
,153036822
           ,97078 -- difference between the first and max post_tran_id (CURRENT AND NEXT POST)
           ,1
		   
		   )
GO


SELECT 153036822 - 152939744
USE [postilion_office]
GO
--SELECT * FROM post_online_system

DECLARE @first_post_tran_id BIGINT
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @max_norm_session_id BIGINT
DECLARE @last_tran_legs_nr BIGINT
DECLARE @online_system_id INT

SELECT  @max_norm_session_id =max(normalization_session_id) FROM post_normalization_session;
SELECT  @first_post_tran_id = MAX(post_tran_id) FROM post_tran (NOLOCK)
SELECT  @first_post_tran_cust_id = MAX(post_tran_cust_id) FROM post_tran (NOLOCK)

SET @max_norm_session_id =  ISNULL(@max_norm_session_id,0);
SET @first_post_tran_id = ISNULL(@first_post_tran_id,1);
SET @first_post_tran_cust_id = ISNULL(@first_post_tran_cust_id,1);

SELECT  @max_norm_session_id =  @max_norm_session_id+1 

INSERT INTO post_normalization_session
(

	online_system_id,
	normalization_session_id,
	datetime_creation,
	first_post_tran_id,
	first_post_tran_cust_id,
	completed
	

) values (
	2, 
	 @max_norm_session_id, --14667,
	getdate(),
	@first_post_tran_id,
	@first_post_tran_cust_id,
	1

)


--SELECT * FROM [post_norm_inter_office_session]


INSERT INTO [dbo].[post_norm_inter_office_session]
           ([local_online_system_id]
           ,[session_id]
           ,[remote_online_system_id]
           ,[first_remote_session_id]
           ,[last_remote_session_id]
           ,[first_post_tran_id]
           ,[max_post_tran_id]
           ,[nr_tran_legs]
           ,[copied_batches])
     VALUES
           (2
		             ,@max_norm_session_id-- must be inserted into post_norm_session
           ,5
           ,290924 -- from remote Office server
           ,290924	-- from remote Office server
           ,@first_post_tran_id
,@first_post_tran_id+97078
           ,97078 -- difference between the first and max post_tran_id (CURRENT AND NEXT POST)
           ,1
		   
		   )
GO

