USE SuperstoreDW;
Go
-- row counts
SELECT 'Fact_Sales' AS tbl, COUNT(*) AS cnt FROM Fact_Sales
UNION ALL SELECT 'Dim_Customer', COUNT(*) FROM Dim_Customer
UNION ALL SELECT 'Dim_Product', COUNT(*) FROM Dim_Product
UNION ALL SELECT 'Dim_Location', COUNT(*) FROM Dim_Location
UNION ALL SELECT 'Dim_Date', COUNT(*) FROM Dim_Date
UNION ALL SELECT 'Ref_State', COUNT(*) FROM Ref_State;
-- total sales (compare with excel file)
SELECT SUM(Sales) AS total_sales FROM Fact_Sales;
-- fact rows without a matching dimension row (should be 0)
SELECT
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS no_customer,
    SUM(CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END) AS no_product,
    SUM(CASE WHEN l.LocationKey IS NULL THEN 1 ELSE 0 END) AS no_location,
    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS no_date
FROM Fact_Sales f
LEFT JOIN Dim_Customer c ON f.CustomerKey = c.CustomerKey
LEFT JOIN Dim_Product p ON f.ProductKey = p.ProductKey
LEFT JOIN Dim_Location l ON f.LocationKey = l.LocationKey
LEFT JOIN Dim_Date d ON f.DateKey = d.DateKey;

-- postal codes and state codes in location dim
SELECT COUNT(*) AS locations,
       SUM(CASE WHEN PostalCode IS NULL THEN 1 ELSE 0 END) AS empty_postal,
       SUM(CASE WHEN LEN(PostalCode) <> 5 THEN 1 ELSE 0 END) AS wrong_postal,
       SUM(CASE WHEN StateCode IS NULL THEN 1 ELSE 0 END) AS no_state_code,
       COUNT(DISTINCT StateCode) AS states
FROM Dim_Location;

-- 92024 is used by two cities, check they are kept separate
SELECT l.City, COUNT(*) AS cnt
FROM Fact_Sales f
JOIN Dim_Location l ON f.LocationKey = l.LocationKey
WHERE l.PostalCode = '92024'
GROUP BY l.City;

-- ship days column
SELECT MIN(ShipDays) AS min_days, MAX(ShipDays) AS max_days, AVG(ShipDays * 1.0) AS avg_days
FROM Fact_Sales;


--  analysis --

-- sales per year + growth
SELECT yr, sales, lines,
       CAST((sales - LAG(sales) OVER (ORDER BY yr)) * 100.0
            / LAG(sales) OVER (ORDER BY yr) AS DECIMAL(5,1)) AS growth_pct
FROM (
    SELECT DateKey / 10000 AS yr, SUM(Sales) AS sales, COUNT(*) AS lines
    FROM Fact_Sales
    GROUP BY DateKey / 10000
) t
ORDER BY yr;

-- sales per quarter (all years)
SELECT ((DateKey / 100) % 100 + 2) / 3 AS qtr, SUM(Sales) AS sales
FROM Fact_Sales
GROUP BY ((DateKey / 100) % 100 + 2) / 3
ORDER BY qtr;

-- sales per category
SELECT p.Category,
       SUM(f.Sales) AS sales,
       COUNT(*) AS lines,
       CAST(AVG(f.Sales) AS DECIMAL(10,2)) AS avg_line,
       CAST(SUM(f.Sales) * 100.0 / (SELECT SUM(Sales) FROM Fact_Sales) AS DECIMAL(5,1)) AS pct
FROM Fact_Sales f
JOIN Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY sales DESC;

-- sales per sub category
SELECT p.Category, p.SubCategory,
       SUM(f.Sales) AS sales,
       COUNT(*) AS lines,
       CAST(AVG(f.Sales) AS DECIMAL(10,2)) AS avg_line
FROM Fact_Sales f
JOIN Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.Category, p.SubCategory
ORDER BY sales DESC;

-- top 5 products
SELECT TOP 5 p.ProductName, p.Category, SUM(f.Sales) AS sales
FROM Fact_Sales f
JOIN Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.Category
ORDER BY sales DESC;

-- sales per region
SELECT l.Region,
       SUM(f.Sales) AS sales,
       COUNT(*) AS lines,
       CAST(SUM(f.Sales) * 100.0 / (SELECT SUM(Sales) FROM Fact_Sales) AS DECIMAL(5,1)) AS pct
FROM Fact_Sales f
JOIN Dim_Location l ON f.LocationKey = l.LocationKey
GROUP BY l.Region
ORDER BY sales DESC;

-- sales per state, and per 1000 people (population from census csv)
SELECT State, StateCode, sales, Population2020,
       CAST(sales * 1000.0 / Population2020 AS DECIMAL(10,2)) AS sales_per_1000,
       RANK() OVER (ORDER BY sales DESC) AS rank_sales,
       RANK() OVER (ORDER BY sales * 1.0 / Population2020 DESC) AS rank_per_person
FROM (
    SELECT l.State, l.StateCode, l.Population2020, SUM(f.Sales) AS sales
    FROM Fact_Sales f
    JOIN Dim_Location l ON f.LocationKey = l.LocationKey
    GROUP BY l.State, l.StateCode, l.Population2020
) t
ORDER BY sales DESC;

-- sales per segment
SELECT c.Segment,
       SUM(f.Sales) AS sales,
       COUNT(DISTINCT c.CustomerKey) AS customers,
       COUNT(*) AS lines,
       CAST(SUM(f.Sales) / COUNT(DISTINCT c.CustomerKey) AS DECIMAL(10,2)) AS sales_per_customer,
       CAST(SUM(f.Sales) * 100.0 / (SELECT SUM(Sales) FROM Fact_Sales) AS DECIMAL(5,1)) AS pct
FROM Fact_Sales f
JOIN Dim_Customer c ON f.CustomerKey = c.CustomerKey
GROUP BY c.Segment
ORDER BY sales DESC;

-- how many days to ship
SELECT ShipDays, COUNT(*) AS lines, SUM(Sales) AS sales,
       CAST(AVG(Sales) AS DECIMAL(10,2)) AS avg_line
FROM Fact_Sales
GROUP BY ShipDays
ORDER BY ShipDays;