ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201408]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201409]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201410]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201411]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201412]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201501]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201502]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201503]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201504]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201505]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201506]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201507]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201508]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201509]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201510]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201511]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201512]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201601]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201602]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201603]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201604]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201605]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201606]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201607]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201608]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201609]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201610]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201611]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201612]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201701]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201702]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201703]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201704]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201705]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201706]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201707]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201708]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201709]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201710]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201711]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201712]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201801]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201802]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201803]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201804]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201805]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201806]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201807]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201808]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201809]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201810]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201811]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201812]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201901]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201902]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201903]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201904]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201905]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201906]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201907]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201908]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201909]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201910]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201911]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_201912]
ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_default]

ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201408', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201408.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201408]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201409', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201409.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201409]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201410', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201410.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201410]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201411', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201411.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201411]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201412', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201412.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201412]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201501', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201501.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201501]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201502', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201502.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201502]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201503', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201503.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201503]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201504', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201504.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201504]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201505', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201505.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201505]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201506', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201506.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201506]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201507', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201507.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201507]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201508', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201508.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201508]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201509', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201509.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201509]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201510', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201510.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201510]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201511', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201511.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201511]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201512', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201512.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201512]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201601', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201601.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201601]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201602', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201602.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201602]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201603', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201603.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201603]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201604', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201604.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201604]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201605', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201605.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201605]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201606', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201606.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201606]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201607', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201607.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201607]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201608', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201608.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201608]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201609', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201609.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201609]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201610', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201610.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201610]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201611', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201611.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201611]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201612', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201612.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201612]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201701', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201701.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201701]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201702', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201702.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201702]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201703', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201703.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201703]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201704', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201704.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201704]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201705', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201705.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201705]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201706', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201706.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201706]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201707', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201707.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201707]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201708', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201708.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201708]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201709', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201709.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201709]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201710', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201710.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201710]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201711', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201711.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201711]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201712', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201712.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201712]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201801', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201801.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201801]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201802', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201802.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201802]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201803', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201803.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201803]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201804', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201804.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201804]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201805', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201805.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201805]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201806', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201806.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201806]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201807', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201807.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201807]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201808', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201808.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201808]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201809', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201809.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201809]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201810', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201810.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201810]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201811', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201811.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201811]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201812', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201812.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201812]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201901', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201901.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201901]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201902', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201902.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201902]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201903', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201903.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201903]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201904', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201904.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201904]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201905', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201905.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201905]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201906', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201906.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201906]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201907', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201907.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201907]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201908', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201908.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201908]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201909', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201909.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201909]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201910', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201910.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201910]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201911', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201911.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201911]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_file_201912', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_201912.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_201912]
ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N'tbl_transactions_default_file', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_202001.ndf', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_default]


 CREATE PARTITION FUNCTION partition_vtuvcare_transactions_db_by_month (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  
'2014-08-31 23:59:59.999',
'2014-09-30 23:59:59.999',
'2014-10-31 23:59:59.999',
'2014-11-30 23:59:59.999',
'2014-12-31 23:59:59.999',
'2015-01-31 23:59:59.999',
'2015-02-28 23:59:59.999',
'2015-03-31 23:59:59.999',
'2015-04-30 23:59:59.999',
'2015-05-31 23:59:59.999',
'2015-06-30 23:59:59.999',
'2015-07-31 23:59:59.999',
'2015-08-31 23:59:59.999',
'2015-09-30 23:59:59.999',
'2015-10-31 23:59:59.999',
'2015-11-30 23:59:59.999',
'2015-12-31 23:59:59.999',
'2016-01-31 23:59:59.999',
'2016-02-29 23:59:59.999',
'2016-03-31 23:59:59.999',
'2016-04-30 23:59:59.999',
'2016-05-31 23:59:59.999',
'2016-06-30 23:59:59.999',
'2016-07-31 23:59:59.999',
'2016-08-31 23:59:59.999',
'2016-09-30 23:59:59.999',
'2016-10-31 23:59:59.999',
'2016-11-30 23:59:59.999',
'2016-12-31 23:59:59.999',
'2017-01-31 23:59:59.999',
'2017-02-28 23:59:59.999',
'2017-03-31 23:59:59.999',
'2017-04-30 23:59:59.999',
'2017-05-31 23:59:59.999',
'2017-06-30 23:59:59.999',
'2017-07-31 23:59:59.999',
'2017-08-31 23:59:59.999',
'2017-09-30 23:59:59.999',
'2017-10-31 23:59:59.999',
'2017-11-30 23:59:59.999',
'2017-12-31 23:59:59.999',
'2018-01-31 23:59:59.999',
'2018-02-28 23:59:59.999',
'2018-03-31 23:59:59.999',
'2018-04-30 23:59:59.999',
'2018-05-31 23:59:59.999',
'2018-06-30 23:59:59.999',
'2018-07-31 23:59:59.999',
'2018-08-31 23:59:59.999',
'2018-09-30 23:59:59.999',
'2018-10-31 23:59:59.999',
'2018-11-30 23:59:59.999',
'2018-12-31 23:59:59.999',
'2019-01-31 23:59:59.999',
'2019-02-28 23:59:59.999',
'2019-03-31 23:59:59.999',
'2019-04-30 23:59:59.999',
'2019-05-31 23:59:59.999',
'2019-06-30 23:59:59.999',
'2019-07-31 23:59:59.999',
'2019-08-31 23:59:59.999',
'2019-09-30 23:59:59.999',
'2019-10-31 23:59:59.999',
'2019-11-30 23:59:59.999',
'2019-12-31 23:59:59.999'
);

