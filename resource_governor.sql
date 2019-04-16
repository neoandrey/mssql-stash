CREATE RESOURCE POOL pool_name [WITH
([
   MIN_CPU_PERCENT =value, ][[,]
    MAX_CPU_PERCENT =value, ][[,]
   MIN_MEMORY_PERCENT =value, ][[,]
    MAX_MEMORY_PERCENT =value, ][[,]
   
   ]



)];
values are in percentages


CREATE WORKLOAD GROUP group_name [WITH

	([ 
	    IMPORTANCE ={LOW|MEDIUM|HIGH}][[,]
	    REQUEST_MAX_MEMORY_GRANT_PERCENT = VALUE ][[,]
	    REQUEST_MAX_CPY_TIME_SEC = VALUE ][[,]
	    REQUEST_MEMORY_GRANT_TIMEOUT_SEC= VALUE ][[,]
	    MAX_DROP =][[,]
	    GROUP_MAX_REQUESTS =VALUE ]
	    )]
	    [
	
              USING {pool_name|"default"}
              
               ];
               
               
   CREATE FUNCTION dbo.ClassifierFunctionName()
   	RETURNS SYSNAME WITH SCHEMABINDING 
   	AS 
   	  BEGIN
   	    RETURN (
   	        SELECT CASE SUSER_SNAME()
   	               WHEN 'ProductionProc' THEN  'HighPriorityGrp'
   	               WHEN 'ReportingProc' THEN   'MidPriorityGrp'
   	               ELSE 'LowPriorityGrp'
   	               
   	               END);
   	               
   	               END 
   	               
   	               GO
   	              
   	    
   	    
   	    )
