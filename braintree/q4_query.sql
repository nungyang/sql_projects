/************************************
Q4a. What is the count of countries and sum of their related gdp_per_capita values for the year 2007
where the string 'an' (case insensitive) appears anywhere in the country name?
*************************************/

/* First restricting per_capita table to 2007*/
 WITH an_2007 AS (
 SELECT *
 FROM per_capita
 WHERE `year` = 2007
 )
SELECT COUNT(*),
	CONCAT('$', ROUND(SUM(gdp_per_capita), 2))
 FROM an_2007
 -- Joining countries table for country names
 LEFT JOIN countries
	ON an_2007.country_code = countries.country_code
WHERE countries.country_name LIKE '%an%';

/************************************
Q4b. Repeat question 4a, but this time make the query case sensitive.
*************************************/
WITH an_2007 AS (
 SELECT *
 FROM per_capita
 WHERE `year` = 2007
 )
SELECT COUNT(*),
	CONCAT('$', ROUND(SUM(gdp_per_capita), 2))
 FROM an_2007
 -- Joining countries table for country names
 LEFT JOIN countries
	ON an_2007.country_code = countries.country_code
WHERE countries.country_name LIKE BINARY '%an%';