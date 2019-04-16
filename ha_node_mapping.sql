
DECLARE @online_system_id INT;
DECLARE @online_system_id_ha INT;

SELECT @online_system_id=online_system_id FROM post_online_system WHERE name ='RealtimeLV'
SELECT @online_system_id_ha=online_system_id FROM post_online_system WHERE name ='RealtimeHA'

SELECT online_system_id, online_node_name, office_node_name INTO #temp_online_nodes FROM post_online_node WHERE online_system_id =@online_system_id

INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
SELECT @online_system_id, online_node_name, office_node_name FROM #temp_online_nodes 
WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id =@online_system_id)

INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
SELECT @online_system_id_ha, online_node_name, office_node_name FROM #temp_online_nodes 
WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id =@online_system_id_ha)