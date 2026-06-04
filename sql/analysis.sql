-- ============================================================
-- # SEOUL BIKE SHARING DEMAND ANALYTICS
-- # Business Analysis Queries
-- # Jalankan file ini SETELAH views.sql
-- ============================================================
-- Urutan eksekusi:
--   1. schema.sql
--   2. etl.sql
--   3. views.sql
--   4. analysis.sql  (file ini)
-- ============================================================
-- File ini berisi query analitik untuk menjawab pertanyaan
-- bisnis utama. Query-query ini juga bisa digunakan sebagai
-- referensi saat membangun dashboard Power BI.
-- ============================================================

USE SeoulBikeAnalytics;
GO


-- ============================================================
-- # 1. TEMPORAL ANALYSIS (Analisis Waktu)
-- ============================================================

-- ------------------------------------------------------------
-- # 1.1 Rata-rata Rental per Jam
-- Tujuan: Identifikasi jam sibuk (peak) dan sepi (off-peak)
-- ------------------------------------------------------------
SELECT
    [hour],
    time_period,
    rush_hour_flag,
    ROUND(avg_rentals, 1) AS avg_rentals,
    total_rentals,
    min_rentals,
    max_rentals,
    ROUND(stddev_rentals, 1) AS demand_volatility
FROM dbo.vw_hourly_summary
ORDER BY [hour];
GO


-- ------------------------------------------------------------
-- # 1.2 Trend Harian: Weekday vs Weekend
-- Tujuan: Strategi armada berbeda untuk hari kerja vs akhir pekan
-- ------------------------------------------------------------
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_category,
    COUNT(*) AS total_days,
    SUM(total_rentals) AS total_rentals,
    ROUND(AVG(CAST(total_rentals AS FLOAT)), 1) AS avg_daily_rentals,
    ROUND(AVG(avg_hourly_rentals), 1) AS avg_hourly_rentals,
    MIN(total_rentals) AS min_daily_rentals,
    MAX(total_rentals) AS max_daily_rentals
FROM dbo.vw_daily_summary
GROUP BY is_weekend
ORDER BY is_weekend;
GO


-- ------------------------------------------------------------
-- # 1.3 Pola Jam per Hari dalam Seminggu (Heatmap Data)
-- Tujuan: Visualisasi pola 24 jam × 7 hari untuk heatmap
-- ------------------------------------------------------------
SELECT
    dd.day_name,
    dd.day_of_week,
    ts.[hour],
    AVG(CAST(f.rented_bike_count AS FLOAT)) AS avg_rentals
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
GROUP BY dd.day_name, dd.day_of_week, ts.[hour]
ORDER BY dd.day_of_week, ts.[hour];
GO


-- ------------------------------------------------------------
-- # 1.4 Trend Bulanan
-- Tujuan: Perencanaan kapasitas bulanan
-- ------------------------------------------------------------
SELECT
    [month],
    month_name,
    season_name,
    total_rentals,
    avg_daily_rentals,
    ROUND(avg_hourly_rentals, 1) AS avg_hourly_rentals,
    ROUND(avg_temperature, 1) AS avg_temp_c,
    total_rainfall_mm,
    total_snowfall_cm,
    zero_demand_hours
FROM dbo.vw_monthly_summary
ORDER BY [month];
GO


-- ------------------------------------------------------------
-- # 1.5 Peak vs Off-Peak Hours Comparison
-- Tujuan: Optimalisasi pricing dinamis
-- ------------------------------------------------------------
SELECT
    CASE WHEN rush_hour_flag = 1 THEN 'Rush Hour' ELSE 'Non-Rush Hour' END AS hour_type,
    COUNT(*) AS hour_slots,
    ROUND(AVG(avg_rentals), 1) AS avg_rentals,
    SUM(total_rentals) AS total_rentals,
    ROUND(
        CAST(SUM(total_rentals) AS FLOAT) / 
        (SELECT SUM(total_rentals) FROM dbo.vw_hourly_summary) * 100
    , 1) AS pct_of_total
