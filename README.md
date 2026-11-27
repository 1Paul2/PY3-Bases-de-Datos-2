# PY3 - Bases de Datos II
Solución de Inteligencia de Negocios sobre la base **BikeStores** (SQL Server):
Data Warehouse, ETL en SSIS, orquestador con SQL Agent, cubo SSAS y dashboards en Power BI.

## Estado del proyecto
| Pieza | Estado |
|---|---|
| Modelado del Data Warehouse | ✅ Terminado |
| ETL (SSIS) | ✅ Terminado |
| Orquestador (SQL Agent) | ⬜ Pendiente |
| Cubo (SSAS) | ⬜ Pendiente |
| Dashboards (Power BI) | ⬜ Pendiente |

## Modelo del Data Warehouse (BikeStoresDW)
Modelo estrella con 2 tablas de hechos y 6 dimensiones.

| Tabla | Tipo | Descripción |
|---|---|---|
| FactVentas | Hechos | Una fila por línea de orden: cantidad, monto bruto, descuento y neto |
| FactInventario | Hechos | Stock por producto y tienda, foto diaria |
| DimFecha | Dimensión | Un registro por día (2016–2026). Fila -1 = "Sin fecha" |
| DimCliente | SCD Tipo 2 | Historial de cambios de dirección. Nombre completo |
| DimProducto | SCD Tipo 2 | Historial de cambios de precio. Marca y categoría desnormalizadas |
| DimTienda | SCD Tipo 1 | Sucursales |
| DimEmpleado | SCD Tipo 1 | Nombre completo, tienda y jefe |
| DimOrden | SCD Tipo 1 | Estado de la orden en texto |

## ETL (ssis/BikeStoresETL/Maestro.dtsx)
El paquete se ejecuta en este orden:
1. **Crear tablas DW**: crea las tablas solo si no existen (no borra historial).
2. **Poblar DimFecha**: inserta los días que falten.
3. **Dimensiones SCD1**: Tienda, Empleado, Orden.
4. **Dimensiones SCD2**: Cliente, Producto.
5. **FactVentas**: calcula montos, busca las llaves de cada dimensión y carga solo líneas nuevas.
6. **FactInventario**: reemplaza la foto del día y carga el stock actual.

Se puede ejecutar varias veces sin duplicar datos.

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
4. Ejecutar `Maestro.dtsx`.

## Estructura
| Carpeta    | Contenido                             |
|------------|---------------------------------------|
| `ssis/`    | Proyecto ETL (Integration Services)   |
| `ssas/`    | Proyecto del cubo (Analysis Services) |
| `powerbi/` | Dashboards de Ventas e Inventario     |
| `sql/`     | Scripts auxiliares                    |