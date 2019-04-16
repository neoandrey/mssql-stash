backup original realtime database
backup original keystore folder
backup and delete original .binding file in realtime/datasources  folder
Restore backup of realtime server on new server
copy keystore folder from realtime

Run the following script:

UPDATE tasks SET HOST ='LOCALHOST'
UPDATE  [realtime].[dbo].[cfg_system_properties] set value = 'LOCALHOST' WHERE property ='postilion.env.database_server'
UPDATE  [realtime].[dbo].[cfg_system_properties] set value = 'LOCALHOST' WHERE property ='postilion.env.server_host_name'
UPDATE [realtime].[dbo].[tm_nodes]  SET    ip_address = replace(ip_address,'172.75.75.9', 'LOCALHOST' )
UPDATE [realtime].[dbo].[node_conns] SET address = replace(address,'172.75.75.9', 'LOCALHOST' )
UPDATE [realtime].[dbo].[node_saps]   SET address = replace(address,'172.75.75.9', 'LOCALHOST' )