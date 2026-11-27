/*
    Verificación del orquestador y del ETL
    --------------------------------------
    Consultas de solo lectura para comprobar que el job corrió y que el DW quedó bien.
*/

SELECT j.name AS job, j.enabled, s.step_name, s.subsystem,
       sc.name AS horario, sc.active_start_time
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps s      ON s.job_id = j.job_id
LEFT JOIN msdb.dbo.sysjobschedules js ON js.job_id = j.job_id
LEFT JOIN msdb.dbo.sysschedules sc    ON sc.schedule_id = js.schedule_id
WHERE j.name = N'ETL BikeStoresDW';

SELECT TOP (10)
       CASE h.run_status WHEN 0 THEN 'Falló' WHEN 1 THEN 'Éxito' WHEN 3 THEN 'Cancelado' ELSE 'Otro' END AS resultado,
       msdb.dbo.agent_datetime(h.run_date, h.run_time) AS inicio,
       h.run_duration AS duracion_hhmmss
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
WHERE j.name = N'ETL BikeStoresDW' AND h.step_id = 0
ORDER BY h.instance_id DESC;

SELECT TOP (10) execution_id, package_name,
       CASE status WHEN 2 THEN 'En ejecución' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Falló'
                   WHEN 7 THEN 'Éxito' ELSE CAST(status AS varchar(10)) END AS estado,
       start_time, end_time
FROM SSISDB.catalog.executions
WHERE folder_name = N'BikeStores' AND project_name = N'BikeStoresETL'
ORDER BY execution_id DESC;

SELECT em.message_time, em.message
FROM SSISDB.catalog.event_messages em
WHERE em.event_name = 'OnError'
  AND em.operation_id = (SELECT MAX(execution_id) FROM SSISDB.catalog.executions
                         WHERE project_name = N'BikeStoresETL' AND status = 4)
ORDER BY em.event_message_id;

SELECT t.name AS tabla, SUM(p.rows) AS filas
FROM BikeStoresDW.sys.tables t
JOIN BikeStoresDW.sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;

SELECT 'Líneas de orden' AS medida,
       (SELECT COUNT(*) FROM BikeStores.sales.order_items) AS origen,
       (SELECT COUNT(*) FROM BikeStoresDW.dbo.FactVentas)  AS dw
UNION ALL
SELECT 'Registros de stock',
       (SELECT COUNT(*) FROM BikeStores.production.stocks),
       (SELECT COUNT(*) FROM BikeStoresDW.dbo.FactInventario);
