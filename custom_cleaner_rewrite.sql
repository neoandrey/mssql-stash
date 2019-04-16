
DECLARE @num_of_del_sessions INT
SET @num_of_del_sessions = 10

SELECT DATETIME_REQ, NTILE(@num_of_del_sessions) OVER (ORDER BY DATETIME_REQ) ses_id INTO #temp_cleaner_data FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) 
WHERE CONVERT(DATE,DATETIME_REQ) =  (SELECT  CONVERT(DATE,MIN(DATETIME_REQ)) FROM post_tran (NOLOCK))

create index ix_datetime_req ON #temp_cleaner_data(
ses_id

)include(
DATETIME_REQ
)
DECLARE @counter INT
SET @counter =1
WHILE (@counter<=@num_of_del_sessions) BEGIN
	DELETE FROM post_tran WHERE datetime_req IN (select datetime_req FROM  #temp_cleaner_data WHERE  ses_id = 1)

SET @counter=@counter+1;
END



		
		

IF (OBJECT_ID('TEMPDB.dbo.#temp_cleaner_data') IS NOT NULL ) BEGIN
	DROP TABLE #temp_cleaner_data
END
DECLARE @num_of_del_sessions INT
SET @num_of_del_sessions = 1000

SELECT DATETIME_REQ, NTILE(@num_of_del_sessions) OVER (ORDER BY DATETIME_REQ) ses_id INTO #temp_cleaner_data FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) 
WHERE CONVERT(DATE,DATETIME_REQ) =  (SELECT  CONVERT(DATE,MIN(DATETIME_REQ)) FROM post_tran (NOLOCK))

create index ix_datetime_req ON #temp_cleaner_data(
ses_id

)include(
DATETIME_REQ
)
DECLARE @counter INT
SET @counter =1
WHILE (@counter<=@num_of_del_sessions) BEGIN
	
	 SET ROWCOUNT  50  
        DELETE_POST_TRAN:  
       DELETE FROM post_tran WHERE datetime_req IN (select datetime_req FROM  #temp_cleaner_data WHERE  ses_id = @counter)
        IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN  
        SET ROWCOUNT 0 
		

SET @counter=@counter+1;
END
