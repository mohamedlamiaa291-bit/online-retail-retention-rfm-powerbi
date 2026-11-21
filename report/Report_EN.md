# Customer Retention & RFM Segmentation — Report

**Tool:** Power BI (Power Query, DAX) · **Data:** Online Retail II, UCI (CC BY 4.0) · **Period:** 1 Dec 2009 – 9 Dec 2011

## 1. Objective

A retailer usually knows how much it sold, but not which customers keep coming back, which ones are fading, and which groups deserve marketing money. This project answers three questions:

1. What share of customers buy again, and how does that change over time?
2. Which customers produce most of the revenue?
3. What should the business do about each customer group?

## 2. Data and preparation

The dataset covers every transaction of a UK-based online gift-ware retailer. Many of its customers are wholesalers.

- Rows without a Customer ID were removed because they cannot be followed over time (1,067,371 rows in the UCI dataset → 824,364 rows used).
- Invoices starting with "C" are cancellations. They were flagged as returns, not deleted, and excluded from revenue, orders and customer counts.
- Rows with zero or negative quantity or price were excluded from the same figures.
- Headline figures (returns excluded): revenue £17.74M, about 37K orders, 5,878 customers.

## 3. Method

**Cohort retention.** Each customer is assigned to the month of their first purchase. For every later month we measure the share of that cohort that bought again. The measure is *not cumulative*: it answers "how many of the cohort were active in month N".

**RFM segmentation.** For each customer, as of 10 Dec 2011: Recency (days since last purchase), Frequency (distinct invoices) and Monetary (total spend). Each is scored 1–5 (quintiles for Recency and Monetary; fixed thresholds for Frequency: 1, 2, 3–4, 5–8, 9+). Customers are then placed in six segments by rules on the R and F scores (see README). The rules are the author's own and were not validated against an external benchmark.

## 4. Findings

### 4.1 Retention

- In the matrix's Total row, about **23% of a cohort buys again in month 1** (22.89%). The share stays between roughly 17% and 25% through month 11, and is **19.24% in month 12**. Repeat buying looks like a stable core rather than a fast-fading tail.
- **Cohorts differ a lot.** Dec 2009 is the strongest (35.29% in month 1, 42.51% in month 3, 49.53% in month 11). Dec 2010 is the weakest (9.21% in month 1, 5.26% in month 2).
- *Hypotheses, not tested:* the Dec 2009 cohort contains customers who already existed before the data starts, so it is not a true "new customer" cohort. The Dec 2010 cohort may be dominated by seasonal gift buyers. Revenue also peaks in November of both years, which fits a seasonal business.

### 4.2 Segmentation

| Segment | Customers | Customer share | Revenue share | Avg recency (days) | Avg orders |
|---|---:|---:|---:|---:|---:|
| Champions | 1,407 | 23.94% | 68.70% | 20.3 | 16.25 |
| Loyal | 1,200 | 20.42% | 14.67% | 77.9 | 5.64 |
| New / Recent | 504 | 8.57% | 2.40% | 27.9 | 1.53 |
| Need Attention | 424 | 7.21% | 1.28% | 109.0 | 1.42 |
| At Risk | 704 | 11.98% | 8.79% | 362.5 | 5.43 |
| Lost | 1,639 | 27.88% | 4.16% | 457.0 | 1.31 |

- **Revenue is concentrated.** Champions are about a quarter of customers and about 69% of revenue (roughly £12.2M). Champions + Loyal are 44.4% of customers and 83.4% of revenue.
- **The Lost segment is the largest by headcount (27.9%) but generates 4.2% of revenue**, so heavy spending to reactivate it is hard to justify.
- **At Risk is the most valuable group to target for win-back:** 704 customers who averaged 5.4 orders but have been silent for about a year, representing 8.8% of historical revenue (about £1.6M). That is past revenue, not a forecast. Some of them may be seasonal buyers rather than churned customers.

## 5. Recommendations

| Segment | Action |
|---|---|
| Champions | Protect first: early access, loyalty perks, ask for reviews and referrals |
| Loyal | Increase basket size: bundles, cross-sell, a loyalty program |
| New / Recent | Secure the second purchase: welcome email and an offer within 30 days |
| Need Attention | Light nudges: reminder emails, limited-time offers |
| At Risk | Run a personalized win-back campaign, and test it on a small group before scaling |
| Lost | Low-cost reactivation only (e.g., a single email); do not over-invest |

Suggested next step: run the At Risk campaign as an A/B test (contacted vs. not contacted) and compare repurchase rates after 30–60 days. The dashboard cannot tell us whether the campaign works; only a test can.

## 6. Limitations

- Customers without an ID are excluded; results describe identified customers only.
- Left-censoring: the data starts in Dec 2009, so first purchases in that month are not necessarily first-ever purchases.
- Many customers are wholesalers; patterns may not hold for a consumer store.
- Cohorts from Jul 2011 onward and months beyond 12 are not shown because follow-up is short and the numbers become unstable.
- Revenue excludes returns, so it is gross of returns.
- Segment thresholds are heuristic; different thresholds would change the segment sizes.
- The analysis describes behavior, not causes.

## 7. Tools

Power BI Desktop · Power Query (M) · DAX · cohort analysis · RFM segmentation.
