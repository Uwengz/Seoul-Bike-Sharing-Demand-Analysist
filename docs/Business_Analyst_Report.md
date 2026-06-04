# 📊 Business Analyst Report
## Seoul Bike Sharing Demand Analytics

> **Prepared by**: Data Analytics Team
> **Date**: 4 Juni 2026
> **Data Period**: 1 Desember 2017 – 30 November 2018 (365 hari, 8,760 jam)
> **Data Source**: UCI Machine Learning Repository — Seoul Bike Sharing Demand
> **Tools Used**: SQL Server (Star Schema + 25 Analysis Queries) → Power BI Dashboard (5 Pages, 64 DAX Measures)

---

## Daftar Isi

1. [Executive Summary](#1-executive-summary)
2. [Dashboard Insights per Page](#2-dashboard-insights-per-page)
   - [Page 1: Executive Summary](#page-1-executive-summary)
   - [Page 2: Temporal Analysis](#page-2-temporal-analysis)
   - [Page 3: Weather Impact](#page-3-weather-impact)
   - [Page 4: Operational Intelligence](#page-4-operational-intelligence)
   - [Page 5: Business Recommendations](#page-5-business-recommendations)
3. [Jawaban Pertanyaan Strategis](#3-jawaban-pertanyaan-strategis)
   - [Strategic Questions (Q1–Q5)](#-strategic-questions)
   - [Revenue Questions (Q6–Q8)](#-revenue-questions)
   - [Operational Questions (Q9–Q10)](#-operational-questions)
4. [Rekomendasi Akhir](#4-rekomendasi-akhir)

---

## 1. Executive Summary

Sistem penyewaan sepeda Seoul mencatat total **6,172,314 perjalanan** dalam satu tahun penuh, dengan rata-rata **16,910 penyewaan per hari** dan **705 penyewaan per jam**. Tiga faktor utama yang secara signifikan memengaruhi volume penyewaan adalah:

| Faktor | Tingkat Pengaruh | Temuan Utama |
|--------|-----------------|--------------|
| **Waktu (Temporal)** | ⭐⭐⭐⭐⭐ | Pola *dual-peak* pada hari kerja (08:00 & 18:00), puncak demand pukul 18:00 |
| **Cuaca (Weather)** | ⭐⭐⭐⭐ | Hujan menurunkan demand 62.3%, salju menurunkan 78.1% |
| **Musim (Season)** | ⭐⭐⭐⭐ | Summer menyumbang 37% total rental, Winter hanya 7.9% |

**Kesimpulan kunci**: Layanan ini didominasi oleh **penggunaan komuter** (commuting), bukan rekreasi. Hal ini dibuktikan oleh pola dual-peak pada hari kerja, demand lebih tinggi di Working Day dibanding Holiday, dan puncak konsisten di jam 08:00 dan 18:00.

---

## 2. Dashboard Insights per Page

### Page 1: Executive Summary

Halaman ini menyajikan gambaran menyeluruh kinerja tahunan sistem bike sharing melalui **4 KPI Cards**, sebuah **Line Chart tren bulanan**, **Donut Chart distribusi musiman**, dan **Tabel Top 5 hari tersibuk**.

#### KPI Utama

| Metrik | Nilai | Interpretasi |
|--------|-------|-------------|
| Total Rentals | **6,172,314 trips** | Volume tahunan keseluruhan |
| Avg Daily Rentals | **16,910 /day** | Rata-rata harian; benchmark untuk target operasional |
| Peak Hour | **18:00** | Jam dengan total penyewaan kumulatif tertinggi sepanjang tahun |
| Busiest Season | **Summer** | Musim Panas menyumbang porsi terbesar dari seluruh penyewaan |

#### Insight dari Tren Bulanan (Line Chart)

Grafik tren bulanan menunjukkan kurva **bell-shaped** yang sangat jelas:
- **Fase naik** (Januari → Juni): Demand meningkat secara bertahap seiring menaiknya suhu dari musim dingin ke musim panas. Kenaikan paling tajam terjadi pada transisi **Maret → April** (awal musim semi) dan **April → Mei**.
- **Puncak** (Juni): Bulan Juni mencatat rental tertinggi sepanjang tahun, diikuti Juli dan Agustus.
- **Fase turun** (Juli → Desember): Demand menurun pasca puncak musim panas, dengan penurunan paling drastis pada **Oktober → November** (transisi ke musim dingin).

> **Insight**: Pola ini sangat berkorelasi dengan suhu. Bulan dengan suhu rata-rata 20-30°C (Mei–September) konsisten menghasilkan demand tertinggi.

#### Insight dari Distribusi Musiman (Donut Chart)

| Musim | Total Rentals | % Kontribusi |
|-------|--------------|-------------|
| **Summer** | 2,283,234 | **36.99%** |
| **Autumn** | 1,790,002 | **29.00%** |
| **Spring** | 1,611,909 | **26.12%** |
| **Winter** | 487,169 | **7.89%** |

- Summer + Autumn menyumbang **66%** dari total tahunan — ini adalah *golden window* operasional.
- Winter hanya menyumbang ~8%, namun tetap beroperasi — mengindikasikan kebutuhan strategi khusus musim dingin.

#### Insight dari Top 5 Hari Tersibuk (Table)

| Tanggal | Hari | Musim | Tipe | Total Rentals | Suhu Avg |
|---------|------|-------|------|--------------|---------|
| 13 Juni 2018 | Rabu | Summer | Working Day | 36,149 | ~28°C |
| 19 Juni 2018 | Selasa | Summer | Working Day | 35,349 | ~28°C |
| 8 Juni 2018 | Jumat | Summer | Working Day | 35,103 | ~26°C |
| 20 Juni 2018 | Rabu | Summer | Working Day | 34,639 | ~27°C |
| 21 Juni 2018 | Kamis | Summer | Working Day | 34,621 | ~28°C |

**Pola yang terlihat jelas**:
- ✅ **Semua** 5 hari tersibuk jatuh di bulan **Juni** (awal musim panas)
- ✅ **Semua** adalah **Working Day** (hari kerja), bukan akhir pekan atau libur
- ✅ **Suhu** berkisar di **26-28°C** — suhu ideal untuk bersepeda
- ✅ Hari-hari tersibuk tersebar merata di weekday (Selasa–Jumat), menunjukkan dominasi commuter use-case

---

### Page 2: Temporal Analysis

Halaman ini menganalisis pola demand berdasarkan dimensi waktu melalui **3 KPI Cards**, **Clustered Bar Chart** (rata-rata rental per jam), **Line Chart** (Weekday vs Weekend), **Matrix Heatmap** (7 hari × 24 jam), dan **Stacked Bar** (per time period).

#### KPI Temporal

| Metrik | Nilai | Interpretasi |
|--------|-------|-------------|
| Weekday Avg | Rata-rata per jam di hari kerja | Hari kerja memiliki demand lebih tinggi secara keseluruhan |
| Weekend Avg | Rata-rata per jam di akhir pekan | Weekend lebih rendah, dengan pola berbeda |
| Rush Hour % | ~35% dari total | Sepertiga demand terjadi di jam sibuk (08:00 & 17:00–19:00) saja |

#### Insight dari Bar Chart: Rata-rata Rental per Jam

Distribusi 24-jam menunjukkan pola **bimodal** yang sangat jelas:
- **Peak Pagi**: Jam **08:00** — lonjakan tajam yang sesuai dengan jam berangkat kerja/sekolah
- **Peak Sore**: Jam **18:00** — puncak absolut sepanjang hari, jam pulang kerja
- **Valley**: Jam **03:00–05:00** — titik terendah dengan demand mendekati nol
- **Shoulder Hours**: Jam **10:00–15:00** — demand moderat, stabil

#### Insight dari Line Chart: Weekday vs Weekend

Perbandingan dua pola ini mengungkap **dualitas fungsi** sistem bike sharing:

**Weekday (Hari Kerja)**:
- Pola **dual-peak** (dua puncak): 08:00 dan 18:00
- Lembah dalam di jam 10:00–15:00 (jam kerja, orang di kantor)
- Demand malam turun cepat setelah pukul 20:00
- **Interpretasi**: Sepeda digunakan sebagai **alat transportasi komuter**

**Weekend (Akhir Pekan)**:
- Pola **single-peak** (satu puncak landai): 14:00–17:00
- Tidak ada lonjakan pagi; demand naik perlahan mulai pukul 10:00
- Demand sore lebih tinggi dari pagi
- **Interpretasi**: Sepeda digunakan untuk **aktivitas rekreasi/leisure**

> **Insight Strategis**: Weekday dan Weekend membutuhkan **strategi distribusi armada yang berbeda**. Di Weekday, fokus redistribusi ke stasiun dekat perkantoran dan transit; di Weekend, fokus ke area taman dan wisata.

#### Insight dari Matrix Heatmap: Hari × Jam

Heatmap 7×24 mengungkap pola granular:
- **Senin–Jumat**: Pola identik (dual-peak), konsistensi tinggi — demand sangat *predictable*
- **Sabtu**: Transisi — masih ada sedikit morning commuter peak, tapi dominan leisure
- **Minggu**: Pola paling berbeda — murni rekreasi, peak di siang hari
- **Titik paling panas**: Jumat pukul 18:00 — gabungan commuter + TGIF leisure activity

#### Insight dari Stacked Bar: Time Period

| Time Period | Jam | Kontribusi | Insight |
|-------------|-----|-----------|---------|
| Evening | 16:00–23:59 | **Tertinggi** | Mencakup peak hour 18:00, aktivitas sore/malam |
| Morning | 06:00–11:59 | Tinggi | Mencakup morning commute 08:00 |
| Afternoon | 12:00–15:59 | Moderat | Jam makan siang, working hour |
| Dawn | 00:00–05:59 | **Terendah** | Hampir zero demand, ideal untuk maintenance |
| Night | (jika ada) | Rendah | Demand menurun setelah 22:00 |

---

### Page 3: Weather Impact

Halaman ini mengukur dampak kuantitatif cuaca terhadap demand melalui **4 KPI Cards**, **Scatter Plot** (suhu vs demand), dan **Bar Charts** (per kondisi cuaca, kategori suhu, dan humidity).

#### KPI Cuaca

| Metrik | Nilai | Interpretasi |
|--------|-------|-------------|
| Avg Temperature | **~12.8 °C** | Rata-rata suhu sepanjang tahun (dingin karena ada musim dingin) |
| Rain Impact | **↓ 62.3% vs Clear** | Hujan mengurangi demand hampir dua pertiga |
| Snow Impact | **↓ 78.1% vs Clear** | Salju mengurangi demand hampir empat perlima |
| Optimal Temp Range | **Warm (20–30°C)** | Rentang suhu dengan demand tertinggi |

#### Insight dari Scatter Plot: Suhu vs Demand

Plot seribu titik data mengungkap hubungan **non-linear** antara suhu dan demand:
- **< 0°C (Freezing)**: Demand sangat rendah, banyak observasi mendekati nol
- **0–10°C (Cold)**: Demand mulai meningkat tapi masih rendah
- **10–20°C (Cool)**: Peningkatan signifikan, kurva mulai curam
- **20–30°C (Warm)**: **Zona optimal** — demand mencapai puncak
- **> 30°C (Hot)**: Demand mulai **menurun** — terlalu panas untuk bersepeda

> **Insight**: Hubungan suhu-demand berbentuk **inverted-U** (U terbalik), bukan linear. Terlalu dingin maupun terlalu panas, keduanya menurunkan demand. Sweet spot di 20–30°C.

#### Insight dari Bar Chart: Kondisi Cuaca

| Kondisi Cuaca | Avg Hourly Rentals | Perbandingan |
|---------------|-------------------|-------------|
| **Clear** | Tertinggi | Baseline (100%) |
| **Rainy** | Rendah | ↓ 62.3% dari Clear |
| **Snowy** | Sangat rendah | ↓ 78.1% dari Clear |
| **Rainy & Snowy** | Terendah | ↓ >80% dari Clear |

> **Insight**: Cuaca buruk adalah *demand killer* terbesar. Satu hari hujan menghilangkan lebih dari setengah potensi rental dibanding hari cerah.

#### Insight dari Bar Chart: Kategori Suhu

| Kategori | Avg Rentals | Insight |
|----------|------------|---------|
| **Hot (>30°C)** | Tinggi | Masih tinggi tapi sedikit turun dari Warm |
| **Warm (20–30°C)** | **Tertinggi** | Zona emas — demand puncak |
| **Cool (10–20°C)** | Moderat | Peralihan, masih nyaman |
| **Cold (0–10°C)** | Rendah | Mulai tidak nyaman bersepeda |
| **Freezing (<0°C)** | **Terendah** | Demand hampir nol |

#### Insight dari Bar Chart: Humidity

| Kategori | Avg Rentals | Insight |
|----------|------------|---------|
| **Low (<40%)** | Tinggi | Udara kering + sejuk = nyaman |
| **Moderate (40–60%)** | **Tertinggi** | Titik nyaman humidity |
| **High (60–80%)** | Moderat | Mulai tidak nyaman |
| **Very High (>80%)** | **Terendah** | Gerah/hujan, demand turun signifikan |

> **Insight**: Humidity tinggi (>80%) sering berkorelasi dengan hujan atau cuaca lembab, yang secara bersamaan menekan demand.

---

### Page 4: Operational Intelligence

Halaman ini menyajikan metrik operasional melalui **4 KPI Cards**, **Matrix** (shift × day type), **Donut Chart** (distribusi shift), **Bar Chart** (per day type), dan **Line Chart** (pola jam per musim).

#### KPI Operasional

| Metrik | Nilai | Interpretasi |
|--------|-------|-------------|
| Zero Demand Hours | **295 jam (3.4%)** | Jam-jam tanpa penyewaan — slot maintenance |
| Demand Volatility | **0.915 (Moderate)** | CV < 1.0 = cukup stabil, bisa diprediksi |
| Holiday Impact | **~0.85x** | Holiday lebih rendah 15% dari Working Day |
| Std Deviation | **σ ≈ 532** | Variasi demand cukup besar, perlu buffer armada |

#### Insight dari Matrix: Shift × Day Type

| Shift | Holiday | Non-Functioning | Working Day | Total |
|-------|---------|----------------|-------------|-------|
| Day Shift | 592 | 0 | 759 | 726 |
| Evening Shift | 739 | 0 | 1,112 | 1,058 |
| Night Shift | 257 | 0 | 346 | 330 |
| **Total** | **529** | **0** | **739** | **705** |

**Temuan utama dari Matrix**:
- **Evening Shift × Working Day** = kombinasi dengan demand **tertinggi** (avg 1,112/jam) — slot paling kritis untuk memastikan ketersediaan armada
- **Night Shift** selalu terendah di semua day type — slot terbaik untuk **maintenance**
- **Non-Functioning Days** menghasilkan **0 rental** (layanan tidak beroperasi)
- **Holiday** secara konsisten lebih rendah dari Working Day di semua shift, mengonfirmasi dominasi commuter use

#### Insight dari Donut Chart: Distribusi per Shift

| Shift | % Total Rentals | Insight |
|-------|----------------|---------|
| Evening Shift | **~42%** | Shift terpenting — alokasikan staf terbanyak |
| Day Shift | **~35%** | Kedua terpenting — mencakup morning commute |
| Night Shift | **~23%** | Terendah — bisa dikurangi staf |

#### Insight dari Line Chart: Pola Jam per Musim

4 garis musiman menunjukkan bahwa **pola dasar dual-peak (08:00 & 18:00) konsisten di semua musim**, namun dengan perbedaan amplitudo:
- **Summer**: Amplitudo tertinggi di semua jam — demand tinggi bahkan di jam off-peak
- **Autumn**: Amplitudo kedua tertinggi, mulai menurun di evening
- **Spring**: Amplitudo moderat, morning peak sedikit lebih rendah dari evening
- **Winter**: Amplitudo sangat rendah — pola dual-peak masih ada tapi sangat meredup

> **Insight**: Pola temporal sangat konsisten lintas musim, yang berubah hanyalah **volume** (amplitudo). Ini artinya model distribusi armada cukup menggunakan 1 template pola jam dengan **seasonal multiplier**.

---

### Page 5: Business Recommendations

Halaman interaktif ini memungkinkan eksplorasi data berdasarkan filter (Season, Weather, Day Category) melalui **3 Slicer**, **2 KPI Cards** (revenue), **Tabel rekomendasi per jam**, **Bar Chart** (top hours), dan **Donut Chart** (revenue per season).

#### KPI Revenue

| Metrik | Nilai | Interpretasi |
|--------|-------|-------------|
| Estimated Revenue | **₩9,258.5M** | ~₩9.26 Miliar KRW estimasi revenue tahunan (@ ₩1,500/trip) |
| Revenue Loss Rain | **₩523.4M lost** | Potensi revenue yang hilang akibat hujan |

> Revenue loss dari hujan setara dengan **~5.7% dari total estimasi revenue tahunan**.

#### Insight dari Tabel Rekomendasi per Jam

Tabel ini mengkategorikan setiap jam ke dalam 4 level aksi:

| Level | Jam | Aksi yang Direkomendasikan |
|-------|-----|---------------------------|
| 🔴 Very Low | 00:00 – 05:00 | **Reduce Fleet** — Tarik armada, lakukan maintenance |
| 🟡 Low | 06:00 – 07:00, 21:00 – 23:00 | **Promote/Discount** — Berikan insentif penggunaan |
| 🟢 Moderate | 09:00 – 16:00, 19:00 – 20:00 | **Maintain** — Operasi normal, monitoring |
| 🔵 High | 08:00, 17:00 – 18:00 | **Maximize Supply** — Full armada, prioritas redistribusi |

#### Insight dari Interaksi Slicer

Kekuatan halaman ini terletak pada **interaktivitas**:

| Filter Slicer | Perubahan yang Terlihat |
|---------------|------------------------|
| Season = **Winter** | Semua jam turun ke 🔴/🟡; revenue anjlok |
| Weather = **Rainy** | Avg Hourly turun drastis; revenue loss melonjak |
| Day = **Weekend** | Pola 🔵 High bergeser dari 08:00 & 18:00 ke 14:00–17:00 |
| Summer + Clear + Weekday | **Skenario optimal** — semua metrik di puncak tertinggi |

---

## 3. Jawaban Pertanyaan Strategis

### 📊 Strategic Questions

#### Q1: Kapan demand paling tinggi? → Optimal staffing & bike distribution

**Jawaban**:

Demand paling tinggi terjadi dalam kombinasi kondisi berikut:

| Dimensi | Kondisi Peak |
|---------|-------------|
| **Jam** | 18:00 (puncak absolut), diikuti 08:00 (puncak sekunder) |
| **Hari** | Hari kerja (Senin–Jumat), terutama Rabu dan Jumat |
| **Bulan** | Juni (puncak absolut), diikuti Juli dan Mei |
| **Musim** | Summer (36.99%), diikuti Autumn (29.00%) |
| **Cuaca** | Clear/Cerah, suhu 20–30°C, humidity 40–60% |

**Implikasi untuk Staffing & Distribution**:
- Pada pukul **17:00**, redistribusi armada harus **sudah selesai** — semua stasiun di area perkantoran harus terisi penuh
- Pada pukul **07:00**, pastikan stasiun dekat **stasiun transit** (kereta/bus) memiliki stok cukup
- Di bulan **Juni–Agustus**, tingkatkan jumlah armada aktif sebesar **40–50%** dari baseline musim dingin
- Alokasi staf per shift: Evening (42%), Day (35%), Night (23%)

---

#### Q2: Bagaimana cuaca mempengaruhi penyewaan? → Weather-responsive supply management

**Jawaban**:

Cuaca memiliki dampak **sangat signifikan** dan terukur:

| Kondisi Cuaca | Avg Hourly Demand | % vs Clear | Tindakan |
|---------------|-------------------|-----------|----------|
| **Clear** | Tertinggi (baseline) | 100% | Full operation |
| **Rainy** | Rendah | **37.7%** (turun 62.3%) | Kurangi armada 50%, aktifkan promo indoor |
| **Snowy** | Sangat rendah | **21.9%** (turun 78.1%) | Kurangi armada 75%, prioritas perawatan |

**Faktor cuaca lainnya**:
- **Suhu optimal**: 20–30°C (Warm) — di bawah 0°C demand mendekati nol
- **Humidity optimal**: 40–60% (Moderate) — di atas 80% demand turun signifikan
- **Hubungan non-linear**: Suhu dan demand membentuk kurva U-terbalik

**Strategi Weather-Responsive**:
1. Integrasikan API cuaca real-time untuk prediksi demand H-24
2. Saat prakiraan hujan > 70%, proaktif tarik 50% armada untuk maintenance
3. Saat prakiraan cerah + suhu 20–30°C, deploy 100% armada + siapkan armada cadangan

---

#### Q3: Apakah pola weekday berbeda dengan weekend? → Segment-specific strategies

**Jawaban**: **Ya, sangat berbeda.** Perbedaan ini fundamental dan membutuhkan strategi terpisah.

| Aspek | Weekday | Weekend |
|-------|---------|---------|
| **Pola Demand** | Dual-peak (08:00 & 18:00) | Single-peak (14:00–17:00) |
| **Use Case Utama** | Komuter (rumah ↔ kantor) | Rekreasi (taman, wisata) |
| **Jam Peak** | 08:00 & 18:00 | 14:00–17:00 |
| **Volume Harian** | Lebih tinggi | Lebih rendah (~15% lebih rendah) |
| **Lokasi Demand** | Stasiun transit, kawasan bisnis | Taman, sungai Han, area wisata |

**Strategi Segment-Specific**:

| Strategi | Weekday | Weekend |
|----------|---------|---------|
| **Distribusi Armada** | Pagi: stasiun transit → sore: area kantor | Pagi: area residensial → siang: area wisata |
| **Pricing** | Standard rate (demand tinggi natural) | Diskon siang hari untuk dorong early adoption |
| **Promosi** | Bundling commuter pass bulanan | Paket keluarga/group weekend |
| **Staf** | Fokus di jam 07–09 dan 17–19 | Fokus di jam 12–18 |

---

#### Q4: Musim mana yang paling menguntungkan? → Seasonal revenue planning

**Jawaban**:

| Musim | Est. Revenue | % Total | Profitabilitas |
|-------|-------------|---------|---------------|
| **Summer** | **₩3,424.9M** | 36.99% | ⭐⭐⭐⭐⭐ Tertinggi |
| **Autumn** | **₩2,685.0M** | 29.00% | ⭐⭐⭐⭐ Tinggi |
| **Spring** | **₩2,417.9M** | 26.12% | ⭐⭐⭐ Moderat |
| **Winter** | **₩730.8M** | 7.89% | ⭐ Rendah |

**Seasonal Revenue Strategy**:

| Musim | Strategi |
|-------|---------|
| **Summer** | **Maximize Revenue** — full armada, surge pricing di jam peak, event kolaborasi dengan festival musim panas Seoul |
| **Autumn** | **Sustain Revenue** — pertahankan armada tinggi, mulai diskon akhir November untuk transisi |
| **Spring** | **Growth Push** — kampanye "kembali bersepeda", promosi langganan tahunan |
| **Winter** | **Cost Reduction** — kurangi armada 60–70%, fokus maintenance besar, tawarkan paket gym indoor partnership |

---

#### Q5: Kapan sebaiknya dilakukan maintenance? → Minimize disruption to service

**Jawaban**:

Berdasarkan analisis **Zero Demand Hours** dan **Low Demand Slots**:

**Window Maintenance Harian**:
| Prioritas | Jam | Avg Demand | Zero Demand % | Rekomendasi |
|-----------|-----|-----------|---------------|-------------|
| 🥇 Utama | **03:00 – 05:00** | < 50/jam | > 20% | **Best time** — hampir zero demand |
| 🥈 Sekunder | **01:00 – 02:00** | < 80/jam | > 15% | Masih sangat sepi |
| 🥉 Alternatif | **00:00** & **06:00** | < 100/jam | > 10% | Awal/akhir window |

**Window Maintenance Musiman**:
| Prioritas | Periode | Alasan |
|-----------|---------|--------|
| 🥇 Utama | **Desember – Februari** (Winter) | Demand terendah (7.9%), cuaca membuat banyak hari zero demand |
| 🥈 Overhaul | **Maret – awal April** | Sebelum Spring rush dimulai, persiapan armada |

**Strategi Maintenance**:
1. **Rotational maintenance**: Servis 15–20% armada setiap malam pukul 01:00–05:00
2. **Major overhaul**: Semua armada di-overhaul bertahap selama Desember–Februari
3. **Pre-season check**: Inspeksi total pada akhir Maret, pastikan 100% armada siap untuk April
4. **Weather-triggered maintenance**: Saat prakiraan hujan/salju > 80%, tarik armada dan lakukan servis mendadak

---

### 💰 Revenue Questions

#### Q6: Jam berapa potensi revenue tertinggi? → Dynamic pricing opportunities

**Jawaban**:

| Ranking | Jam | Avg Hourly Rentals | Level | Pricing Opportunity |
|---------|-----|-------------------|-------|-------------------|
| 🥇 | **18:00** | Tertinggi (~1,100+) | 🔵 High | **Surge pricing** +10–15% |
| 🥈 | **08:00** | Tinggi (~800+) | 🔵 High | **Surge pricing** +10% |
| 🥉 | **17:00** | Tinggi (~900+) | 🔵 High | **Surge pricing** +10% |
| 4 | **19:00** | Moderat-Tinggi (~700+) | 🟢 Moderate | Standard rate |
| 5 | **09:00** | Moderat (~600+) | 🟢 Moderate | Standard rate |

**Dynamic Pricing Tiers**:

| Tier | Jam | Harga | Justifikasi |
|------|-----|-------|-------------|
| **⚡ Peak** | 08:00, 17:00–18:00 | ₩2,000/trip (+33%) | Demand inelastic — commuter HARUS berangkat |
| **🟢 Standard** | 09:00–16:00, 19:00–20:00 | ₩1,500/trip (base) | Demand moderat |
| **💚 Discount** | 06:00–07:00, 21:00–23:00 | ₩1,000/trip (-33%) | Stimulasi demand rendah |
| **🌙 Night** | 00:00–05:00 | ₩800/trip (-47%) | Demand sangat rendah, menarik early adopter |

> **Estimasi tambahan revenue dari dynamic pricing**: Jika surge pricing di 3 jam peak menghasilkan +10% revenue di jam tersebut, estimasi tambahan ≈ **₩300–500M/tahun**.

---

#### Q7: Berapa kehilangan revenue saat hujan/salju? → Weather insurance/mitigation costs

**Jawaban**:

| Kondisi | Demand Drop | Total Jam | Est. Revenue Loss |
|---------|------------|-----------|------------------|
| **Rainy** | -62.3% | ~1,200 jam/tahun | **₩523.4M KRW** |
| **Snowy** | -78.1% | ~400 jam/tahun | **₩250–300M KRW** |
| **Total Weather Loss** | — | — | **~₩773–823M KRW** |

**Konteks**: Total weather loss ≈ **8.4–8.9% dari estimasi revenue tahunan**.

**Strategi Mitigasi**:

| Strategi | Est. Recovery | Biaya Implementasi |
|----------|--------------|-------------------|
| **Langganan Bulanan Flat-Rate** | ₩200–300M | Rendah (sistem billing) |
| **Indoor Cycling Partnership** | ₩50–100M | Sedang (kerjasama gym) |
| **Rain Poncho Dispenser** di stasiun | ₩30–50M | Rendah (hardware + stock) |
| **Weather Insurance Product** | ₩100–150M | Sedang (aktuarial) |

> **Rekomendasi utama**: Dorong konversi dari pay-per-trip ke **langganan bulanan (₩30,000–50,000/bulan)**. Subscriber tetap membayar meskipun hujan, mengurangi weather sensitivity pada revenue.

---

#### Q8: Bagaimana pola holiday vs working day? → Special event/holiday pricing

**Jawaban**:

| Tipe Hari | Avg Hourly Demand | Impact Factor | Pola |
|-----------|-------------------|--------------|------|
| **Working Day** | Tertinggi (baseline) | 1.00x | Dual-peak commuter |
| **Holiday** | Lebih rendah | **~0.85x** (-15%) | Single-peak rekreasi (mirip weekend) |
| **Non-Functioning** | 0 | 0x | Layanan tutup |

**Insight**:
- Holiday **bukan** hari dengan demand tinggi — berbeda dengan industri wisata/F&B
- Pola demand holiday **identik dengan weekend** (single-peak di siang hari)
- Ini **mengonfirmasi bahwa layanan ini commuter-driven**, bukan leisure-driven

**Holiday Pricing Strategy**:

| Strategi | Detail |
|----------|--------|
| **Jangan surge pricing di Holiday** | Demand sudah rendah, surge akan mengurangi lebih lanjut |
| **Holiday Special Promo** | Diskon 20–30% untuk menarik pengguna rekreasi |
| **Event-based Marketing** | Kolaborasi dengan event musiman (Cherry Blossom di Spring, Han River Festival di Summer) |
| **Family/Group Package** | Tarif spesial untuk kelompok 3+ orang saat Holiday |

---

### 🔧 Operational Questions

#### Q9: Berapa banyak sepeda minimal dibutuhkan per jam? → Fleet sizing

**Jawaban**:

Berdasarkan data Peak Hourly Demand dan distribusi per jam:

| Skenario | Basis Perhitungan | Min. Fleet Size |
|----------|-------------------|----------------|
| **Average Hour** | Avg hourly = 705 | **~800 sepeda** (buffer 13%) |
| **Peak Hour (18:00)** | Peak avg ~1,100 | **~1,300 sepeda** (buffer 18%) |
| **Absolute Peak Day** | Max hourly = 3,556 | **~4,000 sepeda** (buffer 12%) |
| **Summer Peak** | Avg hourly Summer = ~900 | **~1,050 sepeda** |
| **Winter Low** | Avg hourly Winter = ~300 | **~350 sepeda** |

**Fleet Sizing Recommendation**:

| Musim | Armada Aktif | % dari Total | Sisa di Maintenance/Storage |
|-------|-------------|-------------|---------------------------|
| **Summer** | **1,300** sepeda | 100% | 0% |
| **Autumn** | **1,100** sepeda | 85% | 15% dalam maintenance |
| **Spring** | **1,000** sepeda | 77% | 23% dalam maintenance |
| **Winter** | **500** sepeda | 38% | 62% dalam overhaul |

> **Total armada yang direkomendasikan: ~1,300–1,500 sepeda** (memperhitungkan yang sedang dalam rotasi maintenance).

---

#### Q10: Di jam berapa redistribusi sebaiknya dilakukan? → Logistics optimization

**Jawaban**:

Berdasarkan pola demand dan transisi antar peak:

| Window | Jam | Durasi | Tujuan Redistribusi |
|--------|-----|--------|-------------------|
| **Pre-Morning Rush** | **05:00 – 06:30** | 1.5 jam | Dari area residensial → stasiun transit & perkantoran |
| **Midday Rebalance** | **10:00 – 11:00** | 1 jam | Dari stasiun transit → area perkantoran (commuter sudah sampai) |
| **Pre-Evening Rush** | **15:00 – 16:30** | 1.5 jam | Dari area perkantoran → stasiun transit (siap untuk pulang) |
| **Night Recall** | **22:00 – 00:00** | 2 jam | Kumpulkan armada yang tersebar → hub utama |

**Redistribusi Logic per Fase**:

```
05:00–06:30  [Residensial] ──────→ [Stasiun Transit] + [Kantor]
             "Stok untuk morning commute"

10:00–11:00  [Stasiun Transit] ──→ [Kantor/Kampus Area]
             "Commuter sudah sampai, redistribute sisa"

15:00–16:30  [Kantor/Kampus] ────→ [Stasiun Transit] + [Residensial]
             "Stok untuk evening commute home"

22:00–00:00  [Semua titik] ──────→ [Hub Utama]
             "Konsolidasi + rotasi maintenance"
```

**Weekend Redistribusi (berbeda)**:
```
09:00–10:00  [Residensial] ──────→ [Taman] + [Area Wisata]
             "Stok untuk leisure activity"

18:00–19:00  [Taman/Wisata] ─────→ [Residensial] + [Hub]
             "Konsolidasi akhir hari"
```

---

## 4. Rekomendasi Akhir

### Prioritas Implementasi (Impact vs Effort Matrix)

| Prioritas | Inisiatif | Impact | Effort | Timeline |
|-----------|----------|--------|--------|----------|
| 🥇 | **Dynamic Pricing** (peak/off-peak) | ⭐⭐⭐⭐⭐ | ⭐⭐ | 1–2 bulan |
| 🥇 | **Weather-responsive Fleet Management** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 2–3 bulan |
| 🥈 | **Langganan Bulanan (Subscription)** | ⭐⭐⭐⭐ | ⭐⭐ | 1–2 bulan |
| 🥈 | **Redistribusi Armada Berbasis Waktu** | ⭐⭐⭐⭐ | ⭐⭐⭐ | 3–4 bulan |
| 🥉 | **Weekend Leisure Campaign** | ⭐⭐⭐ | ⭐ | 1 bulan |
| 🥉 | **Seasonal Fleet Rotation** | ⭐⭐⭐ | ⭐⭐ | Ongoing |

### Estimasi Dampak Finansial

| Inisiatif | Est. Revenue Impact /tahun |
|-----------|--------------------------|
| Dynamic Pricing | +₩300–500M |
| Subscription Model | +₩200–300M (stabilitas) |
| Weather Mitigation | +₩100–200M (recovered) |
| Weekend Campaign | +₩50–100M |
| **Total Potential Uplift** | **+₩650M – ₩1.1B KRW** |

> **Bottom Line**: Implementasi seluruh rekomendasi berpotensi meningkatkan revenue sebesar **7–12% dari baseline**, dari ~₩9.26B menjadi **~₩9.9B – ₩10.36B KRW per tahun**.

---

*End of Report*
