
 
 UPDATE reports_crystal SET  output_params = CASE WHEN output_format = 9 THEN replace(convert(varchar(max),output_params),'.csv','')+'.csv~3~,~"~'
           WHEN output_format = 10 THEN replace(convert(varchar(max),output_params),'.xls','')+'.xls~3~1'
           WHEN output_format = 12 THEN  replace(convert(varchar(max),output_params),'.pdf','')+'.pdf~3~1~'
           ELSE replace(convert(varchar(max),output_params),'.csv','')+'.csv~3~,~"~'
           
           END 
  WHERE RIGHT(convert(VARCHAR(MAX),output_params),1)<> '~'
