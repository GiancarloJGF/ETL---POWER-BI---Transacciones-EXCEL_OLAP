-- Base de datos principal [dbo].[staging_raw]
-- creando tablas para la dimensiones para la creacion de cubo OLAP


select * from [dbo].[staging_raw]
select * from [dbo].[financialSample]

-- prueba 
CREATE VIEW v_staging_financial_bulk AS
SELECT 
    segment, country, product, discount_band, units_sold, 
    manufacturing_price, sale_price, gross_sales, discounts, 
    sales, cogs, profit, transaction_date, month_number, 
    month_name, transaction_year
FROM staging_financial;

BULK INSERT v_staging_financial_bulk
FROM 'C:\Users\DELL\Downloads\proyecto 2 power bi\Financial Sample.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', -- Asegúrate de si tu CSV usa coma (,) o punto y coma (;)
    ROWTERMINATOR = '\n',
    TABLOCK
);

--- Funciono

CREATE TABLE staging_raw (
    segment             VARCHAR(100),
    country             VARCHAR(100),
    product             VARCHAR(100),
    discount_band       VARCHAR(100),
    units_sold          VARCHAR(100),
    manufacturing_price VARCHAR(100),
    sale_price          VARCHAR(100),
    gross_sales         VARCHAR(100),
    discounts           VARCHAR(100),
    sales               VARCHAR(100),
    cogs                VARCHAR(100),
    profit              VARCHAR(100),
    date                VARCHAR(100),
    month_number        VARCHAR(100),
    month_name          VARCHAR(100),
    year                VARCHAR(100)
);

BULK INSERT staging_raw
FROM 'C:\Users\DELL\Downloads\proyecto 2 power bi\Financial Sample.csv'
WITH (
    FIRSTROW    = 2,
    FIELDTERMINATOR = ';',   -- si falla, cambiá a ';'
    ROWTERMINATOR   = '0x0a',  -- más robusto que '\n'
    TABLOCK
);

SELECT TOP 5 * FROM staging_raw;
select * from [dbo].[staging_raw]


