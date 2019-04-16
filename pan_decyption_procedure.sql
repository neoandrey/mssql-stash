DECLARE @pan_decrypted VARCHAR (19)
DECLARE @error INT
EXEC osp_decrypt_pan '628051*********0344', '01G137GUDQUTJ44LC', 'Office Transaction Query Console', @pan_decrypted OUTPUT, @error OUTPUT, 0
SELECT @pan_decrypted AS 'pan', @error AS 'error'