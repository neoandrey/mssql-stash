EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'iswlos-db-22a',  
    @description = 'iswlos-db-22a',  
    @email_address = 'coretech@interswitchgroup.com',  
    @replyto_address = 'coretech@interswitchgroup.com',  
    @display_name = 'iswlos-db-22a',  
    @mailserver_name = '172.16.10.223' ;  
  
-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'iswlos-db-22a',  
    @description = 'iswlos-db-22a' ;  
  
-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'iswlos-db-22a',  
    @account_name = 'coretech@interswitchgroup.com',  
    @sequence_number =1 ;  
  
-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'iswlos-db-22a',  
    @principal_name = 'public',  
    @is_default = 1 ;  
