/*
HEADERS OF RAW DATASET
company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions
*/

/*
    This dataset contains layoff records from various companies across multiple
    industries. It is used for SQL data cleaning, analysis, and visualization
    to uncover trends and insights related to workforce reductions.
*/

-- STEPS INVOLVED IN THE DATA CLEANING..
-- 1. Remove Duplicates
-- 2. Standardize The Data
-- 3. Null values OR Blank values
-- 4. Remove Any Columns ( which are not necessary )

CREATE TABLE layoffs (
 	company TEXT,
	location TEXT,
	industry TEXT,
	total_laid_off TEXT,
	percentage_laid_off TEXT,
	date TEXT,
	stage TEXT,
	country TEXT,
	funds_raised_millions TEXT
)

-- Now we create a copy of the original "layoffs" table
-- Coz we can trace back to source if anything goes wrong
-- We name the copied table as layoffs_E (E-Exercising)

CREATE TABLE layoffs_E
(LIKE layoffs INCLUDING ALL);

INSERT INTO layoffs_E
SELECT *
FROM layoffs;

-- Now campare the num of rows in both tables
-- both numbers should match

SELECT COUNT (*)
FROM layoffs;

SELECT COUNT (*)
FROM layoffs_E;

-- both row count matched that means everthing came up nice and clean ✅
-- LOCATING DUPLICATES
-- WE CAN DO THAT IN 2 WAYS

-- 1.
SELECT
	company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	date,
	stage,
	country,
	funds_raised_millions,
	COUNT(*) AS duplicate_cells
FROM layoffs
GROUP BY 
	company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	date,
	stage,
	country,
	funds_raised_millions
	having count(*) > 1;

-- 2.

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	date,
	stage,
	country,
	funds_raised_millions) AS row_num
FROM layoffs_E
ORDER BY company;

WITH CTE AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	date,
	stage,
	country,
	funds_raised_millions
	ORDER BY company ) AS row_num
FROM layoffs_E
)

SELECT *
FROM CTE
WHERE row_num > 1;

/* we found the duplicates now instead of deleting them we are just transfering the originaks to the new table */


CREATE TABLE layoffs_ND AS
	WITH CTE AS (
		SELECT *,
				ROW_NUMBER() OVER(
				PARTITION BY company,
				location,
				industry,
				total_laid_off,
				percentage_laid_off,
				date,
				stage,
				country,
				funds_raised_millions
			ORDER BY company ) AS row_num
		FROM layoffs_E
)
	SELECT *
		FROM  CTE
		WHERE row_num = 1;

-- Now we just moved the non duplicate (ND) rows to the new table called layoffs_ND
-- layoffs_E cantain 2561 rows but layoffs_ND cantain 2556 row (5 duplicate rows not taken)

-- OR we can delete the duplicated directly from the layoffs_E table by..

WITH duplicates AS (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            date,
                            stage,
                            country,
                            funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_E
)

DELETE FROM layoffs_E
WHERE ctid IN (
    SELECT ctid
    FROM duplicates
    WHERE row_num > 1 
);

-- NOW WE DROP THE 'row_num'

	ALTER 
		  TABLE layoffs_ND
		  DROP COLUMN row_num;
	
-- We now have a duplicate-free table (layoffs_ND).
-- From this point onward, we'll continue all data cleaning
-- and analysis using layoffs_ND instead of layoffs_E.


-- STEP 2 : STANDARDIZE THE DATA

-- FIRST WE REMOVE THE _SPACES in the begining of the name

SELECT
    company, TRIM(company),
    location, TRIM(location),
    industry, TRIM(industry),
    total_laid_off, TRIM(total_laid_off),
    percentage_laid_off, TRIM(percentage_laid_off),
    date, TRIM(date),
    stage, TRIM(stage),
    country, TRIM(country),
    funds_raised_millions, TRIM(funds_raised_millions)
FROM layoffs_ND;

UPDATE layoffs_ND
SET company                 = TRIM(company),
    location                = TRIM(location),
    industry                = TRIM(industry),
    total_laid_off          = TRIM(total_laid_off),
    percentage_laid_off     = TRIM(percentage_laid_off),
    date                    = TRIM(date),
    stage                   = TRIM(stage),
    country                 = TRIM(country),
    funds_raised_millions   = TRIM(funds_raised_millions);
	
-- Check all unique company names.
-- Purpose:
--   Identify inconsistent company names such as leading/trailing spaces,
--   different capitalizations, or spelling variations.
--
-- Expected Result:
--   A list of unique company names. Any inconsistent values found here
--   will be standardized in the next step.

SELECT 
	DISTINCT company
FROM layoffs_ND
ORDER BY company;

-- Company names are mostly unique (~1,900 distinct values),
-- so we'll only trim spaces and move on.

