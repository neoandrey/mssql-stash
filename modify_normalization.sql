SELECT  top 1 trans.tran_nr, in_req, tran_legs_nr FROM tm_trans trans (NOLOCK) JOIN tm_tran_legs legs (NOLOCK) ON trans.tran_nr = legs.tran_nr  WHERE in_req >='2014-06-12 00:00:00'


SELECT TOP 1 * FROM tm_tran_legs_current

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%next%'

select  TOP 1 * from post_norm_rtfw_session ORDER BY session_id DESC

SELECT TOP 1*   FROM post_normalization_session ORDER BY normalization_session_id DESC

SELECT MAX(session_id), MAX(last_datetime) 

SELECT * FROM post_normalization_session

select   * from post_norm_rtfw_session 

SELECT  MAX (normalization_session_id), MAX(datetime_creation)   


SELECT * FROM post_normalization_session

SELECT MAX(tran_nr) FROM post_tran (NOLOCK)

2329676171


UPDATE post_normalization_session SET completed =1 WHERE normalization_session_id = 91858


--

UPDATE post_norm_rtfw_session SET last_tran_legs_nr=23501211115  WHERE session_id >= 91858

UPDATE post_norm_rtfw_session SET last_tran_legs_nr=23431085036  WHERE session_id = 91861


SELECT * FROM post_normalization_tran_nr_lookup

SELECT * FROM post_norm_switchkey
SELECT MAX(post_tran_id), MAX(post_tran_cust_id) FROM post_tran (NOLOCK)

SELECT  MAX(post_tran_cust_id) FROM post_tran_cust (NOLOCK)



--next tran should be the 

hold on

-- yesthe first post tran id should be the last transaction you want to start normalization from. it shoul dbe
-- for exaample


-- this should be one
--? Okay Thank you. SO, It's the date that matters, not really, i think its the first_post_tran_id, first_post_tran_cust_id and completed which really matters

UPDATE post_normalization_session

SET 
completed =1
WHERE 
 [normalization_session_id] =91860


=================================

SELECT MAX(session_id), MAX(last_datetime) SELECT * FROM post_norm_rtfw_session

INSERT INTO post_norm_rtfw_session 
 (session_id,last_tran_legs_nr, last_datetime, copied_batches, is_dst) 
VALUES
(
91859
,2354018276
,'2014-03-27 23:59:59:59.999'
,0
NULL)


SELECT  MAX (normalization_session_id), MAX(datetime_creation)   FROM post_normalization_session

SELECT TOP 1 * FROM post_normalization_session order by normalization_session_id desc

====================

UPDATE post_normalization_session

SET 
completed =1

INSERT INTO post_norm_rtfw_session 

 (session_id,last_tran_legs_nr, last_datetime, copied_batches, is_dst) 
VALUES
(
9
,24871199903
,GETDATE()
,0
,NULL)

INSERT INTO [postilion_office].[dbo].[post_normalization_session]
           ([online_system_id]
           ,[normalization_session_id]
           ,[datetime_creation]
           ,[first_post_tran_id]
           ,[first_post_tran_cust_id]
           ,[completed])
     VALUES
          (1
           ,9
           ,GETDATE()
           ,347735
           ,308344
		,0)=
		
		
		UPDATE post_normalization_session
		
		SET 
		completed =1
		
		INSERT INTO post_norm_rtfw_session 
		
		 (session_id,last_tran_legs_nr, last_datetime, copied_batches, is_dst) 
		VALUES
		(
		8
		,24871199903
		,GETDATE()
		,0
		,NULL)
		
		INSERT INTO [postilion_office].[dbo].[post_normalization_session]
		           ([online_system_id]
		           ,[normalization_session_id]
		           ,[datetime_creation]
		           ,[first_post_tran_id]
		           ,[first_post_tran_cust_id]
		           ,[completed])
		     VALUES
		          (1
		           ,8 
		           ,GETDATE()
		           ,347735
		           ,308344
		,1)