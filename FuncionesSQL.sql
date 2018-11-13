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
/*
FIN Verificar usuarios con conecciones activas en SQL
*/

/* Limpiar Log de base de datos*/
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
/*FIN impiar Log de base de datos*/

/* BUscar un string en toda la base de datos */
DECLARE @resultados TABLE (columna nvarchar(370), valor nvarchar(3630))
DECLARE @tabla nvarchar(256), @columna nvarchar(128), @cadenaBuscar nvarchar(110)
SET  @tabla = ''
SET @cadenaBuscar = QUOTENAME('%César%','''')
 
WHILE @tabla IS NOT NULL
    BEGIN
        SET @columna = ''
        SET @tabla =
        (SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @tabla AND OBJECTPROPERTY(OBJECT_ID( QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) ), 'IsMSShipped' ) = 0)
        WHILE (@tabla IS NOT NULL) AND (@columna IS NOT NULL)
            BEGIN
                SET @columna = (SELECT MIN(QUOTENAME(COLUMN_NAME)) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = PARSENAME(@tabla, 2) AND TABLE_NAME = PARSENAME(@tabla, 1) AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar') AND QUOTENAME(COLUMN_NAME) > @columna)
                IF @columna IS NOT NULL
                    BEGIN
                        INSERT INTO @resultados
                        EXEC ( 'SELECT ''' + @tabla + '.' + @columna + ''', LEFT(' + @columna + ', 3630) FROM ' + @tabla + ' (NOLOCK) ' + ' WHERE ' + @columna + ' LIKE ' + @cadenaBuscar ) 
                    END
                END
    END
 
SELECT columna, valor FROM @resultados

/* FIN BUscar un string en toda la base de datos */


/*Buscar un string en todos SP*/
declare @search varchar(50)
SET @search = 'sp_SAFNO_InsertarSYM'

SELECT 
ROUTINE_NAME
,ROUTINE_DEFINITION
FROM 
INFORMATION_SCHEMA.ROUTINES
WHERE 
ROUTINE_DEFINITION LIKE '%' + @search + '%'
AND ROUTINE_TYPE ='PROCEDURE'
ORDER BY
ROUTINE_NAME

/*FIN Buscar un string en todos SP*/
