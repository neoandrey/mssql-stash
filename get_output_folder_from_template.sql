--get all folders
SELECT  SUBSTRING(CONVERT(VARCHAR(2000),output_params),2, LEN(CONVERT(VARCHAR(2000),output_params))-CHARINDEX('\', REVERSE(CONVERT(VARCHAR(2000),output_params)))) FROM reports_crystal WHERE output_params LIKE '%merchant%'

--change folder
UPDATE reports_crystal set output_params = REPLACE(CONVERT(VARCHAR(max),output_params ), 'G:', 'H:')

--get folder create for command prompt
SELECT  'MKDIR "'+SUBSTRING(CONVERT(VARCHAR(2000),output_params),2, LEN(CONVERT(VARCHAR(2000),output_params))-CHARINDEX('\', REVERSE(CONVERT(VARCHAR(2000),output_params))))+'"' FROM reports_crystal --WHERE output_params LIKE '%merchant%'

SELECT  'MKDIR "'+SUBSTRING(CONVERT(VARCHAR(2000),output_params),2, LEN(CONVERT(VARCHAR(2000),output_params))-CHARINDEX('\', REVERSE(CONVERT(VARCHAR(2000),output_params))))+'"' FROM reports_crystal --WHERE output_params LIKE '%merchant%'



Extract:SELECT 'MKDIR "'+CONVERT(VARCHAR(2000),STANDARD_OUTPUT)+'"'  FROM extract_entity (NOLOCK)

