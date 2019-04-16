USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_get_post_tran_id_range]    Script Date: 03/31/2016 08:01:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
    
    
ALTER PROCEDURE [dbo].[usp_rpt_get_post_tran_id_range] (@report_date_start DATETIME, @report_date_end DATETIME, @first_post_tran_id BIGINT OUTPUT, @last_post_tran_id BIGINT OUTPUT)    
AS    
BEGIN    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
 SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '')     
 SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '')     
 DECLARE @report_date_start_minus DATETIME    
 SET @report_date_start_minus = DATEADD(HOUR, -1,@report_date_start)    
    
 DECLARE @report_date_end_plus DATETIME    

    
 DECLARE @temp_date_start DATETIME    
 DECLARE @temp_date_end DATETIME    
    
   IF(@report_date_start<> @report_date_end) BEGIN    
 SET @report_date_end_plus = DATEADD(HOUR,1,@report_date_end)    
    
   -- SELECT @temp_date_start= MIN(datetime_req) FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req >=@report_date_start AND datetime_req <@report_date_start_minus 
    set @first_post_tran_id  =(select  top 1 post_tran_id from POST_TRAN(NOLOCK) where datetime_req>=@report_date_start_minus AND  recon_business_date>=@report_date_start ORDER BY datetime_req ASC  ) 
    set @last_post_tran_id = (select  top 1 post_tran_id from POST_TRAN(NOLOCK) where datetime_req<@report_date_end_plus AND  recon_business_date<@report_date_end ORDER BY datetime_req desc)    
    
  END    
  ELSE IF(@report_date_start= @report_date_end) BEGIN    
    
      SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '')     
      SET  @report_date_end = DATEADD(D, 1,@report_date_end)    
      SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '')     
           SET @report_date_end_plus = DATEADD(HOUR,1,@report_date_end)    
    set @first_post_tran_id  =(select  top 1 post_tran_id from POST_TRAN(NOLOCK) where datetime_req>=@report_date_start_minus AND  recon_business_date>=@report_date_start ORDER BY datetime_req ASC  ) 
    set @last_post_tran_id = (select  top 1 post_tran_id from POST_TRAN(NOLOCK) where datetime_req<@report_date_end_plus AND  recon_business_date<@report_date_end ORDER BY datetime_req desc)    
    
  END    
if(@first_post_tran_id IS NULL) BEGIN   
 SELECT  @first_post_tran_id = MIN(post_tran_id) FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req >=@report_date_start  
  end  
if(@last_post_tran_id IS NULL) BEGIN    
   SELECT @last_post_tran_id = ISNULL(@last_post_tran_id, MAX(@last_post_tran_id)) FROM post_tran (NOLOCK, INDEX(ix_post_tran_7))       
  END    
  --SELECT @first_post_tran_id = post_tran_id FROM post_tran (NOLOCK) WHERE  datetime_req =convert(DATETIME,@temp_date_start )  
  SELECT @last_post_tran_id = post_tran_id FROM post_tran (NOLOCK) WHERE  datetime_req =convert(DATETIME,@temp_date_end )  
      
RETURN    
END    
    
    
  

