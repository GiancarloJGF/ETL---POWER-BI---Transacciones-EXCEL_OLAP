# ETL---POWER-BI---Transacciones-EXCEL_OLAP
ETL - POWER BI - Transacciones EXCEL_OLAP

##Nota en el proyecto se deja toda la documentacion necesaria para revisar el proyecto archivos .sql , querys usados , .pbix (power bi).

##HERRAMIENTAS USADAS: 
1. Microsoft SQL Server Management Studio 22 https://learn.microsoft.com/es-es/ssms/install/install
2. integration services visual studio 2022 https://marketplace.visualstudio.com/items?itemName=SSIS.MicrosoftDataToolsIntegrationServices
3. analysis services visual studio 2022 https://marketplace.visualstudio.com/items?itemName=ProBITools.MicrosoftAnalysisServicesModelingProjects2022
4. Power BI Desktop  https://apps.microsoft.com/detail/9ntxr16hnw1t?hl=es-MX&gl=NG

#PASOS PARA LA CREACION DEL PROYECTO PASANDO DATOS DE SQL A SQL con integration services visual studio 2022.

https://github.com/GiancarloJGF/ETL---POWER-BI---Transacciones-EXCEL_OLAP/blob/main/NOTAS%20PARA%20INTEGRATION%20SERVICES%20de%20SQL%20a%20SQL.docx

A. Flujo de control. 
<img width="1565" height="655" alt="image" src="https://github.com/user-attachments/assets/1f97c8ae-b064-44b9-8d97-182663fcc59c" />

B. Flujo de datos.
<img width="1539" height="510" alt="image" src="https://github.com/user-attachments/assets/e3f95c83-374a-4070-bf2d-d8eb808fe501" />

C. Origen de datos.
<img width="1104" height="737" alt="image" src="https://github.com/user-attachments/assets/d17cd5db-497c-4a4c-b182-396e8fd4a8ec" />

D. Destino de datos. 
<img width="1171" height="772" alt="image" src="https://github.com/user-attachments/assets/ac3f96b0-3451-473a-a1e1-9d4fe0fd9592" />


##Creacion Cubo-OLAP
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

<img width="669" height="390" alt="image" src="https://github.com/user-attachments/assets/ea57ad55-1314-4dea-a39a-7bde6b9a5a8a" />


Agrupa las 700 transacciones por los 6 productos (Amarilla, Carretera, Montana, Paseo, Velo, VTT), mostrando unidades vendidas, ventas brutas, descuentos, ventas netas, COGS y ganancia — más un gráfico de barras comparativo.


🗺️ Hoja 2 – Movimiento por País

<img width="732" height="497" alt="image" src="https://github.com/user-attachments/assets/97964634-4bdc-469e-8b1e-91a9cf436985" />



Detalla el comportamiento de cada producto por país (Canadá, Francia, Alemania, México, EE.UU.) desglosado además por segmento, con margen porcentual por fila.


💰 Hoja 3 – Ganancias Concebidas

<img width="711" height="431" alt="image" src="https://github.com/user-attachments/assets/d9a17c6a-f9d8-44d1-81a6-2a1f07f3a9ff" />

<img width="712" height="303" alt="image" src="https://github.com/user-attachments/assets/3f3d8cf2-b3b2-47b9-8593-6504eb7e7be5" />




Tres secciones de rentabilidad:

Por Segmento (Government, Midmarket, Small Business, etc.)
Por Año (2013 vs 2014)
Por País con participación % del total global — más gráfico de barras horizontal.

Todas las hojas usan formato profesional con colores corporativos azul marino, filas alternadas, totales destacados y anchos de columna optimizados.



