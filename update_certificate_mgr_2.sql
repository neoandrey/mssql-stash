--INSERT INTO post_pki_keys (key_nr, check_value) VALUES(2, 'A8C86D')
SELECT * FROM post_pki_keys
SELECT * FROM post_rtfw_servers

UPDATE post_pki_keys SET key_nr =3 WHERE check_value ='045536';
UPDATE post_pki_keys SET key_nr =2 WHERE check_value ='A8C86D';
UPDATE post_pki_keys SET key_nr =1 WHERE check_value = '045536';


UPDATE post_rtfw_servers SET is_active=0, last_connect_datetime ='1970-01-01 00:00:00.000', permit_dts =0, permit_cms =0, permit_support_events =0  WHERE datasource_name ='postilion_mirror_2'
UPDATE post_rtfw_servers SET is_active=1, last_connect_datetime = getdate(), permit_dts =1, permit_cms =1, permit_support_events =1  WHERE datasource_name ='postilion_mirror'

SELECT * FROM post_pki_keys

SELECT * FROM post_rtfw_servers



UPDATE post_pki_keys SET key_nr =3 WHERE check_value ='A8C86D';
UPDATE post_pki_keys SET key_nr =2 WHERE check_value ='045536';
UPDATE post_pki_keys SET key_nr =1 WHERE check_value = 'A8C86D';


UPDATE post_rtfw_servers SET is_active=0, last_connect_datetime ='1970-01-01 00:00:00.000', permit_dts =0, permit_cms =0, permit_support_events =0  WHERE datasource_name ='postilion_mirror'
UPDATE post_rtfw_servers SET is_active=1, last_connect_datetime = getdate(), permit_dts =1, permit_cms =1, permit_support_events =1  WHERE datasource_name ='postilion_mirror_2'
