# ETL---POWER-BI---Transacciones-EXCEL_OLAP
ETL - POWER BI - Transacciones EXCEL_OLAP

#PASOS PARA LA CREACION DEL PROYECTO PASANDO DATOS DE EXCEL A SQL 

#Paso 1 – staging_raw

enlace con los pasos a seguir creando tablas para la dimensiones para la creacion de cubo OLAP: 
https://github.com/GiancarloJGF/ETL---POWER-BI---Transacciones-EXCEL_OLAP/blob/main/excel_%20llenar%20tablas.sql

Una tabla plana con todas las columnas del Excel tal cual. Acá es donde cargas el archivo (via COPY, un importador, o tu ETL).

#Paso 2 – Tablas OLAP
El modelo estrella queda así:

<img width="602" height="369" alt="image" src="https://github.com/user-attachments/assets/8f30744d-5152-4b65-b3fb-37af13a4aaf2" />


#Paso 3 – INSERT ... SELECT
Exactamente como pediste. Primero se llenan las dimensiones con SELECT DISTINCT:

sql

INSERT INTO dim_country (country_name)
SELECT DISTINCT country FROM staging_financial
WHERE country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

Luego fact_sales se carga haciendo JOIN a todas las dimensiones para traer los IDs foráneos. El ON CONFLICT DO NOTHING hace el proceso idempotente (puedes correrlo varias veces sin duplicar).

Al final hay una query de verificación que muestra cuántas filas quedaron en cada tabla. Con 700 filas en el Excel deberías ver: 5 segmentos, 5 países, 6 productos, 4 discount bands, y 700 hechos.
#


##DIAGRAMA DE BASE DE DATOS 

<img width="651" height="659" alt="image" src="https://github.com/user-attachments/assets/68bba04e-e387-48f8-96cf-d61637802422" />


## REPORTES 

#Concepto
Se espera que, se consuma un documento de excel específico utilizado en el ejercicio anterior, se espera practicar un proceso de ETL en el cual el Técnico extraiga la información de un EXCEL a una base de datos SQL Server, en la cual deposita todos los datos obtenidos, el técnico deberá:
Normalizar los datos presentes en el excel, crear el diseño de una base de datos, relacional con modelo de CUBO OLAP.
Crear un proceso de ETL el cual extraiga la información del EXCEL y lo traslada al motor de base de datos SQL Server. Pueden ser uno o más procesos en un proyecto de ETL, se espera que se use la herramienta de visual studio: SSIS.
Presentación de un DASHBOARD con los reportes solicitados.


#Descripción del Ejercicio
La empresa de venta de mercancía diversa ha extraído un reporte con todas las ventas realizada en los últimos años, se espera que el técnico consuma ese mismo reporte generado en ese EXCEL provisto y presente los siguientes reportes:
1. Report total de ventas por producto
2. Reporte de Movimiento de los productos a lo largo y ancho de los estados unidos
3. Reporte de Ganancias concebidas
Se espera que el técnico limpie la información al momento de presentar los DASHBOARD y esta esté organizada



📊 Hoja 1 – Ventas por Producto

Agrupa las 700 transacciones por los 6 productos (Amarilla, Carretera, Montana, Paseo, Velo, VTT), mostrando unidades vendidas, ventas brutas, descuentos, ventas netas, COGS y ganancia — más un gráfico de barras comparativo.


🗺️ Hoja 2 – Movimiento por País

Detalla el comportamiento de cada producto por país (Canadá, Francia, Alemania, México, EE.UU.) desglosado además por segmento, con margen porcentual por fila.
💰 Hoja 3 – Ganancias Concebidas

Tres secciones de rentabilidad:

Por Segmento (Government, Midmarket, Small Business, etc.)
Por Año (2013 vs 2014)
Por País con participación % del total global — más gráfico de barras horizontal.

Todas las hojas usan formato profesional con colores corporativos azul marino, filas alternadas, totales destacados y anchos de columna optimizados.



