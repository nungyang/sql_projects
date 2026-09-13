## Importing data
SET GLOBAL local_infile = 1;

USE world_layoffs;

DROP TABLE IF EXISTS layoffs_raw;

CREATE TABLE layoffs_raw (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off TEXT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions TEXT
);

## Loading CSV data into it:
LOAD DATA LOCAL INFILE '/Users/nungyang/Github/sql_walkthrough/layoffs.csv'
INTO TABLE layoffs_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
