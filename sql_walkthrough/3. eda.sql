-- EXPLORATORY DATA ANALYSIS

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs2;

# Date range of layoff dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs2;

# Looking at instances where the company has gone down
SELECT *
FROM layoffs2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

# Total number of layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs2
GROUP BY company
ORDER BY 2 DESC;

# Total number of layoffs by company
SELECT industry, SUM(total_laid_off)
FROM layoffs2
GROUP BY industry
ORDER BY 2 DESC;

# Total number of layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs2
GROUP BY country
ORDER BY 2 DESC;

# Avg % of layoffs by company
SELECT company, AVG(percentage_laid_off)
FROM layoffs2
GROUP BY company
ORDER BY 2 DESC;

SELECT * 
FROM layoffs;

# Rolling total number of layoffs by year
WITH rolling_total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS year_mon,
SUM(total_laid_off) AS total_lo
FROM layoffs2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY year_mon
ORDER BY year_mon ASC
)
SELECT year_mon, total_lo, SUM(total_lo) OVER(ORDER BY year_mon) AS rolling_total
FROM rolling_total;

# Ranking of companies by total laid off for each year
WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs2
GROUP BY company, YEAR(`date`)
), company_rank AS(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_rank
WHERE ranking <= 5
ORDER BY years ASC, ranking ASC;

