 DELETE FROM pp_employee 
 DELETE FROM  pp_fi_issuers 
 DELETE FROM  pp_fi_participants 
 DELETE FROM  pp_fi_prod_reg 
 DELETE FROM  pp_financial_institutions 
 DELETE FROM  sec_auth_token 
  DELETE FROM  sec_group_authenticators 
 DELETE FROM  sec_authenticators 
 DELETE FROM  sec_cat_perm_map 
 DELETE FROM  sec_group_ldap 
 DELETE FROM  sec_group_prod_policy 
 delete from  dbo.sec_usr_inst_perms
 delete from sec_usr_perm_ovrd
   DELETE FROM  sec_pwd_history 
 DELETE FROM  sec_pwd_policy 
  DELETE FROM  sec_product_users
   DELETE FROM  sec_user_role_map 
  DELETE FROM  sec_ldap_users 
 DELETE FROM  sec_users
 DELETE FROM sec_scope
   DELETE FROM  sec_role_perm_map 
 DELETE FROM sec_roles 
 DELETE FROM  sec_groups 
 DELETE FROM  sec_instance_permissions 
 DELETE FROM  sec_ldap_cfgs 
 DELETE FROM  sec_ldap_types 
 delete from sec_usr_perm_ovrd

 DELETE FROM  sec_override_type 
 DELETE FROM  sec_passwords 
  DELETE FROM  sec_prod_perm_map 
 DELETE FROM  sec_product_perm_map 

 delete from  sec_permissions
 DELETE FROM  sec_prod_perm_map
 DELETE FROM  sec_perm_cats 
 DELETE FROM  sec_permissions 
 DELETE FROM  sec_prd_prm_cfg 
 DELETE FROM  sec_preferences 


 DELETE FROM  sec_pwd_history 
 DELETE FROM  sec_pwd_policy 
 DELETE FROM  sec_rl_inst_perms 

 DELETE FROM  sec_roles 
 --DELETE FROM  sec_scope 
 DELETE FROM  sec_user_preferences 

 DELETE FROM  sec_user_types 
 DELETE FROM  sec_users 
 DELETE FROM  sec_usr_inst_perms 
 DELETE FROM  sec_usr_perm_ovrd 
 
 SET IDENTITY_INSERT sec_perm_cats ON 
INSERT INTO sec_perm_cats(perm_category_id,perm_category_name) SELECT perm_category_id,perm_category_name FROM  [172.25.10.89].[realtime].[dbo].[sec_perm_cats];
 SET IDENTITY_INSERT sec_perm_cats OFF 


SET IDENTITY_INSERT sec_permissions ON 
INSERT INTO sec_permissions(permission_id,product_id,permission_category,permission_name,permission_desc,permission_advisor_id,availability) SELECT permission_id,product_id,permission_category,permission_name,permission_desc,permission_advisor_id,availability FROM  [172.25.10.89].[realtime].[dbo].[sec_permissions];
 SET IDENTITY_INSERT sec_permissions OFF 
INSERT INTO sec_prod_perm_map(prod_id,permission_id,anonymous) SELECT prod_id,permission_id,anonymous FROM  [172.25.10.89].[realtime].[dbo].[sec_prod_perm_map];


SET IDENTITY_INSERT sec_groups ON 
INSERT INTO sec_groups(group_id,group_name) SELECT group_id,group_name FROM  [172.25.10.89].[realtime].[dbo].[sec_groups];
 SET IDENTITY_INSERT sec_groups OFF 
SET IDENTITY_INSERT pp_financial_institutions ON 
INSERT INTO pp_financial_institutions(fi_id,fi_name,issuer_name,participant_name,receiving_institution_id_code,routing_and_transit_nr,sec_group_id_employee) SELECT fi_id,fi_name,issuer_name,participant_name,receiving_institution_id_code,routing_and_transit_nr,sec_group_id_employee FROM  [172.25.10.89].[realtime].[dbo].[pp_financial_institutions];
 SET IDENTITY_INSERT pp_financial_institutions OFF 
SET IDENTITY_INSERT pp_employee ON 
INSERT INTO pp_employee(employee_id,default_fi,name,lastname,address_line_1,address_line_2,city,region,postal_code,country,telephone_nr,mobile_nr,fax_nr,email,sec_user_id,support_member_id) SELECT employee_id,default_fi,name,lastname,address_line_1,address_line_2,city,region,postal_code,country,telephone_nr,mobile_nr,fax_nr,email,sec_user_id,support_member_id FROM  [172.25.10.89].[realtime].[dbo].[pp_employee];
 SET IDENTITY_INSERT pp_employee OFF 
