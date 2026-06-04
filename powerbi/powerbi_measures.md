# 📊 Power BI — DAX Measures Documentation

> **Seoul Bike Sharing Demand Analytics**
> Panduan lengkap DAX Measures untuk dashboard Power BI
> Terakhir diperbarui: 3 Juni 2026

---

## 1. Koneksi Database

### 1.1 Setup Koneksi
1. Buka **Power BI Desktop**
2. Klik **Get Data → SQL Server**
3. Isi koneksi:
   - **Server**: `localhost` (atau `localhost\SQLEXPRESS`)
   - **Database**: `SeoulBikeAnalytics`
   - **Data Connectivity mode**: `Import`
4. Klik **OK → Connect**

### 1.2 Tabel yang Di-Import
Import **views** berikut (bukan tabel mentah) untuk performa optimal:

| View | Fungsi | Digunakan di Page |
|------|--------|-------------------|
| `vw_full_detail` | Data lengkap denormalized (utama) | Semua halaman |
| `vw_hourly_summary` | Ringkasan per jam | Temporal Analysis |
| `vw_daily_summary` | Ringkasan per hari | Executive Summary |
| `vw_monthly_summary` | Ringkasan per bulan | Executive Summary, Seasonal |
| `vw_weather_impact` | Dampak cuaca | Weather Impact |

> **Rekomendasi**: Import `vw_full_detail` sebagai tabel utama. View lainnya opsional sebagai pendukung.

### 1.3 Tabel Dimensi (opsional, untuk Slicer)
Jika ingin slicer yang lebih rapi, import juga:

| Tabel Dimensi | Fungsi |
|---------------|--------|
| `dim_date` | Slicer tanggal, bulan, kuartal |
| `dim_season` | Slicer musim |
| `dim_time_slot` | Slicer jam, time period, shift |
| `dim_holiday` | Slicer hari libur |
| `dim_weather` | Slicer kategori cuaca |

---

## 2. Calculated Columns

Tambahkan calculated columns berikut pada tabel `vw_full_detail`.
Cara membuat: Klik tabel `vw_full_detail` → Tab **Modeling** → **New Column** → paste formula.

> ⚠️ **PENTING**: Kolom `month_name` dan `day_name` TIDAK perlu calculated column
> untuk sorting. Gunakan kolom numerik yang sudah ada:
> - `month_name` → Sort by Column → pilih `month`
> - `day_name` → Sort by Column → pilih `day_of_week`

### 2.1 Sort Order untuk Musim
```dax
Season Sort = 
    SWITCH(
        [season_name],
        "Spring", 1,
        "Summer", 2,
        "Autumn", 3,
        "Winter", 4
    )
```
> Setelah dibuat: klik `season_name` → Tab **Column tools** → **Sort by Column** → pilih `Season Sort`.

### 2.2 Sort Order untuk Time Period
```dax
Time Period Sort = 
    SWITCH(
        [time_period],
        "Dawn", 1,
        "Morning", 2,
        "Afternoon", 3,
        "Evening", 4,
        "Night", 5
    )
```
> Klik `time_period` → **Sort by Column** → pilih `Time Period Sort`.

### 2.3 Sort Order untuk Temperature Category
```dax
Temp Category Sort = 
    SWITCH(
        [temp_category],
        "Freezing", 1,
        "Cold", 2,
        "Cool", 3,
        "Warm", 4,
        "Hot", 5
    )
```
> Klik `temp_category` → **Sort by Column** → pilih `Temp Category Sort`.

### 2.4 Day Category (Weekday/Weekend)
```dax
Day Category = 
    IF([is_weekend] = TRUE(), "Weekend", "Weekday")
```
> Catatan: `is_weekend` bertipe Boolean di Power BI, gunakan `TRUE()` bukan `1`.

---

## 3. DAX Measures

Semua measures dibuat di **tabel `vw_full_detail`**.
Cara membuat: Klik tabel → **New Measure** → paste DAX formula.

> **Konvensi Penamaan**:
> - Measure biasa → untuk **chart** (axis, values) — mengembalikan angka
> - Measure `...Display` → untuk **Card** visual — mengembalikan teks berformat
> 
> Gunakan versi **Display** untuk Card visual agar muncul suffix/prefix
> seperti °C, %, jam, dll. Gunakan versi biasa untuk Chart.

---

### 📌 3.1 BASE MEASURES (Measures Dasar)

