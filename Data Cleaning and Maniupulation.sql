## DATA CLEANING AND MANIPULATION

# STEP 1: Data profilling
SELECT *
FROM global_superstore
;

SELECT COUNT(*)
FROM global_superstore
;

-- Establish the timeline
SELECT MIN(OrderDate), MAX(OrderDate)
FROM global_superstore
;

-- Identify Categories domain
SELECT DISTINCT(Category)
FROM global_superstore
;

SELECT DISTINCT(Region)
FROM global_superstore
;

SELECT DISTINCT(Segment)
FROM global_superstore
;

# STEP 2: Preparation of Canvas
-- Handling missing values
SELECT COUNT(*)
FROM global_superstore
WHERE CustomerID IS NULL
	AND OrderID IS NULL
    AND ProductID IS NULL
    AND OrderDate IS NULL
;
-- Delete the null items to have a clean dataset
DELETE FROM global_superstore
WHERE CustomerID IS NULL
	AND OrderID IS NULL
    AND ProductID IS NULL
    AND OrderDate IS NULL
;

-- Checking for duplicates
SELECT OrderID, ProductID, CustomerID, COUNT(*) AS Duplicate_count
FROM global_superstore
GROUP BY OrderID, ProductID, CustomerID
HAVING COUNT(*) > 1
;

DELETE FROM global_superstore
WHERE OrderID > 1
;

UPDATE global_superstore
SET OrderID = NULL
WHERE OrderID = ' '
;

-- Deleting the duplicate columns
CREATE TABLE global_superstore_clean AS 
SELECT *
FROM global_superstore 
;

DELETE t1
FROM global_superstore_clean t1
INNER JOIN global_superstore_clean t2
	WHERE t1.OrderID > t2.OrderID
		AND t1.ProductID = t2.ProductID
        AND t1.CustomerID = t2.CustomerID
;

DELETE t1
FROM global_superstore_clean t1
INNER JOIN global_superstore_clean t2
	WHERE t1.OrderID > t2.OrderID
    AND t1.CustomerName = t2.CustomerName
;

SELECT t1.*
FROM global_superstore_clean t1
INNER JOIN global_superstore_clean t2
WHERE t1.OrderID > t2.OrderID
	AND t1.CustomerName = t2.CustomerName
;

-- Another method to remove duplicate
DELETE FROM global_superstore
WHERE OrderID NOT IN (
    SELECT OrderID FROM (
        SELECT MIN(OrderID) AS id 
        FROM global_superstore
        GROUP BY CustomerName
    ) AS temp_table
);


-- Deleting ??? (unwanted) column
ALTER TABLE global_superstore
CHANGE COLUMN `???` `Unwanted` INT NULL DEFAULT NULL
;

ALTER TABLE global_superstore
DROP COLUMN	Unwanted
;

DROP TABLE global_superstore_clean;

## VERIFY AND/OR UPDATE DATA TYPES
-- Ensure the columns are in appropriate data types
UPDATE global_superstore
SET ShipDate = STR_TO_DATE(ShipDate, '%DD-%MM-%YYYY hh:mm:ss.[fraction]')
;

ALTER TABLE global_superstore
MODIFY OrderDate DATE;

ALTER TABLE global_superstore
MODIFY ShipDate DATETIME;

UPDATE global_superstore
SET OrderDate = STR_TO_DATE(OrderDate, '%Y-%d-%m');

UPDATE global_superstore
SET OrderDate = STR_TO_DATE(OrderDate, '%M-%d-%Y');