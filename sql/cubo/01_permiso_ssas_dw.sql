/*
    Permiso de lectura para Analysis Services sobre el Data Warehouse
    -----------------------------------------------------------------
    Al procesar el cubo, SSAS se conecta a SQL Server para leer BikeStoresDW.
    El Data Source del proyecto usa "Usar la cuenta de servicio", así que esa
    conexión llega con la cuenta del servicio de SSAS:
        NT Service\MSSQLServerOLAPService
    Esa cuenta necesita un login en SQL Server y permiso de solo lectura en el DW.
    Se puede ejecutar varias veces.
*/
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'NT Service\MSSQLServerOLAPService')
    CREATE LOGIN [NT Service\MSSQLServerOLAPService] FROM WINDOWS;
GO

USE BikeStoresDW;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'NT Service\MSSQLServerOLAPService')
    CREATE USER [NT Service\MSSQLServerOLAPService] FOR LOGIN [NT Service\MSSQLServerOLAPService];
GO
-- db_datareader = SELECT sobre todas las tablas, sin poder modificar nada
ALTER ROLE db_datareader ADD MEMBER [NT Service\MSSQLServerOLAPService];
GO
