CREATE PROCEDURE  usp_sync_card_acceptor_with_aspfep5  
AS
BEGIN
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_card_acceptor') is not NULL) begin
		 DROP TABLE  #temp_tm_card_acceptor
		 END  

		 IF  (   OBJECT_ID('tempdb.dbo.#temp_cp_limits_classes') is not NULL) begin
		 DROP TABLE  #temp_cp_limits_classes
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_cp_card_sets') is not NULL) begin
		 DROP TABLE  #temp_cp_card_sets
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_routing_groups') is not NULL) begin
		 DROP TABLE  #temp_tm_routing_groups
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_currencies') is not NULL) begin
		 DROP TABLE  #temp_tm_currencies
		 END  
 
 
		SELECT * INTO #temp_tm_card_acceptor  FROM [ASPFEP5].realtime.dbo.tm_card_acceptor with (NOLOCK)
		create index ix_index_1  ON  #temp_tm_card_acceptor(card_acceptor)
		create index ix_index_2  ON  #temp_tm_card_acceptor( name_location)
		SELECT * INTO #temp_cp_limits_classes  FROM [ASPFEP5].realtime.dbo.cp_limits_classes with (NOLOCK)
		create index ix_index_1 ON #temp_cp_limits_classes (limits_class)
		SELECT * INTO #temp_cp_card_sets  FROM [ASPFEP5].realtime.dbo.cp_card_sets with (NOLOCK)
		CREATE INDEX ix_index_1  ON #temp_cp_card_sets (card_set)
		SELECT * INTO #temp_tm_routing_groups  FROM [ASPFEP5].realtime.dbo.tm_routing_groups with (NOLOCK)
		CREATE INDEX ix_index_1 ON  #temp_tm_routing_groups (routing_group)
		SELECT * INTO #temp_tm_currencies  FROM [ASPFEP5].realtime.dbo.tm_currencies with (NOLOCK)
		CREATE INDEX ix_index_1 ON  #temp_tm_currencies (currency_code)

		INSERT INTO realtime.dbo.cp_limits_classes SELECT * FROM [ASPFEP5].realtime.dbo.#temp_cp_limits_classes with (NOLOCK)  WHERE  limits_class  NOT in  (SELECT  limits_class FROM realtime.dbo.cp_limits_classes with (NOLOCK)) 

		INSERT INTO realtime.dbo.cp_card_sets SELECT * FROM #temp_cp_card_sets with (NOLOCK)  WHERE  card_set  NOT in  (SELECT  card_set FROM realtime.dbo.cp_card_sets with (NOLOCK)) 

		INSERT INTO realtime.dbo.tm_routing_groups SELECT * FROM #temp_tm_routing_groups with (NOLOCK)  WHERE  routing_group  NOT in  (SELECT  routing_group FROM realtime.dbo.tm_routing_groups with (NOLOCK)) 

		INSERT INTO realtime.dbo.tm_currencies SELECT * FROM #temp_tm_currencies  with (NOLOCK)  WHERE  currency_code  NOT in  (SELECT  currency_code FROM realtime.dbo.tm_currencies with (NOLOCK)) 


		INSERT INTO  realtime.dbo.tm_card_acceptor

		  SELECT  * FROM  #temp_tm_card_acceptor  WHERE  card_acceptor NOT  IN  (SELECT card_acceptor FROM  realtime.dbo.tm_card_acceptor  WITH (nolock) )
		and 
		name_location NOT IN (
		SELECT name_location FROM  realtime.dbo.tm_card_acceptor  WITH (nolock) 
		)



		 IF  (   OBJECT_ID('tempdb.dbo.#temp_cp_limits_classes') is not NULL) begin
		 DROP TABLE  #temp_cp_limits_classes
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_cp_card_sets') is not NULL) begin
		 DROP TABLE  #temp_cp_card_sets
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_routing_groups') is not NULL) begin
		 DROP TABLE  #temp_tm_routing_groups
		 END  

		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_currencies') is not NULL) begin
		 DROP TABLE  #temp_tm_currencies
		 END  


		 DECLARE  @card_acceptor VARCHAR(255), @name_location  VARCHAR(255), @currency_code  VARCHAR(255), @default_lang  VARCHAR(255), @card_set  VARCHAR(255), @limit_class  VARCHAR(255),
				  @routing_group  VARCHAR(255), @support_team  VARCHAR(255),  @worst_event_severity  VARCHAR(255), @status  VARCHAR(255), @merchant_type  VARCHAR(255)

		DECLARE  card_acceptor_cursor CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY  FOR  SELECT  a.card_acceptor, a.name_location, a.currency_code, a.default_lang, a.card_set, a.limits_class, a.routing_group, a.support_team, 
																								 a.worst_event_severity, a.status, a.merchant_type FROM #temp_tm_card_acceptor  a with (NOLOCK) JOIN   tm_card_acceptor b  with (NOLOCK) ON 
																								 a.card_acceptor = b.card_acceptor 
																								 AND  (
																								  a.name_location != b.name_location 
																								   OR  a.currency_code != b.currency_code
																								   OR  a.default_lang != b.default_lang
																								   OR  a.card_set != b.card_set
																								   OR  a.limits_class != b.limits_class
																								   OR  a.routing_group != b.routing_group
																								   OR  a.support_team != b.support_team
																								   OR  a.worst_event_severity != b.worst_event_severity
																								   OR  a.status != b.status
																								   OR  a.merchant_type != b.merchant_type
																								 )

		OPEN  card_acceptor_cursor
		FETCH NEXT FROM  card_acceptor_cursor  INTO @card_acceptor, @name_location, @currency_code, @default_lang, @card_set, @limit_class, @routing_group, @support_team,  @worst_event_severity, @status, @merchant_type
		WHILE (@@FETCH_STATUS = 0 ) BEGIN
		BEGIN TRY 

		UPDATE  realtime.dbo.tm_card_acceptor 
				SET  name_location		   = @name_location
					 ,currency_code	       = @currency_code
					 ,default_lang		   = @default_lang
					 ,card_set			   = @card_set
					 ,limits_class		   = @limit_class
					 ,routing_group		   = @routing_group
					 ,support_team		   = @support_team
					 ,worst_event_severity = @worst_event_severity
					 ,[status]             = @status
					 ,merchant_type        = @merchant_type
		WHERE  card_acceptor			   = @card_acceptor 
                  
		FETCH NEXT FROM  card_acceptor_cursor  INTO @card_acceptor, @name_location, @currency_code, @default_lang, @card_set, @limit_class, @routing_group, @support_team,  @worst_event_severity, @status, @merchant_type
		PRINT  @card_acceptor +CHAR(10)

		END TRY
		BEGIN  CATCH 
		FETCH NEXT FROM  card_acceptor_cursor  INTO @card_acceptor, @name_location, @currency_code, @default_lang, @card_set, @limit_class, @routing_group, @support_team,  @worst_event_severity, @status, @merchant_type
		PRINT   'card_acceptor: '+ @card_acceptor +
				' ErrorNumber: '+ ERROR_NUMBER() +  
				' ErrorSeverity: '+ERROR_SEVERITY()+  
				' ErrorState: '+ERROR_STATE() +   
				' ErrorProcedure: '+ERROR_PROCEDURE()+  
				' ErrorMessage: '+ ERROR_MESSAGE() 
				+CHAR(10)
		CONTINUE
		END  CATCH


		END 


		IF  (   OBJECT_ID('tempdb.dbo.#temp_tm_card_acceptor') is not NULL) begin
		 DROP TABLE  #temp_tm_card_acceptor
		 END  


 END
