USE ReportServer;
go

CREATE TABLE  [administrative_users] (
    index_num INT  IDENTITY(1,1),
    login_name   VARCHAR(255),
    team	VARCHAR(500)

)
go

CREATE TABLE dbo.change_events
(
    EventDate    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EventType    NVARCHAR(64),
    EventDDL     NVARCHAR(MAX),
    EventXML     XML,
    DatabaseName NVARCHAR(255),
    SchemaName   NVARCHAR(255),
    ObjectName   NVARCHAR(255),
    HostName     VARCHAR(255),
    IPAddress    VARCHAR(32),
    ProgramName  NVARCHAR(255),
    LoginName    NVARCHAR(255),
    UserName 	 NVARCHAR(255),
    EventTime    NVARCHAR(50)
);


       USE postilion_office;
    GO
    
    USE postilion_office;
    GO
    
    
    ALTER TRIGGER DDL_FILTER_USER_ACCESS
        ON DATABASE
         FOR DDL_DATABASE_LEVEL_EVENTS
    AS
    BEGIN
        SET NOCOUNT ON;
        
            
             DECLARE @body_message VARCHAR(MAX);
             DECLARE @subject_text  VARCHAR(MAX);
            DECLARE   @EventData XML = EVENTDATA();
                DECLARE 
           @ip VARCHAR(32) =
            (
                SELECT client_net_address
                    FROM sys.dm_exec_connections
                    WHERE session_id = @@SPID
            );
         DECLARE @event_time VARCHAR(50) = CONVERT(VARCHAR(MAX), GETDATE());
             
           IF NOT EXISTS( SELECT index_num FROM  ReportServer.dbo.administrative_users (NOLOCK) WHERE login_name = SUSER_SNAME()) BEGIN
           
            ROLLBACK;
              
          
     
         
           set @ip =
            (
                SELECT client_net_address
                    FROM sys.dm_exec_connections
                    WHERE session_id = @@SPID
            );
        SET @event_time = CONVERT(VARCHAR(MAX), GETDATE());
              
	                RAISERROR( 'You do not have permissions to make this change. Please contact an Administrator for some assistance.',16,1)
	                
	                SET @subject_text ='Change Restriction on: '+HOST_NAME();
	                
	                SET @body_message =  '<p>Hello, Support.</p>'
	                +'<p>Trust this meets you well</p>'
	                +'<p>Please be informed that <strong>'+SUSER_SNAME()+'</strong> attempted to make a change in the '+DB_NAME()+' at '+@event_time+'</p>'
	                +'<p>The details of the change  are: </p>'
	                +'<style type="text/css">
#box-table
{
font-family: "Arial", "Times mew Roman", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
font-size: 12px;
text-align: left;
border-collapse: collapse;
border-top: 7px solid #9baff1;
border-bottom: 7px solid #9baff1;
}
#box-table th
{
font-size: 13px;
font-weight: normal;
background: #b9c9fe;
border-right: 2px solid #9baff1;
border-left: 2px solid #9baff1;
border-bottom: 2px solid #9baff1;
color: #039;
}
#box-table td
{
border-right: 1px solid #aabcfe;
border-left: 1px solid #aabcfe;
border-bottom: 1px solid #aabcfe;
color:	black;
}
tr:nth-child(odd)	{ background-color:pink; }
tr:nth-child(even)	{ background-color:#fff; }	
</style><table id="box-table" >
	                        <tr><td><strong>Time</strong></td><td>'+@event_time+'</td></tr>
	                        <tr><td><strong>User</strong></td><td>'''+CONVERT(VARCHAR(128),SUSER_SNAME())+'''</td></tr>
				<tr><td><strong>Type</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)')+'</td></tr>
				<tr><td><strong>Command</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')+'</td></tr>
				<tr><td><strong>Schema</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)')+'</td></tr>
				<tr><td><strong>Object</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)')+'</td></tr>
				<tr><td><strong>Program</strong></td><td>'+PROGRAM_NAME()+'</td></tr>
				<tr><td><strong>IP Address</strong></td><td>'+ @ip+'</td></tr>
	                </table>'
	                +'<p>Please be on standby to review the change and provide support to '+SUSER_SNAME()+'.</p>'
	                +'<br />'
	                +'<p>Best regards</p>';
	                
        INSERT ReportServer.dbo.change_events
        (
            EventType,
            EventDDL,
            EventXML,
            DatabaseName,
            SchemaName,
            ObjectName,
            HostName,
            IPAddress,
            ProgramName,
            LoginName,
            UserName,
            EventTime
            
        )
        SELECT
            @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
            @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
            @EventData,
          CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
            @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
            @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
            HOST_NAME(),
            @ip,
            PROGRAM_NAME(),
            CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/LoginName)')),
	    CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/UserName)')),
	    @event_time;
          END
          ELSE BEGIN
          
          
     
        SET 
           @ip  =
            (
                SELECT client_net_address
                    FROM sys.dm_exec_connections
                    WHERE session_id = @@SPID
            );
         SET @event_time = CONVERT(VARCHAR(MAX), GETDATE());
                       SET @subject_text ='Change Permitted on: '+HOST_NAME();
                       SET @body_message ='<p>Hello, Support.</p>'
		       	                +'<p>Trust this meets you well</p>'
		       	                +'<p>Please be informed that <strong>'+SUSER_SNAME()+'</strong> attempted to make a change in the '+DB_NAME()+' at '+CONVERT(VARCHAR(MAX), GETDATE())+'</p>'
		       	                +'<p>The details of the change  are: </p>'
		       	                +'<style type="text/css">