FROM dbo.vw_hourly_summary
GROUP BY rush_hour_flag
ORDER BY rush_hour_flag DESC;
GO


-- ------------------------------------------------------------
-- # 1.6 Weekday Hourly Pattern vs Weekend Hourly Pattern
-- Tujuan: Memahami perbedaan pola demand antara hari kerja
--         dan akhir pekan untuk distribusi armada
-- ------------------------------------------------------------
SELECT
    ts.[hour],
    ts.time_period,
    ROUND(AVG(CASE WHEN dd.is_weekend = 0 THEN CAST(f.rented_bike_count AS FLOAT) END), 1) AS weekday_avg,
    ROUND(AVG(CASE WHEN dd.is_weekend = 1 THEN CAST(f.rented_bike_count AS FLOAT) END), 1) AS weekend_avg,
    ROUND(
        AVG(CASE WHEN dd.is_weekend = 1 THEN CAST(f.rented_bike_count AS FLOAT) END) -
        AVG(CASE WHEN dd.is_weekend = 0 THEN CAST(f.rented_bike_count AS FLOAT) END)
    , 1) AS weekend_vs_weekday_diff
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
GROUP BY ts.[hour], ts.time_period
ORDER BY ts.[hour];
GO


-- ============================================================
-- # 2. WEATHER IMPACT ANALYSIS (Analisis Dampak Cuaca)
-- ============================================================

-- ------------------------------------------------------------
-- # 2.1 Dampak Temperature terhadap Demand
-- Tujuan: Menentukan threshold suhu optimal untuk demand
-- ------------------------------------------------------------
SELECT
    temp_category,
    SUM(total_observations) AS total_hours,
    SUM(total_rentals) AS total_rentals,
    ROUND(AVG(avg_rentals), 1) AS avg_rentals,
    ROUND(AVG(avg_temperature), 1) AS avg_temp_c,
    ROUND(
        CAST(SUM(total_rentals) AS FLOAT) / 
        (SELECT SUM(rented_bike_count) FROM dbo.fact_rental) * 100
    , 1) AS pct_of_total_rentals
FROM dbo.vw_weather_impact
GROUP BY temp_category
ORDER BY 
    CASE temp_category
        WHEN 'Freezing' THEN 1
        WHEN 'Cold' THEN 2
        WHEN 'Cool' THEN 3
        WHEN 'Warm' THEN 4
        WHEN 'Hot' THEN 5
    END;
GO


-- ------------------------------------------------------------
-- # 2.2 Dampak Curah Hujan terhadap Demand
-- Tujuan: Contingency planning saat hujan
-- ------------------------------------------------------------
SELECT
    weather_condition,
    SUM(total_observations) AS total_hours,
    SUM(total_rentals) AS total_rentals,
    ROUND(AVG(avg_rentals), 1) AS avg_rentals,
    ROUND(
        AVG(avg_rentals) / 
        NULLIF((SELECT AVG(CAST(rented_bike_count AS FLOAT)) FROM dbo.fact_rental), 0) * 100
    , 1) AS pct_vs_overall_avg
FROM dbo.vw_weather_impact
GROUP BY weather_condition
ORDER BY AVG(avg_rentals) DESC;
GO


-- ------------------------------------------------------------
-- # 2.3 Dampak Humidity terhadap Demand
-- Tujuan: Menentukan comfort index thresholds
-- ------------------------------------------------------------
SELECT
    humidity_category,
    SUM(total_observations) AS total_hours,
    SUM(total_rentals) AS total_rentals,
    ROUND(AVG(avg_rentals), 1) AS avg_rentals,
    ROUND(AVG(avg_humidity), 1) AS avg_humidity_pct
FROM dbo.vw_weather_impact
GROUP BY humidity_category
ORDER BY
    CASE humidity_category
        WHEN 'Low' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'High' THEN 3
        WHEN 'Very High' THEN 4
    END;
GO


