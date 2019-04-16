IF NOT EXISTS (
	SELECT * FROM syscolumns c, sysobjects o 
	WHERE o.name = 'post_tran' AND o.id = c.id AND o.type <> 'P' AND ( c.name = 'pos_geographic_data')
)
BEGIN
	ALTER TABLE post_tran ADD pos_geographic_data CHAR(5) NULL
	PRINT	'- Added column: pos_geographic_data'
END
ELSE
BEGIN
	PRINT '- The column post_tran.pos_geographic_data already exists.'
END

IF NOT EXISTS (
	SELECT * FROM syscolumns c, sysobjects o 
	WHERE o.name = 'post_tran' AND o.id = c.id AND o.type <> 'P' AND ( c.name = 'payer_account_id')
)
BEGIN
	ALTER TABLE post_tran ADD payer_account_id CHAR(5) NULL
	PRINT	'- Added column: payer_account_id'
END
ELSE
BEGIN
	PRINT '- The column post_tran.payer_account_id already exists.'
END

