# 📊 PRD — Seoul Bike Sharing Demand Analytics

> **Product Requirements Document (PRD)**
> Proyek Analisis Data Bisnis: Seoul Bike Sharing Demand
> Versi: 1.0 | Tanggal: 2 Juni 2026

---

## 1. Ringkasan Eksekutif

Proyek ini bertujuan untuk membangun sebuah **data analytics pipeline** end-to-end yang menganalisis permintaan (demand) penyewaan sepeda di Seoul, Korea Selatan. Data bersumber dari [UCI Machine Learning Repository — Seoul Bike Sharing Demand](https://archive.ics.uci.edu/dataset/560/seoul+bike+sharing+demand).

Pipeline ini menggunakan **SQL Server** sebagai backend database untuk penyimpanan, transformasi, dan analisis data, serta **Power BI** sebagai frontend visualisasi untuk menghasilkan dashboard interaktif yang memberikan **business insights** kepada stakeholder.

---

## 2. Latar Belakang & Konteks Bisnis

### 2.1 Masalah Bisnis
Bike sharing merupakan moda transportasi urban yang semakin populer. Tantangan utama operator adalah:
- **Under-supply**: Sepeda tidak tersedia saat demand tinggi → pelanggan kecewa, kehilangan revenue
- **Over-supply**: Terlalu banyak sepeda tersedia saat demand rendah → biaya operasional tinggi (maintenance, redistribusi)
- **Lack of Forecasting**: Tidak adanya prediksi berbasis data untuk perencanaan stok dan redistribusi

### 2.2 Tujuan Analisis
| # | Tujuan | Deskripsi |
|---|--------|-----------|
| 1 | **Demand Pattern Analysis** | Memahami pola permintaan berdasarkan waktu (jam, hari, bulan, musim) |
| 2 | **Weather Impact Assessment** | Mengukur pengaruh kondisi cuaca terhadap volume penyewaan |
| 3 | **Operational Optimization** | Mengidentifikasi peak hours dan off-peak hours untuk optimalisasi armada |
| 4 | **Seasonal Strategy** | Memberikan rekomendasi strategi musiman (pricing, promosi, maintenance) |
| 5 | **Anomaly Detection** | Mendeteksi hari-hari dengan demand anomali (holiday, extreme weather) |

---

## 3. Data Source

### 3.1 Dataset Overview
| Atribut | Detail |
|---------|--------|
| **Sumber** | UCI Machine Learning Repository |
| **DOI** | [10.24432/C5F62R](https://doi.org/10.24432/C5F62R) |
| **File** | `SeoulBikeData.csv` (590 KB) |
| **Jumlah Baris** | 8,760 (data per jam selama 1 tahun penuh) |
| **Jumlah Kolom** | 14 |
| **Missing Values** | Tidak ada |
| **Lisensi** | CC BY 4.0 |

### 3.2 Data Dictionary

| Kolom | Tipe Data | Satuan | Deskripsi | Role |
|-------|-----------|--------|-----------|------|
| `Date` | Date | DD/MM/YYYY | Tanggal pencatatan | Feature |
| `Rented Bike Count` | Integer | unit | Jumlah sepeda yang disewa per jam | **Target** |
| `Hour` | Integer | 0–23 | Jam dalam sehari | Feature |
| `Temperature` | Float | °C | Suhu udara | Feature |
| `Humidity` | Integer | % | Kelembaban udara | Feature |
| `Wind speed` | Float | m/s | Kecepatan angin | Feature |
| `Visibility` | Integer | 10m | Jarak pandang | Feature |
| `Dew point temperature` | Float | °C | Titik embun | Feature |
| `Solar Radiation` | Float | MJ/m² | Radiasi matahari | Feature |
| `Rainfall` | Float | mm | Curah hujan | Feature |
| `Snowfall` | Float | cm | Curah salju | Feature |
| `Seasons` | Categorical | — | Winter, Spring, Summer, Autumn | Feature |
| `Holiday` | Categorical | — | Holiday / No Holiday | Feature |
| `Functioning Day` | Categorical | — | Yes (Functional) / No (Non-Functional) | Feature |

---

## 4. Arsitektur & Tech Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ARCHITECTURE OVERVIEW                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐     ┌───────────────┐     ┌───────────────────────┐  │
│  │  CSV Raw  │────▶│   SQL Server  │────▶│      Power BI         │  │
│  │  Dataset  │     │   Database    │     │     Dashboard         │  │
│  └──────────┘     │               │     │                       │  │
│                   │ ┌───────────┐ │     │ ┌───────────────────┐ │  │
│                   │ │ Raw Table │ │     │ │ Executive Summary │ │  │
│                   │ └─────┬─────┘ │     │ │ Temporal Analysis │ │  │
│                   │       │       │     │ │ Weather Impact    │ │  │
│                   │ ┌─────▼─────┐ │     │ │ Operational KPIs  │ │  │
│                   │ │Dim Tables │ │     │ │ Seasonal Strategy │ │  │
│                   │ └─────┬─────┘ │     │ └───────────────────┘ │  │
│                   │       │       │     │                       │  │
│                   │ ┌─────▼─────┐ │     └───────────────────────┘  │
│                   │ │Fact Table │ │                                 │
│                   │ └─────┬─────┘ │                                 │
│                   │       │       │                                 │
│                   │ ┌─────▼─────┐ │                                 │
│                   │ │  Views &  │ │                                 │
│                   │ │  Stored   │ │                                 │
│                   │ │  Procs    │ │                                 │
│                   │ └───────────┘ │                                 │
│                   └───────────────┘                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.1 Tech Stack

| Layer | Teknologi | Versi | Fungsi |
|-------|-----------|-------|--------|
| **Data Source** | CSV File | — | Raw data dari UCI |
| **Database** | SQL Server | 2019+ / Express | Backend data warehouse |
| **ETL** | SQL Scripts + BULK INSERT | — | Load & transform data |
| **Visualization** | Power BI Desktop | Latest | Dashboard & reporting |
| **Version Control** | Git | Latest | Source code management |

---

## 5. Database Schema Design

### 5.1 Star Schema (Dimensional Modeling)

Kita menggunakan **Star Schema** untuk mengoptimalkan query analitik di Power BI.

```
                    ┌──────────────┐
                    │  dim_date    │
                    │──────────────│
                    │ date_id (PK) │
                    │ full_date    │
                    │ year         │
                    │ month        │
                    │ month_name   │
                    │ day          │
                    │ day_of_week  │
                    │ day_name     │
                    │ is_weekend   │
                    │ week_number  │
                    │ quarter      │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────┴────────┐    ┌────────────────┐
│ dim_weather  │    │  fact_rental  │    │  dim_season    │
│──────────────│    │───────────────│    │────────────────│
│weather_id(PK)│◄───│rental_id (PK) │───▶│ season_id (PK) │
│temp_category │    │date_id (FK)   │    │ season_name    │
│humidity_cat  │    │hour           │    │ season_order   │
│weather_cond  │    │season_id (FK) │    └────────────────┘
└──────────────┘    │weather_id(FK) │
                    │holiday_id(FK) │    ┌────────────────┐
                    │rented_bikes   │    │ dim_holiday    │
                    │temperature    │    │────────────────│
                    │humidity       │───▶│holiday_id (PK) │
                    │wind_speed     │    │is_holiday      │
                    │visibility     │    │is_functioning  │
                    │dew_point_temp │    │day_type        │
                    │solar_radiation│    └────────────────┘
                    │rainfall       │
                    │snowfall       │    ┌────────────────┐
                    │               │    │ dim_time_slot  │
                    │time_slot_id   │───▶│────────────────│
                    │(FK)           │    │time_slot_id(PK)│
                    └───────────────┘    │hour            │
                                        │time_period     │
                                        │rush_hour_flag  │
                                        │shift           │
                                        └────────────────┘
```

### 5.2 Deskripsi Tabel

#### 5.2.1 `staging.bike_raw` — Raw/Staging Table
Tabel staging untuk menampung data CSV mentah sebelum transformasi.

```sql
-- Kolom sama persis dengan kolom CSV
-- Digunakan sebagai landing zone saat BULK INSERT
```

#### 5.2.2 `dbo.dim_date` — Dimensi Tanggal
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `date_id` | INT (PK) | Surrogate key (format YYYYMMDD) |
| `full_date` | DATE | Tanggal lengkap |
| `year` | INT | Tahun |
| `month` | INT | Bulan (1-12) |
| `month_name` | VARCHAR(20) | Nama bulan |
| `day` | INT | Hari dalam bulan |
| `day_of_week` | INT | Hari dalam minggu (1=Monday) |
| `day_name` | VARCHAR(20) | Nama hari |
| `is_weekend` | BIT | 1 jika Sabtu/Minggu |
| `week_number` | INT | Nomor minggu dalam tahun |
| `quarter` | INT | Kuartal (1-4) |

#### 5.2.3 `dbo.dim_season` — Dimensi Musim
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `season_id` | INT (PK) | 1=Spring, 2=Summer, 3=Autumn, 4=Winter |
| `season_name` | VARCHAR(20) | Nama musim |
| `season_order` | INT | Urutan kalender |

#### 5.2.4 `dbo.dim_time_slot` — Dimensi Waktu
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `time_slot_id` | INT (PK) | 0–23 |
| `hour` | INT | Jam (0-23) |
| `time_period` | VARCHAR(20) | Dawn/Morning/Afternoon/Evening/Night |
| `rush_hour_flag` | BIT | 1 jika jam sibuk (7-9, 17-19) |
| `shift` | VARCHAR(20) | Shift operasional |

#### 5.2.5 `dbo.dim_holiday` — Dimensi Hari Libur
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `holiday_id` | INT (PK) | Surrogate key |
| `is_holiday` | VARCHAR(20) | Holiday / No Holiday |
| `is_functioning` | VARCHAR(20) | Yes / No |
| `day_type` | VARCHAR(30) | Working Day / Holiday / Non-Functioning |

#### 5.2.6 `dbo.dim_weather` — Dimensi Kategori Cuaca
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `weather_id` | INT (PK) | Surrogate key |
| `temp_category` | VARCHAR(20) | Freezing/Cold/Cool/Warm/Hot |
| `humidity_category` | VARCHAR(20) | Low/Moderate/High/Very High |
| `weather_condition` | VARCHAR(30) | Clear/Rainy/Snowy/Rainy+Snowy |

#### 5.2.7 `dbo.fact_rental` — Fact Table (Tabel Fakta Utama)
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `rental_id` | INT IDENTITY (PK) | Surrogate key |
| `date_id` | INT (FK) | → dim_date |
| `time_slot_id` | INT (FK) | → dim_time_slot |
| `season_id` | INT (FK) | → dim_season |
| `holiday_id` | INT (FK) | → dim_holiday |
| `weather_id` | INT (FK) | → dim_weather |
| `rented_bike_count` | INT | Jumlah sepeda disewa |
| `temperature` | DECIMAL(5,2) | Suhu (°C) |
| `humidity` | INT | Kelembaban (%) |
| `wind_speed` | DECIMAL(5,2) | Kecepatan angin (m/s) |
| `visibility` | INT | Jarak pandang (10m) |
| `dew_point_temp` | DECIMAL(5,2) | Titik embun (°C) |
| `solar_radiation` | DECIMAL(5,2) | Radiasi matahari (MJ/m²) |
| `rainfall` | DECIMAL(5,2) | Curah hujan (mm) |
| `snowfall` | DECIMAL(5,2) | Curah salju (cm) |

---

## 6. Struktur Proyek

```
calm-carson/
│
├── 📄 README.md                          # Dokumentasi proyek
├── 📄 PRD_Seoul_Bike_Sharing_Analysis.md # Dokumen ini
│
├── 📂 data/
│   └── 📄 SeoulBikeData.csv             # Raw dataset dari UCI
│
├── 📂 sql/
│   ├── 📄 schema.sql                    # Database, staging, dimensi, fakta
│   │   # ── Create Database & Schema
│   │   # ── Staging Table (staging.bike_raw)
│   │   # ── Dimension Tables (dim_date, dim_season, dim_time_slot, dim_holiday, dim_weather)
│   │   # ── Fact Table (fact_rental)
│   │
│   ├── 📄 etl.sql                       # Load & transformasi data
│   │   # ── Bulk Insert CSV → Staging
│   │   # ── Populate Dimension Tables
│   │   # ── Populate Fact Table
│   │
│   ├── 📄 analysis.sql                  # Semua query analisis bisnis
│   │   # ── Temporal Analysis (jam, hari, bulan)
│   │   # ── Weather Impact Analysis
│   │   # ── Seasonal Analysis
│   │   # ── Operational KPIs
│   │   # ── Business Insights
│   │
│   └── 📄 views.sql                     # Semua views untuk Power BI
│       # ── vw_hourly_summary
│       # ── vw_daily_summary
│       # ── vw_monthly_summary
│       # ── vw_weather_impact
│
├── 📂 powerbi/
│   ├── 📄 Seoul_Bike_Dashboard.pbix     # File Power BI utama
│   └── 📄 powerbi_measures.md           # Dokumentasi DAX measures
│
└── 📂 docs/
    ├── 📄 data_dictionary.md             # Kamus data lengkap
    ├── 📄 analysis_findings.md           # Temuan analisis
    └── 📄 business_recommendations.md    # Rekomendasi bisnis
```

> **Catatan**: Setiap file `.sql` berisi semua script terkait dalam 1 file, dipisahkan menggunakan comment header `-- ============================================` dan `-- #` untuk memudahkan navigasi.

---

## 7. SQL Analysis Queries (Rencana)

### 7.1 Temporal Analysis (Analisis Waktu)
| Query | Tujuan Bisnis |
|-------|---------------|
| Rata-rata rental per jam | Identifikasi jam sibuk & sepi |
| Trend harian (weekday vs weekend) | Strategi armada berbeda untuk hari kerja vs akhir pekan |
| Trend bulanan | Perencanaan kapasitas bulanan |
| Perbandingan peak vs off-peak | Optimalisasi pricing dinamis |
| Hourly heatmap data | Visualisasi pola 24 jam x 7 hari |

### 7.2 Weather Impact Analysis (Analisis Cuaca)
| Query | Tujuan Bisnis |
|-------|---------------|
| Korelasi suhu vs rental | Threshold suhu optimal |
| Dampak hujan terhadap demand | Contingency planning saat hujan |
| Dampak salju terhadap demand | Strategi musim dingin |
| Humidity impact | Comfort index thresholds |
| Multi-factor weather scoring | Composite weather suitability index |

### 7.3 Operational KPIs
| KPI | Formula | Target |
|-----|---------|--------|
| **Avg Hourly Demand** | SUM(rentals) / COUNT(hours) | Baseline planning |
| **Peak Utilization Rate** | Peak_demand / Max_capacity | > 80% → perlu ekspansi |
| **Weather Sensitivity Index** | StdDev(demand) by weather_condition | Lower = better |
| **Holiday Impact Factor** | AVG(holiday_demand) / AVG(normal_demand) | Staffing guide |
| **Zero-Demand Hours** | COUNT(hours WHERE rentals = 0) | Minimize through strategy |
| **Demand Volatility** | CV (Coefficient of Variation) per time_slot | Inventory planning |

### 7.4 Business Insight Queries
| Insight | Deskripsi |
|---------|-----------|
| Top 10 demand hours | Jam dengan demand tertinggi sepanjang tahun |
| Bottom 10 demand hours | Jam dengan demand terendah — kandidat maintenance |
| Optimal operating conditions | Kombinasi cuaca ideal untuk demand maksimal |
| Revenue opportunity gaps | Jam-jam di mana supply bisa ditingkatkan |
| Seasonal transition patterns | Pola transisi antar musim |

---

## 8. Power BI Dashboard Design

### 8.1 Dashboard Pages

#### Page 1: 🏠 Executive Summary
- **KPI Cards**: Total Rentals, Avg Daily Rentals, Peak Hour, Busiest Season
- **Trend Line**: Monthly rental trend (line chart)
- **Pie Chart**: Distribusi rental per musim
- **Table**: Top 5 hari dengan demand tertinggi

#### Page 2: ⏰ Temporal Analysis
- **Heatmap**: Jam × Hari dalam seminggu (matrix visual)
- **Bar Chart**: Rata-rata rental per jam
- **Line Chart**: Weekday vs Weekend hourly pattern
- **Stacked Bar**: Distribusi time period (Dawn/Morning/Afternoon/Evening/Night)

#### Page 3: 🌦️ Weather Impact
- **Scatter Plot**: Temperature vs Rented Bike Count
- **Clustered Bar**: Demand per weather condition (Clear/Rainy/Snowy)
- **Gauge**: Weather Sensitivity Index
- **Line Chart**: Humidity vs Demand curve
- **Cards**: Optimal temperature range, Rain impact %, Snow impact %

#### Page 4: 📈 Operational Intelligence
- **Matrix**: Rush hour vs non-rush hour demand comparison
- **Waterfall Chart**: Faktor-faktor yang mempengaruhi demand
- **Funnel**: Demand breakdown by season → month → day type
- **KPI Indicators**: Utilization rate, zero-demand hours, volatility

#### Page 5: 💡 Business Recommendations
- **Slicer-driven Analysis**: Filter interaktif per musim, cuaca, hari
- **What-If Parameter**: Simulasi demand berdasarkan temperature threshold
- **Narrative Visual**: Auto-generated insight text
- **Action Table**: Rekomendasi bisnis berdasarkan data

### 8.2 DAX Measures (Key Measures)
```
Total Rentals = SUM(fact_rental[rented_bike_count])
Avg Hourly Demand = AVERAGE(fact_rental[rented_bike_count])
Peak Hour Demand = MAXX(SUMMARIZE(...), [Total Rentals])
YoY Growth = DIVIDE([Total Rentals] - [PY Total Rentals], [PY Total Rentals])
Weather Impact Score = (Rainy Avg / Overall Avg) * 100
Holiday Factor = DIVIDE([Holiday Avg], [Non-Holiday Avg])
Demand Volatility = STDEV.P(fact_rental[rented_bike_count]) / [Avg Hourly Demand]
```

---

## 9. Deliverables & Timeline

### 9.1 Deliverables
| # | Deliverable | Format | Status |
|---|-------------|--------|--------|
| 1 | PRD Document | `.md` | ✅ Selesai |
| 2 | SQL Schema (database + tabel) | `schema.sql` | ⬜ Belum |
| 3 | SQL ETL (load + transform) | `etl.sql` | ⬜ Belum |
| 4 | SQL Analysis (semua query) | `analysis.sql` | ⬜ Belum |
| 5 | SQL Views (untuk Power BI) | `views.sql` | ⬜ Belum |
| 6 | Power BI Dashboard | `.pbix` file | ⬜ Belum |
| 7 | Business Findings Report | `.md` file | ⬜ Belum |
| 8 | DAX Measures Documentation | `.md` file | ⬜ Belum |

### 9.2 Fase Implementasi
| Fase | Aktivitas | Estimasi |
|------|-----------|----------|
| **Fase 1** | Database setup: schema, staging, dimensi, fakta | ~1 hari |
| **Fase 2** | ETL: Load CSV, populate dimensi & fakta | ~1 hari |
| **Fase 3** | Analysis queries & views | ~1-2 hari |
| **Fase 4** | Power BI dashboard development | ~2-3 hari |
| **Fase 5** | Testing, dokumentasi, & finalisasi | ~1 hari |

---

## 10. Prasyarat & Setup

### 10.1 Software Requirements
| Software | Versi Minimum | Fungsi |
|----------|---------------|--------|
| SQL Server | 2019 Express / Developer | Database engine |
| SSMS | 18+ | SQL management & query |
| Power BI Desktop | Latest (free) | Visualization |
| Git | Latest | Version control |

### 10.2 Langkah Setup Awal
1. **Download Dataset** dari [UCI Repository](https://archive.ics.uci.edu/dataset/560/seoul+bike+sharing+demand)
2. **Ekstrak** file `SeoulBikeData.csv` ke folder `data/`
3. **Jalankan** SQL scripts secara berurutan (01 → 02 → 03 → 04)
4. **Buka** Power BI dan koneksikan ke SQL Server database
5. **Import** DAX measures sesuai dokumentasi

---

## 11. Key Business Questions

Analisis ini dirancang untuk menjawab pertanyaan bisnis berikut:

### 📊 Strategic Questions
1. **Kapan demand paling tinggi?** → Optimal staffing & bike distribution
2. **Bagaimana cuaca mempengaruhi penyewaan?** → Weather-responsive supply management
3. **Apakah pola weekday berbeda dengan weekend?** → Segment-specific strategies
4. **Musim mana yang paling menguntungkan?** → Seasonal revenue planning
5. **Kapan sebaiknya dilakukan maintenance?** → Minimize disruption to service

### 💰 Revenue Questions
6. **Jam berapa potensi revenue tertinggi?** → Dynamic pricing opportunities
7. **Berapa kehilangan revenue saat hujan/salju?** → Weather insurance/mitigation costs
8. **Bagaimana pola holiday vs working day?** → Special event/holiday pricing

### 🔧 Operational Questions
9. **Berapa banyak sepeda minimal dibutuhkan per jam?** → Fleet sizing
10. **Di jam berapa redistribusi sebaiknya dilakukan?** → Logistics optimization

---

## 12. Catatan & Asumsi

### 12.1 Asumsi
- Data mencakup periode 1 tahun penuh (365 hari × 24 jam = 8,760 records)
- Data tidak memiliki missing values (sebagaimana dinyatakan UCI)
- 1 record = 1 jam observasi di seluruh stasiun Seoul (aggregated)
- "Functioning Day = No" berarti layanan tidak beroperasi pada jam tersebut

### 12.2 Batasan
- Data hanya 1 tahun → tidak bisa melakukan YoY comparison
- Tidak ada data geografis (stasiun/lokasi) → tidak bisa melakukan spatial analysis
- Tidak ada data revenue/pricing → analisis finansial menggunakan proxy (count × assumed price)
- Data sudah di-aggregate per kota → tidak bisa drill-down per stasiun

### 12.3 Rekomendasi untuk Pengembangan Lanjutan
- Integrasi data real-time dari API bike sharing
- Penambahan data lokasi stasiun untuk geospatial analysis
- Machine learning model untuk demand forecasting
- Integration dengan data transportasi publik lainnya

---

## 13. Referensi

- Seoul Bike Sharing Demand [Dataset]. (2020). UCI Machine Learning Repository. https://doi.org/10.24432/C5F62R
- Sathishkumar V E, Jangwoo Park, and Yongyun Cho. 'Using data mining techniques for bike sharing demand prediction in metropolitan city.' Computer Communications, Vol.153, pp.353-366, March, 2020.
- Sathishkumar V E and Yongyun Cho. 'A rule-based model for Seoul Bike sharing demand prediction using weather data.' European Journal of Remote Sensing, pp. 1-18, Feb, 2020.

---

> **Dokumen ini adalah living document. Akan diperbarui seiring perkembangan proyek.**

---

*Dibuat oleh: Data Analytics Team*
*Terakhir diperbarui: 2 Juni 2026*
