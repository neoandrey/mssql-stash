CREATE TABLE template_parameter_transalation (parameter_name VARCHAR(3000), translation VARCHAR(3000))

INSERT INTO template_parameter_transalation 

SELECT  distinct parameter_name,CASE WHEN DATA_TYPE =  'datetime' THEN 'EDITBOX='+REPLACE(PARAMETER_NAME,'@','')+' in ''''yyyymmdd'''' format:; 100;1;DEFAULT:NULL' ELSE 'EDITBOX='+REPLACE(PARAMETER_NAME,'@','')+':; 1000;0;DEFAULT:NULL' END as transalation  FROM INFORMATION_SCHEMA.PARAMETERS (nolock) WHERE LTRIM(RTRIM(PARAMETER_NAME))!=''

  SELECT [template_name], specific_name, trans.parameter_name, trans.translation  FROM 
  [template_procedure_mapping] tmpt (NOLOCK)
  JOIN
  INFORMATION_SCHEMA.PARAMETERS  params (nolock) ON
  tmpt.procedure_name = params.SPECIFIC_NAME
  JOIN
  template_parameter_transalation trans (NOLOCK) ON
  params.PARAMETER_NAME = trans.PARAMETER_NAME
  ORDER BY template_name