-- ------------------------------------------------------------
-- # 2.4 Temperature Bins (lebih granular per 5°C)
-- Tujuan: Kurva temperature vs demand yang lebih halus
-- ------------------------------------------------------------
SELECT
    CONCAT(
        CAST(FLOOR(temperature / 5) * 5 AS INT), '°C to ',
        CAST(FLOOR(temperature / 5) * 5 + 4 AS INT), '°C'
    ) AS temp_range,
    FLOOR(temperature / 5) * 5 AS temp_bin_start,
    COUNT(*) AS total_hours,
    ROUND(AVG(CAST(rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    SUM(rented_bike_count) AS total_rentals
FROM dbo.fact_rental
GROUP BY FLOOR(temperature / 5) * 5
ORDER BY temp_bin_start;
GO


-- ------------------------------------------------------------
-- # 2.5 Multi-Factor Weather Scoring
-- Tujuan: Composite weather suitability index per kombinasi
-- ------------------------------------------------------------
SELECT TOP 10
    dw.temp_category,
    dw.humidity_category,
    dw.weather_condition,
    COUNT(*) AS total_hours,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    MAX(f.rented_bike_count) AS max_rentals
FROM dbo.fact_rental f
JOIN dbo.dim_weather dw ON f.weather_id = dw.weather_id
GROUP BY dw.temp_category, dw.humidity_category, dw.weather_condition
HAVING COUNT(*) >= 10  -- Minimal 10 observasi untuk signifikansi
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) DESC;
GO


-- ============================================================
-- # 3. SEASONAL ANALYSIS (Analisis Musiman)
-- ============================================================

-- ------------------------------------------------------------
-- # 3.1 Demand per Musim
-- Tujuan: Seasonal revenue planning
-- ------------------------------------------------------------
SELECT
    ds.season_name,
    ds.season_order,
    COUNT(*) AS total_hours,
    SUM(f.rented_bike_count) AS total_rentals,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_hourly_rentals,
    ROUND(AVG(CAST(f.temperature AS FLOAT)), 1) AS avg_temp_c,
    ROUND(
        CAST(SUM(f.rented_bike_count) AS FLOAT) / 
        (SELECT SUM(rented_bike_count) FROM dbo.fact_rental) * 100
    , 1) AS pct_of_annual_rentals
FROM dbo.fact_rental f
JOIN dbo.dim_season ds ON f.season_id = ds.season_id
GROUP BY ds.season_name, ds.season_order
ORDER BY ds.season_order;
GO


-- ------------------------------------------------------------
-- # 3.2 Hourly Pattern per Musim
-- Tujuan: Melihat apakah pola jam berubah antar musim
-- ------------------------------------------------------------
SELECT
    ds.season_name,
    ts.[hour],
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals
FROM dbo.fact_rental f
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
GROUP BY ds.season_name, ds.season_order, ts.[hour]
ORDER BY ds.season_order, ts.[hour];
GO


-- ------------------------------------------------------------
-- # 3.3 Seasonal Transition Analysis
-- Tujuan: Pola transisi antar musim (bulan peralihan)
-- ------------------------------------------------------------
SELECT
    dd.[month],
    dd.month_name,
    ds.season_name,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_hourly_rentals,
    ROUND(AVG(CAST(f.temperature AS FLOAT)), 1) AS avg_temp,
    SUM(f.rented_bike_count) AS total_rentals,
    -- Month-over-month change (akan terlihat di chart)
    LAG(ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1)) 
        OVER (ORDER BY dd.[month]) AS prev_month_avg,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) - 
    LAG(ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1)) 
        OVER (ORDER BY dd.[month]) AS mom_change
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
GROUP BY dd.[month], dd.month_name, ds.season_name
ORDER BY dd.[month];
GO


-- ============================================================
-- # 4. OPERATIONAL KPIs
-- ============================================================

