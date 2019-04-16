DECLARE @successful FLOAT;
DECLARE @unsuccessful FLOAT;
DECLARE @total FLOAT;
DECLARE @sink_node_name VARCHAR(50);
DECLARE @startDate VARCHAR(50);
DECLARE @endDate VARCHAR(50);

SET @sink_node_name='ASPPWCsnk';

SET @startDate = '2014-08-01';

SET @endDate = '2014-08-31';

SELECT @successful= COUNT(post_tran_cust_id)  FROM post_tran (NOLOCK) WHERE sink_node_name	IN (@sink_node_name) AND datetime_req  BETWEEN @startDate AND @endDate AND rsp_code_rsp='00';
SELECT @unsuccessful =COUNT(post_tran_cust_id)  FROM post_tran (NOLOCK) WHERE sink_node_name IN (@sink_node_name) AND datetime_req  BETWEEN @startDate AND @endDate AND rsp_code_rsp='91';
SELECT @total= @successful+ @unsuccessful; 
SELECT @sink_node_name  sink_node_name, @successful successful, @unsuccessful unsuccessful,@total total,  @successful/@total * 100.0 success_percentage

--sink_node_name	successful	unsuccessful	total	success_percentage