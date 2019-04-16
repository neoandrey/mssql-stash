
ALTER FUNCTION dbo.calculate_msc (@merchant_type VARCHAR(10), @tran_amount NUMERIC(15,2) , @settle_currency_code VARCHAR(5))

RETURNS NUMERIC(15,2)

AS

BEGIN
DECLARE @msc NUMERIC(15,2);

SET @tran_amount =dbo.formatAmount(@tran_amount,@settle_currency_code);

IF(@merchant_type='5814' OR @merchant_type='8661' )
BEGIN
     SET @msc = 0.0125 * @tran_amount;
     IF(@msc>100)
     BEGIN 
         SET @msc = 100;
     END
END
ELSE IF(@merchant_type='7011' )
   BEGIN
     SET @msc = 0.0125 * @tran_amount;
  END
ELSE IF(@merchant_type='4722' )
   BEGIN
		SET  @msc = 200;
		IF( @tran_amount<=200 )BEGIN
		     SET  @msc = 0;
		END
  END
ELSE IF(@merchant_type='5300' )
   BEGIN
		SET  @msc = 0.002 *@tran_amount;
		IF( @msc>1000 )BEGIN
		     SET  @msc =1000;
		END
  END
  ELSE IF(@merchant_type='5541' OR @merchant_type='9752' OR @merchant_type='1111')
     BEGIN
  		SET  @msc = 0;
  END
  ELSE BEGIN
  SET  @msc =  0.0125 *@tran_amount;
  		IF( @msc>2000 )BEGIN
  		     SET  @msc =2000;
		END
  
  
  END
  
 
  RETURN @msc;
  END