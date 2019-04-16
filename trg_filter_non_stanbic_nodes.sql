USE [postilion_office]
GO
/****** Object:  Trigger [dbo].[trg_filter_non_stanbic_nodes]    Script Date: 07/14/2016 07:51:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER  [dbo].[trg_filter_non_stanbic_nodes] ON [dbo].[post_tran]
AFTER INSERT 
AS BEGIN
DECLARE @post_tran_cust_id_list TABLE (post_tran_cust_id BIGINT)
DECLARE @sink_node_name VARCHAR(50)
DECLARE @post_tran_cust_id BIGINT

SELECT @post_tran_cust_id =  post_tran_cust_id, @sink_node_name = sink_node_name  FROM inserted WHERE charindex( 'chb', sink_node_name) <0 
IF(@post_tran_cust_id IS NOT NULL) begin
DELETE FROM post_tran_cust WHERE post_tran_cust_id = @post_tran_cust_id  
DELETE FROM post_tran WHERE post_tran_cust_id  = @post_tran_cust_id      AND sink_node_name = @sink_node_name 
end
END




create TRIGGER  [dbo].[trg_filter_non_stanbic_exceptions] ON [dbo].[post_tran_exception]
AFTER INSERT 
AS BEGIN

DECLARE @tran_nr BIGINT
DECLARE @exception varchar(max)

SELECT @tran_nr   =  tran_nr   FROM inserted 

IF exists (SELECT tran_nr FROM  post_tran_exception (NOLOCK)  WHERE tran_nr  = @tran_nr and charindex( 'chb', exception)< 1) BEGIN
	UPDATE post_tran_exception SET  STATE = 20 WHERE tran_nr = @tran_nr
END
END