# Supply Chain & Demand Analytics — SQL Portfolio Project

![Dashboard Preview](dashboard/Supply_Chain_Demand_Analytics_Dashboard.png)

## Project Overview

This project analyses a supply chain dataset using **MySQL** to uncover insights across four business areas: product performance, supplier reliability, warehouse efficiency, and inventory management. The SQL analysis was built to complement and validate an **Excel dashboard** built separately — demonstrating the same business questions answered across two tools.

**Dataset:** 38 rows × 15 columns covering January–February 2024  
**Database:** MySQL 8.0 · Schema: `supply_chain_db` · Table: `supply_chain`  
**Tools used:** MySQL Workbench · Microsoft Excel

---

## Business Questions Answered

| # | Question | Category |
|---|----------|----------|
| 1 | Which products generate the most revenue, profit, and sales volume? | Product Performance |
| 2 | Which supplier is fastest and most reliable for delivery? | Supplier Reliability |
| 3 | Which products have the largest inventory gaps? | Inventory Efficiency |
| 4 | Which warehouse locations are most profitable? | Warehouse Performance |
| 5 | What is each supplier's order fulfilment rate? | Supplier Reliability |
| 6 | Which products are most cost-efficient per euro spent? | Product Performance |
| 7 | How does supplier performance vary by product category? | Supplier Reliability |
| 8 | How does actual demand (units sold) compare to supply (units ordered)? | Inventory Efficiency |
| 9 | Which warehouse-product combinations rank highest in revenue? | Warehouse Performance |
| 10 | What is the overall business health summary? | Executive Summary |

---

## Dataset Columns

| Column | Description |
|--------|-------------|
| `Date` | Transaction date |
| `Product_Type` | Battery, EV Charger, Heat Pump, Solar Panel |
| `Supplier` | Supplier A, B, or C |
| `Warehouse_Location` | Berlin, Cologne, Frankfurt, Hamburg, Munich |
| `Inventory_Level` | Stock on hand at time of transaction |
| `Units_Ordered` | Units ordered from supplier |
| `Units_Delivered` | Units actually delivered |
| `Delivery_Time` | Days taken to deliver |
| `Units_Sold` | Units sold to customers |
| `Price_per_Unit` | Selling price per unit (€) |
| `Revenue` | Total revenue (Units_Sold × Price_per_Unit) |
| `Cost_per_Unit` | Cost price per unit (€) |
| `Total_Cost` | Total cost (Units_Sold × Cost_per_Unit) |
| `Inventory_gap` | Difference between inventory level and units sold |
| `Profit` | Revenue minus Total_Cost |

---

## SQL Queries & Results

### Query 1 — Product Revenue, Profit & Margin

```sql
SELECT
  Product_Type,
  SUM(Revenue)                          AS Total_Revenue,
  SUM(Profit)                           AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS Profit_Margin_Pct,
  SUM(Units_Sold)                       AS Total_Units_Sold
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Total_Revenue DESC;
```

**Business insight:** Heat Pumps lead in revenue (€420K) despite lower sales volume than Solar Panels, confirming a premium pricing advantage. EV Chargers have the lowest revenue and profit across all categories.

![Q1](screenshots/Q1_product_revenue_profit_margin.png)

---

### Query 2 — Supplier Delivery Time & Volume

```sql
SELECT
  Supplier,
  ROUND(AVG(Delivery_Time),1)  AS Avg_Delivery_Days,
  SUM(Units_Delivered)         AS Total_Units_Delivered,
  COUNT(*)                     AS Num_Transactions
FROM supply_chain_db.supply_chain
GROUP BY Supplier
ORDER BY Avg_Delivery_Days ASC;
```

**Business insight:** Supplier A is the fastest (3.5 days avg) and delivers the highest volume (1,396 units), making it the most operationally reliable partner. Supplier C averages 8.7 days — a significant bottleneck risk.

![Q2](screenshots/Q2_supplier_delivery_time_volume.png)

---

### Query 3 — Inventory Gap by Product

```sql
SELECT
  Product_Type,
  SUM(Inventory_gap)            AS Total_Inventory_Gap,
  SUM(Units_Ordered)            AS Total_Ordered,
  SUM(Units_Delivered)          AS Total_Delivered,
  SUM(Units_Ordered)
    - SUM(Units_Delivered)      AS Undelivered_Units
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Total_Inventory_Gap DESC;
```

**Business insight:** Solar Panels have the largest inventory gap (155 units), indicating consistent overstocking. All product categories show positive gaps — a systemic inefficiency in inventory planning across the business.

