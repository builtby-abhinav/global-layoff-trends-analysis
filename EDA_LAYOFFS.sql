/*
=========================================================
EXPLORATORY DATA ANALYSIS (EDA)
=========================================================

Dataset:
    layoffs_ND (Cleaned Dataset)

Description:
    This section explores the cleaned layoffs dataset to
    identify trends, patterns, and key insights related to
    workforce reductions across companies, industries,
    countries, locations, funding stages, and time.

Objectives:
    - Analyze the overall scale of layoffs.
    - Identify companies and industries with the highest layoffs.
    - Explore trends over time.
    - Compare layoffs across countries and locations.
    - Examine the impact of funding stage and company funding.
    - Generate insights for reporting and visualization.

=========================================================
*/

	SELECT *
		FROM layoffs_ND;


-- 	Now lets find MAX & MIN values
-- =========================================================
-- SUMMARY STATISTICS
--
-- Purpose:
--   Examine the overall distribution of numeric values such as
--   layoffs, layoff percentages, and funding amounts.
--
-- Expected Result:
--   Key statistics including minimum, maximum, and averages.
-- =========================================================

-- Earliest Layoff

	SELECT MIN(date)
		FROM layoffs_ND;
--	It's 2020-03-11

-- Latest Layoff

	SELECT MAX(date)
		FROM layoffs_ND;
--	It's 2023-03-06

-- Lets Find MAX & MIN total_laid_offs

	SELECT 
		MIN(total_laid_off),
		MAX(total_laid_off)
	FROM layoffs_ND;
-- MIN = 3, MAX 12000


-- Analyze the minimum and maximum layoff percentages.
--
-- Purpose:
--   Identify the smallest and largest proportion of employees
--   laid off in a single event.
--
-- Note:
--   The 'percentage_laid_off' column stores values as decimals,
--   where 1.0 represents 100% of the workforce being laid off.
--
-- Expected Result:
--   The minimum and maximum layoff percentages recorded
--   in the dataset.

	SELECT 
		MIN(percentage_laid_off),
		MAX(percentage_laid_off)
	FROM layoffs_ND;
-- MIN - 0 , MAX - 1 (where 1 = 100% )

	SELECT *
		FROM layoffs_ND
	WHERE 
		percentage_laid_off = 1
	ORDER BY total_laid_off DESC;
	
	SELECT *
		FROM layoffs_ND
	WHERE
			percentage_laid_off = 1
		AND total_laid_off IS NOT NULL
	ORDER BY total_laid_off DESC;
--	There are a total of 43 companies with 100% layoffs

-- Company with Highest & lowest Funds_raised
	SELECT	company,
			funds_raised_millions
	 FROM  layoffs_ND
	 ORDER BY company, funds_raised_millions ASC;
-- Min = #PAID - 21Millions

-- 
	SELECT	company,
			funds_raised_millions
	 FROM  layoffs_ND
	 ORDER BY funds_raised_millions DESC;
--	Max = 121900 Millions - Netflix

-- Total laid offs per each company
	SELECT 
	 	 	 company,
		     SUM(total_laid_off) AS total_layoffs
		FROM layoffs_ND
	GROUP BY company
	ORDER BY total_layoffs DESC;

-- Lowest = Branch - 3, Highest = Amazon - 18150

-- Total layoffs by Industry
	SELECT
			 Industry,
		     SUM(total_laid_off) AS total_layoffs
		FROM layoffs_ND
	GROUP BY industry
	ORDER BY total_layoffs DESC;

-- Min = manufacturing - 20, Max = Consumer - 45182 

-- Total layoffs by Country , Location
		SELECT
			 country,
			 location,
		     SUM(total_laid_off) AS total_layoffs
		FROM layoffs_ND
	GROUP BY country,
			 location
	ORDER BY total_layoffs DESC;
-- Min = Country - United states, Indianapolis - 20
-- Max = Country - United states, SF bay 	   - 125601

-- top 10 companies with total layoffs
	SELECT 
			company,
			SUM(total_laid_off) AS TOTAL_LAIDOFF
	FROM 	layoffs_ND
	WHERE 	total_laid_off is NOT NULL
	GROUP BY company
	ORDER BY TOTAL_LAIDOFF DESC
	LIMIT 10;
	
-- =========================================================
-- YEARLY LAYOFF ANALYSIS
-- =========================================================

	-- Highest laid off at a single time
		SELECT	date,
			 company,
			 total_laid_off
		FROM layoffs_ND
		WHERE total_laid_off = 
							   ( SELECT 
							   MAX(total_laid_off)
							   FROM layoffs_ND);
