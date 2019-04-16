
CREATE TABLE post_tran_archive_sources (
id INT NOT NULL identity(1,1),
server_name VARCHAR(255) NOT NULL,
database_name VARCHAR(255) NOT NULL,
start_date  DATETIME NOT NULL,
last_tran_date  DATETIME,
end_date	DATETIME NOT NULL,
copy_complete BIT NOT NULL DEFAULT(0),
constraint pk_post_tran_archive_sources PRIMARY KEY(
id
)
)

CREATE UNIQUE INDEX ix_server_db_name ON post_tran_archive_sources (
	server_name, database_name

)


CREATE  INDEX ix_server_name ON post_tran_archive_sources (
	server_name

)



CREATE  INDEX ix_database_name ON post_tran_archive_sources (
	database_name

)


CREATE  INDEX ix_last_tran_date ON post_tran_archive_sources (
	id, last_tran_date

)
