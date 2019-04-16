CREATE DATABASE postilion_office ON PRIMARY
(NAME='postilion_office_db',
FILENAME='F:\sqldata2\MSSQL\post_office_db.mdf')
 LOG ON
 (NAME='postilion_office_log', 
 FILENAME='E:\sql_data2\post_office_log_.ldf')
 
   ALTER DATABASE postilion_office ADD FILE (
 
   NAME = 'USER_DATA1',
    FILENAME = 'E:\sqldata2\post_office9_db.ndf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
    )
       ALTER DATABASE postilion_office ADD FILE (
     
       NAME = 'USER_DATA2',
        FILENAME = 'J:\sqldata2\post_office10_db.ndf',
        SIZE = 5MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB
    )
           ALTER DATABASE postilion_office ADD FILE (
         
           NAME = 'USER_DATA3',
            FILENAME = 'J:\sqldata2\post_office11_db.ndf',
            SIZE = 5MB,
            MAXSIZE = 100MB,
            FILEGROWTH = 5MB
    )
               ALTER DATABASE postilion_office ADD FILE (
             
               NAME = 'USER_DATA4',
                FILENAME = 'D:\sqldata2\USER_DATA4_data.ndf',
                SIZE = 5MB,
                MAXSIZE = 100MB,
                FILEGROWTH = 5MB
    )
                   ALTER DATABASE postilion_office ADD FILE (
                 
                   NAME = 'post_office_ext',
                    FILENAME = 'J:\sqldata2\post_office_ext_Data.NDF',
                    SIZE = 5MB,
                    MAXSIZE = 100MB,
                    FILEGROWTH = 5MB
    )
    
     ALTER DATABASE postilion_office ADD LOG FILE (
                 
                    NAME = 'postilion_office_1_Log',
                    FILENAME = 'F:\sqldata2\postilion_office_log_2.ldf',
                    SIZE = 5MB,
                    MAXSIZE = 100MB,
                    FILEGROWTH = 5MB
    )
         ALTER DATABASE postilion_office ADD LOG FILE (
                     
                        NAME = 'postilion_office_2_Log',
                        FILENAME = 'I:\sqldata2\postilion_office_2_Log.ldf',
                        SIZE = 5MB,
                        MAXSIZE = 100MB,
                        FILEGROWTH = 5MB
    )