-- ------------------------------------------------------------
-- # 4.1 Overview KPI Dashboard
-- Tujuan: Ringkasan KPI utama untuk executive summary
-- ------------------------------------------------------------
SELECT
    -- Volume Metrics
    SUM(rented_bike_count)                                              AS total_annual_rentals,
    ROUND(AVG(CAST(rented_bike_count AS FLOAT)), 1)                     AS avg_hourly_demand,
    ROUND(CAST(SUM(rented_bike_count) AS FLOAT) / 365, 1)              AS avg_daily_demand,
    MAX(rented_bike_count)                                              AS peak_hourly_demand,
    MIN(rented_bike_count)                                              AS min_hourly_demand,

    -- Zero Demand
    SUM(CASE WHEN rented_bike_count = 0 THEN 1 ELSE 0 END)             AS zero_demand_hours,
    ROUND(
        CAST(SUM(CASE WHEN rented_bike_count = 0 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(*) * 100
    , 2)                                                                AS zero_demand_pct,

    -- Volatility
    ROUND(STDEV(CAST(rented_bike_count AS FLOAT)), 1)                   AS demand_stddev,
    ROUND(
        STDEV(CAST(rented_bike_count AS FLOAT)) / 
        NULLIF(AVG(CAST(rented_bike_count AS FLOAT)), 0)
    , 3)                                                                AS coefficient_of_variation,

    -- Operating Days
    COUNT(DISTINCT date_id)                                             AS total_days,
    COUNT(*)                                                            AS total_hours_recorded
FROM dbo.fact_rental;
GO


-- ------------------------------------------------------------
-- # 4.2 Holiday Impact Factor
-- Tujuan: Staffing guide berdasarkan holiday vs working day
-- ------------------------------------------------------------
SELECT
    dh.day_type,
    COUNT(*) AS total_hours,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    SUM(f.rented_bike_count) AS total_rentals,
    ROUND(
        AVG(CAST(f.rented_bike_count AS FLOAT)) / 
        NULLIF((SELECT AVG(CAST(rented_bike_count AS FLOAT)) FROM dbo.fact_rental), 0)
    , 3) AS impact_factor  -- > 1 = above average, < 1 = below average
FROM dbo.fact_rental f
JOIN dbo.dim_holiday dh ON f.holiday_id = dh.holiday_id
GROUP BY dh.day_type
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) DESC;
GO


-- ------------------------------------------------------------
-- # 4.3 Demand Distribution per Shift
-- Tujuan: Staffing allocation per shift operasional
-- ------------------------------------------------------------
SELECT
    ts.[shift],
    COUNT(*) AS total_hours,
    SUM(f.rented_bike_count) AS total_rentals,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    ROUND(
        CAST(SUM(f.rented_bike_count) AS FLOAT) / 
        (SELECT SUM(rented_bike_count) FROM dbo.fact_rental) * 100
    , 1) AS pct_of_total
FROM dbo.fact_rental f
JOIN dbo.dim_time_slot ts ON f.time_slot_id = ts.time_slot_id
GROUP BY ts.[shift]
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) DESC;
GO


-- ------------------------------------------------------------
-- # 4.4 Weather Sensitivity Index
-- Tujuan: Mengukur seberapa sensitif demand terhadap cuaca
-- ------------------------------------------------------------
SELECT
    dw.weather_condition,
    COUNT(*) AS total_hours,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    ROUND(STDEV(CAST(f.rented_bike_count AS FLOAT)), 1) AS stddev_rentals,
    ROUND(
        STDEV(CAST(f.rented_bike_count AS FLOAT)) / 
        NULLIF(AVG(CAST(f.rented_bike_count AS FLOAT)), 0)
    , 3) AS weather_sensitivity_index
FROM dbo.fact_rental f
JOIN dbo.dim_weather dw ON f.weather_id = dw.weather_id
GROUP BY dw.weather_condition
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) DESC;
GO


-- ============================================================
-- # 5. BUSINESS INSIGHTS
-- ============================================================

-- ------------------------------------------------------------
-- # 5.1 Top 10 Hari dengan Demand Tertinggi
-- Tujuan: Identifikasi pola hari-hari puncak
-- ------------------------------------------------------------
SELECT TOP 10
    full_date,
    day_name,
    season_name,
    day_type,
    total_rentals,
    ROUND(avg_hourly_rentals, 1) AS avg_hourly,
    max_hourly_rentals,
    ROUND(avg_temperature, 1) AS avg_temp_c,
    total_rainfall AS rainfall_mm
