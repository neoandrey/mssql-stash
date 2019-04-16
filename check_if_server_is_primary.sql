CREATE FUNCTION [dbo].[svf_AgReplicaState](@availability_group_name sysname)
RETURNS bit
AS
BEGIN

if EXISTS(
    SELECT        ag.name
    FROM            sys.dm_hadr_availability_replica_states AS ars INNER JOIN
                             sys.availability_groups AS ag ON ars.group_id = ag.group_id
    WHERE        (ars.is_local = 1) AND (ars.role_desc = 'PRIMARY') AND (ag.name = @availability_group_name))

    RETURN 1

RETURN 0

END