-- Next, we'll standardize the Industry column,
-- as it contains a limited set of repeated categories.

SELECT
	   DISTINCT industry
	FROM layoffs_ND
ORDER BY  industry;

-- FOUND Few with common name "CRYPTO"
-- Lets sort that first

SELECT industry
	FROM layoffs_ND
WHERE industry ILIKE  '%crypto%';

-- Found multiple values representing the same industry.
-- Standardize them into a single consistent value.

UPDATE layoffs_ND
SET industry = 'Crypto'
WHERE industry ILIKE 'crypto%';

-- ---------------------------------------------------------------------------------------------------
-- Now we deal with the country

SELECT 
		DISTINCT country
	FROM layoffs_ND
ORDER BY 1;

-- Found a flaw at United States lets fix it up

UPDATE 
		layoffs_ND
   SET  country  =  'United States'
   WHERE country ILIKE 'United States%';

-- There are no other changes needed to do,
-- Now lets Deal with 'location'

SELECT
		DISTINCT location
		FROM layoffs_ND
ORDER BY 1;

-- found a flaw at Malmö lets fix that

UPDATE 
		layoffs_ND
	SET location = 'Malmö'
	WHERE location ILIKE 'malmo%';

-- The 'date' column is currently stored as TEXT.
-- Convert it to PostgreSQL's DATE format for proper date operations.
--
-- Purpose:
--   Ensure the column can be used for sorting, filtering,
--   and date-based analysis.
--
-- Expected Result:
--   The second column displays the converted DATE values.

	SELECT
			DISTINCT date
			FROM  layoffs_ND
	ORDER BY date;

-- WE FOUND A CELL with value "NULL" & its a text value
-- Replace the text 'NULL' with an actual SQL NULL.
--
-- Purpose:
--   Convert invalid text values into proper NULL values before
--   changing the column datatype.
--
-- Expected Result:
--   Rows containing the string 'NULL' will become SQL NULLs.

	UPDATE  
		   layoffs_ND
		   SET date = NULL
	WHERE date LIKE 'NULL';
	
	SELECT 
		   date,
		   TO_DATE(date, 'MM/DD/YYYY')
	FROM layoffs_ND;

-- WE got the expected output and that looks fine, 
-- So lets Update the date

	UPDATE 
			layoffs_ND
	SET date = TO_DATE(date, 'MM-DD-YYYY');

-- Lets check it

	SELECT
		   DISTINCT date
		   FROM  layoffs_ND
	ORDER BY date;

-- Looks like the date is sorted ✅


-- BUT WE CAME ACROSS THE ISSUE  
-- just updating that just change the TEXT data into DATE (text)
-- THE DATA TYPE of TEXT still havent changed to DATE
-- WE can check the data type with the following query

/*
	SELECT column_name,
	       data_type
	  FROM information_schema.columns
	  WHERE table_name = 'layoffs_nd'
	  AND column_name = 'date';
*/

-- Lets actually change the DATATYPE of the date

	ALTER TABLE layoffs_ND
	ALTER column date
	TYPE DATE
	USING date::DATE;
	
-- :: is PostgreSQL's type cast operator.

-- It means:
-- "Convert this value to this datatype.";
-- EX - value::datatype
-- '100'::INT


-- The 'date' column is stored as TEXT in MM/DD/YYYY format.
-- Convert both the values and the datatype in a single step.
--
-- Purpose:
--   Convert the text dates into PostgreSQL DATE values.
--
-- Expected Result:
--   The column datatype becomes DATE and the values are stored correctly.

/*
	ALTER TABLE layoffs_ND
	ALTER COLUMN date
	TYPE DATE
	USING TO_DATE(date, 'MM/DD/YYYY');
*/
-- -------------------------------------------------------------------------------------------------------------------

-- STEP 3: Handle NULL and Blank Values
--
-- Purpose:
--   Identify and fix missing or incomplete data to improve
--   data quality before analysis and datatype conversions.
--
-- Expected Result:
--   Missing values are either corrected, replaced, or kept as
--   proper SQL NULLs where appropriate.


--  -- Check rows where both layoff-related columns are missing.
--
-- Purpose:
--   Identify records where both total_laid_off and
--   percentage_laid_off are NULL, as these rows may not
--   provide any useful layoff information.
--
-- Expected Result:
--   Returns rows where both values are NULL for further
--   inspection before deciding whether to keep or remove them.

	SELECT *
			FROM layoffs_ND
			WHERE total_laid_off IS NULL
		AND percentage_laid_off IS NULL;

	SELECT layoffs_ND.percentage_laid_off
			FROM layoffs_ND
			WHERE percentage_laid_off = 'NULL';

	UPDATE layoffs_ND
			SET percentage_laid_off = NULL
			WHERE percentage_laid_off = 'NULL';
