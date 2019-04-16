

create TRIGGER  [dbo].[trg_post_node_mapping_stanbic] ON [dbo].[post_online_node]
AFTER INSERT
AS BEGIN

DECLARE @virtual_system_id INT
DECLARE @online_system_id INT;

DECLARE  @temp_post_online_node TABLE (
	[online_system_id] [int] NOT NULL,
	[online_node_name] [varchar](12) NOT NULL,
	[office_node_name] [varchar](12) NOT NULL
)


DECLARE vitual_system_id_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT distinct virtual_system_id FROM  post_online_system (NOLOCK)
OPEN vitual_system_id_cursor
FETCH NEXT FROM vitual_system_id_cursor INTO @virtual_system_id
WHILE(@@FETCH_STATUS=0) BEGIN
	DECLARE  online_sys_id CURSOR	 LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT online_system_id  FROM post_online_system (NOLOCK) where virtual_system_id = @virtual_system_id
	OPEN online_sys_id
	FETCH NEXT FROM online_sys_id INTO  @online_system_id;
		WHILE(@@FETCH_STATUS=0) BEGIN
			INSERT INTO @temp_post_online_node SELECT online_system_id, online_node_name, office_node_name FROM post_online_node  (NOLOCK) WHERE online_system_id =@online_system_id
			INSERT INTO post_online_node_map (online_system_id, online_node_name, office_node_name)
			SELECT @online_system_id, online_node_name, office_node_name FROM @temp_post_online_node  WHERE online_node_name  NOT IN (select online_node_name from post_online_node_map WHERE online_system_id =@online_system_id)
			DELETE FROM @temp_post_online_node
			FETCH NEXT FROM online_sys_id INTO  @online_system_id;
		END
		CLOSE online_sys_id
		DEALLOCATE online_sys_id
	FETCH NEXT FROM vitual_system_id_cursor INTO  @virtual_system_id;
END
CLOSE vitual_system_id_cursor
DeALLOCATE vitual_system_id_cursor



DECLARE @super_switch_live_system INT
DECLARE @super_switch_dr_system INT
DECLARE @mega_switch_live_system INT
DECLARE @mega_switch_dr_system INT
DECLARE @asp_switch_live_system INT
DECLARE @asp_switch_dr_system INT

SET @super_switch_live_system = 1;
SET @super_switch_dr_system = 2;
SET @mega_switch_live_system  = 3;
SET @mega_switch_dr_system    =4;
SET @asp_switch_live_system   =5
SET @asp_switch_dr_system     = 6


DECLARE @super_switch_online_node_name VARCHAR(120)
DECLARE @merged_switch_online_node_data VARCHAR(MAX)
set @merged_switch_online_node_data ='';
DECLARE switch_column_data_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT online_node_name FROM post_online_node (NOLOCK) WHERE RIGHT(online_node_name, 3)='snk' AND  online_node_name NOT LIKE '%CHB%' AND online_system_id IN(@super_switch_live_system,@super_switch_dr_system)
OPEN switch_column_data_cursor
FETCH NEXT FROM switch_column_data_cursor INTO @super_switch_online_node_name
WHILE (@@FETCH_STATUS=0)BEGIN
	SET @merged_switch_online_node_data =@merged_switch_online_node_data+@super_switch_online_node_name+',';
	FETCH NEXT FROM switch_column_data_cursor INTO @super_switch_online_node_name
END
CLOSE column_data_cursor
DEALLOCATE switch_column_data_cursor
SET @merged_switch_online_node_data = SUBSTRING(@merged_switch_online_node_data, 1, LEN(@merged_switch_online_node_data)-1)
UPDATE [postilion_office].[dbo].[post_norm_entity_has_filter]SET  [param_list] =@merged_switch_online_node_data  WHERE online_system_id IN (@super_switch_live_system,@super_switch_dr_system)

DECLARE @mega_switch_online_node_name VARCHAR(120)
set @merged_switch_online_node_data ='';
DECLARE switch_column_data_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT online_node_name FROM post_online_node (NOLOCK) WHERE  RIGHT(online_node_name, 3)='snk' AND  online_node_name NOT LIKE '%CHB%' AND online_system_id IN (@mega_switch_live_system,@mega_switch_dr_system)
OPEN switch_column_data_cursor
FETCH NEXT FROM switch_column_data_cursor INTO @mega_switch_online_node_name
WHILE (@@FETCH_STATUS=0)BEGIN
	SET @merged_switch_online_node_data =@merged_switch_online_node_data+@mega_switch_online_node_name+',';
	FETCH NEXT FROM switch_column_data_cursor INTO @mega_switch_online_node_name
END
CLOSE column_data_cursor
DEALLOCATE switch_column_data_cursor
SET @merged_switch_online_node_data = SUBSTRING(@merged_switch_online_node_data, 1, LEN(@merged_switch_online_node_data)-1)
UPDATE [postilion_office].[dbo].[post_norm_entity_has_filter]SET  [param_list] =@merged_switch_online_node_data  WHERE online_system_id IN (@mega_switch_live_system,@mega_switch_dr_system)

DECLARE @asp_switch_online_node_name VARCHAR(120)
set @merged_switch_online_node_data ='';
DECLARE switch_column_data_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT online_node_name FROM post_online_node (NOLOCK) WHERE RIGHT(online_node_name, 3)='snk' AND  online_node_name NOT LIKE '%CHB%' AND online_system_id IN(@asp_switch_live_system,@asp_switch_dr_system)
OPEN switch_column_data_cursor
FETCH NEXT FROM switch_column_data_cursor INTO @asp_switch_online_node_name
WHILE (@@FETCH_STATUS=0)BEGIN
	SET @merged_switch_online_node_data =@merged_switch_online_node_data+@asp_switch_online_node_name+',';
	FETCH NEXT FROM switch_column_data_cursor INTO @asp_switch_online_node_name
END
CLOSE column_data_cursor
DEALLOCATE switch_column_data_cursor
SET @merged_switch_online_node_data = SUBSTRING(@merged_switch_online_node_data, 1, LEN(@merged_switch_online_node_data)-1)
UPDATE [postilion_office].[dbo].[post_norm_entity_has_filter]SET  [param_list] =@merged_switch_online_node_data  WHERE online_system_id IN (@asp_switch_live_system,@asp_switch_dr_system)



END

GO