#### Total Rentals
```dax
Total Rentals = 
    SUM(vw_full_detail[rented_bike_count])
```
> Untuk Card: set Display units → `None`, Decimal places → `0`

#### Total Rentals Display
```dax
Total Rentals Display = 
    FORMAT([Total Rentals], "#,##0") & " trips"
```
> Untuk Card visual — menampilkan "6,172,314 trips"

#### Total Hours
```dax
Total Hours = 
    COUNTROWS(vw_full_detail)
```

#### Total Hours Display
```dax
Total Hours Display = 
    FORMAT([Total Hours], "#,##0") & " hours"
```

#### Total Days
```dax
Total Days = 
    DISTINCTCOUNT(vw_full_detail[full_date])
```

---

### 🏠 3.2 EXECUTIVE SUMMARY (Page 1)

#### Average Daily Rentals
```dax
Avg Daily Rentals = 
    DIVIDE(
        [Total Rentals],
        [Total Days],
        0
    )
```

#### Avg Daily Rentals Display
```dax
Avg Daily Rentals Display = 
    FORMAT([Avg Daily Rentals], "#,##0") & " /day"
```
> Card: menampilkan "16,911 /day"

#### Average Hourly Rentals
```dax
Avg Hourly Rentals = 
    AVERAGE(vw_full_detail[rented_bike_count])
```

#### Avg Hourly Rentals Display
```dax
Avg Hourly Rentals Display = 
    FORMAT([Avg Hourly Rentals], "#,##0.0") & " /hr"
```

#### Peak Hourly Demand
```dax
Peak Hourly Demand = 
    MAX(vw_full_detail[rented_bike_count])
```

#### Peak Hourly Demand Display
```dax
Peak Hourly Demand Display = 
    FORMAT([Peak Hourly Demand], "#,##0") & " bikes"
```

#### Min Hourly Demand
```dax
Min Hourly Demand = 
    MIN(vw_full_detail[rented_bike_count])
```

#### Peak Hour
```dax
Peak Hour = 
    VAR _MaxHour = 
        MAXX(
            SUMMARIZE(
                vw_full_detail,
                vw_full_detail[hour],
                "HourTotal", SUM(vw_full_detail[rented_bike_count])
            ),
            [HourTotal]
        )
    RETURN
        MAXX(
            FILTER(
                SUMMARIZE(
                    vw_full_detail,
                    vw_full_detail[hour],
                    "HourTotal", SUM(vw_full_detail[rented_bike_count])
                ),
                [HourTotal] = _MaxHour
            ),
            [hour]
        )
```

#### Peak Hour Display ⭐
```dax
Peak Hour Display = 
    VAR _MaxHour = 
        MAXX(
            SUMMARIZE(
                vw_full_detail,
                vw_full_detail[hour],
                "HourTotal", SUM(vw_full_detail[rented_bike_count])
            ),
            [HourTotal]
        )
    VAR _Hour = 
        MAXX(
            FILTER(
                SUMMARIZE(
                    vw_full_detail,
                    vw_full_detail[hour],
                    "HourTotal", SUM(vw_full_detail[rented_bike_count])
                ),
                [HourTotal] = _MaxHour
            ),
            [hour]
        )
    RETURN
        FORMAT(_Hour, "00") & ":00"
```
> Card: menampilkan "18:00"

#### Busiest Season
```dax
Busiest Season = 
    VAR _MaxRentals = 
        MAXX(
            SUMMARIZE(
                vw_full_detail,
                vw_full_detail[season_name],
                "SeasonTotal", SUM(vw_full_detail[rented_bike_count])
            ),
            [SeasonTotal]
        )
    RETURN
        MAXX(
            FILTER(
                SUMMARIZE(
                    vw_full_detail,
                    vw_full_detail[season_name],
                    "SeasonTotal", SUM(vw_full_detail[rented_bike_count])
                ),
                [SeasonTotal] = _MaxRentals
            ),
            [season_name]
        )
```
> Sudah berformat teks — langsung pakai di Card.

#### Rental Percentage by Season
```dax
Pct of Total Rentals = 
    DIVIDE(
        [Total Rentals],
        CALCULATE([Total Rentals], ALL(vw_full_detail)),
        0
    )
```

#### Pct of Total Rentals Display
```dax
Pct of Total Rentals Display = 
    FORMAT([Pct of Total Rentals], "0.0%")
```
> Card: menampilkan "32.5%"

