CREATE TABLE #visa_chargeback_transaction (
 pan VARCHAR(19),
 card_acceptor_name_loc VARCHAR(250),
 transaction_date DATETIME,
 card_acceptor_id_code   VARCHAR(150)
 
)
DECLARE  @pan VARCHAR(19), @card_acceptor_name_loc VARCHAR(250),@transaction_date DATETIME, @card_acceptor_id_code   VARCHAR(150);

CREATE TABLE  #temp_visa_transactions (pan VARCHAR(19), stan VARCHAR(30), terminal_id VARCHAR(19), tran_amount NUMERIC (20,2), transaction_date DATETIME,acquiring_bank VARCHAR(250) );


INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4707241000009819','IKOYIHOTELSOUTHERNSU','20131018','2058D026');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110913685','PANASERVNIGERIALIMITE','20131231','2058M550');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4483810008999039','IKOYIHOTELSOUTHERNSU','20131018','2058D026');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110085401','BANGILA(NIG)LTD','20140130','2058N136');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4124510135505908','R873855473','20140128','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4124510135505908','R223394002','20140129','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4124510135505908','R276008373','20140129','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4029445066113495','R190336096','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4029445066113495','R675954084','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4029445066113495','R461749211','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300015685991','R996551547','20140202','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R813227249','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R450093565','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R478735393','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R722101148','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R455615772','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R316428606','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R907997140','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R699031671','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R705318299','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R366268453','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R937349544','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R517283250','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R425445560','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R857576177','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R479748616','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R423342517','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R672315911','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R654348964','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R642001501','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R865299272','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R344984382','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R710897789','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R801819450','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R540806019','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R767101614','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R124815879','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R486141021','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R810812277','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R334427517','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R033823496','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R571798884','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R658980305','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R816539394','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R563275084','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R280003698','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R538848860','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R203602850','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R246444390','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R162517805','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R864374495','20140204','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R709869414','20140205','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R803625928','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R757319784','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R830817940','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4503300004526776','R299478669','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4427930003709776','R408849317','20140201','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4427930003709776','R164627753','20140201','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4427930003709776','R952704462','20140201','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4147099852572773','R597167705','20140127','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4147099852572773','R244788503','20140127','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4427930003709776','R933773419','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4500030116038708','IKOYIHOTELSOUTHERNSU','20140225','2058D024');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4147340024144103','R699793025','20140206','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000011109','SEAFBULLSNIGERIAENT','20140302','2058J898');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000011109','SEAFBULLSNIGERIAENT','20140303','2058J898');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000168310','OKAYCOMPUTERSLTD','20140222','2058A395');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4356813402291304','R286454410','20140208','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4430450060388476','R696062989','20140212','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714153800003259','GRANDSQ.SUPERMARKET','20140301','2058J975');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000375422','SBLLOGISTICS&SUPPLY','20140127','2058J252');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714152500007503','THEBRIDGECLINIC','20140303','20580264');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714150400030286','SPEEDWINGSLOGOSTICS','20140219','2058K805');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4121265890136745','R547053715','20140210',NULL);
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4121265890136745','R848658210','20140210',NULL);
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714151400030417','ESSENZAINTERNATIONAL','20140315','2058N098');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000268527','CHERRIESSUPERMART&','20140201','2058E100');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4864030004105213','UPDCHOTELLTDGOLDEN','20140312','2058D067');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000244822','BEAUTY&FRAGRANCEIN','20140313','20583585');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4147099545879148','R625408098','20130212','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110155998','GATIMOLIMITED(RUFF&','20140223','2058M450');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714151100014638','1004ESTATELIMITED','20140329','20583340');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4577660000662391','ALIBERTPRODUCTSNIG.','20140219','20585919');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4706510000348588','SLOTSYSTEMSLIMITED(S','20140111','2058K317');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000186247','FOUANINIGERIALIMITED','20131108','2058H915');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714150400031961','DUNESINVESTMENT&GL','20140302','20587471');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R813840603','20140209','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R469601026','20140209','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R907407034','20140209','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R514307331','20140209','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R721869924','20140209','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R593056913','20140210','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841010374955','R268500604','20140210','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000278161','FEEDWELLSUPERMARKET','20140402','2058Q479');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960268000050933','ZENGARDENCHINESERE','20140212','2058A474');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960268000050933','ZENGARDENCHINESERE','20140404','2058A474');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714153000005732','JANNYSINTERNATIONAL','20140327','2058J735');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714153900003548','DVFASHIONLIMITED(C','20140328','2058A475');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4053852532736602','R111099208','20140128','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4053852532736602','R401951666','20140128','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4053852532736602','R196327682','20140128','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4889922710012751','CONSUMERCOMMODITIES','20140303','20580035');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714150900000359','PINNAHFOODLIMITED','20140314','2058Q163');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4037840058626530','ETRANZACTINTERNATIONAL','20140416','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4147202151210968','ETRANZACTINTERNATIONAL','20140421','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4714150300043066','REDDINGTONMULTISPECI','20140201','20580269');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000383970','ETRANZACTINTERNATIONAL','20140409','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000275035','ETRANZACTINTERNATIONAL','20140414','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4197420000094354','R123461388','20140207','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4563545112787788','ETRANZACTINTERNATIONAL','20140411','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4563545112787788','ETRANZACTINTERNATIONAL','20140411','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4622390126475024','WAKANOW.COMLIMITED','20140416','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4375510231494003','ETRANZACTINTERNATIONAL','20140408','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4417123047035059','R363148936','20140211','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4417123047035059','R090222094','20140211','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4417123047035059','R648398398','20140212','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4465392003654028','WORLDNTRAVELANDLTD','20140408','GTBS2I03');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4133885002530356','ETRANZACTINTERNATIONAL','20140411',NULL);
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000011109','SEAFBULLSNIGERIAENT','20140302','2058J898');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000011109','SEAFBULLSNIGERIAENT','20140302','2058J898');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4412510003832732','R778402290','20140203','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4583010000015681','PENIELAPARTMENT','20140326','2058E082');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4889922600014479','SLOTSYSTEMSLIMITED','20140325','2058K317');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4580980100897381','ETRANZACTINTERNATIONAL','20140423','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960268000049653','R592937335','20140506','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266880036552392','R293903941','20140211','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4128003668565818','SHUBHAMIMPEXLIMITED','20140418','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000197551','XOVARLOUNGELIMITED','20140301','2058J950');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000197551','XOVARLOUNGELIMITED','20140301','2058J950');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000024409','ETRANZACTINTERNATIONAL','20140410','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960268000045172','BUKKYVICKYENTERPRISE','20140422','2058R169');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960268000045172','BUKKYVICKYENTERPRISE','20140423','2058R169');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000087999','ETRANZACTINTERNATIONAL','20140426','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000096564','WAKANOW.COMLIMITED','20140427','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000096564','WAKANOW.COMLIMITED','20140427','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000096564','WAKANOW.COMLIMITED','20140427','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000282486','FORAMOTNIGERIALIMIT','20140506','20584764');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960230000282486','FORAMOTNIGERIALIMIT','20140506','20584764');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000201038','ADAM&EVEENTERPRISES','20140505','2058K116');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960260000201038','ADAM&EVEENTERPRISES','20140505','2058K116');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4960220000113021','ETRANZACTINTERNATIONAL','20140430','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4500740000041770','ETRANZACTINTERNATIONAL','20140409','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4500740000041770','ETRANZACTINTERNATIONAL','20140410','GTBS2I01');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4889922460017901','BUDOSPECIALISTHOSPI','20140329','2058A557');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4889922430024326','CLAMA/C2(EXPRESS)','20140511','2050F107');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4465390012021338','WORLDNTRAVELANDLTD','20140408','GTBS2I03');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140409','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140409','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140409','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140410','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140414','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140416','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140416','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140416','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4489153050964419','WAKANOW.COMLIMITED','20140416','GTBS2I04');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110130280','GLOBALSYNTEKPRIVATE','20140326','2058M658');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110130280','GLOBALSYNTEKPRIVATE','20140327','2058M659');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110180905','CHAMPIONINTER''LSUPE','20140426','2050A899');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110999106','SWEETSENSATIONCONFE','20140329','20587208');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110999106','SWEETSENSATIONCONFE','20140329','20587208');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4266841309740528','R246535664','20130210','3IWPDKON');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4600550013439823','CORPORATEAFFAIRSCO','20140205','2058M367');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4685881110451942','STANDARDALLIANCEINS','20140430','20584102');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4585872100002762','AXARIHOTELANDSUITES','20140520','2058M021');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4075440011669983','3J''SHOTELSLIMITED','20140513','2058D074');
INSERT INTO #visa_chargeback_transaction (pan,card_acceptor_name_loc,transaction_date,card_acceptor_id_code) VALUES('4075440011669983','3J''SHOTELSLIMITED','20140513','2058D074');