![Q3](screenshots/Q3_inventory_gap_by_product.png)

---

### Query 4 — Revenue & Profit by Warehouse Location

```sql
SELECT
  Warehouse_Location,
  SUM(Revenue)                          AS Total_Revenue,
  SUM(Profit)                           AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS Profit_Margin_Pct,
  SUM(Units_Sold)                       AS Units_Sold
FROM supply_chain_db.supply_chain
GROUP BY Warehouse_Location
ORDER BY Total_Revenue DESC;
```

**Business insight:** This extended analysis (not shown in the Excel dashboard) reveals which city locations drive the most revenue, enabling smarter decisions about where to prioritise restocking and logistics investment.

![Q4](screenshots/Q4_revenue_profit_by_warehouse.png)

---

### Query 5 — Supplier Fulfilment Rate

```sql
SELECT
  Supplier,
  SUM(Units_Ordered)                               AS Total_Ordered,
  SUM(Units_Delivered)                             AS Total_Delivered,
  ROUND(SUM(Units_Delivered)
    / SUM(Units_Ordered) * 100, 1)                AS Fulfilment_Rate_Pct
FROM supply_chain_db.supply_chain
GROUP BY Supplier
ORDER BY Fulfilment_Rate_Pct DESC;
```

**Business insight:** No supplier achieves 100% fulfilment — partial delivery is a root cause of the inventory gaps seen in Query 3. This metric is critical for procurement teams evaluating vendor contracts.

![Q5](screenshots/Q5_supplier_fulfilment_rate.png)

---

### Query 6 — Cost Efficiency by Product

```sql
SELECT
  Product_Type,
  SUM(Total_Cost)                               AS Total_Cost,
  SUM(Revenue)                                  AS Total_Revenue,
  ROUND(SUM(Total_Cost)/SUM(Revenue)*100, 1)    AS Cost_Ratio_Pct,
  ROUND(SUM(Revenue)/SUM(Total_Cost), 2)        AS Revenue_Per_Cost_Euro
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Revenue_Per_Cost_Euro DESC;
```

**Business insight:** `Revenue_Per_Cost_Euro` shows how many euros of revenue each euro of cost generates. The product with the highest ratio is the most capital-efficient. EV Chargers likely show the weakest return, reinforcing the case for a pricing review.

![Q6](screenshots/Q6_cost_efficiency_by_product.png)

---

### Query 7 — Supplier Performance by Product Category

```sql
SELECT
  Supplier,
  Product_Type,
  ROUND(AVG(Delivery_Time),1)   AS Avg_Delivery_Days,
  SUM(Units_Delivered)          AS Units_Delivered,
  SUM(Profit)                   AS Total_Profit
FROM supply_chain_db.supply_chain
GROUP BY Supplier, Product_Type
ORDER BY Supplier, Total_Profit DESC;
```

**Business insight:** Cross-tabbing suppliers against products reveals which supplier is best matched to each product category. This enables smarter supplier-product pairing decisions — for example, routing Heat Pump orders to whichever supplier delivers them fastest.

![Q7](screenshots/Q7_supplier_performance_by_product.png)

---

### Query 8 — Demand vs Supply: Sell-Through Rate

```sql
SELECT
  Product_Type,
  SUM(Units_Ordered)                            AS Total_Ordered,
  SUM(Units_Sold)                               AS Total_Sold,
  SUM(Units_Ordered) - SUM(Units_Sold)          AS Order_to_Sales_Gap,
  ROUND(SUM(Units_Sold)
    / SUM(Units_Ordered) * 100, 1)             AS Sell_Through_Rate_Pct
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Sell_Through_Rate_Pct ASC;
```

**Business insight:** Sell-through rate is a standard retail and supply chain KPI. A rate below 80% signals over-ordering. Results show EV Chargers have the lowest sell-through rate (71.7%), meaning they are the most over-ordered product relative to actual sales — reinforcing the case for a demand review. Solar Panels have the highest rate (74.6%) despite the largest order volume, confirming they are the strongest demand-driven product. All four categories fall below 80%, indicating business-wide over-ordering.

![Q8](screenshots/Q8_demand_vs_supply_sell_through.png)

---

### Query 9 — Warehouse-Product Revenue Ranking (Window Function)

