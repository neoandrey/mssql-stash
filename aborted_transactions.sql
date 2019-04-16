CREATE TABLE aborted_transactions(
	 serial_number BIGINT IDENTITY(1,1) NOT NULL,
	 tran_nr BIGINT,
	 stan_desc TEXT,
	 online_system_id INT,
	 [status] INT,
	 date_of_creation DATETIME
	 CONSTRAINT serial_num_cons PRIMARY KEY (serial_number)

)
