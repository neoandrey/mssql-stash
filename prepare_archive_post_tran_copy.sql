ALTER TABLE    post_tran NOCHECK CONSTRAINT ALL
DELETE FROM post_tran

ALTER TABLE    post_tran_cust NOCHECK CONSTRAINT ALL
DELETE FROM post_tran_cust

select * from post_tran