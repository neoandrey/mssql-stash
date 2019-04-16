
UPDATE tm_trans SET

	structured_data_req = '212MerchantInfo262<MerchantInfo><TerminalId>44444444</TerminalId></MerchantInfo>218PrepaidMerchandise3149<?xml version="1.0" encoding="UTF-8"?><PrepaidMerchandise><Request><Product Type="PHONE" UserID="~Óú­" NetworkID="628051042" ProductID="6280510420"/>',
	structured_data_rsp = '212MerchantInfo262<MerchantInfo><TerminalId>44444444</TerminalId></MerchantInfo>218PrepaidMerchandise3149<?xml version="1.0" encoding="UTF-8"?><PrepaidMerchandise><Request><Product Type="PHONE" UserID="~Óú­" NetworkID="628051042" ProductID="6280510420"/>'

WHERE 
	tran_nr =2142035614 

