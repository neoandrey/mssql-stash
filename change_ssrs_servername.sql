  UPDATE [ReportServer].[dbo].[Subscriptions] SET Description = REPLACE( REPLACE (CONVERT(VARCHAR(MAX),Description), 'ASPOFFICE64','ASPOFFICE5DR'), '172.25.15.15' , '172.75.75.18')
  
  
    UPDATE [ReportServer].[dbo].[Subscriptions] SET Description = REPLACE( REPLACE (CONVERT(VARCHAR(MAX),Description), 'OFFICE330DDR','MEGAOFFICE40D64'), '172.25.10.9' , '172.75.75.8')