-- -------------------------------------------------------------------------------------------------------------------
-- Next, we'll clean the total_laid_off column.
--
-- Purpose:
--   Check for invalid values, blanks, NULLs, and convert the column
--   to the appropriate numeric datatype.
--
-- Expected Result:
--   The total_laid_off column contains only valid numeric values
--   and is stored as an INTEGER.

	UPDATE layoffs_ND
		  SET total_laid_off = NULL
		  WHERE total_laid_off ILIKE 'NULL';

	SELECT 
		  DISTINCT total_laid_off
		  FROM layoffs_ND
	ORDER BY total_laid_off ASC;


-- CONVERTING TEXT TO INTEGER

	-- Check for non-numeric values before converting the column to INTEGER.
--
-- Purpose:
--   Identify any values that contain characters other than digits.
--   Such values would cause an error during datatype conversion.
--
-- Expected Result:
--   Ideally, this query should return 0 rows. If any rows are
--   returned, they must be cleaned or corrected before converting
--   the column to INTEGER.

	SELECT *
	FROM layoffs_ND
	WHERE total_laid_off !~ '^[0-9]+$'
	  AND total_laid_off IS NOT NULL;

	SELECT *
	FROM layoffs_ND
	WHERE percentage_laid_off !~ '^[0-9]+(\.[0-9]+)?$'
	  AND percentage_laid_off IS NOT NULL;

-- Everything seems normal now lets do the conversion

-- total_laid_off INTO INTEGER

	ALTER TABLE layoffs_ND
	ALTER COLUMN total_laid_off
	TYPE INTEGER
	USING total_laid_off :: INTEGER;

-- ✅

-- percentage_laid_off INTO DECIMAL

	
	ALTER TABLE layoffs_ND
	ALTER COLUMN percentage_laid_off
	TYPE NUMERIC
	USING percentage_laid_off :: NUMERIC;

-- ✅

-- Upto now we had faced severe issues while we sort data by order by in both %_laid_off & total_laid_off
-- Now the data type is being changed so we can run back that query 

	SELECT DISTINCT
			total_laid_off
		FROM layoffs_ND
		ORDER BY total_laid_off ASC;

	SELECT DISTINCT 
			percentage_laid_off
		FROM layoffs_ND
		ORDER BY percentage_laid_off ASC;

-- ✅

-- lets DEAL with funds_raised_millions

	SELECT DISTINCT 
				funds_raised_millions
			FROM layoffs_nd
	ORDER BY funds_raised_millions ASC;

	SELECT 
			funds_raised_millions
		FROM layoffs_nd
	WHERE funds_raised_millions !~ '^[0-9]+(\.[0-9]+)?$';

-- First lets convert those 'NULL' to NULL

	UPDATE 
		layoffs_ND
	SET 	
		funds_raised_millions = NULL
		WHERE funds_raised_millions = 'NULL';

-- found there are even the devimals in there so we need to convert it to NUMERIC

	ALTER TABLE layoffs_ND
	ALTER COLUMN funds_raised_millions
	TYPE  NUMERIC
	USING funds_raised_millions :: NUMERIC;

-- NOW LETS DEAL WITH STAGE

	SELECT DISTINCT
					stage
				FROM layoffs_ND
				ORDER BY stage ASC;

-- Replace the text value 'NULL' with an actual SQL NULL

-- across all columns in a single query.
--
-- Purpose:
--   Convert placeholder text values ('NULL') into proper SQL NULLs
--   before performing datatype conversions or further cleaning.
--
-- Expected Result:
--   Every occurrence of the string 'NULL' becomes an SQL NULL,
--   while all other values remain unchanged.

	UPDATE layoffs_ND
	SET company               = NULLIF(company, 'NULL'),
	    location              = NULLIF(location, 'NULL'),
	    industry              = NULLIF(industry, 'NULL'),
	    total_laid_off        = NULLIF(total_laid_off, 'NULL'),
	    percentage_laid_off   = NULLIF(percentage_laid_off, 'NULL'),
	    date                  = NULLIF(date, 'NULL'),
	    stage                 = NULLIF(stage, 'NULL'),
	    country               = NULLIF(country, 'NULL'),
	    funds_raised_millions = NULLIF(funds_raised_millions, 'NULL');

-- Replace the text value 'NULL' with an actual SQL NULL.
--
-- Purpose:
--   Some missing values were imported as the literal text 'NULL'
--   instead of SQL NULL. Before changing datatypes or performing
--   analysis, these placeholder values must be converted to proper
--   SQL NULLs.
--
-- Why?
--   SQL NULL represents missing or unknown data, whereas 'NULL' is
--   just a normal text string. Functions like SUM(), AVG(), COUNT(),
--   and datatype conversions treat them differently.
--
-- Expected Result:
--   Every occurrence of the string 'NULL' becomes an SQL NULL, while
--   all other values remain unchanged.

	UPDATE layoffs_ND
	SET company               = NULLIF(company, 'NULL'),
	    location              = NULLIF(location, 'NULL'),
	    industry              = NULLIF(industry, 'NULL'),
	    stage                 = NULLIF(stage, 'NULL'),
	    country               = NULLIF(country, 'NULL');

