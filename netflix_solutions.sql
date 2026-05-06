--netflix project
DROP TABLE IF EXISTS netflix; 
CREATE TABLE netflix 
(
	show_id	    varchar(5),
	type	    varchar(10),
	title	    varchar(150),
	director    varchar(208),
	casts        varchar(1000),
	country	    varchar(150),
	date_added	varchar(50),
	release_year	int,
	rating	        varchar(10),
	duration	    varchar(15),
	listed_in	    varchar(100),
	description     varchar(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

--to check different type of content available
SELECT DISTINCT type FROM netflix;

--1- Count the number of Movies VS TV shows
SELECT 
  type,
  COUNT(*) as total_count
FROM netflix GROUP BY type;

--2-Find the most common rating for movies and TV shows
SELECT 
  type,
  rating
FROM
(
  SELECT 
    type,
    rating,
    COUNT(*),
    RANK() OVER(PARTITION BY type ORDER BY COUNT(*) Desc) as ranking --ranks in desc, RANK() window function
  FROM netflix GROUP BY 1,2 )as t1 
WHERE ranking=1;--choosing for both movies and tvs with the highest rank

--3-List all movies released in a specific year (eg-2020)
SELECT * FROM netflix 
WHERE type='Movie' AND release_year = 2020;

--4-Find the top 5 countries with the most content on netflix
--first slit countries name column
SELECT
  UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, --separate the country name after splitting into array
  COUNT(show_id) as total_content
FROM netflix GROUP BY 1 
ORDER BY 2 Desc 
LIMIT 5;

--5- Find the longest movie
SELECT* FROM netflix
WHERE 
  type='Movie'
  AND
  duration = (SELECT MAX(Duration) FROM netflix);


--6- Find the content added in the last 5 years
SELECT * FROM netflix
WHERE 
  TO_DATE (date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' --TO_DATE (date_added, 'Month DD, YYYY') =convert to date and give the current format also
  
--7- Find all the movies and TV shows done by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'; --multiple directors name so use regex, ILIKE- doesn't consider case sensitivity

--8- List all the TV shows with more than 5 seasons
SELECT * FROM netflix
WHERE 
  type='TV Show'
  AND
  SPLIT_PART(duration, ' ',1)::numeric > 5;  --SPLIT_PART(duration, ' ',1)::numeric ->split durtion into 2 parts and choose the first part and convert to numeric


--9- Count the number of content items in each genre
--first split the different genres in listed_in columns , use unnest and split to arrays and then do group by

SELECT 
   UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
   Count(show_id) as Total_content
FROM netflix GROUP BY 1


--10- Find each year and the average numbers of content release by India on netflix, return top 5 year
-- with highest avg content release

SELECT 
  EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as year,
  COUNT (*) as yearly_content,
  ROUND(
  COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix where country='India')::numeric *100,2) AS avg_content_per_year --2nd part is total content release by india, ROUNDto round off the %
FROM netflix
WHERE country = 'India'
Group by 1


--11- List all the movies that are documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--12-find all the content without a director
SELECT * FROM netflix
WHERE director IS NULL;

--13- Find how many movies actor Salman Khan appeared in last 10 years
SELECT * FROM netflix
where 
  casts ILIKE '%salman khan%'
  AND
  release_year > EXTRACT( YEAR FROM CURRENT_DATE) - 10;

--14- Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT (*) as total_content
FROM netflix where country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 Desc
LIMIT 10

--15- Categorize the content based on the presence of keywords 'kill' and 'violence' in the description
-- field. Label content containing these keywords as 'Bad' and all other content as 'Good' .
-- Count how many items fall into each category.

WITH new_table
AS
(
SELECT * ,
  CASE 
  WHEN  description ILIKE '%kills%'  OR
        description ILIKE '%violence%'   THEN 'BAD_CONTENT'
		ELSE 'GOOD_CONTENT'
  END Category
FROM netflix 
)
SELECT
  category,
  count(*) AS total_content
FROM new_table
GROUP BY 1
