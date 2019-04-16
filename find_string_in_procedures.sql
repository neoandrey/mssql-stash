SELECT
    OBJECT_NAME(OBJECT_ID),
    definition
FROM
    sys.sql_modules
WHERE
    objectproperty(OBJECT_ID, 'IsProcedure') = 1
AND definition LIKE '%Foo%'