DECLARE @structured_data_tag VARCHAR(MAX)
 
SET @structured_data_tag = 'EciFlag' 


EXEC(' 
SELECT top 10 CONVERT( XML,  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX(''<'', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),'';'','''')
  ).value(''(//*/'+@structured_data_tag+')[1]'', ''VARCHAR(MAX)'') xml_data ,  * from 
post_tran (nolock)
 WHERE
 CONVERT(VARCHAR(MAX),structured_data_req) LIKE ''%'+@structured_data_tag+'%''')
 

 /*

 CREATE FUNCTION get_value_from_structured_data (@structured_data_tag VARCHAR(MAX),structured_data VARCHAR(MAX) )
  RETURN VARCHAR
  AS BEGIN
  
  DECLARE @struct_xml XML
  DECLARE @return_value VARCHAR(MAX)
  SET @struct_xml   = CASE WHEN @structured_data NOT LIKE '%<%'+SPACE(1)+'%>%' THEN 
             CONVERT( XML,  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data)), LEN(CONVERT(VARCHAR(MAX),structured_data)) ),';',''))
			 ELSE '' END
			 
			 
   
   RETURN EXEC('DECLARE @xml_data XML
         SET @xml_data = '+@struct_xml+';

         SELECT @xml_data.value(''(//*/'+@structured_data_tag+')[1]'', ''VARCHAR(MAX)'') ')
  
  
  END
 */

select  top 10    CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(ThirdPartyBillPaymentExtension/BillPaymentResponseExtension/Provider)[1]', 'VARCHAR(MAX)'), CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  )
  , * from post_tran (nolock) where  
   structured_data_req NOT LIKE '%<%'+SPACE(1)+'%>%'
   AND 
   CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).query('//*') is not null
  



select  top 10    CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/Provider)[1]', 'VARCHAR(MAX)'), CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  )
  , * from post_tran (nolock) where  
   structured_data_req NOT LIKE '%<%'+SPACE(1)+'%>%'
   AND 
   CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).query('//*') is not null
  
  
  select  top 10    CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/Eciflag)[1]', 'VARCHAR(MAX)'), CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  )
  , * from post_tran (nolock) where  
  structured_data_req NOT LIKE '%<%'+SPACE(1)+'%>%'
   AND 
   CONVERT( XML, 

  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/Eciflag)[1]', 'VARCHAR(MAX)') is not null
  
  
  
  
  
SELECT top 10 CONVERT( XML,  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/EciFlag)[1]', 'VARCHAR(MAX)') eciflag ,  * from 
post_tran (nolock)
 where
 CONVERT(VARCHAR(MAX),structured_data_req) LIKE '%ECIFLAG%'
 
 
DECLARE @structured_data_tag VARCHAR(MAX)
 
SET @structured_data_tag = 'BufferC' 
 
SELECT top 10 CONVERT( XML,  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/'+@structured_data_tag+')[1]', 'VARCHAR(MAX)') xml_data ,  * from 
post_tran (nolock)
 where
 CONVERT(VARCHAR(MAX),structured_data_req) LIKE '%'+@structured_data_tag+'%'
 