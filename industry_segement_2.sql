CASE
    WHEN  (source_node_name = 'SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk' AND acquiring_inst_id_code !='627787') 
	    OR 
		  (source_node_name ='SWTFBPsrc' AND  sink_node_name = 'ASPPOSVISsnk' AND totalsgroup  = 'VISAGroup')
		   THEN 'Intl Visa Transactions (Co-acquired)' 
     WHEN nbs.merchant_type NOT  IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')
	       AND  ( nbs.merchant_type <3501 OR   nbs.merchant_type >4000)  AND  ( LEFT(nbs.terminal_id,1)  IN ('2','5')) and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			THEN 'General Merchant and Airline (Operators)'
	 WHEN nbs.merchant_type IN ('2002','4002','4003','8398','8661','5814','8666')  and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			THEN 'Churches, FastFoods and NGOs'
			
		WHEN  nbs.merchant_type = '1008' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			THEN    'Concession Category'
	   WHEN  nbs.merchant_type IN ('4004', '4722') AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Travel Agencies'
		  WHEN  nbs.merchant_type IN ('5001','5002','7011') AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Hotels & Guest Houses (T&E)'
		 WHEN  convert(int, nbs.merchant_type)  >= 3501   AND  convert(int, nbs.merchant_type)  <= 3501 and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Hotels & Guest Houses (T&E)'
				 WHEN   nbs.merchant_type IN ('1002','5300','5051') and   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Wholesale'
			 WHEN  nbs.merchant_type = '1111'  AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			    THEN  'WholeSale_Acquirer_Borne'
			WHEN  nbs.merchant_type IN ('4001','5541','9752') AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'FuelStations'
			 	WHEN  nbs.merchant_type ='5542' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Easyfuel'
			WHEN  nbs.merchant_type ='2010' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5%)'
			 	WHEN  nbs.merchant_type ='2010' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2011' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2011' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2012' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(6%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2013' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(7%)'
			 			 	WHEN  nbs.merchant_type ='2014' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Reward Money(10%)'
			 	  	 
				WHEN  nbs.merchant_type ='2015' AND NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(12.5%)'
					WHEN  nbs.merchant_type ='2016' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(15%)'
			 WHEN   nbs.merchant_type IN ('9001','9002','9003','9004','9005','9006') and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) then 'WEBPAY Generic'

			 when  (tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4') then 'POS(GENERAL MERCHANT-VISA)PURCHASE'
when  (tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR 
		(CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		(CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828) 
		))then 'POS(2% CATEGORY-VISA)PURCHASE'
when   (		tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4')

		then 'POS(3% CATEGORY-VISA)PURCHASE'
else Category_name+' '+nbs.merchant_type
END