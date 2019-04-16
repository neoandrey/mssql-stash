BACKUP DATABASE  [AirtimeRecon] TO  DISK='\\172.36.1.45\db_nas\etloader\weekly_full\airtime_20180404.bak'  WITH FORMAT,BUFFERCOUNT=15, MAXTRANSFERSIZE =3145728;

BACKUP LOG  [AirtimeRecon] TO  DISK='\\172.36.1.45\db_nas\etloader\transaction_logs\airtime_20180404_log.trn' WITH FORMAT



ALTER AVAILABILITY GROUP [etloader-dag] ADD DATABASE [AirtimeRecon]

RESTORE database [AirtimeRecon] FROM DISK ='\\172.36.1.45\db_nas\etloader\weekly_full\airtime_20180404.bak'  WITH NORECOVERY,REPLACE
RESTORE LOG [AirtimeRecon]  FROM   DISK='\\172.36.1.45\db_nas\etloader\transaction_logs\airtime_20180404_log.trn' WITH NORECOVERY
alter database [AirtimeRecon]  set  HADR RESUME


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'etloader-dag'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [AirtimeRecon] SET HADR AVAILABILITY GROUP = [etloader-dag];

GO
alter database [AirtimeRecon]  set  HADR RESUME
go


