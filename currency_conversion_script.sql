DROP TABLE #temp_currency_stats;
DROP TABLE #final_currency_stats;


CREATE TABLE #temp_currency_stats (currency_code VARCHAR (4), amount FLOAT);
CREATE TABLE #final_currency_stats (currency_code VARCHAR (4),rate FLOAT, amount FLOAT, final_amount FLOAT);
BULK INSERT #temp_currency_stats FROM  'C:\temp\conversion\currency_data.csv'

   WITH (

			FIELDTERMINATOR =',',
			ROWTERMINATOR ='\n'

		)
 DECLARE @currency_code VARCHAR(5);          		
DECLARE @naira_rate FLOAT;
DECLARE @current_rate FLOAT;
DECLARE @amount FLOAT;
DECLARE @final_amount FLOAT;

SELECT @naira_rate = rate FROM post_currencies WHERE currency_code='566';

DECLARE currency_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT currency_code, amount FROM #temp_currency_stats;
OPEN currency_cursor;
FETCH NEXT FROM currency_cursor INTO  @currency_code, @amount;
WHILE  (@@FETCH_STATUS = 0)BEGIN

SELECT @current_rate = rate FROM post_currencies WHERE currency_code=@currency_code;
INSERT INTO #final_currency_stats (currency_code, rate, amount,final_amount)VALUES (@currency_code,@current_rate,@amount,  @naira_rate/@current_rate*@amount );



FETCH NEXT FROM currency_cursor INTO  @currency_code, @amount;
END
CLOSE currency_cursor
DEALLOCATE currency_cursor

SELECT * fROM #final_currency_stats;