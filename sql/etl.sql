-- ============================================================
-- # SEOUL BIKE SHARING DEMAND ANALYTICS
-- # ETL (Extract, Transform, Load)
-- # Jalankan file ini SETELAH schema.sql
-- ============================================================
-- Urutan eksekusi:
--   1. schema.sql
--   2. etl.sql      (file ini)
--   3. views.sql
--   4. analysis.sql
-- ============================================================

USE SeoulBikeAnalytics;
GO


-- ============================================================
-- # 1. BULK INSERT CSV → STAGING
-- ============================================================
-- Load data mentah dari SeoulBikeData.csv ke staging.bike_raw.
--
-- ⚠️  PENTING: Sesuaikan path file CSV di bawah ini dengan
--     lokasi file Anda. Contoh:
--     'C:\Users\samue\Documents\antigravity\calm-carson\data\SeoulBikeData.csv'
-- ============================================================

-- Bersihkan staging table jika ada data sebelumnya
TRUNCATE TABLE staging.bike_raw;
GO

BULK INSERT staging.bike_raw
FROM 'C:\Users\samue\Documents\antigravity\calm-carson\data\SeoulBikeData.csv'
WITH (
    FORMAT         = 'CSV',
    FIRSTROW       = 2,              -- Skip header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR  = '\n',
    CODEPAGE       = '65001',        -- UTF-8 encoding
    TABLOCK
);
GO

-- Verifikasi hasil load
SELECT 
    COUNT(*) AS total_rows,
    MIN([Date]) AS first_date,
    MAX([Date]) AS last_date,
    MIN([Rented Bike Count]) AS min_rentals,
    MAX([Rented Bike Count]) AS max_rentals
FROM staging.bike_raw;
GO

PRINT '✅ CSV data loaded into [staging.bike_raw].';
GO


-- ============================================================
-- # 2. POPULATE DIMENSION TABLES
-- ============================================================

-- Cleanup: Hapus fact_rental terlebih dahulu agar TRUNCATE
-- pada tabel dimensi tidak di-block oleh FK constraint.
-- Ini memungkinkan script di-run ulang tanpa error.
TRUNCATE TABLE dbo.fact_rental;
GO
DBCC CHECKIDENT ('dbo.fact_rental', RESEED, 0);
GO

-- ------------------------------------------------------------
-- # 2.1 Populate dim_season — Dimensi Musim
-- ------------------------------------------------------------
-- Data statis: 4 musim Korea Selatan.

TRUNCATE TABLE dbo.dim_season;
GO

INSERT INTO dbo.dim_season (season_id, season_name, season_order)
VALUES
    (1, 'Spring', 1),
    (2, 'Summer', 2),
    (3, 'Autumn', 3),
    (4, 'Winter', 4);
GO

PRINT '✅ dim_season populated (4 rows).';
GO


-- ------------------------------------------------------------
-- # 2.2 Populate dim_time_slot — Dimensi Waktu (Jam)
-- ------------------------------------------------------------
-- Klasifikasi 24 jam:
--   Time Period  : Dawn (4-6), Morning (7-11), Afternoon (12-16),
--                  Evening (17-20), Night (21-3)
--   Rush Hour    : 07-09 (pagi), 17-19 (sore)
--   Shift        : Night Shift (0-7), Day Shift (8-15), Evening Shift (16-23)

TRUNCATE TABLE dbo.dim_time_slot;
GO

