--SELECT * FROM post_ds_nodes WHERE calendar_date >='20151129'
--SELECT * FROM post_datasummary_session WHERE datetime_process_run IN  (40,41)
--SELECT * FROM post_ds_nodes_session  WHERE session_id IN  (40,41)
--SELECT * FROM post_ds_nodes  WHERE session_id IN  (40,41)


SELECT * FROM post_ds_nodes_session
DECLARE @max_session_id INT 



DECLARE @max_session_id INT 


DECLARE @start_date DATETIME 
DECLARE @end_date  DATETIME 

SET @start_date='20151101'
SET  @end_date= DATEADD(D, 1,@start_date );

WHILE (@start_date< '2015-11-12 00:00:00') BEGIN
SELECT @max_session_id =( MAX(session_id)+1) FROM post_ds_nodes_session 

insert into  post_datasummary_session values  ('Nodes', @max_session_id, 1, GETDATE())

insert into post_ds_nodes_session values (@max_session_id,@start_date,@end_date)

INSERT INTO post_ds_nodes(
calendar_date
,source_node_name
,sink_node_name
,message_type
,tran_type
,extended_tran_type
,rsp_code
,recon_business_date
,tran_postilion_originated
,postilion_stand_in
,tran_aborted
,settle_amount_currency
,nr_trans
,settle_amount_impact
,surcharge_amount_impact
,avg_rsp_time
,session_id
) SELECT 
calendar_date
,source_node_name
,sink_node_name
,message_type
,tran_type
,extended_tran_type
,rsp_code
,recon_business_date
,tran_postilion_originated
,postilion_stand_in
,tran_aborted
,settle_amount_currency
,nr_trans
,settle_amount_impact
,surcharge_amount_impact
,avg_rsp_time
,@max_session_id

 FROM [172.25.10.9].[postilion_office].dbo.[post_ds_nodes]
WHERE recon_business_date  =@start_date

SET @start_date= DATEADD(D, 1,@start_date );
SET  @end_date= DATEADD(D, 1,@start_date );
END



DECLARE @start_date DATETIME 
DECLARE @end_date  DATETIME 

SET @start_date='20151111'
SET  @end_date= DATEADD(D, 1,@start_date );
--WHILE (@start_date< '2015-11-12 00:00:00') BEGIN
SELECT @max_session_id =( MAX(session_id)+1) FROM post_ds_nodes_session 

insert into  post_datasummary_session values  ('Nodes', @max_session_id, 1, GETDATE())

insert into post_ds_nodes_session values (@max_session_id,@start_date,@end_date)

INSERT INTO post_ds_nodes(
calendar_date
,source_node_name
,sink_node_name
,message_type
,tran_type
,extended_tran_type
,rsp_code
,recon_business_date
,tran_postilion_originated
,postilion_stand_in
,tran_aborted
,settle_amount_currency
,nr_trans
,settle_amount_impact
,surcharge_amount_impact
,avg_rsp_time
,session_id
) SELECT 
calendar_date
,source_node_name
,sink_node_name
,message_type
,tran_type
,extended_tran_type
,rsp_code
,recon_business_date
,tran_postilion_originated
,postilion_stand_in
,tran_aborted
,settle_amount_currency
,nr_trans
,settle_amount_impact
,surcharge_amount_impact
,avg_rsp_time
,@max_session_id

 FROM [172.75.75.26].[postilion_office].dbo.[post_ds_nodes]
WHERE recon_business_date  =@start_date

SET @start_date= DATEADD(D, 1,@start_date );
SET  @end_date= DATEADD(D, 1,@start_date );
--END
--sp_help post_ds_nodes
----SELECT * into post_ds_nodes_backup  FROM post_ds_nodes
--SELECT * FROM sp_help post_ds_nodes_session
