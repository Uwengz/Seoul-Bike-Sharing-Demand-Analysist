-- ============================================================
-- # SEOUL BIKE SHARING DEMAND ANALYTICS
-- # Schema Definition
-- # Jalankan file ini PERTAMA sebelum file SQL lainnya
-- ============================================================
-- Urutan eksekusi:
--   1. schema.sql   (file ini)
--   2. etl.sql
--   3. views.sql
--   4. analysis.sql
-- ============================================================


-- ============================================================
-- # 1. CREATE DATABASE & SCHEMA
-- ============================================================

-- Buat database utama
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SeoulBikeAnalytics')
BEGIN
    CREATE DATABASE SeoulBikeAnalytics;
END
GO

USE SeoulBikeAnalytics;
GO

-- Buat schema staging untuk data mentah
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'staging')
BEGIN
    EXEC('CREATE SCHEMA staging');
END
GO


-- ============================================================
-- # 2. STAGING TABLE (staging.bike_raw)
-- ============================================================
-- Tabel staging sebagai landing zone untuk BULK INSERT dari CSV.
-- Kolom disesuaikan dengan header CSV asli dari UCI dataset.

IF OBJECT_ID('staging.bike_raw', 'U') IS NOT NULL
    DROP TABLE staging.bike_raw;
GO

CREATE TABLE staging.bike_raw (
    [Date]                  VARCHAR(20)      NOT NULL,   -- DD/MM/YYYY
    [Rented Bike Count]     INT              NOT NULL,
    [Hour]                  INT              NOT NULL,
    [Temperature]           DECIMAL(5,2)     NOT NULL,   -- °C
    [Humidity]              INT              NOT NULL,   -- %
    [Wind speed]            DECIMAL(5,2)     NOT NULL,   -- m/s
    [Visibility]            INT              NOT NULL,   -- 10m
    [Dew point temperature] DECIMAL(5,2)     NOT NULL,   -- °C
    [Solar Radiation]       DECIMAL(5,2)     NOT NULL,   -- MJ/m²
    [Rainfall]              DECIMAL(5,2)     NOT NULL,   -- mm
    [Snowfall]              DECIMAL(5,2)     NOT NULL,   -- cm
    [Seasons]               VARCHAR(20)      NOT NULL,
    [Holiday]               VARCHAR(20)      NOT NULL,
    [Functioning Day]       VARCHAR(10)      NOT NULL
);
GO

PRINT '✅ Staging table [staging.bike_raw] created.';
GO


-- ============================================================
-- # 3. DIMENSION TABLES
-- ============================================================

-- ------------------------------------------------------------
-- # 3.1 dim_date — Dimensi Tanggal
-- ------------------------------------------------------------
-- Menyimpan atribut tanggal untuk slicing/filtering di Power BI.
-- date_id menggunakan format YYYYMMDD sebagai surrogate key.

IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL
    DROP TABLE dbo.dim_date;
GO

CREATE TABLE dbo.dim_date (
    date_id         INT             PRIMARY KEY,    -- Format YYYYMMDD
    full_date       DATE            NOT NULL,
    [year]          INT             NOT NULL,
    [month]         INT             NOT NULL,       -- 1-12
    month_name      VARCHAR(20)     NOT NULL,       -- January, February, ...
    [day]           INT             NOT NULL,       -- 1-31
    day_of_week     INT             NOT NULL,       -- 1=Monday ... 7=Sunday
    day_name        VARCHAR(20)     NOT NULL,       -- Monday, Tuesday, ...
    is_weekend      BIT             NOT NULL,       -- 1 jika Sabtu/Minggu
    week_number     INT             NOT NULL,       -- 1-53
    [quarter]       INT             NOT NULL        -- 1-4
);
GO

PRINT '✅ Dimension table [dbo.dim_date] created.';
GO


-- ------------------------------------------------------------
-- # 3.2 dim_season — Dimensi Musim
-- ------------------------------------------------------------
-- 4 musim di Korea Selatan. Urutan kalender untuk sorting.

IF OBJECT_ID('dbo.dim_season', 'U') IS NOT NULL
    DROP TABLE dbo.dim_season;
GO

CREATE TABLE dbo.dim_season (
    season_id       INT             PRIMARY KEY,
    season_name     VARCHAR(20)     NOT NULL,
    season_order    INT             NOT NULL        -- Urutan kalender
);
GO

PRINT '✅ Dimension table [dbo.dim_season] created.';
GO


-- ------------------------------------------------------------
-- # 3.3 dim_time_slot — Dimensi Waktu (Jam)
-- ------------------------------------------------------------
-- Klasifikasi 24 jam ke dalam time period, rush hour, dan shift.

IF OBJECT_ID('dbo.dim_time_slot', 'U') IS NOT NULL
    DROP TABLE dbo.dim_time_slot;
GO

CREATE TABLE dbo.dim_time_slot (
    time_slot_id    INT             PRIMARY KEY,    -- 0-23
    [hour]          INT             NOT NULL,
    time_period     VARCHAR(20)     NOT NULL,       -- Dawn/Morning/Afternoon/Evening/Night
    rush_hour_flag  BIT             NOT NULL,       -- 1 jika rush hour
    [shift]         VARCHAR(20)     NOT NULL        -- Shift operasional
);
GO

