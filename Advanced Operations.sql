## ADVANCED OPERATIONS 1
-- Retrieve a list of all unique countries the superstore operates in.
SELECT DISTINCT Country
FROM global_superstore
ORDER BY Country ASC
;

-- Finding all unique sub-categories of products sold
SELECT DISTINCT Sub_Category
FROM global_superstore
ORDER BY Sub_Category ASC
;

-- Finding all unique cities where the superstore operates in 
SELECT DISTINCT City
FROM global_superstore
ORDER BY City ASC
;

-- LIKE OPERATOR: Find all customers whose name begins with the letter 'A'
SELECT DISTINCT CustomerName
FROM global_superstore
WHERE CustomerName
LIKE 'A%'
;

-- Retrieve all products that have the "phone" anywhere in their name
SELECT ProductID, ProductName, Sales
FROM global_superstore
WHERE ProductName
LIKE '%Phone%'
;

-- Retrieve all product ID that have SU in their name
SELECT ProductID, ProductName, Profit
FROM global_superstore
WHERE ProductID
LIKE '%SU%'
;

-- IN OPERATOR: Retrieve orders from specific regions without using the multiple ORs
SELECT OrderID, Region, Sales
FROM global_superstore
WHERE Region
IN ('Africa', 'Oceania', 'West', 'North', 'Central', 'South', 'North Asia')
ORDER BY Region ASC
;

SELECT OrderID, Region, Sales
FROM global_superstore
WHERE Region = 'Africa'
OR Region = 'Oceania'
OR Region = 'West'
OR Region = 'North'
OR Region = 'Central'
ORDER BY Region ASC
;

-- Check for sales belonging to a specific list of target customers.
SELECT OrderDate, CustomerID, CustomerName, Sales
FROM global_superstore
WHERE CustomerName
IN ('Lycoris Saunders', 'Chad Sievert', 'Rob Lucas', 'Alan Barnes')
;

-- Check for sales made in the different customer segments
SELECT OrderDate, CustomerID, Segment, Sales
FROM global_superstore
WHERE Segment
IN ('Consumer', 'Home office', 'Corporate')
;

-- BETWEEN OPERATOR: Filter for medium-tier sales amounts ranging from 100 to 500
SELECT OrderDate, OrderID, Sales
FROM global_superstore
WHERE Sales
BETWEEN 100 AND 500
;

-- Retrieve all orders that were placed in the years 2011 and 2012.
SELECT OrderDate, OrderID, Year, Sales
FROM global_superstore
WHERE Year
BETWEEN 2011 AND 2012
;

-- Retrieve all shipping cost that was around 10 and 50 dollars.
SELECT ShipDate, OrderID, ShipMode, ShippingCost
FROM global_superstore
WHERE ShippingCost
BETWEEN 10 AND 50
;

-- IS NULL: Check for any potential data quality issues where a customer ID might be missing
SELECT CustomerID, CustomerName, OrderID
FROM global_superstore
WHERE CustomerID IS NULL
;

-- Check for any missing order date
SELECT CustomerID, OrderID, OrderDate
FROM global_superstore
WHERE OrderDate IS NULL
;

-- IS NOT NULL: Verify orders that have successfully been assigned a shipping mode.
SELECT OrderID, ShipDate, ShipMode
FROM global_superstore
WHERE ShipMode IS NOT NULL
;

-- Verify orders that heve been successful
SELECT OrderID, OrderDate, ProductID, ProductName, CustomerID
FROM global_superstore
WHERE OrderID IS NOT NULL
;
