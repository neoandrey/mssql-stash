
update post_rtfw_servers SET is_active =1, last_connect_datetime=GETDATE(), permit_cms=1, permit_dts=1, permit_support_events=1 WHERE datasource_name='postilion_mirror_dr2'

update post_rtfw_servers SET is_active =0, last_connect_datetime='1971-01-01', permit_cms=0, permit_dts=0, permit_support_events=0 WHERE datasource_name <>'postilion_mirror_dr2'