#box-table
{
font-family: "Arial", "Times mew Roman", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
font-size: 12px;
text-align: left;
border-collapse: collapse;
border-top: 7px solid #9baff1;
border-bottom: 7px solid #9baff1;
}
#box-table th
{
font-size: 13px;
font-weight: normal;
background: #b9c9fe;
border-right: 2px solid #9baff1;
border-left: 2px solid #9baff1;
border-bottom: 2px solid #9baff1;
color: #039;
}
#box-table td
{
border-right: 1px solid #aabcfe;
border-left: 1px solid #aabcfe;
border-bottom: 1px solid #aabcfe;
color:	black;
}
tr:nth-child(odd)	{ background-color:skyblue; }
tr:nth-child(even)	{ background-color:#fff; }	
</style>'
						                +'<table id="box-table" >
						                        <tr><td><strong>Time</strong></td><td>'+@event_time+'</td></tr>
						                        <tr><td><strong>User</strong></td><td>'+CONVERT(VARCHAR(128), SUSER_SNAME())+'</td></tr>
									<tr><td><strong>Type</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)')+'</td></tr>
									<tr><td><strong>Command</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')+'</td></tr>
									<tr><td><strong>Schema</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)')+'</td></tr>
									<tr><td><strong>Object</strong></td><td>'+@EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)')+'</td></tr>
									<tr><td><strong>Program</strong></td><td>'+PROGRAM_NAME()+'</td></tr>
									<tr><td><strong>IP Address</strong></td><td>'+ @ip+'</td></tr>
	               			 </table>'
		       	                +'<p>The change was successful and no support is required.</p>'
		       	                +'<br />'
	                +'<p>Best regards</p>';
          END
          
           EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Office Vigilante Profile',
        @recipients    = 'mobolaji.aina@interswitchgroup.com',
		@copy_recipients='gbolahan.olowokandi@interswitchgroup.com',
		@subject = @subject_text,
		@body_format = 'HTML',
		@importance = 'Normal',
		@body = @body_message
	            
	            
        INSERT ReportServer.dbo.change_events
        (
            EventType,
            EventDDL,
            EventXML,
            DatabaseName,
            SchemaName,
            ObjectName,
            HostName,
            IPAddress,
            ProgramName,
            LoginName,
            UserName,
            EventTime
            
        )
        SELECT
            @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
            @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
            @EventData,
          CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
            @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
            @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
            HOST_NAME(),
            @ip,
            PROGRAM_NAME(),
            CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/LoginName)')),
	    CONVERT(VARCHAR(128), @EventData.query('data(/EVENT_INSTANCE/UserName)')),
	    @event_time;
          
          
    END
	
insert into  [ReportServer].[dbo].[administrative_users]  values ('officeadmin', 'CoreTech');
DECLARE @host_name VARCHAR(70);
SET @host_name = @@SERVERNAME+'\Administrator';
insert into  [ReportServer].[dbo].[administrative_users]  values (@host_name, 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('sa', 'SQL')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Chris.Esumeh', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Princess.Edoosagie', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Olasupo.Ogunsanya', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Damilola.Akinshiku', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Josiah.Adenegan', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Oladimeji.Isola', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Adetokunbo.Ige', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Gbolahan.Olowokandi', 'CoreTech')
insert into  [ReportServer].[dbo].[administrative_users]  values ('INTERSWITCH\Mobolaji.Aina', 'CoreTech')