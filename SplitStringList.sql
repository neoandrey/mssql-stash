*/
use AdventureWorks
go
create function SplitStringList(@ListString nvarchar(MAX), @delim varchar(2) = ',')
returns @vals table (Item nvarchar(60))
as 
begin
  declare @CurLoc int, @Item nvarchar(60)
  while len(@ListString) > 0
  begin
    set @CurLoc = charindex(@delim, @ListString, 1)
    if @CurLoc = 0
      begin
        set @Item = @ListString
		set @Item = Ltrim(RTrim(@Item))
        set @ListString = ''
      end
    else
      begin
        set @Item = left(@ListString, @CurLoc - 1)
		set @Item = Ltrim(RTrim(@Item))
        set @ListString = substring(@ListString, @CurLoc + 1, Len(@ListString) - @CurLoc)
      end
    insert into @vals (Item) values (@Item)  
    end
    return
end
go