```sql
SELECT
  Warehouse_Location,
  Product_Type,
  SUM(Revenue)     AS Total_Revenue,
  SUM(Profit)      AS Total_Profit,
  RANK() OVER (
    PARTITION BY Product_Type
    ORDER BY SUM(Revenue) DESC
  )                AS Revenue_Rank
FROM supply_chain_db.supply_chain
GROUP BY Warehouse_Location, Product_Type
ORDER BY Product_Type, Revenue_Rank;
```

**Business insight:** For each product category, this ranks which warehouse generates the most revenue. Berlin leads for Heat Pumps (€101,500) and is the clear top location to prioritise for restocking. Revenue was chosen as the ranking metric over profit because it reflects market demand and transaction volume — profit is included as a companion column so both dimensions are visible in one result. Where two warehouses generate identical revenue (e.g. Cologne and Hamburg both at €63,000 for Solar Panels), SQL's `RANK()` correctly assigns them the same rank and skips the next position — this is expected behaviour, not an error. Uses `RANK() OVER (PARTITION BY)` window function.

![Q9](screenshots/Q9_warehouse_product_revenue_rank.png)

---

### Query 10 — Executive Summary KPIs

```sql
SELECT
  COUNT(DISTINCT Product_Type)              AS Product_Categories,
  COUNT(DISTINCT Supplier)                  AS Active_Suppliers,
  COUNT(DISTINCT Warehouse_Location)        AS Warehouse_Locations,
  SUM(Revenue)                              AS Total_Revenue,
  SUM(Profit)                               AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2)     AS Overall_Margin_Pct,
  SUM(Units_Sold)                           AS Total_Units_Sold,
  ROUND(AVG(Delivery_Time),1)               AS Avg_Delivery_Days,
  SUM(Inventory_gap)                        AS Total_Inventory_Gap
FROM supply_chain_db.supply_chain;
```

**Business insight:** This single query reproduces the KPI header row from the Excel dashboard exactly — €1,349,500 revenue, 2,970 units sold, 6.1 day avg delivery, 31.57% margin — validating that the SQL and Excel analyses are fully consistent.

![Q10](screenshots/Q10_executive_summary_kpis.png)

---

## Key Business Findings

- **Heat Pumps** generate the highest revenue (€420K) despite lower sales volume — a premium pricing advantage worth protecting
- **EV Chargers** underperform across all metrics — lowest revenue (€230K), lowest profit (€86K), and lowest sell-through rate (71.7%) — making them the weakest product category and a clear candidate for pricing or demand review
- **Solar Panels** record the highest sales volume (990 units) and best sell-through rate (74.6%), making them the strongest demand-driven product despite the largest inventory gap
- **Supplier A** is the most reliable: fastest delivery (3.5 days avg) and highest volume (1,396 units)
- **Supplier C** represents operational risk: slowest delivery (8.7 days) and lowest fulfilment
- **All products show positive inventory gaps** — systemic overstocking is a business-wide inefficiency
- **Overall profit margin of 31.57%** reflects healthy profitability across product lines

---

## SQL Skills Demonstrated

- Aggregation functions: `SUM()`, `AVG()`, `COUNT()`, `ROUND()`
- `GROUP BY` on single and multiple columns
- `ORDER BY` with `ASC` / `DESC`
- Derived metrics calculated inline (profit margin %, fulfilment rate, sell-through rate, revenue per cost euro)
- `COUNT(DISTINCT ...)` for dimension counting
- Window function: `RANK() OVER (PARTITION BY ... ORDER BY ...)`
- Aliasing with `AS` for readable output

---

## Repository Structure

```
supply-chain-sql-portfolio/
│
├── README.md
├── supply_chain_queries.sql       ← all 10 queries in one file
├── supply_chain_clean.csv         ← raw dataset
│
├── dashboard/
│   └── Supply_Chain_Demand_Analytics_Dashboard.png
│
└── screenshots/
    ├── Q1_product_revenue_profit_margin.png
    ├── Q2_supplier_delivery_time_volume.png
    ├── Q3_inventory_gap_by_product.png
    ├── Q4_revenue_profit_by_warehouse.png
    ├── Q5_supplier_fulfilment_rate.png
    ├── Q6_cost_efficiency_by_product.png
    ├── Q7_supplier_performance_by_product.png
    ├── Q8_demand_vs_supply_sell_through.png
    ├── Q9_warehouse_product_revenue_rank.png
    └── Q10_executive_summary_kpis.png
```

---

## About

Built as part of a data analytics portfolio to demonstrate SQL querying skills alongside Excel dashboard development.  
**Tools:** MySQL 8.0 · MySQL Workbench · Microsoft Excel
