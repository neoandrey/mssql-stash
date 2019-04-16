del -f "c:\temp\tabdiff\tm_sink_node_mapped_fields_sync.sql"
del -f "c:\temp\tabdiff\tm_sink_node_mapped_fields_update_log.txt"

"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver 172.25.15.213 -sourceuser aspoffice_normalizer -sourcepassword Interswitch@10 -sourcedatabase realtime -sourcetable tm_sink_node_mapped_fields -destinationserver 172.75.75.113 -destinationuser office_norm_account -destinationpassword Password123 -destinationdatabase realtime -destinationtable  tm_sink_node_mapped_fields  -f "c:\temp\tabdiff\tm_sink_node_mapped_fields_sync"

SQLCMD -S 172.75.75.113 -U office_norm_account  -P Password123 -d realtime  -i  "c:\temp\tabdiff\tm_sink_node_mapped_fields_sync.sql" -o  "c:\temp\tabdiff\tm_sink_node_mapped_fields_update_log.txt"	