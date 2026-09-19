/************************************
Q3. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World.

Your result should look something like

Asia	Europe	Rest of World
25.0%	25.0%	50.0%
*************************************/

USE braintree;

/* Unlike some of the previous questions where it was ok if a country fell under several continents
there should only be one continent for each country in this question otherwise we'd be double counting
so dealing with this first. First creating a version of the table where each country only falls under one continent.
I use the same classifications as the UN: https://unstats.un.org/unsd/methodology/m49/. */

-- First creating a version of map table where each country only falls under one continent
CREATE TABLE unique_continents AS
SELECT *
FROM map;

-- Checking which ones would need cleaning
SELECT *
FROM unique_continents
WHERE country_code IN (
    SELECT country_code
    FROM map
    GROUP BY country_code
    HAVING COUNT(*) > 1
)
ORDER BY country_code;

-- Deleting all rows if UN does not classify them in that country
DELETE FROM unique_continents
-- Armenia classified as Asia so dropping the EU
WHERE (country_code = 'ARM' AND continent_code = 'EU')
-- Azerbaijan classified as Asia, dropping EU
OR (country_code = 'AZE' AND continent_code = 'EU')
-- Cyprus classified as Asia, dropping EU
OR (country_code = 'CYP' AND continent_code = 'EU')
-- Dropping all FOO as this was just for one of the previous questions
-- It actually just was rows with missing countries so do not know continent
OR (country_code = 'FOO')
-- Georgia classified as Asia, dropping EU
OR (country_code = 'GEO' AND continent_code = 'EU')
-- Kazakhstan classified as Asia, dropping EU
OR (country_code = 'KAZ' AND continent_code = 'EU')
-- Russia classified as EU, dropping Asia
OR (country_code = 'RUS' AND continent_code = 'AS')
-- Turkey classified as Asia, dropping EU
OR (country_code = 'TUR' AND continent_code = 'EU')
-- UMI classified as Oceana, dropping NA
OR (country_code = 'UMI' AND continent_code = 'NA');

-- Now merging per_capita with map
CREATE TABLE per_capita_2012 AS 
SELECT
	table_2012.country_code,
    table_2012.gdp_per_capita AS gdp_2012,
    unique_continents.continent_code
FROM per_capita AS table_2012
JOIN unique_continents
	ON table_2012.country_code = unique_continents.country_code
WHERE table_2012.`year` = 2012;

-- Making sure there are no countries that are listed twice
SELECT *
FROM per_capita_2012
WHERE country_code IN (
	SELECT country_code
    FROM per_capita_2012
    GROUP BY country_code
    HAVING COUNT(*) = 1);

-- Creating the final table
SELECT
	CONCAT(ROUND(100 * SUM(CASE WHEN continent_code = 'AS' THEN gdp_2012 ELSE 0 END ) / SUM(gdp_2012), 2),'%') AS 'Asia',
	CONCAT(ROUND(100 * SUM(CASE WHEN continent_code = 'EU' THEN gdp_2012 ELSE 0 END ) / SUM(gdp_2012), 2), '%') AS 'Europe',
	CONCAT(ROUND(100 * SUM(CASE WHEN continent_code NOT IN ('AS', 'EU') THEN gdp_2012 ELSE 0 END ) / SUM(gdp_2012), 2), '%') AS 'Rest of the World'
FROM per_capita_2012;
