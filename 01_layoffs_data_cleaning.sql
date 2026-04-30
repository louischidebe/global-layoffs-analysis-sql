SELECT * FROM layoffs;

-- Remove Duplicates
-- Standardize the Data
-- Null or Blank Values
-- Remove Any Unnecessary Columns or Rows


CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH cte_duplicate AS (
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country ) AS row_num
FROM layoffs_staging
)
SELECT *
FROM cte_duplicate
WHERE row_num > 1;

SELECT * FROM layoffs_staging
WHERE company = 'Cars24';


WITH cte_duplicate AS (
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country ) AS row_num
FROM layoffs_staging
)

DELETE
FROM cte_duplicate
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country ) AS row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardising Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Auckland, Bengaluru, Brisbane, Buenos Aires
-- Cayman Islands, Gurugram, Kuala Lumpur. London
-- Luxembourg, MalmÃ¶, Non-U.S. to Malmo, Non-U.S. Melbourne, Victoria
-- Montreal, Mumbai, New Delhi, New York City, Singapore, Tel Aviv, Vancouver

UPDATE layoffs_staging2
SET location = CASE 
    WHEN location LIKE 'Auckland%' THEN 'Auckland'
    WHEN location LIKE 'Bengaluru%' THEN 'Bengaluru'
    WHEN location LIKE 'Brisbane%' THEN 'Brisbane'
    WHEN location LIKE 'Buenos Aires%' THEN 'Buenos Aires'
    WHEN location LIKE 'Cayman Islands%' THEN 'Cayman Islands'
    WHEN location LIKE 'Gurugram%' THEN 'Gurugram'
    WHEN location LIKE 'Kuala Lumpur%' THEN 'Kuala Lumpur'
    WHEN location LIKE 'London%' THEN 'London'
    WHEN location LIKE 'Luxembourg%' THEN 'Luxembourg'
    WHEN location LIKE 'Melbourne%' THEN 'Melbourne'
    WHEN location LIKE 'Montreal%' THEN 'Montreal'
    WHEN location LIKE 'Mumbai%' THEN 'Mumbai'
    WHEN location LIKE 'New Delhi%' THEN 'New Delhi'
    WHEN location LIKE 'Singapore%' THEN 'Singapore'
    WHEN location LIKE 'Tel Aviv%' THEN 'Tel Aviv'
    WHEN location LIKE 'Vancouver%' THEN 'Vancouver'
    ELSE location
END;

SELECT 
    location AS Old_Location,
    CASE 
        WHEN location LIKE 'Auckland%' THEN 'Auckland'
        WHEN location LIKE 'Bengaluru%' THEN 'Bengaluru'
        ELSE location
    END AS New_Location
FROM layoffs_staging2
WHERE location LIKE 'Auckland%' 
   OR location LIKE 'Bengaluru%';
   
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT `date`
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = '';


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT date_added, str_to_date(date_added, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

SELECT date_added
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN date_added DATE;

-- Blank and Null Values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Eyeo';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off = '' AND percentage_laid_off = '';

-- I'll be needing total_laid_off and percentage_laid_off a lot in Exploratory Data Analysis, so I'll remove rows with blanks:

DELETE
FROM layoffs_staging2
WHERE total_laid_off = '' AND percentage_laid_off = '';


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;