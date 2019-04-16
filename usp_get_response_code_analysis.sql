
CREATE PROCEDURE usp_get_response_code_analysis (@start_date DATETIME,@end_date DATETIME )

AS 

BEGIN

SET @start_date    = ISNULL(@start_date, GETDATE());
SET @end_date      = ISNULL(@end_date, DATEADD(DAY, 1, @end_date ));

	SELECT  sink_node_name,dbo.formatRspCodeStr(pt.rsp_code_rsp) AS Response_Code_description, pt.rsp_code_rsp,COUNT (rsp_code_rsp) as tran_count,
	FROM post_tran pt (nolock)
	INNER JOIN post_tran_cust ptc (nolock)
	ON pt.post_tran_cust_id = ptc.post_tran_cust_id
	WHERE 

	 (pt.tran_postilion_originated=0)
	AND (pt.tran_completed=1)
	AND pt.sink_node_name not in ('PAYDIRECTsnk','BILLSsnk','VTUsnk','CCLOADsnk','FDsnk')
	AND pt.sink_node_name not like '%MDS%'
	AND pt.sink_node_name not like '%MCC%'
        AND ptc.pan not like '506%'
        AND ptc.pan like '5%'
        AND (pt.datetime_req  BETWEEN  @start_date AND @end_date) 
	GROUP BY sink_node_name, pt.rsp_code_rsp
	ORDER BY sink_node_name
	
END
	
