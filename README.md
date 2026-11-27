# PY3 - Bases de Datos II
Solución de Inteligencia de Negocios sobre la base **BikeStores** (SQL Server):
Data Warehouse, ETL en SSIS, orquestador con SQL Agent, cubo SSAS y dashboards en Power BI.

## Requisitos
- SQL Server con la base **BikeStores** restaurada
  (https://www.sqlservertutorial.net/getting-started/sql-server-sample-database/)
- Visual Studio con la extensión SQL Server Integration Services Projects
- SQL Server Management Studio (SSMS)

## Cómo ejecutar
1. En SSMS, crear la base vacía del Data Warehouse:
   ```sql
   CREATE DATABASE BikeStoresDW;
   ```
2. Abrir `ssis/BikeStoresETL/BikeStoresETL.slnx` en Visual Studio.
3. Verificar que las conexiones `localhost.BikeStores` y `localhost.BikeStoresDW`
   apunten a su servidor.
4. Ejecutar `Maestro.dtsx`. El paquete crea las tablas del DW (si no existen),
   llena DimFecha y carga dimensiones y hechos.

## Estructura
| Carpeta    | Contenido                          |
|------------|------------------------------------|
| `ssis/`    | Proyecto ETL (Integration Services)|
| `ssas/`    | Proyecto del cubo (Analysis Services) |
| `powerbi/` | Dashboards de Ventas e Inventario  |
| `sql/`     | Scripts auxiliares                 |