DECLARE tran_cursor  CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan, card_acceptor_name_loc, transaction_date, card_acceptor_id_code FROM #visa_chargeback_transaction;

OPEN tran_cursor;

FETCH NEXT FROM tran_cursor INTO @pan,@card_acceptor_name_loc,@transaction_date,@card_acceptor_id_code;

WHILE (@@FETCH_STATUS=0)BEGIN

 INSERT INTO 
       #temp_visa_transactions (pan, stan, terminal_id, tran_amount, transaction_date,acquiring_bank)
 SELECT DISTINCT  
       pan, system_trace_audit_nr, terminal_id, tran_amount_rsp/100.0, datetime_req, acquiring_inst_id_code
 FROM 
      post_tran trans (NOLOCK) 	JOIN
      post_tran_cust cust (NOLOCK) 
 ON   
     trans.post_tran_cust_id = cust.post_tran_cust_id
 WHERE 
     pan=@pan
     AND
    (  card_acceptor_name_loc LIKE @card_acceptor_name_loc+'%'
            OR
      terminal_id = @card_acceptor_id_code
      )
      AND 
      datetime_req >= @transaction_date 

      PRINT 'PAN: '+@pan+CHAR(10);
      PRINT 'card_acceptor_name_loc: '+@card_acceptor_name_loc+CHAR(10)
      PRINT 'datetime_req: '+CONVERT(VARCHAR(50), @transaction_date)+CHAR(10)
      PRINT  'card_acceptor_id_code: '+@card_acceptor_id_code+CHAR(10)
     FETCH NEXT FROM tran_cursor INTO @pan,@card_acceptor_name_loc,@transaction_date,@card_acceptor_id_code;
END
CLOSE tran_cursor;
DEALLOCATE tran_cursor;

SELECT * FROM #temp_visa_transactions
--SELECT * FROM #visa_chargeback_transaction
--DROP TABLE #post_tran_cust_id
DROP TABLE #temp_visa_transactions
DROP TABLE #visa_chargeback_transaction