-- BACK TO STAGE

	SELECT DISTINCT
					stage
					FROM layoffs_ND
					ORDER BY stage ASC;

-- NOW LETS DEAL WITH THE NULLS
-- lets see how many NULL exist per each column

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE company IS NULL; 		        -- COUNT 0

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE industry IS NULL;		        -- COUNT 4

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE location IS NULL;		        -- COUNT 0

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE total_laid_off IS NULL;       -- COUNT 739

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE percentage_laid_off IS NULL; 	-- COUNT 784

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE date IS NULL;					-- COUNT 1

	SELECT COUNT(*)
			FROM layoffs_ND
	WHERE funds_raised_millions IS NULL; -- COUNT 209


-- OR

	SELECT
    	  COUNT(*) FILTER (WHERE company IS NULL) AS company_NULL,
    	  COUNT(*) FILTER (WHERE location IS NULL) AS location_NULL,
    	  COUNT(*) FILTER (WHERE industry IS NULL) AS industry_NULL,
    	  COUNT(*) FILTER (WHERE total_laid_off IS NULL) AS total_laid_off_NULL,
    	  COUNT(*) FILTER (WHERE percentage_laid_off IS NULL) AS percentage_laid_off_NULL,
    	  COUNT(*) FILTER (WHERE date IS NULL) AS date_NULL,
    	  COUNT(*) FILTER (WHERE stage IS NULL) AS stage_NULL,
    	  COUNT(*) FILTER (WHERE country IS NULL) AS country_NULL,
    	  COUNT(*) FILTER (WHERE funds_raised_millions IS NULL) AS funds_raised_millions_NULL
	FROM layoffs_ND;

-- Now lets START with dealing with the NULL of industry 
--
-- Some rows have a missing value in the Industry column.
--
-- Plan of Action:
--   Check whether these companies appear elsewhere in the dataset
--   with a valid industry value. If they do, fill the missing
--   industry using that existing information.
--
-- Why?
--   A company's industry is generally consistent across records,
--   making it safe to infer missing values from other rows
--   belonging to the same company.
--
-- Expected Result:
--   Missing industry values are filled wherever a reliable match
--   exists. Any rows without sufficient evidence will remain NULL.

	SELECT *
			FROM layoffs_ND
			WHERE industry IS NULL;
			
	SELECT *
			FROM layoffs_ND
			WHERE company = 'Airbnb';

-- Find rows where the Industry is missing, but another row
-- for the same company and location has a valid Industry.
--
-- Purpose:
--   Identify missing Industry values that can be safely filled
--   using existing data from the same company and location.
--
-- Expected Result:
--   Returns pairs of matching rows where t1 has a NULL Industry
--   and t2 contains the corresponding valid Industry.

	SELECT *
			FROM layoffs_ND t1
			JOIN layoffs_ND t2
				ON t1.company = t2.company
				AND t1.location = t2.location
			WHERE t1.industry IS NULL
			AND t2.industry IS NOT NULL;

-- The matching rows confirmed that the missing Industry values
-- can be safely inferred from other records belonging to the
-- same company and location.
--
-- We now update those NULL Industry values using the existing
-- non-NULL Industry values from the matching rows.
--
-- Expected Result:
--   Only rows with a NULL Industry are updated, while all other
--   records remain unchanged.

	UPDATE layoffs_ND t1
		SET industry = t2.industry
		FROM layoffs_ND t2
	WHERE  
			t1.company = t2.company
		AND t1.location = t2.location
		AND t1.industry IS NULL 
		AND t2.industry IS NOT NULL;


		SELECT  *
		FROM layoffs_ND
		WHERE industry IS NULL;

--  Well a row with company name ' Bally's Interactive ' has a NULL
--	Lets fix that 

	SELECT * 
		FROM layoffs_ND
		WHERE company ILIKE 'bally%';
-- Found no matching results with this company

-- Lets see the rows with companies with both total_laid_off & %_laid_off were NULL

	SELECT *
		FROM layoffs_ND
	WHERE total_laid_off IS NULL
	AND	  percentage_laid_off IS NULL;

-- Suprisingly we've Found 361Rows with both total_laid_off & %_laid_off were NULL
-- Those rows aren't useful, So lets Drop them

	DELETE
		FROM layoffs_ND
	WHERE total_laid_off IS NULL
	AND	  percentage_laid_off IS NULL;

-- Well that was about cleaning the data 
