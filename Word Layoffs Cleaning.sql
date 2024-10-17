SELECT *
FROM layoffs;

-- Creating a new table to manipulate data.

CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;


INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Check for and remove duplicates

SELECT *
FROM layoffs_staging;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off
, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off
, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; -- Query to confirm duplicates in table.


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; -- Creating a second table to delete duplicate rows.


SELECT *
FROM layoffs_staging2;


INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off
, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardizing the data

SELECT company, TRIM(company) -- Identifies if blank spaces exist in column
FROM layoffs_staging2;


UPDATE layoffs_staging2 -- Removal of blank spaces from the table.
SET company = TRIM(company);


SELECT DISTINCT industry -- Checking for repetitive similar industries
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE  'Crypto%';


UPDATE layoffs_staging2 -- Updating Crypto industry to have a single uniform name
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country, TRIM( TRAILING '.' FROM country) -- Removing accidental period after United States in one of the rows.
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM( TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y') -- Changing the date format.
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');


SELECT `date`
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2 -- Changing the data type of the date column.
MODIFY COLUMN `date` DATE;


-- 3. Dealing with null or blank values

SELECT * -- Finding rows with double nulls in key columns
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT * -- Finding blank or null industries
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


SELECT * -- Comparing rows with blank industry data to other rows with the same company but with populated industry data, in order to then update our table.
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging2 t1 -- Updating null industry values in our table
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- 4. Removing any unnecessary columns

SELECT * -- Finding rows with double nulls in key columns
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2 -- Dropping row number column added in the beginning of the cleaning process to identify duplicate rows.
DROP COLUMN row_num;

