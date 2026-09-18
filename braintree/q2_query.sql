/*****************
Q2: List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.
The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp)
The list should include the columns:

rank
continent_name
country_code
country_name
growth_percent
******************/

/**
Part 1: Cleaning and standardising YEAR and gdp_per_capita columns
**/

/* I imported year and gpd as text so first making sure they both get classified as numbers
First checking making sure any empty rows are classified as NULL instead of empty string otherwise conversion won't work */
USE braintree;

-- YEAR column
SELECT *
FROM per_capita
WHERE LENGTH(`year`) < 4;
# All 4 digits long so nothing to clean in year before changing to integer

ALTER TABLE per_capita
MODIFY `year` INT;

-- gdp_per_capita column
SELECT *
FROM per_capita
WHERE gdp_per_capita NOT REGEXP '^[0-9]+\\.[0-9]+$';
# Quite a few rows with no value in gdp_per_capita

# Classifying them as NULL before converting gdp_per_capita to DECIMAL
UPDATE per_capita
SET gdp_per_capita = NULL
WHERE gdp_per_capita NOT REGEXP '^[0-9]+\\.[0-9]+$';

# Converting into decimal column
# Setting generous limits so as to not lose data
ALTER TABLE per_capita
MODIFY gdp_per_capita DECIMAL(20,10);

/*
Part 2: Checking for conflicting/duplicate values in relevant tables
*/

/* Will need to do a self join to create the table requested in the question.
Before that, I make sure there are no duplicate/conflicting values in each of the tables */

-- per_capita table
/* Need to look at country_code & year combo
We already know there will be several rows with same country code or year because each country has one row for each year
And there will be multiple rows for each year because there are multiple countries*/
SELECT country_code, `year`, COUNT(*) AS count
FROM per_capita
GROUP BY country_code, `year`
HAVING count > 1;
# No conflicting/duplicate values so going ahead with self-join

-- country table
/* There should only be one country code for each country */
SELECT country_code, COUNT(*)
FROM countries
GROUP BY country_code
HAVING COUNT(*) > 1;

-- map table
/* Checking if some countries fall under multiple continents */
SELECT country_code, COUNT(*)
FROM map
GROUP BY country_code
HAVING COUNT(*) > 1;

/* There are some countries that fall into multiple which makes sense
And is actually fine for the ranking we want to do since we create rankings for each continent
Nothing wrong with the same country falling into several different rankings
but just checking what they are */
SELECT *
FROM map
WHERE country_code IN (
    SELECT country_code
    FROM map
    GROUP BY country_code
    HAVING COUNT(*) > 1
)
ORDER BY country_code;
/* THey all look right except Armenia is also classified as being African for some reason
There is also a country code UMI but no record of it in other tables so will just leave it */

/* Removing record of Armenia as being African */
DELETE FROM map
WHERE country_code = 'ARM' AND continent_code = 'AF';

-- continents table
-- Checking this one manually since it's such a small table
SELECT *
FROM continents;

/*****
Part 3: Creating table with all relevant columns needed for question
*****/

/* Creating pct growth column first */
CREATE TABLE gdp_growth AS
WITH pct_growth_cte AS (
SELECT
 table_2011.country_code,
 (table_2012.gdp_per_capita - table_2011.gdp_per_capita) / table_2011.gdp_per_capita AS pct_growth
FROM per_capita AS table_2011
JOIN per_capita AS table_2012
	ON table_2011.country_code = table_2012.country_code
WHERE table_2011.`year` = 2011
AND table_2012.`year` = 2012)
/* Joining other tables in to get the columns requested in the question */
SELECT 
	pct_growth_cte.*,
    countries.country_name,
    continents.continent_name
FROM pct_growth_cte
/* Adding country table for the country name */
LEFT JOIN countries
	ON pct_growth_cte.country_code = countries.country_code
/* Adding map for the continent code, which we need for continent name from maps table */
LEFT JOIN map
	ON countries.country_code = map.country_code
/* Adding maps table for continent name */
LEFT JOIN continents
	ON continents.continent_code = map.continent_code;

    
/*****
Part 4: Cleaning table before ranking
*****/
SELECT *
FROM gdp_growth;

/* Dropping any rows with missing pct_growth since there is no way of ranking them anyway */
DELETE from gdp_growth
WHERE pct_growth IS NULL;

/* Some rows have missing continent name
Checking what they are */
SELECT *
FROM gdp_growth
WHERE continent_name IS NULL;

/* Continent for Kosovo is missing
It is  European so adding that data into the table */
UPDATE gdp_growth
SET continent_name = 'Europe'
WHERE country_name = 'Kosovo';

/* Checking it worked */
SELECT *
FROM gdp_growth;

/* Also adding it into map table in case it comes up in another analysis */
INSERT INTO map (country_code, continent_code)
VALUES ('KSV', 'EU');

/* Leaving the other countries with missing continents as they were not countries but regions
No need to delete them as when we do the ranking, they will form their own category */


/*****
Part 5: Pulling ranks 10-12 for each continent and making sure it is in correct format
*****/

WITH ranking AS (
	SELECT *,
    ROW_NUMBER () OVER (PARTITION BY continent_name ORDER BY pct_growth DESC) AS ranking
FROM gdp_growth)
SELECT 
    ranking,
    continent_name,
    country_code,
    country_name,
    CONCAT(ROUND(pct_growth * 100, 2), '%') AS growth_percent
FROM ranking
WHERE continent_name IS NOT NULL
AND ranking IN (10, 11, 12);

