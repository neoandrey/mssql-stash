INSERT INTO post_norm_rtfw_session 
 (session_id,last_tran_legs_nr, last_datetime, copied_batches, is_dst) 
VALUES
(
1
,3890957779
,GETDATE()
,1
,0)

INSERT INTO [postilion_office].[dbo].[post_normalization_session]
           ([online_system_id]
           ,[normalization_session_id]
           ,[datetime_creation]
           ,[first_post_tran_id]
           ,[first_post_tran_cust_id]
           ,[completed])
     VALUES
          (1
           ,1 
           ,GETDATE()
           ,0
           ,0
		,1)