# Data

## Source dataset (not included in this repository)

**Online Retail II** — UCI Machine Learning Repository
https://archive.ics.uci.edu/dataset/502/online+retail+ii

- Transactions of a UK-based, registered, non-store online retailer, 1 Dec 2009 – 9 Dec 2011.
- 1,067,371 rows. The company mainly sells all-occasion gift-ware; many customers are wholesalers.
- Unit prices are in sterling (GBP).
- Citation: Chen, D. (2012). *Online Retail II* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D
- License: CC BY 4.0 (sharing and adaptation allowed with appropriate credit).

The raw file is large (about 44 MB as XLSX), so it is not stored here. Download it from the link above.
`dashboard/online_retail_retention.pbix` contains an imported copy of the data, attributed as above.

## Summary tables in this folder

These are exported from the dashboard and derived from the dataset above.

| File | Content |
|---|---|
| `rfm_segment_summary.csv` | One row per RFM segment: customers, shares, average recency and orders, recommended action |
| `cohort_retention_matrix.csv` | Retention % by cohort month (rows) and months since first purchase 0–12 (columns) |
| `cohort_retention_long.csv` | The same matrix in long format (one row per cohort and month) |

Notes:
- Cohorts shown: Dec 2009 – Jun 2011. Later cohorts are excluded because of limited follow-up.
- Empty cells mean the cohort has not reached that month within the data.
- Retention % is the share of a cohort's customers who purchased in that month (not cumulative).
- Averages in `rfm_segment_summary.csv` are rounded (recency to 1 decimal, orders to 2).
- No customer-level data is included.
