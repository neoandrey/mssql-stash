CREATE TABLE #fbn_transactions (pan VARCHAR(20), amount VARCHAR(30), stan VARCHAR(50), terminal_id VARCHAR(20), tran_code VARCHAR(5), message_type VARCHAR(6))


BULK
       INSERT 
           #fbn_transactions 
           		FROM  'C:\temp\fbn_trans_data.csv'
   WITH (

			FIELDTERMINATOR =',',
			ROWTERMINATOR ='\n'

		)
    CREATE TABLE #results_table (

	COLUMN1 VARCHAR(100)	,
	pan VARCHAR(100)	,
	COLUMN3 VARCHAR(100)	,
	COLUMN4 VARCHAR(100)	,
	COLUMN5 VARCHAR(100)	,
	COLUMN6 VARCHAR(100)	,
	COLUMN7 VARCHAR(100)	,
	COLUMN8 VARCHAR(100)	,
	COLUMN9 VARCHAR(100)	,
	COLUMN10 VARCHAR(100)	,
	COLUMN11 VARCHAR(100)	,
	COLUMN12 VARCHAR(100)	,
	COLUMN13 VARCHAR(100)	,
	COLUMN14 VARCHAR(100)	,
	COLUMN15 VARCHAR(100)	,
	COLUMN16 VARCHAR(100)	,
	COLUMN17 VARCHAR(100)	,
	COLUMN18 VARCHAR(100)	,
	COLUMN19 VARCHAR(100)	,
	COLUMN20 VARCHAR(100)	,
	COLUMN21 VARCHAR(100)	,
	COLUMN22 VARCHAR(100)	,
	COLUMN23 VARCHAR(100)	,
	COLUMN24 VARCHAR(100)	,
	COLUMN25 VARCHAR(100)	,
	COLUMN26 VARCHAR(100)	,
	COLUMN27 VARCHAR(100)	,
	COLUMN28 VARCHAR(100)	,
	COLUMN29 VARCHAR(100)	,
	COLUMN30 VARCHAR(100)	,
	COLUMN31 VARCHAR(100)	

)
		
  DECLARE @pan VARCHAR(20);
  DECLARE @amount VARCHAR(30); 
  DECLARE @stan VARCHAR(50);
  DECLARE @stan_2 VARCHAR(50);
  DECLARE @terminal_id VARCHAR(20);
  DECLARE @trancode VARCHAR(5)  ;
  DECLARE @count INT;
  DECLARE @message_type VARCHAR(6)
  
  SET @count =0;
       		
  DECLARE tran_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT pan, amount, stan, terminal_id, tran_code, message_type FROM #fbn_transactions
  OPEN tran_cursor;
  FETCH NEXT FROM tran_cursor INTO @pan, @amount, @stan, @terminal_id, @trancode, @message_type
  
  WHILE (@@FETCH_STATUS=0) BEGIN
  SET  @amount =REPLICATE('0', 12-LEN(@amount))+@amount;
  SET  @pan  =RIGHT(@pan,4)
  SET @stan_2 = '1'+ SUBSTRING(@stan,2, LEN(@stan))
  PRINT CONVERT(VARCHAR(50),(@count+1))+':'+ @pan+','+ @amount+','+@stan+','+@stan_2+','+@terminal_id+','+ @trancode+','+ @message_type+ CHAR(10)
  IF(@count=0) BEGIN

       INSERT INTO #results_table (COLUMN1,pan,COLUMN3,COLUMN4,COLUMN5,COLUMN6,COLUMN7,COLUMN8,COLUMN9,COLUMN10,COLUMN11,COLUMN12,COLUMN13,COLUMN14,COLUMN15,COLUMN16,COLUMN17,COLUMN18,COLUMN19,COLUMN20,COLUMN21,COLUMN22,COLUMN23,COLUMN24,COLUMN25,COLUMN26,COLUMN27,COLUMN28,COLUMN29,COLUMN30,COLUMN31)
          exec [osp_tlvmaster_fbn] @panl4d=@pan, @AMOUNT_12=@amount, @STAN_0100=@stan_2,@STAN_0220=@stan, @terminal_id=@terminal_id, @tran_code=@trancode
  END 
  ELSE BEGIN
      IF (@message_type='0100') BEGIN
        INSERT INTO #results_table   (COLUMN1,pan,COLUMN3,COLUMN4,COLUMN5,COLUMN6,COLUMN7,COLUMN8,COLUMN9,COLUMN10,COLUMN11,COLUMN12,COLUMN13,COLUMN14,COLUMN15,COLUMN16,COLUMN17,COLUMN18,COLUMN19,COLUMN20,COLUMN21,COLUMN22,COLUMN23,COLUMN24,COLUMN25,COLUMN26,COLUMN27,COLUMN28,COLUMN29,COLUMN30,COLUMN31)
        exec [osp_tlvmaster_fbn] @panl4d=@pan, @AMOUNT_12=@amount, @STAN_0100=@stan,@STAN_0220=@stan_2, @terminal_id=@terminal_id, @tran_code=@trancode
    END
    ELSE IF(@message_type='0200') BEGIN
     INSERT INTO #results_table   (COLUMN1,pan,COLUMN3,COLUMN4,COLUMN5,COLUMN6,COLUMN7,COLUMN8,COLUMN9,COLUMN10,COLUMN11,COLUMN12,COLUMN13,COLUMN14,COLUMN15,COLUMN16,COLUMN17,COLUMN18,COLUMN19,COLUMN20,COLUMN21,COLUMN22,COLUMN23,COLUMN24,COLUMN25,COLUMN26,COLUMN27,COLUMN28,COLUMN29,COLUMN30,COLUMN31)  
     exec [osp_tlvmaster_fbn] @panl4d=@pan, @AMOUNT_12=@amount, @STAN_0100=@stan_2,@STAN_0220=@stan, @terminal_id=@terminal_id, @tran_code=@trancode
    END
  
  
  END
  
  SET @count+=1;
  FETCH NEXT FROM tran_cursor INTO @pan, @amount, @stan, @terminal_id, @trancode, @message_type
  END
  
  select * from #results_table 
  
  DROP TABLE #fbn_transactions
  
 DROP TABLE  #results_table