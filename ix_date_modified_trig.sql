CREATE TRIGGER ix_date_modified_trig ON tbl_merchant_account
AFTER UPDATE
AS
BEGIN
declare @card_acceptor_id_code VARCHAR(300)
SELECT  @card_acceptor_id_code = card_acceptor_id_code FROM inserted 
UPDATE 
tbl_merchant_account 
SET 
Date_Modified = GETDATE()
WHERE 
card_acceptor_id_code=
@card_acceptor_id_code
END