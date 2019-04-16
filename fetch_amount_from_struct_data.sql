

SELECT (convert(xml,[structured_data_req])).value('(/MediaTotals/Totals/Amount)[1]',	'VARCHAR(40)')
  FROM [test_db].[dbo].[structured_data]