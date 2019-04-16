To script All the Stored Procedures in the Database :

SELECT    O.Name as ProcName
        ,M.Definition as CreateScript
        ,O.Create_Date
        ,O.Modify_Date
FROM sys.sql_modules as M INNER JOIN sys.objects as O
ON M.object_id = O.object_id
WHERE O.type = 'P'

If the Stored Procedure is created with ENCRYPTION option then you will get the NULL in the definition column.

Similarly,

To script All the Views in the Database :

SELECT    O.Name as ProcName
        ,M.Definition as CreateScript
        ,O.Create_Date
        ,O.Modify_Date
FROM sys.sql_modules as M INNER JOIN sys.objects as O
ON M.object_id = O.object_id
WHERE O.type = 'V'

To script All the Functions in the Database :

SELECT    O.Name as ProcName
        ,M.Definition as CreateScript
        ,O.Create_Date
        ,O.Modify_Date
FROM sys.sql_modules as M INNER JOIN sys.objects as O
ON M.object_id = O.object_id
WHERE O.type = 'FN'

For scripting all Triggers small modification is required, instead of sys.objects I joined the sys.triggers with sys.sql_modules.

To script All the Triggers in the Database :

SELECT    O.Name as ProcName
        ,M.Definition as CreateScript
        ,O.Create_Date
        ,O.Modify_Date
FROM sys.sql_modules as M INNER JOIN sys.triggers as O
ON M.object_id = O.object_id

Mangal Pardeshi 