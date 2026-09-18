/************************************
Q1. Data Integrity Checking & Cleanup
*************************************/

/*****
Question 1a)
Alphabetically list all of the country codes in the continent_map table that appear more than once.
Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, even though it should alphabetically sort to the middle.
Provide the results of this query as your answer.
*****/

-- First checking that all country codes are just three characters long
SELECT *
FROM map
WHERE LENGTH(country_code) != 3;
# There are some NULL values but no countries have have two or four characters, etc

-- Classifying NULL values as 'FOO' as stated in question
UPDATE map
SET country_code = 'FOO'
WHERE country_code = '';

-- Checking that using '' above are caught all the NULL values 
SELECT *
FROM map
WHERE LENGTH(country_code) != 3;

-- Alphabetically listing those that appear more than once
-- But making sure FOO is listed first
SELECT country_code, COUNT(*) AS count
FROM map
GROUP BY country_code
HAVING count > 1
ORDER BY
	CASE WHEN country_code = 'FOO' THEN 0 ELSE 1 END,
	country_code ASC;

/*****
Question 1b)
For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. 
The record that you keep should be the first one when sorted by the continent_code alphabetically ascending.
Provide the query/ies and explanation of step(s) that you follow to delete these records.
*****/

/* For every row with the same country code, they are sorted alphabetically by continent_code.
Each row is numbered in that order.
Row number 1 is always the first one after sorting, which is the row we want to keep
So filtering to rows with row number 1 at the end. */

WITH multiple_entries AS (
	SELECT *,    
	ROW_NUMBER () OVER (PARTITION BY country_code ORDER BY continent_code) AS rn
	FROM map
) SELECT *
FROM multiple_entries
WHERE rn = 1;