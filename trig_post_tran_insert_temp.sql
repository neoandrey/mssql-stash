create trigger [trig_post_tran_insert_temp]  on  POST_TRAN 
INSTEAD OF INSERT  

AS BEGIN


   IF  NOT EXISTs (SELECT * FROM post_tran t WITH(NOLOCK) join inserted i on  t.tran_nr = i.tran_nr AND  t.message_type = i.message_type and t.tran_postilion_originated = i.tran_postilion_originated and  t.online_system_id = i.online_system_id and t.recon_business_date = '2018-03-21')
    BEGIN 

	insert into  post_tran select * from inserted 

	end 
	end
