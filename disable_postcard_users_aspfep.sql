SELECT usr.id [user_id], usr.login_name, usr.first_name, usr.last_name, dom.name, dom.id domain_id,* 
FROM ui_users usr JOIN ui_domains dom ON usr.domain_id =dom.id WHERE dom.name IN (
 'ACCESSCASHCARD',
 'FIBCASHCARD', 
 'AFRICASHCARD',
 'GTBCASHCARD',
 'SBPCASHCARD',
 'ZIBCASHCARD',
 'CITICASHCARD',
 'FBPCASHCARD',
 'DBPCASHCARD',
 'UBNCASHCARD',
 'PHBCASHCARD',
 'UBPCASHCARD'
 )
  AND usr.account_disabled <> 1
 

 
 
 UPDATE ui_users  SET account_disabled =1 WHERE login_name  IN (
 SELECT usr.login_name FROM ui_users usr JOIN ui_domains dom ON usr.domain_id =dom.id
  WHERE dom.name IN (
 'ACCESSCASHCARD',
 'FIBCASHCARD', 
 'AFRICASHCARD',
 'GTBCASHCARD',
 'SBPCASHCARD',
 'ZIBCASHCARD',
 'CITICASHCARD',
 'FBPCASHCARD',
 'DBPCASHCARD',
 'UBNCASHCARD',
 'PHBCASHCARD',
 'UBPCASHCARD'
 )
  AND usr.account_disabled <> 1
 )
 
 
 
 
 
 
 
)