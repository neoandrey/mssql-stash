Exec sp_ppinScriptTabla 'table_name'

Use Master
GO

Create Function sp_ppinTipoLongitud
(
    @xtype int,
    @length int,
    @isnullable int
)
Returns Varchar(512)
As 
Begin
    -- Función que a partir de un tipo de datos y una logitud, devuelve el texto del tipo.
    -- Por ejemplo: para xtype=varchar y length=10 devolverá "varchar(10)"
    Declare @ret varchar(512)
    Set @ret = ''

    Select @ret = t.name +
    Case When name in ('varchar', 'nvarchar', 'char', 'nchar') Then '(' + Convert(varchar, @length) + ')' Else '' End + ' ' +
    Case @isnullable When 1 Then 'NULL' Else 'NOT NULL' End
    From systypes t 
    Where t.xtype = @xtype

    Return @ret
End
GO

Create Procedure sp_ppinScriptLlavesForaneas
(
    @vchTabla sysname,
    @vchResultado varchar(8000) output
)
AS 
Begin

    DECLARE @tmpFK table(
    	TablaF sysname,
    	TablaR sysname,
    	ColF sysname,
    	ColR sysname,
    	FKName sysname)

    -- obtengo las llaves foraneas en @vchForeign
    Declare @vchForeign varchar(8000), @FKName sysname, @vchColumnasF varchar(4000), @vchColumnasR varchar(4000), @ColF sysname, @ColR sysname
    Declare @vchTemp varchar(1000), @TablaR sysname

    Insert into @tmpFK
    Select TablaF.name AS TablaF, TablaR.name AS TablaR, ColF.name AS ColF, ColR.name AS ColR, ofk.name AS FKName
    From sysforeignkeys fk, sysobjects ofk, sysobjects TablaF, sysobjects TablaR, 
    syscolumns ColF, syscolumns ColR
    Where TablaF.name = @vchTabla
    And ofk.id = fk.constid
    And TablaF.id = fk.fkeyid
    And TablaR.id = fk.rkeyid
    And ColF.id = TablaF.id And ColF.colid = fk.fkey
    And ColR.id = TablaR.id And ColR.colid = fk.rkey
    order by FKName

    Set @vchForeign = ''
    While Exists ( Select * From @tmpFK )
    Begin
    	Select Top 1 @FKName = FKName From @tmpFK
    	Set @vchColumnasF = ''
    	Set @vchColumnasR = ''
    	While Exists ( Select * From @tmpFK Where FKName = @FKName )
    	Begin
    		Select Top 1 @ColF = ColF, @ColR = ColR, @TablaR = TablaR From @tmpFK Where FKName = @FKName
    		Delete From @tmpFK Where ColF = @ColF And ColR = @ColR And TablaR = @TablaR And FKName = @FKName
    		Set @vchColumnasF = @vchColumnasF + @ColF + ', '
    		Set @vchColumnasR = @vchColumnasR + @ColR + ', '
    	End

    	Set @vchColumnasF = LEFT(@vchColumnasF, LEN(@vchColumnasF) - 1)
    	Set @vchColumnasR = LEFT(@vchColumnasR, LEN(@vchColumnasR) - 1)
    	Set @vchTemp = 'Constraint ' + @FKName + ' Foreign Key (' + @vchColumnasF + ') '
    	Set @vchTemp = @vchTemp + 'References ' + @TablaR + ' (' + @vchColumnasR + ')'
    	Set @vchForeign = @vchForeign + char(9) + @vchTemp + ',' + char(13) 
    End

    Select @vchResultado = Case When Len(@vchForeign) >=2 Then Left(@vchForeign, Len(@vchForeign) - 2) Else @vchForeign End
End
GO

Create Procedure sp_ppinScriptTabla
(
    @vchTabla sysname
)
AS

Set nocount on

-- Obtengo las foreign keys
Declare @foreign varchar(8000)
Exec sp_ppinScriptLlavesForaneas @vchTabla, @foreign output

-- SELECT que devuelve el script de Create Table de la tabla
Select 'Create ' + 
Case o.xtype When 'U' Then 'Table' When 'P' Then 'Procedure' Else '??' End + ' ' +
@vchTabla + char(13) + '('
From sysobjects o
Where o.name = @vchTabla
Union all
-- Campos + identitys + DEFAULTS
select char(9) + c.name + ' ' + 								-- Nombre
dbo.sp_ppinTipoLongitud(t.xtype, c.length, c.isnullable) +  		-- Tipo(longitud)
Case When c.colstat & 1 = 1 									-- Identity (si aplica)
    Then ' Identity(' + convert(varchar, ident_seed(@vchTabla)) + ',' + Convert(varchar, ident_incr(@vchTabla)) + ')' 
    Else '' 
End + 
Case When not od.name is null   								-- Defaults (si aplica)
    Then ' Constraint ' + od.name + ' Default ' + replace(replace(cd.text, '((', '('), '))', ')')
    Else ''
End + ', '
from sysobjects o, syscolumns c
LEFT OUTER JOIN sysobjects od On od.id = c.cdefault LEFT OUTER join syscomments cd On cd.id = od.id, 
systypes t
where o.id = object_id(@vchTabla)
and o.id = c.id
and c.xtype = t.xtype
Union all
-- Primary Keys y Unique keys
select char(9) + 'Constraint ' + o.name + ' ' +
Case o.xtype When 'PK' Then 'Primary Key' Else 'Unique' End + ' ' +
dbo.sp_ppinCamposIndice (db_name(), @vchTabla, i.indid) + ', '
from sysobjects o, sysindexes i
where o.parent_obj = object_id(@vchTabla)
and o.xtype in ('PK','UQ')
and i.id = o.parent_obj
and o.name = i.name
Union all
-- Check constraints
select char(9) + 'Constraint ' + o.name + ' Check ' + c.text + ', '
from sysobjects o, syscomments c
where o.parent_obj = object_id(@vchTabla)
and o.xtype in ('C')
and o.id = c.id
Union all
-- Foreign keys
Select @foreign
Union all
Select ')'

Set nocount off
GO

