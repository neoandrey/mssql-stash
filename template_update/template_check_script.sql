
SELECT * FROM reports_crystal_ondemand
SELECT * FROM reports_crystal_template
SELECT * FROM reports_template


SELECT REPLACE(CONVERT(VARCHAR(MAX), template),'C:\postilion\Office\reports\Balancing\', '') template_filename,* INTO #cup_templates 
FROM reports_crystal WHERE entity in(
SELECT entity_id fROM reports_Entity  WHERE name LIKE '%CUP_Pos_Acquired%')

SELECT * FROM #cup_templates


UPDATE reports_crystal SET report_params= map.report_params 
FROM 
 reports_entity ent JOIN reports_crystal cry ON ent.entity_id = cry.entity 
 join #temp_cup_ent_map map  on ent.name = map.name
 WHERE  ent.name LIKE '%CUP_Pos_Acquired%'


SELECT name, report_params INTO  #temp_cup_ent_map from [172.25.10.10].[postilion_OFfice].dbo.reports_entity ent JOIN [172.25.10.10].[postilion_OFfice].dbo.reports_crystal cry ON ent.entity_id = cry.entity WHERE  name LIKE '%CUP_Pos_Acquired%'



DELETE FROM reports_crystal_ondemand
DELETE FROM reports_crystal_template
UPDATE reports_entity SET template_id = null
DELETE FROM reports_template


DELETE FROM reports_crystal WHERE entity =1843
DELETE FROM reports_entity

INSERT INTO  reports_entity 
select  entity_id
,name
,plugin_id
,user_param_list 
, NULL from 
[172.25.10.116].[postilion_Office].dbo.[reports_entity]


INSERT INTO  reports_crystal
select * from 
[172.25.10.116].[postilion_Office].dbo.reports_crystal


sELECT *  FROM reports_crystal WHERE template like '%not on us%'


SELECT
 TOP 1000 SUBSTRING(CONVERT(VARCHAR(MAX), template),39, LEN(CONVERT(VARCHAR(MAX), template)))
  
 FROM reports_crystal WHERE LEN(CONVERT(VARCHAR(MAX),template)) > 0

SELECT TOP 100 REPLACE(CONVERT(VARCHAR(MAX), template),'Office\reports\Balancing\', '')   FROM reports_crystal_template

SELECT * FROM reports_template
SELECT * FROM reports_crystal_template WHERE template_id= 1745803838
~NULL~NULL~SWTUBAsnk~627480~SWTNCS2src,SWTSHOPRTsrc,SWTASGTVLsrc,SWTNCSKIMsrc~NULL~NULL~NULL~NULL~NULL~
EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=Acquirer:; 1000;0;DEFAULT:NULL
EDITBOX=AcquirerInstId:; 1000;0;DEFAULT:NULL
EDITBOX=SourceNodes:; 1000;0;DEFAULT:NULL
EDITBOX=merchants:; 512;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL

UPDATE reports_crystal SET template = REPLACE(CONVERT(VARCHAR(MAX), template),'J:\postilion\Office\reports\Balancing\', 'C:\postilion\Office\reports\Balancing\')

UPDATE reports_crystal SET output_params = REPLACE(CONVERT(VARCHAR(MAX), output_params), 'I:','E:')
CONVERT(VARCHAR(MAX), template),


select REPLACE(CONVERT(VARCHAR(MAX), template),'Office\reports\Balancing\', '') from reports_crystal_template

select  * FROM REPORTS_CRYSTAL SUBSTRING(CONVERT(VARCHAR(MAX), template), (LEN(CONVERT(VARCHAR(MAX), template)) - CHARINDEX('\', REVERSE(CONVERT(VARCHAR(MAX), template)))) +2, LEN(CONVERT(VARCHAR(MAX), template))) FROM reports_crystal

SELECT 
--ent.name, 
entity, user_params_defs , temp.template, report_params,template_id  INTO  #temp_template_info
FROM reports_crystal cry
 
   JOIN reports_crystal_template temp on REPLACE(CONVERT(VARCHAR(MAX), temp.template),'Office\reports\Balancing\', '') =SUBSTRING(CONVERT(VARCHAR(MAX), cry.template),39, LEN(CONVERT(VARCHAR(MAX), cry.template)))  
 WHERE LEN(CONVERT(VARCHAR(MAX),temp.template)) > 0

   --JOIN reports_entity ent on  cry.entity=ent.entity_id
   --ORDER BY ent.name

   SELECT * FROM #temp_template_info

   UPDATE reports_entity SET template_id = temp.template_id FROM reports_entity ent JOIN #temp_template_info temp ON ent.entity_id=temp.entity

  SELECT * FROM  #temp_template_info WHERE template_id like '%.rpt%'

EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SinkNodes:; 510;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL
EDITBOX=Period:; 18;0;DEFAULT:NULL

~NULL~NULL~NULL~Last Business Day~MEGAIBPsnk~NULL~NULL~NULL~


--update reports_crystal set report_params =   '~NULL~NULL'+SUBSTRING(REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) ), CHARINDEX('~', REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) )), LEN(REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) )))+'~NULL~NULL~NULL~NULL~Last Business Day~'
SELECT  '~NULL~NULL'+REPLACE(REPLACE(CONVERT(VARCHAR(MAX),temp.report_params), 'NULL~', ''), 'False~', '')+'NULL~NULL~NULL~NULL~', *,temp.report_params    --, replace(temp.report_params, 'c~NULL~1','c~1')+'NULL~', replace(temp.report_params, 'c~true~1','c~1')+'NULL~'
 FROM #temp_template_info temp JOIN   reports_crystal cry
ON temp.entity= cry.entity
 WHERE temp.template like '%Switched-Out Detail_Megat%'

 SELECT * FROM reports_entity WHERE name = 'Switched-Out Detail_Megat'
 1141	ABBEY_PrepaidCardLoad_csv	Crystal	NULL	-618768440
 411	ABP_NotOnUs_csv	Crystal	NULL	1169661620

 SELECT * FROM reports_crystal WHERE entity = 1141
 ~NULL~NULL~SWTABSCCsnk,SWTABSCC1snk~130~sss~false~NULL~NULL~ABS~
 ~NULL~NULL~SWTABSCCsnk,SWTABSCC1snk~130~ABS~NULL~NULL~NULL~NULL~
 ~NULL~NULL~SWTPRUsnk,SWTPRUsnk~076~627805,506106,506129~PRU,PRUGroup,PRUCCGroup~NULL~NULL~NULL~NULL~
~NULL~NULL~SWTOBIsnk,SWTEBNsnk~056,050~603948,506122,903708,506118~EBN,OBI,OBIGroup,OBICCGroup,EBNGroup,EBNCCGroup,EBNeACCGroup~NULL~NULL~NULL~NULL~




SELECT entity, template_name, template_id INTO #reports_template_entity_map 
FROM reports_crystal cry JOIN  reports_template temp ON REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(SUBSTRING( template, LEN(template) -(CHARINDEX('\', REVERSE (template))-2), LEN(template) -(LEN(template) -(CHARINDEX('\', REVERSE (template))-5)))) ),'-','_'),' ','_'),'__','_')  = REPLACE(REPLACE(REPLACE(template_name,'-','_'),' ','_') ,'__','_')
WHERE LEN(CONVERT(VARCHAR(MAX),template)) > 0


UPDATE reports_entity SET template_id = map.template_id  FROM  reports_entity ent join #reports_template_entity_map map ON ent.entity_id =map.entity

select SUBSTRING(CONVERT(VARCHAR(MAX),report_params),1,( LEN(CONVERT(VARCHAR(MAX),report_params))-6)) from reports_crystal  WHERE template like '%not on us%'


update reports_crystal set report_params =   '~NULL~NULL'+SUBSTRING(REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) ), CHARINDEX('~', REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) )), LEN(REVERSE( SUBSTRING( REVERSE(temp.report_params), 17,CHARINDEX('~', REVERSE(temp.report_params),17)) )))+'~NULL~NULL~NULL~NULL~Last Business Day~'
FROM #temp_template_info temp JOIN   reports_crystal cry
ON temp.entity= cry.entity
 WHERE temp.template like '%B05 - Balancing TPP Switched-In Detail_csv_Mega%'
  
 SELECT  SUBSTRING( CONVERT(VARCHAR(MAX),report_params), 11,lEN(CONVERT(VARCHAR(MAX),report_params))-5), *   --,  SUBSTRING(CONVERT(VARCHAR(MAX),report_params),1,( LEN(CONVERT(VARCHAR(MAX),report_params))-5)) 
 FROM reports_crystal
 
 --_template

 update reports_crystal set report_params = SUBSTRING( CONVERT(VARCHAR(MAX),report_params), 11,lEN(CONVERT(VARCHAR(MAX),report_params))-5)
   WHERE entity  in(

   SelECT entity_id FROM reports_entity WHERE name  LIKE '%prepaidcardload%summary%')

   
SELECT * FROM reports_crystal    WHERE entity  in(

   SelECT entity_id, template_id FROM reports_entity WHERE name  LIKE '%Billpayment_Acquired%')



  
update reports_crystal set report_params =replace(CONVERT(VARCHAR(MAX),report_params), 'c~NULL~1','c~1')
 WHERE template like '%not on us%'

 update reports_crystal set report_params =replace(CONVERT(VARCHAR(MAX),report_params), 'c~true~1','c~1')
 WHERE template like '%not on us%'



 update reports_crystal set report_params =SUBSTRING(CONVERT(VARCHAR(MAX),report_params),1,( LEN(CONVERT(VARCHAR(MAX),report_params))-4))
 WHERE template like '%not on us%'

update reports_crystal set report_params =CONVERT(VARCHAR(MAX),report_params)+'~'
 WHERE template like '%not on us%'


 ~NULL~NULL~NULL~Last Business Day~MEGAGTBsnk,MEGAASPsnk,MEGAPWCsnk~NULL~NULL~NULL~


 EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SourceNode:; 1000;0;DEFAULT:NULL
EDITBOX=terminalID:; 40;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=TotalsGroup:; 512;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL


~NULL~NULL~SWTAFRIsrc~1S014~NULL~NULL~NULL~NULL~NULL~

 ~NULL~NULL~SWTABPsrc,SWTIBPsrc~NULL~1S044,1S069~NULL~NULL~NULL~NULL~
 ~NULL~NULL~SWTABPsrc,SWTIBPsrc~1S044,1S069~NULL~NULL~NULL~NULL~NULL~



update reports_crystal set report_params =SUBSTRING(CONVERT(VARCHAR(MAX),report_params),1,( LEN(CONVERT(VARCHAR(MAX),report_params))-4))
 WHERE template like '%not on us%'
 
 update reports_crystal set report_params =SUBSTRING(CONVERT(VARCHAR(MAX),report_params),1,( LEN(CONVERT(VARCHAR(MAX),report_params))-6))
 WHERE template like '%Prepaid%'
 update reports_crystal set report_params =
  '~NULL~NULL'+REPLACE(REPLACE(CONVERT(VARCHAR(MAX),report_params), 'NULL~', ''), 'False~', '')+'NULL~NULL~NULL~NULL~'
   WHERE template like '%Prepaid%'

   SELECT * FROM reports_crystal WHERE entity =1843



EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SourceNode:; 1000;0;DEFAULT:NULL
EDITBOX=terminalID:; 40;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=TotalsGroup:; 512;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL

~NULL~NULL~SWTZIBsrc~NULL~1SO57~NULL~NULL~NULL~NULL~
~NULL~NULL~SWTZIBsrc~1SO57~NULL~NULL~NULL~NULL~NULL
,


~NULL~NULL~SWTEBNsrc,SWTOBIsrc~1S050,1S056~NULL~NULL~NULL~NULL~NULL~

~NULL~NULL~SWTZIBsrc~1SO57~NULL~NULL~NULL~NULL~NULL~

EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SourceNode:; 1000;0;DEFAULT:NULL
EDITBOX=terminalID:; 40;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=TotalsGroup:; 512;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL

~NULL~NULL~SWTGTBsnk,SWTGTB1snk~058~627787,506103~False~NULL~NULL~GTB,GTBGroup,GTBCCGroup,GTBSBGroup,GTBMCDebit~
PrepaidCardLoad_csv

EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SinkNode:; 40;0;DEFAULT:NULL
EDITBOX=CBNCodes:; 40;0;DEFAULT:NULL
EDITBOX=totalsgroups:; 40;0;DEFAULT:NULL
EDITBOX=ALLBINs:; 255;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
	~NULL~NULL~SWTABSCCsnk,SWTABSCC1snk~130~sss~false~NULL~NULL~ABS~


	SELECT CONVERT(VARCHAR(MAX),report_params), * FROM reports_crystal WHERE

EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SinkNode:; 40;0;DEFAULT:NULL
EDITBOX=CBNCodes:; 40;0;DEFAULT:NULL
EDITBOX=totalsgroups:; 40;0;DEFAULT:NULL
EDITBOX=ALLBINs:; 255;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL


EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=SinkNode:; 40;0;DEFAULT:NULL
EDITBOX=CBNCodes:; 40;0;DEFAULT:NULL
EDITBOX=ALLBINs:; 1000;0;DEFAULT:NULL
EDITBOX=totalsgroups:; 40;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL

~NULL~NULL~20141231~20150104~SWTDBLsnk,SWTDBL1snk,SWTEXPERTsnk~063~627168~DBLGroup,DBLCCGroup,DBL~NULL~NULL~NULL


EDITBOX=StartDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=EndDate in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=AcquiringBIN:; 25;0;DEFAULT:NULL
EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL
EDITBOX=report_date_start in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=report_date_end in 'yyyymmdd' format:; 30;1;DEFAULT:NULL
EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL


