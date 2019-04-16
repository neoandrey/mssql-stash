ALTER INDEX ix_post_tran_1 ON post_tran REBUILD WITH (ONLINE=ON);
ALTER INDEX ix_post_tran_2 ON post_tran REBUILD WITH (ONLINE=ON);
ALTER INDEX ix_post_tran_3 ON post_tran REBUILD WITH (ONLINE=ON);
ALTER INDEX ix_post_tran_4 ON post_tran REBUILD WITH (ONLINE=ON); 
ALTER INDEX ix_post_tran_5 ON post_tran REBUILD WITH (ONLINE=ON); 

ALTER INDEX ix_post_tran_7 ON post_tran REBUILD WITH (ONLINE=ON); 
ALTER INDEX ix_post_tran_8 ON post_tran REBUILD WITH (ONLINE=ON); 
ALTER INDEX ix_post_tran_9 ON post_tran REBUILD WITH (ONLINE=ON); 
ALTER INDEX ix_post_tran_10 ON post_tran REBUILD WITH (ONLINE=ON); 


ALTER INDEX ALL ON post_tran_cust REBUILD WITH (ONLINE=ON) ; 



DBCC DBREINDEX ('post_tran', 'ix_post_tran_1', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_2', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_3', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_4', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_5', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_7', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_8', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_9', 90)
DBCC DBREINDEX ('post_tran', 'ix_post_tran_10',90)

DBCC DBREINDEX ('post_tran_cust', 'ix_post_tran_10',90)


DBCC DBREINDEX ('post_tran_cust','', 90)