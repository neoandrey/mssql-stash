 SELECT TOP 100  structured_data_rsp
 ,CASE WHEN CHARINDEX ('BufferC',structured_data_rsp)> 0 then  SUBSTRING(structured_data_rsp, CHARINDEX('BufferC>',structured_data_rsp)+8, CHARINDEX('</BufferC>',structured_data_rsp) -(CHARINDEX('BufferC>',structured_data_rsp)+8)) else structured_data_rsp end
 ,* FROM  post_tran (NOLOCK) WHERE convert(varchar(max), structured_data_rsp) LIKE '%bufferc%'
 AND
 SUBSTRING(structured_data_rsp, CHARINDEX('BufferC>',structured_data_rsp)+8, CHARINDEX('</BufferC>',structured_data_rsp) -(CHARINDEX('BufferC>',structured_data_rsp)+8)) ='1260426936'