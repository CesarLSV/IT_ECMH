/*
Calcular fecha  20180531 15:47 pm
*/

declare @bd varchar(50)
set @bd = '20100601'

SELECT        PEOPLE_CODE_ID, BIRTH_DATE, DATEDIFF(year, ''+@bd+'', GETDATE()) - (CASE WHEN datepart(month, ''+@bd+'') > datepart(month, getdate()) THEN 1 
WHEN datepart(month, ''+@bd+'') = datepart(month, getdate()) 
                         AND datepart(day, ''+@bd+'') > datepart(day, getdate()) THEN 1 ELSE 0 END) AS AGE
FROM            dbo.PEOPLE
WHERE        (PEOPLE_CODE_ID = 'P019950004')





/*Crear Json desde SQL
Unicamente SQL 2016 o superior*/


SELECT     modulo.modulo, modulo.descripcion,
(
SELECT m.modulo, m.descripcion, r.descripcion, r.nombrereporte

            FROM reporte_modulo as m,reporte_modulo  as r

            WHERE m.modulo = r.modulo 

            FOR JSON auto
			
			) AS Emails

FROM         modulo

