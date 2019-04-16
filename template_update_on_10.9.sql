SELECT *  INTO reports_entity_20160616_imported_backup FROM reports_entity  (NOLOCK) 
SELECT *  INTO reports_crystal_20160616_imported_backup  FROM reports_crystal  (NOLOCK) 
SELECT *  INTO reports_crytal_template_20160616_imported_backup  FROM reports_crystal_template  (NOLOCK)
SELECT *  INTO reports_template_20160616_imported_backup  FROM  reports_template (NOLOCK)


DELETE FROM reports_crystal_ondemand

--DELETE FROM reports_template
--DELETE FROM reports_crystal
--DELETE FROM reports_crystal_template 
--DELETE FROM reports_crystal_20160520
--DELETE FROM reports_entity


SELECT * FROM reports_crystal_backup_20160615


insert into reports_entity SELECT *, null FROM  [172.25.10.10].[postilion_OFfice].dbo.reports_entity
insert into reports_crystal SELECT *, 1 FROM  [172.25.10.10].[postilion_OFfice].dbo.reports_crystal 

select * from 
reports_crystal


C:\postilion\Office\base\reports\Balancing\B05 - Balancing TPP Switched-In Detail_Mega.rpt

~I:\BankReports\GTB\Mastercard\GTB_B04 -TPP POS_Acquirer Detail.pdf~3~1~



SELECT *  INTO #reports_entity FROM reports_entity  (NOLOCK) 
SELECT *  INTO #reports_crystal FROM reports_crystal  (NOLOCK) 

UPDATE reports_crystal SET template = temp.template, report_params = temp.report_params FROM reports_crystal cry JOIN  #reports_crystal temp 
ON cry.entity = temp.entity

SELECT * FROM reportS_crystal (NOLOCK)

SELECT * FROM reports_crystal WHERE entity IN (
SELECT entity_id FROM reports_entity (NOLOCK) where name = 'Anchorage_Pos_Acquired' -- template_id is NULL
)
C:\postilion\Office\base\reports\Balancing\cup\
SELECT * FROM reports_crystal (NOLOCK) where template = 'C:\postilion\Office\base\reports\Balancing\Switched In MasterCard Summary.rpt'

UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\Switched In MasterCard Summary.rpt' WHERE entity = 415
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\Switched out MasterCard Summary.rpt' WHERE entity = 416

C:\postilion\Office\base\reports\Balancing\
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B11 - Not On Us Summary_ATM_CUP.rpt' WHERE entity = 254
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B05 - Balancing TPP Switched-Out _CUP_ALL_csv.rpt' WHERE entity = 256
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B11 - Acquirer Summary_Pos_CUP.rpt' WHERE entity = 309
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B05 - Balancing TPP Switched-Out _CUP_ALL_POS_csv.rpt' WHERE entity = 310
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B04 - POS_Acquirer Detail_CUP_Eloho.rpt' WHERE entity = 326
UPDATE reports_crystal SET  template = 'C:\postilion\Office\base\reports\Balancing\B04 -mastercard_pos_per_terminal_csv.rpt' WHERE entity = 188

SELECT * FROM reports_entity WHERE template_id = -1834047634

SELECT * FROM reports_crystal_tempLate WHERE template_id = -1834047634

Office\base\reports\Balancing\B05 - Balancing TPP Switched-Out Detail_CUP.rpt
Office\base\reports\Balancing\B04 -TPP POS_Acquirer Detail_naira_merchant.rpt


 UPDATE reports_crystal_template SET user_params_defs='EDITBOX=StartDate in ''yyyymmdd'' format:; 1000;1;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=EndDate in ''yyyymmdd'' format:; 1000;1;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=SinkNode::; 1000;0;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=Period::; 1000;0;DEFAULT:NULL'rep
WHERE template='Office\base\reports\Balancing\B19 - Response Codes Analysis_periodic.rpt'


UPDATE reports_crystal SET output_params = REPLACE(CONVERT(VARCHAR(MAX),output_params), 'I:', 'G:')



EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=SinkNode:; 40;0;DEFAULT:NULL    
+CHAR(13)+CHAR(10)+'EDITBOX=CBN_Code:; 3;0;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=report_date_start in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=report_date_end in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL' 
EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=SourceNode:; 1000;0;DEFAULT:NULL  EDITBOX=CBN_Code:; 3;0;DEFAULT:NULL  EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL  EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL  EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL    

~NULL~NULL~NULL~NULL~NULL~NULL~20100006MC00412~NULL~NULL~NULL~Last business day~

EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=IINs:; 255;0;DEFAULT:NULL
EDITBOX=AcquirerInstId:; 255;0;DEFAULT:NULL
EDITBOX=SourceNodes:; 255;0;DEFAULT:NULL
EDITBOX=merchants:; 512;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL
EDITBOX=rate:; null;1;DEFAULT:NULL