INSERT INTO pp_fi_issuers(fi_id,issuer_name) SELECT fi_id,issuer_name FROM  [172.25.10.89].[realtime].[dbo].[pp_fi_issuers];
INSERT INTO pp_fi_participants(fi_id,participant_id) SELECT fi_id,participant_id FROM  [172.25.10.89].[realtime].[dbo].[pp_fi_participants];
INSERT INTO pp_fi_prod_reg(fi_id,prod_id,parameters,enabled) SELECT fi_id,prod_id,parameters,enabled FROM  [172.25.10.89].[realtime].[dbo].[pp_fi_prod_reg];


INSERT INTO sec_auth_token(guid,requesting_prod_usr_id,on_behalf_of_prod_usr_id,expiry_date) SELECT guid,requesting_prod_usr_id,on_behalf_of_prod_usr_id,expiry_date FROM  [172.25.10.89].[realtime].[dbo].[sec_auth_token];

SET IDENTITY_INSERT sec_authenticators ON 
INSERT INTO sec_authenticators(id,product_id,display_name,class_name) SELECT id,product_id,display_name,class_name FROM  [172.25.10.89].[realtime].[dbo].[sec_authenticators];
 SET IDENTITY_INSERT sec_authenticators OFF 
INSERT INTO sec_cat_perm_map(perm_category_id,permission_id) SELECT perm_category_id,permission_id FROM  [172.25.10.89].[realtime].[dbo].[sec_cat_perm_map];
INSERT INTO sec_group_authenticators(group_id,interface_name,rank,authenticator_id) SELECT group_id,interface_name,rank,authenticator_id FROM  [172.25.10.89].[realtime].[dbo].[sec_group_authenticators];


SET IDENTITY_INSERT sec_ldap_types ON 
INSERT INTO sec_ldap_types(type_id,type_name) SELECT type_id,type_name FROM  [172.25.10.89].[realtime].[dbo].[sec_ldap_types];
 SET IDENTITY_INSERT sec_ldap_types OFF 
 
SET IDENTITY_INSERT sec_ldap_cfgs ON 
INSERT INTO sec_ldap_cfgs(ldap_cfg_id,display_name,search_base,url,type_id,domain) SELECT ldap_cfg_id,display_name,search_base,url,type_id,domain FROM  [172.25.10.89].[realtime].[dbo].[sec_ldap_cfgs];
 SET IDENTITY_INSERT sec_ldap_cfgs OFF 


INSERT INTO sec_group_ldap(group_id,ldap_cfg_id,dfault) SELECT group_id,ldap_cfg_id,dfault FROM  [172.25.10.89].[realtime].[dbo].[sec_group_ldap];
INSERT INTO sec_group_prod_policy(group_id,product_id,id_default,id_max_len,pin_default,pin_default_len,role_default) SELECT group_id,product_id,id_default,id_max_len,pin_default,pin_default_len,role_default FROM  [172.25.10.89].[realtime].[dbo].[sec_group_prod_policy];

SET IDENTITY_INSERT sec_instance_permissions ON 
INSERT INTO sec_instance_permissions(instance_id,permission_id,object_reg_id,parent,parameters) SELECT instance_id,permission_id,object_reg_id,parent,parameters FROM  [172.25.10.89].[realtime].[dbo].[sec_instance_permissions];
 SET IDENTITY_INSERT sec_instance_permissions OFF 
SET IDENTITY_INSERT sec_users ON 
INSERT INTO sec_users(user_id,group_id,status,created,last_updated,guid) SELECT user_id,group_id,status,created,last_updated,guid FROM  [172.25.10.89].[realtime].[dbo].[sec_users];
 SET IDENTITY_INSERT sec_users OFF 


INSERT INTO sec_ldap_users(user_id,ldap_username) SELECT user_id,ldap_username FROM  [172.25.10.89].[realtime].[dbo].[sec_ldap_users];
INSERT INTO sec_override_type(override_type,override_desc) SELECT override_type,override_desc FROM  [172.25.10.89].[realtime].[dbo].[sec_override_type];

SET IDENTITY_INSERT sec_passwords ON 
INSERT INTO sec_passwords(password_id,salt,password,last_password_change) SELECT password_id,salt,password,last_password_change FROM  [172.25.10.89].[realtime].[dbo].[sec_passwords];
 SET IDENTITY_INSERT sec_passwords OFF 


