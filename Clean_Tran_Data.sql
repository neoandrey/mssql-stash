use postilion_office
--This script will clean out all transaction and process log data from the
--Postilion Office db. No config tables will be cleaned.
--Note the scripts to clean the components should be executed first.


PRINT 'Cleaning out Postilion Office Transaction and Process info'


--Clean EJ Tables
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_term_ej_activity'))
BEGIN
PRINT ' Cleaning table post_term_ej_activity'
DELETE FROM post_term_ej_activity
END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_term_ej_tran'))
BEGIN
PRINT 'Cleaning table post_term_ej_tran'
DELETE FROM post_term_ej_tran
END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_term_ej'))
BEGIN
PRINT 'Cleaning table post_term_ej_tran'
DELETE FROM post_term_ej
END
GO


--Clean Transaction Tables
PRINT 'Cleaning table post_tran_exception'
DELETE FROM post_tran_exception


PRINT 'Cleaning table post_tran'
DELETE FROM post_tran
GO


PRINT 'Cleaning table post_tran_cust'
DELETE FROM post_tran_cust
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_norm_switchkey'))
BEGIN
PRINT 'Cleaning table post_norm_switchkey'
DELETE FROM post_norm_switchkey
END
GO


PRINT 'Cleaning table post_batch'
DELETE FROM post_batch
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_online_batch'))
BEGIN
PRINT 'Cleaning table post_online_batch'
DELETE FROM post_online_batch
END
GO


PRINT 'Cleaning table post_settle_entity'
DELETE FROM post_settle_entity
GO


--Cleaning Process Info
PRINT 'Cleaning table post_process_run_phase_detail'
DELETE FROM post_process_run_phase_detail
GO


PRINT 'Cleaning table post_process_run_phase'
DELETE FROM post_process_run_phase
GO


PRINT 'Cleaning table post_process_run'
DELETE FROM post_process_run
GO


PRINT 'Cleaning table post_normalization_session'
DELETE FROM post_normalization_session
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('post_norm_rtfw_session'))
BEGIN
PRINT 'Cleaning table post_norm_rtfw_session'
DELETE FROM post_norm_rtfw_session
END
GO


PRINT 'Done'
GO





/*
begin transaction

-- remove all extraction transaction and sessions
delete from postilion_office..extract_tran
delete from postilion_office..extract_session

-- remove all office transactions already normalised/ settlement entities
delete from postilion_office..post_tran
delete from postilion_office..post_tran_cust
delete from postilion_office..post_batch
delete from postilion_office..post_settle_entity

-- remove process detail
delete from postilion_office..post_process_run_phase_detail
delete from postilion_office..post_process_run_phase
delete from postilion_office..post_process_run

commit transaction
go
*/