ALTER procedure usp_sync_terminal_owner_table as
begin
set transaction isolation level  read uncommitteD
DECLARE @local_count int;
DECLARE @expected_count int;

SELECT   @local_count = COUNT (terminal_id) FROM tbl_terminal_owner;
SELECT   @expected_count = COUNT (terminal_id) FROM [172.25.15.15].[postilion_office].dbo.post_terminal (NOLOCK);

IF(@local_count!= @expected_count )BEGIN
DELETE FROM tbl_terminal_owner;
  INSERT  INTO tbl_terminal_owner (terminal_id, terminal_code) 
select distinct terminal_id, comms_info  from [172.25.15.15].[postilion_office].dbo.post_terminal (NOLOCK)
END
ELSE BEGIN

PRINT 'Tables are in sync. There is nothing to copy'
END


end

CREATE procedure usp_sync_ptsp_table as
begin
set transaction isolation level  read uncommitteD
DECLARE @local_count int;
DECLARE @expected_count int;

SELECT   @local_count = COUNT (terminal_id) FROM tbl_ptsp;
SELECT   @expected_count = COUNT (terminal_id) FROM [172.25.15.15].[postilion_office].dbo.post_terminal_has_client (NOLOCK);

IF(@local_count!= @expected_count )BEGIN
DELETE FROM tbl_ptsp;
  INSERT  INTO tbl_ptsp (terminal_id, PTSP_Code) 
select distinct terminal_id, participant_client_id  from [172.25.15.15].[postilion_office].dbo.post_terminal_has_client (NOLOCK)
END
ELSE BEGIN

PRINT 'Tables are in sync. There is nothing to copy'
END


end