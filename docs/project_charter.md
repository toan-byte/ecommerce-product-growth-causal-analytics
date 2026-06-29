# Project Charter: E-Commerce Product Growth & Causal Analytics

**Author:** Xuan Toan  
**Role Simulation:** Product Data Analyst / Analytics Engineer  
**Project Type:** Portfolio Flagship Case Study  
**Status:** Completed (Production-Ready)  

---

## 1. Project Overview
This flagship project aims to analyze a large-scale e-commerce clickstream dataset (~68 million user events, November 2019) to identify the root causes behind a critical business anomaly: **a surge in traffic that failed to translate into proportional revenue growth.**

The project simulates the role of a Product Data Analyst working closely with Product Managers and C-Suite Stakeholders. It combines modern data engineering (dbt + DuckDB), exploratory product analytics, cohort retention modeling, and advanced causal inference (Difference-in-Differences) to deliver boardroom-ready business diagnostics and actionable growth experiments.

---

## 2. Business Problem & Context
The e-commerce platform experienced a significant divergence in key growth indicators over the analyzed period:
* **Website Traffic (Sessions):** Increased by approximately **+35%**
* **Total Revenue:** Increased by only **+2%**

This raises critical business questions for the executive team:
1. Where are users dropping off in the customer journey?
2. Which specific product categories and customer segments are underperforming?
3. What is the root cause preventing traffic growth from driving revenue?
4. How can we quantify the financial damage of recent policy changes?
5. Which product initiatives and A/B tests should the business prioritize?

---

## 3. Project Objectives
1. **Local MDS Pipeline:** Build a high-performance, zero-cost local Data Lakehouse using Parquet, DuckDB, and dbt-duckdb.
2. **Data Governance & Quality:** Implement robust data auditing, dynamic bot filtering (P99 velocity), and surrogate key generation at the staging layer.
3. **Funnel Diagnosis:** Map the end-to-end user journey (View → Cart → Purchase) to locate the exact conversion leakage points.
4. **Cohort & Retention Analysis:** Measure weekly user retention decay curves and identify the product's "Aha Moment."
5. **Customer Value Segmentation:** Segment the active user base using an RFM (Recency, Frequency, Monetary) matrix to find recoverable revenue.
6. **Causal Impact Validation:** Isolate and measure the exact causal effect of the November 15 shipping fee change on conversion rates using Difference-in-Differences (DiD).
7. **Strategic Growth Roadmap:** Translate statistical findings into a prioritized Experiment Backlog and an interactive Power BI Executive Dashboard.

---

## 4. North Star Metric & Key KPI Framework

### North Star Metric: Revenue per Session
* **Formula:** `Revenue per Session = [Total Revenue] / [Total Sessions]`
* **Justification:** This metric directly measures the commercial monetization efficiency of user traffic. When traffic surges by +35% but Revenue per Session plummets (by -24% in our case), it mathematically proves that either traffic quality has diluted or a massive conversion friction point has been introduced.

### Key KPI Framework:
* **Volume Metrics:** `Total Revenue`, `Total Sessions`, `Total Users`, `Total Purchases`, `Total Carts`.
* **Efficiency Metrics:** `Conversion Rate` (Sessions-to-Purchase), `Revenue per User (ARPU)`.
* **Leakage Metrics:** `Cart Recovery Rate` (Purchases / Carts), `Cart Abandonment Rate` (1 - Recovery Rate).

---

## 5. Dataset Specification
* **Type:** Large-Scale E-Commerce Clickstream Log
* **Time Range:** November 1, 2019 – November 30, 2019 (Peak shopping season)
* **Approximate Size:** 67.5 Million Records (8.39 GB raw CSV compressed to ~1.2 GB Parquet)
* **Core Schema Fields:** `event_time`, `event_type` (view, cart, purchase), `user_id`, `user_session`, `product_id`, `category_id`, `category_code`, `brand`, `price`.

---

## 6. Technology Stack
* **Storage & Local Query Engine:** DuckDB (Local column-store database file)
* **Transformation & Modeling:** dbt-duckdb (Staging, Intermediate, and Mart layers)
* **Statistical Modeling:** Python (`statsmodels`, `pandas`, `pyarrow`)
* **Interactive Visualization:** Power BI Desktop (Parquet direct import)
* **Version Control & Documentation:** Git, GitHub, dbt Docs

---

## 7. Project Scope

### Included:
* Dynamic P99 bot traffic filtering and custom multi-entropy MD5 surrogate keys.
* Reconstructing raw clickstream logs into clean, sessionized analytical tables.
* Pre-calculating weekly cohort retention rates and RFM segments (ntile-5 scoring).
* Running a full Difference-in-Differences (DiD) OLS regression in Python and validating the parallel trends assumption.
* Designing a 5-page interactive dark-mode Power BI dashboard with dynamic bookmarks, cross-filtering, and What-if simulation parameters.

### Excluded:
* Machine Learning predictive models (Focus remains on causal inference and business diagnostics).
* Real-time streaming data ingestion.
* Cloud warehouse hosting (BigQuery/Snowflake) to preserve zero-cost local architecture.

---

## 8. Expected Deliverables

### Analytics Assets
* **Jupyter Notebooks:** `02_exploratory_analysis.py`, `03_business_insights.py`, `04_causal_analytics.py`.
* **dbt DAG Models:** 3 staging views, 4 intermediate tables, and 5 reporting marts.

### 5-Page Interactive Dashboard (Power BI)
* **Page 1: Executive Command Center** (Core KPIs, revenue-traffic divergence line chart, top brands, and C-Suite critical alert panel).
* **Page 2: Funnel Diagnosis** (View → Cart → Purchase funnel, category conversion leakage matrix with dynamic "Red Alert" formatting).
* **Page 3: Retention & Cohort** (Matrix cohort heatmap, weekly retention decay curves, and retention opportunity table).
* **Page 4: Customer Segmentation (RFM)** (Interactive RFM bubble chart, revenue treemap, and the $119M recoverable revenue opportunity table controlled by a What-if slider).
* **Page 5: Causal Analytics (DiD)** (DiD line trend with Raw vs. Base-100 toggle, parallel trend validation card, OLS stats table, and growth experiment backlog).

---

## 9. Success Criteria
* Successfully isolate and quantify the causal impact of the Nov 15 shipping fee change on conversion rate with at least 95% statistical confidence.
* Identify the highest-value leaking customer segment and calculate its exact recoverable revenue potential.
* Deliver an end-to-end dbt lineage DAG with 100% of staging schema tests (`unique`, `not_null`, `accepted_values`) passed.
* Create a cohesive, dark-theme dashboard that uses bookmarks and sliders to deliver an application-like user experience.