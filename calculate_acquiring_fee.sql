
CREATE FUNCTION [dbo].[calculate_acquiring_fee] (@pan VARCHAR(20), @merchant_type VARCHAR(10), @msc NUMERIC(15,2) )

RETURNS NUMERIC(15,2)

AS

BEGIN
DECLARE @aquiring_fee NUMERIC(15,2);

IF(LEFT(@pan, 3)= '506'  OR LEFT(@pan, 6) IN ('539945','528649','521090','551609','559453','519615','528668') ) BEGIN
		IF( @merchant_type NOT IN ('8211','8220', '8241','8244','8299' ,'8400','8250','8265','8550','6211' ,'8999','4812'))
		 BEGIN

					SET @aquiring_fee = @msc * 0.175;

		END
		ELSE IF( @merchant_type IN ('8211','8220', '8241','8244','8299' ,'8400','8250','8265','8550','6211' ,'8999','4812'))
		 BEGIN
				
					SET @aquiring_fee = @msc * 0.125;

				
		END
END
ELSE IF(LEFT(@pan, 2) IN ('51','52','53','54','55') AND LEFT(@pan, 6) NOT IN ('539945','528649','521090','551609','559453','519615','528668')  ) 
BEGIN
						SET @aquiring_fee = @msc * 0.125;
END

RETURN @aquiring_fee;
END