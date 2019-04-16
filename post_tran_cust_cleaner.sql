
while exists (select top 1 post_tran_cust_id from post_tran_cust (nolock)
where post_tran_cust_id < (select MIN(post_tran_cust_id) from post_tran (nolock , INDEX(ix_post_tran_2)))
order by post_tran_cust_id)
begin
	delete from  post_tran_cust
	where post_tran_cust_id in(

	select top 1000 post_tran_cust_id 
	from post_tran_cust (nolock)

	where post_tran_cust_id < (select MIN(post_tran_cust_id) from post_tran (nolock, INDEX(ix_post_tran_2)))
	order by post_tran_cust_id)

end