1) Create & backup database test_mirror to disk='d:\test_mirror.bkp'

2) backup log test_mirror to disk='d:\test_mirror_log.bkp'

3) move the backup file into destination server

4) Restore the database with norecovery

RESTORE DATABASE [test_mirror] FROM DISK = N'd:\test_mirror.bkp' WITH FILE = 1,

NORECOVERY, NOUNLOAD, REPLACE, STATS = 10
GO

5) Restore the log with norecovery

RESTORE log [test_mirror] FROM DISK = N'd:\test_mirror_log.bkp' WITH FILE = 1,

NORECOVERY, NOUNLOAD, REPLACE, STATS = 10

6) Configure the mirroring

a) Select test_mirror database right click - go to tasks - select mirror
b) Configure the Security using configure Security button. It will prompt for the

connections and authentication. You can configure different servers or 2 instances for

mirroring.
c) As first step it will ask for Witness server, this is optional. Witness server

can be configured to watch the mirroring from different server.
d) Principal and Mirror servers can be configured using next steps.
e) Select Operating Mode either Asynchronous(high performance) or Synchronous (high protection).
Asynchronous is nothing but changes will happend at principal server first then changes pass to mirror server.
Synchronous is like changes will happend same time at both the servers.


7) create the test table before start the mirroring.

create table test_1(regno numeric)


8) Start the mirroring

9) create the test_2 table after start the mirroring

create table test_2(regno numeric)

10) Create the snapshot copy in destination

CREATE DATABASE test_mirror_copy ON
(
NAME = test_mirror,
FILENAME = 'd:\testmirror.ss'
)
AS SNAPSHOT OF test_mirror

11) In the snapshot copy I can see both test-1 and test_2 tables.


12) Insert data into test_1 table

insert into test_1 values(1)

13) drop the existing snapshot

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'test_mirror_copy'
GO
USE [master]
GO
/****** Object: Database [test_mirror_copy] Script Date: 03/18/2009 05:38:05 ******/
DROP DATABASE [test_mirror_copy]
GO


14) create the new snapshot

CREATE DATABASE test_mirror_copy ON
(
NAME = test_mirror,
FILENAME = 'd:\testmirror.ss'
)
AS SNAPSHOT OF test_mirror

15) So we can able to see one row in test_1 table. It means mirror happening from

principle to mirror server.

