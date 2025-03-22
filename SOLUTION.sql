SELECT *
FROM netflix;

SELECT
  COUNT(*) AS total_content
FROM netflix;

SELECT
 DISTINCT type
FROM netflix;

SELECT
 DISTINCT rating
FROM netflix;


/*
CREATED BY: OLUBUNMI ADEOLU
DATE: 15/03/2025
DESCRIPTION: ANALYSIS OF NETFLIX DATA SET(15 BUSINESS PROBLEMS AND SOLUTIONS)
*/

--- 1. COUNT THE NUMBER OF MOVIES VS TV SHOWS

SELECT
 type,
 COUNT(*) as total_content
FROM 
 netflix
GROUP BY type;

-----2.FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS

SELECT
 Distinct rating,
  type
FROM netflix;

SELECT type, rating, COUNT(*) AS rating_count
FROM netflix
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY type, rating_count DESC;


SELECT
 type,
 rating
FROM

    (SELECT 
      type,
      rating, 
      COUNT(*),
      RANK()OVER(PARTITION BY type ORDER BY COUNT(*)DESC) as ranking
    FROM netflix
    GROUP BY 1, 2) as ranked_rating
 WHERE ranking = 1

--- 3. LIST ALL MOVIES RELEASED IN A SPECIFIC YEAR (e.g 2020)

SELECT * FROM netflix
WHERE
  type = 'Movie' 
  AND release_year = 2020

  ---4. FIND THE TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX

  SELECT 
    country, 
    COUNT(*) AS content_count
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;

 SELECT 
    country, 
    COUNT(show_id) AS content_count
FROM netflix
GROUP BY 1

SELECT
 STRING_TO_ARRAY(country,',') as new_country
FROM netflix

SELECT
 UNNEST(STRING_TO_ARRAY(country,',')) as new_country
FROM netflix

SELECT 
   UNNEST(STRING_TO_ARRAY(country,',')) as new_country,  
   COUNT (show_id) AS content_count
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

---5 IDENTIFY THE LONGEST MOVIE

SELECT * FROM netflix
WHERE type = 'Movie'

--GROUP BY type
--ORDER BY duration

SELECT 
    title, 
    duration 
FROM netflix 
WHERE type = 'Movie'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;


SELECT * FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration)FROM netflix)
  
SELECT * 
FROM netflix
WHERE type = 'Movie'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) = 
    (SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)) FROM netflix WHERE type = 'Movie');

-- FIND THE CONTENT ADDED IN THE LAST 5 YEARS

SELECT * 
FROM netflix
WHERE date_added IS NOT NULL
AND CAST(date_added AS DATE) >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY date_added DESC;

SELECT * 
FROM netflix
WHERE date_added >= CURRENT_DATE - INTERVAL '5 YEARS'

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATE - INTERVAL '5 YEARS'
AND date_added IS NOT NULL
ORDER BY TO_DATE(date_added, 'Month DD, YYYY') DESC


SELECT 
SPLIT_PART('APPLE, BANANA, MANGO', ' ',3)

--- 7 LIST ALL TV SHOWS WITH MORE THAN 5 SEASONS
SELECT * 
FROM netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

SELECT * 
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

--8 FIND ALL THE MOVIES/TV SHOWS BY DIRECTOR 'Rajiv Chilaka'

SELECT * 
FROM netflix
WHERE director = 'Rajiv Chilaka';

SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--9 COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE

SELECT 
   UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
   COUNT(*) AS content_count
FROM netflix
GROUP BY 1
ORDER BY content_count DESC;

SELECT
 UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
 COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC;

--10 FIND EACH YEAR AND AVERAGE NUMBERS OF CONTENT RELEASED IN INDIA ON netflix,
--release top 5 year with highest avg content release

SELECT
TO_DATE(date_added,'Month DD, YYYY')
FROM netflix



SELECT
COUNT(*) FROM netflix
WHERE country = 'India'

SELECT
  EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY') )AS year,
  COUNT(*) as yearly_content,
 ROUND (COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India'):: numeric * 100 
  ,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5





SELECT
  EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS release_year,
  COUNT(*) AS yearly_content,
  ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(DISTINCT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))) 
                             FROM netflix WHERE country = 'India'), 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY yearly_content DESC
LIMIT 5;


SELECT COUNT(DISTINCT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))) AS number_of_years
FROM netflix
WHERE country = 'India';


-- 11 list all movies that are documentaries

SELECT * FROM netflix
WHERE
  listed_in  ILIKE '%documentaries%'

SELECT * 
FROM netflix
WHERE type = 'Movie' 
AND listed_in ILIKE '%Documentaries%';


--- 12 Find all content without director

SELECT * 
FROM netflix
WHERE  director IS NULL


SELECT * 
FROM netflix
WHERE director IS NULL OR director = ''

--13 Find how many movies  actor 'Salman Khan' appeared in the last 10 years?

SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND 
release_year >= EXTRACT(YEAR FROM CURRENT_DATE) -10


SELECT COUNT(*) AS num_movies
FROM netflix
WHERE type = 'Movie'
AND casts ILIKE '%Salman Khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;


---14 Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
 --show_id,
 --casts,
 UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
 COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actor, 
    COUNT(*) AS num_movies
FROM netflix
WHERE type = 'Movie' 
AND country ILIKE '%India%'
AND casts IS NOT NULL
GROUP BY actor
ORDER BY num_movies DESC
LIMIT 10


---15 Categorize the content based  on the experience  of the keywords 'kill' and 'violence' in the 
--description field, label content containing these keywords as 'Bad' and all other content as 'Good'. Count  how many items  fall into each category.

WITH new_table
AS

(SELECT
*,
  CASE
  WHEN
      description ILIKE '%kill%' OR
	  description ILIKE '%violence%' THEN 'Bad_Content'
	  ELSE 'Good_Content'
  END category
FROM netflix
)
SELECT 
     category,
	 COUNT(*) AS total_content
FROM new_table
GROUP BY 1

SELECT 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_count
FROM netflix
GROUP BY content_category;

