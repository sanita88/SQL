-- Exploratory Data Analysis
SELECT *
FROM layoff_stagings2;
-- MAX total laid off and percentage laid off
SELECT MAX(total_laid_off) AS max_layoff,MAX(percentage_laid_off) AS max_perc
FROM layoff_stagings2;
-- SELECT the companies with 100% percentage laid off
SELECT *
FROM layoff_stagings2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoff_stagings2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

SELECT company,SUM(total_laid_off)
FROM layoff_stagings2
GROUP BY company 
ORDER BY 2 DESC;

-- RANGE of dates where laid off happened
SELECT MIN(`date`) , MAX(`date`)
FROM layoff_stagings2;

-- Industry having most lay offs
SELECT industry,SUM(total_laid_off)
FROM layoff_stagings2
GROUP BY industry
ORDER BY 2 DESC;

-- country with most lay offs
SELECT country,SUM(total_laid_off)
FROM layoff_stagings2
GROUP BY country
ORDER BY 2 DESC;

-- Most lay offs year
SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoff_stagings2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoff_stagings2
GROUP BY stage
ORDER BY 2 DESC;

-- Rolling total year wise
SELECT SUBSTRING(`date`,1,7) AS month_wise,SUM(total_laid_off)
FROM layoff_stagings2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY month_wise
ORDER BY 1;

WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1,7) AS month_wise,SUM(total_laid_off) AS total_off
FROM layoff_stagings2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY month_wise
ORDER BY 1
)
SELECT month_wise,total_off,SUM(total_off) OVER (ORDER BY month_wise) AS rolling_total
FROM Rolling_Total;

SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoff_stagings2
GROUP  BY company,YEAR(`date`)
ORDER BY 3 DESC;


WITH company_year(comapny,years,total_laid_off) AS
(SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoff_stagings2
GROUP  BY company,YEAR(`date`)
),Company_year_Rank AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL)
SELECT *
FROM Company_year_Rank 
WHERE ranking <=5;