---

### ⏰ 3.3 TEMPORAL ANALYSIS (Page 2)

#### Average Rentals per Hour of Day
```dax
Avg Rentals by Hour = 
    AVERAGEX(
        VALUES(vw_full_detail[full_date]),
        CALCULATE(SUM(vw_full_detail[rented_bike_count]))
    )
```

#### Weekday Average
```dax
Weekday Avg = 
    CALCULATE(
        AVERAGE(vw_full_detail[rented_bike_count]),
        vw_full_detail[is_weekend] = FALSE()
    )
```

#### Weekday Avg Display
```dax
Weekday Avg Display = 
    FORMAT([Weekday Avg], "#,##0.0") & " /hr"
```

#### Weekend Average
```dax
Weekend Avg = 
    CALCULATE(
        AVERAGE(vw_full_detail[rented_bike_count]),
        vw_full_detail[is_weekend] = TRUE()
    )
```

#### Weekend Avg Display
```dax
Weekend Avg Display = 
    FORMAT([Weekend Avg], "#,##0.0") & " /hr"
```

#### Weekend vs Weekday Difference
```dax
Weekend vs Weekday Diff = 
    [Weekend Avg] - [Weekday Avg]
```

#### Weekend vs Weekday Diff Display
```dax
Weekend vs Weekday Diff Display = 
    VAR _Diff = [Weekend vs Weekday Diff]
    RETURN
        IF(
            _Diff >= 0,
            "+" & FORMAT(_Diff, "#,##0.0"),
            FORMAT(_Diff, "#,##0.0")
        )
```
> Card: menampilkan "+45.2" atau "-120.3"

#### Rush Hour Rentals
```dax
Rush Hour Rentals = 
    CALCULATE(
        [Total Rentals],
        vw_full_detail[rush_hour_flag] = TRUE()
    )
```

#### Non-Rush Hour Rentals
```dax
Non-Rush Hour Rentals = 
    CALCULATE(
        [Total Rentals],
        vw_full_detail[rush_hour_flag] = FALSE()
    )
```

#### Rush Hour Percentage
```dax
Rush Hour Pct = 
    DIVIDE(
        [Rush Hour Rentals],
        [Total Rentals],
        0
    )
```

#### Rush Hour Pct Display
```dax
Rush Hour Pct Display = 
    FORMAT([Rush Hour Pct], "0.0%")
```
> Card: menampilkan "35.2%"

---

### 🌦️ 3.4 WEATHER IMPACT (Page 3)

#### Average Temperature
```dax
Avg Temperature = 
    AVERAGE(vw_full_detail[temperature])
```

#### Avg Temperature Display ⭐
```dax
Avg Temperature Display = 
    FORMAT([Avg Temperature], "#,##0.0") & " °C"
```
> Card: menampilkan "12.8 °C"

#### Average Humidity
```dax
Avg Humidity = 
    AVERAGE(vw_full_detail[humidity])
```

#### Avg Humidity Display
```dax
Avg Humidity Display = 
    FORMAT([Avg Humidity], "#,##0.0") & "%"
```
> Card: menampilkan "58.2%"

#### Average Wind Speed
```dax
Avg Wind Speed = 
    AVERAGE(vw_full_detail[wind_speed])
```

#### Avg Wind Speed Display
```dax
Avg Wind Speed Display = 
    FORMAT([Avg Wind Speed], "#,##0.0") & " m/s"
```
> Card: menampilkan "1.7 m/s"

#### Clear Weather Avg Demand
```dax
Clear Weather Avg = 
    CALCULATE(
        AVERAGE(vw_full_detail[rented_bike_count]),
        vw_full_detail[weather_condition] = "Clear"
    )
```

#### Clear Weather Avg Display
```dax
Clear Weather Avg Display = 
    FORMAT([Clear Weather Avg], "#,##0.0") & " /hr"
```

#### Rainy Weather Avg Demand
```dax
Rainy Weather Avg = 
    CALCULATE(
        AVERAGE(vw_full_detail[rented_bike_count]),
        vw_full_detail[weather_condition] = "Rainy"
    )
```

#### Rainy Weather Avg Display
```dax
Rainy Weather Avg Display = 
    FORMAT([Rainy Weather Avg], "#,##0.0") & " /hr"
```

#### Snowy Weather Avg Demand
```dax
Snowy Weather Avg = 
    CALCULATE(
        AVERAGE(vw_full_detail[rented_bike_count]),
        vw_full_detail[weather_condition] = "Snowy"
    )
```

