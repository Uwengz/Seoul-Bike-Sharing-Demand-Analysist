<p align="center">
  <img src="https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white" alt="SQL Server"/>
  <img src="https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" alt="Power BI"/>
  <img src="https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=powerbi&logoColor=white" alt="DAX"/>
  <img src="https://img.shields.io/badge/T--SQL-4479A1?style=for-the-badge&logo=database&logoColor=white" alt="T-SQL"/>
  <img src="https://img.shields.io/badge/Star_Schema-Kimball-orange?style=for-the-badge" alt="Star Schema"/>
  <img src="https://img.shields.io/badge/License-CC_BY_4.0-lightgrey?style=for-the-badge" alt="License"/>
</p>

<h1 align="center">Seoul Bike Sharing Demand Analytics</h1>

<p align="center">
  <b>End-to-End Data Analytics Pipeline</b><br>
  Raw CSV → SQL Server Star Schema → Power BI Interactive Dashboard → Business Insights
</p>

<p align="center">
  <a href="#1-project-overview">Overview</a> •
  <a href="#2-dataset">Dataset</a> •
  <a href="#3-technology-used">Tech Stack</a> •
  <a href="#4-repository-structure">Structure</a> •
  <a href="#5-pipeline-architecture">Architecture</a> •
  <a href="#6-chapter-1--sql-server-data-engineering">SQL</a> •
  <a href="#7-chapter-2--power-bi-data-visualization">Power BI</a> •
  <a href="#8-key-findings--business-insights">Insights</a> •
  <a href="#11-how-to-reproduce">Reproduce</a>
</p>

---

## 1. Project Overview

### 1.1 Deskripsi Proyek

Proyek ini merupakan implementasi **data analytics pipeline end-to-end** yang menganalisis pola permintaan (*demand*) layanan penyewaan sepeda di kota Seoul, Korea Selatan. Pipeline ini memproses data mentah (CSV) melalui SQL Server, mentransformasikannya ke dalam arsitektur *Star Schema*, memvisualisasikannya menjadi dashboard interaktif di Power BI, dan menghasilkan *actionable recommendations* yang dapat ditindaklanjuti oleh *stakeholder* operasional.

Proyek ini mencakup empat area kompetensi utama dalam *data analytics*:

| Area | Cakupan | Tools |
|------|---------|-------|
| **Data Engineering** | Perancangan arsitektur *Star Schema*, pembangunan proses ETL (*Extract, Transform, Load*), serta pembuatan *analytical views* | SQL Server, T-SQL |
| **Data Analysis** | Eksekusi 25 *business analysis queries* untuk menggali *insight* dari dimensi temporal, cuaca, musiman, dan operasional | T-SQL |
| **Data Visualization** | Pembangunan dashboard interaktif 5 halaman dengan 64 DAX *measures* yang mendukung *filtering* dinamis | Power BI Desktop, DAX |
| **Business Intelligence** | Penyusunan laporan analisis bisnis lengkap beserta rekomendasi strategis berbasis data | Markdown Report |

### 1.2 Konteks Bisnis

*Bike sharing* merupakan moda transportasi perkotaan (*urban transportation*) yang semakin vital dalam ekosistem mobilitas kota-kota besar. Sistem ini memungkinkan pengguna menyewa sepeda dari satu stasiun dan mengembalikannya di stasiun lain, berfungsi sebagai solusi *last-mile transportation* yang efisien dan ramah lingkungan.

Dalam operasionalnya, pengelola layanan *bike sharing* menghadapi tiga tantangan bisnis utama yang secara langsung memengaruhi profitabilitas dan kepuasan pengguna:

| Tantangan | Deskripsi | Dampak Bisnis |
|-----------|-----------|---------------|
| **Under-supply** | Ketidaktersediaan unit sepeda pada periode *demand* tinggi, misalnya jam pulang kerja (18:00) di musim panas. | Kehilangan *revenue* secara langsung, penurunan *customer satisfaction*, dan potensi *churn* pengguna ke moda transportasi alternatif. |
| **Over-supply** | Kelebihan unit sepeda yang tidak terpakai pada periode *demand* rendah, misalnya dini hari (03:00) di musim dingin. | Pembengkakan biaya operasional akibat *maintenance* unit *idle*, biaya redistribusi yang tidak efisien, serta depresiasi aset. |
| **Absence of Data-Driven Forecasting** | Ketiadaan sistem prediksi berbasis data untuk perencanaan distribusi armada dan penjadwalan sumber daya. | Pengambilan keputusan bersifat reaktif, bukan proaktif. Inefisiensi operasional yang berulang secara sistemik. |

Proyek ini menjawab ketiga tantangan tersebut melalui analisis terhadap **8.760 observasi per jam** (365 hari × 24 jam) untuk mengidentifikasi pola *demand*, mengukur faktor-faktor penentu, serta menghasilkan rekomendasi strategis yang terukur.

### 1.3 Tujuan Analisis

| # | Tujuan | Deskripsi | Halaman Dashboard |
|---|--------|-----------|-------------------|
| 1 | **Demand Pattern Analysis** | Identifikasi pola permintaan berdasarkan dimensi waktu: jam, hari, bulan, dan musim. | Page 1 & 2 |
| 2 | **Weather Impact Assessment** | Pengukuran kuantitatif pengaruh kondisi cuaca (suhu, curah hujan, curah salju, kelembaban) terhadap volume penyewaan. | Page 3 |
| 3 | **Operational Optimization** | Identifikasi *peak hours* dan *off-peak hours* untuk optimalisasi distribusi armada serta penjadwalan staf. | Page 4 |
| 4 | **Seasonal Revenue Planning** | Penyusunan rekomendasi strategi musiman untuk *pricing*, promosi, dan *fleet management*. | Page 5 |
| 5 | **Maintenance Scheduling** | Penentuan *window* waktu optimal untuk *maintenance* dengan dampak minimal terhadap layanan. | Page 4 & 5 |

---

## 2. Dataset

### 2.1 Latar Belakang

#### Seoul Bike Sharing System — Ttareungyi (따릉이)

Seoul, ibu kota Korea Selatan dengan populasi sekitar 9,7 juta jiwa, mengoperasikan sistem *bike sharing* publik bernama **Ttareungyi (따릉이)**. Sistem ini diluncurkan pada tahun 2015 oleh Seoul Metropolitan Government dan menyediakan unit sepeda sewaan di ratusan *docking station* yang tersebar di seluruh kota — meliputi area stasiun kereta bawah tanah (*subway*), halte bus, kawasan perkantoran, taman publik, serta area wisata di sepanjang Sungai Han (*Hangang*).

