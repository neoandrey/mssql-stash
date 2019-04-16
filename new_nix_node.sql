declare @interface varchar(100)
declare @interchange varchar(100)
declare @address varchar(100)

declare @protocol varchar(100)
declare @setup_data varchar(1000)
declare @sap_class varchar(200)
declare @sap_parameters varchar(100)
declare @sap_address varchar(1000)
DECLARE @misc_options INT

declare @is_client_connection BIT

Set @interface = 'PostBridge'

declare cr cursor for 
SELECT node from SWTHOST.realtime.dbo.node WITH (nolock) where node_interface = @interface

open cr

fetch next from cr into @interchange

while @@FETCH_STATUS=0
begin

	IF EXISTS ( select * from nix_connections (nolock) WHERE nix_name in (@interchange+ 'Clt',@interchange+ 'Svr'))
	begin
		print 'Sap '+@interchange+' already exists!...checking connections'
		goto rollover
	end
	PRINT 'INTERCHANGE ' + @interchange



IF(CHARINDEX('CCPB', @interchange)>1) BEGIN
 SET @misc_options = 44
END

IF(CHARINDEX('CCPB', @interchange)<1) BEGIN
SET @misc_options = 13
END

INSERT   
INTO              nix_connections(nix_name, nix_type, misc_options, msg_profile)
VALUES        (@interchange+ 'Clt','TCP Client',@misc_options,@interface)

IF(CHARINDEX('CCPB', @interchange)>1) BEGIN
SET @misc_options = 13
END


IF(CHARINDEX('CCPB', @interchange)<1) BEGIN
 SET @misc_options = 44
END


INSERT   
INTO              nix_connections(nix_name, nix_type, misc_options, msg_profile)
VALUES        (@interchange+ 'Svr','TCP Server',@misc_options,@interface)

declare cr2 cursor for select address from SWTHOST.realtime.dbo.node_conns WITH (nolock) where node = @interchange

open cr2
fetch next from cr2 into @address

WHILE @@FETCH_STATUS = 0
begin
 ---client saps found...address is ip,port
	declare @hostname varchar(50)
	declare @port varchar(50)

	set @hostname = substring(@address,1,CHARINDEX(',',@address)-1)
	set @port = substring(@address,CHARINDEX(',',@address)+1,LEN(@address)-CHARINDEX(',',@address))

	--create client sap
	IF EXISTS (SELECT * FROM nix_connection_param_value WHERE nix_name=@interchange+ 'Clt' AND nix_type='TCP Client' AND param_name= 'Remote Connection')
	BEGIN
		declare @conn_nr int
		select @conn_nr = MAX(substring(param_value,1,1))+1 FROM nix_connection_param_value WHERE nix_name=@interchange+ 'Clt' AND nix_type='TCP Client' AND param_name= 'Remote Connection'
		INSERT      
		INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
		VALUES        (@interchange+ 'Clt','TCP Client','Remote Connection', cast(@conn_nr as varchar(2))+';'+@interchange+cast(@conn_nr as varchar(2))+';;'+@address)
		GOTO next_conn
	END

	INSERT      
		INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
		VALUES        (@interchange+ 'Clt','TCP Client','Remote Connection', '1;'+@interchange+';;'+@address)
		
	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES        (@interchange+ 'Clt','TCP Client','Max Nr Failures','10')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES        (@interchange+ 'Clt','TCP Client','A/A Leadership Election Context',@interchange+ 'Clt')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES        (@interchange+ 'Clt','TCP Client','Reconnect Delay On Partner Disconnect','2000')

	/**check if special type client*/
	select @protocol = protocol, @sap_address=address, @setup_data=setup_data from SWTHOST.realtime.dbo.node_saps WITH (nolock) where node = @interchange and protocol <> 0
	if(@protocol is not null AND @protocol <> '0')
	begin
			INSERT      
			INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
			VALUES        (@interchange+ 'Clt','TCP Client','SAP Protocol',@protocol)
		if(@protocol ='100') --generic protocol
		begin
			set @sap_class = substring(@setup_data,1,CHARINDEX(',',@setup_data)-1)
			set @setup_data = substring(@setup_data,CHARINDEX(',',@setup_data)+1,LEN(@setup_data)-CHARINDEX(',',@setup_data))
			--print @setup_data
			INSERT      
			INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
			VALUES        (@interchange+ 'Clt','TCP Client','SAP Class',@sap_class)
			
			declare @string varchar(1000)
			declare @to_insert varchar(2000)
			declare @part varchar(100)

			if(@sap_address is null OR @sap_address = '0,' OR @sap_address = '0' OR @sap_address ='')
			begin
				set @string = @setup_data
			end
			else
			begin
				set @string = @sap_address
			end
			--print @string
			declare @indx int
			declare @count int
			set @count = 0
			set @to_insert = ''
			set @indx =  CHARINDEX(',',@string)
			WHILE @indx>0
			begin
				Set @count = @count + 1
				set @part = substring(@string,1,CHARINDEX(',',@string)-1)
				set @string = substring(@string,CHARINDEX(',',@string)+1,LEN(@string)-CHARINDEX(',',@string))
				
				--print @string
				set @to_insert = @to_insert + '<parameter_'+cast(@count as varchar(2))+'>'+@part+ '</parameter_'+cast(@count as varchar(2))+'>'
				set @indx =  CHARINDEX(',',@string)
			end
			set @to_insert = @to_insert + '<parameter_n>'+@string+'</parameter_n>'
			INSERT   
			INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
			VALUES        (@interchange+ 'Clt','TCP Client','SAP Parameters','<parameters>'+@to_insert+'</parameters>')
		end
		else
		begin
			INSERT      
			INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
			VALUES        (@interchange+ 'Clt','TCP Client','SAP Setup Data',@setup_data)
		end

	end

	--create server sap
	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','Traffic Splitting Strategy','Priority')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','A/A Leadership Election Context',@interchange+ 'Svr')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','Port Number',@port)

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','IP Address','NIXHOST')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','Reconnect Delay On Partner Disconnect','2000')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','Remote Connection','1;SNIXHOST;;SNIXHOST')

	INSERT      
	INTO              nix_connection_param_value(nix_name, nix_type, param_name, param_value)
	VALUES (@interchange+ 'Svr','TCP Server','Remote Connection','2;SWTPARTNER;;SWTPARTNER')
	
	next_conn:
	fetch next from cr2 into @address
