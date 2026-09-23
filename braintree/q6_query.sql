/************************************
Q5. 6. All in a single query, execute all of the steps below and provide the results as your final answer:

a. create a single list of all per_capita records for year 2009 that includes columns:
continent_name
country_code
country_name
gdp_per_capita

b. order this list by:
continent_name ascending
characters 2 through 4 (inclusive) of the country_name descending

c. create a running total of gdp_per_capita by continent_name

d. return only the first record from the ordered list for which
each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns:
continent_name
country_code
country_name
gdp_per_capita
running_total
*************************************/
USE braintree;

WITH q6 AS (
	SELECT continents.continent_name,
	per_capita.country_code,
	per_capita.gdp_per_capita,
	countries.country_name
	FROM per_capita
	-- adding countries table for the country name
	LEFT JOIN countries
		ON per_capita.country_code = countries.country_code
	-- adding unique continents table for the continent code
	LEFT JOIN unique_continents
		ON countries.country_code = unique_continents.country_code
	-- adding continents table for the continent name
	LEFT JOIN continents
		ON continents.continent_code = unique_continents.continent_code
	WHERE `year` = 2009
    -- removing those where continent is null because doesn't make sense to rank all countries when they're not in the same continent
    AND continents.continent_name IS NOT NULL
),
totals AS (
	SELECT *,
		SUM(gdp_per_capita) OVER (
			PARTITION BY continent_name
            ORDER BY continent_name ASC, SUBSTRING(country_name, 2, 3) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS running_total
	FROM q6
),
ranked AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY continent_name
            ORDER BY running_total
		) AS rn
	FROM totals
    WHERE running_total >= 70000
)
SELECT continent_name,
	country_code,
	CONCAT('$', ROUND(gdp_per_capita, 2)) AS gdp_per_capita,
	country_name,
	CONCAT('$', ROUND(running_total, 2)) AS running_total
FROM ranked
WHERE rn = 1
ORDER BY continent_name;

