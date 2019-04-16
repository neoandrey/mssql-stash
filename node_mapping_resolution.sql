

DECLARE @realtime_system_name_1  VARCHAR(20);
DECLARE @realtime_system_name_2  VARCHAR(20);
DECLARE @realtime_system_id_1  INT;
DECLARE @realtime_system_id_2  INT;

SET  @realtime_system_name_1  ='Realtime';
SET  @realtime_system_name_2 ='Realtime2';

SELECT @realtime_system_id_1  = online_system_id FROM post_online_system  WHERE name = @realtime_system_name_1;
SELECT @realtime_system_id_2  = online_system_id FROM post_online_system  WHERE name = @realtime_system_name_2;

SELECT online_system_id, online_node_name, office_node_name INTO #temp_online_nodes FROM post_online_node WHERE online_system_id =@realtime_system_id_1


INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
SELECT  @realtime_system_id_1 , online_node_name, office_node_name FROM #temp_online_nodes 
WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id = @realtime_system_id_1 )

INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
SELECT  @realtime_system_id_2 , online_node_name, office_node_name FROM #temp_online_nodes 
WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id = @realtime_system_id_2 )