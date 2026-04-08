# Drone Attacks in Pakistan — SQL Analysis Project

A end-to-end SQL project covering data cleaning, transformation, and exploratory analysis of drone strike incidents in Pakistan. The dataset spans attacks from the **George Bush era through the Donald Trump administration**, covering regions primarily in **KPK (Khyber Pakhtunkhwa)**.

---

## Project Structure

```
drone-attacks-pakistan-sql/
│
├── DroneAttackProject.sql     ← Full project: cleaning + analysis queries
└── README.md
```

---

## Dataset Overview

The dataset contains records of drone strikes with the following key columns:

| Column | Description |
|--------|-------------|
| `Date` | Date of the strike |
| `Time` | Time of the strike |
| `City` | City where the strike occurred |
| `Province` | Province (all normalized to KPK) |
| `No_of_Strike` | Number of strikes in the event |
| `Al_Qaeda` | Al-Qaeda casualties |
| `Taliban` | Taliban casualties |
| `Civilians_Min/Max` | Civilian death range |
| `Total_Died_Min/Max` | Total death range |
| `Injured_Min/Max` | Injury range |
| `Women_Children` | Women & children affected |
| `Longitude / Latitude` | Geolocation of strike |
| `Temperature_C` | Temperature at time of strike |
| `Source_Name` | Reporting channel/source |

---

## Data Cleaning Steps

The raw dataset had several issues that were fixed before any analysis:

**1. Column Name Fix**
The first column had an encoding issue (`ï»¿S_No`) caused by a BOM character in the CSV — renamed it cleanly to `S.No`.

**2. Province Standardization**
FATA (Federally Administered Tribal Areas) was merged into KPK by the Pakistani government, so all `fata` values were updated to `kpk`. Province values were also normalized to uppercase for consistency.

**3. Date & Time Conversion**
- `Date` column was stored as text — converted using `STR_TO_DATE()` with 4-digit year format (`%m/%d/%Y`) and altered to proper `DATE` type.
- `Time` column was stored as text — converted using `STR_TO_DATE()` with AM/PM format (`%h:%i:%s %p`).
- Timestamps that imported as `00:00:00` were replaced with `NULL` (verified against original data — these were not genuine midnight strikes).

**4. Handling -1 Sentinel Values**
During import, NULLs in integer columns were replaced with `-1` to avoid import errors. These were reverted back to `NULL` after import.

**5. Backup Table Strategy**
A working copy (`droneattacks72`) was created from the cleaned original (`droneattacks7`) so the raw data was preserved as a backup throughout cleaning.

**6. Derived Average Columns Added**

Rather than working with inconsistent min/max ranges, three new calculated columns were added:

```sql
avg_civilians_died = ROUND((civilians_min + civilians_max) / 2)
avg_died           = ROUND((total_died_min + total_died_max) / 2)
avg_injured        = ROUND((injured_min + injured_max) / 2)
avg_foreigners_died = ROUND((foreigners_min + foreigners_max) / 2)
```

`COALESCE()` was used to treat NULLs as 0 in calculations.

---

## 🔍 Analysis Queries

### 1. Strikes by U.S. Presidential Administration
A `Tenure` column was added to classify each strike under the president in office at the time:

| President | Period |
|-----------|--------|
| George Bush | Before Jan 20, 2009 |
| Barack Obama | Jan 20, 2009 – Jan 20, 2017 |
| Donald Trump | Jan 20, 2017 – Jan 20, 2021 |

```sql
SELECT tenure, SUM(No_Of_Strike) AS Total_Strikes
FROM droneattacks
GROUP BY tenure;
```

### 2. Most Strikes in a Single Day
```sql
SELECT date, No_of_Strike, avg_civilians_died
FROM droneattacks
GROUP BY date, No_of_Strike, avg_civilians_died
ORDER BY No_of_Strike DESC;
```

### 3. Deadliest Single Strike on Civilians
```sql
SELECT Date, tenure, No_Of_Strike, city, avg_civilians_died
FROM droneattacks
WHERE avg_civilians_died = (SELECT MAX(avg_civilians_died) FROM droneattacks);
```

### 4. Most Strikes by City
```sql
SELECT city, SUM(No_Of_Strike) AS strikes
FROM droneattacks
GROUP BY city
ORDER BY strikes DESC;
```

### 5. Strikes Where Only Deaths Occurred (No Injuries)
These are potentially direct-impact casualties with no survivors — a marker of strike precision or close-range hits.
```sql
SELECT * FROM droneattacks
WHERE (Total_Died_Min > 0 AND Total_Died_Max > 0)
AND (injured_min = 0 AND injured_max = 0);
```

### 6. Strikes Involving Women & Children (Human Rights Concern)
```sql
SELECT * FROM droneattacks
WHERE Women_Children = -1;
```

### 7. Best Reported Source Channel
```sql
SELECT source_Name, COUNT(source_Name) AS Reports
FROM droneattacks
GROUP BY source_Name
ORDER BY Reports DESC;
```

### 8. Night-time Strikes (After 7 PM)
```sql
SELECT SUM(No_of_Strike), SUM(avg_civilians_died)
FROM droneattacks
WHERE Time BETWEEN '19:00:00' AND '5:00:00'
GROUP BY No_of_Strike, avg_civilians_died
ORDER BY SUM(avg_civilians_died) DESC;
```

---

## 🛠️ Tools Used

- **MySQL** — All querying, cleaning, and transformation
- **Power BI** *(planned)* — Dashboard and visualization layer

---

## ▶️ How to Run

1. Open MySQL Workbench (or any MySQL client)
2. Create a new schema: `CREATE SCHEMA sql_store;`
3. Import your raw CSV into a table named `droneattacks7`
4. Run `DroneAttackProject.sql` from top to bottom

> **Note:** Disable safe update mode before running UPDATE statements:
> ```sql
> SET sql_safe_updates = 0;
> ```

---

## 💡 Key Takeaways

- The **Obama administration** had the highest number of drone strikes in Pakistan based on this dataset
- Most strikes were concentrated in **KPK** (which includes the former FATA regions like North and South Waziristan)
- A significant portion of strikes have **no recorded time**, suggesting intelligence gaps in reporting
- Several strikes show **zero injuries with confirmed deaths**, which may indicate high-precision or close-range strikes
- The dataset relies on **media and NGO sources**, so numbers represent reported estimates, not verified official figures

---

## ⚠️ Data Disclaimer

This dataset is taken from the Kaggle.
