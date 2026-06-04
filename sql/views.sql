-- ============================================================
-- # SEOUL BIKE SHARING DEMAND ANALYTICS
-- # Views untuk Power BI
-- # Jalankan file ini SETELAH etl.sql
-- ============================================================
-- Urutan eksekusi:
--   1. schema.sql
--   2. etl.sql
--   3. views.sql    (file ini)
--   4. analysis.sql
-- ============================================================

USE SeoulBikeAnalytics;
GO


-- ============================================================
-- # 1. vw_hourly_summary — Ringkasan Per Jam
-- ============================================================
-- View ini menampilkan rata-rata, total, min, max demand per jam.
-- Berguna untuk mengidentifikasi pola jam sibuk dan sepi.

IF OBJECT_ID('dbo.vw_hourly_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_hourly_summary;
GO

CREATE VIEW dbo.vw_hourly_summary AS
SELECT
    ts.time_slot_id,
    ts.[hour],
    ts.time_period,
    ts.rush_hour_flag,
    ts.[shift],
    COUNT(*)                                    AS total_observations,
    SUM(f.rented_bike_count)                    AS total_rentals,
    AVG(CAST(f.rented_bike_count AS FLOAT))     AS avg_rentals,
    MIN(f.rented_bike_count)                    AS min_rentals,
    MAX(f.rented_bike_count)                    AS max_rentals,
    STDEV(CAST(f.rented_bike_count AS FLOAT))   AS stddev_rentals,
    AVG(CAST(f.temperature AS FLOAT))           AS avg_temperature,
    AVG(CAST(f.humidity AS FLOAT))              AS avg_humidity
FROM dbo.fact_rental f
JOIN dbo.dim_time_slot ts ON f.time_slot_id = ts.time_slot_id
GROUP BY
    ts.time_slot_id,
    ts.[hour],
    ts.time_period,
    ts.rush_hour_flag,
    ts.[shift];
GO

PRINT '✅ View [dbo.vw_hourly_summary] created.';
GO


-- ============================================================
-- # 2. vw_daily_summary — Ringkasan Per Hari
-- ============================================================
-- View ini menampilkan total dan rata-rata demand per hari.
-- Termasuk atribut tanggal (weekday/weekend, quarter, dll).

IF OBJECT_ID('dbo.vw_daily_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_daily_summary;
GO

CREATE VIEW dbo.vw_daily_summary AS
SELECT
    dd.date_id,
    dd.full_date,
    dd.[year],
    dd.[month],
    dd.month_name,
    dd.[day],
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend,
    dd.week_number,
    dd.[quarter],
    ds.season_name,
    dh.day_type,
    COUNT(*)                                    AS hours_recorded,
    SUM(f.rented_bike_count)                    AS total_rentals,
    AVG(CAST(f.rented_bike_count AS FLOAT))     AS avg_hourly_rentals,
    MIN(f.rented_bike_count)                    AS min_hourly_rentals,
    MAX(f.rented_bike_count)                    AS max_hourly_rentals,
    AVG(CAST(f.temperature AS FLOAT))           AS avg_temperature,
    MIN(f.temperature)                          AS min_temperature,
    MAX(f.temperature)                          AS max_temperature,
    AVG(CAST(f.humidity AS FLOAT))              AS avg_humidity,
    SUM(f.rainfall)                             AS total_rainfall,
    SUM(f.snowfall)                             AS total_snowfall,
    AVG(CAST(f.wind_speed AS FLOAT))            AS avg_wind_speed,
    AVG(CAST(f.solar_radiation AS FLOAT))       AS avg_solar_radiation
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
JOIN dbo.dim_holiday dh    ON f.holiday_id = dh.holiday_id
GROUP BY
    dd.date_id, dd.full_date, dd.[year], dd.[month], dd.month_name,
    dd.[day], dd.day_of_week, dd.day_name, dd.is_weekend,
    dd.week_number, dd.[quarter], ds.season_name, dh.day_type;
GO

PRINT '✅ View [dbo.vw_daily_summary] created.';
GO


-- ============================================================
-- # 3. vw_monthly_summary — Ringkasan Per Bulan
-- ============================================================
-- View ini menampilkan aggregasi bulanan untuk trend analysis.
-- Berguna untuk Power BI line chart dan seasonal comparison.

IF OBJECT_ID('dbo.vw_monthly_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_monthly_summary;
GO

CREATE VIEW dbo.vw_monthly_summary AS
SELECT
    dd.[year],
    dd.[month],
    dd.month_name,
    dd.[quarter],
    ds.season_name,
    COUNT(DISTINCT dd.full_date)                AS days_in_month,
    COUNT(*)                                    AS total_hours,
    SUM(f.rented_bike_count)                    AS total_rentals,
    AVG(CAST(f.rented_bike_count AS FLOAT))     AS avg_hourly_rentals,
    SUM(f.rented_bike_count) / 
        NULLIF(COUNT(DISTINCT dd.full_date), 0) AS avg_daily_rentals,
    MIN(f.rented_bike_count)                    AS min_hourly_rentals,
    MAX(f.rented_bike_count)                    AS max_hourly_rentals,
    AVG(CAST(f.temperature AS FLOAT))           AS avg_temperature,
    MIN(f.temperature)                          AS min_temperature,
    MAX(f.temperature)                          AS max_temperature,
    AVG(CAST(f.humidity AS FLOAT))              AS avg_humidity,
    SUM(f.rainfall)                             AS total_rainfall_mm,
    SUM(f.snowfall)                             AS total_snowfall_cm,

    -- Hitung jumlah jam dengan kondisi cuaca tertentu
    SUM(CASE WHEN f.rainfall > 0 THEN 1 ELSE 0 END) AS rainy_hours,
    SUM(CASE WHEN f.snowfall > 0 THEN 1 ELSE 0 END) AS snowy_hours,

    -- Hitung jumlah jam zero-demand
    SUM(CASE WHEN f.rented_bike_count = 0 THEN 1 ELSE 0 END) AS zero_demand_hours
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
GROUP BY
    dd.[year], dd.[month], dd.month_name, dd.[quarter], ds.season_name;
GO

PRINT '✅ View [dbo.vw_monthly_summary] created.';
GO


-- ============================================================
-- # 4. vw_weather_impact — Dampak Cuaca terhadap Demand
-- ============================================================
-- View ini menampilkan rata-rata demand per kategori cuaca.
-- Berguna untuk scatter plot, clustered bar, dan gauge di Power BI.

IF OBJECT_ID('dbo.vw_weather_impact', 'V') IS NOT NULL
    DROP VIEW dbo.vw_weather_impact;
GO

CREATE VIEW dbo.vw_weather_impact AS
SELECT
    dw.weather_id,
    dw.temp_category,
    dw.humidity_category,
    dw.weather_condition,
    COUNT(*)                                    AS total_observations,
    SUM(f.rented_bike_count)                    AS total_rentals,
    AVG(CAST(f.rented_bike_count AS FLOAT))     AS avg_rentals,
    MIN(f.rented_bike_count)                    AS min_rentals,
    MAX(f.rented_bike_count)                    AS max_rentals,
    STDEV(CAST(f.rented_bike_count AS FLOAT))   AS stddev_rentals,

    -- Coefficient of Variation (volatility)
    CASE
        WHEN AVG(CAST(f.rented_bike_count AS FLOAT)) > 0
        THEN STDEV(CAST(f.rented_bike_count AS FLOAT)) / AVG(CAST(f.rented_bike_count AS FLOAT))
        ELSE 0
    END                                         AS demand_volatility,

    AVG(CAST(f.temperature AS FLOAT))           AS avg_temperature,
    AVG(CAST(f.humidity AS FLOAT))              AS avg_humidity,
    AVG(CAST(f.wind_speed AS FLOAT))            AS avg_wind_speed,
    AVG(CAST(f.visibility AS FLOAT))            AS avg_visibility,
    AVG(CAST(f.solar_radiation AS FLOAT))       AS avg_solar_radiation
FROM dbo.fact_rental f
JOIN dbo.dim_weather dw ON f.weather_id = dw.weather_id
GROUP BY
    dw.weather_id,
    dw.temp_category,
    dw.humidity_category,
    dw.weather_condition;
GO

PRINT '✅ View [dbo.vw_weather_impact] created.';
GO


-- ============================================================
-- # 5. vw_full_detail — Detail Lengkap (Denormalized)
-- ============================================================
-- View tambahan: gabungan semua tabel untuk fleksibilitas
-- query di Power BI tanpa perlu join manual.

IF OBJECT_ID('dbo.vw_full_detail', 'V') IS NOT NULL
    DROP VIEW dbo.vw_full_detail;
GO

CREATE VIEW dbo.vw_full_detail AS
SELECT
    -- Fact metrics
    f.rental_id,
    f.rented_bike_count,
    f.temperature,
    f.humidity,
    f.wind_speed,
    f.visibility,
    f.dew_point_temp,
    f.solar_radiation,
    f.rainfall,
    f.snowfall,

    -- Date dimension
    dd.full_date,
    dd.[year],
    dd.[month],
    dd.month_name,
    dd.[day],
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend,
    dd.week_number,
    dd.[quarter],

    -- Time dimension
    ts.[hour],
    ts.time_period,
    ts.rush_hour_flag,
    ts.[shift],

    -- Season dimension
    ds.season_name,

    -- Holiday dimension
    dh.is_holiday,
    dh.is_functioning,
    dh.day_type,

    -- Weather dimension
    dw.temp_category,
    dw.humidity_category,
    dw.weather_condition

FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
JOIN dbo.dim_holiday dh    ON f.holiday_id = dh.holiday_id
JOIN dbo.dim_weather dw    ON f.weather_id = dw.weather_id;
GO

PRINT '✅ View [dbo.vw_full_detail] created.';
GO


-- ============================================================
-- # VIEWS SUMMARY
-- ============================================================

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    'VIEW' AS TABLE_TYPE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT '============================================================';
PRINT '  ✅ ALL VIEWS CREATED';
PRINT '  Views tersedia:';
PRINT '    - dbo.vw_hourly_summary';
PRINT '    - dbo.vw_daily_summary';
PRINT '    - dbo.vw_monthly_summary';
PRINT '    - dbo.vw_weather_impact';
PRINT '    - dbo.vw_full_detail';
PRINT '  Selanjutnya jalankan: analysis.sql';
PRINT '============================================================';
GO