end
close cr2 
deallocate cr2

declare cr3 cursor for select address from SWTHOST.realtime.dbo.node_saps WITH (nolock) where node = @interchange and sap_type =1

open cr3
fetch next from cr3 into @address

WHILE @@FETCH_STATUS = 0	-- it is a server sap instead...get details from node_saps
begin	
		set @hostname = substring(@address,1,CHARINDEX(',',@address)-1)
		set @port = substring(@address,CHARINDEX(',',@address)+1,LEN(@address)-CHARINDEX(',',@address))

		IF EXISTS (SELECT * FROM nix_connection_param_value WHERE nix_name=@interchange+ 'Svr' AND nix_type='TCP Server' AND param_name= 'Port Number')
		BEGIN
				INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
				VALUES       (@interchange+ 'Svr','TCP Server','Port Number',@port)
			GOTO next_conn2
		END

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Clt','TCP Client','Remote Connection','2;SWTPARTNER;;SWTPARTNER,'+@port)

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Clt','TCP Client','Reconnect Delay On Partner Disconnect','2000')

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Clt','TCP Client','Remote Connection','1;SWTHOST;;SWTHOST,'+@port)

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Clt','TCP Client','Max Nr Failures','10')

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Clt','TCP Client','A/A Leadership Election Context', @interchange+ 'Clt')

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Svr','TCP Server','Reconnect Delay On Partner Disconnect','2000')

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Svr','TCP Server','IP Address','SNIXHOST')

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Svr','TCP Server','Port Number',@port)

		INSERT INTO nix_connection_param_value
								 (nix_name, nix_type, param_name, param_value)
		VALUES       (@interchange+ 'Svr','TCP Server','A/A Leadership Election Context', @interchange+ 'Svr')
		
		next_conn2:
	fetch next from cr3 into @address
end
close cr3
deallocate cr3

IF NOT EXISTS (SELECT nix_source FROM nix_routes(NOLOCK) WHERE nix_source =@interchange+ 'Svr') 
BEGIN
	INSERT       
	INTO              nix_routes(nix_source, nix_dest, state)
	VALUES        (@interchange+ 'Svr',@interchange+ 'Clt',1)
END
ELSE  BEGIN
 PRINT @interchange+ 'Svr already exists'
 END

 IF NOT EXISTS (SELECT nix_source FROM nix_routes(NOLOCK) WHERE nix_source =@interchange+ 'Clt') 
BEGIN
INSERT     
	INTO              nix_routes(nix_source, nix_dest, state)
	VALUES        (@interchange+ 'Clt',@interchange+ 'Svr',1)
	END
ELSE  BEGIN
 PRINT @interchange+ 'Clt already exists'
 END

rollover:
fetch next from cr into @interchange

end

close cr
deallocate cr