#### Snowy Weather Avg Display
```dax
Snowy Weather Avg Display = 
    FORMAT([Snowy Weather Avg], "#,##0.0") & " /hr"
```

#### Rain Impact Percentage
```dax
Rain Impact Pct = 
    VAR _ClearAvg = [Clear Weather Avg]
    VAR _RainyAvg = [Rainy Weather Avg]
    RETURN
        DIVIDE(
            _ClearAvg - _RainyAvg,
            _ClearAvg,
            0
        )
```

#### Rain Impact Pct Display ⭐
```dax
Rain Impact Pct Display = 
    "↓ " & FORMAT([Rain Impact Pct], "0.0%") & " vs Clear"
```
> Card: menampilkan "↓ 62.3% vs Clear"

#### Snow Impact Percentage
```dax
Snow Impact Pct = 
    VAR _ClearAvg = [Clear Weather Avg]
    VAR _SnowyAvg = [Snowy Weather Avg]
    RETURN
        DIVIDE(
            _ClearAvg - _SnowyAvg,
            _ClearAvg,
            0
        )
```

#### Snow Impact Pct Display ⭐
```dax
Snow Impact Pct Display = 
    "↓ " & FORMAT([Snow Impact Pct], "0.0%") & " vs Clear"
```
> Card: menampilkan "↓ 78.1% vs Clear"

#### Weather Sensitivity Index
```dax
Weather Sensitivity = 
    DIVIDE(
        STDEV.P(vw_full_detail[rented_bike_count]),
        AVERAGE(vw_full_detail[rented_bike_count]),
        0
    )
```

#### Weather Sensitivity Display
```dax
Weather Sensitivity Display = 
    "CV: " & FORMAT([Weather Sensitivity], "0.000")
```
> Card: menampilkan "CV: 0.892"

#### Optimal Temp Range
```dax
Optimal Temp Range = 
    VAR _Summary = 
        ADDCOLUMNS(
            SUMMARIZE(vw_full_detail, vw_full_detail[temp_category]),
            "AvgDemand", CALCULATE(AVERAGE(vw_full_detail[rented_bike_count]))
        )
    VAR _BestCategory = 
        MAXX(_Summary, [AvgDemand])
    RETURN
        MAXX(
            FILTER(_Summary, [AvgDemand] = _BestCategory),
            [temp_category]
        )
```
> Sudah berformat teks — langsung pakai di Card. Menampilkan "Warm" atau "Hot"

---

### 📈 3.5 OPERATIONAL INTELLIGENCE (Page 4)

#### Zero Demand Hours
```dax
Zero Demand Hours = 
    CALCULATE(
        COUNTROWS(vw_full_detail),
        vw_full_detail[rented_bike_count] = 0
    )
```

#### Zero Demand Hours Display
```dax
Zero Demand Hours Display = 
    FORMAT([Zero Demand Hours], "#,##0") & " hours (" & FORMAT([Zero Demand Pct], "0.0%") & ")"
```
> Card: menampilkan "295 hours (3.4%)"

#### Zero Demand Percentage
```dax
Zero Demand Pct = 
    DIVIDE(
        [Zero Demand Hours],
        [Total Hours],
        0
    )
```

#### Zero Demand Pct Display
```dax
Zero Demand Pct Display = 
    FORMAT([Zero Demand Pct], "0.00%")
```

#### Demand Volatility (CV)
```dax
Demand Volatility = 
    DIVIDE(
        STDEV.P(vw_full_detail[rented_bike_count]),
        AVERAGE(vw_full_detail[rented_bike_count]),
        0
    )
```

#### Demand Volatility Display ⭐
```dax
Demand Volatility Display = 
    VAR _CV = [Demand Volatility]
    VAR _Label = 
        SWITCH(
            TRUE(),
            _CV < 0.5, "Stable",
            _CV < 1.0, "Moderate",
            "High Volatility"
        )
    RETURN
        FORMAT(_CV, "0.000") & " (" & _Label & ")"
```
> Card: menampilkan "0.892 (Moderate)"

