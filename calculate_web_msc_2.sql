USE [isw_data]
GO
/****** Object:  UserDefinedFunction [dbo].[calculate_web_msc]    Script Date: 01/26/2015 16:07:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[calculate_web_msc] (@merchant_type VARCHAR(10), @tran_amount NUMERIC(15,2) , @settle_currency_code VARCHAR(5))

RETURNS NUMERIC(15,2)

AS

BEGIN
DECLARE @msc NUMERIC(15,2);

SET @tran_amount =dbo.formatAmount(@tran_amount,@settle_currency_code);

IF(@merchant_type='8211' )
BEGIN
     SET @msc = 200;
END
ELSE IF(@merchant_type='8220' )
   BEGIN
     SET @msc = 300;
  END
ELSE IF(@merchant_type='8241' )
   BEGIN
		SET  @msc = 150;
  END
ELSE IF(@merchant_type='8244' )
   BEGIN
		SET  @msc = 0.015 *@tran_amount;
		IF( @msc>300 )BEGIN
		     SET  @msc =300;
		END
  END
  ELSE IF(@merchant_type='8299' )
     BEGIN
  		SET  @msc = 0.015 *@tran_amount;
		IF( @msc>250 )BEGIN
		     SET  @msc =250;
		END
  END
  ELSE IF ( @merchant_type='8400')
	  BEGIN
		  SET  @msc = 400;
	  END 
     ELSE IF(@merchant_type='8250' )
      BEGIN
  		SET  @msc =250;
    END
     ELSE IF(@merchant_type='8265' )
      BEGIN
  		SET  @msc = 265;		
       END
       ELSE IF(@merchant_type='8550' )
      BEGIN
  		SET  @msc = 550;		
       END
       ELSE IF(@merchant_type='6211' )
           BEGIN
  			SET  @msc = 0.0125 *@tran_amount;
			IF( @msc>2000 )BEGIN
				 SET  @msc =2000;
			END
	   END
	    ELSE IF(@merchant_type='8999' )
           BEGIN
  			SET  @msc = 0.02 *@tran_amount;
	     END
	    ELSE IF(@merchant_type='6211' )
           BEGIN
  			SET  @msc = 0.0125 *@tran_amount;
			IF( @msc>2000 )BEGIN
				 SET  @msc =2000;
			END
	   END
	   ELSE IF(@merchant_type='4812' )
           BEGIN
  			SET  @msc = 0.0125 *@tran_amount;
			IF( @msc>1500 )BEGIN
				 SET  @msc =1500;
			END
	   END
	   ELSE 
           BEGIN
  			SET  @msc = 0.015 *@tran_amount;
			IF( @msc>2000 )BEGIN
				 SET  @msc =2000;
			END
	   END
  
 
  RETURN @msc;
  END