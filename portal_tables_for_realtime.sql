SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME NOT IN (SELECT TABLE_NAME FROM [172.25.10.67].REALTIME.INFORMATION_SCHEMA.TABLES)

TABLE_CATALOG	TABLE_SCHEMA	TABLE_NAME	TABLE_TYPE
realtime	dbo	aud_actions	BASE TABLE
realtime	dbo	aud_data	BASE TABLE
realtime	dbo	aud_events	BASE TABLE
realtime	dbo	aud_extract_session	BASE TABLE
realtime	dbo	aud_records	BASE TABLE
realtime	dbo	aud_services	BASE TABLE
realtime	dbo	aud_states	BASE TABLE
realtime	dbo	dm_progress	BASE TABLE
realtime	dbo	pp_employee	BASE TABLE
realtime	dbo	pp_fi_issuers	BASE TABLE
realtime	dbo	pp_fi_participants	BASE TABLE
realtime	dbo	pp_fi_prod_reg	BASE TABLE
realtime	dbo	pp_financial_institutions	BASE TABLE
realtime	dbo	prod_class_reg	BASE TABLE
realtime	dbo	prod_obj_cats	BASE TABLE
realtime	dbo	prod_reg	BASE TABLE
realtime	dbo	rb56dd89f4_050400014_sfevtdc	BASE TABLE
realtime	dbo	sec_auth_token	BASE TABLE
realtime	dbo	sec_authenticators	BASE TABLE
realtime	dbo	sec_cat_perm_map	BASE TABLE
realtime	dbo	sec_group_authenticators	BASE TABLE
realtime	dbo	sec_group_ldap	BASE TABLE
realtime	dbo	sec_group_prod_policy	BASE TABLE
realtime	dbo	sec_groups	BASE TABLE
realtime	dbo	sec_instance_permissions	BASE TABLE
realtime	dbo	sec_ldap_cfgs	BASE TABLE
realtime	dbo	sec_ldap_types	BASE TABLE
realtime	dbo	sec_ldap_users	BASE TABLE
realtime	dbo	sec_override_type	BASE TABLE
realtime	dbo	sec_passwords	BASE TABLE
realtime	dbo	sec_perm_cats	BASE TABLE
realtime	dbo	sec_permissions	BASE TABLE
realtime	dbo	sec_prd_prm_cfg	BASE TABLE
realtime	dbo	sec_preferences	BASE TABLE
realtime	dbo	sec_prod_perm_map	BASE TABLE
realtime	dbo	sec_product_perm_map	BASE TABLE
realtime	dbo	sec_product_users	BASE TABLE
realtime	dbo	sec_pwd_history	BASE TABLE
realtime	dbo	sec_pwd_policy	BASE TABLE
realtime	dbo	sec_rl_inst_perms	BASE TABLE
realtime	dbo	sec_role_perm_map	BASE TABLE
realtime	dbo	sec_roles	BASE TABLE
realtime	dbo	sec_scope	BASE TABLE
realtime	dbo	sec_user_preferences	BASE TABLE
realtime	dbo	sec_user_role_map	BASE TABLE
realtime	dbo	sec_user_types	BASE TABLE
realtime	dbo	sec_users	BASE TABLE
realtime	dbo	sec_usr_inst_perms	BASE TABLE
realtime	dbo	sec_usr_perm_ovrd	BASE TABLE
realtime	dbo	ssb_fi_ext_config	BASE TABLE