#### Holiday Impact Factor
```dax
Holiday Impact Factor = 
    VAR _HolidayAvg = 
        CALCULATE(
            AVERAGE(vw_full_detail[rented_bike_count]),
            vw_full_detail[day_type] = "Holiday"
        )
    VAR _WorkingAvg = 
        CALCULATE(
            AVERAGE(vw_full_detail[rented_bike_count]),
            vw_full_detail[day_type] = "Working Day"
        )
    RETURN
        DIVIDE(_HolidayAvg, _WorkingAvg, 0)
```

#### Holiday Impact Factor Display ⭐
```dax
Holiday Impact Factor Display = 
    VAR _Factor = [Holiday Impact Factor]
    VAR _Label = 
        IF(_Factor > 1, "↑ Higher on Holidays", "↓ Lower on Holidays")
    RETURN
        FORMAT(_Factor, "0.00") & "x — " & _Label
```
> Card: menampilkan "0.85x — ↓ Lower on Holidays"

#### Demand Std Dev
```dax
Demand StdDev = 
    STDEV.P(vw_full_detail[rented_bike_count])
```

#### Demand StdDev Display
```dax
Demand StdDev Display = 
    "σ = " & FORMAT([Demand StdDev], "#,##0.0")
```
> Card: menampilkan "σ = 532.1"

#### Shift Percentage
```dax
Shift Pct = 
    DIVIDE(
        [Total Rentals],
        CALCULATE([Total Rentals], ALL(vw_full_detail[shift])),
        0
    )
```

#### Shift Pct Display
```dax
Shift Pct Display = 
    FORMAT([Shift Pct], "0.0%")
```

---

### 💡 3.6 BUSINESS RECOMMENDATIONS (Page 5)

#### Action Recommendation
```dax
Action Recommendation = 
    VAR _Avg = [Avg Hourly Rentals]
    RETURN
        SWITCH(
            TRUE(),
            _Avg < 100,  "🔴 Very Low — Reduce Fleet",
            _Avg < 300,  "🟡 Low — Promote/Discount",
            _Avg < 700,  "🟢 Moderate — Maintain",
                         "🔵 High — Maximize Supply"
        )
```
> Sudah berformat teks — langsung pakai di Card atau Table.

#### Estimated Revenue (proxy)
```dax
Estimated Revenue = 
    [Total Rentals] * 1500
```
> Asumsi: harga rata-rata 1,500 KRW per rental.

#### Estimated Revenue Display ⭐
```dax
Estimated Revenue Display = 
    "₩" & FORMAT([Estimated Revenue] / 1000000, "#,##0.0") & "M"
```
> Card: menampilkan "₩9,258.5M" (dalam juta KRW)

#### Revenue Loss from Rain
```dax
Revenue Loss Rain = 
    VAR _ClearAvg = [Clear Weather Avg]
    VAR _RainyAvg = [Rainy Weather Avg]
    VAR _RainyHours = 
        CALCULATE(COUNTROWS(vw_full_detail), vw_full_detail[weather_condition] = "Rainy")
    RETURN
        (_ClearAvg - _RainyAvg) * _RainyHours * 1500
```

#### Revenue Loss Rain Display ⭐
```dax
Revenue Loss Rain Display = 
    "₩" & FORMAT([Revenue Loss Rain] / 1000000, "#,##0.0") & "M lost"
```
> Card: menampilkan "₩523.4M lost"

---

## 4. Panduan Visualisasi per Page

### Panduan Umum: Kapan Pakai Versi Display vs Biasa

| Konteks Visual | Gunakan Versi |
|----------------|---------------|
| **Card** | `...Display` (teks berformat) |
| **Chart Axis / Values** | Versi biasa (angka) |
| **Table Column** | Keduanya bisa |
| **Slicer** | Field langsung (bukan measure) |
| **Conditional Formatting** | Versi biasa (angka) |

### Page 1: 🏠 Executive Summary

| Visual | Measure / Field | Keterangan |
|--------|----------------|------------|
| KPI Card | `Total Rentals Display` | "6,172,314 trips" |
| KPI Card | `Avg Daily Rentals Display` | "16,911 /day" |
| KPI Card | `Peak Hour Display` | "18:00" |
| KPI Card | `Busiest Season` | "Summer" |
| Line Chart | Axis: `month_name`, Value: `Total Rentals` | Sort by `month` |
| Pie/Donut Chart | Legend: `season_name`, Value: `Total Rentals` | Distribusi musiman |
| Table | Columns dari `vw_daily_summary`, sort by `total_rentals` DESC | Top 5 hari |

### Page 2: ⏰ Temporal Analysis

