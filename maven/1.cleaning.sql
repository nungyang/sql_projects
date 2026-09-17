-- Maven Analytics Marketing Campaign Results Data --

-- Imported data using 'Table Data Import Wizard'
# I had to take one step before importing it:
# Have to strip the UTF-8BOM on the file in Terminal
# Otherwise it does not import through import wizard
# File without UTF-9BOM is called marketing_data_clean.csv

# Setting schema as maven_analytics
USE maven_analytics;

# Creating a version of database that I can make changes to
DROP TABLE IF EXISTS marketing;
CREATE TABLE marketing LIKE raw_data;

INSERT INTO marketing
SELECT * FROM raw_data;

-- 1. Are there any null values or outliers? How will you handle them?
# First getting list of all columns
DESCRIBE marketing;

# Checking each column for nulls
SELECT
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS ID_nulls,
    SUM(CASE WHEN Year_Birth IS NULL THEN 1 ELSE 0 END) AS Year_Birth_nulls,
    SUM(CASE WHEN Education IS NULL THEN 1 ELSE 0 END) AS Education_nulls,
    SUM(CASE WHEN Marital_Status IS NULL THEN 1 ELSE 0 END) AS Marital_Status_nulls,
    SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS Income_nulls,
    SUM(CASE WHEN Kidhome IS NULL THEN 1 ELSE 0 END) AS Kidhome_nulls,
    SUM(CASE WHEN Teenhome IS NULL THEN 1 ELSE 0 END) AS Teenhome_nulls,
    SUM(CASE WHEN Dt_Customer IS NULL THEN 1 ELSE 0 END) AS Dt_Customer_nulls,
    SUM(CASE WHEN Recency IS NULL THEN 1 ELSE 0 END) AS Recency_nulls,
    SUM(CASE WHEN MntWines IS NULL THEN 1 ELSE 0 END) AS MntWines_nulls,
    SUM(CASE WHEN MntFruits IS NULL THEN 1 ELSE 0 END) AS MntFruits_nulls,
    SUM(CASE WHEN MntMeatProducts IS NULL THEN 1 ELSE 0 END) AS MntMeatProducts_nulls,
    SUM(CASE WHEN MntFishProducts IS NULL THEN 1 ELSE 0 END) AS MntFishProducts_nulls,
    SUM(CASE WHEN MntSweetProducts IS NULL THEN 1 ELSE 0 END) AS MntSweetProducts_nulls,
    SUM(CASE WHEN MntGoldProds IS NULL THEN 1 ELSE 0 END) AS MntGoldProds_nulls,
    SUM(CASE WHEN NumDealsPurchases IS NULL THEN 1 ELSE 0 END) AS NumDealsPurchases_nulls,
    SUM(CASE WHEN NumWebPurchases IS NULL THEN 1 ELSE 0 END) AS NumWebPurchases_nulls,
    SUM(CASE WHEN NumCatalogPurchases IS NULL THEN 1 ELSE 0 END) AS NumCatalogPurchases_nulls,
    SUM(CASE WHEN NumStorePurchases IS NULL THEN 1 ELSE 0 END) AS NumStorePurchases_nulls,
    SUM(CASE WHEN NumWebVisitsMonth IS NULL THEN 1 ELSE 0 END) AS NumWebVisitsMonth_nulls,
    SUM(CASE WHEN AcceptedCmp3 IS NULL THEN 1 ELSE 0 END) AS AcceptedCmp3_nulls,
    SUM(CASE WHEN AcceptedCmp4 IS NULL THEN 1 ELSE 0 END) AS AcceptedCmp4_nulls,
    SUM(CASE WHEN AcceptedCmp5 IS NULL THEN 1 ELSE 0 END) AS AcceptedCmp5_nulls,
    SUM(CASE WHEN AcceptedCmp1 IS NULL THEN 1 ELSE 0 END) AS AcceptedCmp1_nulls,
    SUM(CASE WHEN AcceptedCmp2 IS NULL THEN 1 ELSE 0 END) AS AcceptedCmp2_nulls,
    SUM(CASE WHEN Response IS NULL THEN 1 ELSE 0 END) AS Response_nulls,
    SUM(CASE WHEN Complain IS NULL THEN 1 ELSE 0 END) AS Complain_nulls,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS Country_nulls
