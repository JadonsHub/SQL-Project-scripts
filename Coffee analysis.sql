CREATE SCHEMA CoffeeSalesDB;

CREATE SCHEMA productsalesdb;

## CLEANING THE COFFEE DATABASE
-- 1. Proffilling the database
SELECT *
FROM coffeeraworder
;

SELECT *
FROM coffeerawcustomers
;

SELECT *
FROM coffeerawproducts
;

SELECT COUNT(*)
FROM coffeeraworder;

SELECT COUNT(*)
FROM coffeerawcustomers;

SELECT COUNT(*)
FROM coffeerawproducts;

-- Modifying columns
ALTER TABLE coffeeraworder
CHANGE COLUMN `Order Date` `Order_Date` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Order ID` `Order_ID` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Customer ID` `Customer_ID` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Product ID` `Product_ID` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Coffee Type` `Coffee_type` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Roast Type` `Roast_type` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Unit Price` `Unit_price` TEXT NOT NULL;

ALTER TABLE coffeeraworder
CHANGE COLUMN `Customer Name` `Customer_Name` TEXT NOT NULL;

-- 2. Checking for duplicates
SELECT 
		Order_Date,
		Order_ID,
		Customer_ID,
		Product_ID,
		Quantity,
		Customer_Name,
		Email,
		Country,
		Coffee_type,
		Roast_type,
		Size,
		Unit_price,
		Sales,
        COUNT(*) AS Total_duplicates
FROM coffeeraworder
GROUP BY
		Order_Date,
		Order_ID,
		Customer_ID,
		Product_ID,
		Quantity,
		Customer_Name,
		Email,
		Country,
		Coffee_type,
		Roast_type,
		Size,
		Unit_price,
		Sales
HAVING COUNT(*) > 1
;

-- Checking for missing emails in customer table
SELECT COUNT(*)
FROM coffeerawcustomers
WHERE Email IS NULL
	OR Email = ' '
;

-- Renaming columns for standardization
ALTER TABLE coffeerawcustomers
CHANGE COLUMN `Customer ID` `Customer_ID` TEXT;

ALTER TABLE coffeerawcustomers
CHANGE COLUMN `Address Line 1` `Address_line` TEXT;

ALTER TABLE coffeerawcustomers
CHANGE COLUMN `Customer Name` `Customer_Name` TEXT;

ALTER TABLE coffeerawcustomers
CHANGE COLUMN `Loyalty Card` `Loyalty_card` TEXT;

-- Renaming the columns in products table for standardization
ALTER TABLE coffeerawproducts
CHANGE COLUMN `Product ID` `Product_ID` TEXT;

ALTER TABLE coffeerawproducts
CHANGE COLUMN `Roast Type` `Roast_type` TEXT;

ALTER TABLE coffeerawproducts
CHANGE COLUMN `Unit Price` `Unit_price` TEXT;

ALTER TABLE coffeerawproducts
CHANGE COLUMN `Price per 100g` `Price_per_100g` TEXT;

ALTER TABLE coffeerawproducts
CHANGE COLUMN `Coffee Type` `Coffee_type` TEXT;

-- Converting data type format
UPDATE coffeeraworder
SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y');

ALTER TABLE coffeeraworder
MODIFY Order_Date DATE;

## Creating a cleaned table
CREATE TABLE cleaned_coffeedata AS
SELECT
	o.Order_ID,
    o.Order_Date,
    -- customer details pulled from the customer table
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.City,
    c.Country AS CustomerCountry,
    c.Loyalty_card,
    -- product details pulled from the products table
    p.Product_ID,
    p.Coffee_type,
    p.Roast_type,
    p.Size AS BagSize_kg,
    -- pulling the financials
    o.Quantity,
    p.Unit_price,
    (o.Quantity * p.Unit_price) AS CalculatedSales,
    (o.Quantity * p.Profit) AS TotalProfit
FROM coffeeraworder o
-- We want all orders that have valid products and customers details
INNER JOIN coffeerawcustomers c
		ON o.Customer_ID = c.Customer_ID
INNER JOIN coffeerawproducts p 
		ON o.Product_ID = p.Product_ID
;
    

SELECT *
FROM cleaned_coffeedata
;

SELECT COUNT(*)
FROM cleaned_coffeedata
;

-- Checking for duplicates
SELECT
	Order_ID,
    Order_Date,
    Customer_ID,
    Email,
    City,
    CustomerCountry,
    Loyalty_card,
    Product_ID,
    Coffee_type,
    Roast_type,
    BagSize_kg,
    Quantity,
    Unit_price,
    CalculatedSales,
    TotalProfit,
    COUNT(*) AS Duplicates
FROM cleaned_coffeedata
GROUP BY 
	Order_ID,
    Order_Date,
    Customer_ID,
    Email,
    City,
    CustomerCountry,
    Loyalty_card,
    Product_ID,
    Coffee_type,
    Roast_type,
    BagSize_kg,
    Quantity,
    Unit_price,
    CalculatedSales,
    TotalProfit
HAVING COUNT(*) > 1
;

-- Checking for nulls
SELECT COUNT(*) AS empty_cell
FROM cleaned_coffeedata
WHERE Customer_Name
	AND Email IS NULL
;
    
## ANALYZING THE DATA
-- 1. What is the total revenue and profit?
SELECT
	ROUND(SUM(CalculatedSales), 2) AS Total_Revenue,
	ROUND(SUM(TotalProfit), 2) AS Profit
FROM cleaned_coffeedata
;

-- 2. Which Coffee Type generates the most revenue?
SELECT
	Coffee_type,
	ROUND(SUM(CalculatedSales), 2) AS Revenue,
	SUM(Quantity) AS TotalBagSold
FROM cleaned_coffeedata
GROUP BY Coffee_type
ORDER BY TotalBagSold
;

-- 3. Do Loyalty Card holders spend more on average than non-holders?
SELECT
	Loyalty_card,
	COUNT(DISTINCT Customer_ID) AS Number_of_customers,
	COUNT(Order_ID) AS Total_Orders,
    ROUND(AVG(CalculatedSales), 2) AS Average_order_value
FROM cleaned_coffeedata
GROUP BY Loyalty_card
;

-- 4. Top 5 Best-Selling Products by Country?
WITH RankedProducts AS (
    SELECT 
        CustomerCountry,
        Product_ID,
        Coffee_type,
        ROUND(SUM(CalculatedSales), 2) AS Total_sales,
        DENSE_RANK() OVER(PARTITION BY CustomerCountry ORDER BY SUM(CalculatedSales) DESC) as SalesRank
    FROM cleaned_coffeedata
    GROUP BY CustomerCountry, Product_ID, Coffee_type
)
SELECT *
FROM RankedProducts 
WHERE SalesRank <= 5
;

-- 5. Monthly Sales Trend (Seasonality)
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS YearMonth,
    ROUND(SUM(CalculatedSales), 2) AS Monthly_Revenue
FROM cleaned_coffeedata
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY YearMonth ASC
;

