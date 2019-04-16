drop table #COPIED_TABLES
CREATE TABLE #COPIED_TABLES (id INT identity(1,1) , TABLE_NAME varchar(500))

insert into #COPIED_TABLES
SELECT  TABLE_NAME     FROM INFORMATION_SCHEMA.TABLES  --where left(TABLE_NAME,4) in ('SSTL','SPAY','SPST')
 AND TABLE_NAME NOT IN 
 
 (
SELECT OBJECT_NAME(f.parent_object_id)
   
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc
ON f.OBJECT_ID = fc.constraint_object_id)
AND TABLE_TYPE= 'BASE TABLE'

run_insert:
INSERT INTO #COPIED_TABLES
SELECT   OBJECT_NAME(f.parent_object_id) AS TableName
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc
ON f.OBJECT_ID = fc.constraint_object_id
AND  OBJECT_NAME (f.referenced_object_id)  IN ( SELECT TABLE_NAME FROM #COPIED_TABLES)
AND OBJECT_NAME(f.parent_object_id) NOT IN  ( SELECT TABLE_NAME FROM #COPIED_TABLES)
IF @@ROWCOUNT >0 GOTO run_insert

SELECT   * FROM   #COPIED_TABLES