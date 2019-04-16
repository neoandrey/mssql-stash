CREATE TABLE daily_file_growth_stats( index_number BIGINT IDENTITY(1,1),
stats_logged_time DATETIME DEFAULT CURRENT_TIMESTAMP,DATABASE_NAME VARCHAR(30), [TOTAL_SIZE(MB)] FLOAT
);

INSERT INTO daily_file_growth_stats(DATABASE_NAME, [TOTAL_SIZE(MB)]) 

SELECT DB_NAME(database_id) , (SUM(size)*8.0)/(1024.0) FROM sys.master_files WHERE  DB_NAME(database_id) ='postilion_office'

GROUP BY database_id

SELECT * FROM daily_file_growth_stats

truncate table daily_file_growth_stats