INSERT INTO staging_financial (
    segment, country, product, discount_band,
    units_sold, manufacturing_price, sale_price,
    gross_sales, discounts, sales, cogs, profit,
    date, month_number, month_name, year
)
SELECT
    segment,
    country,
    product,
    discount_band,
    TRY_CAST(REPLACE(units_sold,          ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(manufacturing_price, ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(sale_price,          ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(gross_sales,         ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(discounts,           ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(sales,               ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(cogs,                ',', '.') AS DECIMAL(15,2)),
    TRY_CAST(REPLACE(profit,              ',', '.') AS DECIMAL(15,2)),
    TRY_CONVERT(DATE, date, 103),   -- formato DD/MM/YYYY
    TRY_CAST(month_number AS INT),
    month_name,
    TRY_CAST(year AS INT)
FROM staging_raw
WHERE TRY_CAST(year AS INT) IS NOT NULL; 

///////dimensiones tabla
IF OBJECT_ID('dim_segment', 'U') IS NOT NULL DROP TABLE dim_segment;
CREATE TABLE dim_segment (
    segment_id   INT IDENTITY(1,1) PRIMARY KEY,
    segment_name VARCHAR(50) NOT NULL UNIQUE
);

IF OBJECT_ID('dim_country', 'U') IS NOT NULL DROP TABLE dim_country;
CREATE TABLE dim_country (
    country_id   INT IDENTITY(1,1) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

IF OBJECT_ID('dim_product', 'U') IS NOT NULL DROP TABLE dim_product;
CREATE TABLE dim_product (
    product_id          INT IDENTITY(1,1) PRIMARY KEY,
    product_name        VARCHAR(50)    NOT NULL UNIQUE,
    manufacturing_price DECIMAL(15,2),
    sale_price          DECIMAL(15,2)
);

IF OBJECT_ID('dim_discount_band', 'U') IS NOT NULL DROP TABLE dim_discount_band;
CREATE TABLE dim_discount_band (
    discount_band_id   INT IDENTITY(1,1) PRIMARY KEY,
    discount_band_name VARCHAR(20) NOT NULL UNIQUE
);

IF OBJECT_ID('dim_date', 'U') IS NOT NULL DROP TABLE dim_date;
CREATE TABLE dim_date (
    date_id      INT IDENTITY(1,1) PRIMARY KEY,
    full_date    DATE         NOT NULL UNIQUE,
    month_number INT,
    month_name   VARCHAR(20),
    year         INT,
    quarter      AS (CEILING(MONTH(full_date) / 3.0)) PERSISTED
);
-- ---------- TABLA DE HECHOS ----------
 
IF OBJECT_ID('fact_sales', 'U') IS NOT NULL DROP TABLE fact_sales;

CREATE TABLE fact_sales (
    fact_id          INT IDENTITY(1,1) PRIMARY KEY,
    date_id          INT REFERENCES dim_date(date_id),
    segment_id       INT REFERENCES dim_segment(segment_id),
    country_id       INT REFERENCES dim_country(country_id),
    product_id       INT REFERENCES dim_product(product_id),
    discount_band_id INT REFERENCES dim_discount_band(discount_band_id),
    units_sold       DECIMAL(18,2),   -- más espacio
    gross_sales      DECIMAL(18,2),
    discounts        DECIMAL(18,2),
    sales            DECIMAL(18,2),
    cogs             DECIMAL(18,2),
    profit           DECIMAL(18,2)
);
 

--sql insert

INSERT INTO dim_segment (segment_name)
SELECT DISTINCT segment
FROM   [dbo].[staging_raw]
WHERE  segment IS NOT NULL
  AND  NOT EXISTS (
    SELECT 1 FROM dim_segment WHERE segment_name = staging_raw.segment
  );

  select * from [dbo].[dim_segment]

  -- dim_country
INSERT INTO dim_country (country_name)
SELECT DISTINCT country
FROM   [dbo].[staging_raw]
WHERE  country IS NOT NULL
  AND  NOT EXISTS (
    SELECT 1 FROM dim_country WHERE country_name = staging_raw.country
      );

-- dim_product
INSERT INTO dim_product (product_name, manufacturing_price, sale_price)
SELECT DISTINCT
    product,
    AVG(TRY_CAST(
        REPLACE(REPLACE(REPLACE(manufacturing_price, '$', ''), ',', ''), ' ', '')
    AS DECIMAL(15,2))) OVER (PARTITION BY product),
    AVG(TRY_CAST(
        REPLACE(REPLACE(REPLACE(sale_price, '$', ''), ',', ''), ' ', '')
    AS DECIMAL(15,2))) OVER (PARTITION BY product)
FROM [dbo].[staging_raw]
WHERE product IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM dim_product WHERE product_name = staging_raw.product
  );

  -- dim_discount_band
INSERT INTO dim_discount_band (discount_band_name)
SELECT DISTINCT ISNULL(discount_band, 'None')
FROM   [dbo].[staging_raw]
WHERE  NOT EXISTS (
    SELECT 1 FROM dim_discount_band
    WHERE discount_band_name = ISNULL(staging_raw.discount_band, 'None')
  );

  Select * from [dbo].[dim_discount_band]

  -- dim_date
INSERT INTO dim_date (full_date, month_number, month_name, year)
SELECT DISTINCT
    date, month_number, month_name, year
FROM   [dbo].[staging_raw]
WHERE  date IS NOT NULL
  AND  NOT EXISTS (
    SELECT 1 FROM dim_date WHERE full_date = staging_raw.date
  );

  select * from [dbo].[dim_date]

  ---Solucion error year
  UPDATE staging_raw
SET year = REPLACE(REPLACE(REPLACE(year, CHAR(13), ''), CHAR(10), ''), ' ', '');

UPDATE staging_raw
SET 
    month_number = REPLACE(REPLACE(REPLACE(month_number, CHAR(13), ''), CHAR(10), ''), ' ', ''),
    month_name   = REPLACE(REPLACE(REPLACE(month_name,   CHAR(13), ''), CHAR(10), ''), ' ', ''),
    year         = REPLACE(REPLACE(REPLACE(year,         CHAR(13), ''), CHAR(10), ''), ' ', '');

-- Cambiar simbolo de dolar 
UPDATE [dbo].[staging_raw]
SET
    units_sold          = REPLACE(REPLACE(REPLACE(units_sold,          '$', ''), ',', ''), ' ', ''),
    manufacturing_price = REPLACE(REPLACE(REPLACE(manufacturing_price, '$', ''), ',', ''), ' ', ''),
    sale_price          = REPLACE(REPLACE(REPLACE(sale_price,          '$', ''), ',', ''), ' ', ''),
    gross_sales         = REPLACE(REPLACE(REPLACE(gross_sales,         '$', ''), ',', ''), ' ', ''),
    discounts           = REPLACE(REPLACE(REPLACE(discounts,           '$', ''), ',', ''), ' ', ''),
    sales               = REPLACE(REPLACE(REPLACE(sales,               '$', ''), ',', ''), ' ', ''),
    cogs                = REPLACE(REPLACE(REPLACE(cogs,                '$', ''), ',', ''), ' ', ''),
    profit              = REPLACE(REPLACE(REPLACE(profit,              '$', ''), ',', ''), ' ', '')

    -- confirmando que funciono 

    SELECT TOP 5
    units_sold, manufacturing_price, sale_price,
    gross_sales, discounts, sales, cogs, profit
FROM [dbo].[staging_raw]l;

------------------------
-- crear tabla para los IDS

-- 3.6  fact_sales  (join de vuelta a dimensiones para obtener IDs)
INSERT INTO fact_sales (
    date_id, segment_id, country_id, product_id, discount_band_id,
    units_sold, gross_sales, discounts, sales, cogs, profit
)
SELECT
    d.date_id,
    seg.segment_id,
    c.country_id,
    p.product_id,
    db.discount_band_id,
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.units_sold,  '$',''),',',''),' ','') AS DECIMAL(18,2)),
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.gross_sales, '$',''),',',''),' ','') AS DECIMAL(18,2)),
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.discounts,   '$',''),',',''),' ','') AS DECIMAL(18,2)),
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.sales,       '$',''),',',''),' ','') AS DECIMAL(18,2)),
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.cogs,        '$',''),',',''),' ','') AS DECIMAL(18,2)),
    TRY_CAST(REPLACE(REPLACE(REPLACE(s.profit,      '$',''),',',''),' ','') AS DECIMAL(18,2))
FROM staging_raw s
JOIN dim_date          d   ON d.full_date          = TRY_CAST(s.date AS DATE)
JOIN dim_segment       seg ON seg.segment_name      = s.segment
JOIN dim_country       c   ON c.country_name        = s.country
JOIN dim_product       p   ON p.product_name        = s.product
JOIN dim_discount_band db  ON db.discount_band_name = ISNULL(s.discount_band, 'None');

 select * from [dbo].[fact_sales]




-- VERIFICACIÓN RÁPIDA
-- ============================================================
 
SELECT 'dim_segment'     AS tabla, COUNT(*) AS filas FROM dim_segment
UNION ALL
SELECT 'dim_country',              COUNT(*)           FROM dim_country
UNION ALL
SELECT 'dim_product',              COUNT(*)           FROM dim_product
UNION ALL
SELECT 'dim_discount_band',        COUNT(*)           FROM dim_discount_band
UNION ALL
SELECT 'dim_date',                 COUNT(*)           FROM dim_date
UNION ALL
SELECT 'fact_sales',               COUNT(*)           FROM fact_sales;