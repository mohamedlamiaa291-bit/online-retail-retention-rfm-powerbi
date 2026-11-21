# DAX reference

Everything below is what the report uses. Table and column names match the PBIX.
"Valid sale" = not a return, quantity > 0, price > 0.

## Calendar (calculated table)

```dax
Calendar =
ADDCOLUMNS(
    CALENDAR(DATE(2009,12,1), DATE(2011,12,31)),
    "Year", YEAR([Date]),
    "MonthNum", MONTH([Date]),
    "Month", FORMAT([Date], "MMM yyyy"),
    "YearMonth", YEAR([Date]) * 100 + MONTH([Date])
)
```

Mark as date table on `[Date]`. Sort `Month` by `YearMonth`.
Relationship: `Sales[InvoiceDay]` (many) → `Calendar[Date]` (one), single direction.

## Sales — calculated columns (cohort logic)

```dax
First Purchase Date =
CALCULATE(
    MIN(Sales[InvoiceDay]),
    ALLEXCEPT(Sales, Sales[Customer ID]),
    Sales[IsReturn] = FALSE()
)
```

```dax
Cohort Month = DATE(YEAR(Sales[First Purchase Date]), MONTH(Sales[First Purchase Date]), 1)
```

```dax
Month Index =
DATEDIFF(
    Sales[Cohort Month],
    DATE(YEAR(Sales[InvoiceDay]), MONTH(Sales[InvoiceDay]), 1),
    MONTH
)
```

## Core measures

```dax
Total Revenue =
CALCULATE(SUM(Sales[Revenue]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0)

Orders =
CALCULATE(DISTINCTCOUNT(Sales[Invoice]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0)

Customers =
CALCULATE(DISTINCTCOUNT(Sales[Customer ID]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0)

AOV = DIVIDE([Total Revenue], [Orders])

Return Value = -CALCULATE(SUM(Sales[Revenue]), Sales[IsReturn] = TRUE())

Return Rate = DIVIDE([Return Value], [Total Revenue])
```

## Retention measures

```dax
Cohort Size =
CALCULATE([Customers], REMOVEFILTERS(Sales[Month Index]), Sales[Month Index] = 0)

Retention % = DIVIDE([Customers], [Cohort Size])
```

Matrix: rows = `Sales[Cohort Month]`, columns = `Sales[Month Index]`, values = `[Retention %]`.
Visual filters: `Cohort Month` before 1 Jul 2011, `Month Index` ≤ 12.

## RFM

Snapshot date: 10 Dec 2011 (the day after the last transaction).

```dax
RFM Customers =
FILTER(
    ADDCOLUMNS(
        VALUES(Sales[Customer ID]),
        "Last Purchase",
            CALCULATE(MAX(Sales[InvoiceDay]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0),
        "Frequency",
            CALCULATE(DISTINCTCOUNT(Sales[Invoice]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0),
        "Monetary",
            CALCULATE(SUM(Sales[Revenue]), Sales[IsReturn] = FALSE(), Sales[Quantity] > 0, Sales[Price] > 0)
    ),
    [Frequency] > 0
)
```

Calculated columns on `RFM Customers`:

```dax
Recency = DATEDIFF([Last Purchase], DATE(2011,12,10), DAY)
```

```dax
R Score =
VAR p20 = PERCENTILE.INC('RFM Customers'[Recency], 0.2)
VAR p40 = PERCENTILE.INC('RFM Customers'[Recency], 0.4)
VAR p60 = PERCENTILE.INC('RFM Customers'[Recency], 0.6)
VAR p80 = PERCENTILE.INC('RFM Customers'[Recency], 0.8)
RETURN
SWITCH(TRUE(),
    [Recency] <= p20, 5,
    [Recency] <= p40, 4,
    [Recency] <= p60, 3,
    [Recency] <= p80, 2,
    1)
```

```dax
M Score =
VAR p20 = PERCENTILE.INC('RFM Customers'[Monetary], 0.2)
VAR p40 = PERCENTILE.INC('RFM Customers'[Monetary], 0.4)
VAR p60 = PERCENTILE.INC('RFM Customers'[Monetary], 0.6)
VAR p80 = PERCENTILE.INC('RFM Customers'[Monetary], 0.8)
RETURN
SWITCH(TRUE(),
    [Monetary] <= p20, 1,
    [Monetary] <= p40, 2,
    [Monetary] <= p60, 3,
    [Monetary] <= p80, 4,
    5)
```

```dax
F Score =
SWITCH(TRUE(),
    [Frequency] = 1, 1,
    [Frequency] = 2, 2,
    [Frequency] <= 4, 3,
    [Frequency] <= 8, 4,
    5)
```

```dax
Segment =
VAR R = 'RFM Customers'[R Score]
VAR F = 'RFM Customers'[F Score]
RETURN
SWITCH(TRUE(),
    R >= 4 && F >= 4, "Champions",
    R >= 3 && F >= 3, "Loyal",
    R >= 4 && F <= 2, "New / Recent",
    R <= 2 && F >= 3, "At Risk",
    R <= 2 && F <= 2, "Lost",
    "Need Attention")
```

```dax
Recommended Action =
SWITCH('RFM Customers'[Segment],
    "Champions", "Reward: early access, loyalty perks, ask for reviews and referrals",
    "Loyal", "Upsell: bundles, cross-sell, loyalty program",
    "New / Recent", "Onboard: welcome email and a second-purchase offer within 30 days",
    "Need Attention", "Nudge: reminder emails and a limited-time offer",
    "At Risk", "Win back: personalized offer and a we-miss-you campaign",
    "Lost", "Low-cost reactivation only, don't over-invest",
    "")
```

Segment measures:

```dax
Segment Customers = COUNTROWS('RFM Customers')
Segment Revenue   = SUM('RFM Customers'[Monetary])
Customer Share    = DIVIDE([Segment Customers], CALCULATE([Segment Customers], ALL('RFM Customers')))
Revenue Share     = DIVIDE([Segment Revenue],   CALCULATE([Segment Revenue],   ALL('RFM Customers')))
Avg Recency (days) = AVERAGE('RFM Customers'[Recency])
Avg Orders         = AVERAGE('RFM Customers'[Frequency])
```

Note: quintile scores on Recency and Monetary can be uneven when many customers share the same value.
