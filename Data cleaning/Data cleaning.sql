-- DATA CLEANING
SELECT *
FROM layoffs;

-- STEPS IN DATA CLEANING
-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA
-- 3. HANDLE NULL VALUES
-- 4. REMOVE COLUMNS

-- Create a copy of the table before doing any alterations
CREATE TABLE layoff_stagings
LIKE layoffs;

SELECT *
FROM layoff_stagings;

INSERT INTO layoff_stagings
SELECT *
FROM layoffs;

-- Now we are working on copy of table created as layoff_stagings
-- 1. REMOVE DUPLICATES
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoff_stagings;

WITH CTE_1 AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoff_stagings)
SELECT * FROM CTE_1 
WHERE row_num>1;

-- let's just look at the company oda to confirm
SELECT *
FROM layoff_stagings
WHERE company = 'Oda';
-- it looks like these are all legitimate entries and shouldn't be deleted.
-- We need to really look at every single row to be accurate

WITH CTE_1 AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_stagings)
SELECT * FROM CTE_1 
WHERE row_num>1;

-- Creating another table where row_num>1 inorder to delete the duplicate rows

CREATE TABLE `layoff_stagings2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoff_stagings2;

INSERT INTO layoff_stagings2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_stagings;

SELECT *
FROM layoff_stagings2
WHERE row_num>1;
-- DELETE Duplicates rows
DELETE 
FROM 
layoff_stagings2
WHERE row_num>1;
-- checking if dupicates are removed
SELECT *
FROM layoff_stagings2
WHERE row_num>1;

-- STANDARDIZING DATA
-- Remove space in company column
UPDATE layoff_stagings2
SET company=TRIM(company);
-- Checking the industry column
SELECT DISTINCT industry
FROM layoff_stagings2
ORDER BY industry;
-- It seems crypto and crypto currency are same
SELECT *
FROM layoff_stagings2
WHERE industry LIKE 'crypto%';
-- Updating crypto currency as crypto
UPDATE layoff_stagings2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

-- Checking  location column
SELECT DISTINCT location 
FROM layoff_stagings2
ORDER BY location;

-- Checking  country column
SELECT DISTINCT country 
FROM layoff_stagings2
ORDER BY country;

UPDATE layoff_stagings2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

-- Converting date column from string to date format
UPDATE layoff_stagings2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');
-- now we can convert the data type properly
ALTER TABLE layoff_stagings2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoff_stagings2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoff_stagings2
WHERE industry IS NULL
OR industry = '';

UPDATE layoff_stagings2
SET industry = NULL 
WHERE industry='';

SELECT *
FROM layoff_stagings2 t1
JOIN layoff_stagings2 t2
ON t1.company=t2.company
AND t1.location=t2.location
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- Removing null values in induatry by populating with columns having same company and location
UPDATE layoff_stagings2 t1
JOIN layoff_stagings2 t2
ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- DELETE the rows having both total paid off and percentage paid off is null

DELETE
FROM layoff_stagings2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *

FROM layoff_stagings2;

ALTER TABLE layoff_stagings2
DROP COLUMN row_num;