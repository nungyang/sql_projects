## Resetting so I can always run this script from top to bottom
DROP TABLE IF EXISTS layoffs;

## Creating new layoffs table to leave layoffs_raw as raw table 
CREATE TABLE layoffs
LIKE layoffs_raw;

INSERT layoffs
SELECT *
FROM layoffs_raw;

-- DUPLICATES
## Identifying duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, `date`,
    stage, country, funds_raised_millions) AS row_num
FROM layoffs
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

DROP TABLE IF EXISTS layoffs2;

## Creating dataset without duplicates
CREATE TABLE layoffs2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off TEXT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions TEXT,
    row_num INT
);

INSERT INTO layoffs2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, `date`,
    stage, country, funds_raised_millions) AS row_num
FROM layoffs;

DELETE
FROM layoffs2
WHERE row_num > 1;

-- STANDARDISATION
# Removing trailing white spaces in company name
UPDATE layoffs2
SET company = TRIM(company);

# Standardising industry category for those in crypto
UPDATE layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# There was one version of United States that had a . at the end of it
UPDATE layoffs2
SET country = TRIM(TRAILING '.' FROM country);

# Converting date to date format
UPDATE layoffs2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs2
MODIFY COLUMN `date` DATE;

# Convert numbers into integers, currently recognised as text
UPDATE layoffs2
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

ALTER TABLE layoffs2
MODIFY COLUMN total_laid_off INT;


UPDATE layoffs2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

ALTER TABLE layoffs2
MODIFY COLUMN percentage_laid_off DECIMAL(10, 5);


UPDATE layoffs2
SET funds_raised_millions = NULL
WHERE funds_raised_millions LIKE '%null%';

ALTER TABLE layoffs2
MODIFY COLUMN funds_raised_millions INT;


-- NULL VALUES
UPDATE layoffs2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs2 t1
JOIN layoffs2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

DELETE
FROM layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs2
DROP COLUMN row_num;

SELECT *
FROM layoffs2;