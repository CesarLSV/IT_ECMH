/*
Calcular fecha / edad  20180531 15:47 pm
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



/*
Verificar usuarios con conecciones activas en SQL
*/

SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame
;


-- Limpiar Log de base de datos
USE sig;  
GO  
-- Truncate the log by changing the database recovery model to SIMPLE.  
ALTER DATABASE sig
SET RECOVERY SIMPLE;  
GO  
-- Shrink the truncated log file to 1 MB.  
DBCC SHRINKFILE (sig_log, 1);  
GO  
-- Reset the database recovery model.  
ALTER DATABASE sig
SET RECOVERY FULL;  
GO 


select * from sys.database_files;