FROM marketing;
# -- There are no NULL values in any of the column

## Looking into year of birth
SELECT *
FROM marketing
ORDER BY Year_Birth ASC;

## Assuming this is a dataset from 2014 (date of last entry), anyone born before 1900 would be over 110...
## Classifying those years of birth as NULL values as probably incorrect
UPDATE marketing
SET Year_Birth = NULL
WHERE Year_Birth <= 1900;

## Checking it worked
SELECT *
FROM marketing
ORDER BY Year_Birth ASC;

## Looking for unusual birth years in the later years too by looking at desc
SELECT *
FROM marketing
ORDER BY Year_Birth DESC;

## Looking for unusual values in all the binary/categorical variables first
# -- Education
SELECT Education, COUNT(*) AS count
FROM marketing
GROUP BY Education;
# Nothing unusual or outlier

# -- Marital Status
SELECT Marital_Status, COUNT(*) AS count
FROM marketing
GROUP BY Marital_Status;

# Has YOLO, Alone and Absurd as categories which don't make sense
# Classifying Alone, YOLO and Absurd as NULL
# Can't tell if Alone is meant to be single or widowed or divorced
UPDATE marketing
SET Marital_Status = NULL
WHERE Marital_Status = 'YOLO'
OR Marital_Status = 'Absurd'
OR Marital_status = 'Alone';

# Checking they all worked
SELECT Marital_Status, COUNT(*) AS count
FROM marketing
GROUP BY Marital_Status;

# -- Kid Home
SELECT KidHome, COUNT(*) AS count
FROM marketing
GROUP BY KidHome;

# -- Teen Home
SELECT Teenhome, COUNT(*) AS count
FROM marketing
GROUP BY Teenhome;

# -- Country 
SELECT Country, COUNT(*) AS count
FROM marketing
GROUP BY Country;

# Mexico has an unusually small number of 3
# Looking at those entries in case there is anything particular about those entries
SELECT *
FROM marketing
WHERE Country = 'Mexico';
# Nothing to suggest it's wrong so leaving it in

# -- Income (annual)
SELECT MIN(Income), MAX(Income)
FROM marketing;

SELECT *
FROM marketing
ORDER BY Income ASC;

# Four digit numbers for income seem low for yearly income but not impossible
# No information to suggest it's wrong so leaving as is

# -- Dt_Customer
# First making sure it is in date format
ALTER TABLE marketing
MODIFY Dt_Customer DATE;

# Checking if there are any null values after that change
SELECT Dt_Customer
FROM marketing
WHERE Dt_Customer IS NULL;

# Finding first and last date someone was added to db
SELECT MIN(Dt_Customer), MAX(Dt_Customer)
FROM marketing;

SELECT *
FROM marketing
ORDER BY Dt_Customer DESC;
# No outliers in Dt_Customer column

-- Recency (days since last purchase)
SELECT MIN(Recency), MAX(Recency)
FROM marketing;

SELECT *
FROM marketing
ORDER BY Recency DESC;
# Nothing unusual or odd in this column either

-- Already checked that Mnt and Num columns have no nulls
-- Not much to check aside from that as no indication of what would be the wong value

-- Just checking that the binary columns are actually binary
SELECT *
FROM marketing
WHERE AcceptedCmp1 NOT IN (0, 1)
OR AcceptedCmp2 NOT IN (0, 1)
OR AcceptedCmp3 NOT IN (0, 1)
OR AcceptedCmp4 NOT IN (0, 1)
OR AcceptedCmp5 NOT IN (0, 1)
OR Response NOT IN (0, 1)
OR Complain NOT IN (0, 1);
# Everything is 1 or 0 so all good

