DECLARE @min_templated_id BIGINT
DECLARE @max_templated_id BIGINT
DECLARE @new_templated_id BIGINT
DECLARE @counter BIGINT = 0
DECLARE @templated_id_table TABLE (template_id BIGINT)
SELECT  @min_templated_id= ISNULL(MIN(template_id),-2126057116),@max_templated_id = ISNULL(MAX(template_id),2140118795) FROM reports_crystal_template (NOLOCK)
SET @counter = @min_templated_id
WHILE (@counter <=@max_templated_id)BEGIN
IF NOT EXISTS(SELECT template FROM reports_crystal_template(NOLOCK) WHERE template_id = @counter) BEGIN
insert into @templated_id_table values(@counter)
break;
END
SELECT @counter =@counter+1;
END

SELECT * FROM @templated_id_table




INSERT INTO reports_template VALUES (@templated_id, 'Crystal','NIBSS_POS _Acquirer Detail-Eloho2', 'Balancing')

INSERT INTO reports_crystal_template VALUES(@templated_id_table, 'Office\base\reports\Balancing\NIBSS_POS _Acquirer Detail-Eloho2.rpt', 
 'EDITBOX=StartDate in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=EndDate in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=merchants:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=sourceNodes:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=report_date_start in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=report_date_end in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=rpt_tran_id1:; 1000;0;DEFAULT:NULL'
)

DECLARE @new_entity_id INT 

SELECT @new_entity_id = (MAX(entity_id)+1) FROM reports_entity (NOLOCK)

INSERT INTO reports_entity VALUES (3420, 'NIBSS_ACQUIRED_POS_NIBSS','Crystal', NULL,templated_id)   -- entity_name is user defined

insert into reports_crystal values (3420 
,'C:\postilion\Office\base\reports\NIBSS_POS _Acquirer Detail-Eloho2.rpt'
, 0
,9  --csv   or 12 for pdf  :gp
,'~~3~''''~' --csv   or  '~~1~1~' for pdf
,''
,90
,null
,null
,1)