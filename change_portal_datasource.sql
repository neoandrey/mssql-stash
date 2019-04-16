use realtime;
GO

SELECT * FROM prod_class_reg

SELECT * FROM prod_reg


[dbo].[prod_update_datasources]
 
	@prod_name                     VARCHAR(255),
	@realtime_ds                   VARCHAR(50),
	@postcard_ds                   VARCHAR(50),
	@office_ds                     VARCHAR(50)

EXEC prod_update_datasources 'ATM', 'realtime', NULL, NULL
EXEC prod_update_datasources 'OFFICE', NULL, NULL, 'postilion_office'


For example, to reconfigure the ATM plug-in to connect to a realtime data source named 'realtime_atm'
(but leave the postcard and office databases, if any, used by the plug-in unchanged), execute the
following:
prod_update_datasources 'ATM', 'realtime_atm', NULL, NULL
Restart Tomcat for these changes to take effect.