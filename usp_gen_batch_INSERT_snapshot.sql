USE [autopay_upgrade]
GO
/****** Object:  StoredProcedure [dbo].[usp_gen_batch_INSERT]    Script Date: 6/5/2017 2:46:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_gen_batch_INSERT]
	@batchDescription varchar(50),
	@accountId int = NULL,
	@batchStatus int,
	@corporateId int,
	@sponsorId int,
	@batch_size int = NULL,
	@batch_total decimal(18, 0) = NULL,
	@tranType char(2) = NULL,
	@isSingleDebit bit = NULL,
	@paymentType char(2) = NULL,
	@createdOn datetime,
	@createdBy varchar(50) = NULL,
	@modifiedOn datetime,
	@modifiedBy varchar(50) = NULL,
	@isUploaded bit = NULL,
	@completedBatchCount int = NULL,
	@isNotified bit = NULL,
	@batchGenCode bigint = NULL,
	@batch_authorization_worker_status int = NULL,
	@batch_authorization_total_records bigint = NULL,
	@batch_authorization_number_authorized bigint = NULL,
	@batch_authorization_failed_records bigint = NULL,
	@batch_authorization_number_pending bigint = NULL,
	@autogateProcessorCounter bigint = null,
	@isGatewayBatch int = NULL,
	@gateWayNotificationStatus int = NULL,
	@batchId bigint OUTPUT
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
INSERT INTO [dbo].[tbl_batch] (
	[batchDescription],
	[accountId],
	[batchStatus],
	[corporateId],
	[sponsorId],
	[batch_size],
	[batch_total],
	[tranType],
	[isSingleDebit],
	[paymentType],
	[createdOn],
	[createdBy],
	[modifiedOn],
	[modifiedBy],
	[isUploaded],
	[completedBatchCount],
	[isNotified],
	[batchGenCode],
	[batch_authorization_worker_status],
	[batch_authorization_total_records],
	[batch_authorization_number_authorized],
	[batch_authorization_failed_records],
	[batch_authorization_number_pending]
) VALUES (
	@batchDescription,
	@accountId,
	@batchStatus,
	@corporateId,
	@sponsorId,
	@batch_size,
	@batch_total,
	@tranType,
	@isSingleDebit,
	@paymentType,
	@createdOn,
	@createdBy,
	@modifiedOn,
	@modifiedBy,
	@isUploaded,
	@completedBatchCount,
	@isNotified,
	@batchGenCode,
	@batch_authorization_worker_status,
	@batch_authorization_total_records,
	@batch_authorization_number_authorized,
	@batch_authorization_failed_records,
	@batch_authorization_number_pending
)

SET @batchId = SCOPE_IDENTITY()
SELECT @batchId

--endregion

