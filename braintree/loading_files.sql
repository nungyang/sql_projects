/* Brain tree challenge
Source: https://github.com/AlexanderConnelly/BrainTree_SQL_Coding_Challenge_Data_Analyst
*/

/************************
-- Section 0: Setting up
**************************/

USE braintree;
SET GLOBAL local_infile = 1; -- enabling local file loading

/* Loading all files
Loading all columns as TEXT in the first instance to avoid losing data */

-- Loading continent_map.csv
CREATE TABLE map (
	country_code TEXT,
    continent_code TEXT
);

LOAD DATA LOCAL INFILE '/Users/nungyang/GitHub/sql_projects/braintree/continent_map.csv'
INTO TABLE map
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Loading continents.csv
CREATE TABLE continents (
	continent_code TEXT,
    continent_name TEXT
);

LOAD DATA LOCAL INFILE '/Users/nungyang/GitHub/sql_projects/braintree/continents.csv'
INTO table continents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
	
-- Loading countries.csv
CREATE TABLE countries (
	country_code TEXT,
    country_name TEXT
);

LOAD DATA LOCAL INFILE '/Users/nungyang/GitHub/sql_projects/braintree/countries.csv'
INTO table countries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
	
-- Loading per_capita.csv
CREATE TABLE per_capita (
	country_code TEXT,
    year TEXT,
    gdp_per_capita TEXT
);

LOAD DATA LOCAL INFILE '/Users/nungyang/GitHub/sql_projects/braintree/per_capita.csv'
INTO table per_capita
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
    