DECLARE  @FILE_DIR VARCHAR(255)

SELECT @FILE_DIR='I:\BankReports\Hotels'

DECLARE @REPORT_DATE DATETIME

DECLARE @REPORT_DATE_STRING VARCHAR(255)

SELECT @REPORT_DATE=DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))

SELECT @REPORT_DATE = REPLACE(@REPORT_DATE,'-', '_');

SELECT @REPORT_DATE_STRING = LEFT(CONVERT(VARCHAR(255),@REPORT_DATE,112), 10)

SELECT @REPORT_DATE_STRING

DECLARE @REPORT_FILE VARCHAR(255)

DECLARE @sql VARCHAR(5000)

SET @REPORT_FILE= @FILE_DIR+'\FBN\fbn_hotel_extract_'+@REPORT_DATE_STRING+'.csv'
SELECT @sql='bcp "exec postilion_office.dbo.osp_rpt_b04_web_pos_acquirer_omc   @StartDate = NULL, @EndDate = NULL, @SourceNodes =N''MEGASPFBNsrc,ADJFBNsrc'',  @IINs = NULL,  @AcquirerInstId = NULL,   @merchants = NULL,   @show_full_pan = NULL,@report_date_start = NULL,@report_date_end = NULL,@rpt_tran_id = NULL;"  queryout '+@REPORT_FILE+' -c -t, -T -S'
EXEC master..xp_cmdshell @sql

SET @REPORT_FILE= @FILE_DIR+'\GTB\gtb_hotel_extract_'+@REPORT_DATE_STRING+'.csv'
SELECT @sql='bcp "exec postilion_office.dbo.osp_rpt_b04_web_pos_acquirer_omc   @StartDate = NULL, @EndDate = NULL, @SourceNodes = N''MEGASPGTBsrc,ADJGTBsrc'',  @IINs = NULL,  @AcquirerInstId = NULL,   @merchants = NULL,   @show_full_pan = NULL,   @report_date_start = NULL,   @report_date_end = NULL,   @rpt_tran_id = NULL;"  queryout '+@REPORT_FILE+' -c -t, -T -S'
EXEC master..xp_cmdshell @sql

SET @REPORT_FILE= @FILE_DIR+'\SKYE\skye_hotel_extract_'+@REPORT_DATE_STRING+'.csv'
SELECT @sql='bcp "exec postilion_office.dbo.osp_rpt_b04_web_pos_acquirer_omc  @StartDate = NULL, @EndDate = NULL, @SourceNodes = N''MEGASPPRUsrc,MEGASPEBNsrc,ADJEBNsrc'',  @IINs = NULL,  @AcquirerInstId = NULL,   @merchants = NULL,   @show_full_pan = NULL,   @report_date_start = NULL,   @report_date_end = NULL,   @rpt_tran_id = NULL;"  queryout '+@REPORT_FILE+' -c -t, -T -S'
EXEC master..xp_cmdshell @sql