| Visual | Measure / Field | Keterangan |
|--------|----------------|------------|
| KPI Card | `Weekday Avg Display` | "xxx.x /hr" |
| KPI Card | `Weekend Avg Display` | "xxx.x /hr" |
| KPI Card | `Rush Hour Pct Display` | "35.2%" |
| Matrix (Heatmap) | Rows: `day_name`, Columns: `hour`, Value: `Avg Hourly Rentals` | Conditional formatting → Color scale |
| Clustered Bar | Axis: `hour`, Value: `Avg Hourly Rentals` | Sort 0–23 |
| Line Chart (2 lines) | Axis: `hour`, Values: `Weekday Avg`, `Weekend Avg` | Perbandingan pola |
| Stacked Bar | Axis: `time_period`, Value: `Total Rentals` | Sort by `Time Period Sort` |

### Page 3: 🌦️ Weather Impact

| Visual | Measure / Field | Keterangan |
|--------|----------------|------------|
| KPI Card | `Avg Temperature Display` | "12.8 °C" |
| KPI Card | `Rain Impact Pct Display` | "↓ 62.3% vs Clear" |
| KPI Card | `Snow Impact Pct Display` | "↓ 78.1% vs Clear" |
| KPI Card | `Optimal Temp Range` | "Warm" |
| Scatter Plot | X: `temperature`, Y: `rented_bike_count` | Dari `vw_full_detail` |
| Clustered Bar | Axis: `weather_condition`, Value: `Avg Hourly Rentals` | Clear vs Rainy vs Snowy |
| Line Chart | Axis: `temp_category`, Value: `Avg Hourly Rentals` | Sort by `Temp Category Sort` |

### Page 4: 📈 Operational Intelligence

| Visual | Measure / Field | Keterangan |
|--------|----------------|------------|
| KPI Card | `Zero Demand Hours Display` | "295 hours (3.4%)" |
| KPI Card | `Demand Volatility Display` | "0.892 (Moderate)" |
| KPI Card | `Holiday Impact Factor Display` | "0.85x — ↓ Lower on Holidays" |
| KPI Card | `Demand StdDev Display` | "σ = 532.1" |
| Matrix | Rows: `shift`, Columns: `day_type`, Value: `Avg Hourly Rentals` | Distribusi per shift × day_type |
| Donut Chart | Legend: `shift`, Value: `Total Rentals` | Distribusi per shift |

### Page 5: 💡 Business Recommendations

| Visual | Measure / Field | Keterangan |
|--------|----------------|------------|
| Slicer | `season_name` | Filter per musim |
| Slicer | `weather_condition` | Filter per cuaca |
| Slicer | `Day Category` | Weekday / Weekend |
| Table | `hour`, `Avg Hourly Rentals`, `Action Recommendation` | Rekomendasi per jam |
| KPI Card | `Estimated Revenue Display` | "₩9,258.5M" |
| KPI Card | `Revenue Loss Rain Display` | "₩523.4M lost" |

---

## 5. Tips & Best Practices

### 5.1 Format di Measure Tools (untuk Chart)
Jika menggunakan measure biasa (bukan Display) di Chart:

| Measure | Format | Decimal Places |
|---------|--------|---------------|
| Rentals (count) | Whole Number | 0 |
| Averages | Decimal Number | 1 |
| Percentages | Percentage | 1 |
| Temperature | Decimal Number | 1 |
| CV / Index | Decimal Number | 3 |

Cara: Klik measure → Tab **Measure tools** → **Format** → pilih tipe → set decimal places.

### 5.2 Conditional Formatting
- **Heatmap**: Matrix visual → Format → Cell elements → Background color → gradient (putih → biru → merah)
- **Action Recommendation**: Gunakan conditional formatting icon di kolom tabel
- **KPI Cards**: Gunakan warna hijau untuk positif, merah untuk negatif

### 5.3 Slicer Sync
Untuk filter yang sync di semua halaman:
1. Klik slicer → Format → **Sync slicers**
2. Centang halaman yang ingin di-sync

### 5.4 Bookmark untuk Scenarios
Buat bookmarks untuk preset filter:
- "Summer Peak Analysis"
- "Winter Operations"  
- "Rainy Day Impact"
- "Weekend vs Weekday"

---

## 6. Daftar Lengkap Measures

### Quick Reference — Semua Measures