Ttareungyi dirancang sebagai solusi *last-mile transportation*, yaitu menjembatani jarak antara stasiun transit (kereta/bus) dengan destinasi akhir pengguna. Sistem ini beroperasi 24 jam, 7 hari dalam seminggu, dan dapat diakses oleh seluruh kalangan — baik warga lokal maupun wisatawan — melalui aplikasi *mobile* atau kartu keanggotaan.

#### Signifikansi Dataset untuk Analisis

Dataset ini memiliki beberapa karakteristik yang menjadikannya relevan untuk analisis bisnis:

1. **Kelengkapan temporal yang tinggi**: Data mencakup **setiap jam** selama **satu tahun penuh** (8.760 observasi), memungkinkan analisis pola pada berbagai level granularity — dari per jam, per hari, per minggu, per bulan, hingga per musim.

2. **Variasi iklim yang signifikan**: Seoul memiliki empat musim dengan perbedaan kondisi cuaca yang ekstrem — musim panas dengan suhu mencapai 39.4°C dan musim dingin dengan suhu turun hingga -17.8°C disertai curah salju. Variasi ini menyediakan *range* data yang luas untuk menganalisis korelasi cuaca terhadap *demand*.

3. **Integritas data**: Dataset tidak memiliki *missing values* (nol *null/NA*), sehingga tidak diperlukan tahap *imputation* yang berpotensi mengurangi keandalan hasil analisis.

4. **Relevansi bisnis langsung**: Pola yang teridentifikasi dari dataset ini dapat diterjemahkan secara langsung menjadi keputusan operasional — meliputi *fleet sizing*, *pricing strategy*, *maintenance scheduling*, dan *promotional campaign planning*.

#### Sumber dan Kredibilitas

Dataset ini dipublikasikan melalui **UCI Machine Learning Repository**, salah satu repositori dataset paling terkemuka di dunia yang dikelola oleh University of California, Irvine. Dataset dikontribusikan oleh peneliti **Sathishkumar V E** dan **Yongyun Cho**, serta telah digunakan dan direferensikan dalam beberapa publikasi ilmiah *peer-reviewed*.

### 2.2 Informasi Umum

