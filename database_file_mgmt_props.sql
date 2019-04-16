USE postilion_office;

SELECT [NAME], [FILENAME],[SIZE], [MAXSIZE], ([MAXSIZE]- [SIZE]) AS FREE_SPACE FROM sysfiles;