
SELECT * FROM post_process_param WHERE process_name = 'Settlement' AND param_name='WorkerThreads'
SELECT * FROM post_process_param WHERE process_name = 'Settlement' AND param_name='Throttle'

UPDATE post_process_param SET value =90 WHERE process_name = 'Settlement' AND param_name='Throttle'
UPDATE post_process_param SET value =12 WHERE process_name = 'Settlement' AND param_name='WorkerThreads'