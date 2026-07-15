-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- to check which company has the 100 percent layoff

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY year(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT substring(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

-- Rolling month layoff 

WITH ROllingLayoff AS 
(
SELECT substring(`date`,1,7) AS `Month`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off, 
SUM(total_off) OVER (ORDER BY `Month` ASC) as rolling_total_layoffs
FROM ROllingLayoff
ORDER BY `Month` ASC;


SELECT company, year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, year(`date`)
ORDER BY 1 ASC;

-- Year wise and rank wise top company with high layoff

WITH Company_Year (Company, YEARS, Totallayoff) AS
(
SELECT company, year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, year(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() over( PARTITION BY YEARS ORDER BY Totallayoff DESC) AS Ranking
FROM Company_Year
WHERE YEARS IS NOT NULL)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;





