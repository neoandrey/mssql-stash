SELECT * FROM  post_normalization_session sess join
post_norm_rtfw_session rtfw 
on  
sess.normalization_session_id = rtfw.session_id
join post_online_system ons
ON sess.online_system_id= ons.online_system_id
ORDER BY datetime_creation desc 