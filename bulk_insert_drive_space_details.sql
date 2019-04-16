BULK
       INSERT 
           disk_drive_usage
           		FROM  'C:\Program Files\PostilionOfficeUtility\disk_report.csv'
   WITH (

			FIELDTERMINATOR =',',
			ROWTERMINATOR ='\n'

		)
           		
           		GO