PRINT '✅ Dimension table [dbo.dim_time_slot] created.';
GO


-- ------------------------------------------------------------
-- # 3.4 dim_holiday — Dimensi Hari Libur & Status Operasional
-- ------------------------------------------------------------
-- Kombinasi holiday status + functioning day status.

IF OBJECT_ID('dbo.dim_holiday', 'U') IS NOT NULL
    DROP TABLE dbo.dim_holiday;
GO

CREATE TABLE dbo.dim_holiday (
    holiday_id      INT IDENTITY(1,1)   PRIMARY KEY,
    is_holiday      VARCHAR(20)         NOT NULL,   -- Holiday / No Holiday
    is_functioning  VARCHAR(10)         NOT NULL,   -- Yes / No
    day_type        VARCHAR(30)         NOT NULL    -- Working Day / Holiday / Non-Functioning
);
GO

PRINT '✅ Dimension table [dbo.dim_holiday] created.';
GO


-- ------------------------------------------------------------
-- # 3.5 dim_weather — Dimensi Kategori Cuaca
-- ------------------------------------------------------------
-- Kategori cuaca berdasarkan temperature, humidity, dan presipitasi.
-- Setiap kombinasi unik mendapat 1 row.

IF OBJECT_ID('dbo.dim_weather', 'U') IS NOT NULL
    DROP TABLE dbo.dim_weather;
GO

CREATE TABLE dbo.dim_weather (
    weather_id          INT IDENTITY(1,1)   PRIMARY KEY,
    temp_category       VARCHAR(20)         NOT NULL,   -- Freezing/Cold/Cool/Warm/Hot
    humidity_category   VARCHAR(20)         NOT NULL,   -- Low/Moderate/High/Very High
    weather_condition   VARCHAR(30)         NOT NULL    -- Clear/Rainy/Snowy/Rainy & Snowy
);
GO

PRINT '✅ Dimension table [dbo.dim_weather] created.';
GO


-- ============================================================
-- # 4. FACT TABLE (fact_rental)
-- ============================================================
-- Tabel fakta utama: 1 baris = 1 jam observasi.
-- Berisi semua metric numerik + foreign keys ke dimension tables.

IF OBJECT_ID('dbo.fact_rental', 'U') IS NOT NULL
    DROP TABLE dbo.fact_rental;
GO

CREATE TABLE dbo.fact_rental (
    rental_id           INT IDENTITY(1,1)   PRIMARY KEY,

    -- Foreign Keys ke Dimension Tables
    date_id             INT                 NOT NULL,
    time_slot_id        INT                 NOT NULL,
    season_id           INT                 NOT NULL,
    holiday_id          INT                 NOT NULL,
    weather_id          INT                 NOT NULL,

    -- Measures / Metrics
    rented_bike_count   INT                 NOT NULL,
    temperature         DECIMAL(5,2)        NOT NULL,   -- °C
    humidity            INT                 NOT NULL,   -- %
    wind_speed          DECIMAL(5,2)        NOT NULL,   -- m/s
    visibility          INT                 NOT NULL,   -- 10m
    dew_point_temp      DECIMAL(5,2)        NOT NULL,   -- °C
    solar_radiation     DECIMAL(5,2)        NOT NULL,   -- MJ/m²
    rainfall            DECIMAL(5,2)        NOT NULL,   -- mm
    snowfall            DECIMAL(5,2)        NOT NULL,   -- cm

    -- Constraints
    CONSTRAINT FK_fact_rental_date      FOREIGN KEY (date_id)       REFERENCES dbo.dim_date(date_id),
    CONSTRAINT FK_fact_rental_time      FOREIGN KEY (time_slot_id)  REFERENCES dbo.dim_time_slot(time_slot_id),
    CONSTRAINT FK_fact_rental_season    FOREIGN KEY (season_id)     REFERENCES dbo.dim_season(season_id),
    CONSTRAINT FK_fact_rental_holiday   FOREIGN KEY (holiday_id)    REFERENCES dbo.dim_holiday(holiday_id),
    CONSTRAINT FK_fact_rental_weather   FOREIGN KEY (weather_id)    REFERENCES dbo.dim_weather(weather_id)
);
GO

-- Index untuk performa query analitik
CREATE NONCLUSTERED INDEX IX_fact_rental_date      ON dbo.fact_rental(date_id);
CREATE NONCLUSTERED INDEX IX_fact_rental_time      ON dbo.fact_rental(time_slot_id);
CREATE NONCLUSTERED INDEX IX_fact_rental_season    ON dbo.fact_rental(season_id);
CREATE NONCLUSTERED INDEX IX_fact_rental_holiday   ON dbo.fact_rental(holiday_id);
CREATE NONCLUSTERED INDEX IX_fact_rental_weather   ON dbo.fact_rental(weather_id);
GO

PRINT '✅ Fact table [dbo.fact_rental] created with indexes.';
GO


-- ============================================================
-- # SCHEMA SUMMARY
-- ============================================================
-- Tampilkan ringkasan semua tabel yang telah dibuat.

SELECT 
    s.name AS [Schema],
    t.name AS [Table],
    (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS [Columns]
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;
GO

PRINT '';
PRINT '============================================================';
PRINT '  ✅ SCHEMA CREATION COMPLETE';
PRINT '  Selanjutnya jalankan: etl.sql';
PRINT '============================================================';
GO