FROM dbo.vw_daily_summary
ORDER BY total_rentals DESC;
GO


-- ------------------------------------------------------------
-- # 5.2 Top 10 Hari dengan Demand Terendah (Non-Functioning excluded)
-- Tujuan: Identifikasi hari terbaik untuk maintenance
-- ------------------------------------------------------------
SELECT TOP 10
    full_date,
    day_name,
    season_name,
    day_type,
    total_rentals,
    ROUND(avg_hourly_rentals, 1) AS avg_hourly,
    ROUND(avg_temperature, 1) AS avg_temp_c,
    total_rainfall AS rainfall_mm,
    total_snowfall AS snowfall_cm
FROM dbo.vw_daily_summary
WHERE day_type <> 'Non-Functioning'
ORDER BY total_rentals ASC;
GO


-- ------------------------------------------------------------
-- # 5.3 Optimal Operating Conditions
-- Tujuan: Kombinasi kondisi ideal untuk demand tertinggi
-- ------------------------------------------------------------
SELECT TOP 10
    ds.season_name,
    dd.day_name,
    ts.time_period,
    dw.temp_category,
    dw.weather_condition,
    COUNT(*) AS frequency,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    MAX(f.rented_bike_count) AS max_rentals
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
JOIN dbo.dim_weather dw    ON f.weather_id = dw.weather_id
GROUP BY ds.season_name, dd.day_name, ts.time_period, dw.temp_category, dw.weather_condition
HAVING COUNT(*) >= 5  -- Minimal 5 observasi
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) DESC;
GO


