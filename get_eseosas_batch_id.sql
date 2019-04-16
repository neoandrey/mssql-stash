DECLARE card_acceptor_name_loc VARCHAR(100);
DECLARE @lastSlash VARCHAR(100);

SET  card_acceptor_name_loc='05082014/JUNE2014OVERTIME/758412/   LANG';
--SET  card_acceptor_name_loc='28082014/AUGUSTSAL/782628/          LANG';
--SET  card_acceptor_name_loc='28082014/AUGUSTSAL/782628/          LANG';
--SET  card_acceptor_name_loc='28082014/AUGUSTSAL/782628/          LANG';
--SET  card_acceptor_name_loc='28082014/AUGUSTSAL/782628/          LANG';
--SET  card_acceptor_name_loc='28082014/AUGUSTSAL/782628/          LANG';

SELECT REVERSE(SUBSTRING(SUBSTRING(REVERSE(card_acceptor_name_loc), CHARINDEX('/', REVERSE(card_acceptor_name_loc))+1, LEN(card_acceptor_name_loc)),0, CHARINDEX('/',SUBSTRING(REVERSE(card_acceptor_name_loc), CHARINDEX('/', REVERSE(card_acceptor_name_loc))+1, LEN(card_acceptor_name_loc)))))

