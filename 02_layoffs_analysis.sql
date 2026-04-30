-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off),
MAX(percentage_laid_off)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;  -- the data seems to show a majority of the layoffs happened in the US

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;  -- Amazon has the total layoffs with 58k in 6 years

SELECT MIN(`date`),
MAX(`date`)   -- the data is dated from 2020, assuming, from the hit of the covid19 pandemic to 6 years later
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry  -- Retail, Hardwaee, Consumer are the most affected industries, with Product, AI and Legal being the least affected
ORDER BY 2 DESC; 

SELECT country,
SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;      -- confirmed: the US is leading India by 89% with 618k layoffs in 6 years

SELECT YEAR(`date`),
SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;     -- the most impacted year was 2023, with 264k layoffs

SELECT SUBSTRING(`date`, 1, 7) AS `Month`,
SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;  -- sudden spike in October, 2022 that went on till August the following year, after which the biggest layoffs happened on Januaries

WITH Rolling_Sum AS (
SELECT SUBSTRING(`date`, 1, 7) AS `Month`,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`,
total_layoffs,
SUM(total_layoffs) OVER(ORDER BY `Month`) AS Rolling_total
FROM Rolling_Sum;

SELECT company,
YEAR(`date`),
SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (Company, Years, Total_layoffs) AS (
SELECT company,
YEAR(`date`),
SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Pre_Ranking AS (
SELECT *,
DENSE_RANK () OVER (PARTITION BY Years ORDER BY Total_layoffs DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Pre_Ranking
WHERE Ranking <= 5;  -- Amazon and Meta have been ranked among the top 5 companies with the biggest layoffs per year

SELECT stage,
MAX(percentage_laid_off)
FROM layoffs_staging2
GROUP BY stage;

SELECT company,
COUNT(company) as layoff_rounds,
SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(company) > 1
ORDER BY 2 DESC;  -- Amazon, Salesforce, Rivian, Google, Microsoft have the most frequent layoffs


-- Total vs Average layoffs (stability)
SELECT industry,
AVG(total_laid_off) AS average_layoffs,
SUM(total_laid_off) AS total_layoffs, 
ROUND(AVG(percentage_laid_off) * 100, 2) AS average_percentage_layoffs,
COUNT(*) AS total_layoff_events
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL AND industry != ''
GROUP BY industry
ORDER BY average_percentage_layoffs DESC;   -- Aerospace and Construction are not the biggest industries, but when there are layoffs, they are big

SELECT stage,
COUNT(*) AS number_of_layoffs,
SUM(CASE WHEN percentage_laid_off = 1 THEN 1 ELSE 0 END) AS total_shutdowns,
ROUND((SUM(CASE WHEN percentage_laid_off = 1 THEN 1 ELSE 0 END ) / COUNT(*)) * 100, 2) AS fatality_rate
FROM layoffs_staging2
WHERE stage != 'Unknown' AND stage != ""
GROUP BY stage
ORDER by fatality_rate DESC;   -- the Seed stage has been by far the riskiest, with a rate of 63%, with Series A coming second with 18.58%