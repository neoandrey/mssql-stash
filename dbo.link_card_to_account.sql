                       USE postcard;

                         GO


ALTER PROCEDURE dbo.link_card_to_account
(
@pan       VARCHAR(100), @account_id    VARCHAR(100),@user_id        VARCHAR(100),@card_program    VARCHAR(100)
)
AS
BEGIN


DECLARE @issuer_nr_param      VARCHAR(100),     @seq_nr_param        VARCHAR(100),  @account_type_param   VARCHAR(100);


SELECT

@issuer_nr_param  = pc.issuer_nr,
@pan_param  =pc.pan,
@seq_nr_param= pc.seq_nr,
@account_id_param =account_id,
@account_type_param = account_type,
@user_id_param = ISNULL( @user_id,SUSER_SNAME())

FROM
pc_cards pc (NOLOCK)

JOIN pc_card_accounts ac (NOLOCK)

ON
pc.issuer_nr = ac.issuer_nr AND pc.pan = ac.pan AND pc.seq_nr = ac.seq_nr

WHERE
pc.pan =@pan AND card_program=@card_program AND account_id=@account_id

exec  psp_cms_link_card_to_account
@issuer_nr =@issuer_nr_param_param,
@pan= @pan_param,
@seq_nr= @seq_nr_param,
@account_id=@account_id_param,
@user_id=@user_id_param,
@account_type =@account_type_param

END
