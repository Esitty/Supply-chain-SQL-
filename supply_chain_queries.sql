-- ============================================================
-- Supply Chain & Demand Analytics — SQL Portfolio Project
-- Tool: MySQL 8.0
-- Schema: supply_chain_db | Table: supply_chain
-- Dataset: 38 rows × 15 columns | Jan–Feb 2024
-- ============================================================


-- ============================================================
-- TABLE SETUP
-- ============================================================

CREATE TABLE supply_chain (
    Date                DATE,
    Product_Type        VARCHAR(50),
    Supplier            VARCHAR(50),
    Warehouse_Location  VARCHAR(50),
    Inventory_Level     INT,
    Units_Ordered       INT,
    Units_Delivered     INT,
    Delivery_Time       INT,
    Units_Sold          INT,
    Price_per_Unit      DECIMAL(10,2),
    Revenue             DECIMAL(10,2),
    Cost_per_Unit       DECIMAL(10,2),
    Total_Cost          DECIMAL(10,2),
    Inventory_gap       INT,
    Profit              DECIMAL(10,2)
);


-- ============================================================
-- QUERY 1 — Product Revenue, Profit & Margin
-- Business question: Which products generate the most revenue,
-- profit, and sales volume?
-- ============================================================

SELECT
  Product_Type,
  SUM(Revenue)                          AS Total_Revenue,
  SUM(Profit)                           AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS Profit_Margin_Pct,
  SUM(Units_Sold)                       AS Total_Units_Sold
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Total_Revenue DESC;


-- ============================================================
-- QUERY 2 — Supplier Delivery Time & Volume
-- Business question: Which supplier is fastest and most
-- reliable for delivery?
-- ============================================================

SELECT
  Supplier,
  ROUND(AVG(Delivery_Time),1)  AS Avg_Delivery_Days,
  SUM(Units_Delivered)         AS Total_Units_Delivered,
  COUNT(*)                     AS Num_Transactions
FROM supply_chain_db.supply_chain
GROUP BY Supplier
ORDER BY Avg_Delivery_Days ASC;


-- ============================================================
-- QUERY 3 — Inventory Gap by Product
-- Business question: Which products have the largest
-- inventory gaps?
-- ============================================================

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


-- ============================================================
-- QUERY 4 — Revenue & Profit by Warehouse Location
-- Business question: Which warehouse locations are most
-- profitable? (Extended analysis — not in Excel dashboard)
-- ============================================================

SELECT
  Warehouse_Location,
  SUM(Revenue)                          AS Total_Revenue,
  SUM(Profit)                           AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS Profit_Margin_Pct,
  SUM(Units_Sold)                       AS Units_Sold
FROM supply_chain_db.supply_chain
GROUP BY Warehouse_Location
ORDER BY Total_Revenue DESC;


-- ============================================================
-- QUERY 5 — Supplier Fulfilment Rate
-- Business question: What percentage of ordered units does
-- each supplier actually deliver?
-- ============================================================

SELECT
  Supplier,
  SUM(Units_Ordered)               AS Total_Ordered,
  SUM(Units_Delivered)             AS Total_Delivered,
  ROUND(SUM(Units_Delivered)
    / SUM(Units_Ordered) * 100, 1) AS Fulfilment_Rate_Pct
FROM supply_chain_db.supply_chain
GROUP BY Supplier
ORDER BY Fulfilment_Rate_Pct DESC;


-- ============================================================
-- QUERY 6 — Cost Efficiency by Product
-- Business question: Which products generate the most revenue
-- per euro of cost spent?
-- ============================================================

SELECT
  Product_Type,
  SUM(Total_Cost)                             AS Total_Cost,
  SUM(Revenue)                                AS Total_Revenue,
  ROUND(SUM(Total_Cost)/SUM(Revenue)*100, 1)  AS Cost_Ratio_Pct,
  ROUND(SUM(Revenue)/SUM(Total_Cost), 2)      AS Revenue_Per_Cost_Euro
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Revenue_Per_Cost_Euro DESC;


-- ============================================================
-- QUERY 7 — Supplier Performance by Product Category
-- Business question: How does each supplier perform across
-- different product types?
-- ============================================================

SELECT
  Supplier,
  Product_Type,
  ROUND(AVG(Delivery_Time),1)   AS Avg_Delivery_Days,
  SUM(Units_Delivered)          AS Units_Delivered,
  SUM(Profit)                   AS Total_Profit
FROM supply_chain_db.supply_chain
GROUP BY Supplier, Product_Type
ORDER BY Supplier, Total_Profit DESC;


-- ============================================================
-- QUERY 8 — Demand vs Supply: Sell-Through Rate
-- Business question: How does actual demand (units sold)
-- compare to supply (units ordered)?
-- ============================================================

SELECT
  Product_Type,
  SUM(Units_Ordered)                    AS Total_Ordered,
  SUM(Units_Sold)                       AS Total_Sold,
  SUM(Units_Ordered) - SUM(Units_Sold)  AS Order_to_Sales_Gap,
  ROUND(SUM(Units_Sold)
    / SUM(Units_Ordered) * 100, 1)      AS Sell_Through_Rate_Pct
FROM supply_chain_db.supply_chain
GROUP BY Product_Type
ORDER BY Sell_Through_Rate_Pct ASC;


-- ============================================================
-- QUERY 9 — Warehouse-Product Revenue Ranking
-- Business question: Which warehouse-product combinations
-- rank highest in revenue?
-- Skill demonstrated: RANK() window function with PARTITION BY
-- Note: tied revenues (e.g. Cologne & Hamburg for Solar Panel)
-- receive the same rank — correct RANK() behaviour.
-- ============================================================

SELECT
  Warehouse_Location,
  Product_Type,
  SUM(Revenue) AS Total_Revenue,
  SUM(Profit)  AS Total_Profit,
  RANK() OVER (
    PARTITION BY Product_Type
    ORDER BY SUM(Revenue) DESC
  )                AS Revenue_Rank
FROM supply_chain_db.supply_chain
GROUP BY Warehouse_Location, Product_Type
ORDER BY Product_Type, Revenue_Rank;


-- ============================================================
-- QUERY 10 — Executive Summary KPIs
-- Business question: What is the overall business health?
-- Validates figures shown in the Excel dashboard header row.
-- ============================================================

SELECT
  COUNT(DISTINCT Product_Type)          AS Product_Categories,
  COUNT(DISTINCT Supplier)              AS Active_Suppliers,
  COUNT(DISTINCT Warehouse_Location)    AS Warehouse_Locations,
  SUM(Revenue)                          AS Total_Revenue,
  SUM(Profit)                           AS Total_Profit,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS Overall_Margin_Pct,
  SUM(Units_Sold)                       AS Total_Units_Sold,
  ROUND(AVG(Delivery_Time),1)           AS Avg_Delivery_Days,
  SUM(Inventory_gap)                    AS Total_Inventory_Gap
FROM supply_chain_db.supply_chain;