| # | Measure | Tipe | Untuk |
|---|---------|------|-------|
| 1 | `Total Rentals` | Angka | Chart |
| 2 | `Total Rentals Display` | Teks | Card |
| 3 | `Total Hours` | Angka | Chart |
| 4 | `Total Hours Display` | Teks | Card |
| 5 | `Total Days` | Angka | Chart |
| 6 | `Avg Daily Rentals` | Angka | Chart |
| 7 | `Avg Daily Rentals Display` | Teks | Card |
| 8 | `Avg Hourly Rentals` | Angka | Chart |
| 9 | `Avg Hourly Rentals Display` | Teks | Card |
| 10 | `Peak Hourly Demand` | Angka | Chart |
| 11 | `Peak Hourly Demand Display` | Teks | Card |
| 12 | `Min Hourly Demand` | Angka | Chart |
| 13 | `Peak Hour` | Angka | Chart |
| 14 | `Peak Hour Display` | Teks | Card |
| 15 | `Busiest Season` | Teks | Card |
| 16 | `Pct of Total Rentals` | Angka | Chart |
| 17 | `Pct of Total Rentals Display` | Teks | Card |
| 18 | `Avg Rentals by Hour` | Angka | Chart |
| 19 | `Weekday Avg` | Angka | Chart |
| 20 | `Weekday Avg Display` | Teks | Card |
| 21 | `Weekend Avg` | Angka | Chart |
| 22 | `Weekend Avg Display` | Teks | Card |
| 23 | `Weekend vs Weekday Diff` | Angka | Chart |
| 24 | `Weekend vs Weekday Diff Display` | Teks | Card |
| 25 | `Rush Hour Rentals` | Angka | Chart |
| 26 | `Non-Rush Hour Rentals` | Angka | Chart |
| 27 | `Rush Hour Pct` | Angka | Chart |
| 28 | `Rush Hour Pct Display` | Teks | Card |
| 29 | `Avg Temperature` | Angka | Chart |
| 30 | `Avg Temperature Display` | Teks | Card |
| 31 | `Avg Humidity` | Angka | Chart |
| 32 | `Avg Humidity Display` | Teks | Card |
| 33 | `Avg Wind Speed` | Angka | Chart |
| 34 | `Avg Wind Speed Display` | Teks | Card |
| 35 | `Clear Weather Avg` | Angka | Chart |
| 36 | `Clear Weather Avg Display` | Teks | Card |
| 37 | `Rainy Weather Avg` | Angka | Chart |
| 38 | `Rainy Weather Avg Display` | Teks | Card |
| 39 | `Snowy Weather Avg` | Angka | Chart |
| 40 | `Snowy Weather Avg Display` | Teks | Card |
| 41 | `Rain Impact Pct` | Angka | Chart |
| 42 | `Rain Impact Pct Display` | Teks | Card |
| 43 | `Snow Impact Pct` | Angka | Chart |
| 44 | `Snow Impact Pct Display` | Teks | Card |
| 45 | `Weather Sensitivity` | Angka | Chart |
| 46 | `Weather Sensitivity Display` | Teks | Card |
| 47 | `Optimal Temp Range` | Teks | Card |
| 48 | `Zero Demand Hours` | Angka | Chart |
| 49 | `Zero Demand Hours Display` | Teks | Card |
| 50 | `Zero Demand Pct` | Angka | Chart |
| 51 | `Zero Demand Pct Display` | Teks | Card |
| 52 | `Demand Volatility` | Angka | Chart |
| 53 | `Demand Volatility Display` | Teks | Card |
| 54 | `Holiday Impact Factor` | Angka | Chart |
| 55 | `Holiday Impact Factor Display` | Teks | Card |
| 56 | `Demand StdDev` | Angka | Chart |
| 57 | `Demand StdDev Display` | Teks | Card |
| 58 | `Shift Pct` | Angka | Chart |
| 59 | `Shift Pct Display` | Teks | Card |
| 60 | `Action Recommendation` | Teks | Card/Table |
| 61 | `Estimated Revenue` | Angka | Chart |
| 62 | `Estimated Revenue Display` | Teks | Card |
| 63 | `Revenue Loss Rain` | Angka | Chart |
| 64 | `Revenue Loss Rain Display` | Teks | Card |

**Total: 64 measures** (32 angka + 32 display)

---

> **Catatan**: File `.pbix` harus dibuat manual di Power BI Desktop karena format binary. Dokumen ini berfungsi sebagai blueprint lengkap untuk membangun dashboard.
