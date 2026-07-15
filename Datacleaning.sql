-- Data Cleaning

select * 
from work_layoff.layoffs;

-- Making copy of the row dataset
 
create table layoff_staging
LIKE layoffs;

SELECT * FROM  layoff_staging;

INSERT layoff_staging
SELECT * 
FROM layoffs;

SELECT *
FROM layoff_staging;


-- 1. Remove Duplicates

-- Checking for duplicate rows by counting each row if its more than one row_num

select company, location, total_laid_off, percentage_Laid_off, `date`,
Row_Number() over(
partition by company, location, total_laid_off, percentage_Laid_off, `date`) as row_num
from 
work_layoff.layoff_staging;


SELECT *
FROM (
select company, location, total_laid_off, percentage_Laid_off, `date`,
Row_Number() over(
partition by company, location, total_laid_off, percentage_Laid_off, `date`) as row_num
from 
work_layoff.layoff_staging
) duplicates
WHERE row_num >1 ;

-- AS in result if we check there are multiple rows with duplicate value 
-- but its important to cross check the rows

SELECT * 
FROM layoff_staging
WHERE company = 'Oda';

-- As after checking this row it can be seen that the value is diffrent so its necesary to check all the columns


SELECT *
FROM (
select company, location, industry, total_laid_off, percentage_Laid_off, `date`, stage, country, funds_raised_millions,
Row_Number() over(
partition by company, location, industry, total_laid_off, percentage_Laid_off, `date`, stage, country, funds_raised_millions) as row_num
from 
work_layoff.layoff_staging
) duplicates
WHERE row_num >1 ;

-- cross check the duplicate
 
SELECT * 
FROM layoff_staging
WHERE company = 'Hibob';


-- even for this duplicate let do delect column but with creating new table

SELECT *
FROM world_layoffs.layoffs_staging
;

CREATE TABLE `work_layoff`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

SELECT * FROM work_layoff.layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
Row_Number() over(
partition by company, location, industry, total_laid_off, percentage_Laid_off, `date`, stage, country, funds_raised_millions) as row_num
from 
work_layoff.layoff_staging;


SELECT * 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- 2. Standardize Data 
-- Trim the data 

SELECT company, trim((company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim((company));

-- finding same value with different name and rename

SELECT distinct industry
from layoffs_staging2
ORDER BY 1;

-- Found the Crypto with 2 more different name 
-- Rename all with same name

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

SELECT distinct location
from layoffs_staging2
ORDER BY 1;

SELECT distinct country
from layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

SELECT country
from layoffs_staging2
group by country;

SELECT `date`
FROM layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
 
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 3. Null value or blank values

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry='';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ='';


SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry = 'NULL'
and t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry = 'NULL' 
and t2.industry != 'NULL';

SELECT *
FROM layoffs_staging2
where company = 'Airbnb';

-- 4. Removing clumn and rows 

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- as it shows null values for the layoff and percentage layoff which we dont need as its already null

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- and thats all all the data is clean and ready for the analysis


