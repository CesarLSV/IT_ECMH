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




/*Eliminar connections de sql >= 2005*/

USE [master];

DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('ECMH_SA')

EXEC(@kill);

/*FIN Eliminar connections de sql >= 2005*/




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


/*Reseed identity table TSQL*/

DBCC CHECKIDENT ('exalumno.[exalumno]', RESEED, 4001)  

/* FINReseed identity table TSQL*/					   
					
/*Respaldar todas las bases de datos vía SQLCMD*/					

DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = 'C:\Respaldos\DB\'  
 
-- specify filename format
SELECT @fileDate = replace(convert(varchar, getdate(),23),'/','') +'_'+replace(convert(varchar, getdate(),8),':','')
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor

/*Fín Respaldar todas las bases de datos vía SQLCMD*/
					
					
/*Pruebas de estress sqlServer*/
DECLARE @i INT
SET @i = 0
 
WHILE (@i < 1000)
BEGIN
	-- Replace with your query
	SELECT 
		[City Key],
		[Salesperson Key],
		SUM(Quantity),
		SUM([Total Including Tax])
	FROM WideWorldImportersDW.Fact.OrderHistory
	GROUP BY 
	City Key,
	[Salesperson Key]
	--
 
	SET @i = @i + 1
END


/*bat RunQuery.bat*/
sqlcmd -S.\SQL19 -iQuery.sql -dWideWorldImportersDW
/*FIN*/



/*bat RunStress.bat*/
START RunQuery.bat
START RunQuery.bat
START RunQuery.bat
START RunQuery.bat
START RunQuery.bat
START RunQuery.bat
/*FIN*/

/*Fin pruebas estress*/

/*SP Ver relaciones de tablas*/
CREATE OR ALTER PROC sp_ReportForeignKeys
AS
BEGIN
 
	SELECT
		'FOREIGNKEYS' AS [REPORT],
		@@SERVERNAME AS [ServerName],
		DB_NAME() AS [DatabaseName],
		[fk].[name] AS [ForeignKeyName],
		SCHEMA_NAME([fk].schema_id) AS [TableSchema],
		OBJECT_NAME([fk].[parent_object_id]) AS [Table],
		COL_NAME([fkc].[parent_object_id], [fkc].[parent_column_id]) AS [ConstraintColumn],
		[fk].[is_disabled] AS [IsDisabled],
		OBJECT_SCHEMA_NAME ([fk].[referenced_object_id]) AS [ReferencedTableSchema],
		OBJECT_NAME ([fk].[referenced_object_id]) AS [ReferencedTable],
		COL_NAME([fkc].[referenced_object_id], [fkc].[referenced_column_id]) AS [ReferencedColumn],
		[fk].[delete_referential_action_desc] AS [DeleteAction],
		[fk].[update_referential_action_desc] AS [UpdateAction],
		[fk].[create_date] AS [CreateDate],
		[fk].[modify_date] AS [ModifyDate],
		CASE [fk].[is_system_named]
			WHEN 1 THEN 'System' 
			WHEN 0 THEN 'User'
		END AS [Named]
	FROM [sys].[foreign_keys] AS [fk]
	INNER JOIN [sys].[foreign_key_columns] AS [fkc]
	   ON [fk].[object_id] = [fkc].[constraint_object_id]
	ORDER BY 
		SCHEMA_NAME([fk].[schema_id]),
		OBJECT_NAME([fk].[parent_object_id]) 
 
END
/*Fin Ver relaciones de tablas*/


/*SP reporte de peso tablas*/
CREATE PROCEDURE dbo.sp_ReportUserDbTables
AS
BEGIN 

	WITH rep AS(
	SELECT
		SchemaName = s.Name, 
		ObjectName = t.NAME,
		t.create_date AS CreateDate, 
		t.modify_date AS ModifyDate,
		p.rows AS RowCounts,
		SUM(a.total_pages) * 8 AS TotalSpaceKB, 
		SUM(a.used_pages) * 8 AS UsedSpaceKB, 
		(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
	FROM 
		sys.tables t
	INNER JOIN      
		sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN 
		sys.schemas s ON t.schema_id = s.schema_id
	WHERE 
		t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255 
	GROUP BY 
		s.Name, t.NAME, t.create_date, t.modify_date, p.Rows
	)

	SELECT 	REPORT = 'DATABASE TABLES',
		ServerName = @@SERVERNAME,
		DatabaseName = DB_NAME(),
		*
	FROM rep
	ORDER BY 4, 5
END

/*Fin SP reporte de peso tablas*/
