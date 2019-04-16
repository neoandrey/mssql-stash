exec postilion_office.dbo.manage_transaction_cleaner 
@default_retention_period = 30, 
@throttle_factor=90,
@segment_size= 8000,
@offet_reduction_factor =5