INSERT INTO dbo.dim_time_slot (time_slot_id, [hour], time_period, rush_hour_flag, [shift])
VALUES
    (0,  0,  'Night',     0, 'Night Shift'),
    (1,  1,  'Night',     0, 'Night Shift'),
    (2,  2,  'Night',     0, 'Night Shift'),
    (3,  3,  'Night',     0, 'Night Shift'),
    (4,  4,  'Dawn',      0, 'Night Shift'),
    (5,  5,  'Dawn',      0, 'Night Shift'),
    (6,  6,  'Dawn',      0, 'Night Shift'),
    (7,  7,  'Morning',   1, 'Night Shift'),    -- Rush Hour
    (8,  8,  'Morning',   1, 'Day Shift'),      -- Rush Hour
    (9,  9,  'Morning',   1, 'Day Shift'),      -- Rush Hour
    (10, 10, 'Morning',   0, 'Day Shift'),
    (11, 11, 'Morning',   0, 'Day Shift'),
    (12, 12, 'Afternoon', 0, 'Day Shift'),
    (13, 13, 'Afternoon', 0, 'Day Shift'),
    (14, 14, 'Afternoon', 0, 'Day Shift'),
    (15, 15, 'Afternoon', 0, 'Day Shift'),
    (16, 16, 'Afternoon', 0, 'Evening Shift'),
    (17, 17, 'Evening',   1, 'Evening Shift'),  -- Rush Hour
    (18, 18, 'Evening',   1, 'Evening Shift'),  -- Rush Hour
    (19, 19, 'Evening',   1, 'Evening Shift'),  -- Rush Hour
    (20, 20, 'Evening',   0, 'Evening Shift'),
    (21, 21, 'Night',     0, 'Evening Shift'),
    (22, 22, 'Night',     0, 'Evening Shift'),
    (23, 23, 'Night',     0, 'Evening Shift');
GO

PRINT '✅ dim_time_slot populated (24 rows).';
GO


-- ------------------------------------------------------------
-- # 2.3 Populate dim_date — Dimensi Tanggal
-- ------------------------------------------------------------
-- Mengekstrak tanggal unik dari staging, lalu menghitung atribut
-- kalender (year, month, day_of_week, is_weekend, dll).

TRUNCATE TABLE dbo.dim_date;
GO

INSERT INTO dbo.dim_date (
    date_id, full_date, [year], [month], month_name, 
    [day], day_of_week, day_name, is_weekend, week_number, [quarter]
)
SELECT DISTINCT
    -- date_id: format YYYYMMDD
    CONVERT(INT, FORMAT(CONVERT(DATE, [Date], 103), 'yyyyMMdd'))    AS date_id,
    
    -- full_date
    CONVERT(DATE, [Date], 103)                                       AS full_date,
    
    -- year
    YEAR(CONVERT(DATE, [Date], 103))                                 AS [year],
    
    -- month (1-12)
    MONTH(CONVERT(DATE, [Date], 103))                                AS [month],
    
    -- month_name
    DATENAME(MONTH, CONVERT(DATE, [Date], 103))                      AS month_name,
    
    -- day (1-31)
    DAY(CONVERT(DATE, [Date], 103))                                  AS [day],
    
    -- day_of_week: 1=Monday ... 7=Sunday (ISO standard)
    (DATEPART(WEEKDAY, CONVERT(DATE, [Date], 103)) + 5) % 7 + 1     AS day_of_week,
    
    -- day_name
    DATENAME(WEEKDAY, CONVERT(DATE, [Date], 103))                    AS day_name,
    
    -- is_weekend: 1 jika Saturday (6) atau Sunday (7)
    CASE 
        WHEN (DATEPART(WEEKDAY, CONVERT(DATE, [Date], 103)) + 5) % 7 + 1 IN (6, 7) 
        THEN 1 ELSE 0 
    END                                                               AS is_weekend,
    
    -- week_number
    DATEPART(ISO_WEEK, CONVERT(DATE, [Date], 103))                   AS week_number,
    
    -- quarter (1-4)
    DATEPART(QUARTER, CONVERT(DATE, [Date], 103))                    AS [quarter]

FROM staging.bike_raw;
GO

-- Verifikasi dim_date
SELECT COUNT(*) AS total_dates FROM dbo.dim_date;
SELECT TOP 5 * FROM dbo.dim_date ORDER BY full_date;
GO

PRINT '✅ dim_date populated.';
GO


-- ------------------------------------------------------------
-- # 2.4 Populate dim_holiday — Dimensi Status Hari
-- ------------------------------------------------------------
-- Mengekstrak kombinasi unik Holiday × Functioning Day,
-- lalu menentukan day_type:
--   - 'Non-Functioning' jika Functioning Day = 'No'
--   - 'Holiday'         jika Holiday = 'Holiday'
--   - 'Working Day'     untuk sisanya