--SET IDENTITY_INSERT sec_permissions ON 
--INSERT INTO sec_permissions(permission_id,product_id,permission_category,permission_name,permission_desc,permission_advisor_id,availability) SELECT permission_id,product_id,permission_category,permission_name,permission_desc,permission_advisor_id,availability FROM  [172.25.10.89].[realtime].[dbo].[sec_permissions];
-- SET IDENTITY_INSERT sec_permissions OFF 
INSERT INTO sec_prd_prm_cfg(product_id,user_type,permission_id) SELECT product_id,user_type,permission_id FROM  [172.25.10.89].[realtime].[dbo].[sec_prd_prm_cfg];
INSERT INTO sec_preferences(unique_name,prod_id) SELECT unique_name,prod_id FROM  [172.25.10.89].[realtime].[dbo].[sec_preferences];
--INSERT INTO sec_prod_perm_map(prod_id,permission_id,anonymous) SELECT prod_id,permission_id,anonymous FROM  [172.25.10.89].[realtime].[dbo].[sec_prod_perm_map];
INSERT INTO sec_product_perm_map(product_id,permission_id) SELECT product_id,permission_id FROM  [172.25.10.89].[realtime].[dbo].[sec_product_perm_map];

SET IDENTITY_INSERT sec_product_users ON 
INSERT INTO sec_product_users(product_usr_id,user_id,product_usr_name,product_id,product_pwd_id,product_status,curr_pwd_tries,last_login,last_updated,created,last_failed_login) SELECT product_usr_id,user_id,product_usr_name,product_id,product_pwd_id,product_status,curr_pwd_tries,last_login,last_updated,created,last_failed_login FROM  [172.25.10.89].[realtime].[dbo].[sec_product_users];
 SET IDENTITY_INSERT sec_product_users OFF 

SET IDENTITY_INSERT sec_pwd_history ON 
INSERT INTO sec_pwd_history(history_nr,product_usr_id,password_change_date,old_password) SELECT history_nr,product_usr_id,password_change_date,old_password FROM  [172.25.10.89].[realtime].[dbo].[sec_pwd_history];
 SET IDENTITY_INSERT sec_pwd_history OFF 

SET IDENTITY_INSERT sec_pwd_policy ON 
INSERT INTO sec_pwd_policy(pwd_policy_id,group_id,product_id,min_pwd_length,complexity,max_pin_tries,retention_per,pwd_cycle_per,dormant_days) SELECT pwd_policy_id,group_id,product_id,min_pwd_length,complexity,max_pin_tries,retention_per,pwd_cycle_per,dormant_days FROM  [172.25.10.89].[realtime].[dbo].[sec_pwd_policy];
 SET IDENTITY_INSERT sec_pwd_policy OFF 
INSERT INTO sec_rl_inst_perms(role_id,instance_id) SELECT role_id,instance_id FROM  [172.25.10.89].[realtime].[dbo].[sec_rl_inst_perms];

SET IDENTITY_INSERT sec_roles ON 
INSERT INTO sec_roles(role_id,group_id,role_name) SELECT role_id,group_id,role_name FROM  [172.25.10.89].[realtime].[dbo].[sec_roles];
SET IDENTITY_INSERT sec_roles OFF 

INSERT INTO sec_role_perm_map(role_id,permission_id) SELECT role_id,permission_id FROM  [172.25.10.89].[realtime].[dbo].[sec_role_perm_map];

SET IDENTITY_INSERT sec_scope ON 
INSERT INTO sec_scope(scope_id,group_id,scope_obj_id,parameters,permission_id) SELECT scope_id,group_id,scope_obj_id,parameters,permission_id FROM  [172.25.10.89].[realtime].[dbo].[sec_scope];
 SET IDENTITY_INSERT sec_scope OFF 
INSERT INTO sec_user_preferences(user_id,prod_id,unique_name,value) SELECT user_id,prod_id,unique_name,value FROM  [172.25.10.89].[realtime].[dbo].[sec_user_preferences];
INSERT INTO sec_user_role_map(user_id,role_id) SELECT user_id,role_id FROM  [172.25.10.89].[realtime].[dbo].[sec_user_role_map];
INSERT INTO sec_user_types(user_type) SELECT user_type FROM  [172.25.10.89].[realtime].[dbo].[sec_user_types];

INSERT INTO sec_usr_inst_perms(user_id,instance_id) SELECT user_id,instance_id FROM  [172.25.10.89].[realtime].[dbo].[sec_usr_inst_perms];
INSERT INTO sec_usr_perm_ovrd(user_id,permission_id,override_type) SELECT user_id,permission_id,override_type FROM  [172.25.10.89].[realtime].[dbo].[sec_usr_perm_ovrd];
