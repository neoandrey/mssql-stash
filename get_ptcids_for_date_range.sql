USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[get_ptcids_for_date_range]    Script Date: 2/7/2018 11:52:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


									  create FUNCTION  [dbo].[get_ptcids_for_date_range](@start_date DATETIME, @end_date DATETIME )
									   RETURNS  @id_table  TABLE (post_tran_cust_id BIGINT)
									   AS 
									   begin
									   
										 INSERT INTO @id_table SELECT  post_tran_cust_id  FROM  post_tran WITH (nolock, INDEX(ix_post_tran_1)) where  post_tran_id  in 	
										  ( SELECT  post_tran_id FROM  dbo.get_ptids_for_date_range(@start_date,@end_date) )

							             
										 
									     RETURN 
										 END

										 USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[get_ptids_for_date_range]    Script Date: 2/7/2018 11:52:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER FUNCTION  [dbo].[get_ptids_for_date_range](@start_date DATETIME, @end_date DATETIME )
									   RETURNS  @id_table  TABLE (post_tran_id BIGINT)
									   AS 
									   begin
									     DECLARE  @start_id BIGINT
										 DECLARE  @end_id  BIGINT
										   

										 SELECT @start_id = MIN(post_tran_id) FROM  post_tran (nolock, INDEX(ix_post_tran_9)) WHERE  recon_business_date = @start_date
										  SELECT @end_id  = MAX(post_tran_id) FROM  post_tran (nolock, INDEX(ix_post_tran_9)) WHERE  recon_business_date = @end_date
									    
										 WHILE (@start_id<=@end_id)BEGIN
										 INSERT INTO @id_table VALUES(@start_id);

							             SELECT @start_id =@start_id+1;
										 END
									     RETURN 
										 END

GO

