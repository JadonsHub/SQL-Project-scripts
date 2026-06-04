##CORE BUSINESS INTELLIGENCE
-- Aggregations, Structure, Group By, Aliasing, Having Keywords.

-- 1. Find the region that are highly profitable by taking the average of their profits.
SELECT Region, AVG(profit) AS Average_profit, SUM(Sales) AS Total_sales
FROM global_superstore
GROUP BY Region
HAVING AVG(profit) > 20
ORDER BY Average_profit DESC
;

-- 2. Identify product Sub-Categories where there are losses.
SELECT Sub_Category, SUM(Profit) AS Total_profit, SUM(Sales) AS Total_sales
FROM global_superstore
GROUP BY Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_profit DESC
;

-- 3. Evaluate customer loyalty by identifying frequent buyers.
SELECT CustomerName, COUNT(RowID) AS No_of_purchase, SUM(Sales) AS Lifetime_value
FROM global_superstore
GROUP BY CustomerName
HAVING COUNT(RowID) > 20
ORDER BY No_of_purchase DESC
LIMIT 10
;

-- 4. Find the MIN and MAX discounts given across different shipping modes, but only modes that have processed over 10,000 items in total
SELECT ShipMode, MIN(Discount) AS Min_discount, MAX(Discount) AS Max_discount, SUM(Quantity) AS Total_items_shipped, ROUND(SUM(Profit), 2) AS Gain, ROUND(SUM(Sales), 2) AS Revenue
FROM global_superstore
GROUP BY ShipMode
HAVING SUM(Quantity) > 10000
ORDER BY Max_discount DESC
;

## MULTILEVEL GROUPING
-- 5.Summarize total sales by Category and Segment.
SELECT Category, Segment, SUM(Sales) AS Total_sales
FROM global_superstore
GROUP BY Category, Segment
HAVING SUM(Sales) > 50000
ORDER BY Segment, Total_sales DESC
LIMIT 5
;

-- 6. Which Sub Category and Segment has the highest average profit. i.e. > 20
SELECT Sub_Category, Segment, AVG(Profit) AS Highest_Profit
FROM global_superstore
GROUP BY Sub_Category, Segment
HAVING AVG(Profit) > 20
ORDER BY Segment, Highest_Profit DESC
;

-- 7. Which Country and Market has the highest product quantity sold. i.e > 5000 items
SELECT Country, Market, SUM(Quantity) AS Items_sold
FROM global_superstore
GROUP BY Country, Market
HAVING SUM(Quantity) > 5000
ORDER BY Market, Items_sold DESC
;


-- 8. Analyze high-volume shipping operations by country. i.e. average cost > 20
SELECT Country, ROUND(AVG(ShippingCost), 2) AS Avg_shipping_cost, COUNT(OrderID) AS Total_orders
FROM global_superstore
GROUP BY Country
HAVING AVG(ShippingCost) > 20
ORDER BY Avg_shipping_cost DESC
LIMIT 10
;

-- 9. Deepdive into discount strategies by City.
-- Finding cities that have been given an average discount higher than 30%
SELECT City, ROUND(AVG(Discount), 2) AS Avg_Discount, SUM(Sales) AS Total_City_Sales
FROM global_superstore
GROUP BY City
HAVING AVG(Discount) > 0.3
ORDER BY Avg_Discount DESC
LIMIT 10
;

-- 10. Identify premium product markets. i.e. single profit > $1,500
SELECT Market, MAX(Profit) AS Highest_single_profit, SUM(Quantity) AS Total_revenue
FROM global_superstore
GROUP BY Market
HAVING MAX(Profit) > 1500
ORDER BY Highest_single_profit DESC
;