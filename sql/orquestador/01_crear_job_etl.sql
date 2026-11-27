/*
    Orquestador del ETL - Job de SQL Server Agent
    ------------------------------------------------
    Crea el job "ETL BikeStoresDW", que ejecuta el paquete Maestro.dtsx
    desplegado en el catálogo SSISDB (\SSISDB\BikeStores\BikeStoresETL).

    Requisitos previos:
      1. Catálogo SSISDB creado (SSMS > Integration Services Catalogs > Create Catalog).
      2. Proyecto BikeStoresETL desplegado en la carpeta "BikeStores" de SSISDB.
      3. Base BikeStoresDW creada (el paquete crea las tablas, no la base).
      4. Servicio SQL Server Agent en ejecución.

    Si el job ya existe, el script no hace nada (así no se pierde su historial).
    Para recrearlo desde cero, borrarlo primero:
        EXEC msdb.dbo.sp_delete_job @job_name = N'ETL BikeStoresDW';
*/
USE msdb;
GO

DECLARE @job_name  sysname       = N'ETL BikeStoresDW';
DECLARE @paquete   nvarchar(400) = N'\SSISDB\BikeStores\BikeStoresETL\Maestro.dtsx';
DECLARE @servidor  sysname       = @@SERVERNAME;
DECLARE @job_id    uniqueidentifier;

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @job_name)
BEGIN
    PRINT N'El job "' + @job_name + N'" ya existe. No se hicieron cambios.';
    RETURN;
END;

-- validacion 
IF NOT EXISTS (
    SELECT 1
    FROM SSISDB.catalog.packages  pk
    JOIN SSISDB.catalog.projects  pr ON pr.project_id = pk.project_id
    JOIN SSISDB.catalog.folders   f  ON f.folder_id   = pr.folder_id
    WHERE f.name = N'BikeStores' AND pr.name = N'BikeStoresETL' AND pk.name = N'Maestro.dtsx')
BEGIN
    RAISERROR(N'Maestro.dtsx no está desplegado en \SSISDB\BikeStores\BikeStoresETL. Despliegue el proyecto primero.', 16, 1);
    RETURN;
END;

BEGIN TRANSACTION;

    -- job
    EXEC msdb.dbo.sp_add_job
        @job_name        = @job_name,
        @enabled         = 1,
        @description     = N'Ejecuta el ETL Maestro.dtsx (BikeStores -> BikeStoresDW) desde el catálogo SSISDB.',
        @owner_login_name = N'sa',
        @job_id          = @job_id OUTPUT;

    DECLARE @comando nvarchar(max) =
          N'/ISSERVER "\"' + @paquete + N'\"" /SERVER "\"' + @servidor + N'\"" '
        + N'/Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 '
        + N'/Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True '
        + N'/CALLERINFO SQLAGENT /REPORTING E';

    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @job_id,
        @step_name = N'Ejecutar Maestro.dtsx',
        @subsystem = N'SSIS',
        @command = @comando,
        @on_success_action = 1,
        @on_fail_action = 2,
        @retry_attempts = 0;

    -- todos los días a las 2:00 a.m.
    EXEC msdb.dbo.sp_add_jobschedule
        @job_id  = @job_id,
        @name = N'Diario 2:00 a. m.',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @active_start_time = 020000;

    EXEC msdb.dbo.sp_add_jobserver
        @job_id      = @job_id,
        @server_name = N'(local)';

COMMIT TRANSACTION;

PRINT N'Job "' + @job_name + N'" creado. Para ejecutarlo ahora:';
PRINT N'    EXEC msdb.dbo.sp_start_job @job_name = N''' + @job_name + N''';';
GO
