USE [master]
GO
CREATE DATABASE [postilion_office_vis] ON 
( FILENAME = N'L:\postilion_office_visa\post_office_db.mdf' ),
( FILENAME = N'L:\postilion_office_visa\post_office_log.ldf' ),
( FILENAME = N'L:\postilion_office_visa\2\post_office_db_2.ndf' ),
( FILENAME = N'L:\postilion_office_visa\post_office_db_2.NDF' )
 FOR ATTACH
GO
