USE [postilion_office]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[osp_rpt_b04_web_pos_acquirer_nibss_ceaser]
		@StartDate = NULL,
		@EndDate = NULL,
		@SourceNodes = 'SWTASPKIMsrc,SWTASPPOSsrc,SWTNCSKI2src,SWTFBPsrc,SWTUBAsrc,SWTASGTVLsrc,SWTFCMBsrc,SWTNCS2src,SWTSHOPRTsrc,SWTNCSKIMsrc,SWTEASYFLsrc,SWTFBNsrc,SWTZIBsrc,SWTASPZIBsrc,SWTFUELsrc,SWTTRAVELsrc,SWTTELCOsrc,SWTASPKSKsrc,S',
		@merchants = NULL,
		@show_full_pan = NULL,
		@report_date_start = NULL,
		@report_date_end = NULL,
		@rpt_tran_id1 = NULL,
		@rpt_tran_id = NULL

SELECT	'Return Value' = @return_value

GO

SELECT * FROM tbl_wpos_acq_nibss_ceaser