TRUNCATE TABLE dbo.dim_holiday;
GO

-- Reset identity
DBCC CHECKIDENT ('dbo.dim_holiday', RESEED, 0);
GO

INSERT INTO dbo.dim_holiday (is_holiday, is_functioning, day_type)
SELECT DISTINCT
    [Holiday]           AS is_holiday,
    [Functioning Day]   AS is_functioning,
    CASE
        WHEN [Functioning Day] = 'No'       THEN 'Non-Functioning'
        WHEN [Holiday] = 'Holiday'          THEN 'Holiday'
        ELSE 'Working Day'
    END                 AS day_type
FROM staging.bike_raw;
GO

SELECT * FROM dbo.dim_holiday;
GO

PRINT '✅ dim_holiday populated.';
GO


-- ------------------------------------------------------------
-- # 2.5 Populate dim_weather — Dimensi Kategori Cuaca
-- ------------------------------------------------------------
-- Mengkategorikan data cuaca mentah menjadi grup bisnis:
--
--   Temperature Category:
--     Freezing : < -5°C
--     Cold     : -5°C s/d 5°C
--     Cool     : 5°C s/d 15°C
--     Warm     : 15°C s/d 25°C
--     Hot      : > 25°C
--
--   Humidity Category:
--     Low       : < 40%
--     Moderate  : 40% s/d 60%
--     High      : 60% s/d 80%
--     Very High : > 80%
--
--   Weather Condition:
--     Clear         : Rainfall = 0 AND Snowfall = 0
--     Rainy         : Rainfall > 0 AND Snowfall = 0
--     Snowy         : Rainfall = 0 AND Snowfall > 0
--     Rainy & Snowy : Rainfall > 0 AND Snowfall > 0

TRUNCATE TABLE dbo.dim_weather;
GO

DBCC CHECKIDENT ('dbo.dim_weather', RESEED, 0);
GO

INSERT INTO dbo.dim_weather (temp_category, humidity_category, weather_condition)
SELECT DISTINCT
    -- Temperature Category
    CASE
        WHEN [Temperature] < -5    THEN 'Freezing'
        WHEN [Temperature] <= 5    THEN 'Cold'
        WHEN [Temperature] <= 15   THEN 'Cool'
        WHEN [Temperature] <= 25   THEN 'Warm'
        ELSE 'Hot'
    END AS temp_category,

    -- Humidity Category
    CASE
        WHEN [Humidity] < 40       THEN 'Low'
        WHEN [Humidity] <= 60      THEN 'Moderate'
        WHEN [Humidity] <= 80      THEN 'High'
        ELSE 'Very High'
    END AS humidity_category,

    -- Weather Condition (berdasarkan presipitasi)
    CASE
        WHEN [Rainfall] > 0 AND [Snowfall] > 0  THEN 'Rainy & Snowy'
        WHEN [Rainfall] > 0                      THEN 'Rainy'
        WHEN [Snowfall] > 0                      THEN 'Snowy'
        ELSE 'Clear'
    END AS weather_condition

FROM staging.bike_raw;
GO

SELECT * FROM dbo.dim_weather ORDER BY weather_id;
GO

PRINT '✅ dim_weather populated.';
GO


-- ============================================================
-- # 3. POPULATE FACT TABLE
-- ============================================================
-- Menggabungkan data staging dengan semua dimension keys.
-- Setiap baris staging di-lookup ke masing-masing dimensi
-- untuk mendapatkan foreign key yang sesuai.

TRUNCATE TABLE dbo.fact_rental;
GO

DBCC CHECKIDENT ('dbo.fact_rental', RESEED, 0);
GO

