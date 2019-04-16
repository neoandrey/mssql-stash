[?9/?21/?2016 1:42 PM] Ebun Reffell: 
hi
[?9/?21/?2016 1:42 PM] Mobolaji Aina: 
Hi
[?9/?21/?2016 1:43 PM] Ebun Reffell: 
it deleted it but the updates are still there
[?9/?21/?2016 1:43 PM] Mobolaji Aina: 
Commit
From that database
[?9/?21/?2016 1:43 PM] Ebun Reffell: 
i should commit now?
[?9/?21/?2016 1:43 PM] Mobolaji Aina: 
job
Wait
[?9/?21/?2016 1:43 PM] Ebun Reffell: 
what job
[?9/?21/?2016 1:43 PM] Mobolaji Aina: 
did you close and reopen
[?9/?21/?2016 1:43 PM] Ebun Reffell: 
yes
[?9/?21/?2016 1:44 PM] Mobolaji Aina: 
and the updates are there?
[?9/?21/?2016 1:44 PM] Ebun Reffell: 
it has removed the config i specified
[?9/?21/?2016 1:44 PM] Mobolaji Aina: 
kk
[?9/?21/?2016 1:44 PM] Ebun Reffell: 
but the updates done to the fields are still there
they are just not committed
[?9/?21/?2016 1:45 PM] Mobolaji Aina: 
kk
then it has rolled back
[?9/?21/?2016 1:46 PM] Mobolaji Aina: 
Commit is meant to save and set to current
[?9/?21/?2016 1:46 PM] Ebun Reffell: 
the changes are still there though
[?9/?21/?2016 1:46 PM] Mobolaji Aina: 
in the  last saved version
[?9/?21/?2016 1:47 PM] Ebun Reffell: 
well .....i can still see them but the last config version has been deleted
[?9/?21/?2016 1:48 PM] Mobolaji Aina: 
792?
[?9/?21/?2016 1:48 PM] Ebun Reffell: 
793
[?9/?21/?2016 1:48 PM] Mobolaji Aina: 
that's what we deleted
[?9/?21/?2016 1:48 PM] Ebun Reffell: 
yes
the one there is now 792
[?9/?21/?2016 1:48 PM] Mobolaji Aina: 
Cool
So, If we start Settlement, it will pick 792
[?9/?21/?2016 1:49 PM] Ebun Reffell: 
yes
[?9/?21/?2016 1:49 PM] Mobolaji Aina: 
Aii
[?9/?21/?2016 1:49 PM] Ebun Reffell: 
but the things Deola changed are still there
[?9/?21/?2016 1:49 PM] Mobolaji Aina: 
Yup
[?9/?21/?2016 1:49 PM] Ebun Reffell: 
so if i update again...it will save them
there is no way to get rid of that?
[?9/?21/?2016 1:50 PM] Mobolaji Aina: 
Unless you know the version that she committed
[?9/?21/?2016 1:50 PM] Ebun Reffell: 
she hasnt
[?9/?21/?2016 1:50 PM] Mobolaji Aina: 
Are you sure?
[?9/?21/?2016 1:50 PM] Ebun Reffell: 
yes
the update is on 89 and she hasnt committed so we are still settling with the old version from that box
[?9/?21/?2016 1:51 PM] Mobolaji Aina: 
Okay
show me some of the updates
[?9/?21/?2016 1:52 PM] Ebun Reffell: 
ok
[?9/?21/?2016 1:54 PM] Ebun Reffell: 
im coming
[?9/?21/?2016 1:54 PM] Mobolaji Aina: 
here?
I'm going for lunch
[?9/?21/?2016 1:54 PM] Ebun Reffell: 
i just reopened on 19
it has cancelled it o
abi on 93?
[?9/?21/?2016 1:54 PM] Mobolaji Aina: 
what?
[?9/?21/?2016 1:55 PM] Ebun Reffell: 
let me share and show you
[?9/?21/?2016 1:55 PM] Mobolaji Aina: 
It has cancelled what?
[?9/?21/?2016 1:55 PM] Ebun Reffell: 
call if you can pls
[?9/?21/?2016 1:58 PM] Ebun Reffell: 
DECLARE @config_version INT; 
DECLARE @config_version INT;

SET @config_version = 793

DELETE FROM dbo.sstl_journal_adj WHERE config_version>=@config_version
DELETE FROM dbo.spay_aggregation WHERE config_version>=@config_version
DELETE FROM dbo.spay_proc_ent WHERE config_version>=@config_version
DELETE FROM dbo.spay_proc_ent_fltr_grp WHERE config_version>=@config_version
DELETE FROM dbo.spay_se_acc WHERE config_version>=@config_version
DELETE FROM dbo.spay_se_acc_rel WHERE config_version>=@config_version
DELETE FROM dbo.spay_se_acc_rel_param WHERE config_version>=@config_version
DELETE FROM dbo.spay_se_amount_pay_freq WHERE config_version>=@config_version
DELETE FROM dbo.spay_se_fee_pay_freq WHERE config_version>=@config_version
DELETE FROM dbo.spay_statement_profile WHERE config_version>=@config_version
DELETE FROM dbo.spst_aggregation WHERE config_version>=@config_version
DELETE FROM dbo.spst_proc_ent WHERE config_version>=@config_version
DELETE FROM dbo.spst_proc_ent_fltr_grp WHERE config_version>=@config_version
DELETE FROM dbo.spst_se_amount_pst_freq WHERE config_version>=@config_version
DELETE FROM dbo.spst_se_fee_pst_freq WHERE config_version>=@config_version
DELETE FROM dbo.spst_statement_profile WHERE config_version>=@config_version
DELETE FROM dbo.sstl_acc WHERE config_version>=@config_version
DELETE FROM dbo.sstl_coa WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_grp WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_grp_elem WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_param WHERE config_version>=@config_version
DELETE FROM dbo.sstl_pred WHERE config_version>=@config_version
DELETE FROM dbo.sstl_pred_prop_value WHERE config_version>=@config_version
DELETE FROM dbo.sstl_proc_ent WHERE config_version>=@config_version
DELETE FROM dbo.sstl_prop WHERE config_version>=@config_version
DELETE FROM dbo.sstl_prop_value WHERE config_version>=@config_version
DELETE FROM dbo.sstl_prop_value_node WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_acc_nr WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_amount WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_amount_value WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_amount_value_int WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_cal WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_cal_date_range WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_fee WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_fee_priority WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_fee_value WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_nt_fee WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_nt_fee_acc_post WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_nt_fee_value WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_rule WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_rule_acc_post WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_statement WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_tax WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_tax_rate WHERE config_version>=@config_version
DELETE FROM dbo.sstl_se_third_party WHERE config_version>=@config_version
DELETE FROM dbo.sstl_session WHERE config_version>=@config_version
DELETE FROM dbo.sstl_statement_profile WHERE config_version>=@config_version
DELETE FROM dbo.sstl_tran_field WHERE config_version>=@config_version
DELETE FROM dbo.sstl_tran_ident WHERE config_version>=@config_version
DELETE FROM dbo.sstl_tran_ident_def WHERE config_version>=@config_version
DELETE FROM dbo.spay_session WHERE config_version>=@config_version
DELETE FROM dbo.spst_session WHERE config_version>=@config_version
DELETE FROM dbo.spst_exception WHERE config_version>=@config_version
DELETE FROM dbo.sstl_config_version WHERE config_version>=@config_version 
