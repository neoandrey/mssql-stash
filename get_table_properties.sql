 SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.yourTableName') 
 
 
 select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='tablenName'
 
 SELECT 
     T.TABLE_NAME AS 'TABLE NAME',
     C.COLUMN_NAME AS 'COLUMN NAME'
 FROM INFORMATION_SCHEMA.TABLES T
 INNER JOIN INFORMATION_SCHEMA.COLUMNS C ON T.TABLE_NAME=C.TABLE_NAME
     WHERE   T.TABLE_TYPE='BASE TABLE'
            AND T.TABLE_NAME LIKE 'Your Table Name'
            
 
 SELECT o.Name                   as Table_Name
      , c.Name                   as Field_Name
      , t.Name                   as Data_Type
      , t.length                 as Length_Size
      , t.prec                   as Precision_
 FROM syscolumns c 
      INNER JOIN sysobjects o ON o.id = c.id
      LEFT JOIN  systypes t on t.xtype = c.xtype  
 WHERE o.type = 'U' 
ORDER BY o.Name, c.Name



exec sp_columns executionLog