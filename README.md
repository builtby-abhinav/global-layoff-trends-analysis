# Global Layoffs Trend Analysis

End-to-end SQL + Power BI analysis of **384K+ layoffs across 2K+ companies** worldwide — exploring how workforce reductions varied by time, industry, country, and company funding stage.

---

## Dashboard Preview

![Global Layoffs Dashboard](Global%20Layoffs%20dashboard%20image.jpg)

---

## Key Metrics

| Metric | Value |
|---|---:|
| Total Layoffs | **384K** |
| Companies Affected | **2K** |
| Average Workforce Cut | **26%** |
| Total Funds Raised by Affected Companies | **$1.60T** |

---

## Questions This Project Answers

- How did global layoff volume trend over time?
- Which companies and industries were hit hardest?
- Which countries saw the most layoffs?
- Does funding stage (Series A vs. IPO vs. Public, etc.) correlate with layoff severity?

---

## Workflow

**1. Data Cleaning** (`DATA_CLEANING_LAYOFFS.sql`)
Removed duplicates, standardized inconsistent company/industry/country naming, handled missing values, and corrected data types to prepare the raw dataset for analysis.

**2. Exploratory Data Analysis** (`EDA_LAYOFFS.sql`)
Queried the cleaned data across year, company, industry, country, and funding stage to surface layoff patterns and trends.

**3. Power BI Dashboard** (`Global Layoffs Analysis.pbix`)
Built an interactive dashboard with KPI cards, top-company/country breakdowns, and a funding-stage comparison view.

---

## Key Findings

- The United States recorded the highest total layoffs among all countries in the dataset.
- Layoffs spiked sharply in the later part of the analyzed period, rather than trending evenly.
- Layoff severity did not scale predictably with funding stage — well-funded, late-stage companies were not immune.
- *Note: 2023 data only covers January–March, so year-over-year comparisons for 2023 are partial.*

---

## Tools

| Tool | Purpose |
|---|---|
| SQL | Data cleaning and exploratory analysis |
| Power BI | Dashboard development and visualization |
| CSV | Raw data source |

---

## Repository Structure

global-layoff-trends-analysis/
├── DATA_CLEANING_LAYOFFS.sql # Data cleaning queries
├── EDA_LAYOFFS.sql # Exploratory analysis queries
├── Global Layoffs Analysis.pbix # Power BI dashboard
├── Global Layoffs dashboard image.jpg
├── Global_layoffs (raw data).csv # Raw dataset
└── README.md


---

## Skills Demonstrated

Data Cleaning · SQL · Exploratory Data Analysis · Power BI · Dashboard Design · Data Visualization · Data Interpretation

---

## How to Explore

1. Review the raw dataset: `Global_layoffs (raw data).csv`
2. Open `DATA_CLEANING_LAYOFFS.sql` to see the cleaning process.
3. Open `EDA_LAYOFFS.sql` to review the exploratory queries.
4. Open `Global Layoffs Analysis.pbix` in Power BI Desktop to explore the interactive dashboard.

---

## Author

**Abhinav Chinthakayala**
Aspiring Data Analyst focused on turning raw data into clear, decision-ready insights using SQL and Power BI.

[LinkedIn](https://www.linkedin.com/in/abhinav-chinthakayala-profile/) · [GitHub](https://github.com/builtby-abhinav)