-- ------------------------------------------------------------
-- # 5.4 Revenue Opportunity: Low-Demand Hours Analysis
-- Tujuan: Identifikasi jam-jam di mana supply bisa ditingkatkan
--         atau promosi bisa dilakukan
-- ------------------------------------------------------------
SELECT
    ts.[hour],
    ts.time_period,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) - 
        (SELECT AVG(CAST(rented_bike_count AS FLOAT)) FROM dbo.fact_rental) AS gap_from_avg,
    SUM(CASE WHEN f.rented_bike_count = 0 THEN 1 ELSE 0 END) AS zero_hours,
    ROUND(
        CAST(SUM(CASE WHEN f.rented_bike_count = 0 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(*) * 100
    , 1) AS zero_pct,
    CASE
        WHEN AVG(CAST(f.rented_bike_count AS FLOAT)) < 100 THEN '🔴 Very Low - Reduce Fleet'
        WHEN AVG(CAST(f.rented_bike_count AS FLOAT)) < 300 THEN '🟡 Low - Promote/Discount'
        WHEN AVG(CAST(f.rented_bike_count AS FLOAT)) < 700 THEN '🟢 Moderate - Maintain'
        ELSE '🔵 High - Maximize Supply'
    END AS action_recommendation
FROM dbo.fact_rental f
JOIN dbo.dim_time_slot ts ON f.time_slot_id = ts.time_slot_id
GROUP BY ts.[hour], ts.time_period
ORDER BY ts.[hour];
GO


-- ------------------------------------------------------------
-- # 5.5 Weekend vs Weekday Revenue Opportunity
-- Tujuan: Identifikasi gap antara weekday dan weekend per jam
-- ------------------------------------------------------------
SELECT
    ts.[hour],
    ts.time_period,
    ROUND(AVG(CASE WHEN dd.is_weekend = 0 THEN CAST(f.rented_bike_count AS FLOAT) END), 1) AS weekday_avg,
    ROUND(AVG(CASE WHEN dd.is_weekend = 1 THEN CAST(f.rented_bike_count AS FLOAT) END), 1) AS weekend_avg,
    CASE
        WHEN AVG(CASE WHEN dd.is_weekend = 1 THEN CAST(f.rented_bike_count AS FLOAT) END) >
             AVG(CASE WHEN dd.is_weekend = 0 THEN CAST(f.rented_bike_count AS FLOAT) END)
        THEN 'Weekend Higher'
        ELSE 'Weekday Higher'
    END AS dominant_period,
    ROUND(ABS(
        AVG(CASE WHEN dd.is_weekend = 1 THEN CAST(f.rented_bike_count AS FLOAT) END) -
        AVG(CASE WHEN dd.is_weekend = 0 THEN CAST(f.rented_bike_count AS FLOAT) END)
    ), 1) AS demand_gap
FROM dbo.fact_rental f
JOIN dbo.dim_date dd       ON f.date_id = dd.date_id
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
GROUP BY ts.[hour], ts.time_period
ORDER BY ts.[hour];
GO


-- ------------------------------------------------------------
-- # 5.6 Rain Impact: Revenue Loss Estimation
-- Tujuan: Estimasi kehilangan demand saat hujan
-- ------------------------------------------------------------
;WITH weather_avg AS (
    SELECT
        dw.weather_condition,
        COUNT(*) AS total_hours,
        AVG(CAST(f.rented_bike_count AS FLOAT)) AS avg_demand,
        SUM(f.rented_bike_count) AS total_demand
    FROM dbo.fact_rental f
    JOIN dbo.dim_weather dw ON f.weather_id = dw.weather_id
    GROUP BY dw.weather_condition
)
SELECT
    clear.avg_demand                                            AS avg_clear_demand,
    rainy.avg_demand                                            AS avg_rainy_demand,
    ROUND(clear.avg_demand - rainy.avg_demand, 1)               AS demand_drop,
    ROUND((1 - rainy.avg_demand / NULLIF(clear.avg_demand, 0)) * 100, 1) AS demand_drop_pct,
    rainy.total_hours                                           AS total_rainy_hours,
    ROUND((clear.avg_demand - rainy.avg_demand) * rainy.total_hours, 0) AS estimated_total_demand_loss
FROM 
    (SELECT * FROM weather_avg WHERE weather_condition = 'Clear') clear,
    (SELECT * FROM weather_avg WHERE weather_condition = 'Rainy') rainy;
GO


-- ------------------------------------------------------------
-- # 5.7 Optimal Maintenance Windows
-- Tujuan: Identifikasi slot waktu terbaik untuk maintenance
--         (demand rendah + sering zero demand)
-- ------------------------------------------------------------
SELECT TOP 5
    ts.[hour],
    ts.time_period,
    ds.season_name,
    ROUND(AVG(CAST(f.rented_bike_count AS FLOAT)), 1) AS avg_rentals,
    SUM(CASE WHEN f.rented_bike_count = 0 THEN 1 ELSE 0 END) AS zero_demand_count,
    COUNT(*) AS total_observations,
    ROUND(
        CAST(SUM(CASE WHEN f.rented_bike_count = 0 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(*) * 100
    , 1) AS zero_demand_pct
FROM dbo.fact_rental f
JOIN dbo.dim_time_slot ts  ON f.time_slot_id = ts.time_slot_id
JOIN dbo.dim_season ds     ON f.season_id = ds.season_id
GROUP BY ts.[hour], ts.time_period, ds.season_name, ds.season_order
HAVING AVG(CAST(f.rented_bike_count AS FLOAT)) < 100
ORDER BY AVG(CAST(f.rented_bike_count AS FLOAT)) ASC;
GO


-- ============================================================
-- # ANALYSIS SUMMARY
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '  ✅ ALL ANALYSIS QUERIES EXECUTED';
PRINT '  Query Sections:';
PRINT '    1. Temporal Analysis     (6 queries)';
PRINT '    2. Weather Impact        (5 queries)';
PRINT '    3. Seasonal Analysis     (3 queries)';
PRINT '    4. Operational KPIs      (4 queries)';
PRINT '    5. Business Insights     (7 queries)';
PRINT '  Total: 25 analysis queries';
PRINT '============================================================';
GO
