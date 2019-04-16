CASE
    WHEN  (source_node_name = 'SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk' AND acquiring_inst_id_code !='627787') 
	    OR 
		  (source_node_name ='SWTFBPsrc' AND  sink_node_name = 'ASPPOSVISsnk' AND totalsgroup  = 'VISAGroup')
		   THEN 'Intl Visa Transactions (Co-acquired)' 
     WHEN merchant_type NOT  IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')
	       AND  ( merchant_type <3501 OR   merchant_type >4000)  AND  ( LEFT(terminal_id,1)  IN ('2','5')) and {@IndustrySegmentSupplVisa} = '4'
			THEN 'General Merchant and Airline (Operators)'
	 WHEN merchant_type IN ('2002','4002','4003','8398','8661','5814','8666')  and {@IndustrySegmentSupplVisa} = '4'
			THEN 'Churches, FastFoods and NGOs'
			
		WHEN  merchant_type = '1008' AND  {@IndustrySegmentSupplVisa} = '4'
			THEN    'Concession Category'
	   WHEN  merchant_type IN ('4004', '4722') AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Travel Agencies'
		  WHEN  merchant_type IN ('5001','5002','7011') AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Hotels & Guest Houses (T&E)'
		 WHEN  convert(int, merchant_type)  >= 3501   AND  convert(int, merchant_type)  <= 3501 {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Hotels & Guest Houses (T&E)'
				 WHEN   merchant_type IN ('1002','5300','5051') and  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Wholesale'
			 WHEN  merchant_type = '1111'  AND  {@IndustrySegmentSupplVisa} = '4' 
			    THEN  'WholeSale_Acquirer_Borne'
			WHEN  merchant_type IN ('4001','5541','9752') AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'FuelStations'
			 	WHEN  merchant_type ='5542' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Easyfuel'
			WHEN  merchant_type ='2010' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(5%)'
			 	WHEN  merchant_type ='2010' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(5%)'
			 	  	 
					 	WHEN  merchant_type ='2011' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  merchant_type ='2011' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  merchant_type ='2012' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(6%)'
			 	  	 
					 	WHEN  merchant_type ='2013' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(7%)'
			 			 	WHEN  merchant_type ='2014' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(10%)'
			 	  	 
				WHEN  merchant_type ='2015' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(12.5%)'
					WHEN  merchant_type ='2016' AND  {@IndustrySegmentSupplVisa} = '4' 
			 THEN 'Reward Money(15%)'
			 WHEN   merchant_type IN ('9001','9002','9003','9004','9005','9006') and {@IndustrySegmentSupplVisa} = '4'
				then 'WEBPAY Generic'	 
			 when  {@IndustrySegmentSupplVisa} = '1' then 'POS(GENERAL MERCHANT-VISA)PURCHASE'
when {@IndustrySegmentSupplVisa} = '2' then 'POS(2% CATEGORY-VISA)PURCHASE'
when  {@IndustrySegmentSupplVisa} = '3' then 'POS(3% CATEGORY-VISA)PURCHASE'
else Category_name+' '+merchant_type
END