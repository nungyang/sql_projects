/************************************
Q7. Find the country with the highest average gdp_per_capita for each continent for all years.
Now compare your list to the following data set.
Please describe any and all mistakes that you can find with the data set below.
Include any code that you use to help detect these mistakes.

rank	continent_name	country_code	country_name	avg_gdp_per_capita
1	Africa	SYC	Seychelles	$11,348.66
1	Asia	KWT	Kuwait	$43,192.49
1	Europe	MCO	Monaco	$152,936.10
1	North America	BMU	Bermuda	$83,788.48
1	Oceania	AUS	Australia	$47,070.39
1	South America	CHL	Chile	$10,781.71
*************************************/
-- Creating tables instead of CTEs because they will help detect mistakes from the above table

CREATE TABLE avg_gdp_table AS (
	SELECT country_code,
	   ROUND(AVG(gdp_per_capita), 2) AS avg_gdp
	FROM per_capita
	GROUP BY per_capita.country_code
);

CREATE TABLE avg_gdp_table_cont AS (
	SELECT continents.continent_name,
		avg_gdp_table.country_code,
		countries.country_name,
		CONCAT('$', ROUND(avg_gdp_table.avg_gdp,2)) AS avg_gdp_per_capita,
        ROW_NUMBER() OVER(
			PARTITION BY (continent_name)
            ORDER BY avg_gdp DESC
		) AS ranking
	FROM avg_gdp_table
	JOIN unique_continents
		ON avg_gdp_table.country_code = unique_continents.country_code
	JOIN continents
		ON unique_continents.continent_code = continents.continent_code
	JOIN countries
		ON countries.country_code = avg_gdp_table.country_code
);

-- This is the ranking with correct values
SELECT *
FROM avg_gdp_table_cont
WHERE ranking = 1;

