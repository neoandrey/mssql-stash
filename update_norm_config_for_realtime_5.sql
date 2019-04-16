SELECT * FROM post_pki_keys
select * from post_rtfw_servers

--insert into  post_pki_keys values(3,'4F03AE')


update post_rtfw_servers set  is_active =0, last_connect_datetime ='1970-01-01 00:00:00.000', permit_cms =0, permit_dts =0 , permit_support_events =0 WHERE datasource_name = 'postilion_mirror'
update post_rtfw_servers set  is_active =1, last_connect_datetime =getdate(), permit_cms =1, permit_dts =1 , permit_support_events =1 WHERE datasource_name = 'postilion_mirror_2'



update post_pki_keys SET key_nr =4 WHERE key_nr =1
update post_pki_keys SET key_nr =1 WHERE key_nr =3
update post_pki_keys SET key_nr =3 WHERE key_nr =4