# Creating a database for the global superstore project
CREATE SCHEMA global_superstore;

## PERFOMING EXPLORATORY DATA ANALYSIS

-- Retrieving all data from the superstore table
SELECT *
FROM global_superstore
;

-- Counting the number of rows in the data
SELECT COUNT(*)
FROM global_superstore
;

-- Retrieving the names of the products, their categories and the sales amount
SELECT ProductName, Category, Sales
FROM global_superstore
;

-- Find all high value sales where the transaction amount is strictly greater than 50
SELECT ProductID, ProductName, Sales
FROM global_superstore
WHERE sales > 50
;

-- Retrieve all orders that were placed in the West region
SELECT OrderID, ProductName, City, Sales, Region
FROM global_superstore
WHERE Region = 'West'
;

-- Finding the orders where sales are greater than 100 AND the region is North
SELECT OrderID, Sales, Region
FROM global_superstore
WHERE Sales > 100
	AND Region = 'North'
;

## Filtering datasets for multiple valid categories using the OR operator
-- Find the products sold in both Furniture and Technology Categories
SELECT CustomerName, ProductName, Region, Category, Sales
FROM global_superstore
WHERE Category = 'Furniture'
	OR Category = 'Technology'
;

-- Identify unprofited products that also has a shipping cost greater than 10
SELECT CustomerName, ProductName, OrderID, Profit, ShippingCost
FROM global_superstore
WHERE profit < 0
	AND ShippingCost > 10
;

-- Find bulk purchases (Quantity > 5) where absolutely no discount was given
SELECT CustomerName, ProductName, OrderID, Quantity, Discount, Sales
FROM global_superstore
WHERE Quantity > 5
	AND Discount = 0
    ;
    
## ASSIGNMENT
-- Retrieve all consumer segment sales that took place in the united states
SELECT CustomerName, Segment, Country, Sales
FROM global_superstore
WHERE Segment = 'Consumer'
	AND Country = 'United States'
;

-- Find highly urgent order where priority is critical OR it is shipped on the same day
SELECT OrderID, OrderPriority, ShipMode
FROM global_superstore
WHERE OrderPriority = 'Critical'
	OR ShipMode = 'Same Day'
;


