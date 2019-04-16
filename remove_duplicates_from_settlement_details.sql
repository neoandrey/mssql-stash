DECLARE @entry_id BIGINT
 DECLARE @duplicate_entry_table TABLE( entry_id BIGINT)
 DECLARE @index BIGINT
 insert into @duplicate_entry_table  SELECT entry_id from settlement_summary_breakdown_details_20170426 (nolock) GROUP BY entry_id HAVING COUNT(entry_id) >1
 DECLARE entry_id_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  entry_id FROM @duplicate_entry_table
 OPEN entry_id_cursor
 FETCH NEXT FROM entry_id_cursor INTO @entry_id
 WHILE (@@FETCH_STATUS = 0 )BEGIN
 SELECT TOP 1 @index = index_no FROM  settlement_summary_breakdown_details_20170426(nolock) WHERE entry_id  = @entry_id

 DELETE FROM settlement_summary_breakdown_details_20170426 WHERE entry_id = @entry_id AND index_no != @index
  FETCH NEXT FROM entry_id_cursor INTO @entry_id
 END
 CLOSE entry_id_cursor
 DEALLOCATE  entry_id_cursor 
