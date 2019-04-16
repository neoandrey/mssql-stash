with fk_tables as (
    select    s1.name as from_schema    
    ,        o1.Name as from_table    
    ,        s2.name as to_schema    
    ,        o2.Name as to_table    
    from    sys.foreign_keys fk    
    inner    join sys.objects o1    
    on        fk.parent_object_id = o1.object_id    
    inner    join sys.schemas s1    
    on        o1.schema_id = s1.schema_id    
    inner    join sys.objects o2    
    on        fk.referenced_object_id = o2.object_id    
    inner    join sys.schemas s2    
    on        o2.schema_id = s2.schema_id    
    /*For the purposes of finding dependency hierarchy       
        we're not worried about self-referencing tables*/
    where    not    (    s1.name = s2.name                 
            and        o1.name = o2.name)
)
,ordered_tables AS 
(        SELECT    s.name as schemaName
        ,        t.name as tableName
        ,        0 AS Level    
        FROM    (    select    *                
                    from    sys.tables                 
                    where    name <> 'sysdiagrams') t    
        INNER    JOIN sys.schemas s    
        on        t.schema_id = s.schema_id    
        LEFT    OUTER JOIN fk_tables fk    
        ON        s.name = fk.from_schema    
        AND        t.name = fk.from_table    
        WHERE    fk.from_schema IS NULL
        UNION    ALL
        SELECT    fk.from_schema
        ,        fk.from_table
        ,        ot.Level + 1    
        FROM    fk_tables fk    
        INNER    JOIN ordered_tables ot    
        ON        fk.to_schema = ot.schemaName    
        AND        fk.to_table = ot.tableName
)select    distinct    ot.schemaName
,        ot.tableName
,        ot.Level
from    ordered_tables ot
inner    join (
        select    schemaName
        ,        tableName
        ,        MAX(Level) maxLevel        
        from    ordered_tables        
        group    by schemaName,tableName
        ) mx
on        ot.schemaName = mx.schemaName
and        ot.tableName = mx.tableName
and        mx.maxLevel = ot.Level;