INSERT INTO dbo.fact_rental (
    date_id, time_slot_id, season_id, holiday_id, weather_id,
    rented_bike_count, temperature, humidity, wind_speed,
    visibility, dew_point_temp, solar_radiation, rainfall, snowfall
)
SELECT
    -- date_id: lookup dari dim_date
    dd.date_id,

    -- time_slot_id: langsung dari Hour (0-23)
    s.[Hour] AS time_slot_id,

    -- season_id: lookup dari dim_season
    ds.season_id,

    -- holiday_id: lookup dari dim_holiday
    dh.holiday_id,

    -- weather_id: lookup dari dim_weather (match kategori)
    dw.weather_id,

    -- Measures
    s.[Rented Bike Count],
    s.[Temperature],
    s.[Humidity],
    s.[Wind speed],
    s.[Visibility],
    s.[Dew point temperature],
    s.[Solar Radiation],
    s.[Rainfall],
    s.[Snowfall]

FROM staging.bike_raw s

-- Join dim_date
INNER JOIN dbo.dim_date dd
    ON dd.full_date = CONVERT(DATE, s.[Date], 103)

-- Join dim_season
INNER JOIN dbo.dim_season ds
    ON ds.season_name = s.[Seasons]

-- Join dim_holiday
INNER JOIN dbo.dim_holiday dh
    ON dh.is_holiday     = s.[Holiday]
    AND dh.is_functioning = s.[Functioning Day]

-- Join dim_weather (match berdasarkan kategori yang sama)
INNER JOIN dbo.dim_weather dw
    ON dw.temp_category = CASE
            WHEN s.[Temperature] < -5    THEN 'Freezing'
            WHEN s.[Temperature] <= 5    THEN 'Cold'
            WHEN s.[Temperature] <= 15   THEN 'Cool'
            WHEN s.[Temperature] <= 25   THEN 'Warm'
            ELSE 'Hot'
        END
    AND dw.humidity_category = CASE
            WHEN s.[Humidity] < 40       THEN 'Low'
            WHEN s.[Humidity] <= 60      THEN 'Moderate'
            WHEN s.[Humidity] <= 80      THEN 'High'
            ELSE 'Very High'
        END
    AND dw.weather_condition = CASE
            WHEN s.[Rainfall] > 0 AND s.[Snowfall] > 0  THEN 'Rainy & Snowy'
            WHEN s.[Rainfall] > 0                        THEN 'Rainy'
            WHEN s.[Snowfall] > 0                        THEN 'Snowy'
            ELSE 'Clear'
        END;
GO


-- ============================================================
-- # 4. VERIFIKASI ETL
-- ============================================================

-- Cek total baris (harus 8760)
SELECT 'fact_rental' AS [Table], COUNT(*) AS [Row Count] FROM dbo.fact_rental
UNION ALL
SELECT 'staging.bike_raw', COUNT(*) FROM staging.bike_raw
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dbo.dim_date
UNION ALL
SELECT 'dim_season', COUNT(*) FROM dbo.dim_season
UNION ALL
SELECT 'dim_time_slot', COUNT(*) FROM dbo.dim_time_slot
UNION ALL
SELECT 'dim_holiday', COUNT(*) FROM dbo.dim_holiday
UNION ALL
SELECT 'dim_weather', COUNT(*) FROM dbo.dim_weather;
GO

-- Cek apakah ada data yang hilang (orphaned rows)
SELECT 
    (SELECT COUNT(*) FROM staging.bike_raw) AS staging_rows,
    (SELECT COUNT(*) FROM dbo.fact_rental)  AS fact_rows,
    (SELECT COUNT(*) FROM staging.bike_raw) - (SELECT COUNT(*) FROM dbo.fact_rental) AS missing_rows;
GO

-- Sample data dari fact table
SELECT TOP 10 
    f.rental_id,
    dd.full_date,
    ts.[hour],
    ts.time_period,
    ds.season_name,
    dh.day_type,
    dw.temp_category,
    dw.weather_condition,
    f.rented_bike_count,
    f.temperature,
    f.humidity
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
JOIN dbo.dim_holiday dh    ON f.holiday_id = dh.holiday_id
JOIN dbo.dim_weather dw    ON f.weather_id = dw.weather_id
ORDER BY dd.full_date, ts.[hour];
GO

PRINT '';
PRINT '============================================================';
PRINT '  ✅ ETL COMPLETE';
PRINT '  Selanjutnya jalankan: views.sql';
PRINT '============================================================';
GO
