ALTER TRIGGER  trg_sec_product_users ON sec_product_users  AFTER UPDATE 
  AS BEGIN
  
  DECLARE @user_id BIGINT;
  DECLARE @product_user_id BIGINT;
  DECLARE @user_name VARCHAR(1000);
  DECLARE @fin_inst VARCHAR(5000);
  DECLARE @spid INT 
  DECLARE @permitted_nodes VARCHAR(5000);
  
  SELECT @user_id = [USER_ID] FROM inserted;
  
  select  
        @product_user_id = product_usr_id,	
		@user_name=pu.product_usr_name,
	   @fin_inst= fi.fi_name,
	   @spid= @@spid

	FROM
	 (sec_product_users AS pu INNER JOIN sec_users AS u ON pu.user_id = u.user_id) LEFT JOIN sec_passwords AS p ON pu.product_pwd_id = p.password_id
	 JOIN pp_financial_institutions fi ON U.group_id = FI.sec_group_id_employee
	 WHERE pu.user_id = @user_id
	
	 IF NOT EXISTS(select portal_user_name FROM pp_user_sessions_financial_institutions(NOLOCK) WHERE session_id = @spid )
	 BEGIN
	 SELECT @permitted_nodes = [permitted_nodes] FROM [pp_financial_institution_nodes](NOLOCK) WHERE  @fin_inst =[financial_institution_name]
	  INSERT INTO 
	 pp_user_sessions_financial_institutions
	 VALUES (
	 @product_user_id,@user_name,@fin_inst,@spid, @permitted_nodes
	 )
	 END
	 ELSE BEGIN
	 	 SELECT @permitted_nodes = [permitted_nodes] FROM [pp_financial_institution_nodes](NOLOCK) WHERE  @fin_inst =[financial_institution_name]

	 UPDATE pp_user_sessions_financial_institutions
	 SET 
	    portal_user_id =@product_user_id,	
		portal_user_name = @user_name,
	    financial_institution = @fin_inst ,
	    [permitted_nodes]=@permitted_nodes
	    WHERE session_id = @spid
	 END
  
  
  END