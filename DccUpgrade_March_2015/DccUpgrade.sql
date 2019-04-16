USE [postilion_office]
GO


--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating Table: tbl_Dcc_iFile_status'
PRINT ''
--------------------------------------------------------------------------------
GO
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'dbo.tbl_Dcc_iFile_status') AND OBJECTPROPERTY(id,N'IsUserTable') =1)
PRINT 'TABLE tbl_Dcc_iFile_status ALREADY EXISTS... CREATE TABLE ABORTED'
ELSE

CREATE TABLE tbl_Dcc_iFile_status ( 
	[id] [bigint] IDENTITY(1,1) PRIMARY KEY,
	[iFile] VARCHAR(100) NOT NULL,
	[acq_code] VARCHAR(5) NOT NULL,
	[file_sequence_num] int NOT NULL,
	[creation_date] datetime NOT NULL,
	[status] VARCHAR(500) NOT NULL
)

GO


--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating Table: tbl_Dcc_iFileGen_Control'
PRINT ''
--------------------------------------------------------------------------------
GO
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'dbo.tbl_Dcc_iFileGen_Control') AND OBJECTPROPERTY(id,N'IsUserTable') =1)
PRINT 'TABLE tbl_Dcc_iFileGen_Control ALREADY EXISTS... CREATE TABLE ABORTED'
ELSE

CREATE TABLE tbl_Dcc_iFileGen_Control ( 
	[id] [bigint] IDENTITY(1,1) PRIMARY KEY,
	[acq_code] VARCHAR(5) NOT NULL,
	[should_generate] [bit] NOT NULL
)

GO


--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating Stored Procedure:  psp_insert_dcc_iFile_status'
PRINT ''
--------------------------------------------------------------------------------
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('psp_insert_dcc_iFile_status'))
BEGIN
    PRINT 'Dropping current psp_insert_dcc_iFile_status'
   	DROP PROCEDURE psp_insert_dcc_iFile_status
END
GO

CREATE PROCEDURE [dbo].[psp_insert_dcc_iFile_status]
(
	@fileName VARCHAR(100),
	@acq_code VARCHAR(5),
	@seq_num int
)

AS
BEGIN
	INSERT INTO tbl_Dcc_IFile_status(iFile, acq_code, file_sequence_num, creation_date, status)
	VALUES(@fileName, @acq_code, @seq_num, GETDATE(), 'Pending') 
END


--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating Stored Procedure:  psp_Update_iFile_Status'
PRINT ''
--------------------------------------------------------------------------------
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('psp_Update_iFile_Status'))
BEGIN
    PRINT 'Dropping current psp_Update_iFile_Status'
   	DROP PROCEDURE psp_Update_iFile_Status
END
GO

CREATE PROCEDURE [dbo].[psp_Update_iFile_Status]
(
	@acq_code VARCHAR(6),
	@seq_num int,
	@status VARCHAR(500)
)

AS
BEGIN
	UPDATE tbl_Dcc_IFile_status
	SET status = @status
	WHERE acq_code = @acq_code
	AND file_sequence_num = @seq_num
END



--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating Stored Procedure:  psp_Update_iFileGen_Control'
PRINT ''
--------------------------------------------------------------------------------
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('psp_Update_iFileGen_Control'))
BEGIN
    PRINT 'Dropping current psp_Update_iFileGen_Control'
   	DROP PROCEDURE psp_Update_iFileGen_Control
END
GO

CREATE PROCEDURE [dbo].[psp_Update_iFileGen_Control]
(
	@acq_code VARCHAR(5),
	@shld_generate bit
)

AS
BEGIN
	SELECT * from tbl_Dcc_iFileGen_Control (nolock)
	WHERE acq_code = @acq_code

	IF(@@ROWCOUNT > 0)
	BEGIN
		UPDATE tbl_Dcc_iFileGen_Control
		SET should_generate = @shld_generate
		WHERE acq_code = @acq_code
	END
	ELSE
	BEGIN
		INSERT INTO tbl_Dcc_iFileGen_Control(acq_code,should_generate) 
		VALUES(@acq_code,@shld_generate)
	END
END


