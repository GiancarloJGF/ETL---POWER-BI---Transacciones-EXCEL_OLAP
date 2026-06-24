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
