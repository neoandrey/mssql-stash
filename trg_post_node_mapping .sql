CREATE TRIGGER  trg_post_node_mapping ON post_online_node
AFTER INSERT
AS BEGIN

DECLARE @online_system_id INT;

DECLARE  online_sys_id CURSOR	 LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT online_system_id  FROM post_online_system
OPEN online_sys_id


FETCH NEXT FROM online_sys_id INTO  @online_system_id;
WHILE(@@FETCH_STATUS=0) BEGIN
SELECT online_system_id, online_node_name, office_node_name INTO #temp_online_nodes FROM post_online_node WHERE online_system_id =@online_system_id

INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
SELECT @online_system_id, online_node_name, office_node_name FROM #temp_online_nodes 
WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id =@online_system_id)
DROP TABLE #temp_online_nodes;
FETCH NEXT FROM online_sys_id INTO  @online_system_id;
END
CLOSE online_sys_id
DeALLOCATE online_sys_id


END