-- RESULT = 2023-01-10, Google, 12000 laid off
-- Total layoffs by month
	SELECT 	
				DATE_TRUNC('month', date) AS month,
				SUM(total_laid_off) AS total_laid
	   FROM	    layoffs_ND
	   GROUP BY month
	   ORDER BY	month;
-- we got the insights of month-wise total laid_offs
-- In 2020 April leads with highest layoffs of 26710
-- In 2021 January leads with highest layoffs of 6813
-- In 2022 November leads with highest layoffs of 53451
-- In 2023 January recorded the highest monthly layoffs with 84,714 employees.
-- OBSERVATION
--
-- i've observed that year by year mass Layoffs increased But
-- in the initial year 2020 to next year 2021 the layoffs dropped by 74.64% ( from 26710 to 6813 )
-- In the year 2022 layoffs hiked by 684.54%
-- In the year 2023 layoffs hiked by 58.4%
-- Overall, 2022 recorded the highest total layoffs in the dataset.


-- Average layoffs per each company
		SELECT
				company,
				AVG(total_laid_off) AS AVG_LAYOFFS
		  FROM	layoffs_ND
		 WHERE	total_laid_off IS NOT NULL
	  GROUP BY	company
	  ORDER BY	AVG_LAYOFFS DESC;

--	OBSERVATIONS
-- Google ranks the top with Avg of 12000 &
-- Branch ranks the least with avg of 3


---- Average layoffs per each industry
		SELECT
				industry,
				AVG(total_laid_off) AS AVG_LAYOFFS
		  FROM	layoffs_ND
		 WHERE	total_laid_off IS NOT NULL
	  GROUP BY	industry
	  ORDER BY	AVG_LAYOFFS DESC;
--	OBSERVATIONS
--  Manufacturing ranks the least with Avg of  20 &
--  Hardware ranks the top with avg of 1382


-- Average layoffs per country.
	  	SELECT
				country,
				AVG(total_laid_off) AS AVG_LAYOFFS
		  FROM	layoffs_ND
		 WHERE	total_laid_off IS NOT NULL
	  GROUP BY	country
	  ORDER BY	AVG_LAYOFFS DESC;
--	OBSERVATIONS
--  Poland ranks the least with Avg of 25 &
--  Netherlands ranks the top with avg of 1913.3333333333333333

--	Count of number of layoff events for each company.
		SELECT
				company,
				COUNT(*) AS Layoff_Events
	  	FROM	layoffs_ND
  	GROUP BY	company
  	ORDER BY	Layoff_Events DESC;
-- OBSERVATIONS
-- the highest laying off events that took place in Company named Loft about 6 times
-- About 1415 companies laid their employees only once
			
-- Top funded companies with the highest layoffs.	
		SELECT 	
			    company,
				MAX(funds_raised_millions) AS funds_raised,
				SUM(total_laid_off) AS total_laid
		  FROM	layoffs_ND
		 WHERE	total_laid_off IS NOT NULL AND 
		 		funds_raised_millions IS NOT NULL
	  GROUP	BY	company
	  ORDER BY	funds_raised DESC,
	  			total_laid DESC;
-- OBSERVATION
--
-- Netflix is the highest-funded company in the dataset,
--
-- Several highly funded companies still experienced
-- significant layoffs, indicating that large funding
-- does not necessarily prevent workforce reductions.
--
-- Companies such as Meta, Uber, Twitter, Byju's,
-- Salesforce, Amazon, and Google also recorded
-- substantial layoffs despite raising large amounts
-- Overall, there is no clear evidence from this dataset
-- that higher funding consistently results in fewer layoffs.

-- Total layoffs by funding stage

SELECT
    stage,
    SUM(total_laid_off) AS total_laid
FROM layoffs_ND
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_laid DESC;
-- OBSERVATION
-- Stage with highest layoffs (204132) - POST IPO
-- Stage with lowest layoffs (1094) - Subsidiary


---- Total layoffs by funding range
SELECT
    CASE
        WHEN funds_raised_millions < 100 THEN '<100M'
        WHEN funds_raised_millions < 1000 THEN '100M-999M'
        WHEN funds_raised_millions < 10000 THEN '1B-9.9B'
        ELSE '10B+'
    END AS funding_range,

    SUM(total_laid_off) AS total_laid
FROM layoffs_ND
WHERE funds_raised_millions IS NOT NULL
GROUP BY funding_range
ORDER BY total_laid DESC;

-- OBSERVATIONS
-- 100M-999M range - 145447 employees laid
-- <100M range - 83918 employees laid
-- 1B-9.9B range - 81224 employees laid
-- 10B+ range - 24770 employees laid