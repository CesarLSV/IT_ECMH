declare @bd varchar(50)
set @bd = '20100601'

SELECT        PEOPLE_CODE_ID, BIRTH_DATE, DATEDIFF(year, ''+@bd+'', GETDATE()) - (CASE WHEN datepart(month, ''+@bd+'') > datepart(month, getdate()) THEN 1 
WHEN datepart(month, ''+@bd+'') = datepart(month, getdate()) 
                         AND datepart(day, ''+@bd+'') > datepart(day, getdate()) THEN 1 ELSE 0 END) AS AGE
FROM            dbo.PEOPLE
WHERE        (PEOPLE_CODE_ID = 'P019950004')