CREATE PARTITION SCHEME partition_vtucare_transactions_by_month_partition_scheme AS PARTITION partition_quickteller_db_by_month TO (
[tbl_transactions_partition_201408],
[tbl_transactions_partition_201409],
[tbl_transactions_partition_201410],
[tbl_transactions_partition_201411],
[tbl_transactions_partition_201412],
[tbl_transactions_partition_201501],
[tbl_transactions_partition_201502],
[tbl_transactions_partition_201503],
[tbl_transactions_partition_201504],
[tbl_transactions_partition_201505],
[tbl_transactions_partition_201506],
[tbl_transactions_partition_201507],
[tbl_transactions_partition_201508],
[tbl_transactions_partition_201509],
[tbl_transactions_partition_201510],
[tbl_transactions_partition_201511],
[tbl_transactions_partition_201512],
[tbl_transactions_partition_201601],
[tbl_transactions_partition_201602],
[tbl_transactions_partition_201603],
[tbl_transactions_partition_201604],
[tbl_transactions_partition_201605],
[tbl_transactions_partition_201606],
[tbl_transactions_partition_201607],
[tbl_transactions_partition_201608],
[tbl_transactions_partition_201609],
[tbl_transactions_partition_201610],
[tbl_transactions_partition_201611],
[tbl_transactions_partition_201612],
[tbl_transactions_partition_201701],
[tbl_transactions_partition_201702],
[tbl_transactions_partition_201703],
[tbl_transactions_partition_201704],
[tbl_transactions_partition_201705],
[tbl_transactions_partition_201706],
[tbl_transactions_partition_201707],
[tbl_transactions_partition_201708],
[tbl_transactions_partition_201709],
[tbl_transactions_partition_201710],
[tbl_transactions_partition_201711],
[tbl_transactions_partition_201712],
[tbl_transactions_partition_201801],
[tbl_transactions_partition_201802],
[tbl_transactions_partition_201803],
[tbl_transactions_partition_201804],
[tbl_transactions_partition_201805],
[tbl_transactions_partition_201806],
[tbl_transactions_partition_201807],
[tbl_transactions_partition_201808],
[tbl_transactions_partition_201809],
[tbl_transactions_partition_201810],
[tbl_transactions_partition_201811],
[tbl_transactions_partition_201812],
[tbl_transactions_partition_201901],
[tbl_transactions_partition_201902],
[tbl_transactions_partition_201903],
[tbl_transactions_partition_201904],
[tbl_transactions_partition_201905],
[tbl_transactions_partition_201906],
[tbl_transactions_partition_201907],
[tbl_transactions_partition_201908],
[tbl_transactions_partition_201909],
[tbl_transactions_partition_201910],
[tbl_transactions_partition_201911],
[tbl_transactions_partition_201912],
[tbl_transactions_partition_partition_default])

