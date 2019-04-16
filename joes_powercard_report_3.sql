
DECLARE @successful FLOAT;
DECLARE @unsuccessful FLOAT;
DECLARE @total FLOAT;
DECLARE @sink_node_name VARCHAR(50);
DECLARE @startDate VARCHAR(50);
DECLARE @endDate VARCHAR(50);
DROP TABLE #sink_nodes
SET @sink_node_name='MEGAPWCsnk,MEGAPWC2snk';
CREATE TABLE #sink_nodes (sink_node_name VARCHAR(200));
INSERT INTO #sink_nodes (sink_node_name) SELECT part FROM usf_split_string('MEGAPWCsnk,MEGAPWC2snk',',')

SET @startDate = '2014-06-01';

SET @endDate = '2014-06-30';

SELECT @successful= COUNT(post_tran_cust_id)  FROM isw_data_megaoffice (NOLOCK) WHERE sink_node_name	IN (SELECT sink_node_name FROM #sink_nodes) AND datetime_req  BETWEEN @startDate AND @endDate AND rsp_code_rsp='00';
SELECT @unsuccessful =COUNT(post_tran_cust_id)  FROM isw_data_megaoffice (NOLOCK) WHERE sink_node_name IN (SELECT sink_node_name FROM #sink_nodes) AND datetime_req  BETWEEN @startDate AND @endDate AND rsp_code_rsp='91';
SELECT @total= @successful+ @unsuccessful; 
SELECT @sink_node_name  sink_node_name, @successful successful, @unsuccessful unsuccessful,@total total,  @successful/@total * 100.0 success_percentage

sink_node_name	        successful	unsuccessful	total	success_percentage
MEGAPWCsnk,MEGAPWC2snk	 4202	125	         4327	   97.1111624682228