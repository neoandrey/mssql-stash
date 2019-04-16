

   Declare @ip VARchAR(20)
Declare @ipLine varchar(200)
Declare @pos int

          set @ip = NULL
          declare  @temp  table(ipLine varchar(200))
          Insert @temp exec master..xp_cmdshell 'ipconfig'
          select @ipLine = ipLine
          from @temp
          where  (ipLine) like '%IP%'
          if (isnull (@ipLine,'***') != '***')
          begin 
                set @pos = CharIndex (':',@ipLine,1);
                set @ip = rtrim(ltrim(substring (@ipLine , 
               @pos + 1 ,
                len (@ipLine) - @pos)))
           end 
SELECT  @ip
