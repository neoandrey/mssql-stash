 /****** Object:  Table [dbo].[at_log]    Script Date: 05/16/2017 22:41:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo][temp_post_tran_id_range_table]') AND type in (N'U'))
DROP TABLE [dbo].temp_post_tran_id_range_table
GO


  select distinct POST_TRAN_Id, NTILE (10) OVER  (ORDER BY POST_TRAN_Id) thread_id INTO temp_post_tran_id_range_table FROM 
  (SELECT DISTINCT post_tran_id from temp_journal_details_data (NOLOCK)
  union  all
  SELECT  DISTINCT PT_post_tran_id  post_tran_id from [temp_POST_TRAN_details_data](NOLOCK)
  )T
  CREATE clustered index  ix_temp_post_tran_id_range_table_1 ON temp_post_tran_id_range_table(
   post_tran_id
  )
  
  create index ix_temp_post_tran_id_range_table_2 ON temp_post_tran_id_range_table(
   THREAD_ID
  )include (
   post_tran_id 
  )