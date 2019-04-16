
-- This sp will insert/update a card_account.
CREATE PROCEDURE pcb_card_accounts_update
                @issuer_nr                                                                                         INT,
                @pan                                                                                                                    VARCHAR(19),
                @seq_nr                                                                                                             VARCHAR(3),
                @account_id                                                                                     VARCHAR(28),
                @account_type_nominated                       VARCHAR(2),                                     -- ver 2.1 (renamed from account_type in 2.0)
                @account_type_qualifier                            VARCHAR(1),                                     -- '' => leave as is (ver 2.1 (renamed from is_default in 2.0))
                @last_updated_date                                     VARCHAR(30),                   -- '' => leave as is
                @last_updated_user                                     VARCHAR(20),                   -- '' => leave as is
                --- ver 2.1
                @account_type                                                                                VARCHAR(2)=NULL         -- may be NULL if account ids are unique across account types
AS
BEGIN
                DECLARE @sql_exec_str                               VARCHAR(8000)
                DECLARE @proc_name                                VARCHAR(100)
                DECLARE @issuer_nr_str                              VARCHAR(10)
                DECLARE @tablename_post                       VARCHAR(10)

                ---Card_accounts tables belong to the 'base' tablegroup.
                SELECT @tablename_post = NULL
                SELECT
                                @tablename_post =
                                                '_' + current_table_set_cardaccounts
                FROM
                                pc_issuers
                WHERE
                                issuer_nr = @issuer_nr

                IF (@tablename_post IS NULL)
                BEGIN
                                DECLARE @error_string VARCHAR(1000)
                                SET @error_string = 'Invalid issuer_nr for stored procedure pcb_card_accounts_update.'
                                RAISERROR (@error_string, 18, 1)
                                RETURN
                END

                SELECT @issuer_nr_str = CONVERT(VARCHAR,@issuer_nr)
                SELECT @proc_name = 'pc_card_accounts_update_' + @issuer_nr_str + @tablename_post

                EXEC      @proc_name
                                                @pan,
                                                @seq_nr,
                                                @account_id,
                                                @account_type_nominated,
                                                @account_type_qualifier,
                                                @last_updated_date,
                                                @last_updated_user,
                                                @account_type
END

GO





CREATE PROCEDURE psp_cms_link_card_to_account
                @issuer_nr                                                                                         int,
                @pan                                                                                                    varchar(19),
                @seq_nr                                                 varchar(3),
                @account_id                                                                                     varchar(28),
        @user_id                                                varchar(20),
        @account_type                                           varchar(2)=NULL
AS
BEGIN
                                EXEC pcb_card_accounts_update
                                                @issuer_nr,
                                                @pan,
                                                @seq_nr,
                                                @account_id,
                                                @account_type,
                                                '1',
                                                NULL,
                                                @user_id,
                                                @account_type
        
END


GO


SELECT 