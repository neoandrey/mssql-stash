
  SELECT [filename], drives.[drive_letter], total_space, [size] as filesize, CONVERT(FLOAT,SUBSTRING([usable_space], 0, LEN([usable_space])-1))*1024*1024  usable_space_1, CONVERT(FLOAT,SUBSTRING([growth], 0, LEN([growth])-1))  growth_new_2,  CASE  WHEN 
CONVERT(FLOAT,SUBSTRING([growth], 0, LEN([growth])-1)) = 0 THEN 0
ELSE
 CONVERT(INT,(CONVERT(FLOAT,SUBSTRING([usable_space], 0, LEN([usable_space])-1))*1024*1024/CONVERT(FLOAT,SUBSTRING([growth], 0, LEN([growth])-1)) ))
END  growth_multiples FROM postilion_office.dbo.disk_drive_usage drives, post_office_file_size_details files WHERE drives.drive_letter = LEFT(files.[filename],2);	
