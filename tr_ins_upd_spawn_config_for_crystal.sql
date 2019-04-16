 ALTER TRIGGER tr_ins_upd_spawn_config_for_crystal ON reports_crystal  
FOR INSERT, UPDATE  
AS  
BEGIN  
        DECLARE @entity_name VARCHAR(max)  
        DECLARE @entity_id   INT  
        DECLARE @version     INT  
        DECLARE @path        VARCHAR(255)  
  
        DECLARE cur_inserted_entity CURSOR FOR  
        SELECT entity, crystal_version, name   
        FROM   
                        inserted ins   
                JOIN   
                        reports_entity re WITH (NOLOCK)  
                ON  
                        ins.entity = re.entity_id  
  
        OPEN    cur_inserted_entity               
        FETCH NEXT FROM cur_inserted_entity INTO @entity_id, @version, @entity_name  
  
        WHILE @@FETCH_STATUS = 0  
        BEGIN  
                IF (@version = 115)  
                        SET @path = 'C:\postilion\Office\Reports\Crystal\bin'  
                ELSE  
      IF (@version = 90)  
                        SET @path = 'C:\postilion\Office\Reports\Crystal\bin90'  
      ELSE  
                        SET @path = 'C:\postilion\Office\Reports\Crystal\bin'      
         
                IF NOT EXISTS(SELECT 1 FROM post_process_spawn_config (NOLOCK)WHERE (entity_name = @entity_name AND process_name = 'Reports') )  
                BEGIN  IF(LEN(@entity_name)<255)  
                 BEGIN
                        INSERT INTO   
                                post_process_spawn_config(process_name, entity_name, default_path)  
                        VALUES  
                                ('Reports',  @entity_name,  @path) 
                                END ELSE  
                                 INSERT INTO   
                                post_process_spawn_config(process_name, entity_name, default_path)  
                        VALUES  
                                ('Reports',  SUBSTRING(@entity_name, 1,200),  @path)
                                
                                
                END  
                ELSE  
                BEGIN  
                        UPDATE post_process_spawn_config  
                        SET  
                              --  entity_name = CONVERT(VARCHAR(255), @entity_name),  
                                default_path =   @path
                        WHERE  
                                (entity_name = CONVERT(VARCHAR(200), @entity_name) AND process_name = 'Reports')  
                END  
  
     UPDATE   
      post_process_spawn_config  
     SET  
      jvm_dll = null -- Reports processes should not be started with the Microsoft VM  
     WHERE  
      entity_name = CONVERT(VARCHAR(255), @entity_name)   
      AND   
      process_name = 'Reports'  
      AND  
      jvm_dll = 'msjava.dll'  
  
                FETCH NEXT FROM cur_inserted_entity INTO @entity_id, @version,  @entity_name    
        END  
  
        CLOSE cur_inserted_entity  
        DEALLOCATE cur_inserted_entity  
END  
   