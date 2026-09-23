/************************************
Q5. Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where
(i) the year is before 2012 and
(ii) the country has a null gdp_per_capita in 2012.

Your result should have the columns:
year
country_count
total
*************************************/
USE braintree;

SELECT `year`,
-- Making sure money is in format requested
CONCAT('$', ROUND(SUM(gdp_per_capita), 2)) AS total,
-- Making sure country count only includes those that are not null
COUNT(gdp_per_capita) AS country_count
FROM per_capita
-- restricting to years before 2012
WHERE `year` < 2012
-- restricting countries to those that have NULL values in 2012
AND country_code IN
	(SELECT country_code
	FROM per_capita
	WHERE gdp_per_capita IS NULL
	AND `year` = 2012)
GROUP BY `year`;