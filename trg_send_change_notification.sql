CREATE TRIGGER trg_send_change_notification ON ReportServer.dbo.change_events 
AFTER INSERT 
AS

BEGIN

DECLARE @body_message VARCHAR(MAX);
DECLARE @subject_text  VARCHAR(MAX);
DECLARE  @EventData XML;
DECLARE @event_time  VARCHAR(30);
DECLARE @user_account VARCHAR(255);
DECLARE @ip VARCHAR(30);

   IF NOT EXISTS( SELECT index_num FROM  ReportServer.dbo.administrative_users (NOLOCK) WHERE login_name = SUSER_SNAME()) BEGIN
		SELECT  @EventData = EventXML, @ip = ipaddress,@user_account =  FROM inserted;

SET @subject_text ='Change Restriction on: '+HOST_NAME();
	                
	                SET @body_message =  '<p>Hello, Support.</p>'
	                +'<p>Trust this meets you well</p>'
	                +'<p>Please be informed that <strong>'''+ Replace(SUSER_SNAME(),'.', '') +'''</strong> attempted to make a change in the '''+DB_NAME()+''' database at '+@event_time+'</p>'
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
	    
	               EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Office Vigilante Profile',
        @recipients    = 'coretechnology@interswitchgroup.com',
		@copy_recipients='gbolahan.olowokandi@interswitchgroup.com,mobolaji.aina@interswitchgroup.com',
		@subject = @subject_text,
		@body_format = 'HTML',
		@importance = 'Normal',
		@body = @body_message
	END
	end