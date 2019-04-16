  


USE [master]
GO

/****** Object:  Table [dbo].[administrative_users]    Script Date: 11/08/2016 13:07:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[administrative_users](
	[index_num] [int] IDENTITY(1,1) NOT NULL,
	[login_name] [varchar](255) NULL,
	[team] [varchar](500) NULL,
	[is_monitored] [bit] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [master]
GO

/****** Object:  Table [dbo].[change_events]    Script Date: 11/08/2016 13:07:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[change_events](
	[EventDate] [datetime] NOT NULL,
	[EventType] [nvarchar](64) NULL,
	[EventDDL] [nvarchar](max) NULL,
	[EventXML] [xml] NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[SchemaName] [nvarchar](255) NULL,
	[ObjectName] [nvarchar](255) NULL,
	[HostName] [varchar](255) NULL,
	[IPAddress] [varchar](32) NULL,
	[ProgramName] [nvarchar](255) NULL,
	[LoginName] [nvarchar](255) NULL,
	[UserName] [nvarchar](255) NULL,
	[EventTime] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[change_events] ADD  DEFAULT (getdate()) FOR [EventDate]
GO

insert into  [master].[dbo].[administrative_users]  values ('officeadmin', 'CoreTech',0);
DECLARE @host_name VARCHAR(70);
SET @host_name = @@SERVERNAME+'\Administrator';
insert into  [master].[dbo].[administrative_users]  values (@host_name, 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('sa', 'SQL',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Chris.Esumeh', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Princess.Edoosagie', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Olasupo.Ogunsanya', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Damilola.Akinshiku', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Josiah.Adenegan', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Oladimeji.Isola', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Adetokunbo.Ige', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Gbolahan.Olowokandi', 'CoreTech',0)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Mobolaji.Aina', 'CoreTech',0)
	insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Ebun.Reffell', 'Settlement',1)
insert into  [master].[dbo].[administrative_users]  values ('INTERSWITCH\Owolabi.Akala', 'TPPOPS',1)
 

select s.name,l.name
 from  msdb..sysjobs s 
 left join master.sys.syslogins l on s.owner_sid = l.sid
 WHERE  CONVERT(VARCHAR(MAX),L.name collate SQL_Latin1_General_CP1_CI_AS  ) not in(
 select  CONVERT(VARCHAR(MAX),login_name collate SQL_Latin1_General_CP1_CI_AS )   from [master].dbo.[administrative_users] 
 )


  CREATE TRIGGER DDL_FILTER_USER_ACCESS
        ON DATABASE	 
         FOR DDL_DATABASE_LEVEL_EVENTS
    AS
    BEGIN
        SET NOCOUNT ON;
        
            
             DECLARE @body_message VARCHAR(MAX);
             DECLARE @subject_text  VARCHAR(MAX);
            DECLARE   @EventData XML = EVENTDATA();
                DECLARE 
           @ip VARCHAR(32) = '172.25.10.88'
         DECLARE @event_time VARCHAR(50) = CONVERT(VARCHAR(MAX), GETDATE());
             
           IF NOT EXISTS( SELECT index_num FROM  master.dbo.administrative_users (NOLOCK) WHERE login_name = SUSER_SNAME()) BEGIN
           
            ROLLBACK;
              
          
     
         
           set @ip = ISNULL(
            (
                SELECT client_net_address
                    FROM sys.dm_exec_connections
                    WHERE session_id = @@SPID
            ),@ip );
        SET @event_time = CONVERT(VARCHAR(MAX), GETDATE());
              
	                RAISERROR( 'You do not have permissions to make this change. Please contact an Administrator for some assistance.',16,1)
	                
	                SET @subject_text ='Change Restriction on: '+HOST_NAME();
	                
	                SET @body_message =  '<p>Hello, Support.</p>'
	                +'<p>Trust this meets you well</p>'
	                +'<p>Please be informed that <strong>'+SUSER_SNAME()+'</strong> attempted to make a change in the '+DB_NAME()+' database at '+@event_time+'</p>'
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
	                
        INSERT master.dbo.change_events
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
	    
	    
	               EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Office Vigilante Profile',
        @recipients    = 'coretechnology@interswitchgroup.com',
		@copy_recipients='gbolahan.olowokandi@interswitchgroup.com,mobolaji.aina@interswitchgroup.com',
		@subject = @subject_text,
		@body_format = 'HTML',
		@importance = 'Normal',
		@body = @body_message
	            
	            
	            
          END
          ELSE BEGIN
          
          
     
        SET 
           @ip  =isnull(
            (
                SELECT client_net_address
                    FROM sys.dm_exec_connections
                    WHERE session_id = @@SPID
            ),@ip ) ;
         SET @event_time = CONVERT(VARCHAR(MAX), GETDATE());
                       SET @subject_text ='Change Permitted on: '+HOST_NAME();
                       SET @body_message ='<p>Hello, Support.</p>'
	                +'<p>Trust this meets you well</p>'
	                +'<p>Please be informed that <strong>'+SUSER_SNAME()+'</strong> attempted to make a change in the '+DB_NAME()+' database at '+@event_time+'</p>'
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
          
          IF EXISTS(  SELECT index_num FROM  master.dbo.administrative_users (NOLOCK) WHERE login_name = SUSER_SNAME() AND is_monitored = 1)BEGIN
				   EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Office Vigilante Profile',
				 @recipients    = 'coretechnology@interswitchgroup.com',
		@copy_recipients='gbolahan.olowokandi@interswitchgroup.com,mobolaji.aina@interswitchgroup.com',
				@subject = @subject_text,
				@body_format = 'HTML',
				@importance = 'Normal',
				@body = @body_message
	       END     
	            
        INSERT master.dbo.change_events
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