| Atribut | Detail |
|---------|--------|
| **Nama** | Seoul Bike Sharing Demand |
| **Sumber** | [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/560/seoul+bike+sharing+demand) |
| **DOI** | [10.24432/C5F62R](https://doi.org/10.24432/C5F62R) |
| **File** | `SeoulBikeData.csv` (590 KB) |
| **Jumlah Baris** | 8.760 (1 baris = 1 observasi per jam) |
| **Jumlah Kolom** | 14 |
| **Periode** | 1 Desember 2017 – 30 November 2018 (365 hari) |
| **Granularity** | Per jam (*hourly*) |
| **Missing Values** | 0 |
| **Lisensi** | CC BY 4.0 (Creative Commons Attribution 4.0 International) |

### 2.3 Data Dictionary

#### Target Variable

| Kolom | Tipe | Satuan | Range | Deskripsi |
|-------|------|--------|-------|-----------|
| `Rented Bike Count` | Integer | unit | 0 – 3.556 | Jumlah unit sepeda yang disewa pada jam pencatatan. Merupakan **variabel utama** yang dianalisis dalam seluruh pipeline. Nilai 0 mengindikasikan tidak adanya aktivitas penyewaan, umumnya terjadi pada dini hari atau saat kondisi cuaca ekstrem. |

#### Feature Variables — Temporal

| Kolom | Tipe | Satuan | Range | Deskripsi |
|-------|------|--------|-------|-----------|
| `Date` | Date | DD/MM/YYYY | 01/12/2017 – 30/11/2018 | Tanggal pencatatan dalam format DD/MM/YYYY. Dalam proses ETL, kolom ini di-*parse* untuk mengekstrak atribut turunan: tahun, bulan, nama bulan, hari, nama hari, dan status *weekend*. |
| `Hour` | Integer | jam | 0 – 23 | Jam pencatatan dalam format 24 jam. Kolom ini merupakan salah satu *predictor* terkuat terhadap *demand*, mengingat pola penyewaan sangat bervariasi berdasarkan jam (*bimodal distribution* pada hari kerja). |

#### Feature Variables — Meteorologis

| Kolom | Tipe | Satuan | Range | Deskripsi |
|-------|------|--------|-------|-----------|
| `Temperature` | Float | °C | -17.8 – 39.4 | Suhu udara. Range yang luas mencerminkan iklim empat musim Seoul. Suhu di bawah 0°C secara konsisten menghasilkan *demand* mendekati nol. |
| `Humidity` | Integer | % | 0 – 98 | Kelembaban udara relatif. Nilai di atas 80% umumnya berkorelasi dengan kondisi cuaca lembab atau presipitasi, yang menurunkan *demand* secara signifikan. |
| `Wind speed` | Float | m/s | 0 – 7.4 | Kecepatan angin. Kecepatan tinggi mengurangi kenyamanan dan keselamatan bersepeda. |
| `Visibility` | Integer | 10m | 27 – 2.000 | Jarak pandang. Nilai rendah mengindikasikan kabut atau polusi udara yang berdampak pada keselamatan bersepeda. |
| `Dew point temperature` | Float | °C | -30.6 – 27.2 | Suhu titik embun. Nilai yang mendekati suhu udara aktual mengindikasikan kelembaban tinggi dan potensi presipitasi. |
| `Solar Radiation` | Float | MJ/m² | 0 – 3.52 | Intensitas radiasi matahari. Nilai tinggi menandakan kondisi cerah; nilai 0 pada periode malam atau cuaca mendung tebal. |
| `Rainfall` | Float | mm | 0 – 35 | Curah hujan per jam. Nilai > 0 menandakan terjadinya presipitasi hujan. Merupakan salah satu faktor paling signifikan terhadap penurunan *demand*. |
| `Snowfall` | Float | cm | 0 – 8.8 | Curah salju per jam. Terjadi pada periode musim dingin (Desember–Februari). Dampaknya terhadap penurunan *demand* lebih besar dibandingkan hujan. |

#### Feature Variables — Kategorikal

| Kolom | Tipe | Nilai | Deskripsi |
|-------|------|-------|-----------|
| `Seasons` | Categorical | `Spring`, `Summer`, `Autumn`, `Winter` | Musim pada saat pencatatan. Korea Selatan memiliki empat musim yang jelas: Spring (Maret–Mei), Summer (Juni–Agustus), Autumn (September–November), Winter (Desember–Februari). |
| `Holiday` | Categorical | `Holiday`, `No Holiday` | Status hari libur nasional Korea Selatan. Berpengaruh terhadap pola *demand* karena absennya kebutuhan *commuting*. |
| `Functioning Day` | Categorical | `Yes`, `No` | Status operasional sistem. Nilai `No` menandakan layanan tidak beroperasi (misalnya akibat *maintenance* massal atau kondisi darurat cuaca), yang menjadikan `Rented Bike Count` bernilai 0. |

---

## 3. Technology Used

| Kategori | Teknologi | Versi | Peran dalam Pipeline |
|----------|-----------|-------|---------------------|
| **Database** | Microsoft SQL Server | 2019+ | *Data warehouse* backend menggunakan arsitektur *Star Schema*. Menyimpan, memproses, dan menganalisis data. |
| **IDE SQL** | SQL Server Management Studio (SSMS) | 19.x | Antarmuka pengembangan untuk penulisan dan eksekusi *scripts* T-SQL. |
| **Visualization** | Microsoft Power BI Desktop | 2026 | Pembangunan dashboard interaktif 5 halaman dengan *Import Mode* dari SQL Server. |
| **Query Language** | T-SQL (Transact-SQL) | — | Bahasa SQL native Microsoft untuk DDL, DML, *views*, dan *analytical queries*. |
| **Measure Language** | DAX (Data Analysis Expressions) | — | Bahasa formula Power BI untuk *calculated columns*, *measures*, dan KPI computation. |
| **Data Modeling** | Star Schema (Kimball methodology) | — | Arsitektur dimensional yang memisahkan *fact table* dan *dimension tables* untuk performa *analytical queries* yang optimal. |
| **Version Control** | Git / GitHub | — | Manajemen kode sumber, dokumentasi, dan *version history*. |

### Justifikasi Pemilihan Teknologi

| Keputusan | Justifikasi |
|-----------|------------|
| **SQL Server** vs PostgreSQL/MySQL | Integrasi native dengan Power BI (ekosistem Microsoft), dukungan `BULK INSERT` untuk *high-performance data loading*, serta fitur T-SQL yang komprehensif untuk transformasi data. |
| **Star Schema** vs *flat table* | Pemisahan *measures* dan *dimensions* mengoptimalkan performa *analytical queries*, menyederhanakan model data, serta memaksimalkan kompatibilitas dengan Power BI *relationships* dan DAX. |
| **Power BI** vs Tableau/Looker | Integrasi superior dengan SQL Server, dukungan DAX untuk kalkulasi bisnis kompleks, serta *Import Mode* yang memungkinkan distribusi dashboard tanpa dependensi koneksi database. |
| **Import Mode** vs DirectQuery | Data ter-*embed* dalam file `.pbix`, memungkinkan eksplorasi dashboard tanpa memerlukan SQL Server aktif — esensial untuk distribusi dan *review* oleh pihak eksternal. |

---

## 4. Repository Structure

```
seoul-bike-sharing-analytics/
│
├── data/
│   └── SeoulBikeData.csv                       # Raw dataset (UCI Repository, 590 KB, 8.760 baris)
│
├── sql/
│   ├── schema.sql                              # [Step 1] DDL — Database, staging, dimension & fact tables
│   ├── etl.sql                                 # [Step 2] ETL — BULK INSERT, cleansing, categorization, loading
│   ├── views.sql                               # [Step 3] 5 analytical views
│   └── analysis.sql                            # [Step 4] 25 business analysis queries
│
├── powerbi/
│   ├── Seoul Bike Sharing Demand.pbix          # Dashboard interaktif (5 halaman, data embedded)
│   └── powerbi_measures.md                     # Dokumentasi 64 DAX measures & visualization blueprint
│
├── docs/
│   └── Business_Analyst_Report.md              # Laporan analisis bisnis & 10 jawaban strategis
│
├── Seoul Bike Sharing Demand Dashboard.pdf     # Ekspor PDF dashboard
├── PRD_Seoul_Bike_Sharing_Analysis.md          # Product Requirements Document
└── README.md                                   # Dokumentasi proyek
```

### Deskripsi File

| File | Ukuran | Deskripsi |
|------|--------|-----------|
| `SeoulBikeData.csv` | 590 KB | Dataset mentah dari UCI Repository. 14 kolom, 8.760 baris observasi per jam. Titik awal seluruh pipeline. |
| `schema.sql` | 9.5 KB (258 baris) | Pembuatan database `SeoulBikeAnalytics`, schema `staging`, *staging table* (`bike_raw`), 5 *dimension tables*, dan 1 *fact table* dengan *foreign key constraints* serta *nonclustered indexes*. |
| `etl.sql` | 13.5 KB (436 baris) | Proses ETL lengkap: `BULK INSERT` CSV ke *staging*, populasi 5 *dimension tables* dengan logika kategorisasi, dan populasi *fact table* melalui `JOIN` ke seluruh dimensi. Dirancang *idempotent*. |
| `views.sql` | 9.9 KB (297 baris) | Pembuatan 5 *analytical views*: `vw_full_detail` (denormalized), `vw_hourly_summary`, `vw_daily_summary`, `vw_monthly_summary`, dan `vw_weather_impact`. |
| `analysis.sql` | 22.5 KB (604 baris) | 25 *business analysis queries* dalam 5 section: Temporal (6), Weather (5), Seasonal (3), Operational (4), Business Insights (7). |
| `powerbi_measures.md` | 24 KB | Dokumentasi teknis 64 DAX measures (32 *calculation* + 32 *display*), 4 *calculated columns*, *sorting guide*, dan *visualization blueprint*. |
| `Business_Analyst_Report.md` | 28 KB | Laporan analisis bisnis komprehensif: *insight* per halaman dashboard dan jawaban terhadap 10 pertanyaan strategis. |
| `.pbix` | 547 KB | File Power BI Desktop dengan dashboard interaktif 5 halaman. Data ter-*embed* melalui *Import Mode*. |
| `.pdf` | 930 KB | Ekspor PDF dashboard untuk *preview* tanpa instalasi Power BI Desktop. |

---

## 5. Pipeline Architecture

### 5.1 Diagram Alur Data

```
  DATA SOURCE                    SQL SERVER (Backend)                      POWER BI (Frontend)
  ────────────                   ────────────────────                      ───────────────────

  ┌──────────────┐
  │ SeoulBike    │
  │ Data.csv     │    BULK INSERT     ┌─────────────────────────┐
  │              │ ──────────────────→│  staging.bike_raw       │
  │ 8,760 rows   │                    │  (8,760 rows, raw)      │
  │ 14 columns   │                    └───────────┬─────────────┘
  └──────────────┘                                │
                                    TRANSFORM     │
                                    & LOAD        │
                                                  ▼
                                    ┌─────────────────────────────────┐
                                    │       STAR SCHEMA               │
                                    │                                 │
                                    │  dim_date (365) ────┐           │
                                    │  dim_time_slot (24) ┤           │
                                    │  dim_season (4)  ───┼→ fact_rental (8,760)
                                    │  dim_holiday (4) ───┤           │
                                    │  dim_weather (~50) ─┘           │
                                    │                                 │
                                    └────────────┬────────────────────┘
                                                 │
                                    CREATE VIEWS  │
                                                  ▼
                                    ┌─────────────────────────────────┐
                                    │  vw_full_detail (denormalized)  │
                                    │  vw_hourly_summary (24 rows)   │──── Import Mode ────→ ┌──────────────────┐
                                    │  vw_daily_summary (365 rows)   │                       │  POWER BI        │
                                    │  vw_monthly_summary (12 rows)  │                       │                  │
                                    │  vw_weather_impact (~50 rows)  │                       │  64 DAX Measures  │
                                    └────────────┬────────────────────┘                       │  4 Calc Columns  │
                                                 │                                           │                  │
                                    25 Analysis   │                                           │  5-Page Dashboard│
                                    Queries       ▼                                           │  43 Visuals      │
                                    ┌─────────────────────────────────┐                       └────────┬─────────┘
                                    │  Business Analysis Results      │                                │
                                    └─────────────────────────────────┘                                ▼
                                                                                              ┌──────────────────┐
                                                                                              │  OUTPUT          │
                                                                                              │                  │
                                                                                              │  • BA Report     │
                                                                                              │  • Recommendations│
                                                                                              │  • Revenue Est.  │
                                                                                              └──────────────────┘
```

### 5.2 Deskripsi Layer

| Layer | File Terkait | Input | Output | Proses |
|-------|-------------|-------|--------|--------|
| **Data Source** | `SeoulBikeData.csv` | — | CSV 590 KB | Dataset mentah dari UCI Repository, tanpa *missing values*. |
| **Staging** | `schema.sql`, `etl.sql` | CSV | `staging.bike_raw` | `BULK INSERT` ke SQL Server. Data belum ditransformasi. |
| **Star Schema** | `schema.sql`, `etl.sql` | Staging | 5 Dimensions + 1 Fact | Transformasi: *date parsing*, klasifikasi jam, kategorisasi cuaca, *mapping* dimensi via `JOIN`. |
| **Views** | `views.sql` | Star Schema | 5 Views | Pre-agregasi pada berbagai level granularity dan denormalisasi untuk kemudahan akses. |
| **Analysis** | `analysis.sql` | Views + Star Schema | 25 Query Results | Eksekusi *analytical queries* untuk menggali *insight* bisnis. |
| **Visualization** | `.pbix` | Views (Import) | Dashboard 5 halaman | Visualisasi interaktif dengan 64 DAX measures dan 43 *visual elements*. |
| **Output** | `.md` reports | Dashboard + Analysis | Laporan bisnis | Dokumentasi temuan, *insight*, dan rekomendasi strategis. |

---

## 6. Chapter 1 — SQL Server: Data Engineering

### 6.1 Database Design: Star Schema

Proyek ini menerapkan arsitektur **Star Schema** berdasarkan metodologi Kimball. Arsitektur ini memisahkan data ke dalam dua kategori tabel:

- **Fact Table** — menyimpan data transaksional/event numerik yang menjadi subjek analisis. Dalam konteks ini, `fact_rental` menyimpan observasi penyewaan per jam beserta seluruh *measures* numerik (jumlah penyewaan, suhu, kelembaban, dan sebagainya).

- **Dimension Tables** — menyimpan atribut deskriptif yang digunakan untuk *filtering*, *grouping*, dan *slicing* data pada *fact table*. Contoh: `dim_date` menyimpan atribut tanggal (bulan, hari, status *weekend*), `dim_weather` menyimpan kategori cuaca.

#### Justifikasi Penggunaan Star Schema

| Aspek | Justifikasi |
|-------|------------|
| **Query Performance** | *Dimension tables* berukuran kecil dan ter-*index*, mempercepat operasi `GROUP BY`, `SUM`, dan `AVG`. |
| **Model Clarity** | Setiap dimensi memiliki peran semantik yang jelas, memudahkan pemahaman model data. |
| **Power BI Compatibility** | Power BI dirancang untuk bekerja optimal dengan *star schema* — *relationships*, *slicers*, dan DAX memanfaatkan pemisahan *fact/dimension*. |
| **Extensibility** | Penambahan dimensi baru (misalnya `dim_station`) dapat dilakukan tanpa modifikasi *fact table*. |
| **Maintainability** | Perubahan logika kategorisasi cukup dilakukan pada *dimension table*, tanpa memengaruhi dataset utama. |

#### Entity Relationship Diagram

```
                    ┌──────────────────┐
                    │    dim_date       │
                    │──────────────────│
                    │ date_id (PK)     │
                    │ full_date        │
                    │ year, month      │
                    │ month_name       │
                    │ day, day_of_week │
                    │ day_name         │
                    │ is_weekend       │
                    │ week_number      │
                    │ quarter          │
                    └────────┬─────────┘
                             │ FK
┌──────────────┐    ┌────────┴────────────────────┐    ┌──────────────────┐
│ dim_season   │    │       fact_rental            │    │ dim_time_slot    │
│──────────────│    │────────────────────────────│    │──────────────────│
│season_id (PK)│◄───│ rental_id (PK, IDENTITY)   │───►│time_slot_id (PK) │
│ season_name  │ FK │ date_id (FK)               │ FK │ hour (0–23)      │
│ season_order │    │ time_slot_id (FK)          │    │ time_period      │
└──────────────┘    │ season_id (FK)             │    │ rush_hour_flag   │
                    │ holiday_id (FK)            │    │ shift            │
┌──────────────┐    │ weather_id (FK)            │    └──────────────────┘
│ dim_holiday  │    │────────────────────────────│
│──────────────│    │ rented_bike_count  (INT)   │
│holiday_id(PK)│◄───│ temperature        (DEC)   │
│ is_holiday   │ FK │ humidity           (INT)   │
│is_functioning│    │ wind_speed         (DEC)   │
│ day_type     │    │ visibility         (INT)   │
└──────────────┘    │ dew_point_temp     (DEC)   │
                    │ solar_radiation    (DEC)   │
┌──────────────┐    │ rainfall           (DEC)   │
│ dim_weather  │    │ snowfall           (DEC)   │
│──────────────│    └─────────────────────────────┘
│weather_id(PK)│◄─── FK
│temp_category │
│humidity_cat  │
│weather_cond  │
└──────────────┘
```

#### Spesifikasi Tabel

| Tabel | Tipe | Rows | Columns | Deskripsi |
|-------|------|------|---------|-----------|
| `staging.bike_raw` | Staging | 8.760 | 14 | *Landing zone* untuk data mentah CSV. Kolom dan format identik dengan sumber asli. Di-*truncate* pada setiap eksekusi ETL. |
| `dbo.dim_date` | Dimension | 365 | 10 | Satu baris per tanggal. Atribut turunan: tahun, bulan, nama bulan, hari, nama hari, status *weekend*, nomor minggu, *quarter*. Surrogate key menggunakan format YYYYMMDD. |
| `dbo.dim_time_slot` | Dimension | 24 | 5 | Satu baris per jam (0–23). Klasifikasi: `time_period` (Dawn/Morning/Afternoon/Evening/Night), `rush_hour_flag` (jam 7–9 dan 17–19), `shift` (Day/Evening/Night Shift). |
| `dbo.dim_season` | Dimension | 4 | 3 | Data statis: Spring, Summer, Autumn, Winter. Kolom `season_order` untuk *sorting* pada Power BI. |
| `dbo.dim_holiday` | Dimension | 4 | 4 | Kombinasi unik `Holiday` × `Functioning Day`. Derivasi `day_type`: Working Day, Holiday, atau Non-Functioning. |
| `dbo.dim_weather` | Dimension | ~50 | 4 | Kombinasi unik tiga kategori cuaca yang di-*derive* saat ETL: `temp_category`, `humidity_category`, `weather_condition`. |
| `dbo.fact_rental` | Fact | 8.760 | 14 | Tabel utama. Satu baris per jam observasi. 9 *measures* numerik dan 5 *foreign keys*. *Nonclustered indexes* pada setiap FK. |

### 6.2 Proses ETL

ETL (*Extract, Transform, Load*) merupakan tahapan pemrosesan data dari sumber mentah ke struktur analitik. Proses ini diimplementasikan dalam file `etl.sql` dan dirancang *idempotent* — dapat dieksekusi berulang kali tanpa menghasilkan duplikasi data atau error.

| Step | Proses | Deskripsi | Justifikasi |
|------|--------|-----------|------------|
| **1** | **Cleanup** | `TRUNCATE` pada `fact_rental` terlebih dahulu, dilanjutkan ke seluruh *dimension tables*. Reset *identity counter* via `DBCC CHECKIDENT`. | Urutan *truncate* (fact sebelum dimension) diperlukan karena adanya *foreign key constraint*. Pendekatan ini memastikan *idempotency*. |
| **2** | **BULK INSERT** | Pemuatan 8.760 baris dari CSV ke `staging.bike_raw` dengan opsi `FORMAT = 'CSV'`, `FIRSTROW = 2`, `CODEPAGE = '65001'`, dan `TABLOCK`. | `BULK INSERT` memberikan performa *loading* tertinggi dibandingkan metode alternatif (`INSERT INTO ... VALUES`, *import wizard*). |
| **3** | **Populate dim_season** | Insersi 4 baris statis: Spring (1), Summer (2), Autumn (3), Winter (4). | Kolom `season_order` memungkinkan *sorting* kronologis pada Power BI. |
| **4** | **Populate dim_time_slot** | Generasi 24 baris (jam 0–23) dengan logika `CASE WHEN` untuk: `time_period` (Dawn 0–5, Morning 6–11, Afternoon 12–15, Evening 16–20, Night 21–23), `rush_hour_flag` (jam 7–9 dan 17–19), `shift` (Night 0–5, Day 6–15, Evening 16–23). | Kategorisasi jam ke dalam *time period*, *rush hour*, dan *shift* memungkinkan pengelompokan data yang bermakna secara operasional. |
| **5** | **Populate dim_date** | Ekstraksi tanggal unik dari staging, *parsing* format DD/MM/YYYY via `TRY_CONVERT`, dan derivasi atribut melalui `DATEPART` dan `DATENAME`. Konfigurasi `SET DATEFIRST 1` (Senin = 1). | Format DD/MM/YYYY memerlukan *parsing* eksplisit. Konfigurasi `DATEFIRST` diperlukan karena *default* SQL Server menggunakan Minggu = 1. |
| **6** | **Populate dim_holiday** | Ekstraksi kombinasi unik `Holiday` × `Functioning Day` dan derivasi `day_type` via `CASE WHEN`: `Functioning Day = 'No'` → Non-Functioning, `Holiday = 'Holiday'` → Holiday, lainnya → Working Day. | Penggabungan dua kolom terpisah menjadi satu kolom `day_type` yang semantik menyederhanakan analisis dan visualisasi. |
| **7** | **Populate dim_weather** | Kategorisasi berdasarkan tiga dimensi: `temp_category` (< 0°C: Freezing, 0–10: Cold, 10–20: Cool, 20–30: Warm, > 30: Hot), `humidity_category` (< 40%: Low, 40–60: Moderate, 60–80: High, > 80%: Very High), `weather_condition` (Clear / Rainy / Snowy / Rainy & Snowy). | Konversi nilai numerik mentah ke kategori deskriptif memungkinkan pengelompokan visual dan analisis yang lebih interpretatif. |
| **8** | **Populate fact_rental** | `JOIN` staging dengan seluruh *dimension tables* berdasarkan *business keys*, kemudian `INSERT` *measures* numerik dan *foreign keys*. | Tahap final yang menghubungkan data transaksional dengan model dimensional, mengaktifkan seluruh kapabilitas analitik *star schema*. |

### 6.3 Analytical Views

Lima *views* dibuat untuk menyederhanakan akses data dan menyediakan agregasi pada berbagai level granularity:

| View | Granularity | Rows | Deskripsi | Penggunaan |
|------|-------------|------|-----------|-----------|
| `vw_full_detail` | Per jam | 8.760 | `JOIN` seluruh *fact* dan 5 *dimensions* menjadi satu tabel *denormalized*. | Sumber data utama di Power BI untuk sebagian besar visualisasi dan *measures*. |
| `vw_hourly_summary` | Per jam (agregat) | 24 | `GROUP BY hour` — `AVG`, `SUM`, `MIN`, `MAX`, `STDEV` per jam. | Identifikasi *peak/off-peak hours*; Power BI *bar charts*. |
| `vw_daily_summary` | Per hari | 365 | `GROUP BY date` — ringkasan harian termasuk cuaca, musim, dan *day type*. | Tabel Top 5 Days; analisis harian. |
| `vw_monthly_summary` | Per bulan | 12 | `GROUP BY month` — tren bulanan termasuk *zero demand hours* dan curah presipitasi. | *Line chart* tren bulanan; perencanaan kapasitas. |
| `vw_weather_impact` | Per kategori cuaca | ~50 | `GROUP BY weather categories` — dampak per kombinasi cuaca termasuk *coefficient of variation*. | Scatter plot, *bar charts* cuaca; analisis sensitivitas. |

### 6.4 Business Analysis Queries

25 *queries* analisis bisnis diorganisasikan dalam 5 section:

| Section | Queries | Fokus |
|---------|---------|-------|
| **1. Temporal Analysis** | 6 | Pola per jam, weekday vs weekend, *heatmap* 7×24, tren bulanan, *peak vs off-peak*, perbedaan pola jam weekday/weekend. |
| **2. Weather Impact** | 5 | Dampak suhu, hujan, humidity, *temperature bins* per 5°C, *multi-factor weather scoring*. |
| **3. Seasonal Analysis** | 3 | *Demand* per musim, pola jam per musim, *seasonal transition* (MoM *change*). |
| **4. Operational KPIs** | 4 | Overview KPI, *holiday impact factor*, distribusi per shift, *weather sensitivity index*. |
| **5. Business Insights** | 7 | Top 10 hari tersibuk/tersepi, *optimal operating conditions*, *low-demand hours*, *revenue loss estimation*, *maintenance windows*. |

---

## 7. Chapter 2 — Power BI: Data Visualization

### 7.1 Konfigurasi Koneksi Data

| Parameter | Nilai |
|-----------|-------|
| **Connection Type** | SQL Server |
| **Server** | `localhost` |
| **Database** | `SeoulBikeAnalytics` |
| **Authentication** | Windows Authentication |
| **Data Connectivity Mode** | Import (data ter-*embed* dalam file `.pbix`) |

Penggunaan *Import Mode* memungkinkan file `.pbix` didistribusikan dan dibuka tanpa dependensi terhadap SQL Server yang aktif.

### 7.2 DAX Measures: Arsitektur Dual

Proyek ini menerapkan sistem **dual measure** untuk mengatasi keterbatasan *formatting* pada Power BI Card Visual:

| Tipe | Jumlah | Output | Penggunaan |
|------|--------|--------|-----------|
| **Calculation Measure** | 32 | Numerik (contoh: `12.8`) | *Chart axes*, *values*, *conditional formatting*, *filter* |
| **Display Measure** | 32 | String berformat (contoh: `"12.8 °C"`) | *Card visual* — menampilkan angka dengan *suffix/prefix* yang informatif |

Pendekatan ini diperlukan karena Power BI *Card Visual* tidak menyediakan opsi *suffix* bawaan. Versi *Display* menggunakan `FORMAT()` untuk menambahkan satuan, sementara versi *Calculation* tetap tersedia sebagai tipe numerik untuk operasi matematis pada *charts*.

Dokumentasi teknis lengkap seluruh 64 *measures* tersedia pada [`powerbi/powerbi_measures.md`](powerbi/powerbi_measures.md).

### 7.3 Spesifikasi Dashboard per Halaman

#### Page 1: Executive Summary

Menyajikan gambaran menyeluruh kinerja tahunan sistem *bike sharing*.

| Visual | Komponen | Data yang Ditampilkan |
|--------|---------|----------------------|
| 4× KPI Card | Total Rentals, Avg Daily, Peak Hour, Busiest Season | Metrik kinerja tahunan: **6.172.314 trips**, **16.910/hari**, puncak pukul **18:00**, musim tersibuk **Summer**. |
| Line Chart | `month_name` × `Total Rentals` | Tren rental bulanan — kurva *bell-shaped* dengan puncak di bulan Juni. |
| Donut Chart | `season_name` × `Total Rentals` | Distribusi persentase rental per musim. Summer: 37%, Autumn: 29%, Spring: 26%, Winter: 8%. |
| Table | `vw_daily_summary` (Top 5 filter) | Lima hari dengan *demand* tertinggi — seluruhnya Working Day di bulan Juni dengan suhu 26–28°C. |

#### Page 2: Temporal Analysis

Analisis mendalam pola *demand* berdasarkan dimensi waktu.

| Visual | Komponen | Data yang Ditampilkan |
|--------|---------|----------------------|
| 3× KPI Card | Weekday Avg, Weekend Avg, Rush Hour % | Perbandingan rata-rata per jam antara hari kerja dan akhir pekan, serta proporsi *demand* pada jam sibuk. |
| Clustered Bar Chart | `hour` × `Avg Hourly Rentals` | 24 bar yang menunjukkan rata-rata rental per jam. Pola *bimodal* (dual-peak) terlihat jelas. |
| Dual-Line Chart | `hour` × `Weekday Avg` & `Weekend Avg` | Perbandingan pola Weekday (*dual-peak*: 08:00 & 18:00) dengan Weekend (*single-peak*: 14:00–17:00). |
| Matrix Heatmap | `day_name` × `hour` × `Avg Hourly Rentals` | Grid 7×24 dengan *conditional formatting gradient* — mengungkap konsistensi pola Senin–Jumat dan perbedaan Sabtu–Minggu. |
| Stacked Bar Chart | `time_period` × `Total Rentals` | Distribusi rental per periode waktu (Dawn/Morning/Afternoon/Evening/Night). |

#### Page 3: Weather Impact

Pengukuran kuantitatif dampak kondisi meteorologis terhadap *demand*.

| Visual | Komponen | Data yang Ditampilkan |
|--------|---------|----------------------|
| 4× KPI Card | Avg Temperature, Rain Impact %, Snow Impact %, Optimal Temp Range | Suhu rata-rata **12.8°C**, penurunan *demand* akibat hujan **-62.3%**, akibat salju **-78.1%**, suhu optimal **Warm (20–30°C)**. |
| Scatter Plot | `temperature` × `rented_bike_count` | Hubungan non-linear (kurva *inverted-U*) antara suhu dan volume penyewaan. |
| 3× Clustered Bar Chart | Per `weather_condition`, `temp_category`, `humidity_category` | Perbandingan rata-rata *demand* per kategori cuaca, suhu, dan kelembaban. |

#### Page 4: Operational Intelligence

Metrik operasional untuk pengambilan keputusan *fleet management* dan *staffing*.

| Visual | Komponen | Data yang Ditampilkan |
|--------|---------|----------------------|
| 4× KPI Card | Zero Demand Hours, Demand Volatility, Holiday Impact, StdDev | **295 jam (3,4%)** zero demand, CV **0.915** (Moderate), Holiday factor **0.85x**, σ ≈ **532**. |
| Matrix Heatmap | `shift` × `day_type` × `Avg Hourly Rentals` | Identifikasi kombinasi shift dan tipe hari dengan *demand* tertinggi: Evening Shift × Working Day. |
| Donut Chart | `shift` × `Total Rentals` | Distribusi: Evening Shift ~42%, Day Shift ~35%, Night Shift ~23%. |
| Clustered Bar Chart | `day_type` × `Avg Hourly Rentals` | Perbandingan Working Day > Holiday > Non-Functioning. |
| Multi-Line Chart | `hour` × `Avg Hourly Rentals` × `season_name` | Empat kurva musiman — pola konsisten, amplitudo bervariasi berdasarkan musim. |

#### Page 5: Business Recommendations

Halaman interaktif berbasis *slicer* untuk eksplorasi skenario bisnis.

| Visual | Komponen | Data yang Ditampilkan |
|--------|---------|----------------------|
| 3× Slicer (Tile) | Season, Weather Condition, Day Category | *Filter* interaktif yang memengaruhi seluruh visual pada halaman. |
| 2× KPI Card | Estimated Revenue, Revenue Loss (Rain) | Estimasi revenue **₩9.258,5M**, potensi kerugian akibat hujan **₩523,4M**. |
| Table (24 rows) | `hour` × `Avg Hourly Rentals` × `Action Recommendation` | Rekomendasi aksi per jam: 🔴 Reduce Fleet, 🟡 Promote/Discount, 🟢 Maintain, 🔵 Maximize Supply. |
| Clustered Bar Chart | `hour` × `Avg Hourly Rentals` | Visualisasi jam berdasarkan *demand* — berubah dinamis sesuai konfigurasi *slicer*. |
| Donut Chart | `season_name` × `Estimated Revenue` | Distribusi *estimated revenue* per musim. |

---

## 8. Key Findings & Business Insights

### 8.1 Temuan Utama

#### Finding 1: Dominasi *Commuter Use-Case*

Sistem *bike sharing* Seoul secara dominan digunakan untuk keperluan *commuting* (perjalanan rumah–kantor), bukan rekreasi. Bukti pendukung:
- Pola *dual-peak* (08:00 & 18:00) pada hari kerja yang konsisten sepanjang tahun.
- *Demand* hari kerja **15% lebih tinggi** dibandingkan akhir pekan.
- Holiday *impact factor* sebesar **0.85x** — *demand* menurun saat tidak ada kebutuhan *commuting*.
- Seluruh 5 hari tersibuk merupakan **Working Day** di bulan Juni.

#### Finding 2: Cuaca sebagai Faktor Penurun *Demand* Terbesar

| Kondisi | Penurunan vs Clear | Estimasi Revenue Loss per Tahun |
|---------|-------------------|---------------------------------|
| Rainy | **-62,3%** | ₩523,4M |
| Snowy | **-78,1%** | ₩250–300M |
| **Total** | — | **₩773–823M (~8,5% revenue tahunan)** |

#### Finding 3: Pola Musiman yang Signifikan

| Musim | Kontribusi | Estimasi Revenue |
|-------|-----------|-----------------|
| Summer | **37,0%** | ₩3.424,9M |
| Autumn | **29,0%** | ₩2.685,0M |
| Spring | **26,1%** | ₩2.417,9M |
| Winter | **7,9%** | ₩730,8M |

Summer dan Autumn secara kumulatif menyumbang **66% dari total revenue tahunan**.

#### Finding 4: Prediktabilitas *Demand*

*Coefficient of Variation* sebesar **0,915** (kategori Moderate) dan konsistensi pola temporal lintas musim mengindikasikan bahwa *demand* mengikuti pola berulang yang dapat diprediksi. Temuan ini mendukung kelayakan implementasi *data-driven fleet management*.

### 8.2 Rekomendasi Strategis

| Prioritas | Inisiatif | Estimasi Revenue Impact per Tahun |
|-----------|----------|----------------------------------|
| 1 | **Dynamic Pricing** — diferensiasi tarif *peak/off-peak* | +₩300–500M |
| 1 | **Weather-responsive Fleet Management** — redistribusi proaktif berdasarkan prakiraan cuaca | Cost reduction signifikan |
| 2 | **Subscription Model** — konversi *pay-per-trip* ke langganan bulanan | +₩200–300M |
| 2 | **Time-based Fleet Redistribution** — redistribusi terjadwal 4 kali per hari | Peningkatan efisiensi operasional |
| 3 | **Weekend Leisure Campaign** — promosi taman dan rute wisata untuk akhir pekan | +₩50–100M |

**Estimasi total *uplift***: implementasi seluruh rekomendasi berpotensi meningkatkan revenue **7–12%**, dari ~₩9,26B menjadi **₩9,9B–₩10,36B KRW per tahun**.

Analisis mendalam untuk setiap temuan dan jawaban terhadap 10 pertanyaan strategis bisnis tersedia pada [`docs/Business_Analyst_Report.md`](docs/Business_Analyst_Report.md).

---

## 9. Limitations & Known Gaps

| # | Limitasi | Dampak | Mitigasi |
|---|---------|--------|---------|
| 1 | **Cakupan temporal terbatas** — data hanya mencakup 1 tahun (Desember 2017 – November 2018). | Tidak memungkinkan analisis tren *year-over-year* atau validasi konsistensi pola lintas tahun. | Seluruh temuan diperlakukan sebagai pola 1 tahun. Validasi memerlukan dataset multi-tahun. |
| 2 | **Tidak tersedia data lokasi/stasiun.** | Tidak memungkinkan analisis distribusi spasial *demand* atau identifikasi *hotspot/cold spot*. | Analisis difokuskan pada dimensi temporal dan meteorologis. |
| 3 | **Revenue bersifat estimasi** — menggunakan asumsi ₩1.500/trip. | Angka revenue absolut mungkin tidak akurat. | Angka digunakan untuk perbandingan relatif, bukan sebagai nilai absolut. |
| 4 | **Tidak tersedia data segmentasi pengguna.** | Tidak memungkinkan analisis *cohort*, *retention*, atau diferensiasi *subscriber* vs *casual user*. | Inferensi *use-case* (commuter vs leisure) berdasarkan pola temporal. |
| 5 | **Analisis bersifat historis**, bukan prediktif. | Tidak dapat digunakan untuk *real-time fleet management* atau *automated forecasting*. | Pola historis yang *repeatable* digunakan sebagai *baseline* perencanaan. |
| 6 | **Data cuaca bersifat observasional**, bukan prediktif. | Strategi *weather-responsive* memerlukan integrasi dengan API prakiraan cuaca eksternal. | Rekomendasi diasumsikan menggunakan prakiraan cuaca dari sumber terpisah. |

---

## 10. Potential Improvements

| # | Improvement | Deskripsi | Kompleksitas |
|---|------------|-----------|-------------|
| 1 | **Predictive Modeling** | Pembangunan model *machine learning* (XGBoost, Random Forest, LSTM) untuk *demand forecasting* berbasis fitur cuaca dan temporal. | Tinggi |
| 2 | **Real-time Dashboard** | Migrasi ke *DirectQuery* dengan *scheduled refresh* untuk monitoring *near real-time*. | Tinggi |
| 3 | **Geospatial Analysis** | Penambahan *map visual* untuk analisis distribusi *demand* per lokasi stasiun (memerlukan data stasiun). | Sedang |
| 4 | **User Segmentation** | Analisis *cohort* pengguna: *subscriber* vs *casual*, frekuensi penggunaan, *lifetime value*, *churn prediction*. | Sedang |
| 5 | **Anomaly Detection** | Implementasi *statistical anomaly detection* (Z-score, IQR) untuk identifikasi hari dengan *demand* abnormal. | Sedang |
| 6 | **A/B Testing Framework** | Perancangan eksperimen untuk validasi efektivitas *dynamic pricing* dan kampanye promosi. | Tinggi |
| 7 | **ETL Automation** | Migrasi proses ETL ke SSIS atau Apache Airflow untuk *scheduled execution* dan *error handling* otomatis. | Tinggi |
| 8 | **Multi-year Analysis** | Penggabungan dataset dari tahun lain untuk validasi pola dan analisis tren jangka panjang. | Rendah |

---

## 11. How to Reproduce

### Prerequisites

| Software | Versi Minimum | Sumber | Fungsi |
|----------|-------------|--------|--------|
| **Microsoft SQL Server** | 2017+ | [Download (Express Edition — Gratis)](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) | Database backend |
| **SQL Server Management Studio** | 18.x+ | [Download (Gratis)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) | Eksekusi SQL scripts |
| **Microsoft Power BI Desktop** | Terbaru | [Download (Gratis)](https://powerbi.microsoft.com/en-us/desktop/) | Eksplorasi dashboard |

> **Catatan**: Untuk eksplorasi dashboard saja, hanya diperlukan **Power BI Desktop**. File `.pbix` sudah menyertakan data (*Import Mode*) dan tidak memerlukan koneksi SQL Server aktif.

### Langkah Reproduksi

#### Step 1 — Clone Repository

```bash
git clone https://github.com/<username>/seoul-bike-sharing-analytics.git
cd seoul-bike-sharing-analytics
```

#### Step 2 — Konfigurasi SQL Server (Opsional)

> Langkah ini hanya diperlukan apabila hendak menjalankan SQL scripts secara mandiri.

1. Pastikan SQL Server terinstal dan berjalan.
2. Buka SSMS dan lakukan koneksi ke *instance* lokal (`localhost`).

#### Step 3 — Eksekusi SQL Scripts (Opsional)

Keempat file SQL **harus dieksekusi secara berurutan** — setiap file memiliki dependensi terhadap output file sebelumnya.

| Urutan | File | Estimasi Waktu |
|--------|------|---------------|
| 1 | `sql/schema.sql` | ~2 detik |
| 2 | `sql/etl.sql` | ~5 detik |
| 3 | `sql/views.sql` | ~2 detik |
| 4 | `sql/analysis.sql` | ~3 detik |

Prosedur eksekusi di SSMS: **File → Open → File** → pilih file SQL → **Execute** (F5).

> **Konfigurasi wajib pada `etl.sql`**: path file CSV pada perintah `BULK INSERT` harus disesuaikan dengan lokasi aktual pada sistem lokal:
> ```sql
> BULK INSERT staging.bike_raw
> FROM 'C:\path\ke\data\SeoulBikeData.csv'  -- Sesuaikan path ini
> ```

#### Step 4 — Eksplorasi Dashboard

1. Buka file `powerbi/Seoul Bike Sharing Demand.pbix` menggunakan Power BI Desktop.
2. Dashboard dapat langsung dieksplorasi tanpa konfigurasi tambahan.
3. Navigasi antar halaman tersedia melalui tab di bagian bawah.

#### Step 5 — Refresh Data (Opsional)

Apabila SQL scripts telah dieksekusi dan *refresh* data diperlukan:

1. Buka file `.pbix`.
2. Klik **Home → Refresh** pada ribbon.
3. Konfirmasi koneksi ke `localhost` dengan *Windows Authentication*.

---

## 12. Citation

```bibtex
@misc{seoul_bike_sharing_demand_560,
  author       = {Sathishkumar V E and Yongyun Cho},
  title        = {{Seoul Bike Sharing Demand}},
  year         = {2020},
  howpublished = {UCI Machine Learning Repository},
  doi          = {10.24432/C5F62R},
  url          = {https://archive.ics.uci.edu/dataset/560/seoul+bike+sharing+demand}
}
```

### Publikasi Terkait

1. Sathishkumar V E, Jangwoo Park, and Yongyun Cho. *"Using data mining techniques for bike sharing demand prediction in metropolitan city."* Computer Communications, Vol. 153, pp. 353–366, 2020. [DOI: 10.1016/j.comcom.2020.02.007](https://doi.org/10.1016/j.comcom.2020.02.007)

2. Sathishkumar V E and Yongyun Cho. *"A rule-based model for Seoul Bike sharing demand prediction using weather data."* European Journal of Remote Sensing, Vol. 53, Sup. 1, pp. 166–183, 2020. [DOI: 10.1080/22797254.2020.1725789](https://doi.org/10.1080/22797254.2020.1725789)

---

<p align="center">
  <i>Seoul Bike Sharing Demand Analytics — End-to-End Data Pipeline Project</i>
</p>
